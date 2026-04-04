-- ╔═════════════════════════════════╗
-- ║  YiDaMuSake — Pages Builder      ║
-- ╚══════════════════════════════════╝

local TELEPORT_LOCATIONS = {
    "Starter","Jungle","Desert","Snow",
    "Sailor","Shibuya","HollowIsland","Boss",
    "Dungeon","Shinjuku","Slime","Academy",
    "Judgement","Ninja","Lawless","Tower",
}

local FARM_ISLANDS = {
    "Starter Island","Jungle Island","Desert Island","Snow Island",
    "Shibuya","Hollow",
    "Shinjuku Island#1","Shinjuku Island#2",
    "Slime","Academy","Judgement","Soul Dominion",
    "Ninja","Lawless",
}

-- Boss exclusion list
local BOSS_EXCLUSIONS = {
    DesertBoss=true, MonkeyBoss=true,
    PandaMiniBoss=true, SnowBoss=true,
}

local function detectBosses()
    local list = {}
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then return list end
    for _, child in ipairs(npcs:GetChildren()) do
        if child.Name:find("Boss", 1, true)
            and not BOSS_EXCLUSIONS[child.Name] then
            table.insert(list, child.Name)
        end
    end
    return list
end

-- Format seconds → "M:SS" or "Spawning!"
local function fmtTime(secs)
    if type(secs) ~= "number" then return "?" end
    secs = math.floor(secs)
    if secs <= 0 then return "Spawning!" end
    local m = math.floor(secs/60)
    local s = secs%60
    return string.format("%d:%02d",m,s)
end

