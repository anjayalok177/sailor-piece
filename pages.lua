-- YiDaMuSake Pages v8
local TELEPORT_LOCATIONS = {
    "Starter","Jungle","Desert","Snow","Sailor","Shibuya","HollowIsland","Boss",
    "Dungeon","Shinjuku","Slime","Academy","Judgement","Ninja","Lawless","Tower",
}
local FARM_ISLANDS = {
    "Starter Island","Jungle Island","Desert Island","Snow Island","Shibuya","Hollow",
    "Shinjuku Island#1","Shinjuku Island#2","Slime","Academy","Judgement","Soul Dominion","Ninja","Lawless",
}
local KNOWN_BOSSES = {
    "AizenBoss","AlucardBoss","JinwooBoss","SukunaBoss","YujiBoss",
    "GojoBoss","KnightBoss","YamatoBoss","StrongestShinobiBoss",
}

local function findTimerTextLabel(container)
    for _,desc in ipairs(container:GetDescendants()) do
        if desc:IsA("TextLabel") and (desc.Text or ""):match("^%d+:%d%d$") then
            return desc
        end
    end
    return nil
end
local function parseTimerSecs(text)
    local m,s=(text or ""):match("(%d+):(%d+)")
    if m and s then return tonumber(m)*60+tonumber(s) end
    return -1
end

local function makeNotifier(gui,T,TweenService)
    return function(title,subtitle,col)
        pcall(function()
            local snd=Instance.new("Sound"); snd.SoundId="rbxassetid://82845990304289"
            snd.Volume=0.65; snd.Parent=workspace; snd:Play()
            game:GetService("Debris"):AddItem(snd,6)
        end)
        local notif=Instance.new("Frame",gui)
        notif.Size=UDim2.new(0,285,0,58)
        notif.Position=UDim2.new(0.5,-142,0,-70)
        notif.BackgroundColor3=Color3.fromRGB(12,11,20)
        notif.BorderSizePixel=0; notif.ZIndex=600
        Instance.new("UICorner",notif).CornerRadius=UDim.new(0,12)
        local ns=Instance.new("UIStroke",notif)
        ns.Color=col or T.green; ns.Thickness=1.4; ns.Transparency=0.08
        local bar=Instance.new("Frame",notif)
        bar.Size=UDim2.new(0,3,1,-12); bar.Position=UDim2.new(0,8,0,6)
        bar.BackgroundColor3=col or T.green; bar.BorderSizePixel=0
        Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
        local tl=Instance.new("TextLabel",notif)
        tl.Size=UDim2.new(1,-26,0,22); tl.Position=UDim2.new(0,18,0,7)
        tl.BackgroundTransparency=1; tl.Text=title
        tl.TextColor3=T.white; tl.Font=Enum.Font.GothamBold
        tl.TextSize=13; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=601
        local sl=Instance.new("TextLabel",notif)
        sl.Size=UDim2.new(1,-26,0,14); sl.Position=UDim2.new(0,18,0,34)
        sl.BackgroundTransparency=1; sl.Text=subtitle or ""
        sl.TextColor3=T.textSub; sl.Font=Enum.Font.Gotham
        sl.TextSize=10; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=601
        TweenService:Create(notif,TweenInfo.new(0.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Position=UDim2.new(0.5,-142,0,10)}):Play()
        task.delay(4.5,function()
            if notif and notif.Parent then
                TweenService:Create(notif,TweenInfo.new(0.28,Enum.EasingStyle.Quint),
                    {Position=UDim2.new(0.5,-142,0,-70)}):Play()
                task.wait(0.32); pcall(function() notif:Destroy() end)
            end
        end)
    end
end

