-- ╔══════════════════════════════════╗
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
    "Shibuya","Hollow","Shinjuku Island#1","Shinjuku Island#2",
    "Slime","Academy","Judgement","Soul Dominion","Ninja","Lawless",
}
local KNOWN_BOSSES = {
    "AizenBoss","AlucardBoss","JinwooBoss","SukunaBoss","YujiBoss",
    "GojoBoss","KnightBoss","YamatoBoss","StrongestShinobiBoss",
}

-- FIX Bug#9: accept MM:SS and HH:MM:SS
local function findTimerTextLabel(container)
    for _,desc in ipairs(container:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local txt=desc.Text or ""
            if txt:match("^%d+:%d%d$") or txt:match("^%d+:%d%d:%d%d$") then return desc end
        end
    end
    return nil
end
local function parseTimerSecs(text)
    if not text then return -1 end
    local h,m,s=text:match("^(%d+):(%d+):(%d+)$")
    if h then return tonumber(h)*3600+tonumber(m)*60+tonumber(s) end
    local m2,s2=text:match("^(%d+):(%d+)$")
    if m2 then return tonumber(m2)*60+tonumber(s2) end
    return -1
end

local function makeNotifier(gui,T,TweenService)
    return function(title,subtitle,col)
        -- FIX: PlayLocalSound agar tidak perlu load wait
        pcall(function()
            local snd=Instance.new("Sound")
            snd.SoundId="rbxassetid://82845990304289"
            snd.Volume=0.65
            snd.RollOffMaxDistance=1000
            snd.Parent=game:GetService("SoundService")
            game:GetService("SoundService"):PlayLocalSound(snd)
            game:GetService("Debris"):AddItem(snd,6)
        end)
        local notif=Instance.new("Frame",gui)
        notif.Size=UDim2.new(0,290,0,60)
        notif.Position=UDim2.new(0.5,-145,0,-72)
        notif.BackgroundColor3=Color3.fromRGB(12,11,20)
        notif.BorderSizePixel=0; notif.ZIndex=600
        Instance.new("UICorner",notif).CornerRadius=UDim.new(0,12)
        local ns=Instance.new("UIStroke",notif)
        ns.Color=col or T.green; ns.Thickness=1.4; ns.Transparency=0.1
        local bar=Instance.new("Frame",notif)
        bar.Size=UDim2.new(0,3,1,-14); bar.Position=UDim2.new(0,8,0,7)
        bar.BackgroundColor3=col or T.green; bar.BorderSizePixel=0
        Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
        local tl=Instance.new("TextLabel",notif)
        tl.Size=UDim2.new(1,-28,0,22); tl.Position=UDim2.new(0,20,0,8)
        tl.BackgroundTransparency=1; tl.Text=title
        tl.TextColor3=T.white; tl.Font=Enum.Font.GothamBold
        tl.TextSize=13; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=601
        local sl=Instance.new("TextLabel",notif)
        sl.Size=UDim2.new(1,-28,0,14); sl.Position=UDim2.new(0,20,0,34)
        sl.BackgroundTransparency=1; sl.Text=subtitle or ""
        sl.TextColor3=T.textSub; sl.Font=Enum.Font.Gotham
        sl.TextSize=10; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=601
        TweenService:Create(notif,TweenInfo.new(0.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Position=UDim2.new(0.5,-145,0,12)}):Play()
        task.delay(4.5,function()
            if notif and notif.Parent then
                TweenService:Create(notif,TweenInfo.new(0.28,Enum.EasingStyle.Quint),
                    {Position=UDim2.new(0.5,-145,0,-72)}):Play()
                task.wait(0.32); pcall(function() notif:Destroy() end)
            end
        end)
    end
end

return function(lib,sideData,contentArea,bgF,root,rootCorner,rootStroke,rootGlow,particleList,spawnParticles,applyUIBgMode,applyMiniBgMode,gui)
    local T=lib.T; local UISettings=lib.UISettings
    local smooth=lib.smooth; local ripple=lib.ripple
    local TweenService=game:GetService("TweenService")
    local mkScrollPage=lib.mkScrollPage; local mkTwoColLayout=lib.mkTwoColLayout
    local mkGroupBox=lib.mkGroupBox; local mkSectionLabel=lib.mkSectionLabel
    local mkSection=lib.mkSection; local mkStatus=lib.mkStatus
    local mkSlider=lib.mkSlider; local mkToggle=lib.mkToggle
    local mkOnOffBtn=lib.mkOnOffBtn; local mkDropdownV2=lib.mkDropdownV2
    local mkSubTabBar=lib.mkSubTabBar
    local showNotif=makeNotifier(gui,T,TweenService)

    -- INFO PAGE
    local infoSF=mkScrollPage(sideData["Info"].page)
    mkSection(infoSF,"Boss Countdown",1)
    local irBtn=Instance.new("TextButton",infoSF)
    irBtn.Size=UDim2.new(1,0,0,30); irBtn.BackgroundColor3=Color3.fromRGB(20,18,34)
    irBtn.Text="Refresh Timer"; irBtn.TextColor3=T.textSub; irBtn.Font=Enum.Font.GothamBold
    irBtn.TextSize=11; irBtn.BorderSizePixel=0; irBtn.LayoutOrder=2; irBtn.ZIndex=6
    Instance.new("UICorner",irBtn).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",irBtn).Color=T.borderBright
    local timerContainer=Instance.new("Frame",infoSF)
    timerContainer.BackgroundTransparency=1; timerContainer.Size=UDim2.new(1,0,0,0)
    timerContainer.AutomaticSize=Enum.AutomaticSize.Y; timerContainer.BorderSizePixel=0; timerContainer.LayoutOrder=3
    local tcL=Instance.new("UIListLayout",timerContainer); tcL.Padding=UDim.new(0,5); tcL.SortOrder=Enum.SortOrder.LayoutOrder
    local timerEntries={}
    local function buildTimerCards()
        for _,c in ipairs(timerContainer:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        timerEntries={}; local found=0
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
                local abar=Instance.new("Frame",card); abar.Size=UDim2.new(0,3,1,-14); abar.Position=UDim2.new(0,8,0,7)
                abar.BackgroundColor3=T.accentDim; abar.BorderSizePixel=0; Instance.new("UICorner",abar).CornerRadius=UDim.new(1,0)
                local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(0.55,0,0,20); nameL.Position=UDim2.new(0,18,0,7)
                nameL.BackgroundTransparency=1; nameL.Text=bossName; nameL.TextColor3=T.text
                nameL.Font=Enum.Font.GothamBold; nameL.TextSize=12; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
                local dispTimer=Instance.new("TextLabel",card); dispTimer.Size=UDim2.new(0.45,-18,0,20); dispTimer.Position=UDim2.new(0.55,0,0,7)
                dispTimer.BackgroundTransparency=1; dispTimer.Text=timerLbl and timerLbl.Text or "..."
                dispTimer.TextColor3=T.accentGlow; dispTimer.Font=Enum.Font.GothamBold; dispTimer.TextSize=13
                dispTimer.TextXAlignment=Enum.TextXAlignment.Right; dispTimer.ZIndex=6
                local dispStatus=Instance.new("TextLabel",card); dispStatus.Size=UDim2.new(1,-24,0,12); dispStatus.Position=UDim2.new(0,18,0,30)
                dispStatus.BackgroundTransparency=1; dispStatus.Text=timerLbl and "Timer aktif" or "Belum ditemukan"
                dispStatus.TextColor3=timerLbl and T.textDim or T.amber; dispStatus.Font=Enum.Font.Gotham
                dispStatus.TextSize=9; dispStatus.TextXAlignment=Enum.TextXAlignment.Left; dispStatus.ZIndex=6
                table.insert(timerEntries,{container=child,bossName=bossName,timerLbl=timerLbl,
                    dispTimer=dispTimer,dispStatus=dispStatus,cardStroke=cs,accentBar=abar,prevSecs=-1})
            end
        end
        if found==0 then
            local el=Instance.new("TextLabel",timerContainer); el.Size=UDim2.new(1,0,0,30)
            el.BackgroundTransparency=1; el.Text="Tidak ada TimedBossSpawn di workspace"
            el.TextColor3=T.textDim; el.Font=Enum.Font.Gotham; el.TextSize=10; el.LayoutOrder=1
        end
    end
    buildTimerCards()
    irBtn.MouseButton1Click:Connect(function() ripple(irBtn,irBtn.AbsoluteSize.X*0.5,irBtn.AbsoluteSize.Y*0.5,T.accent); buildTimerCards() end)
    task.spawn(function()
        while infoSF and infoSF.Parent do
            for _,e in ipairs(timerEntries) do pcall(function()
                if not e.timerLbl or not e.timerLbl.Parent then
                    local f=findTimerTextLabel(e.container)
                    if f then e.timerLbl=f; e.dispStatus.Text="Timer OK"; e.dispStatus.TextColor3=T.green
                    else e.dispTimer.Text="?"; e.dispStatus.Text="Belum ada timer"; e.dispStatus.TextColor3=T.amber; return end
                end
                local txt=e.timerLbl.Text or ""; e.dispTimer.Text=(txt~="" and txt or "?")
                local secs=parseTimerSecs(txt)
                if secs==0 and e.prevSecs>0 then showNotif(e.bossName.." spawned!","Boss telah muncul!",T.green) end
                e.prevSecs=secs
                if secs<0 then e.dispTimer.TextColor3=T.textDim; e.dispStatus.Text="Format: "..txt
                    smooth(e.cardStroke,{Color=T.border},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.textDim},0.3):Play()
                elseif secs==0 then e.dispTimer.TextColor3=T.green; e.dispStatus.Text="Spawn sekarang!"
                    smooth(e.cardStroke,{Color=T.green},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.green},0.3):Play()
                elseif secs<60 then e.dispTimer.TextColor3=T.amber; e.dispStatus.Text="Segera spawn!"
                    smooth(e.cardStroke,{Color=T.amber},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.amber},0.3):Play()
                else e.dispTimer.TextColor3=T.accentGlow; e.dispStatus.Text="Menunggu..."
                    smooth(e.cardStroke,{Color=T.border},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.accentDim},0.3):Play()
                end
            end) end
            task.wait(1)
        end
    end)

    -- MAIN PAGE
    local mainPage=sideData["Main"].page
    local mainInner=Instance.new("Frame",mainPage)
    mainInner.Size=UDim2.new(1,-8,1,-8); mainInner.Position=UDim2.new(0,4,0,4)
    mainInner.BackgroundTransparency=1; mainInner.ZIndex=3
    local subPages=mkSubTabBar(mainInner,{"Farm","TP","Boss","Dungeon"})

    -- FARM
    local leftF,rightF=mkTwoColLayout(subPages["Farm"],T.border)
    local farmGroup=mkGroupBox(leftF,1); mkSectionLabel(farmGroup,"Pulau & Mode",1)
    local _,getIsland=mkDropdownV2(farmGroup,"Pulau","*",Color3.fromRGB(78,46,200),FARM_ISLANDS,"Starter Island",nil,2)
    local _,getFarmMode=mkDropdownV2(farmGroup,"Mode","o",Color3.fromRGB(50,130,200),{"V1 - Semua Titik","V2 - Titik Tengah"},"V1 - Semua Titik",nil,3)
    local farmOnOffBtn,setFarmOnOff,getFarmOn,setFarmCallback=mkOnOffBtn(farmGroup,"Auto Farm + Quest",4)
    local _,_,getAutoHitOn=mkToggle(farmGroup,"Kill Aura",false,nil,5)
    local modeGroup=mkGroupBox(leftF,2); mkSectionLabel(modeGroup,"Testing Mode",1)
    local _,_,getFaceDown=mkToggle(modeGroup,"Face Down",false,nil,2)
    local _,_,getSpinOn=mkToggle(modeGroup,"Auto Spin HRP",false,nil,3)
    local skillGroup=mkGroupBox(leftF,3); mkSectionLabel(skillGroup,"Auto Skill",1)
    local skillOn={Z=false,X=false,C=false,V=false}
    mkToggle(skillGroup,"Z",false,function(v) skillOn.Z=v end,2)
    mkToggle(skillGroup,"X",false,function(v) skillOn.X=v end,3)
    mkToggle(skillGroup,"C",false,function(v) skillOn.C=v end,4)
    mkToggle(skillGroup,"V",false,function(v) skillOn.V=v end,5)
    mkSection(rightF,"Adjust",1)
    local _,setHeight,getHeight=mkSlider(rightF,"Height",0,50,0," st",nil,2)
    local _,setSpeed,getSpeed=mkSlider(rightF,"Speed",20,500,150," st/s",nil,3)
    local _,setTD,getTD=mkSlider(rightF,"Jeda",1,10,1,"s",nil,4)
    local _,setLD,getLD=mkSlider(rightF,"Loop Delay",0,10,3,"s",nil,5)

    -- TP
    local tpLeftF,tpRightF=mkTwoColLayout(subPages["TP"],T.border)
    local tpStatCard=Instance.new("Frame",tpLeftF); tpStatCard.Size=UDim2.new(1,0,0,24)
    tpStatCard.BackgroundTransparency=1; tpStatCard.BorderSizePixel=0; tpStatCard.LayoutOrder=0
    local tpStatLbl=Instance.new("TextLabel",tpStatCard); tpStatLbl.Size=UDim2.new(1,0,1,0)
    tpStatLbl.BackgroundTransparency=1; tpStatLbl.Text="Pilih lokasi"; tpStatLbl.TextColor3=T.textDim
    tpStatLbl.Font=Enum.Font.Gotham; tpStatLbl.TextSize=10; tpStatLbl.TextXAlignment=Enum.TextXAlignment.Center
    local tpStatR=Instance.new("Frame",tpRightF); tpStatR.Size=UDim2.new(1,0,0,24)
    tpStatR.BackgroundTransparency=1; tpStatR.BorderSizePixel=0; tpStatR.LayoutOrder=0
    local function setTPStat(txt,col)
        tpStatLbl.Text=txt or "--"; if col then smooth(tpStatLbl,{TextColor3=col},0.15):Play() end
    end
    local function makeTpCard(parent,loc,order)
        local card=Instance.new("Frame",parent); card.Size=UDim2.new(1,0,0,40); card.BackgroundColor3=T.card
        card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5
        Instance.new("UICorner",card).CornerRadius=UDim.new(0,9)
        local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.5; cs.Thickness=0.8
        local ibar=Instance.new("Frame",card); ibar.Size=UDim2.new(0,2,0,20); ibar.Position=UDim2.new(0,6,0.5,0)
        ibar.AnchorPoint=Vector2.new(0,0.5); ibar.BackgroundColor3=T.textDim; ibar.BorderSizePixel=0
        Instance.new("UICorner",ibar).CornerRadius=UDim.new(1,0)
        local nameLbl=Instance.new("TextLabel",card); nameLbl.Size=UDim2.new(1,-54,1,0); nameLbl.Position=UDim2.new(0,14,0,0)
        nameLbl.BackgroundTransparency=1; nameLbl.Text=loc; nameLbl.TextColor3=T.text
        nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=11; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=6
        local goBtn=Instance.new("TextButton",card); goBtn.Size=UDim2.new(0,36,0,22); goBtn.Position=UDim2.new(1,-40,0.5,0)
        goBtn.AnchorPoint=Vector2.new(0,0.5); goBtn.BackgroundColor3=Color3.fromRGB(35,155,110)
        goBtn.Text="GO"; goBtn.TextColor3=T.white; goBtn.Font=Enum.Font.GothamBold; goBtn.TextSize=10
        goBtn.BorderSizePixel=0; goBtn.ZIndex=7; Instance.new("UICorner",goBtn).CornerRadius=UDim.new(0,6)
        Instance.new("UIGradient",goBtn).Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(50,188,135)),ColorSequenceKeypoint.new(1,Color3.fromRGB(28,138,92)),
        }
        card.MouseEnter:Connect(function() smooth(card,{BackgroundColor3=T.cardHover},0.1):Play(); smooth(cs,{Color=T.accentGlow,Transparency=0.15},0.1):Play(); smooth(ibar,{BackgroundColor3=T.accentGlow},0.1):Play() end)
        card.MouseLeave:Connect(function() smooth(card,{BackgroundColor3=T.card},0.1):Play(); smooth(cs,{Color=T.border,Transparency=0.5},0.1):Play(); smooth(ibar,{BackgroundColor3=T.textDim},0.1):Play() end)
        goBtn.MouseButton1Down:Connect(function() smooth(goBtn,{Size=UDim2.new(0,32,0,18)},0.07):Play() end)
        goBtn.MouseButton1Up:Connect(function() smooth(goBtn,{Size=UDim2.new(0,36,0,22)},0.12):Play() end)
        goBtn.MouseLeave:Connect(function() smooth(goBtn,{Size=UDim2.new(0,36,0,22)},0.12):Play() end)
        local ci=loc
        goBtn.MouseButton1Click:Connect(function()
            ripple(goBtn,goBtn.AbsoluteSize.X*0.5,goBtn.AbsoluteSize.Y*0.5,T.white)
            setTPStat("Teleporting to "..ci,T.amber)
            pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(ci) end)
            task.delay(1.5,function() setTPStat("Arrived: "..ci,T.green) end)
        end)
        return card
    end
    for i=1,8  do makeTpCard(tpLeftF,TELEPORT_LOCATIONS[i],i)   end
    for i=9,16 do makeTpCard(tpRightF,TELEPORT_LOCATIONS[i],i-8) end

    -- BOSS
