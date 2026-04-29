-- ╔══════════════════════════════════════════════╗
-- ║  pages.lua  — Yi Da Mu Sake  v8.3            ║
-- ╚══════════════════════════════════════════════╝

-- ── Module-level constants (no service calls here) ───────────────────────────
local TELEPORT_LOCATIONS = {
    "Starter","Jungle","Desert","Snow","Sailor","Shibuya",
    "HollowIsland","Boss","Dungeon","Shinjuku","Slime",
    "Academy","Judgement","Ninja","Lawless","Tower"
}
local FARM_ISLANDS = {
    "Starter Island","Jungle Island","Desert Island","Snow Island",
    "Shibuya","Hollow","Shinjuku Island#1","Shinjuku Island#2",
    "Slime","Academy","Judgement","Soul Dominion","Ninja","Lawless"
}
local KNOWN_BOSSES = {
    "AizenBoss","AlucardBoss","JinwooBoss","SukunaBoss",
    "YujiBoss","GojoBoss","KnightBoss","YamatoBoss","StrongestShinobiBoss"
}

-- ── Timer helpers ─────────────────────────────────────────────────────────────
local function findTimerTextLabel(container)
    for _,desc in ipairs(container:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local txt = desc.Text or ""
            if txt:match("^%d+:%d%d$") or txt:match("^%d+:%d%d:%d%d$") then
                return desc
            end
        end
    end
    return nil
end

local function parseTimerSecs(text)
    if not text then return -1 end
    local h,m,s = text:match("^(%d+):(%d+):(%d+)$")
    if h then return tonumber(h)*3600 + tonumber(m)*60 + tonumber(s) end
    local m2,s2 = text:match("^(%d+):(%d+)$")
    if m2 then return tonumber(m2)*60 + tonumber(s2) end
    return -1
end

-- ── Notification factory ──────────────────────────────────────────────────────
-- Stacks from bottom-right upward; each notif slides in from right.
local function makeNotifier(gui, T, TweenService)
    local NOTIF_W   = 272
    local NOTIF_H   = 60
    local NOTIF_GAP = 5
    local MARGIN_X  = 10
    local MARGIN_Y  = 10
    local stack     = {}  -- {frame, _done}

    local function recalc()
        local baseY = -MARGIN_Y
        for i = #stack, 1, -1 do
            local e = stack[i]
            if e and e.frame and e.frame.Parent then
                local targetY = baseY - NOTIF_H
                TweenService:Create(e.frame,
                    TweenInfo.new(0.20, Enum.EasingStyle.Quint),
                    {Position = UDim2.new(1, -(NOTIF_W + MARGIN_X), 1, targetY)}
                ):Play()
                baseY = baseY - NOTIF_H - NOTIF_GAP
            end
        end
    end

    local function dismiss(entry)
        if entry._done then return end
        entry._done = true
        if entry.frame and entry.frame.Parent then
            TweenService:Create(entry.frame,
                TweenInfo.new(0.18, Enum.EasingStyle.Quint),
                {Position = UDim2.new(1, MARGIN_X, entry.frame.Position.Y.Scale,
                    entry.frame.Position.Y.Offset)}
            ):Play()
            task.delay(0.20, function() pcall(function() entry.frame:Destroy() end) end)
        end
        for i,e in ipairs(stack) do
            if e == entry then table.remove(stack, i); break end
        end
        recalc()
    end

    return function(title, subtitle, col)
        pcall(function()
            local snd = Instance.new("Sound")
            snd.SoundId = "rbxassetid://9118377284"
            snd.Volume  = 0.55
            snd.Parent  = game:GetService("SoundService")
            game:GetService("SoundService"):PlayLocalSound(snd)
            game:GetService("Debris"):AddItem(snd, 4)
        end)

        local accentCol = col or T.green

        local frame = Instance.new("Frame", gui)
        frame.Size             = UDim2.new(0, NOTIF_W, 0, NOTIF_H)
        frame.Position         = UDim2.new(1, MARGIN_X, 1, -MARGIN_Y - NOTIF_H)
        frame.BackgroundColor3 = Color3.fromRGB(13,12,22)
        frame.BorderSizePixel  = 0
        frame.ZIndex           = 650
        frame.ClipsDescendants = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

        local ns = Instance.new("UIStroke", frame)
        ns.Color = accentCol; ns.Thickness = 1.4; ns.Transparency = 0.05

        local prog = Instance.new("Frame", frame)
        prog.Size             = UDim2.new(1,0,0,2)
        prog.Position         = UDim2.new(0,0,1,-2)
        prog.BackgroundColor3 = accentCol
        prog.BorderSizePixel  = 0; prog.ZIndex = 652
        Instance.new("UICorner", prog).CornerRadius = UDim.new(1,0)

        local leftBar = Instance.new("Frame", frame)
        leftBar.Size             = UDim2.new(0,3,1,-14)
        leftBar.Position         = UDim2.new(0,8,0,7)
        leftBar.BackgroundColor3 = accentCol
        leftBar.BorderSizePixel  = 0
        Instance.new("UICorner", leftBar).CornerRadius = UDim.new(1,0)

        local tl = Instance.new("TextLabel", frame)
        tl.Size               = UDim2.new(1,-30,0,22)
        tl.Position           = UDim2.new(0,18,0,6)
        tl.BackgroundTransparency = 1
        tl.Text               = title or ""
        tl.TextColor3         = T.white
        tl.Font               = Enum.Font.GothamBold
        tl.TextSize           = 13
        tl.TextXAlignment     = Enum.TextXAlignment.Left
        tl.TextTruncate       = Enum.TextTruncate.AtEnd
        tl.ZIndex             = 651

        local sl = Instance.new("TextLabel", frame)
        sl.Size               = UDim2.new(1,-30,0,14)
        sl.Position           = UDim2.new(0,18,0,32)
        sl.BackgroundTransparency = 1
        sl.Text               = subtitle or ""
        sl.TextColor3         = T.textSub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize           = 10
        sl.TextXAlignment     = Enum.TextXAlignment.Left
        sl.TextTruncate       = Enum.TextTruncate.AtEnd
        sl.ZIndex             = 651

        local xBtn = Instance.new("TextButton", frame)
        xBtn.Size               = UDim2.new(0,16,0,16)
        xBtn.Position           = UDim2.new(1,-19,0,4)
        xBtn.BackgroundTransparency = 1
        xBtn.Text               = "x"
        xBtn.TextColor3         = T.textDim
        xBtn.Font               = Enum.Font.GothamBold
        xBtn.TextSize           = 10
        xBtn.ZIndex             = 653

        local entry = {frame=frame, _done=false}
        table.insert(stack, entry)
        recalc()

        local SHOW = 4.5
        TweenService:Create(prog,
            TweenInfo.new(SHOW, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0,0,0,2)}
        ):Play()
        task.delay(SHOW, function() dismiss(entry) end)
        xBtn.MouseButton1Click:Connect(function() dismiss(entry) end)
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
--  MAIN EXPORT — everything inside this closure has correct access to lib/T/etc
-- ═════════════════════════════════════════════════════════════════════════════
return function(lib, sideData, contentArea, bgF, root, rootCorner, rootStroke, rootGlow, particleList, spawnParticles, applyUIBgMode, applyMiniBgMode, gui)

    local T           = lib.T
    local UISettings  = lib.UISettings
    local smooth      = lib.smooth
    local ripple      = lib.ripple
    local TweenService = game:GetService("TweenService")
    local Players      = game:GetService("Players")
    local LocalPlayer  = Players.LocalPlayer

    local mkScrollPage   = lib.mkScrollPage
    local mkTwoColLayout = lib.mkTwoColLayout
    local mkGroupBox     = lib.mkGroupBox
    local mkSectionLabel = lib.mkSectionLabel
    local mkSection      = lib.mkSection
    local mkStatus       = lib.mkStatus
    local mkSlider       = lib.mkSlider
    local mkToggle       = lib.mkToggle
    local mkOnOffBtn     = lib.mkOnOffBtn
    local mkDropdownV2   = lib.mkDropdownV2
    local mkSubTabBar    = lib.mkSubTabBar
    local mkCard         = lib.mkCard

    local showNotif = makeNotifier(gui, T, TweenService)

    -- ══════════════════════════════════════════════
    -- INFO PAGE
    -- ══════════════════════════════════════════════
    local infoSF = mkScrollPage(sideData["Info"].page)
    mkSection(infoSF, "Boss Countdown", 1)

    local irBtn = Instance.new("TextButton", infoSF)
    irBtn.Size             = UDim2.new(1,0,0,30)
    irBtn.BackgroundColor3 = Color3.fromRGB(20,18,34)
    irBtn.Text             = "Refresh Timer"
    irBtn.TextColor3       = T.textSub
    irBtn.Font             = Enum.Font.GothamBold
    irBtn.TextSize         = 11
    irBtn.BorderSizePixel  = 0
    irBtn.LayoutOrder      = 2
    irBtn.ZIndex           = 6
    Instance.new("UICorner", irBtn).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", irBtn).Color        = T.borderBright

    local timerContainer = Instance.new("Frame", infoSF)
    timerContainer.BackgroundTransparency = 1
    timerContainer.Size           = UDim2.new(1,0,0,0)
    timerContainer.AutomaticSize  = Enum.AutomaticSize.Y
    timerContainer.BorderSizePixel = 0
    timerContainer.LayoutOrder    = 3
    local tcL = Instance.new("UIListLayout", timerContainer)
    tcL.Padding   = UDim.new(0,5)
    tcL.SortOrder = Enum.SortOrder.LayoutOrder

    local timerEntries = {}

    local function buildTimerCards()
        for _,c in ipairs(timerContainer:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        timerEntries = {}
        local found = 0
        for _,child in ipairs(workspace:GetChildren()) do
            local bossName = child.Name:match("^TimedBossSpawn_(.+)_Container$")
            if bossName then
                found = found + 1
                local timerLbl = findTimerTextLabel(child)
                local card = Instance.new("Frame", timerContainer)
                card.Size             = UDim2.new(1,0,0,52)
                card.BackgroundColor3 = Color3.fromRGB(14,13,22)
                card.BorderSizePixel  = 0
                card.LayoutOrder      = found
                card.ZIndex           = 5
                Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
                local cs  = Instance.new("UIStroke", card)
                cs.Color = T.border; cs.Transparency = 0.25; cs.Thickness = 0.8
                local abar = Instance.new("Frame", card)
                abar.Size             = UDim2.new(0,3,1,-14)
                abar.Position         = UDim2.new(0,8,0,7)
                abar.BackgroundColor3 = T.accentDim
                abar.BorderSizePixel  = 0
                Instance.new("UICorner", abar).CornerRadius = UDim.new(1,0)
                local nameL = Instance.new("TextLabel", card)
                nameL.Size               = UDim2.new(0.55,0,0,20)
                nameL.Position           = UDim2.new(0,18,0,8)
                nameL.BackgroundTransparency = 1
                nameL.Text               = bossName
                nameL.TextColor3         = T.text
                nameL.Font               = Enum.Font.GothamBold
                nameL.TextSize           = 12
                nameL.TextXAlignment     = Enum.TextXAlignment.Left
                nameL.ZIndex             = 6
                local dispTimer = Instance.new("TextLabel", card)
                dispTimer.Size               = UDim2.new(0.45,-18,0,20)
                dispTimer.Position           = UDim2.new(0.55,0,0,8)
                dispTimer.BackgroundTransparency = 1
                dispTimer.Text               = timerLbl and timerLbl.Text or "..."
                dispTimer.TextColor3         = T.accentGlow
                dispTimer.Font               = Enum.Font.GothamBold
                dispTimer.TextSize           = 13
                dispTimer.TextXAlignment     = Enum.TextXAlignment.Right
                dispTimer.ZIndex             = 6
                local dispStatus = Instance.new("TextLabel", card)
                dispStatus.Size               = UDim2.new(1,-24,0,12)
                dispStatus.Position           = UDim2.new(0,18,0,32)
                dispStatus.BackgroundTransparency = 1
                dispStatus.Text               = timerLbl and "Timer aktif" or "Belum ditemukan"
                dispStatus.TextColor3         = timerLbl and T.textDim or T.amber
                dispStatus.Font               = Enum.Font.Gotham
                dispStatus.TextSize           = 9
                dispStatus.TextXAlignment     = Enum.TextXAlignment.Left
                dispStatus.ZIndex             = 6
                table.insert(timerEntries, {
                    container=child, bossName=bossName,
                    timerLbl=timerLbl, dispTimer=dispTimer,
                    dispStatus=dispStatus, cardStroke=cs,
                    accentBar=abar, prevSecs=-1
                })
            end
        end
        if found == 0 then
            local el = Instance.new("TextLabel", timerContainer)
            el.Size               = UDim2.new(1,0,0,30)
            el.BackgroundTransparency = 1
            el.Text               = "Tidak ada TimedBossSpawn di workspace"
            el.TextColor3         = T.textDim
            el.Font               = Enum.Font.Gotham
            el.TextSize           = 10
            el.LayoutOrder        = 1
            el.TextXAlignment     = Enum.TextXAlignment.Center
        end
    end

    buildTimerCards()
    irBtn.MouseButton1Click:Connect(function()
        ripple(irBtn, irBtn.AbsoluteSize.X*0.5, irBtn.AbsoluteSize.Y*0.5, T.accent)
        buildTimerCards()
    end)

    task.spawn(function()
        while infoSF and infoSF.Parent do
            for _,e in ipairs(timerEntries) do
                pcall(function()
                    if not e.timerLbl or not e.timerLbl.Parent then
                        local f = findTimerTextLabel(e.container)
                        if f then
                            e.timerLbl = f
                            e.dispStatus.Text      = "Timer OK"
                            e.dispStatus.TextColor3 = T.green
                        else
                            e.dispTimer.Text        = "?"
                            e.dispStatus.Text       = "Belum ada timer"
                            e.dispStatus.TextColor3 = T.amber
                            return
                        end
                    end
                    local txt  = e.timerLbl.Text or ""
                    e.dispTimer.Text = (txt ~= "" and txt or "?")
                    local secs = parseTimerSecs(txt)
                    if secs == 0 and e.prevSecs > 0 then
                        showNotif(e.bossName .. " Spawned!", "Boss telah muncul di map!", T.green)
                    end
                    e.prevSecs = secs
                    if secs < 0 then
                        e.dispTimer.TextColor3 = T.textDim
                        e.dispStatus.Text      = "Format: " .. txt
                        smooth(e.cardStroke, {Color=T.border}, 0.3):Play()
                        smooth(e.accentBar,  {BackgroundColor3=T.textDim}, 0.3):Play()
                    elseif secs == 0 then
                        e.dispTimer.TextColor3 = T.green
                        e.dispStatus.Text      = "Spawn sekarang!"
                        smooth(e.cardStroke, {Color=T.green}, 0.3):Play()
                        smooth(e.accentBar,  {BackgroundColor3=T.green}, 0.3):Play()
                    elseif secs < 60 then
                        e.dispTimer.TextColor3 = T.amber
                        e.dispStatus.Text      = "Segera spawn!"
                        smooth(e.cardStroke, {Color=T.amber}, 0.3):Play()
                        smooth(e.accentBar,  {BackgroundColor3=T.amber}, 0.3):Play()
                    else
                        e.dispTimer.TextColor3 = T.accentGlow
                        e.dispStatus.Text      = "Menunggu..."
                        smooth(e.cardStroke, {Color=T.border}, 0.3):Play()
                        smooth(e.accentBar,  {BackgroundColor3=T.accentDim}, 0.3):Play()
                    end
                end)
            end
            task.wait(1)
        end
    end)

    -- ══════════════════════════════════════════════
    -- MAIN PAGE  (Farm / TP / Boss / Dungeon)
    -- ══════════════════════════════════════════════
    local mainPage  = sideData["Main"].page
    local mainInner = Instance.new("Frame", mainPage)
    mainInner.Size             = UDim2.new(1,-8,1,-8)
    mainInner.Position         = UDim2.new(0,4,0,4)
    mainInner.BackgroundTransparency = 1
    mainInner.ZIndex           = 3
    local subPages = mkSubTabBar(mainInner, {"Farm","TP","Boss","Dungeon"})

    -- ── FARM ─────────────────────────────────────────────────────────────────
    local leftF, rightF = mkTwoColLayout(subPages["Farm"], T.border)

    local farmGroup = mkGroupBox(leftF, 1)
    mkSectionLabel(farmGroup, "Pulau & Mode", 1)
    local _, getIsland   = mkDropdownV2(farmGroup,"Pulau","*",Color3.fromRGB(78,46,200),FARM_ISLANDS,"Starter Island",nil,2)
    local _, getFarmMode = mkDropdownV2(farmGroup,"Mode","o",Color3.fromRGB(50,130,200),{"V1 - Semua Titik","V2 - Titik Tengah"},"V1 - Semua Titik",nil,3)
    local _, setFarmOnOff, getFarmOn, setFarmCallback = mkOnOffBtn(farmGroup,"Auto Farm + Quest",4)
    local _, _, getAutoHitOn = mkToggle(farmGroup,"Kill Aura",false,nil,5)

    -- ── TP LOOP GROUP ─────────────────────────────────────────────────────────
    local tpLoopGroup = mkGroupBox(leftF, 2)
    mkSectionLabel(tpLoopGroup, "TP Loop (2 Titik)", 1)

    -- default coordinates
    local DEF_A = {x=-203.174, y=22.093,  z=-420.721}
    local DEF_B = {x=-309.006, y=-3.667, z=-148.328}

    -- status label
    local tpLoopStatFrame = Instance.new("Frame", tpLoopGroup)
    tpLoopStatFrame.Size               = UDim2.new(1,0,0,18)
    tpLoopStatFrame.BackgroundTransparency = 1
    tpLoopStatFrame.BorderSizePixel    = 0
    tpLoopStatFrame.LayoutOrder        = 2
    local tpLoopStatLbl = Instance.new("TextLabel", tpLoopStatFrame)
    tpLoopStatLbl.Size               = UDim2.new(1,0,1,0)
    tpLoopStatLbl.BackgroundTransparency = 1
    tpLoopStatLbl.Text               = "Idle"
    tpLoopStatLbl.TextColor3         = T.textDim
    tpLoopStatLbl.Font               = Enum.Font.Gotham
    tpLoopStatLbl.TextSize           = 9
    tpLoopStatLbl.TextXAlignment     = Enum.TextXAlignment.Center
    tpLoopStatLbl.ZIndex             = 6

    local function setTpLoopStat(txt, col)
        if tpLoopStatLbl and tpLoopStatLbl.Parent then
            tpLoopStatLbl.Text = txt or "Idle"
            if col then smooth(tpLoopStatLbl, {TextColor3=col}, 0.15):Play() end
        end
    end

    local _, setTpLoopOnOff, getTpLoopOn, setTpLoopCallback = mkOnOffBtn(tpLoopGroup,"TP Loop",3)

    -- helper: single coordinate row (label + textbox)
    local function mkCoordBox(parent, labelTxt, initVal, order)
        local row = Instance.new("Frame", parent)
        row.Size             = UDim2.new(1,0,0,26)
        row.BackgroundColor3 = Color3.fromRGB(14,13,22)
        row.BorderSizePixel  = 0
        row.LayoutOrder      = order
        row.ZIndex           = 5
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
        local rs = Instance.new("UIStroke", row)
        rs.Color = T.border; rs.Transparency = 0.45; rs.Thickness = 0.7
        local lbl = Instance.new("TextLabel", row)
        lbl.Size               = UDim2.new(0,18,1,0)
        lbl.Position           = UDim2.new(0,8,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = labelTxt
        lbl.TextColor3         = T.accentGlow
        lbl.Font               = Enum.Font.GothamBold
        lbl.TextSize           = 10
        lbl.ZIndex             = 6
        lib.regAccent("txtGlow", lbl)
        local box = Instance.new("TextBox", row)
        box.Size               = UDim2.new(1,-30,1,-6)
        box.Position           = UDim2.new(0,26,0,3)
        box.BackgroundTransparency = 1
        box.Text               = tostring(initVal)
        box.TextColor3         = T.text
        box.PlaceholderColor3  = T.textDim
        box.Font               = Enum.Font.Gotham
        box.TextSize           = 10
        box.TextXAlignment     = Enum.TextXAlignment.Left
        box.ClearTextOnFocus   = false
        box.ZIndex             = 7
        box.Focused:Connect(function() smooth(rs,{Color=T.accentGlow,Transparency=0.05},0.15):Play() end)
        box.FocusLost:Connect(function() smooth(rs,{Color=T.border,Transparency=0.45},0.15):Play() end)
        return box
    end

    -- Coord A
    mkSectionLabel(tpLoopGroup, "Koordinat A", 4)
    local coordAFrame = Instance.new("Frame", tpLoopGroup)
    coordAFrame.Size               = UDim2.new(1,0,0,0)
    coordAFrame.AutomaticSize      = Enum.AutomaticSize.Y
    coordAFrame.BackgroundTransparency = 1
    coordAFrame.BorderSizePixel    = 0
    coordAFrame.LayoutOrder        = 5
    local coordAList = Instance.new("UIListLayout", coordAFrame)
    coordAList.Padding   = UDim.new(0,3)
    coordAList.SortOrder = Enum.SortOrder.LayoutOrder
    local axBox = mkCoordBox(coordAFrame,"X",DEF_A.x,1)
    local ayBox = mkCoordBox(coordAFrame,"Y",DEF_A.y,2)
    local azBox = mkCoordBox(coordAFrame,"Z",DEF_A.z,3)

    -- Coord B
    mkSectionLabel(tpLoopGroup, "Koordinat B", 6)
    local coordBFrame = Instance.new("Frame", tpLoopGroup)
    coordBFrame.Size               = UDim2.new(1,0,0,0)
    coordBFrame.AutomaticSize      = Enum.AutomaticSize.Y
    coordBFrame.BackgroundTransparency = 1
    coordBFrame.BorderSizePixel    = 0
    coordBFrame.LayoutOrder        = 7
    local coordBList = Instance.new("UIListLayout", coordBFrame)
    coordBList.Padding   = UDim.new(0,3)
    coordBList.SortOrder = Enum.SortOrder.LayoutOrder
    local bxBox = mkCoordBox(coordBFrame,"X",DEF_B.x,1)
    local byBox = mkCoordBox(coordBFrame,"Y",DEF_B.y,2)
    local bzBox = mkCoordBox(coordBFrame,"Z",DEF_B.z,3)

    -- "Use current position" buttons
    local function mkSetPosBtn(parent, label, order, onClick)
        local btn = Instance.new("TextButton", parent)
        btn.Size             = UDim2.new(1,0,0,24)
        btn.BackgroundColor3 = Color3.fromRGB(20,18,38)
        btn.Text             = label
        btn.TextColor3       = T.accentGlow
        btn.Font             = Enum.Font.GothamBold
        btn.TextSize         = 9
        btn.BorderSizePixel  = 0
        btn.LayoutOrder      = order
        btn.ZIndex           = 6
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = T.accentDim; bs.Transparency = 0.2; bs.Thickness = 0.8
        btn.MouseEnter:Connect(function() smooth(bs,{Color=T.accentGlow,Transparency=0.0},0.1):Play() end)
        btn.MouseLeave:Connect(function() smooth(bs,{Color=T.accentDim,Transparency=0.2},0.1):Play() end)
        btn.MouseButton1Down:Connect(function() smooth(btn,{BackgroundTransparency=0.3},0.06):Play() end)
        btn.MouseButton1Up:Connect(function()   smooth(btn,{BackgroundTransparency=0},  0.1):Play() end)
        btn.MouseButton1Click:Connect(function()
            ripple(btn, btn.AbsoluteSize.X*0.5, btn.AbsoluteSize.Y*0.5, T.accent)
            if onClick then onClick() end
        end)
        return btn
    end

    mkSetPosBtn(tpLoopGroup, "[ Set A = Posisi Saat Ini ]", 8, function()
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = hrp.Position
            axBox.Text = string.format("%.3f",p.X)
            ayBox.Text = string.format("%.3f",p.Y)
            azBox.Text = string.format("%.3f",p.Z)
            setTpLoopStat("Titik A diperbarui!", T.green)
        else
            setTpLoopStat("Karakter tidak ditemukan", T.red)
        end
    end)

    mkSetPosBtn(tpLoopGroup, "[ Set B = Posisi Saat Ini ]", 9, function()
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = hrp.Position
            bxBox.Text = string.format("%.3f",p.X)
            byBox.Text = string.format("%.3f",p.Y)
            bzBox.Text = string.format("%.3f",p.Z)
            setTpLoopStat("Titik B diperbarui!", T.green)
        else
            setTpLoopStat("Karakter tidak ditemukan", T.red)
        end
    end)

    -- getters for logic.lua
    local function getTpLoopCoordA()
        return Vector3.new(
            tonumber(axBox.Text) or DEF_A.x,
            tonumber(ayBox.Text) or DEF_A.y,
            tonumber(azBox.Text) or DEF_A.z
        )
    end
    local function getTpLoopCoordB()
        return Vector3.new(
            tonumber(bxBox.Text) or DEF_B.x,
            tonumber(byBox.Text) or DEF_B.y,
            tonumber(bzBox.Text) or DEF_B.z
        )
    end

    -- ── Testing + Skill groups ────────────────────────────────────────────────
    local modeGroup = mkGroupBox(leftF, 3)
    mkSectionLabel(modeGroup,"Testing Mode",1)
    local _,_,getFaceDown = mkToggle(modeGroup,"Face Down",false,nil,2)
    local _,_,getSpinOn   = mkToggle(modeGroup,"Auto Spin HRP",false,nil,3)

    local skillGroup = mkGroupBox(leftF, 4)
    mkSectionLabel(skillGroup,"Auto Skill",1)
    local skillOn = {Z=false,X=false,C=false,V=false}
    mkToggle(skillGroup,"Z",false,function(v) skillOn.Z=v end,2)
    mkToggle(skillGroup,"X",false,function(v) skillOn.X=v end,3)
    mkToggle(skillGroup,"C",false,function(v) skillOn.C=v end,4)
    mkToggle(skillGroup,"V",false,function(v) skillOn.V=v end,5)

    -- ── Right column sliders ──────────────────────────────────────────────────
    mkSection(rightF,"Adjust",1)
    local _,_,getHeight = mkSlider(rightF,"Height",0,50,0," st",nil,2)
    local _,_,getSpeed  = mkSlider(rightF,"Speed",20,500,150," st/s",nil,3)
    local _,_,getTD     = mkSlider(rightF,"Jeda",1,10,1,"s",nil,4)
    local _,_,getLD     = mkSlider(rightF,"Loop Delay",0,10,3,"s",nil,5)

    mkSection(rightF,"TP Loop",6)
    local _,_,getTpDelay = mkSlider(rightF,"Jeda Titik",1,30,5,"s",nil,7)

    -- ── TP TAB ────────────────────────────────────────────────────────────────
    local tpLeftF, tpRightF = mkTwoColLayout(subPages["TP"], T.border)
    local tpStatCard = Instance.new("Frame", tpLeftF)
    tpStatCard.Size               = UDim2.new(1,0,0,22)
    tpStatCard.BackgroundTransparency = 1
    tpStatCard.BorderSizePixel    = 0
    tpStatCard.LayoutOrder        = 0
    local tpStatLbl = Instance.new("TextLabel", tpStatCard)
    tpStatLbl.Size               = UDim2.new(1,0,1,0)
    tpStatLbl.BackgroundTransparency = 1
    tpStatLbl.Text               = "Pilih lokasi"
    tpStatLbl.TextColor3         = T.textDim
    tpStatLbl.Font               = Enum.Font.Gotham
    tpStatLbl.TextSize           = 10
    tpStatLbl.TextXAlignment     = Enum.TextXAlignment.Center
    local function setTPStat(txt,col)
        tpStatLbl.Text = txt or "--"
        if col then smooth(tpStatLbl,{TextColor3=col},0.15):Play() end
    end

    local function makeTpCard(parent, loc, order)
        local card = Instance.new("Frame", parent)
        card.Size             = UDim2.new(1,0,0,40)
        card.BackgroundColor3 = T.card
        card.BorderSizePixel  = 0
        card.LayoutOrder      = order
        card.ZIndex           = 5
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,9)
        local cs = Instance.new("UIStroke", card)
        cs.Color = T.border; cs.Transparency = 0.5; cs.Thickness = 0.8
        local ibar = Instance.new("Frame", card)
        ibar.Size             = UDim2.new(0,2,0,20)
        ibar.Position         = UDim2.new(0,6,0.5,0)
        ibar.AnchorPoint      = Vector2.new(0,0.5)
        ibar.BackgroundColor3 = T.textDim
        ibar.BorderSizePixel  = 0
        Instance.new("UICorner",ibar).CornerRadius = UDim.new(1,0)
        local nameLbl = Instance.new("TextLabel", card)
        nameLbl.Size               = UDim2.new(1,-54,1,0)
        nameLbl.Position           = UDim2.new(0,14,0,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text               = loc
        nameLbl.TextColor3         = T.text
        nameLbl.Font               = Enum.Font.GothamBold
        nameLbl.TextSize           = 11
        nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
        nameLbl.ZIndex             = 6
        local goBtn = Instance.new("TextButton", card)
        goBtn.Size             = UDim2.new(0,36,0,22)
        goBtn.Position         = UDim2.new(1,-40,0.5,0)
        goBtn.AnchorPoint      = Vector2.new(0,0.5)
        goBtn.BackgroundColor3 = Color3.fromRGB(35,155,110)
        goBtn.Text             = "GO"
        goBtn.TextColor3       = T.white
        goBtn.Font             = Enum.Font.GothamBold
        goBtn.TextSize         = 10
        goBtn.BorderSizePixel  = 0
        goBtn.ZIndex           = 7
        Instance.new("UICorner",goBtn).CornerRadius = UDim.new(0,6)
        Instance.new("UIGradient",goBtn).Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(50,188,135)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(28,138,92))
        }
        card.MouseEnter:Connect(function() smooth(card,{BackgroundColor3=T.cardHover},0.1):Play(); smooth(cs,{Color=T.accentGlow,Transparency=0.15},0.1):Play() end)
        card.MouseLeave:Connect(function() smooth(card,{BackgroundColor3=T.card},0.1):Play(); smooth(cs,{Color=T.border,Transparency=0.5},0.1):Play() end)
        goBtn.MouseButton1Down:Connect(function() smooth(goBtn,{Size=UDim2.new(0,32,0,18)},0.07):Play() end)
        goBtn.MouseButton1Up:Connect(function()   smooth(goBtn,{Size=UDim2.new(0,36,0,22)},0.12):Play() end)
        local ci = loc
        goBtn.MouseButton1Click:Connect(function()
            ripple(goBtn,goBtn.AbsoluteSize.X*0.5,goBtn.AbsoluteSize.Y*0.5,T.white)
            setTPStat("Teleporting to "..ci, T.amber)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(ci)
            end)
            task.delay(1.5, function() setTPStat("Arrived: "..ci, T.green) end)
        end)
        return card
    end

    for i=1,8  do makeTpCard(tpLeftF,  TELEPORT_LOCATIONS[i],   i)   end
    for i=9,16 do makeTpCard(tpRightF, TELEPORT_LOCATIONS[i], i-8)   end

    -- ── BOSS TAB ──────────────────────────────────────────────────────────────
    local bossLeftF, bossRightF = mkTwoColLayout(subPages["Boss"], T.border)
    local killBossGroup = mkGroupBox(bossLeftF, 1)
    mkSectionLabel(killBossGroup,"Kill Boss",1)
    local _,setBossStatFn  = mkStatus(killBossGroup,"Status","Idle",2)
    local _,setBossPhaseFn = mkStatus(killBossGroup,"Phase","--",3)
    local _,setBossOnOff,getBossOn,setBossCallback = mkOnOffBtn(killBossGroup,"Kill Boss",4)

    local activeBossContainer = Instance.new("Frame", killBossGroup)
    activeBossContainer.BackgroundTransparency = 1
    activeBossContainer.Size           = UDim2.new(1,0,0,0)
    activeBossContainer.AutomaticSize  = Enum.AutomaticSize.Y
    activeBossContainer.BorderSizePixel = 0
    activeBossContainer.LayoutOrder    = 5
    local abcL = Instance.new("UIListLayout", activeBossContainer)
    abcL.Padding   = UDim.new(0,3)
    abcL.SortOrder = Enum.SortOrder.LayoutOrder

    local selectedBoss    = nil
    local activeBossCards = {}

    local function getActiveBossNames()
        local active = {}
        local npcs   = workspace:FindFirstChild("NPCs")
        for _,bn in ipairs(KNOWN_BOSSES) do
            local found = false
            if npcs and npcs:FindFirstChild(bn) then found = true
            elseif workspace:FindFirstChild(bn,true) then found = true end
            if found then table.insert(active,bn) end
        end
        return active
    end

    local function rebuildActiveBossCards()
        for _,c in ipairs(activeBossCards) do pcall(function() c:Destroy() end) end
        activeBossCards = {}
        local active = getActiveBossNames()
        if #active == 0 then
            local el = Instance.new("TextLabel", activeBossContainer)
            el.Size=UDim2.new(1,0,0,22); el.LayoutOrder=1; el.BackgroundTransparency=1
            el.Text="Tidak ada boss aktif"; el.TextColor3=T.textDim; el.Font=Enum.Font.Gotham
            el.TextSize=9; el.TextXAlignment=Enum.TextXAlignment.Center
            table.insert(activeBossCards,el); return
        end
        if selectedBoss then
            local still = false
            for _,n in ipairs(active) do if n==selectedBoss then still=true; break end end
            if not still then selectedBoss=nil end
        end
        for idx,bossName in ipairs(active) do
            local isSel = (selectedBoss==bossName)
            local card = Instance.new("Frame",activeBossContainer)
            card.Size=UDim2.new(1,0,0,30); card.BackgroundColor3=isSel and Color3.fromRGB(28,18,52) or Color3.fromRGB(14,13,22)
            card.BorderSizePixel=0; card.LayoutOrder=idx; card.ZIndex=5
            Instance.new("UICorner",card).CornerRadius=UDim.new(0,7)
            local cs=Instance.new("UIStroke",card); cs.Color=isSel and T.accentGlow or T.border; cs.Transparency=isSel and 0.05 or 0.5; cs.Thickness=isSel and 1.3 or 0.8
            local adot=Instance.new("Frame",card); adot.Size=UDim2.new(0,5,0,5); adot.Position=UDim2.new(0,7,0.5,0); adot.AnchorPoint=Vector2.new(0,0.5); adot.BackgroundColor3=T.green; adot.BorderSizePixel=0; Instance.new("UICorner",adot).CornerRadius=UDim.new(1,0)
            local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(1,-46,1,0); nameL.Position=UDim2.new(0,17,0,0); nameL.BackgroundTransparency=1; nameL.Text=bossName; nameL.TextColor3=isSel and T.white or T.textSub; nameL.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham; nameL.TextSize=9; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
            local selBtn=Instance.new("TextButton",card); selBtn.Size=UDim2.new(0,34,0,16); selBtn.Position=UDim2.new(1,-38,0.5,0); selBtn.AnchorPoint=Vector2.new(0,0.5); selBtn.BackgroundColor3=isSel and T.accentSoft or Color3.fromRGB(22,20,36); selBtn.Text=isSel and "ON" or "Set"; selBtn.TextColor3=T.white; selBtn.Font=Enum.Font.GothamBold; selBtn.TextSize=8; selBtn.BorderSizePixel=0; selBtn.ZIndex=7; Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,4)
            local ci=bossName
            selBtn.MouseButton1Click:Connect(function() selectedBoss=ci; ripple(selBtn,selBtn.AbsoluteSize.X*0.5,selBtn.AbsoluteSize.Y*0.5,T.accent); rebuildActiveBossCards() end)
            table.insert(activeBossCards,card)
        end
    end

    rebuildActiveBossCards()
    task.spawn(function() while killBossGroup and killBossGroup.Parent do task.wait(3); if killBossGroup and killBossGroup.Parent then rebuildActiveBossCards() end end end)

    local autoKillGroup = mkGroupBox(bossRightF, 1)
    mkSectionLabel(autoKillGroup,"Auto Kill Boss",1)
    local _,setAutoBossStatFn  = mkStatus(autoKillGroup,"Status","Idle",2)
    local _,setAutoBossPhaseFn = mkStatus(autoKillGroup,"Phase","--",3)
    local _,setAutoBossOnOff,getAutoBossOn,setAutoBossCallback = mkOnOffBtn(autoKillGroup,"Auto Kill Boss",4)
    mkSectionLabel(autoKillGroup,"Pilih Boss (multi)",5)
    local autoBossSelected={}
    for _,n in ipairs(KNOWN_BOSSES) do autoBossSelected[n]=false end
    for idx,bossName in ipairs(KNOWN_BOSSES) do
        local card,ccs=mkCard(autoKillGroup,28,idx+5)
        local dot=Instance.new("Frame",card); dot.Size=UDim2.new(0,5,0,5); dot.Position=UDim2.new(0,8,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.textDim; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(1,-36,1,0); nameL.Position=UDim2.new(0,18,0,0); nameL.BackgroundTransparency=1; nameL.Text=bossName; nameL.TextColor3=T.textSub; nameL.Font=Enum.Font.Gotham; nameL.TextSize=9; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
        local chk=Instance.new("TextLabel",card); chk.Size=UDim2.new(0,18,1,0); chk.Position=UDim2.new(1,-20,0,0); chk.BackgroundTransparency=1; chk.Text=""; chk.TextColor3=T.green; chk.Font=Enum.Font.GothamBold; chk.TextSize=12; chk.ZIndex=7
        local hit=Instance.new("TextButton",card); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=8
        local ci=bossName; local cdot=dot; local cname=nameL; local cchk=chk; local css=ccs
        hit.MouseButton1Click:Connect(function()
            autoBossSelected[ci]=not autoBossSelected[ci]; local on=autoBossSelected[ci]
            ripple(card,card.AbsoluteSize.X*0.5,card.AbsoluteSize.Y*0.5,T.accent)
            smooth(cdot,{BackgroundColor3=on and T.green or T.textDim},0.15):Play()
            smooth(cname,{TextColor3=on and T.white or T.textSub},0.15):Play()
            smooth(css,{Color=on and T.accentGlow or T.border,Transparency=on and 0.1 or 0.45},0.15):Play()
            cchk.Text=on and "v" or ""; cname.Font=on and Enum.Font.GothamBold or Enum.Font.Gotham
        end)
    end
    local function getAutoBossSelectedList()
        local list={}
        for _,n in ipairs(KNOWN_BOSSES) do if autoBossSelected[n] then table.insert(list,n) end end
        return list
    end

    -- ── DUNGEON TAB ───────────────────────────────────────────────────────────
    local dungeonSF = mkScrollPage(subPages["Dungeon"])
    local dStatCard=Instance.new("Frame",dungeonSF); dStatCard.Size=UDim2.new(1,0,0,18); dStatCard.BackgroundTransparency=1; dStatCard.LayoutOrder=1; dStatCard.BorderSizePixel=0
    local dungeonStatLbl=Instance.new("TextLabel",dStatCard); dungeonStatLbl.Size=UDim2.new(1,0,1,0); dungeonStatLbl.BackgroundTransparency=1; dungeonStatLbl.Text="Idle"; dungeonStatLbl.TextColor3=T.textDim; dungeonStatLbl.Font=Enum.Font.Gotham; dungeonStatLbl.TextSize=10; dungeonStatLbl.TextXAlignment=Enum.TextXAlignment.Center
    local dNPCCard=Instance.new("Frame",dungeonSF); dNPCCard.Size=UDim2.new(1,0,0,14); dNPCCard.BackgroundTransparency=1; dNPCCard.LayoutOrder=2; dNPCCard.BorderSizePixel=0
    local dungeonNPCLbl=Instance.new("TextLabel",dNPCCard); dungeonNPCLbl.Size=UDim2.new(1,0,1,0); dungeonNPCLbl.BackgroundTransparency=1; dungeonNPCLbl.Text="NPC: --"; dungeonNPCLbl.TextColor3=T.textDim; dungeonNPCLbl.Font=Enum.Font.Gotham; dungeonNPCLbl.TextSize=9; dungeonNPCLbl.TextXAlignment=Enum.TextXAlignment.Center
    local dHitCard=Instance.new("Frame",dungeonSF); dHitCard.Size=UDim2.new(1,0,0,14); dHitCard.BackgroundTransparency=1; dHitCard.LayoutOrder=3; dHitCard.BorderSizePixel=0
    local dungeonHitLbl=Instance.new("TextLabel",dHitCard); dungeonHitLbl.Size=UDim2.new(1,0,1,0); dungeonHitLbl.BackgroundTransparency=1; dungeonHitLbl.Text="0/s"; dungeonHitLbl.TextColor3=T.textDim; dungeonHitLbl.Font=Enum.Font.Gotham; dungeonHitLbl.TextSize=9; dungeonHitLbl.TextXAlignment=Enum.TextXAlignment.Center
    local function setDungeonStat(txt,col) if dungeonStatLbl and dungeonStatLbl.Parent then dungeonStatLbl.Text=txt or "Idle"; if col then smooth(dungeonStatLbl,{TextColor3=col},0.15):Play() end end end
    local function setDungeonNPC(txt,col) if dungeonNPCLbl and dungeonNPCLbl.Parent then dungeonNPCLbl.Text="NPC: "..(txt or "--"); if col then smooth(dungeonNPCLbl,{TextColor3=col},0.15):Play() end end end
    local function setDungeonHit(txt,col) if dungeonHitLbl and dungeonHitLbl.Parent then dungeonHitLbl.Text=txt or "0/s"; if col then smooth(dungeonHitLbl,{TextColor3=col},0.15):Play() end end end
    local _,setDungeonOnOff,getDungeonOn,setDungeonCallback = mkOnOffBtn(dungeonSF,"Auto Dungeon",4)

    -- ══════════════════════════════════════════════
    -- MENU PAGE  — fully inside the closure
    -- ══════════════════════════════════════════════
    local menuSF = mkScrollPage(sideData["Menu"].page)

    -- status label (LayoutOrder=1 so it sits at top)
    local menuStatLbl = Instance.new("TextLabel", menuSF)
    menuStatLbl.Size               = UDim2.new(1,0,0,16)
    menuStatLbl.BackgroundTransparency = 1
    menuStatLbl.Text               = ""
    menuStatLbl.TextColor3         = T.textDim
    menuStatLbl.Font               = Enum.Font.Gotham
    menuStatLbl.TextSize           = 9
    menuStatLbl.TextXAlignment     = Enum.TextXAlignment.Center
    menuStatLbl.LayoutOrder        = 1
    menuStatLbl.ZIndex             = 5
    menuStatLbl.TextWrapped        = true

    local function setMenuStat(msg, col, dur)
        if not menuStatLbl or not menuStatLbl.Parent then return end
        menuStatLbl.Text = msg or ""
        smooth(menuStatLbl, {TextColor3=col or T.textDim}, 0.12):Play()
        local captured = msg
        task.delay(dur or 5, function()
            if menuStatLbl and menuStatLbl.Parent and menuStatLbl.Text==captured then
                smooth(menuStatLbl, {TextColor3=T.textDim}, 0.2):Play()
                task.delay(0.25, function()
                    if menuStatLbl and menuStatLbl.Parent and menuStatLbl.Text==captured then
                        menuStatLbl.Text=""
                    end
                end)
            end
        end)
    end

    local guiOpenState = {}  -- { [path]=bool }

    local function getUIOpen(path)
        local pg = LocalPlayer:FindFirstChild("PlayerGui"); if not pg then return false end
        local ui = pg:FindFirstChild(path)
        if not ui then
            local low = path:lower()
            for _,c in ipairs(pg:GetChildren()) do if c.Name:lower()==low then ui=c; break end end
        end
        if not ui then return false end
        if ui:IsA("ScreenGui") and not ui.Enabled then return false end
        for _,c in ipairs(ui:GetChildren()) do if c:IsA("GuiObject") and c.Visible then return true end end
        for _,c in ipairs(ui:GetChildren()) do for _,g in ipairs(c:GetChildren()) do if g:IsA("GuiObject") and g.Visible then return true end end end
        return false
    end

    local function tryToggleUI(path, btnRef)
        local wantOpen = not getUIOpen(path)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then setMenuStat("PlayerGui tidak ditemukan",T.red); return false end
        local ui = pg:FindFirstChild(path)
        if not ui then
            local low=path:lower()
            for _,c in ipairs(pg:GetChildren()) do if c.Name:lower()==low then ui=c; break end end
        end
        if not ui then
            local names={}; for _,c in ipairs(pg:GetChildren()) do table.insert(names,c.Name) end
            setMenuStat("["..path.."] tidak ada. Ada: "..table.concat(names,", "):sub(1,80), T.red, 8)
            return false
        end
        local ok,err = pcall(function()
            if wantOpen then
                if ui:IsA("ScreenGui") then ui.Enabled=true end
                local shown=0
                for _,c in ipairs(ui:GetChildren()) do if c:IsA("GuiObject") then c.Visible=true; shown=shown+1 end end
                if shown==0 then
                    for _,c in ipairs(ui:GetChildren()) do for _,g in ipairs(c:GetChildren()) do if g:IsA("GuiObject") then g.Visible=true; shown=shown+1 end end end
                end
                if shown==0 then local f=ui:FindFirstChildWhichIsA("GuiObject",true); if f then f.Visible=true end end
                task.spawn(function()
                    for _=1,4 do
                        task.wait(0.25)
                        if not guiOpenState[path] then break end
                        pcall(function()
                            if ui:IsA("ScreenGui") then ui.Enabled=true end
                            for _,c in ipairs(ui:GetChildren()) do if c:IsA("GuiObject") then c.Visible=true end end
                        end)
                    end
                end)
            else
                if ui:IsA("ScreenGui") then ui.Enabled=false end
                for _,c in ipairs(ui:GetChildren()) do
                    if c:IsA("GuiObject") then c.Visible=false end
                    for _,g in ipairs(c:GetChildren()) do if g:IsA("GuiObject") then g.Visible=false end end
                end
            end
        end)
        if ok then
            guiOpenState[path]=wantOpen
            if btnRef and btnRef.Parent then
                btnRef.Text = wantOpen and "Close" or "Open"
                smooth(btnRef,{BackgroundColor3=wantOpen and Color3.fromRGB(180,50,50) or Color3.fromRGB(40,100,200)},0.18):Play()
            end
            setMenuStat((wantOpen and "Dibuka: " or "Ditutup: ")..path, wantOpen and T.green or T.amber)
            return true
        else
            setMenuStat(tostring(err):sub(1,80), T.red, 8)
            return false
        end
    end

    -- card builder
    local function mkMenuCard(parent, labelText, btnText, btnCol, order)
        local card=Instance.new("Frame",parent); card.Size=UDim2.new(1,0,0,38); card.BackgroundColor3=Color3.fromRGB(14,13,22); card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5
        Instance.new("UICorner",card).CornerRadius=UDim.new(0,9)
        local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.45; cs.Thickness=0.8
        local dot=Instance.new("Frame",card); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0,8,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.accentDim; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local lbl=Instance.new("TextLabel",card); lbl.Size=UDim2.new(1,-76,1,0); lbl.Position=UDim2.new(0,18,0,0); lbl.BackgroundTransparency=1; lbl.Text=labelText; lbl.TextColor3=T.text; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6; lbl.TextTruncate=Enum.TextTruncate.AtEnd
        local btn=Instance.new("TextButton",card); btn.Size=UDim2.new(0,58,0,22); btn.Position=UDim2.new(1,-62,0.5,0); btn.AnchorPoint=Vector2.new(0,0.5); btn.BackgroundColor3=btnCol or T.accentSoft; btn.Text=btnText; btn.TextColor3=T.white; btn.Font=Enum.Font.GothamBold; btn.TextSize=10; btn.BorderSizePixel=0; btn.ZIndex=7
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        card.MouseEnter:Connect(function() smooth(card,{BackgroundColor3=Color3.fromRGB(18,17,30)},0.08):Play(); smooth(cs,{Color=T.accentGlow,Transparency=0.2},0.08):Play(); smooth(dot,{BackgroundColor3=T.accentGlow},0.08):Play() end)
        card.MouseLeave:Connect(function() smooth(card,{BackgroundColor3=Color3.fromRGB(14,13,22)},0.08):Play(); smooth(cs,{Color=T.border,Transparency=0.45},0.08):Play(); smooth(dot,{BackgroundColor3=T.accentDim},0.08):Play() end)
        btn.MouseButton1Down:Connect(function() smooth(btn,{Size=UDim2.new(0,52,0,18)},0.07):Play() end)
        btn.MouseButton1Up:Connect(function()   smooth(btn,{Size=UDim2.new(0,58,0,22)},0.10):Play() end)
        return card, btn
    end

    -- Open GUI section
    local GUI_LIST_MENU = {
        {name="Enchant UI",     path="EnchantUI"},
        {name="Tower Merchant", path="InfiniteTowerMerchantUI"},
        {name="Power Reroll",   path="PowerRerollUI"},
        {name="Reroll Stats",   path="RerollStatsUI"},
        {name="Spec Passive",   path="SpecPassiveUI"},
        {name="Trait Reroll",   path="TraitRerollUI"},
        {name="Blessing",       path="BlessingUI"},
    }
    mkSection(menuSF,"Open GUI",2)
    for i,g in ipairs(GUI_LIST_MENU) do
        local ci = g.path
        local _,btn = mkMenuCard(menuSF, g.name, "Open", Color3.fromRGB(40,100,200), i+2)
        btn.MouseButton1Click:Connect(function()
            ripple(btn,btn.AbsoluteSize.X*0.5,btn.AbsoluteSize.Y*0.5,T.white)
            tryToggleUI(ci, btn)
        end)
    end

    -- Scan + open-any
    local SO = #GUI_LIST_MENU + 4
    mkSection(menuSF,"Debug Tools",SO)

    local _,scanBtn = mkMenuCard(menuSF,"Scan Semua ScreenGui","Scan",Color3.fromRGB(80,60,180),SO+1)
    scanBtn.MouseButton1Click:Connect(function()
        ripple(scanBtn,scanBtn.AbsoluteSize.X*0.5,scanBtn.AbsoluteSize.Y*0.5,T.white)
        local pg=LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then setMenuStat("PlayerGui tidak ditemukan",T.red); return end
        local names={}
        for _,c in ipairs(pg:GetChildren()) do if c:IsA("ScreenGui") then table.insert(names,c.Name) end end
        setMenuStat(#names>0 and table.concat(names,"  |  "):sub(1,200) or "Tidak ada ScreenGui", T.accentGlow, 10)
    end)

    local _,openAnyBtn = mkMenuCard(menuSF,"Buka GUI by Name","Buka",Color3.fromRGB(60,140,80),SO+2)
    local openAnyRow = Instance.new("Frame",menuSF); openAnyRow.Size=UDim2.new(1,0,0,34); openAnyRow.BackgroundColor3=Color3.fromRGB(14,13,22); openAnyRow.BorderSizePixel=0; openAnyRow.LayoutOrder=SO+3; openAnyRow.ZIndex=5; Instance.new("UICorner",openAnyRow).CornerRadius=UDim.new(0,9)
    local oaStr=Instance.new("UIStroke",openAnyRow); oaStr.Color=T.border; oaStr.Transparency=0.35; oaStr.Thickness=0.9
    local openAnyBox=Instance.new("TextBox",openAnyRow); openAnyBox.Size=UDim2.new(1,-76,1,-8); openAnyBox.Position=UDim2.new(0,10,0,4); openAnyBox.BackgroundTransparency=1; openAnyBox.Text=""; openAnyBox.PlaceholderText="Nama GUI (contoh: EnchantUI)"; openAnyBox.TextColor3=T.text; openAnyBox.PlaceholderColor3=T.textDim; openAnyBox.Font=Enum.Font.Gotham; openAnyBox.TextSize=10; openAnyBox.TextXAlignment=Enum.TextXAlignment.Left; openAnyBox.ClearTextOnFocus=false; openAnyBox.ZIndex=7
    local openAnyOK=Instance.new("TextButton",openAnyRow); openAnyOK.Size=UDim2.new(0,58,0,22); openAnyOK.Position=UDim2.new(1,-62,0.5,0); openAnyOK.AnchorPoint=Vector2.new(0,0.5); openAnyOK.BackgroundColor3=Color3.fromRGB(40,100,200); openAnyOK.Text="Buka"; openAnyOK.TextColor3=T.white; openAnyOK.Font=Enum.Font.GothamBold; openAnyOK.TextSize=10; openAnyOK.BorderSizePixel=0; openAnyOK.ZIndex=8; Instance.new("UICorner",openAnyOK).CornerRadius=UDim.new(0,6)
    openAnyBox.Focused:Connect(function()   smooth(oaStr,{Color=T.accentGlow,Transparency=0.0},0.15):Play() end)
    openAnyBox.FocusLost:Connect(function() smooth(oaStr,{Color=T.border,Transparency=0.35},0.15):Play() end)
    openAnyOK.MouseButton1Down:Connect(function() smooth(openAnyOK,{Size=UDim2.new(0,52,0,18)},0.07):Play() end)
    openAnyOK.MouseButton1Up:Connect(function()   smooth(openAnyOK,{Size=UDim2.new(0,58,0,22)},0.10):Play() end)
    openAnyOK.MouseButton1Click:Connect(function()
        ripple(openAnyOK,openAnyOK.AbsoluteSize.X*0.5,openAnyOK.AbsoluteSize.Y*0.5,T.white)
        local raw=openAnyBox.Text:match("^%s*(.-)%s*$") or ""
        if raw=="" then setMenuStat("Masukkan nama GUI!",T.amber); return end
        tryToggleUI(raw, openAnyOK)
    end)

    -- Open Boss UI
    mkSection(menuSF,"Open Boss UI",SO+4)
    local bossHint=Instance.new("TextLabel",menuSF); bossHint.Size=UDim2.new(1,0,0,14); bossHint.BackgroundTransparency=1; bossHint.Text="Format: NamaBossUI  (e.g. TheWorldBossUI)"; bossHint.TextColor3=T.textDim; bossHint.Font=Enum.Font.Gotham; bossHint.TextSize=9; bossHint.TextXAlignment=Enum.TextXAlignment.Center; bossHint.LayoutOrder=SO+5; bossHint.ZIndex=5

    local bossInputRow=Instance.new("Frame",menuSF); bossInputRow.Size=UDim2.new(1,0,0,38); bossInputRow.BackgroundColor3=Color3.fromRGB(14,13,22); bossInputRow.BorderSizePixel=0; bossInputRow.LayoutOrder=SO+6; bossInputRow.ZIndex=5; Instance.new("UICorner",bossInputRow).CornerRadius=UDim.new(0,9)
    local biStr=Instance.new("UIStroke",bossInputRow); biStr.Color=T.border; biStr.Transparency=0.35; biStr.Thickness=0.9
    local bossInput=Instance.new("TextBox",bossInputRow); bossInput.Size=UDim2.new(1,-74,1,-10); bossInput.Position=UDim2.new(0,10,0,5); bossInput.BackgroundTransparency=1; bossInput.Text=""; bossInput.PlaceholderText="Nama boss (contoh: TheWorld)"; bossInput.TextColor3=T.text; bossInput.PlaceholderColor3=T.textDim; bossInput.Font=Enum.Font.Gotham; bossInput.TextSize=10; bossInput.TextXAlignment=Enum.TextXAlignment.Left; bossInput.ClearTextOnFocus=false; bossInput.ZIndex=7
    local bossOpenBtn=Instance.new("TextButton",bossInputRow); bossOpenBtn.Size=UDim2.new(0,60,0,24); bossOpenBtn.Position=UDim2.new(1,-64,0.5,0); bossOpenBtn.AnchorPoint=Vector2.new(0,0.5); bossOpenBtn.BackgroundColor3=Color3.fromRGB(40,100,200); bossOpenBtn.Text="Open"; bossOpenBtn.TextColor3=T.white; bossOpenBtn.Font=Enum.Font.GothamBold; bossOpenBtn.TextSize=10; bossOpenBtn.BorderSizePixel=0; bossOpenBtn.ZIndex=8; Instance.new("UICorner",bossOpenBtn).CornerRadius=UDim.new(0,6)
    bossInput.Focused:Connect(function()   smooth(biStr,{Color=T.accentGlow,Transparency=0.0},0.15):Play() end)
    bossInput.FocusLost:Connect(function() smooth(biStr,{Color=T.border,Transparency=0.35},0.15):Play() end)
    bossOpenBtn.MouseButton1Down:Connect(function() smooth(bossOpenBtn,{Size=UDim2.new(0,54,0,20)},0.07):Play() end)
    bossOpenBtn.MouseButton1Up:Connect(function()   smooth(bossOpenBtn,{Size=UDim2.new(0,60,0,24)},0.10):Play() end)
    bossOpenBtn.MouseButton1Click:Connect(function()
        ripple(bossOpenBtn,bossOpenBtn.AbsoluteSize.X*0.5,bossOpenBtn.AbsoluteSize.Y*0.5,T.white)
        local raw=bossInput.Text:match("^%s*(.-)%s*$") or ""
        if raw=="" then setMenuStat("Masukkan nama boss dulu!",T.amber); return end
        local attempts={raw.."BossUI", raw:sub(1,1):upper()..raw:sub(2).."BossUI", raw}
        local pg=LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local low=raw:lower()
            for _,c in ipairs(pg:GetChildren()) do
                local clow=c.Name:lower()
                if clow:find(low,1,true) and (clow:find("boss",1,true) or clow:find("ui",1,true)) then
                    local dup=false; for _,a in ipairs(attempts) do if a==c.Name then dup=true; break end end
                    if not dup then table.insert(attempts,c.Name) end
                end
            end
        end
        local ok2=false
        for _,attempt in ipairs(attempts) do
            if tryToggleUI(attempt, bossOpenBtn) then ok2=true; break end
        end
        if not ok2 then setMenuStat("["..raw.."BossUI] tidak ditemukan. Coba Scan.",T.red,8) end
    end)

    -- ══════════════════════════════════════════════
    -- SETTINGS PAGE
    -- ══════════════════════════════════════════════
    local settingsMaster = sideData["Settings"].page
    local settingsSubs   = mkSubTabBar(settingsMaster,{"Tampilan","Webhook"})
    local settingsSF     = mkScrollPage(settingsSubs["Tampilan"])
    mkSection(settingsSF,"Appearance",1)
    mkSlider(settingsSF,"UI Scale",70,130,100,"%",function(v)
        local bW=root.AbsoluteSize.X>0 and root.AbsoluteSize.X or 460
        local bH=root.AbsoluteSize.Y>0 and root.AbsoluteSize.Y or 340
        root.Size=UDim2.new(0,bW*(v/100),0,bH*(v/100))
    end,2)
    mkSlider(settingsSF,"Border Opacity",0,100,90,"%",function(v) rootStroke.Transparency=1-(v/100) end,3)
    mkSlider(settingsSF,"Corner Radius",6,24,14,"px",function(v) rootCorner.CornerRadius=UDim.new(0,v) end,4)
    mkSection(settingsSF,"Font",5)
    mkSlider(settingsSF,"Font Size",8,18,12,"px",function(v) lib.applyFontSize(v) end,6)
    mkSection(settingsSF,"Accent Color",7)
    mkDropdownV2(settingsSF,"Accent","*",Color3.fromRGB(118,68,255),{"Purple","Blue","Cyan","Green","Red"},"Purple",function(v) lib.applyAccent(v) end,8)
    mkSection(settingsSF,"Particles",9)
    mkToggle(settingsSF,"Enable Particles",true,function(v) UISettings.particles=v; for _,p in ipairs(particleList) do if p and p.Parent then p.Visible=v end end end,10)
    mkSlider(settingsSF,"Jumlah Partikel",5,80,26,"",function(v) UISettings.particleCount=v; spawnParticles(v) end,11)
    mkSection(settingsSF,"Background Window",12)
    mkDropdownV2(settingsSF,"Mode BG","o",Color3.fromRGB(80,80,180),{"Solid","Transparent","Blur"},"Solid",function(v) applyUIBgMode(v) end,13)
    mkSection(settingsSF,"Background Minimize Bar",14)
    mkDropdownV2(settingsSF,"Mode Mini BG","o",Color3.fromRGB(60,60,160),{"Solid","Transparent"},"Solid",function(v) applyMiniBgMode(v) end,15)
    mkSection(settingsSF,"Effects",16)
    mkToggle(settingsSF,"Window Glow",true,function(v) UISettings.glow=v; lib.smooth(rootGlow,{ImageTransparency=v and 0.85 or 1},0.3):Play() end,17)

    -- ── Webhook subtab ────────────────────────────────────────────────────────
    local webhookSF = mkScrollPage(settingsSubs["Webhook"])
    mkSection(webhookSF,"Kontrol",1)
    local _,setWhStatFn                           = mkStatus(webhookSF,"Status","Nonaktif",2)
    local _,setWhOnOff,getWhOn,setWhCallback      = mkOnOffBtn(webhookSF,"Kirim Webhook",3)
    mkSection(webhookSF,"Filter Item",4)
    local searchRow=Instance.new("Frame",webhookSF); searchRow.Size=UDim2.new(1,0,0,34); searchRow.BackgroundColor3=Color3.fromRGB(14,13,22); searchRow.BorderSizePixel=0; searchRow.LayoutOrder=5; searchRow.ZIndex=5; Instance.new("UICorner",searchRow).CornerRadius=UDim.new(0,8)
    local srStroke=Instance.new("UIStroke",searchRow); srStroke.Color=T.border; srStroke.Transparency=0.35; srStroke.Thickness=0.9
    local searchBox=Instance.new("TextBox",searchRow); searchBox.Size=UDim2.new(1,-76,1,-8); searchBox.Position=UDim2.new(0,10,0,4); searchBox.BackgroundTransparency=1; searchBox.Text=""; searchBox.PlaceholderText="Cari item..."; searchBox.TextColor3=T.text; searchBox.PlaceholderColor3=T.textDim; searchBox.Font=Enum.Font.Gotham; searchBox.TextSize=10; searchBox.TextXAlignment=Enum.TextXAlignment.Left; searchBox.ClearTextOnFocus=false; searchBox.ZIndex=6
    local function mkSmallBtn(parent,xOff,bg,sym,col)
        local b=Instance.new("TextButton",parent); b.Size=UDim2.new(0,28,0,22); b.Position=UDim2.new(1,xOff,0.5,0); b.AnchorPoint=Vector2.new(0,0.5); b.BackgroundColor3=bg; b.Text=sym; b.TextColor3=col or T.white; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.BorderSizePixel=0; b.ZIndex=7; Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        b.MouseEnter:Connect(function() smooth(b,{BackgroundTransparency=0.22},0.08):Play() end)
        b.MouseLeave:Connect(function() smooth(b,{BackgroundTransparency=0},0.08):Play() end)
        return b
    end
    local refreshItemBtn=mkSmallBtn(searchRow,-66,Color3.fromRGB(28,26,46),"R",T.textSub)
    local confirmItemBtn=mkSmallBtn(searchRow,-34,T.accentSoft,"v",T.white); lib.regAccent("bgSoft",confirmItemBtn)
    local selCountLbl=Instance.new("TextLabel",webhookSF); selCountLbl.Size=UDim2.new(1,-4,0,14); selCountLbl.BackgroundTransparency=1; selCountLbl.Text="Belum ada item dipilih"; selCountLbl.TextColor3=T.textDim; selCountLbl.Font=Enum.Font.Gotham; selCountLbl.TextSize=9; selCountLbl.TextXAlignment=Enum.TextXAlignment.Right; selCountLbl.LayoutOrder=6; selCountLbl.ZIndex=5
    local itemListSF=Instance.new("ScrollingFrame",webhookSF); itemListSF.Size=UDim2.new(1,0,0,164); itemListSF.BackgroundTransparency=1; itemListSF.BorderSizePixel=0; itemListSF.ScrollBarThickness=2; itemListSF.ScrollBarImageColor3=T.accent; itemListSF.ScrollBarImageTransparency=0.4; itemListSF.CanvasSize=UDim2.new(0,0,0,0); itemListSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; itemListSF.ZIndex=3; itemListSF.ClipsDescendants=true; itemListSF.LayoutOrder=7; lib.regAccent("scrollbar",itemListSF)
    local ilL=Instance.new("UIListLayout",itemListSF); ilL.Padding=UDim.new(0,3); ilL.SortOrder=Enum.SortOrder.LayoutOrder
    local ilP=Instance.new("UIPadding",itemListSF); ilP.PaddingTop=UDim.new(0,3); ilP.PaddingBottom=UDim.new(0,4); ilP.PaddingLeft=UDim.new(0,2); ilP.PaddingRight=UDim.new(0,2)
    local selectedWhItems={}; local activeItemCards={}; local cachedItemNames={}
    local function loadStorageNames()
        local names={}
        local ok,storage=pcall(function()
            local pg=LocalPlayer:FindFirstChild("PlayerGui"); if not pg then error("no pg") end
            local ui=pg:FindFirstChild("InventoryPanelUI"); if not ui then error("no ui") end
            return ui.MainFrame.Frame.Content.Holder.StorageHolder.Storage
        end)
        if not ok or not storage then return names end
        for _,child in ipairs(storage:GetChildren()) do
            local name=child.Name:match("^Item_(.+)$"); if name then table.insert(names,name) end
        end
        table.sort(names); return names
    end
    local function updateSelCountLbl()
        local n=0; for _,v in pairs(selectedWhItems) do if v then n=n+1 end end
        if n>0 then selCountLbl.Text=n.." item dipilih"; smooth(selCountLbl,{TextColor3=T.accentGlow},0.15):Play()
        else selCountLbl.Text="Belum ada item dipilih"; smooth(selCountLbl,{TextColor3=T.textDim},0.15):Play() end
    end
    local function rebuildItemList(filter)
        for _,c in ipairs(activeItemCards) do pcall(function() c:Destroy() end) end; activeItemCards={}
        if #cachedItemNames==0 then cachedItemNames=loadStorageNames() end
        local filterLow=(filter or ""):lower(); local order=0
        for _,itemName in ipairs(cachedItemNames) do
            if filterLow=="" or itemName:lower():find(filterLow,1,true) then
                order=order+1; local isSel=selectedWhItems[itemName]==true
                local card=Instance.new("Frame",itemListSF); card.Size=UDim2.new(1,-2,0,26); card.BackgroundColor3=isSel and Color3.fromRGB(20,15,38) or Color3.fromRGB(14,13,22); card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,6)
                local cs=Instance.new("UIStroke",card); cs.Color=isSel and T.accentGlow or T.border; cs.Transparency=isSel and 0.10 or 0.55; cs.Thickness=isSel and 1.1 or 0.7
                local dot=Instance.new("Frame",card); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0,7,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=isSel and T.green or T.textDim; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
                local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(1,-36,1,0); nameL.Position=UDim2.new(0,16,0,0); nameL.BackgroundTransparency=1; nameL.Text=itemName; nameL.TextColor3=isSel and T.white or T.textSub; nameL.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham; nameL.TextSize=9; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
                local chk=Instance.new("TextLabel",card); chk.Size=UDim2.new(0,18,1,0); chk.Position=UDim2.new(1,-20,0,0); chk.BackgroundTransparency=1; chk.Text=isSel and "v" or ""; chk.TextColor3=T.green; chk.Font=Enum.Font.GothamBold; chk.TextSize=11; chk.ZIndex=7
                local hit=Instance.new("TextButton",card); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=8
                local ci2=itemName; local ccard=card; local ccs=cs; local cdot=dot; local cname=nameL; local cchk=chk
                hit.MouseEnter:Connect(function() if not selectedWhItems[ci2] then smooth(ccard,{BackgroundColor3=Color3.fromRGB(18,17,30)},0.08):Play() end end)
                hit.MouseLeave:Connect(function() if not selectedWhItems[ci2] then smooth(ccard,{BackgroundColor3=Color3.fromRGB(14,13,22)},0.08):Play() end end)
                hit.MouseButton1Click:Connect(function()
                    selectedWhItems[ci2]=not selectedWhItems[ci2]; local on=selectedWhItems[ci2]==true
                    ripple(ccard,ccard.AbsoluteSize.X*0.5,ccard.AbsoluteSize.Y*0.5,T.accent)
                    smooth(ccard,{BackgroundColor3=on and Color3.fromRGB(20,15,38) or Color3.fromRGB(14,13,22)},0.15):Play()
                    smooth(ccs,{Color=on and T.accentGlow or T.border,Transparency=on and 0.10 or 0.55},0.15):Play()
                    smooth(cdot,{BackgroundColor3=on and T.green or T.textDim},0.15):Play()
                    smooth(cname,{TextColor3=on and T.white or T.textSub},0.15):Play()
                    cname.Font=on and Enum.Font.GothamBold or Enum.Font.Gotham; cchk.Text=on and "v" or ""; updateSelCountLbl()
                end)
                table.insert(activeItemCards,card)
            end
        end
        if order==0 then
            local el=Instance.new("TextLabel",itemListSF); el.Size=UDim2.new(1,-2,0,26); el.BackgroundTransparency=1; el.LayoutOrder=1
            el.Text=#cachedItemNames==0 and "Storage tidak ditemukan (buka Inventory dulu)" or "Tidak ada item cocok"
            el.TextColor3=T.textDim; el.Font=Enum.Font.Gotham; el.TextSize=9; el.TextXAlignment=Enum.TextXAlignment.Center
            table.insert(activeItemCards,el)
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(function() rebuildItemList(searchBox.Text) end)
    searchBox.Focused:Connect(function()   smooth(srStroke,{Color=T.accentGlow,Transparency=0.0},0.15):Play() end)
    searchBox.FocusLost:Connect(function() smooth(srStroke,{Color=T.border,Transparency=0.35},0.15):Play() end)
    refreshItemBtn.MouseButton1Click:Connect(function() ripple(refreshItemBtn,refreshItemBtn.AbsoluteSize.X*0.5,refreshItemBtn.AbsoluteSize.Y*0.5,T.accent); cachedItemNames=loadStorageNames(); rebuildItemList(searchBox.Text) end)
    confirmItemBtn.MouseButton1Click:Connect(function()
        ripple(confirmItemBtn,confirmItemBtn.AbsoluteSize.X*0.5,confirmItemBtn.AbsoluteSize.Y*0.5,T.green)
        local n=0; for _,v in pairs(selectedWhItems) do if v then n=n+1 end end
        setWhStatFn(n>0 and (n.." item dikunci untuk dipantau") or "Belum ada item dipilih", n>0 and T.green or T.amber)
    end)
    rebuildItemList("")
    local function getSelectedWhItems()
        local list={}; for name,v in pairs(selectedWhItems) do if v then table.insert(list,name) end end; table.sort(list); return list
    end

    -- ══════════════════════════════════════════════
    -- RETURN REFS  — all keys used by logic.lua
    -- ══════════════════════════════════════════════
    return {
        -- Farm
        getIsland        = getIsland,
        getFarmMode      = getFarmMode,
        getHeight        = getHeight,
        getSpeed         = getSpeed,
        getTD            = getTD,
        getLD            = getLD,
        setFarmOnOff     = setFarmOnOff,
        getFarmOn        = getFarmOn,
        setFarmCallback  = setFarmCallback,
        getAutoHitOn     = function() return getAutoHitOn() end,
        getFaceDown      = function() return getFaceDown()  end,
        getSpinOn        = function() return getSpinOn()    end,
        getSkillOn       = function(k) return skillOn[k]   end,
        setFarmStat      = function() end,
        setFarmPhase     = function() end,
        setFarmNPC       = function() end,
        -- TP Loop
        getTpLoopOn       = getTpLoopOn,
        setTpLoopOnOff    = setTpLoopOnOff,
        setTpLoopCallback = setTpLoopCallback,
        getTpLoopCoordA   = getTpLoopCoordA,
        getTpLoopCoordB   = getTpLoopCoordB,
        getTpDelay        = getTpDelay,
        setTpLoopStat     = setTpLoopStat,
        -- Boss (single)
        getSelectedBoss  = function() return selectedBoss end,
        setBossStat      = setBossStatFn,
        setBossPhase     = setBossPhaseFn,
        setBossTarget    = function() end,
        setBossOnOff     = setBossOnOff,
        getBossOn        = getBossOn,
        setBossCallback  = setBossCallback,
        -- Auto Boss
        getAutoBossSelectedList = getAutoBossSelectedList,
        setAutoBossStat         = setAutoBossStatFn,
        setAutoBossPhase        = setAutoBossPhaseFn,
        setAutoBossOnOff        = setAutoBossOnOff,
        getAutoBossOn           = getAutoBossOn,
        setAutoBossCallback     = setAutoBossCallback,
        -- Dungeon
        setDungeonStat     = setDungeonStat,
        setDungeonNPC      = setDungeonNPC,
        setDungeonHit      = setDungeonHit,
        setDungeonOnOff    = setDungeonOnOff,
        getDungeonOn       = getDungeonOn,
        setDungeonCallback = setDungeonCallback,
        -- Webhook
        getSelectedWhItems = getSelectedWhItems,
        getWhOn            = getWhOn,
        setWhOnOff         = setWhOnOff,
        setWhCallback      = setWhCallback,
        setWhStat          = setWhStatFn,
    }

end  -- end of return function
