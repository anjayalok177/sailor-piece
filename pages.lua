-- ╔══════════════════════════════════╗
-- ║  YiDaMuSake — Pages Builder  v6 ║
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
    -- PAGE: INFO
    -- ════════════════════════════════
    local infoSF = mkScrollPage(sideData["Info"].page)
    mkSection(infoSF,"Script",1)
    mkStatus(infoSF,"Name","Yi Da Mu Sake",2)
    mkStatus(infoSF,"Ver","sailor piece  v6",3)
    mkSection(infoSF,"Farm",4)
    mkStatus(infoSF,"V1","Keliling 5 titik berurutan",5)
    mkStatus(infoSF,"V2","Diam di titik tengah pulau",6)
    mkStatus(infoSF,"Pulau","14 pulau tersedia",7)
    mkSection(infoSF,"Boss Kill",8)
    mkStatus(infoSF,"Path","workspace.NPCs.{Boss}.Boss",9)
    mkStatus(infoSF,"Detect","Cek BoolValue dalam Boss",10)
    mkStatus(infoSF,"Fly","Tween 70st/s ke boss",11)
    mkStatus(infoSF,"Click","Auto click dalam radius 50st",12)
    mkSection(infoSF,"Quest",13)
    mkStatus(infoSF,"NPC","QuestNPC1 — QuestNPC19",14)
    mkSection(infoSF,"Teleport",15)
    mkStatus(infoSF,"Lokasi","16 lokasi tersedia",16)
    mkSection(infoSF,"UI",17)
    mkStatus(infoSF,"Resize","Drag pojok kanan bawah",18)

    -- ════════════════════════════════
    -- PAGE: MAIN  (5 sub-tabs)
    -- ════════════════════════════════
    local mainPage  = sideData["Main"].page
    local mainInner = Instance.new("Frame",mainPage)
    mainInner.Size  = UDim2.new(1,-8,1,-8)
    mainInner.Position = UDim2.new(0,4,0,4)
    mainInner.BackgroundTransparency = 1; mainInner.ZIndex = 3

    local subPages = mkSubTabBar(mainInner,{"Farm","Quest","Hit","TP","Boss"})

    -- ── FARM ─────────────────────────────────────────────
    local farmSF    = subPages["Farm"]
    local farmGroup = mkGroupBox(farmSF, 1)
    mkSectionLabel(farmGroup,"Status",1)
    local _,setFarmStat  = mkStatus(farmGroup,"Status","Idle",2)
    local _,setFarmPhase = mkStatus(farmGroup,"Phase","--",3)
    mkSectionLabel(farmGroup,"Pulau & Mode",4)
    local _,getIsland = mkDropdownV2(
        farmGroup,"Pulau","⚓",Color3.fromRGB(78,46,200),
        FARM_ISLANDS,"Starter Island",nil,5)
    local _,getFarmMode = mkDropdownV2(
        farmGroup,"Mode","⚙",Color3.fromRGB(50,130,200),
        {"V1 - Semua Titik","V2 - Titik Tengah"},
        "V1 - Semua Titik",nil,6)
    local farmOnOffBtn,setFarmOnOff,getFarmOn,setFarmCallback =
        mkOnOffBtn(farmGroup,"Auto Farm",7)
    mkSection(farmSF,"Adjust",2)
    local _,setHeight,getHeight = mkSlider(farmSF,"Height Offset",0,50,0," studs",nil,3)
    local _,setSpeed, getSpeed  = mkSlider(farmSF,"Tween Speed",20,500,150," st/s",nil,4)
    local _,setTD,    getTD     = mkSlider(farmSF,"Jeda Titik",1,10,1,"s",nil,5)
    local _,setLD,    getLD     = mkSlider(farmSF,"Loop Delay",0,10,3,"s",nil,6)

    -- ── QUEST ────────────────────────────────────────────
    local questSF    = subPages["Quest"]
    local questGroup = mkGroupBox(questSF,1)
    mkSectionLabel(questGroup,"Status",1)
    local _,setQNPC  = mkStatus(questGroup,"NPC","--",2)
    local _,setQLast = mkStatus(questGroup,"Last","--",3)
    mkSectionLabel(questGroup,"Target & Control",4)
    local _,getNPCFilter = mkDropdownV2(
        questGroup,"Target NPC","Q",Color3.fromRGB(45,130,210),
        {"Semua NPC","NPC Terdekat Saja"},"Semua NPC",nil,5)
    local questOnOffBtn,setQuestOnOff,getQuestOn,setQuestCallback =
        mkOnOffBtn(questGroup,"Auto Quest",6)
    mkSection(questSF,"Adjust",2)
    local _,setQR,getQR = mkSlider(questSF,"Radius",10,200,50," st",nil,3)

    -- ── HIT ──────────────────────────────────────────────
    local hitSF    = subPages["Hit"]
    local hitGroup = mkGroupBox(hitSF,1)
    mkSectionLabel(hitGroup,"Status",1)
    local _,setHitStat = mkStatus(hitGroup,"Status","Idle",2)
    mkSectionLabel(hitGroup,"Method & Control",3)
    local _,getHitMethod = mkDropdownV2(
        hitGroup,"Click Method","H",Color3.fromRGB(180,60,80),
        {"VIM SendMouseButtonEvent","mouse1click()","mouse1press/release","UIS InputBegan Fire"},
        "VIM SendMouseButtonEvent",nil,4)
    local hitOnOffBtn,setHitOnOff,getHitOn,setHitCallback =
        mkOnOffBtn(hitGroup,"Auto Hit",5)
    mkSection(hitSF,"Adjust",2)
    local _,setCI,getCI = mkSlider(hitSF,"Interval",50,1000,100,"ms",nil,3)

    -- ── TELEPORT (list GO button, border per item) ────────
    local tpSF = subPages["TP"]

    local tpStatusGroup = mkGroupBox(tpSF,1)
    mkSectionLabel(tpStatusGroup,"Status",1)
    local _,setTPStat = mkStatus(tpStatusGroup,"Status","--",2)

    mkSection(tpSF,"Pilih Lokasi",2)

    for idx,loc in ipairs(TELEPORT_LOCATIONS) do
        local card = Instance.new("Frame",tpSF)
        card.Size  = UDim2.new(1,0,0,46)
        card.BackgroundColor3 = T.card
        card.BorderSizePixel  = 0; card.LayoutOrder = idx+2
        card.ClipsDescendants = true; card.ZIndex = 5
        Instance.new("UICorner",card).CornerRadius = UDim.new(0,10)
        local cs = Instance.new("UIStroke",card)
        cs.Color = T.borderBright; cs.Transparency = 0.28; cs.Thickness = 1.2
        Instance.new("UIGradient",card).Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(25,22,38)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(16,14,26)),
        }
        local numLbl = Instance.new("TextLabel",card)
        numLbl.Size = UDim2.new(0,22,1,0); numLbl.Position = UDim2.new(0,8,0,0)
        numLbl.BackgroundTransparency=1; numLbl.Text=tostring(idx)
        numLbl.TextColor3=T.textDim; numLbl.Font=Enum.Font.GothamBold
        numLbl.TextSize=9; numLbl.ZIndex=6
        local nameLbl = Instance.new("TextLabel",card)
        nameLbl.Size = UDim2.new(1,-86,1,0); nameLbl.Position = UDim2.new(0,32,0,0)
        nameLbl.BackgroundTransparency=1; nameLbl.Text=loc
        nameLbl.TextColor3=T.text; nameLbl.Font=Enum.Font.GothamBold
        nameLbl.TextSize=12; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=6
        local goBtn = Instance.new("TextButton",card)
        goBtn.Size = UDim2.new(0,48,0,28); goBtn.Position = UDim2.new(1,-54,0.5,0)
        goBtn.AnchorPoint = Vector2.new(0,0.5)
        goBtn.BackgroundColor3 = Color3.fromRGB(35,155,110)
        goBtn.Text = "GO"; goBtn.TextColor3 = T.white
        goBtn.Font = Enum.Font.GothamBold; goBtn.TextSize = 12
        goBtn.BorderSizePixel = 0; goBtn.ZIndex = 7
        Instance.new("UICorner",goBtn).CornerRadius = UDim.new(0,8)
        Instance.new("UIGradient",goBtn).Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(52,195,138)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(28,140,95)),
        }
        local goStroke = Instance.new("UIStroke",goBtn)
        goStroke.Color=Color3.fromRGB(60,215,152); goStroke.Thickness=1.2; goStroke.Transparency=0.35
        card.MouseEnter:Connect(function()
            smooth(card,{BackgroundColor3=T.cardHover},0.14):Play()
            smooth(cs,{Color=T.accentGlow,Transparency=0.1},0.14):Play()
        end)
        card.MouseLeave:Connect(function()
            smooth(card,{BackgroundColor3=T.card},0.14):Play()
            smooth(cs,{Color=T.borderBright,Transparency=0.28},0.14):Play()
        end)
        goBtn.MouseButton1Down:Connect(function()
            smooth(goBtn,{Size=UDim2.new(0,44,0,24)},0.09):Play()
        end)
        goBtn.MouseButton1Up:Connect(function()
            smooth(goBtn,{Size=UDim2.new(0,48,0,28)},0.14):Play()
        end)
        goBtn.MouseLeave:Connect(function()
            smooth(goBtn,{Size=UDim2.new(0,48,0,28)},0.14):Play()
        end)
        local ci = loc
        goBtn.MouseButton1Click:Connect(function()
            ripple(goBtn,goBtn.AbsoluteSize.X*0.5,goBtn.AbsoluteSize.Y*0.5,T.white)
            setTPStat("→ "..ci.."...", T.amber)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                    :WaitForChild("TeleportToPortal"):FireServer(ci)
            end)
            task.delay(1.5,function() setTPStat("Done: "..ci, T.green) end)
        end)
    end

    -- ── BOSS KILL ─────────────────────────────────────────
    local bossSF = subPages["Boss"]

    -- Status group
    local bossStatusGroup = mkGroupBox(bossSF,1)
    mkSectionLabel(bossStatusGroup,"Status",1)
    local _,setBossStat   = mkStatus(bossStatusGroup,"Status","Idle",2)
    local _,setBossTarget = mkStatus(bossStatusGroup,"Target","--",3)

    -- Boss selector group
    local bossSelectorGroup = mkGroupBox(bossSF,2)
    mkSectionLabel(bossSelectorGroup,"Boss Terdeteksi",1)

    -- Refresh button
    local refreshBtn = Instance.new("TextButton",bossSelectorGroup)
    refreshBtn.Size = UDim2.new(1,0,0,34)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(38,76,160)
    refreshBtn.Text = "↻  Refresh Boss List"
    refreshBtn.TextColor3 = T.white; refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 11; refreshBtn.BorderSizePixel = 0
    refreshBtn.LayoutOrder = 2; refreshBtn.ZIndex = 6
    Instance.new("UICorner",refreshBtn).CornerRadius = UDim.new(0,9)
    local rbStroke = Instance.new("UIStroke",refreshBtn)
    rbStroke.Color = Color3.fromRGB(70,120,220); rbStroke.Thickness=1.2; rbStroke.Transparency=0.3
    refreshBtn.MouseButton1Down:Connect(function()
        smooth(refreshBtn,{Size=UDim2.new(0.97,0,0,30)},0.09):Play()
    end)
    refreshBtn.MouseButton1Up:Connect(function()
        smooth(refreshBtn,{Size=UDim2.new(1,0,0,34)},0.14):Play()
    end)
    refreshBtn.MouseLeave:Connect(function()
        smooth(refreshBtn,{Size=UDim2.new(1,0,0,34)},0.14):Play()
    end)

    -- Container boss list (auto-size)
    local bossListContainer = Instance.new("Frame",bossSelectorGroup)
    bossListContainer.BackgroundTransparency = 1
    bossListContainer.Size = UDim2.new(1,0,0,0)
    bossListContainer.AutomaticSize = Enum.AutomaticSize.Y
    bossListContainer.BorderSizePixel = 0
    bossListContainer.LayoutOrder = 3; bossListContainer.ZIndex = 5
    local blcLayout = Instance.new("UIListLayout",bossListContainer)
    blcLayout.Padding = UDim.new(0,4); blcLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Control group
    local bossControlGroup = mkGroupBox(bossSF,3)
    mkSectionLabel(bossControlGroup,"Control",1)
    local bossOnOffBtn,setBossOnOff,getBossOn,setBossCallback =
        mkOnOffBtn(bossControlGroup,"Auto Kill Boss",2)

    -- ── Boss selector logic ──────────────────────────────
    local selectedBoss = nil
    local bossCards    = {}

    local function detectBosses()
        local list = {}
        local npcs = workspace:FindFirstChild("NPCs")
        if not npcs then return list end
        for _,child in ipairs(npcs:GetChildren()) do
            local bossModel = child:FindFirstChild("Boss")
            if bossModel then
                -- Cek keberadaan BoolValue di dalam Boss model
                local hasBool = false
                for _,v in ipairs(bossModel:GetChildren()) do
                    if v:IsA("BoolValue") then hasBool=true; break end
                end
                if hasBool then
                    table.insert(list, child.Name)
                end
            end
        end
        return list
    end

    local function rebuildBossCards()
        -- Hapus kartu lama
        for _,c in ipairs(bossCards) do
            pcall(function() c:Destroy() end)
        end
        bossCards = {}

        local list = detectBosses()

        if #list == 0 then
            local emptyCard = Instance.new("Frame",bossListContainer)
            emptyCard.Size = UDim2.new(1,0,0,34)
            emptyCard.BackgroundColor3 = Color3.fromRGB(18,16,28)
            emptyCard.BorderSizePixel = 0; emptyCard.LayoutOrder=1; emptyCard.ZIndex=5
            Instance.new("UICorner",emptyCard).CornerRadius = UDim.new(0,8)
            local emptyLbl = Instance.new("TextLabel",emptyCard)
            emptyLbl.Size = UDim2.new(1,0,1,0); emptyLbl.BackgroundTransparency=1
            emptyLbl.Text = "Tidak ada boss terdeteksi"
            emptyLbl.TextColor3=T.textDim; emptyLbl.Font=Enum.Font.Gotham
            emptyLbl.TextSize=10; emptyLbl.ZIndex=6
            table.insert(bossCards, emptyCard)
            return
        end

        for idx,bossName in ipairs(list) do
            local isSelected = (selectedBoss == bossName)
            local card = Instance.new("Frame",bossListContainer)
            card.Size = UDim2.new(1,0,0,40)
            card.BackgroundColor3 = isSelected
                and Color3.fromRGB(40,28,72)
                or  Color3.fromRGB(18,16,28)
            card.BorderSizePixel=0; card.LayoutOrder=idx; card.ZIndex=5
            Instance.new("UICorner",card).CornerRadius = UDim.new(0,9)
            local cs = Instance.new("UIStroke",card)
            cs.Color = isSelected and T.accentGlow or T.border
            cs.Transparency = isSelected and 0.08 or 0.5
            cs.Thickness = isSelected and 1.5 or 1.0

            local dot = Instance.new("Frame",card)
            dot.Size = UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,10,0.5,0)
            dot.AnchorPoint=Vector2.new(0,0.5)
            dot.BackgroundColor3 = isSelected and T.accentGlow or T.textDim
            dot.BorderSizePixel=0; dot.ZIndex=7
            Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

            local nameLbl = Instance.new("TextLabel",card)
            nameLbl.Size=UDim2.new(1,-80,1,0); nameLbl.Position=UDim2.new(0,24,0,0)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=bossName
            nameLbl.TextColor3 = isSelected and T.white or T.textSub
            nameLbl.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            nameLbl.TextSize=11; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=6

            local selBtn = Instance.new("TextButton",card)
            selBtn.Size=UDim2.new(0,54,0,26); selBtn.Position=UDim2.new(1,-58,0.5,0)
            selBtn.AnchorPoint=Vector2.new(0,0.5)
            selBtn.BackgroundColor3 = isSelected and T.accentSoft or Color3.fromRGB(32,28,50)
            selBtn.Text = isSelected and "✓ Aktif" or "Pilih"
            selBtn.TextColor3=T.white; selBtn.Font=Enum.Font.GothamBold
            selBtn.TextSize=10; selBtn.BorderSizePixel=0; selBtn.ZIndex=7
            Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,7)

            local ci = bossName
            selBtn.MouseButton1Click:Connect(function()
                selectedBoss = ci
                setBossTarget(ci, T.accentGlow)
                ripple(selBtn,selBtn.AbsoluteSize.X*0.5,selBtn.AbsoluteSize.Y*0.5,T.accent)
                rebuildBossCards()
            end)

            table.insert(bossCards, card)
        end
    end

    -- Refresh button handler
    refreshBtn.MouseButton1Click:Connect(function()
        ripple(refreshBtn,refreshBtn.AbsoluteSize.X*0.5,refreshBtn.AbsoluteSize.Y*0.5,T.white)
        rebuildBossCards()
        setBossStat("List diperbarui", T.accentGlow)
        task.delay(1.5,function()
            if not getBossOn() then setBossStat("Idle",T.textDim) end
        end)
    end)

    -- Initial build
    rebuildBossCards()

    -- ════════════════════════════════
    -- PAGE: SETTINGS
    -- ════════════════════════════════
    local settingsSF = mkScrollPage(sideData["Settings"].page)

    mkSection(settingsSF,"Appearance",1)
    mkSlider(settingsSF,"UI Scale",70,130,100,"%",function(v)
        root.Size=UDim2.new(0,root.AbsoluteSize.X*(v/100),0,root.AbsoluteSize.Y*(v/100))
    end,2)
    mkSlider(settingsSF,"Border Opacity",0,100,90,"%",function(v)
        rootStroke.Transparency=1-(v/100)
    end,3)
    mkSlider(settingsSF,"Corner Radius",6,24,16,"px",function(v)
        rootCorner.CornerRadius=UDim.new(0,v)
    end,4)

    mkSection(settingsSF,"Font",5)
    mkSlider(settingsSF,"Font Size",8,18,12,"px",function(v)
        UISettings.fontSize=v
        local function doUpdate(obj)
            for _,c in ipairs(obj:GetChildren()) do
                if (c:IsA("TextLabel") or c:IsA("TextButton"))
                    and c.TextSize>=11 and c.TextSize<=16 then
                    c.TextSize=v
                end
                doUpdate(c)
            end
        end
        doUpdate(contentArea)
    end,6)

    mkSection(settingsSF,"Accent Color",7)
    mkDropdownV2(settingsSF,"Accent","🎨",Color3.fromRGB(118,68,255),
        {"Purple","Blue","Cyan","Green","Red"},"Purple",function(v)
            lib.applyAccent(v)
        end,8)

    mkSection(settingsSF,"Particles",9)
    mkToggle(settingsSF,"Enable Particles",true,function(v)
        UISettings.particles=v
        for _,p in ipairs(particleList) do
            if p and p.Parent then p.Visible=v end
        end
    end,10)
    mkSlider(settingsSF,"Jumlah Partikel",5,80,26,"",function(v)
        UISettings.particleCount=v; spawnParticles(v)
    end,11)

    mkSection(settingsSF,"UI Background",12)
    mkDropdownV2(settingsSF,"Mode BG Window","◈",Color3.fromRGB(80,80,180),
        {"Solid","Transparent","Blur"},"Solid",function(v)
            applyUIBgMode(v)
        end,13)

    mkSection(settingsSF,"Minimize Bar",14)
    mkDropdownV2(settingsSF,"Mode BG Minimize","◉",Color3.fromRGB(60,120,200),
        {"Solid","Transparent","Blur"},"Solid",function(v)
            applyMiniBgMode(v)
        end,15)

    mkSection(settingsSF,"Effects",16)
    mkToggle(settingsSF,"Window Glow",true,function(v)
        UISettings.glow=v
        smooth(rootGlow,{ImageTransparency=v and 0.85 or 1},0.3):Play()
    end,17)

    mkSection(settingsSF,"Info",18)
    mkStatus(settingsSF,"Game","Sailor Piece",19)
    mkStatus(settingsSF,"Dev","Bibran",20)
    mkStatus(settingsSF,"Exec","Mobile / iPhone",21)
    mkSection(settingsSF,"Keybind",22)
    mkStatus(settingsSF,"Drag","Topbar",23)
    mkStatus(settingsSF,"Resize","Pojok kanan bawah",24)
    mkStatus(settingsSF,"Min","Tombol — kuning",25)
    mkStatus(settingsSF,"Close","Tombol × merah",26)

    -- ════════════════════════════════
    -- RETURN REFS
    -- ════════════════════════════════
    return {
        -- Farm
        getIsland=getIsland, getFarmMode=getFarmMode,
        getHeight=getHeight, getSpeed=getSpeed, getTD=getTD, getLD=getLD,
        setFarmStat=setFarmStat, setFarmPhase=setFarmPhase,
        setFarmOnOff=setFarmOnOff, getFarmOn=getFarmOn,
        setFarmCallback=setFarmCallback,
        -- Quest
        getNPCFilter=getNPCFilter, getQR=getQR,
        setQNPC=setQNPC, setQLast=setQLast,
        setQuestOnOff=setQuestOnOff, getQuestOn=getQuestOn,
        setQuestCallback=setQuestCallback,
        -- Hit
        getHitMethod=getHitMethod, getCI=getCI,
        setHitStat=setHitStat,
        setHitOnOff=setHitOnOff, getHitOn=getHitOn,
        setHitCallback=setHitCallback,
        -- Boss Kill
        getSelectedBoss = function() return selectedBoss end,
        setBossStat     = setBossStat,
        setBossTarget   = setBossTarget,
        setBossOnOff    = setBossOnOff,
        getBossOn       = getBossOn,
        setBossCallback = setBossCallback,
    }
end