-- BOSS
local bossLeftF,bossRightF=mkTwoColLayout(subPages["Boss"],T.border)

-- KIRI: control + status
local bossCtrlGroup=mkGroupBox(bossLeftF,1)
mkSectionLabel(bossCtrlGroup,"Control",1)

local _,setBossStat=mkStatus(bossCtrlGroup,"Status","Idle",2)
local _,setBossPhase=mkStatus(bossCtrlGroup,"Phase","--",3)

local bossOnOffBtn,setBossOnOff,getBossOn,setBossCallback=
    mkOnOffBtn(bossCtrlGroup,"Auto Kill Boss",4)

-- KANAN: pilih boss
local bossPickGroup=mkGroupBox(bossRightF,1)
mkSectionLabel(bossPickGroup,"Pilih Boss",1)

-- label info boss terpilih
local bossSelCard=Instance.new("Frame",bossPickGroup)
bossSelCard.Size=UDim2.new(1,0,0,22); bossSelCard.BackgroundTransparency=1
bossSelCard.BorderSizePixel=0; bossSelCard.LayoutOrder=2
local bossSelLbl=Instance.new("TextLabel",bossSelCard)
bossSelLbl.Size=UDim2.new(1,0,1,0); bossSelLbl.BackgroundTransparency=1
bossSelLbl.Text="Belum dipilih"; bossSelLbl.TextColor3=T.textDim
bossSelLbl.Font=Enum.Font.GothamBold; bossSelLbl.TextSize=10
bossSelLbl.TextXAlignment=Enum.TextXAlignment.Center