return function(lib,sideData,contentArea,bgF,root,rootCorner,
                rootStroke,rootGlow,particleList,spawnParticles,
                applyUIBgMode,applyMiniBgMode,gui)

    local T            = lib.T
    local UISettings   = lib.UISettings
    local smooth       = lib.smooth
    local ripple       = lib.ripple
    local TweenService = game:GetService("TweenService")

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

    local showNotif = makeNotifier(gui,T,TweenService)

    -- ══════════════════════════════
    -- INFO PAGE — Boss Countdown
    -- ══════════════════════════════
    local infoSF=mkScrollPage(sideData["Info"].page)
    mkSection(infoSF,"Boss Countdown",1)

    local irBtn=Instance.new("TextButton",infoSF)
    irBtn.Size=UDim2.new(1,0,0,30); irBtn.BackgroundColor3=Color3.fromRGB(20,18,34)
    irBtn.Text="↻  Refresh Timer"; irBtn.TextColor3=T.textSub
    irBtn.Font=Enum.Font.GothamBold; irBtn.TextSize=11; irBtn.BorderSizePixel=0
    irBtn.LayoutOrder=2; irBtn.ZIndex=6
    Instance.new("UICorner",irBtn).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",irBtn).Color=T.borderBright

    local timerContainer=Instance.new("Frame",infoSF)
    timerContainer.BackgroundTransparency=1; timerContainer.Size=UDim2.new(1,0,0,0)
    timerContainer.AutomaticSize=Enum.AutomaticSize.Y; timerContainer.BorderSizePixel=0
    timerContainer.LayoutOrder=3
    local tcL=Instance.new("UIListLayout",timerContainer)
    tcL.Padding=UDim.new(0,5); tcL.SortOrder=Enum.SortOrder.LayoutOrder

    local timerEntries={}
    local function buildTimerCards()
        for _,c in ipairs(timerContainer:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        timerEntries={}
        local found=0
        for _,child in ipairs(workspace:GetChildren()) do
            local bossName=child.Name:match("^TimedBossSpawn_(.+)_Container$")
            if bossName then
                found=found+1
                local timerLbl=findTimerTextLabel(child)
                local card=Instance.new("Frame",timerContainer)
                card.Size=UDim2.new(1,0,0,50); card.BackgroundColor3=Color3.fromRGB(14,13,22)
                card.BorderSizePixel=0; card.LayoutOrder=found; card.ZIndex=5
                Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
                local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.25; cs.Thickness=0.8
                local abar=Instance.new("Frame",card)
                abar.Size=UDim2.new(0,3,1,-12); abar.Position=UDim2.new(0,8,0,6)
                abar.BackgroundColor3=T.accentDim; abar.BorderSizePixel=0
                Instance.new("UICorner",abar).CornerRadius=UDim.new(1,0)
                local nameL=Instance.new("TextLabel",card)
                nameL.Size=UDim2.new(0.55,0,0,20); nameL.Position=UDim2.new(0,18,0,7)
                nameL.BackgroundTransparency=1; nameL.Text=bossName
                nameL.TextColor3=T.text; nameL.Font=Enum.Font.GothamBold
                nameL.TextSize=12; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
                local dispTimer=Instance.new("TextLabel",card)
                dispTimer.Size=UDim2.new(0.45,-18,0,20); dispTimer.Position=UDim2.new(0.55,0,0,7)
                dispTimer.BackgroundTransparency=1; dispTimer.Text=timerLbl and timerLbl.Text or "..."
                dispTimer.TextColor3=T.accentGlow; dispTimer.Font=Enum.Font.GothamBold
                dispTimer.TextSize=13; dispTimer.TextXAlignment=Enum.TextXAlignment.Right; dispTimer.ZIndex=6
                local dispStatus=Instance.new("TextLabel",card)
                dispStatus.Size=UDim2.new(1,-24,0,12); dispStatus.Position=UDim2.new(0,18,0,30)
                dispStatus.BackgroundTransparency=1
                dispStatus.Text=timerLbl and "Timer aktif" or "Belum ditemukan"
                dispStatus.TextColor3=timerLbl and T.textDim or T.amber
                dispStatus.Font=Enum.Font.Gotham; dispStatus.TextSize=9
                dispStatus.TextXAlignment=Enum.TextXAlignment.Left; dispStatus.ZIndex=6
                table.insert(timerEntries,{
                    container=child, bossName=bossName,
                    timerLbl=timerLbl, dispTimer=dispTimer,
                    dispStatus=dispStatus, cardStroke=cs, accentBar=abar,
                    prevSecs=-1,
                })
            end
        end
        if found==0 then
            local el=Instance.new("TextLabel",timerContainer)
            el.Size=UDim2.new(1,0,0,30); el.BackgroundTransparency=1
            el.Text="Tidak ada TimedBossSpawn di workspace"
            el.TextColor3=T.textDim; el.Font=Enum.Font.Gotham; el.TextSize=10; el.LayoutOrder=1
        end
    end
    buildTimerCards()
    irBtn.MouseButton1Click:Connect(function()
        ripple(irBtn,irBtn.AbsoluteSize.X*0.5,irBtn.AbsoluteSize.Y*0.5,T.accent)
        buildTimerCards()
    end)
    task.spawn(function()
        while infoSF and infoSF.Parent do
            for _,e in ipairs(timerEntries) do
                pcall(function()
                    if not e.timerLbl or not e.timerLbl.Parent then
                        local f=findTimerTextLabel(e.container)
                        if f then e.timerLbl=f; e.dispStatus.Text="Timer OK"; e.dispStatus.TextColor3=T.green
                        else e.dispTimer.Text="?"; e.dispStatus.Text="Belum ada timer"; e.dispStatus.TextColor3=T.amber; return end
                    end
                    local txt=e.timerLbl.Text or ""
                    e.dispTimer.Text=(txt~="" and txt or "?")
                    local secs=parseTimerSecs(txt)
                    if secs==0 and e.prevSecs>0 then
                        showNotif(e.bossName.." has spawn!!","Boss telah muncul!",T.green)
                    end
                    e.prevSecs=secs
                    if secs<0 then
                        e.dispTimer.TextColor3=T.textDim; e.dispStatus.Text="Format: "..txt
                        smooth(e.cardStroke,{Color=T.border},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.textDim},0.3):Play()
                    elseif secs==0 then
                        e.dispTimer.TextColor3=T.green; e.dispStatus.Text="⚡ Spawn sekarang!"
                        smooth(e.cardStroke,{Color=T.green},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.green},0.3):Play()
                    elseif secs<60 then
                        e.dispTimer.TextColor3=T.amber; e.dispStatus.Text="⚠ Segera spawn!"
                        smooth(e.cardStroke,{Color=T.amber},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.amber},0.3):Play()
                    else
                        e.dispTimer.TextColor3=T.accentGlow; e.dispStatus.Text="Menunggu..."
                        smooth(e.cardStroke,{Color=T.border},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.accentDim},0.3):Play()
                    end
                end)
            end
            task.wait(1)
        end
    end)

    -- ══════════════════════════════
    -- MAIN PAGE — 4 sub-tabs
    -- ══════════════════════════════
    local mainPage=sideData["Main"].page
    local mainInner=Instance.new("Frame",mainPage)
    mainInner.Size=UDim2.new(1,-8,1,-8); mainInner.Position=UDim2.new(0,4,0,4)
    mainInner.BackgroundTransparency=1; mainInner.ZIndex=3

    -- subPages[name] = plain Frame
    local subPages=mkSubTabBar(mainInner,{"Farm","TP","Boss","Dungeon"})

    -- ══════════════════════════════
    -- FARM — Dua kolom (1 SF + 2 plain Frame)
    -- ══════════════════════════════
    local leftF,rightF=mkTwoColLayout(subPages["Farm"])

    -- Kiri: kontrol
    local farmGroup=mkGroupBox(leftF,1)
    mkSectionLabel(farmGroup,"Pulau & Mode",1)
    local _,getIsland=mkDropdownV2(farmGroup,"Pulau","⚓",Color3.fromRGB(78,46,200),FARM_ISLANDS,"Starter Island",nil,2)
    local _,getFarmMode=mkDropdownV2(farmGroup,"Mode","⚙",Color3.fromRGB(50,130,200),
        {"V1 - Semua Titik","V2 - Titik Tengah"},"V1 - Semua Titik",nil,3)
    local _,setFarmOnOff,getFarmOn,setFarmCallback=mkOnOffBtn(farmGroup,"Auto Farm + Quest",4)
    local _,_,getAutoHitOn=mkToggle(farmGroup,"Auto Hit (RequestHit)",false,nil,5)

    local modeGroup=mkGroupBox(leftF,2)
    mkSectionLabel(modeGroup,"Testing Mode",1)
    local _,_,getFaceDown=mkToggle(modeGroup,"Face Down (menghadap bawah)",false,nil,2)
    local _,_,getSpinOn  =mkToggle(modeGroup,"Auto Spin HRP (360°)",false,nil,3)

    local skillGroup=mkGroupBox(leftF,3)
    mkSectionLabel(skillGroup,"Auto Skill",1)
    local skillOn={Z=false,X=false,C=false,V=false}
    mkToggle(skillGroup,"Z  (arg 1)",false,function(v) skillOn.Z=v end,2)
    mkToggle(skillGroup,"X  (arg 2)",false,function(v) skillOn.X=v end,3)
    mkToggle(skillGroup,"C  (arg 3)",false,function(v) skillOn.C=v end,4)
    mkToggle(skillGroup,"V  (arg 4)",false,function(v) skillOn.V=v end,5)

    -- Kanan: adjust
    mkSection(rightF,"Adjust",1)
    local _,_,getHeight=mkSlider(rightF,"Height",0,50,0," st",nil,2)
    local _,_,getSpeed =mkSlider(rightF,"Speed",20,500,150," st/s",nil,3)
    local _,_,getTD    =mkSlider(rightF,"Jeda",1,10,1,"s",nil,4)
    local _,_,getLD    =mkSlider(rightF,"Loop Delay",0,10,3,"s",nil,5)

    -- ══════════════════════════════
    -- TP — 8 kiri / 8 kanan
    -- ══════════════════════════════
    local tpLeft,tpRight=mkTwoColLayout(subPages["TP"])
    local tpStatCard=Instance.new("Frame",tpLeft)
    tpStatCard.Size=UDim2.new(1,0,0,22); tpStatCard.BackgroundTransparency=1; tpStatCard.LayoutOrder=0
    local tpStatLbl=Instance.new("TextLabel",tpStatCard)
    tpStatLbl.Size=UDim2.new(1,0,1,0); tpStatLbl.BackgroundTransparency=1
    tpStatLbl.Text="Pilih lokasi"; tpStatLbl.TextColor3=T.textDim
    tpStatLbl.Font=Enum.Font.Gotham; tpStatLbl.TextSize=10; tpStatLbl.TextXAlignment=Enum.TextXAlignment.Center
    -- spacer kanan
    local tpRSpace=Instance.new("Frame",tpRight)
    tpRSpace.Size=UDim2.new(1,0,0,22); tpRSpace.BackgroundTransparency=1; tpRSpace.LayoutOrder=0

    local function setTPStat(txt,col)
        tpStatLbl.Text=txt or "--"
        if col then smooth(tpStatLbl,{TextColor3=col},0.15):Play() end
    end

    local function makeTpCard(parent,loc,order)
        local card=Instance.new("Frame",parent)
        card.Size=UDim2.new(1,0,0,40); card.BackgroundColor3=T.card
        card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5
        Instance.new("UICorner",card).CornerRadius=UDim.new(0,9)
        local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.5; cs.Thickness=0.8
        local ibar=Instance.new("Frame",card)
        ibar.Size=UDim2.new(0,2,0,18); ibar.Position=UDim2.new(0,6,0.5,0)
        ibar.AnchorPoint=Vector2.new(0,0.5); ibar.BackgroundColor3=T.textDim; ibar.BorderSizePixel=0
        Instance.new("UICorner",ibar).CornerRadius=UDim.new(1,0)
        local nameLbl=Instance.new("TextLabel",card)
        nameLbl.Size=UDim2.new(1,-54,1,0); nameLbl.Position=UDim2.new(0,14,0,0)
        nameLbl.BackgroundTransparency=1; nameLbl.Text=loc
        nameLbl.TextColor3=T.text; nameLbl.Font=Enum.Font.GothamBold
        nameLbl.TextSize=11; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=6
        local goBtn=Instance.new("TextButton",card)
        goBtn.Size=UDim2.new(0,36,0,22); goBtn.Position=UDim2.new(1,-40,0.5,0)
        goBtn.AnchorPoint=Vector2.new(0,0.5); goBtn.BackgroundColor3=Color3.fromRGB(35,155,110)
        goBtn.Text="GO"; goBtn.TextColor3=T.white; goBtn.Font=Enum.Font.GothamBold
        goBtn.TextSize=10; goBtn.BorderSizePixel=0; goBtn.ZIndex=7
        Instance.new("UICorner",goBtn).CornerRadius=UDim.new(0,6)
        Instance.new("UIGradient",goBtn).Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(50,188,135)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(28,138,92)),
        }
        card.MouseEnter:Connect(function()
            smooth(card,{BackgroundColor3=T.cardHover},0.1):Play()
            smooth(cs,{Color=T.accentGlow,Transparency=0.15},0.1):Play()
            smooth(ibar,{BackgroundColor3=T.accentGlow},0.1):Play()
        end)
        card.MouseLeave:Connect(function()
            smooth(card,{BackgroundColor3=T.card},0.1):Play()
            smooth(cs,{Color=T.border,Transparency=0.5},0.1):Play()
            smooth(ibar,{BackgroundColor3=T.textDim},0.1):Play()
        end)
        goBtn.MouseButton1Down:Connect(function() smooth(goBtn,{Size=UDim2.new(0,32,0,18)},0.07):Play() end)
        goBtn.MouseButton1Up:Connect(function()   smooth(goBtn,{Size=UDim2.new(0,36,0,22)},0.12):Play() end)
        goBtn.MouseLeave:Connect(function()       smooth(goBtn,{Size=UDim2.new(0,36,0,22)},0.12):Play() end)
        local ci=loc
        goBtn.MouseButton1Click:Connect(function()
            ripple(goBtn,goBtn.AbsoluteSize.X*0.5,goBtn.AbsoluteSize.Y*0.5,T.white)
            setTPStat("→ "..ci.."...",T.amber)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                    :WaitForChild("TeleportToPortal"):FireServer(ci)
            end)
            task.delay(1.5,function() setTPStat("Done: "..ci,T.green) end)
        end)
        return card
    end
    for i=1,8  do makeTpCard(tpLeft,  TELEPORT_LOCATIONS[i],   i) end
    for i=9,16 do makeTpCard(tpRight, TELEPORT_LOCATIONS[i], i-8) end

    -- ══════════════════════════════
    -- BOSS — 5 kiri / 4 kanan
    -- FIX: rebuildBossCards sebagai local forward declaration
    -- ══════════════════════════════
    local bossLeft,bossRight=mkTwoColLayout(subPages["Boss"])

    local bossCtrlGroup=mkGroupBox(bossLeft,1)
    mkSectionLabel(bossCtrlGroup,"Control",1)

    local bossStatLbl=Instance.new("TextLabel",bossCtrlGroup)
    bossStatLbl.Size=UDim2.new(1,0,0,16); bossStatLbl.BackgroundTransparency=1; bossStatLbl.LayoutOrder=2
    bossStatLbl.Text="Idle"; bossStatLbl.TextColor3=T.textDim
    bossStatLbl.Font=Enum.Font.Gotham; bossStatLbl.TextSize=10; bossStatLbl.TextXAlignment=Enum.TextXAlignment.Center

    local bossPhaseLbl=Instance.new("TextLabel",bossCtrlGroup)
    bossPhaseLbl.Size=UDim2.new(1,0,0,13); bossPhaseLbl.BackgroundTransparency=1; bossPhaseLbl.LayoutOrder=3
    bossPhaseLbl.Text="--"; bossPhaseLbl.TextColor3=T.textDim
    bossPhaseLbl.Font=Enum.Font.GothamBold; bossPhaseLbl.TextSize=9; bossPhaseLbl.TextXAlignment=Enum.TextXAlignment.Center

    local function setBossStat(txt,col)
        bossStatLbl.Text=txt or "Idle"
        if col then smooth(bossStatLbl,{TextColor3=col},0.15):Play() end
    end
    local function setBossPhase(txt,col)
        bossPhaseLbl.Text=txt or "--"
        if col then smooth(bossPhaseLbl,{TextColor3=col},0.15):Play() end
    end

    local _,setBossOnOff,getBossOn,setBossCallback=mkOnOffBtn(bossCtrlGroup,"Auto Kill Boss",4)

    local bossListLeft=mkGroupBox(bossLeft,2)
    mkSectionLabel(bossListLeft,"Pilih Boss",1)

    local bossListRight=mkGroupBox(bossRight,1)
    mkSectionLabel(bossListRight,"—",1)

    local selectedBoss=nil
    local bossCards={}

    -- FIX: forward declaration agar bisa dipanggil dari dalam dirinya sendiri
    local rebuildBossCards
    rebuildBossCards = function()
        for _,c in ipairs(bossCards) do pcall(function() c:Destroy() end) end
        bossCards={}
        for idx,bossName in ipairs(KNOWN_BOSSES) do
            local isSel=(selectedBoss==bossName)
            local parent = idx<=5 and bossListLeft or bossListRight
            local order  = idx<=5 and (idx+1) or (idx-4)
            local card=Instance.new("Frame",parent)
            card.Size=UDim2.new(1,0,0,36)
            card.BackgroundColor3=isSel and Color3.fromRGB(32,22,58) or Color3.fromRGB(14,13,22)
            card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5
            Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
            local cs=Instance.new("UIStroke",card)
            cs.Color=isSel and T.accentGlow or T.border
            cs.Transparency=isSel and 0.1 or 0.5; cs.Thickness=isSel and 1.2 or 0.8
            local lbar=Instance.new("Frame",card)
            lbar.Size=UDim2.new(0,2,0,18); lbar.Position=UDim2.new(0,6,0.5,0)
            lbar.AnchorPoint=Vector2.new(0,0.5)
            lbar.BackgroundColor3=isSel and T.accentGlow or T.textDim; lbar.BorderSizePixel=0
            Instance.new("UICorner",lbar).CornerRadius=UDim.new(1,0)
            local nameL=Instance.new("TextLabel",card)
            nameL.Size=UDim2.new(1,-58,1,0); nameL.Position=UDim2.new(0,14,0,0)
            nameL.BackgroundTransparency=1; nameL.Text=bossName
            nameL.TextColor3=isSel and T.white or T.textSub
            nameL.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham
            nameL.TextSize=10; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
            local selBtn=Instance.new("TextButton",card)
            selBtn.Size=UDim2.new(0,44,0,22); selBtn.Position=UDim2.new(1,-48,0.5,0)
            selBtn.AnchorPoint=Vector2.new(0,0.5)
            selBtn.BackgroundColor3=isSel and T.accentSoft or Color3.fromRGB(24,22,38)
            selBtn.Text=isSel and "✓" or "Pilih"; selBtn.TextColor3=T.white
            selBtn.Font=Enum.Font.GothamBold; selBtn.TextSize=9
            selBtn.BorderSizePixel=0; selBtn.ZIndex=7
            Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,6)
            local ci=bossName
            selBtn.MouseButton1Click:Connect(function()
                selectedBoss=ci
                ripple(selBtn,selBtn.AbsoluteSize.X*0.5,selBtn.AbsoluteSize.Y*0.5,T.accent)
                rebuildBossCards()
            end)
            table.insert(bossCards,card)
        end
    end
    rebuildBossCards()

    -- ══════════════════════════════
    -- DUNGEON — kolom tunggal
    -- ══════════════════════════════
    local dungeonSF=mkScrollPage(subPages["Dungeon"])

    local function mkCompactStat(parent,order,defaultText)
        local f=Instance.new("Frame",parent)
        f.Size=UDim2.new(1,0,0,16); f.BackgroundTransparency=1; f.LayoutOrder=order
        local l=Instance.new("TextLabel",f)
        l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Text=defaultText
        l.TextColor3=T.textDim; l.Font=Enum.Font.Gotham; l.TextSize=10
        l.TextXAlignment=Enum.TextXAlignment.Center
        return l
    end
    local dungeonStatLbl=mkCompactStat(dungeonSF,1,"Idle")
    local dungeonNPCLbl =mkCompactStat(dungeonSF,2,"NPC: --")
    local dungeonHitLbl =mkCompactStat(dungeonSF,3,"0/s")
    local function setDungeonStat(t,c) dungeonStatLbl.Text=t or "Idle"; if c then smooth(dungeonStatLbl,{TextColor3=c},0.15):Play() end end
    local function setDungeonNPC(t,c)  dungeonNPCLbl.Text="NPC: "..(t or "--"); if c then smooth(dungeonNPCLbl,{TextColor3=c},0.15):Play() end end
    local function setDungeonHit(t,c)  dungeonHitLbl.Text=t or "0/s"; if c then smooth(dungeonHitLbl,{TextColor3=c},0.15):Play() end end
    local _,setDungeonOnOff,getDungeonOn,setDungeonCallback=mkOnOffBtn(dungeonSF,"Auto Dungeon",4)

    -- ══════════════════════════════
    -- SETTINGS
    -- ══════════════════════════════
    local settingsSF=mkScrollPage(sideData["Settings"].page)
    mkSection(settingsSF,"Appearance",1)
    mkSlider(settingsSF,"UI Scale",70,130,100,"%",function(v)
        root.Size=UDim2.new(0,root.AbsoluteSize.X*(v/100),0,root.AbsoluteSize.Y*(v/100))
    end,2)
    mkSlider(settingsSF,"Border Opacity",0,100,90,"%",function(v)
        rootStroke.Transparency=1-(v/100)
    end,3)
    mkSlider(settingsSF,"Corner Radius",6,24,14,"px",function(v)
        rootCorner.CornerRadius=UDim.new(0,v)
    end,4)
    mkSection(settingsSF,"Font",5)
    mkSlider(settingsSF,"Font Size",8,18,12,"px",function(v) lib.applyFontSize(v) end,6)
    mkSection(settingsSF,"Accent Color",7)
    mkDropdownV2(settingsSF,"Accent","🎨",Color3.fromRGB(118,68,255),
        {"Purple","Blue","Cyan","Green","Red"},"Purple",function(v) lib.applyAccent(v) end,8)
    mkSection(settingsSF,"Particles",9)
    mkToggle(settingsSF,"Enable Particles",true,function(v)
        UISettings.particles=v
        for _,p in ipairs(particleList) do if p and p.Parent then p.Visible=v end end
    end,10)
    mkSlider(settingsSF,"Jumlah Partikel",5,80,26,"",function(v)
        UISettings.particleCount=v; spawnParticles(v)
    end,11)
    mkSection(settingsSF,"UI Background",12)
    mkDropdownV2(settingsSF,"Mode BG Window","◈",Color3.fromRGB(80,80,180),
        {"Solid","Transparent","Blur"},"Solid",function(v) applyUIBgMode(v) end,13)
    mkSection(settingsSF,"Minimize Bar",14)
    mkDropdownV2(settingsSF,"Mode BG Minimize","◉",Color3.fromRGB(60,120,200),
        {"Solid","Transparent","Blur"},"Solid",function(v) applyMiniBgMode(v) end,15)
    mkSection(settingsSF,"Effects",16)
    mkToggle(settingsSF,"Window Glow",true,function(v)
        UISettings.glow=v
        lib.smooth(rootGlow,{ImageTransparency=v and 0.85 or 1},0.3):Play()
    end,17)

    -- ══════════════════════════════
    -- RETURN REFS (tidak ada duplicate key)
    -- ══════════════════════════════
    return {
        getIsland=getIsland, getFarmMode=getFarmMode,
        getHeight=getHeight, getSpeed=getSpeed, getTD=getTD, getLD=getLD,
        setFarmOnOff=setFarmOnOff, getFarmOn=getFarmOn, setFarmCallback=setFarmCallback,
        getAutoHitOn=function() return getAutoHitOn() end,
        getFaceDown  =function() return getFaceDown() end,
        getSpinOn    =function() return getSpinOn() end,
        getSkillOn   =function(k) return skillOn[k] end,
        setFarmStat  =function() end,
        setFarmPhase =function() end,
        setFarmNPC   =function() end,
        getSelectedBoss=function() return selectedBoss end,
        setBossStat=setBossStat, setBossPhase=setBossPhase,
        setBossTarget=function() end,
        setBossOnOff=setBossOnOff, getBossOn=getBossOn, setBossCallback=setBossCallback,
        setDungeonStat=setDungeonStat, setDungeonNPC=setDungeonNPC, setDungeonHit=setDungeonHit,
        setDungeonOnOff=setDungeonOnOff, getDungeonOn=getDungeonOn, setDungeonCallback=setDungeonCallback,
    }
end