return function(lib, sideData, contentArea, bgF, root, rootCorner,
                rootStroke, rootGlow, particleList, spawnParticles,
                applyUIBgMode, applyMiniBgMode)

    local T              = lib.T
    local UISettings     = lib.UISettings
    local smooth         = lib.smooth
    local spring         = lib.spring
    local ease           = lib.ease
    local ripple         = lib.ripple
    local mkScrollPage   = lib.mkScrollPage
    local mkGroupBox     = lib.mkGroupBox
    local mkSectionLabel = lib.mkSectionLabel
    local mkSection      = lib.mkSection
    local mkStatus       = lib.mkStatus
    local mkSlider       = lib.mkSlider
    local mkToggle       = lib.mkToggle
    local mkOnOffBtn     = lib.mkOnOffBtn
    local mkDropdownV2   = lib.mkDropdownV2
    local mkSubTabBar    = lib.mkSubTabBar

    -- ════════════════════════════════
    -- PAGE: INFO — Boss Countdown Timers
    -- ════════════════════════════════
    local infoSF = mkScrollPage(sideData["Info"].page)

    -- Header
    mkSection(infoSF, "Boss Countdown", 1)

    -- Refresh button
    local infoRefreshBtn = Instance.new("TextButton", infoSF)
    infoRefreshBtn.Size = UDim2.new(1,0,0,34)
    infoRefreshBtn.BackgroundColor3 = Color3.fromRGB(28,24,44)
    infoRefreshBtn.Text = "↻  Refresh Timer List"
    infoRefreshBtn.TextColor3 = T.textSub; infoRefreshBtn.Font = Enum.Font.GothamBold
    infoRefreshBtn.TextSize = 11; infoRefreshBtn.BorderSizePixel = 0
    infoRefreshBtn.LayoutOrder = 2; infoRefreshBtn.ZIndex = 6
    Instance.new("UICorner", infoRefreshBtn).CornerRadius = UDim.new(0,9)
    local irStroke = Instance.new("UIStroke", infoRefreshBtn)
    irStroke.Color = T.borderBright; irStroke.Thickness = 1.2; irStroke.Transparency = 0.3

    -- Timer cards container
    local timerContainer = Instance.new("Frame", infoSF)
    timerContainer.BackgroundTransparency = 1
    timerContainer.Size = UDim2.new(1,0,0,0)
    timerContainer.AutomaticSize = Enum.AutomaticSize.Y
    timerContainer.BorderSizePixel = 0; timerContainer.LayoutOrder = 3
    local tcLayout = Instance.new("UIListLayout", timerContainer)
    tcLayout.Padding = UDim.new(0,5); tcLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Timer update data
    local timerDataList = {}

    local function buildTimerCards()
        -- Clear old
        for _, c in ipairs(timerContainer:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        timerDataList = {}

        -- Scan workspace for TimedBossSpawn_*_Container
        local found = 0
        for _, child in ipairs(workspace:GetChildren()) do
            local bossName = child.Name:match("^TimedBossSpawn_(.+)_Container$")
            if bossName then
                found = found + 1
                -- Card
                local card = Instance.new("Frame", timerContainer)
                card.Size = UDim2.new(1,0,0,52)
                card.BackgroundColor3 = Color3.fromRGB(14,13,22)
                card.BorderSizePixel = 0; card.LayoutOrder = found; card.ZIndex = 5
                Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
                local cs = Instance.new("UIStroke", card)
                cs.Color = T.border; cs.Transparency = 0.2; cs.Thickness = 1.0

                -- Boss name
                local nameL = Instance.new("TextLabel", card)
                nameL.Size = UDim2.new(0.6,0,0,22); nameL.Position = UDim2.new(0,12,0,6)
                nameL.BackgroundTransparency = 1; nameL.Text = bossName
                nameL.TextColor3 = T.text; nameL.Font = Enum.Font.GothamBold
                nameL.TextSize = 12; nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.ZIndex = 6

                -- Timer value (right side)
                local timerL = Instance.new("TextLabel", card)
                timerL.Size = UDim2.new(0.4,-12,0,22); timerL.Position = UDim2.new(0.6,0,0,6)
                timerL.BackgroundTransparency = 1; timerL.Text = "..."
                timerL.TextColor3 = T.accentGlow; timerL.Font = Enum.Font.GothamBold
                timerL.TextSize = 12; timerL.TextXAlignment = Enum.TextXAlignment.Right; timerL.ZIndex = 6

                -- Status bar (small indicator bottom)
                local statusL = Instance.new("TextLabel", card)
                statusL.Size = UDim2.new(1,-24,0,14); statusL.Position = UDim2.new(0,12,0,32)
                statusL.BackgroundTransparency = 1; statusL.Text = "Checking..."
                statusL.TextColor3 = T.textDim; statusL.Font = Enum.Font.Gotham
                statusL.TextSize = 9; statusL.TextXAlignment = Enum.TextXAlignment.Left; statusL.ZIndex = 6

                table.insert(timerDataList, {
                    container = child,
                    timerL    = timerL,
                    statusL   = statusL,
                    cardStroke= cs,
                })
            end
        end

        if found == 0 then
            local emptyL = Instance.new("TextLabel", timerContainer)
            emptyL.Size = UDim2.new(1,0,0,36); emptyL.BackgroundTransparency = 1
            emptyL.Text = "Tidak ada TimedBossSpawn di workspace"
            emptyL.TextColor3 = T.textDim; emptyL.Font = Enum.Font.Gotham
            emptyL.TextSize = 10; emptyL.LayoutOrder = 1; emptyL.ZIndex = 5
        end
    end

    buildTimerCards()

    infoRefreshBtn.MouseButton1Click:Connect(function()
        ripple(infoRefreshBtn, infoRefreshBtn.AbsoluteSize.X*0.5, infoRefreshBtn.AbsoluteSize.Y*0.5, T.accent)
        buildTimerCards()
    end)

    -- Live update every 1 second
    task.spawn(function()
        while infoSF and infoSF.Parent do
            for _, d in ipairs(timerDataList) do
                pcall(function()
                    if not d.container or not d.container.Parent then
                        d.timerL.Text = "Tidak aktif"
                        d.timerL.TextColor3 = T.textDim
                        d.statusL.Text = "Container tidak ditemukan"
                        smooth(d.cardStroke, {Color=T.border}, 0.3):Play()
                        return
                    end
                    -- Try to find any NumberValue/IntValue for countdown
                    local numVal = d.container:FindFirstChild("Timer")
                        or d.container:FindFirstChild("Countdown")
                        or d.container:FindFirstChild("TimeLeft")
                        or d.container:FindFirstChild("Time")
                        or d.container:FindFirstChildOfClass("NumberValue")
                        or d.container:FindFirstChildOfClass("IntValue")
                    if numVal then
                        local v = numVal.Value
                        local txt = fmtTime(v)
                        d.timerL.Text = txt
                        if v <= 0 then
                            d.timerL.TextColor3 = T.green
                            d.statusL.Text = "Boss sedang spawn!"
                            smooth(d.cardStroke, {Color=T.green}, 0.3):Play()
                        elseif v < 60 then
                            d.timerL.TextColor3 = T.amber
                            d.statusL.Text = "Segera spawn!"
                            smooth(d.cardStroke, {Color=T.amber}, 0.3):Play()
                        else
                            d.timerL.TextColor3 = T.accentGlow
                            d.statusL.Text = "Menunggu..."
                            smooth(d.cardStroke, {Color=T.border}, 0.3):Play()
                        end
                    else
                        -- Check BoolValue
                        local boolVal = d.container:FindFirstChildOfClass("BoolValue")
                        if boolVal then
                            d.timerL.Text = boolVal.Value and "Active" or "Waiting"
                            d.timerL.TextColor3 = boolVal.Value and T.green or T.textSub
                            d.statusL.Text = boolVal.Value and "Boss aktif" or "Menunggu spawn"
                        else
                            d.timerL.Text = "Active"
                            d.timerL.TextColor3 = T.green
                            d.statusL.Text = "Container ditemukan"
                        end
                    end
                end)
            end
            task.wait(1)
        end
    end)

    -- ════════════════════════════════
    -- PAGE: MAIN (6 sub-tabs)
    -- ════════════════════════════════
    local mainPage  = sideData["Main"].page
    local mainInner = Instance.new("Frame", mainPage)
    mainInner.Size  = UDim2.new(1,-8,1,-8)
    mainInner.Position = UDim2.new(0,4,0,4)
    mainInner.BackgroundTransparency = 1; mainInner.ZIndex = 3

    local subPages = mkSubTabBar(mainInner, {"Farm","Quest","Hit","TP","Boss","Dungeon"})

    -- ── FARM ─────────────────────────────────────────────
    local farmSF    = subPages["Farm"]
    local farmGroup = mkGroupBox(farmSF, 1)
    mkSectionLabel(farmGroup, "Status", 1)
    local _, setFarmStat  = mkStatus(farmGroup, "Status", "Idle", 2)
    local _, setFarmPhase = mkStatus(farmGroup, "Phase",  "--",   3)
    mkSectionLabel(farmGroup, "Pulau & Mode", 4)
    local _, getIsland = mkDropdownV2(
        farmGroup,"Pulau","⚓",Color3.fromRGB(78,46,200),
        FARM_ISLANDS, "Starter Island", nil, 5)
    local _, getFarmMode = mkDropdownV2(
        farmGroup,"Mode","⚙",Color3.fromRGB(50,130,200),
        {"V1 - Semua Titik","V2 - Titik Tengah"},
        "V1 - Semua Titik", nil, 6)
    local farmOnOffBtn,setFarmOnOff,getFarmOn,setFarmCallback =
        mkOnOffBtn(farmGroup, "Auto Farm", 7)
    mkSection(farmSF, "Adjust", 2)
    local _,setHeight,getHeight = mkSlider(farmSF,"Height Offset",0,50,0," studs",nil,3)
    local _,setSpeed, getSpeed  = mkSlider(farmSF,"Tween Speed",20,500,150," st/s",nil,4)
    local _,setTD,    getTD     = mkSlider(farmSF,"Jeda Titik",1,10,1,"s",nil,5)
    local _,setLD,    getLD     = mkSlider(farmSF,"Loop Delay",0,10,3,"s",nil,6)

    -- ── QUEST ────────────────────────────────────────────
    local questSF    = subPages["Quest"]
    local questGroup = mkGroupBox(questSF, 1)
    mkSectionLabel(questGroup, "Status", 1)
    local _, setQNPC  = mkStatus(questGroup, "NPC",  "--", 2)
    local _, setQLast = mkStatus(questGroup, "Last", "--", 3)
    mkSectionLabel(questGroup, "Target & Control", 4)
    local _, getNPCFilter = mkDropdownV2(
        questGroup,"Target NPC","Q",Color3.fromRGB(45,130,210),
        {"Semua NPC","NPC Terdekat Saja"}, "Semua NPC", nil, 5)
    local questOnOffBtn,setQuestOnOff,getQuestOn,setQuestCallback =
        mkOnOffBtn(questGroup, "Auto Quest", 6)
    mkSection(questSF, "Adjust", 2)
    local _,setQR,getQR = mkSlider(questSF,"Radius",10,200,50," st",nil,3)

    -- ── HIT (spam RequestHit remote) ──────────────────────
    local hitSF    = subPages["Hit"]
    local hitGroup = mkGroupBox(hitSF, 1)
    mkSectionLabel(hitGroup, "Status", 1)
    local _, setHitStat = mkStatus(hitGroup, "Status", "Idle", 2)
    local _, setHitRate = mkStatus(hitGroup, "Remote", "RequestHit", 3)
    mkSectionLabel(hitGroup, "Control", 4)
    local hitOnOffBtn,setHitOnOff,getHitOn,setHitCallback =
        mkOnOffBtn(hitGroup, "Auto Hit (RequestHit)", 5)

    -- ── TELEPORT ─────────────────────────────────────────
    local tpSF          = subPages["TP"]
    local tpStatusGroup = mkGroupBox(tpSF, 1)
    mkSectionLabel(tpStatusGroup, "Status", 1)
    local _, setTPStat = mkStatus(tpStatusGroup, "Status", "--", 2)
    mkSection(tpSF, "Pilih Lokasi", 2)

    for idx, loc in ipairs(TELEPORT_LOCATIONS) do
        local card = Instance.new("Frame", tpSF)
        card.Size  = UDim2.new(1,0,0,44)
        card.BackgroundColor3 = T.card
        card.BorderSizePixel  = 0; card.LayoutOrder = idx+2
        card.ClipsDescendants = true; card.ZIndex = 5
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
        local cs = Instance.new("UIStroke", card)
        cs.Color = T.border; cs.Transparency = 0.2; cs.Thickness = 1.0
        Instance.new("UIGradient", card).Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(20,18,32)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(13,12,22)),
        }
        local numLbl = Instance.new("TextLabel", card)
        numLbl.Size  = UDim2.new(0,20,1,0); numLbl.Position = UDim2.new(0,8,0,0)
        numLbl.BackgroundTransparency = 1; numLbl.Text = tostring(idx)
        numLbl.TextColor3 = T.textDim; numLbl.Font = Enum.Font.GothamBold
        numLbl.TextSize = 9; numLbl.ZIndex = 6
        local nameLbl = Instance.new("TextLabel", card)
        nameLbl.Size  = UDim2.new(1,-82,1,0); nameLbl.Position = UDim2.new(0,30,0,0)
        nameLbl.BackgroundTransparency = 1; nameLbl.Text = loc
        nameLbl.TextColor3 = T.text; nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 12; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 6
        local goBtn = Instance.new("TextButton", card)
        goBtn.Size  = UDim2.new(0,46,0,26); goBtn.Position = UDim2.new(1,-50,0.5,0)
        goBtn.AnchorPoint = Vector2.new(0,0.5)
        goBtn.BackgroundColor3 = Color3.fromRGB(35,155,110)
        goBtn.Text = "GO"; goBtn.TextColor3 = T.white
        goBtn.Font = Enum.Font.GothamBold; goBtn.TextSize = 11
        goBtn.BorderSizePixel = 0; goBtn.ZIndex = 7
        Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0,7)
        Instance.new("UIGradient", goBtn).Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(50,188,135)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(28,138,92)),
        }
        card.MouseEnter:Connect(function()
            smooth(card,{BackgroundColor3=T.cardHover},0.12):Play()
            smooth(cs,{Color=T.accentGlow,Transparency=0.1},0.12):Play()
        end)
        card.MouseLeave:Connect(function()
            smooth(card,{BackgroundColor3=T.card},0.12):Play()
            smooth(cs,{Color=T.border,Transparency=0.2},0.12):Play()
        end)
        goBtn.MouseButton1Down:Connect(function()
            smooth(goBtn,{Size=UDim2.new(0,42,0,22)},0.08):Play()
        end)
        goBtn.MouseButton1Up:Connect(function()
            smooth(goBtn,{Size=UDim2.new(0,46,0,26)},0.12):Play()
        end)
        goBtn.MouseLeave:Connect(function()
            smooth(goBtn,{Size=UDim2.new(0,46,0,26)},0.12):Play()
        end)
        local ci = loc
        goBtn.MouseButton1Click:Connect(function()
            ripple(goBtn, goBtn.AbsoluteSize.X*0.5, goBtn.AbsoluteSize.Y*0.5, T.white)
            setTPStat("→ "..ci.."...", T.amber)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                    :WaitForChild("TeleportToPortal"):FireServer(ci)
            end)
            task.delay(1.5, function() setTPStat("Done: "..ci, T.green) end)
        end)
    end

    -- ── BOSS ─────────────────────────────────────────────
    local bossSF = subPages["Boss"]

    local bossStatusGroup = mkGroupBox(bossSF, 1)
    mkSectionLabel(bossStatusGroup, "Status", 1)
    local _, setBossStat   = mkStatus(bossStatusGroup, "Status", "Idle",  2)
    local _, setBossTarget = mkStatus(bossStatusGroup, "Target", "--",    3)

    local bossSelectorGroup = mkGroupBox(bossSF, 2)
    mkSectionLabel(bossSelectorGroup, "Boss Terdeteksi", 1)

    -- Refresh button
    local bossRefreshBtn = Instance.new("TextButton", bossSelectorGroup)
    bossRefreshBtn.Size = UDim2.new(1,0,0,32)
    bossRefreshBtn.BackgroundColor3 = Color3.fromRGB(32,28,52)
    bossRefreshBtn.Text = "↻  Refresh Boss"
    bossRefreshBtn.TextColor3 = T.textSub; bossRefreshBtn.Font = Enum.Font.GothamBold
    bossRefreshBtn.TextSize = 11; bossRefreshBtn.BorderSizePixel = 0
    bossRefreshBtn.LayoutOrder = 2; bossRefreshBtn.ZIndex = 6
    Instance.new("UICorner", bossRefreshBtn).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", bossRefreshBtn).Color = T.borderBright

    -- Boss list container
    local bossListContainer = Instance.new("Frame", bossSelectorGroup)
    bossListContainer.BackgroundTransparency = 1
    bossListContainer.Size = UDim2.new(1,0,0,0)
    bossListContainer.AutomaticSize = Enum.AutomaticSize.Y
    bossListContainer.BorderSizePixel = 0; bossListContainer.LayoutOrder = 3
    local blcLayout = Instance.new("UIListLayout", bossListContainer)
    blcLayout.Padding = UDim.new(0,4); blcLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local bossControlGroup = mkGroupBox(bossSF, 3)
    mkSectionLabel(bossControlGroup, "Control", 1)
    local bossOnOffBtn,setBossOnOff,getBossOn,setBossCallback =
        mkOnOffBtn(bossControlGroup, "Auto Kill Boss", 2)

    local selectedBoss = nil
    local bossCards    = {}

    local function rebuildBossCards()
        for _, c in ipairs(bossCards) do pcall(function() c:Destroy() end) end
        bossCards = {}
        local list = detectBosses()
        if #list == 0 then
            local emptyCard = Instance.new("Frame", bossListContainer)
            emptyCard.Size = UDim2.new(1,0,0,32); emptyCard.BackgroundColor3 = Color3.fromRGB(14,13,22)
            emptyCard.BorderSizePixel = 0; emptyCard.LayoutOrder = 1; emptyCard.ZIndex = 5
            Instance.new("UICorner", emptyCard).CornerRadius = UDim.new(0,8)
            local el = Instance.new("TextLabel", emptyCard)
            el.Size = UDim2.new(1,0,1,0); el.BackgroundTransparency = 1
            el.Text = "Tidak ada boss terdeteksi"; el.TextColor3 = T.textDim
            el.Font = Enum.Font.Gotham; el.TextSize = 10; el.ZIndex = 6
            table.insert(bossCards, emptyCard); return
        end
        for idx, bossName in ipairs(list) do
            local isSel = (selectedBoss == bossName)
            local card  = Instance.new("Frame", bossListContainer)
            card.Size   = UDim2.new(1,0,0,38)
            card.BackgroundColor3 = isSel and Color3.fromRGB(36,24,64) or Color3.fromRGB(15,14,23)
            card.BorderSizePixel = 0; card.LayoutOrder = idx; card.ZIndex = 5
            Instance.new("UICorner", card).CornerRadius = UDim.new(0,9)
            local cs = Instance.new("UIStroke", card)
            cs.Color = isSel and T.accentGlow or T.border
            cs.Transparency = isSel and 0.08 or 0.4; cs.Thickness = 1.0
            local dot = Instance.new("Frame", card)
            dot.Size = UDim2.new(0,6,0,6); dot.Position = UDim2.new(0,10,0.5,0)
            dot.AnchorPoint = Vector2.new(0,0.5)
            dot.BackgroundColor3 = isSel and T.green or T.red
            dot.BorderSizePixel = 0; dot.ZIndex = 7
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
            local nameL = Instance.new("TextLabel", card)
            nameL.Size = UDim2.new(1,-80,1,0); nameL.Position = UDim2.new(0,22,0,0)
            nameL.BackgroundTransparency = 1; nameL.Text = bossName
            nameL.TextColor3 = isSel and T.white or T.textSub
            nameL.Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham
            nameL.TextSize = 11; nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.ZIndex = 6
            local selBtn = Instance.new("TextButton", card)
            selBtn.Size = UDim2.new(0,52,0,24); selBtn.Position = UDim2.new(1,-56,0.5,0)
            selBtn.AnchorPoint = Vector2.new(0,0.5)
            selBtn.BackgroundColor3 = isSel and T.accentSoft or Color3.fromRGB(28,24,44)
            selBtn.Text = isSel and "✓ Aktif" or "Pilih"
            selBtn.TextColor3 = T.white; selBtn.Font = Enum.Font.GothamBold
            selBtn.TextSize = 10; selBtn.BorderSizePixel = 0; selBtn.ZIndex = 7
            Instance.new("UICorner", selBtn).CornerRadius = UDim.new(0,6)
            local ci = bossName
            selBtn.MouseButton1Click:Connect(function()
                selectedBoss = ci
                setBossTarget(ci, T.accentGlow)
                ripple(selBtn, selBtn.AbsoluteSize.X*0.5, selBtn.AbsoluteSize.Y*0.5, T.accent)
                rebuildBossCards()
            end)
            table.insert(bossCards, card)
        end
    end
    bossRefreshBtn.MouseButton1Click:Connect(function()
        ripple(bossRefreshBtn, bossRefreshBtn.AbsoluteSize.X*0.5, bossRefreshBtn.AbsoluteSize.Y*0.5, T.white)
        rebuildBossCards()
        setBossStat("List diperbarui", T.accentGlow)
        task.delay(1.5, function() if not getBossOn() then setBossStat("Idle",T.textDim) end end)
    end)
    rebuildBossCards()

    -- ── DUNGEON ──────────────────────────────────────────
    local dungeonSF = subPages["Dungeon"]

    local dungeonStatusGroup = mkGroupBox(dungeonSF, 1)
    mkSectionLabel(dungeonStatusGroup, "Status", 1)
    local _, setDungeonStat = mkStatus(dungeonStatusGroup, "Status", "Idle",   2)
    local _, setDungeonNPC  = mkStatus(dungeonStatusGroup, "NPC",    "--",     3)
    local _, setDungeonHit  = mkStatus(dungeonStatusGroup, "Hit",    "0 /s",   4)

    local dungeonControlGroup = mkGroupBox(dungeonSF, 2)
    mkSectionLabel(dungeonControlGroup, "Control", 1)
    local dungeonOnOffBtn,setDungeonOnOff,getDungeonOn,setDungeonCallback =
        mkOnOffBtn(dungeonControlGroup, "Auto Dungeon", 2)

    -- Info note
    mkSection(dungeonSF, "Info", 3)
    local _, _ = mkStatus(dungeonSF, "Remote", "RequestHit",         4)
    local _, _ = mkStatus(dungeonSF, "Tween",  "Ke semua NPC",       5)
    local _, _ = mkStatus(dungeonSF, "Jeda",   "1 detik per NPC",    6)

    -- ════════════════════════════════
    -- PAGE: SETTINGS
    -- ════════════════════════════════
    local settingsSF = mkScrollPage(sideData["Settings"].page)

    mkSection(settingsSF, "Appearance", 1)
    mkSlider(settingsSF,"UI Scale",70,130,100,"%",function(v)
        root.Size=UDim2.new(0,root.AbsoluteSize.X*(v/100),0,root.AbsoluteSize.Y*(v/100))
    end, 2)
    mkSlider(settingsSF,"Border Opacity",0,100,90,"%",function(v)
        rootStroke.Transparency=1-(v/100)
    end, 3)
    mkSlider(settingsSF,"Corner Radius",6,24,16,"px",function(v)
        rootCorner.CornerRadius=UDim.new(0,v)
    end, 4)

    mkSection(settingsSF, "Font", 5)
    mkSlider(settingsSF,"Font Size",8,18,12,"px",function(v)
        lib.applyFontSize(v)
    end, 6)

    mkSection(settingsSF, "Accent Color", 7)
    mkDropdownV2(settingsSF,"Accent","🎨",Color3.fromRGB(118,68,255),
        {"Purple","Blue","Cyan","Green","Red"}, "Purple", function(v)
            lib.applyAccent(v)
        end, 8)

    mkSection(settingsSF, "Particles", 9)
    mkToggle(settingsSF,"Enable Particles",true,function(v)
        UISettings.particles=v
        for _,p in ipairs(particleList) do
            if p and p.Parent then p.Visible=v end
        end
    end, 10)
    mkSlider(settingsSF,"Jumlah Partikel",5,80,26,"",function(v)
        UISettings.particleCount=v; spawnParticles(v)
    end, 11)

    mkSection(settingsSF, "UI Background", 12)
    mkDropdownV2(settingsSF,"Mode BG Window","◈",Color3.fromRGB(80,80,180),
        {"Solid","Transparent","Blur"}, "Solid", function(v)
            applyUIBgMode(v)
        end, 13)

    mkSection(settingsSF, "Minimize Bar", 14)
    mkDropdownV2(settingsSF,"Mode BG Minimize","◉",Color3.fromRGB(60,120,200),
        {"Solid","Transparent","Blur"}, "Solid", function(v)
            applyMiniBgMode(v)
        end, 15)

    mkSection(settingsSF, "Effects", 16)
    mkToggle(settingsSF,"Window Glow",true,function(v)
        UISettings.glow=v
        smooth(rootGlow,{ImageTransparency=v and 0.85 or 1},0.3):Play()
    end, 17)

    -- ════════════════════════════════
    -- RETURN REFS
    -- ════════════════════════════════
    return {
        -- Farm
        getIsland=getIsland, getFarmMode=getFarmMode,
        getHeight=getHeight, getSpeed=getSpeed, getTD=getTD, getLD=getLD,
        setFarmStat=setFarmStat, setFarmPhase=setFarmPhase,
        setFarmOnOff=setFarmOnOff, getFarmOn=getFarmOn, setFarmCallback=setFarmCallback,
        -- Quest
        getNPCFilter=getNPCFilter, getQR=getQR,
        setQNPC=setQNPC, setQLast=setQLast,
        setQuestOnOff=setQuestOnOff, getQuestOn=getQuestOn, setQuestCallback=setQuestCallback,
        -- Hit
        setHitStat=setHitStat, setHitRate=setHitRate,
        setHitOnOff=setHitOnOff, getHitOn=getHitOn, setHitCallback=setHitCallback,
        -- Boss
        getSelectedBoss=function() return selectedBoss end,
        setBossStat=setBossStat, setBossTarget=setBossTarget,
        setBossOnOff=setBossOnOff, getBossOn=getBossOn, setBossCallback=setBossCallback,
        -- Dungeon
        setDungeonStat=setDungeonStat, setDungeonNPC=setDungeonNPC, setDungeonHit=setDungeonHit,
        setDungeonOnOff=setDungeonOnOff, getDungeonOn=getDungeonOn, setDungeonCallback=setDungeonCallback,
    }
end