local selectedBoss=nil
local bossCards={}

local function setBossStatFn(txt,col)
    setBossStat(txt or "Idle",col)
end
local function setBossPhaseFn(txt,col)
    setBossPhase(txt or "--",col)
end

-- FIX Bug#2: forward declare as local
local rebuildBossCards
rebuildBossCards=function()
    for _,c in ipairs(bossCards) do pcall(function() c:Destroy() end) end
    bossCards={}
    local order=3
    for idx,bossName in ipairs(KNOWN_BOSSES) do
        local isSel=(selectedBoss==bossName)
        local card=Instance.new("Frame",bossPickGroup)
        card.Size=UDim2.new(1,0,0,34)
        card.BackgroundColor3=isSel and Color3.fromRGB(28,18,52) or Color3.fromRGB(14,13,22)
        card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5
        Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
        local cs=Instance.new("UIStroke",card)
        cs.Color=isSel and T.accentGlow or T.border
        cs.Transparency=isSel and 0.05 or 0.5; cs.Thickness=isSel and 1.4 or 0.8

        local lbar=Instance.new("Frame",card)
        lbar.Size=UDim2.new(0,2,0,16); lbar.Position=UDim2.new(0,6,0.5,0)
        lbar.AnchorPoint=Vector2.new(0,0.5)
        lbar.BackgroundColor3=isSel and T.accentGlow or T.textDim
        lbar.BorderSizePixel=0
        Instance.new("UICorner",lbar).CornerRadius=UDim.new(1,0)

        local nameL=Instance.new("TextLabel",card)
        nameL.Size=UDim2.new(1,-52,1,0); nameL.Position=UDim2.new(0,14,0,0)
        nameL.BackgroundTransparency=1; nameL.Text=bossName
        nameL.TextColor3=isSel and T.white or T.textSub
        nameL.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham
        nameL.TextSize=10; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6

        local selBtn=Instance.new("TextButton",card)
        selBtn.Size=UDim2.new(0,40,0,20); selBtn.Position=UDim2.new(1,-44,0.5,0)
        selBtn.AnchorPoint=Vector2.new(0,0.5)
        selBtn.BackgroundColor3=isSel and T.accentSoft or Color3.fromRGB(22,20,36)
        selBtn.Text=isSel and "ON" or "Set"
        selBtn.TextColor3=T.white; selBtn.Font=Enum.Font.GothamBold
        selBtn.TextSize=9; selBtn.BorderSizePixel=0; selBtn.ZIndex=7
        Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,5)

        local ci=bossName
        selBtn.MouseButton1Click:Connect(function()
            selectedBoss=ci
            bossSelLbl.Text="Target: "..ci
            smooth(bossSelLbl,{TextColor3=T.accentGlow},0.2):Play()
            ripple(selBtn,selBtn.AbsoluteSize.X*0.5,selBtn.AbsoluteSize.Y*0.5,T.accent)
            rebuildBossCards()
        end)

        table.insert(bossCards,card)
        order=order+1
    end
