-- ╔══════════════════════════════════╗
-- ║  YiDaMuSake — Pages Builder      ║
-- ╚══════════════════════════════════╝
-- Dipanggil dari main.lua setelah window dibuat
-- Param: lib (ui_lib), sideData (tab pages), contentArea

local TELEPORT_LOCATIONS = {
    "Starter","Jungle","Desert","Snow",
    "Sailor","Shibuya","HollowIsland","Boss",
    "Dungeon","Shinjuku","Slime","Academy",
    "Judgement","Ninja","Lawless","Tower",
}

return function(lib, sideData, contentArea, bgF, root, rootCorner, rootStroke, rootGlow, particleList, spawnParticles, applyUIBgMode, applyMiniBgMode)
    local T            = lib.T
    local UISettings   = lib.UISettings
    local smooth       = lib.smooth
    local spring       = lib.spring
    local ease         = lib.ease
    local ripple       = lib.ripple
    local mkScrollPage = lib.mkScrollPage
    local mkGroupBox   = lib.mkGroupBox
    local mkSectionLabel = lib.mkSectionLabel
    local mkSection    = lib.mkSection
    local mkStatus     = lib.mkStatus
    local mkSlider     = lib.mkSlider
    local mkToggle     = lib.mkToggle
    local mkOnOffBtn   = lib.mkOnOffBtn
    local mkDropdownV2 = lib.mkDropdownV2
    local mkSubTabBar  = lib.mkSubTabBar

    -- ── INFO ──────────────────────────────────────────────
    local infoSF=mkScrollPage(sideData["Info"].page)
    mkSection(infoSF,"Script",1)
    mkStatus(infoSF,"Name","Yi Da Mu Sake",2)
    mkStatus(infoSF,"Ver","sailor piece  v6",3)
    mkSection(infoSF,"Farm",4)
    mkStatus(infoSF,"V1","Keliling 5 titik berurutan",5)
    mkStatus(infoSF,"V2","Diam di titik tengah pulau",6)
    mkStatus(infoSF,"Move","Jarak >100=Tween | <100=TP",7)
    mkSection(infoSF,"Quest",8)
    mkStatus(infoSF,"Cara","Fire sekali per NPC baru",9)
    mkStatus(infoSF,"NPC","QuestNPC1 — QuestNPC19",10)
    mkSection(infoSF,"Hit",11)
    mkStatus(infoSF,"Method","VirtualInputManager",12)
    mkSection(infoSF,"Teleport",13)
    mkStatus(infoSF,"Lokasi","16 lokasi tersedia",14)
    mkSection(infoSF,"UI",15)
    mkStatus(infoSF,"Resize","Drag pojok kanan bawah",16)

    -- ── MAIN PAGE ─────────────────────────────────────────
    local mainPage=sideData["Main"].page
    local mainInner=Instance.new("Frame",mainPage)
    mainInner.Size=UDim2.new(1,-8,1,-8); mainInner.Position=UDim2.new(0,4,0,4)
    mainInner.BackgroundTransparency=1; mainInner.ZIndex=3

    local subPages=mkSubTabBar(mainInner,{"Farm","Quest","Hit","TP"})

    -- FARM
    local farmSF=subPages["Farm"]
    local farmGroup1=mkGroupBox(farmSF,1)
    mkSectionLabel(farmGroup1,"Status",1)
    local _,setFarmStat  =mkStatus(farmGroup1,"Status","Idle",2)
    local _,setFarmPhase =mkStatus(farmGroup1,"Phase","--",3)
    mkSectionLabel(farmGroup1,"Pulau & Mode",4)
    local _,getIsland=mkDropdownV2(
        farmGroup1,"Pulau","⚓",Color3.fromRGB(78,46,200),
        {"Starter Island","Jungle Island","Desert Island","Snow Island","Shibuya","Hollow","Curse"},
        "Starter Island",nil,5)
    local _,getFarmMode=mkDropdownV2(
        farmGroup1,"Mode","⚙",Color3.fromRGB(50,130,200),
        {"V1 - Semua Titik","V2 - Titik Tengah"},
        "V1 - Semua Titik",nil,6)
    local farmOnOffBtn,setFarmOnOff,getFarmOn,setFarmCallback=mkOnOffBtn(farmGroup1,"Auto Farm",7)
    mkSection(farmSF,"Adjust",2)
    local _,setHeight,getHeight=mkSlider(farmSF,"Height Offset",0,50,0," studs",nil,3)
    local _,setSpeed, getSpeed =mkSlider(farmSF,"Tween Speed",20,500,150," st/s",nil,4)
    local _,setTD,    getTD    =mkSlider(farmSF,"Jeda Titik",1,10,1,"s",nil,5)
    local _,setLD,    getLD    =mkSlider(farmSF,"Loop Delay",0,10,3,"s",nil,6)

    -- QUEST
    local questSF=subPages["Quest"]
    local questGroup1=mkGroupBox(questSF,1)
    mkSectionLabel(questGroup1,"Status",1)
    local _,setQNPC =mkStatus(questGroup1,"NPC","--",2)
    local _,setQLast=mkStatus(questGroup1,"Last","--",3)
    mkSectionLabel(questGroup1,"Target & Control",4)
    local _,getNPCFilter=mkDropdownV2(
        questGroup1,"Target NPC","Q",Color3.fromRGB(45,130,210),
        {"Semua NPC","NPC Terdekat Saja"},
        "Semua NPC",nil,5)
    local questOnOffBtn,setQuestOnOff,getQuestOn,setQuestCallback=mkOnOffBtn(questGroup1,"Auto Quest",6)
    mkSection(questSF,"Adjust",2)
    local _,setQR,getQR=mkSlider(questSF,"Radius",10,200,50," st",nil,3)

    -- HIT
    local hitSF=subPages["Hit"]
    local hitGroup1=mkGroupBox(hitSF,1)
    mkSectionLabel(hitGroup1,"Status",1)
    local _,setHitStat=mkStatus(hitGroup1,"Status","Idle",2)
    mkSectionLabel(hitGroup1,"Method & Control",3)
    local _,getHitMethod=mkDropdownV2(
        hitGroup1,"Click Method","H",Color3.fromRGB(180,60,80),
        {"VIM SendMouseButtonEvent","mouse1click()","mouse1press/release","UIS InputBegan Fire"},
        "VIM SendMouseButtonEvent",nil,4)
    local hitOnOffBtn,setHitOnOff,getHitOn,setHitCallback=mkOnOffBtn(hitGroup1,"Auto Hit",5)
    mkSection(hitSF,"Adjust",2)
    local _,setCI,getCI=mkSlider(hitSF,"Interval",50,1000,100,"ms",nil,3)

    -- TELEPORT
    local tpSF=subPages["TP"]
    local tpGroup1=mkGroupBox(tpSF,1)
    mkSectionLabel(tpGroup1,"Pilih Lokasi",1)
    local _,getTPLoc=mkDropdownV2(
        tpGroup1,"Lokasi","✈",Color3.fromRGB(40,160,120),
        TELEPORT_LOCATIONS,"Starter",nil,2)
    local tpBtn=Instance.new("TextButton",tpGroup1)
    tpBtn.Size=UDim2.new(1,0,0,44); tpBtn.BackgroundColor3=Color3.fromRGB(35,155,110)
    tpBtn.Text=""; tpBtn.BorderSizePixel=0; tpBtn.LayoutOrder=3; tpBtn.ZIndex=6
    Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,10)
    Instance.new("UIGradient",tpBtn).Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(50,190,135)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(28,140,95)),
    }
    local tpStroke=Instance.new("UIStroke",tpBtn)
    tpStroke.Color=Color3.fromRGB(60,210,150); tpStroke.Thickness=1.5; tpStroke.Transparency=0.3
    local tpLbl=Instance.new("TextLabel",tpBtn)
    tpLbl.Size=UDim2.new(1,0,1,0); tpLbl.BackgroundTransparency=1
    tpLbl.Text="✈  Teleport Sekarang"; tpLbl.TextColor3=T.white
    tpLbl.Font=Enum.Font.GothamBold; tpLbl.TextSize=13; tpLbl.ZIndex=7
    mkSectionLabel(tpGroup1,"Status",4)
    local _,setTPStat=mkStatus(tpGroup1,"Status","--",5)
    tpBtn.MouseButton1Down:Connect(function() smooth(tpBtn,{Size=UDim2.new(0.97,0,0,40)},0.10):Play() end)
    tpBtn.MouseButton1Up:Connect(function() smooth(tpBtn,{Size=UDim2.new(1,0,0,44)},0.18):Play() end)
    tpBtn.MouseLeave:Connect(function() smooth(tpBtn,{Size=UDim2.new(1,0,0,44)},0.16):Play() end)
    tpBtn.MouseEnter:Connect(function() smooth(tpStroke,{Transparency=0.0},0.13):Play() end)
    tpBtn.MouseButton1Click:Connect(function()
        ripple(tpBtn,tpBtn.AbsoluteSize.X*0.5,tpBtn.AbsoluteSize.Y*0.5,T.white)
        local loc=getTPLoc()
        setTPStat("Teleporting ke "..loc.."...", T.amber)
        smooth(tpStroke,{Transparency=0.3},0.2):Play()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                :WaitForChild("TeleportToPortal"):FireServer(loc)
        end)
        task.delay(1.5, function() setTPStat("Done: "..loc, T.green) end)
    end)

    -- ── SETTINGS ──────────────────────────────────────────
    local settingsSF=mkScrollPage(sideData["Settings"].page)
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
                if (c:IsA("TextLabel") or c:IsA("TextButton")) and c.TextSize>=11 and c.TextSize<=16 then
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

    -- Return semua getter/setter yang dibutuhkan logic
    return {
        getIsland=getIsland, getFarmMode=getFarmMode,
        getNPCFilter=getNPCFilter, getHitMethod=getHitMethod,
        getHeight=getHeight, getSpeed=getSpeed,
        getTD=getTD, getLD=getLD,
        getQR=getQR, getCI=getCI,
        setFarmStat=setFarmStat, setFarmPhase=setFarmPhase,
        setQNPC=setQNPC, setQLast=setQLast,
        setHitStat=setHitStat,
        setFarmOnOff=setFarmOnOff, getFarmOn=getFarmOn, setFarmCallback=setFarmCallback,
        setQuestOnOff=setQuestOnOff, getQuestOn=getQuestOn, setQuestCallback=setQuestCallback,
        setHitOnOff=setHitOnOff, getHitOn=getHitOn, setHitCallback=setHitCallback,
    }
end
