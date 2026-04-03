-- ╔══════════════════════════════════╗
-- ║  YiDaMuSake — Pages Builder  v6 ║
-- ╚══════════════════════════════════╝

-- Lokasi teleport (exact value server)
local TELEPORT_LOCATIONS = {
    "Starter","Jungle","Desert","Snow",
    "Sailor","Shibuya","HollowIsland","Boss",
    "Dungeon","Shinjuku","Slime","Academy",
    "Judgement","Ninja","Lawless","Tower",
}

-- Island list untuk farm dropdown (harus cocok dengan ISLANDS di logic.lua)
local FARM_ISLANDS = {
    "Starter Island","Jungle Island","Desert Island","Snow Island",
    "Shibuya","Hollow",
    "Shinjuku Island#1","Shinjuku Island#2",
    "Slime","Academy","Judgement","Soul Dominion",
    "Ninja","Lawless",
}

return function(lib, sideData, contentArea, bgF, root, rootCorner, rootStroke, rootGlow, particleList, spawnParticles, applyUIBgMode, applyMiniBgMode)
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
    mkStatus(infoSF,"Move","Jarak >100=Tween | <100=TP",7)
    mkStatus(infoSF,"Pulau","14 pulau tersedia",8)
    mkSection(infoSF,"Quest",9)
    mkStatus(infoSF,"Cara","Fire sekali per NPC baru",10)
    mkStatus(infoSF,"NPC","QuestNPC1 — QuestNPC19",11)
    mkSection(infoSF,"Hit",12)
    mkStatus(infoSF,"Method","VirtualInputManager",13)
    mkSection(infoSF,"Teleport",14)
    mkStatus(infoSF,"Lokasi","16 lokasi tersedia",15)
    mkSection(infoSF,"UI",16)
    mkStatus(infoSF,"Resize","Drag pojok kanan bawah",17)
    mkStatus(infoSF,"Range","Min 400x280 — Max 96% layar",18)

    -- ════════════════════════════════
    -- PAGE: MAIN (sub-tabs)
    -- ════════════════════════════════
    local mainPage  = sideData["Main"].page
    local mainInner = Instance.new("Frame", mainPage)
    mainInner.Size  = UDim2.new(1,-8,1,-8)
    mainInner.Position = UDim2.new(0,4,0,4)
    mainInner.BackgroundTransparency = 1; mainInner.ZIndex = 3

    local subPages = mkSubTabBar(mainInner, {"Farm","Quest","Hit","TP"})

    -- ── FARM ─────────────────────────────────────────────
    local farmSF = subPages["Farm"]

    -- Group: Status + Select + ON/OFF (1 border)
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

    -- Slider Adjust (card biasa, di luar group)
    mkSection(farmSF, "Adjust", 2)
    local _,setHeight,getHeight = mkSlider(farmSF,"Height Offset",0,50,0," studs",nil,3)
    local _,setSpeed, getSpeed  = mkSlider(farmSF,"Tween Speed",20,500,150," st/s",nil,4)
    local _,setTD,    getTD     = mkSlider(farmSF,"Jeda Titik",1,10,1,"s",nil,5)
    local _,setLD,    getLD     = mkSlider(farmSF,"Loop Delay",0,10,3,"s",nil,6)

    -- ── QUEST ────────────────────────────────────────────
    local questSF = subPages["Quest"]

    local questGroup = mkGroupBox(questSF, 1)
    mkSectionLabel(questGroup, "Status", 1)
    local _, setQNPC  = mkStatus(questGroup, "NPC",  "--", 2)
    local _, setQLast = mkStatus(questGroup, "Last", "--", 3)
    mkSectionLabel(questGroup, "Target & Control", 4)
    local _, getNPCFilter = mkDropdownV2(
        questGroup,"Target NPC","Q",Color3.fromRGB(45,130,210),
        {"Semua NPC","NPC Terdekat Saja"},
        "Semua NPC", nil, 5)
    local questOnOffBtn,setQuestOnOff,getQuestOn,setQuestCallback =
        mkOnOffBtn(questGroup, "Auto Quest", 6)

    mkSection(questSF, "Adjust", 2)
    local _,setQR,getQR = mkSlider(questSF,"Radius",10,200,50," st",nil,3)

    -- ── HIT ──────────────────────────────────────────────
    local hitSF = subPages["Hit"]

    local hitGroup = mkGroupBox(hitSF, 1)
    mkSectionLabel(hitGroup, "Status", 1)
    local _, setHitStat = mkStatus(hitGroup, "Status", "Idle", 2)
    mkSectionLabel(hitGroup, "Method & Control", 3)
    local _, getHitMethod = mkDropdownV2(
        hitGroup,"Click Method","H",Color3.fromRGB(180,60,80),
        {"VIM SendMouseButtonEvent","mouse1click()","mouse1press/release","UIS InputBegan Fire"},
        "VIM SendMouseButtonEvent", nil, 4)
    local hitOnOffBtn,setHitOnOff,getHitOn,setHitCallback =
        mkOnOffBtn(hitGroup, "Auto Hit", 5)

    mkSection(hitSF, "Adjust", 2)
    local _,setCI,getCI = mkSlider(hitSF,"Interval",50,1000,100,"ms",nil,3)

    -- ── TELEPORT (list dengan GO button, tiap lokasi border sendiri) ──
    local tpSF = subPages["TP"]

    -- Status group
    local tpStatusGroup = mkGroupBox(tpSF, 1)
    mkSectionLabel(tpStatusGroup, "Status", 1)
    local _, setTPStat = mkStatus(tpStatusGroup, "Status", "--", 2)

    -- Header section
    mkSection(tpSF, "Pilih Lokasi", 2)

    -- List lokasi — setiap item punya border sendiri
    for idx, loc in ipairs(TELEPORT_LOCATIONS) do
        local card = Instance.new("Frame", tpSF)
        card.Size  = UDim2.new(1,0,0,46)
        card.BackgroundColor3 = T.card
        card.BorderSizePixel  = 0
        card.LayoutOrder = idx + 2
        card.ClipsDescendants = true
        card.ZIndex = 5
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)

        -- Border individual tiap card
        local cs = Instance.new("UIStroke", card)
        cs.Color = T.borderBright; cs.Transparency = 0.28; cs.Thickness = 1.2

        Instance.new("UIGradient", card).Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25,22,38)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16,14,26)),
        }

        -- Nomor urut
        local numLbl = Instance.new("TextLabel", card)
        numLbl.Size  = UDim2.new(0,22,1,0)
        numLbl.Position = UDim2.new(0,8,0,0)
        numLbl.BackgroundTransparency = 1
        numLbl.Text      = tostring(idx)
        numLbl.TextColor3 = T.textDim
        numLbl.Font      = Enum.Font.GothamBold
        numLbl.TextSize  = 9; numLbl.ZIndex = 6

        -- Nama lokasi
        local nameLbl = Instance.new("TextLabel", card)
        nameLbl.Size  = UDim2.new(1,-86,1,0)
        nameLbl.Position = UDim2.new(0,32,0,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = loc
        nameLbl.TextColor3 = T.text
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = 6

        -- Tombol GO (hijau)
        local goBtn = Instance.new("TextButton", card)
        goBtn.Size  = UDim2.new(0,50,0,28)
        goBtn.Position = UDim2.new(1,-58,0.5,0)
        goBtn.AnchorPoint = Vector2.new(0,0.5)
        goBtn.BackgroundColor3 = Color3.fromRGB(35,155,110)
        goBtn.Text = "GO"
        goBtn.TextColor3 = T.white
        goBtn.Font = Enum.Font.GothamBold
        goBtn.TextSize = 12
        goBtn.BorderSizePixel = 0
        goBtn.ZIndex = 7
        Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0,8)
        Instance.new("UIGradient", goBtn).Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(52,195,138)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(28,140,95)),
        }
        local goStroke = Instance.new("UIStroke", goBtn)
        goStroke.Color = Color3.fromRGB(60,215,152)
        goStroke.Thickness = 1.2; goStroke.Transparency = 0.35

        -- Hover card
        card.MouseEnter:Connect(function()
            smooth(card, {BackgroundColor3 = T.cardHover}, 0.14):Play()
            smooth(cs, {Color = T.accentGlow, Transparency = 0.1}, 0.14):Play()
        end)
        card.MouseLeave:Connect(function()
            smooth(card, {BackgroundColor3 = T.card}, 0.14):Play()
            smooth(cs, {Color = T.borderBright, Transparency = 0.28}, 0.14):Play()
        end)

        -- GO button press anim
        goBtn.MouseButton1Down:Connect(function()
            smooth(goBtn, {Size = UDim2.new(0,46,0,24)}, 0.09):Play()
        end)
        goBtn.MouseButton1Up:Connect(function()
            smooth(goBtn, {Size = UDim2.new(0,50,0,28)}, 0.14):Play()
        end)
        goBtn.MouseLeave:Connect(function()
            smooth(goBtn, {Size = UDim2.new(0,50,0,28)}, 0.14):Play()
        end)
        goBtn.MouseEnter:Connect(function()
            smooth(goStroke, {Transparency = 0.0}, 0.12):Play()
        end)

        -- Teleport action
        local ci = loc
        goBtn.MouseButton1Click:Connect(function()
            ripple(goBtn, goBtn.AbsoluteSize.X*0.5, goBtn.AbsoluteSize.Y*0.5, T.white)
            setTPStat("→ "..ci.."...", T.amber)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                    :WaitForChild("TeleportToPortal"):FireServer(ci)
            end)
            task.delay(1.5, function()
                setTPStat("Done: "..ci, T.green)
            end)
        end)
    end

    -- ════════════════════════════════
    -- PAGE: SETTINGS
    -- ════════════════════════════════
    local settingsSF = mkScrollPage(sideData["Settings"].page)

    -- Appearance
    mkSection(settingsSF, "Appearance", 1)
    mkSlider(settingsSF,"UI Scale",70,130,100,"%",function(v)
        root.Size = UDim2.new(0, root.AbsoluteSize.X*(v/100), 0, root.AbsoluteSize.Y*(v/100))
    end, 2)
    mkSlider(settingsSF,"Border Opacity",0,100,90,"%",function(v)
        rootStroke.Transparency = 1-(v/100)
    end, 3)
    mkSlider(settingsSF,"Corner Radius",6,24,16,"px",function(v)
        rootCorner.CornerRadius = UDim.new(0,v)
    end, 4)

    -- Font
    mkSection(settingsSF, "Font", 5)
    mkSlider(settingsSF,"Font Size",8,18,12,"px",function(v)
        UISettings.fontSize = v
        local function doUpdate(obj)
            for _,c in ipairs(obj:GetChildren()) do
                if (c:IsA("TextLabel") or c:IsA("TextButton"))
                    and c.TextSize >= 11 and c.TextSize <= 16 then
                    c.TextSize = v
                end
                doUpdate(c)
            end
        end
        doUpdate(contentArea)
    end, 6)

    -- Accent Color (live apply)
    mkSection(settingsSF, "Accent Color", 7)
    mkDropdownV2(settingsSF,"Accent","🎨",Color3.fromRGB(118,68,255),
        {"Purple","Blue","Cyan","Green","Red"}, "Purple", function(v)
            lib.applyAccent(v)
        end, 8)

    -- Particles
    mkSection(settingsSF, "Particles", 9)
    mkToggle(settingsSF,"Enable Particles",true,function(v)
        UISettings.particles = v
        for _,p in ipairs(particleList) do
            if p and p.Parent then p.Visible = v end
        end
    end, 10)
    mkSlider(settingsSF,"Jumlah Partikel",5,80,26,"",function(v)
        UISettings.particleCount = v
        spawnParticles(v)
    end, 11)

    -- UI Background
    mkSection(settingsSF, "UI Background", 12)
    mkDropdownV2(settingsSF,"Mode BG Window","◈",Color3.fromRGB(80,80,180),
        {"Solid","Transparent","Blur"}, "Solid", function(v)
            applyUIBgMode(v)
        end, 13)

    -- Minimize Bar Background
    mkSection(settingsSF, "Minimize Bar", 14)
    mkDropdownV2(settingsSF,"Mode BG Minimize","◉",Color3.fromRGB(60,120,200),
        {"Solid","Transparent","Blur"}, "Solid", function(v)
            applyMiniBgMode(v)
        end, 15)

    -- Effects
    mkSection(settingsSF, "Effects", 16)
    mkToggle(settingsSF,"Window Glow",true,function(v)
        UISettings.glow = v
        smooth(rootGlow, {ImageTransparency = v and 0.85 or 1}, 0.3):Play()
    end, 17)

    -- Info
    mkSection(settingsSF, "Info", 18)
    mkStatus(settingsSF, "Game",   "Sailor Piece",    19)
    mkStatus(settingsSF, "Dev",    "Bibran",           20)
    mkStatus(settingsSF, "Exec",   "Mobile / iPhone",  21)
    mkSection(settingsSF, "Keybind", 22)
    mkStatus(settingsSF, "Drag",   "Topbar",           23)
    mkStatus(settingsSF, "Resize", "Pojok kanan bawah",24)
    mkStatus(settingsSF, "Min",    "Tombol — kuning",  25)
    mkStatus(settingsSF, "Close",  "Tombol × merah",   26)

    -- ════════════════════════════════
    -- Return refs ke logic layer
    -- ════════════════════════════════
    return {
        getIsland       = getIsland,
        getFarmMode     = getFarmMode,
        getNPCFilter    = getNPCFilter,
        getHitMethod    = getHitMethod,
        getHeight       = getHeight,
        getSpeed        = getSpeed,
        getTD           = getTD,
        getLD           = getLD,
        getQR           = getQR,
        getCI           = getCI,
        setFarmStat     = setFarmStat,
        setFarmPhase    = setFarmPhase,
        setQNPC         = setQNPC,
        setQLast        = setQLast,
        setHitStat      = setHitStat,
        setFarmOnOff    = setFarmOnOff,
        getFarmOn       = getFarmOn,
        setFarmCallback = setFarmCallback,
        setQuestOnOff   = setQuestOnOff,
        getQuestOn      = getQuestOn,
        setQuestCallback= setQuestCallback,
        setHitOnOff     = setHitOnOff,
        getHitOn        = getHitOn,
        setHitCallback  = setHitCallback,
    }
end