end
rebuildBossCards()

-- Auto refresh list boss setiap 3 detik
task.spawn(function()
    while bossPickGroup and bossPickGroup.Parent do
        task.wait(3)
        rebuildBossCards()
    end
end)

    -- DUNGEON
    local dungeonSF=mkScrollPage(subPages["Dungeon"])
    local dStatCard=Instance.new("Frame",dungeonSF); dStatCard.Size=UDim2.new(1,0,0,18)
    dStatCard.BackgroundTransparency=1; dStatCard.LayoutOrder=1; dStatCard.BorderSizePixel=0
    local dungeonStatLbl=Instance.new("TextLabel",dStatCard); dungeonStatLbl.Size=UDim2.new(1,0,1,0)
    dungeonStatLbl.BackgroundTransparency=1; dungeonStatLbl.Text="Idle"; dungeonStatLbl.TextColor3=T.textDim
    dungeonStatLbl.Font=Enum.Font.Gotham; dungeonStatLbl.TextSize=10; dungeonStatLbl.TextXAlignment=Enum.TextXAlignment.Center
    local dNPCCard=Instance.new("Frame",dungeonSF); dNPCCard.Size=UDim2.new(1,0,0,14)
    dNPCCard.BackgroundTransparency=1; dNPCCard.LayoutOrder=2; dNPCCard.BorderSizePixel=0
    local dungeonNPCLbl=Instance.new("TextLabel",dNPCCard); dungeonNPCLbl.Size=UDim2.new(1,0,1,0)
    dungeonNPCLbl.BackgroundTransparency=1; dungeonNPCLbl.Text="NPC: --"; dungeonNPCLbl.TextColor3=T.textDim
    dungeonNPCLbl.Font=Enum.Font.Gotham; dungeonNPCLbl.TextSize=9; dungeonNPCLbl.TextXAlignment=Enum.TextXAlignment.Center
    local dHitCard=Instance.new("Frame",dungeonSF); dHitCard.Size=UDim2.new(1,0,0,14)
    dHitCard.BackgroundTransparency=1; dHitCard.LayoutOrder=3; dHitCard.BorderSizePixel=0
    local dungeonHitLbl=Instance.new("TextLabel",dHitCard); dungeonHitLbl.Size=UDim2.new(1,0,1,0)
    dungeonHitLbl.BackgroundTransparency=1; dungeonHitLbl.Text="0/s"; dungeonHitLbl.TextColor3=T.textDim
    dungeonHitLbl.Font=Enum.Font.Gotham; dungeonHitLbl.TextSize=9; dungeonHitLbl.TextXAlignment=Enum.TextXAlignment.Center
    local function setDungeonStat(txt,col) dungeonStatLbl.Text=txt or "Idle"; if col then smooth(dungeonStatLbl,{TextColor3=col},0.15):Play() end end
    local function setDungeonNPC(txt,col)  dungeonNPCLbl.Text="NPC: "..(txt or "--"); if col then smooth(dungeonNPCLbl,{TextColor3=col},0.15):Play() end end
    local function setDungeonHit(txt,col)  dungeonHitLbl.Text=txt or "0/s"; if col then smooth(dungeonHitLbl,{TextColor3=col},0.15):Play() end end
    local dungeonOnOffBtn,setDungeonOnOff,getDungeonOn,setDungeonCallback=mkOnOffBtn(dungeonSF,"Auto Dungeon",4)

    -- SETTINGS
    local settingsSF=mkScrollPage(sideData["Settings"].page)
    mkSection(settingsSF,"Appearance",1)
    -- FIX Bug#4: capture base dimensions at build time, not live AbsoluteSize
    local baseW=root.AbsoluteSize.X; local baseH=root.AbsoluteSize.Y
    mkSlider(settingsSF,"UI Scale",70,130,100,"%",function(v)
        root.Size=UDim2.new(0,baseW*(v/100),0,baseH*(v/100))
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
    mkSection(settingsSF,"UI Background",12)
    mkDropdownV2(settingsSF,"Mode BG Window","o",Color3.fromRGB(80,80,180),{"Solid","Transparent","Blur"},"Solid",function(v) applyUIBgMode(v) end,13)
    mkSection(settingsSF,"Minimize Bar",14)
    mkDropdownV2(settingsSF,"Mode BG Minimize","o",Color3.fromRGB(60,120,200),{"Solid","Transparent","Blur"},"Solid",function(v) applyMiniBgMode(v) end,15)
    mkSection(settingsSF,"Effects",16)
    mkToggle(settingsSF,"Window Glow",true,function(v) UISettings.glow=v; lib.smooth(rootGlow,{ImageTransparency=v and 0.85 or 1},0.3):Play() end,17)

    return {
        getIsland=getIsland, getFarmMode=getFarmMode,
        getHeight=getHeight, getSpeed=getSpeed, getTD=getTD, getLD=getLD,
        setFarmOnOff=setFarmOnOff, getFarmOn=getFarmOn, setFarmCallback=setFarmCallback,
        getAutoHitOn=function() return getAutoHitOn() end,
        getFaceDown=function() return getFaceDown() end,
        getSpinOn=function() return getSpinOn() end,
        getSkillOn=function(k) return skillOn[k] end,
        setFarmStat=function() end, setFarmPhase=function() end, setFarmNPC=function() end,
        getSelectedBoss=function() return selectedBoss end,
        setBossStat=setBossStatFn, setBossPhase=setBossPhaseFn, setBossTarget=function() end,
        setBossOnOff=setBossOnOff, getBossOn=getBossOn, setBossCallback=setBossCallback,
        getSelectedBoss=function() return selectedBoss end,
        setDungeonStat=setDungeonStat, setDungeonNPC=setDungeonNPC, setDungeonHit=setDungeonHit,
        setDungeonOnOff=setDungeonOnOff, getDungeonOn=getDungeonOn, setDungeonCallback=setDungeonCallback,
    }
end