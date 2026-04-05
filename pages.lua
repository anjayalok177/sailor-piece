-- ╔══════════════════════════════════╗
-- ║  YiDaMuSake — Pages Builder  v7 ║
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

local BOSS_EXCLUSIONS = {
    DesertBoss=true, MonkeyBoss=true,
    PandaMiniBoss=true, SnowBoss=true,
}

local function detectBosses()
    local list={}
    local npcs=workspace:FindFirstChild("NPCs"); if not npcs then return list end
    for _,child in ipairs(npcs:GetChildren()) do
        if child.Name:find("Boss",1,true) and not BOSS_EXCLUSIONS[child.Name] then
            table.insert(list,child.Name)
        end
    end
    return list
end

-- FIX: Scan semua TextLabel descendant di container
-- Cari yang textnya format "M:SS" (waktu countdown)
local function findTimerTextLabel(container)
    for _,desc in ipairs(container:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local txt = desc.Text or ""
            -- match format "1:23" atau "12:34"
            if txt:match("^%d+:%d%d$") then
                return desc
            end
        end
    end
    return nil
end

local function parseTimerSecs(text)
    if not text or text=="" then return -1 end
    local m,s=text:match("(%d+):(%d+)")
    if m and s then return tonumber(m)*60+tonumber(s) end
    return -1
end

return function(lib, sideData, contentArea, bgF, root, rootCorner,
                rootStroke, rootGlow, particleList, spawnParticles,
                applyUIBgMode, applyMiniBgMode)

    local T              = lib.T
    local UISettings     = lib.UISettings
    local smooth         = lib.smooth
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
    local infoSF=mkScrollPage(sideData["Info"].page)
    mkSection(infoSF,"Boss Countdown",1)

    local infoRefreshBtn=Instance.new("TextButton",infoSF)
    infoRefreshBtn.Size=UDim2.new(1,0,0,32)
    infoRefreshBtn.BackgroundColor3=Color3.fromRGB(24,20,40)
    infoRefreshBtn.Text="↻  Refresh Timer List"
    infoRefreshBtn.TextColor3=T.textSub; infoRefreshBtn.Font=Enum.Font.GothamBold
    infoRefreshBtn.TextSize=11; infoRefreshBtn.BorderSizePixel=0
    infoRefreshBtn.LayoutOrder=2; infoRefreshBtn.ZIndex=6
    Instance.new("UICorner",infoRefreshBtn).CornerRadius=UDim.new(0,9)
    local irS=Instance.new("UIStroke",infoRefreshBtn)
    irS.Color=T.borderBright; irS.Thickness=1.0; irS.Transparency=0.3

    local timerContainer=Instance.new("Frame",infoSF)
    timerContainer.BackgroundTransparency=1
    timerContainer.Size=UDim2.new(1,0,0,0)
    timerContainer.AutomaticSize=Enum.AutomaticSize.Y
    timerContainer.BorderSizePixel=0; timerContainer.LayoutOrder=3
    local tcL=Instance.new("UIListLayout",timerContainer)
    tcL.Padding=UDim.new(0,5); tcL.SortOrder=Enum.SortOrder.LayoutOrder

    -- {timerLbl=TextLabel ref, dispTimer=TextLabel, dispStatus=TextLabel, cardStroke=UIStroke}
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

                -- FIX: scan semua descendant TextLabel cari format "M:SS"
                local timerLbl=findTimerTextLabel(child)

                local card=Instance.new("Frame",timerContainer)
                card.Size=UDim2.new(1,0,0,54)
                card.BackgroundColor3=Color3.fromRGB(14,13,22)
                card.BorderSizePixel=0; card.LayoutOrder=found; card.ZIndex=5
                Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
                local cs=Instance.new("UIStroke",card)
                cs.Color=T.border; cs.Transparency=0.2; cs.Thickness=1.0

                local nameL=Instance.new("TextLabel",card)
                nameL.Size=UDim2.new(0.6,0,0,22); nameL.Position=UDim2.new(0,12,0,6)
                nameL.BackgroundTransparency=1; nameL.Text=bossName
                nameL.TextColor3=T.text; nameL.Font=Enum.Font.GothamBold
                nameL.TextSize=12; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6

                local dispTimer=Instance.new("TextLabel",card)
                dispTimer.Size=UDim2.new(0.4,-12,0,22); dispTimer.Position=UDim2.new(0.6,0,0,6)
                dispTimer.BackgroundTransparency=1
                dispTimer.Text=timerLbl and timerLbl.Text or "Mencari..."
                dispTimer.TextColor3=T.accentGlow; dispTimer.Font=Enum.Font.GothamBold
                dispTimer.TextSize=13; dispTimer.TextXAlignment=Enum.TextXAlignment.Right; dispTimer.ZIndex=6

                local dispStatus=Instance.new("TextLabel",card)
                dispStatus.Size=UDim2.new(1,-24,0,14); dispStatus.Position=UDim2.new(0,12,0,34)
                dispStatus.BackgroundTransparency=1
                dispStatus.Text=timerLbl and "Timer ditemukan" or "Timer TextLabel tidak ditemukan"
                dispStatus.TextColor3=timerLbl and T.textDim or T.red
                dispStatus.Font=Enum.Font.Gotham
                dispStatus.TextSize=9; dispStatus.TextXAlignment=Enum.TextXAlignment.Left; dispStatus.ZIndex=6

                table.insert(timerEntries,{
                    container=child,
                    timerLbl=timerLbl,
                    dispTimer=dispTimer,
                    dispStatus=dispStatus,
                    cardStroke=cs,
                })
            end
        end

        if found==0 then
            local el=Instance.new("TextLabel",timerContainer)
            el.Size=UDim2.new(1,0,0,34); el.BackgroundTransparency=1
            el.Text="Tidak ada TimedBossSpawn di workspace"
            el.TextColor3=T.textDim; el.Font=Enum.Font.Gotham
            el.TextSize=10; el.LayoutOrder=1; el.ZIndex=5
        end
    end
    buildTimerCards()

    infoRefreshBtn.MouseButton1Click:Connect(function()
        ripple(infoRefreshBtn,infoRefreshBtn.AbsoluteSize.X*0.5,infoRefreshBtn.AbsoluteSize.Y*0.5,T.accent)
        buildTimerCards()
    end)

    -- Live update: setiap 1 detik baca .Text langsung dari TextLabel game
    task.spawn(function()
        while infoSF and infoSF.Parent do
            for _,e in ipairs(timerEntries) do
                pcall(function()
                    -- Jika timerLbl belum ditemukan saat build, coba lagi
                    if not e.timerLbl or not e.timerLbl.Parent then
                        local found=findTimerTextLabel(e.container)
                        if found then
                            e.timerLbl=found
                            e.dispStatus.Text="Timer ditemukan"
                            e.dispStatus.TextColor3=T.textDim
                        else
                            e.dispTimer.Text="?"
                            e.dispTimer.TextColor3=T.textDim
                            e.dispStatus.Text="Belum ada timer — coba refresh"
                            e.dispStatus.TextColor3=T.red
                            return
                        end
                    end

                    local txt=e.timerLbl.Text or ""
                    e.dispTimer.Text=(txt~="" and txt or "?")

                    local secs=parseTimerSecs(txt)
                    if secs<0 then
                        e.dispTimer.TextColor3=T.textDim
                        e.dispStatus.Text="Format tidak dikenali: "..txt
                        smooth(e.cardStroke,{Color=T.border},0.3):Play()
                    elseif secs==0 then
                        e.dispTimer.TextColor3=T.green
                        e.dispStatus.Text="⚡ Boss sedang spawn!"
                        smooth(e.cardStroke,{Color=T.green},0.3):Play()
                    elseif secs<60 then
                        e.dispTimer.TextColor3=T.amber
                        e.dispStatus.Text="⚠ Segera spawn!"
                        smooth(e.cardStroke,{Color=T.amber},0.3):Play()
                    else
                        e.dispTimer.TextColor3=T.accentGlow
                        e.dispStatus.Text="Menunggu..."
                        smooth(e.cardStroke,{Color=T.border},0.3):Play()
                    end
                end)
            end
            task.wait(1)
        end
    end)

    -- ════════════════════════════════
    -- PAGE: MAIN (5 sub-tabs)
    -- ════════════════════════════════
    local mainPage=sideData["Main"].page
    local mainInner=Instance.new("Frame",mainPage)
    mainInner.Size=UDim2.new(1,-8,1,-8); mainInner.Position=UDim2.new(0,4,0,4)
    mainInner.BackgroundTransparency=1; mainInner.ZIndex=3

    local subPages=mkSubTabBar(mainInner,{"Farm","Hit","TP","Boss","Dungeon"})

    -- ── FARM ─────────────────────────────────────────────
    local farmSF=subPages["Farm"]

    local farmGroup=mkGroupBox(farmSF,1)
    mkSectionLabel(farmGroup,"Status",1)
    local _,setFarmStat  =mkStatus(farmGroup,"Status","Idle",2)
    local _,setFarmPhase =mkStatus(farmGroup,"Phase","--",3)
    local _,setFarmNPC   =mkStatus(farmGroup,"Quest","--",4)
    mkSectionLabel(farmGroup,"Pulau & Mode",5)
    local _,getIsland=mkDropdownV2(
        farmGroup,"Pulau","⚓",Color3.fromRGB(78,46,200),
        FARM_ISLANDS,"Starter Island",nil,6)
    local _,getFarmMode=mkDropdownV2(
        farmGroup,"Mode","⚙",Color3.fromRGB(50,130,200),
        {"V1 - Semua Titik","V2 - Titik Tengah"},
        "V1 - Semua Titik",nil,7)
    local farmOnOffBtn,setFarmOnOff,getFarmOn,setFarmCallback=
        mkOnOffBtn(farmGroup,"Auto Farm + Quest",8)

    mkSection(farmSF,"Adjust",2)
    local _,setHeight,getHeight=mkSlider(farmSF,"Height Offset",0,50,0," studs",nil,3)
    local _,setSpeed, getSpeed =mkSlider(farmSF,"Tween Speed",20,500,150," st/s",nil,4)
    local _,setTD,    getTD    =mkSlider(farmSF,"Jeda Titik",1,10,1,"s",nil,5)
    local _,setLD,    getLD    =mkSlider(farmSF,"Loop Delay",0,10,3,"s",nil,6)

    mkSection(farmSF,"Auto Skill",7)
    local skillGroup=mkGroupBox(farmSF,8)
    mkSectionLabel(skillGroup,"Toggle per Skill",1)
    local skillOn={Z=false,X=false,C=false,V=false}
    mkToggle(skillGroup,"Auto Z Skill  (arg 1)",false,function(v) skillOn.Z=v end,2)
    mkToggle(skillGroup,"Auto X Skill  (arg 2)",false,function(v) skillOn.X=v end,3)
    mkToggle(skillGroup,"Auto C Skill  (arg 3)",false,function(v) skillOn.C=v end,4)
    mkToggle(skillGroup,"Auto V Skill  (arg 4)",false,function(v) skillOn.V=v end,5)

    -- ── HIT ──────────────────────────────────────────────
    local hitSF=subPages["Hit"]
    local hitGroup=mkGroupBox(hitSF,1)
    mkSectionLabel(hitGroup,"Status",1)
    local _,setHitStat=mkStatus(hitGroup,"Status","Idle",2)
    local _,setHitRate=mkStatus(hitGroup,"Rate","0/s",3)
    mkSectionLabel(hitGroup,"Control",4)
    local hitOnOffBtn,setHitOnOff,getHitOn,setHitCallback=
        mkOnOffBtn(hitGroup,"Auto Hit (RequestHit)",5)

    -- ── TELEPORT ─────────────────────────────────────────
    local tpSF=subPages["TP"]
    local tpStatusGroup=mkGroupBox(tpSF,1)
    mkSectionLabel(tpStatusGroup,"Status",1)
    local _,setTPStat=mkStatus(tpStatusGroup,"Status","--",2)
    mkSection(tpSF,"Pilih Lokasi",2)

    for idx,loc in ipairs(TELEPORT_LOCATIONS) do
        local card=Instance.new("Frame",tpSF)
        card.Size=UDim2.new(1,0,0,44); card.BackgroundColor3=T.card
        card.BorderSizePixel=0; card.LayoutOrder=idx+2
        card.ClipsDescendants=true; card.ZIndex=5
        Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
        local cs=Instance.new("UIStroke",card)
        cs.Color=T.border; cs.Transparency=0.2; cs.Thickness=1.0
        Instance.new("UIGradient",card).Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(20,18,32)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(13,12,22)),
        }
        local numLbl=Instance.new("TextLabel",card)
        numLbl.Size=UDim2.new(0,20,1,0); numLbl.Position=UDim2.new(0,8,0,0)
        numLbl.BackgroundTransparency=1; numLbl.Text=tostring(idx)
        numLbl.TextColor3=T.textDim; numLbl.Font=Enum.Font.GothamBold
        numLbl.TextSize=9; numLbl.ZIndex=6
        local nameLbl=Instance.new("TextLabel",card)
        nameLbl.Size=UDim2.new(1,-80,1,0); nameLbl.Position=UDim2.new(0,30,0,0)
        nameLbl.BackgroundTransparency=1; nameLbl.Text=loc
        nameLbl.TextColor3=T.text; nameLbl.Font=Enum.Font.GothamBold
        nameLbl.TextSize=12; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=6
        local goBtn=Instance.new("TextButton",card)
        goBtn.Size=UDim2.new(0,46,0,26); goBtn.Position=UDim2.new(1,-50,0.5,0)
        goBtn.AnchorPoint=Vector2.new(0,0.5)
        goBtn.BackgroundColor3=Color3.fromRGB(35,155,110)
        goBtn.Text="GO"; goBtn.TextColor3=T.white
        goBtn.Font=Enum.Font.GothamBold; goBtn.TextSize=11
        goBtn.BorderSizePixel=0; goBtn.ZIndex=7
        Instance.new("UICorner",goBtn).CornerRadius=UDim.new(0,7)
        Instance.new("UIGradient",goBtn).Color=ColorSequence.new{
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
    end

    -- ── BOSS ─────────────────────────────────────────────
    local bossSF=subPages["Boss"]

    local bossStatusGroup=mkGroupBox(bossSF,1)
    mkSectionLabel(bossStatusGroup,"Status",1)
    local _,setBossStat  =mkStatus(bossStatusGroup,"Status","Idle",2)
    local _,setBossTarget=mkStatus(bossStatusGroup,"Target","--",3)
    local _,setBossPhase =mkStatus(bossStatusGroup,"Phase","--",4)

    local bossSelectorGroup=mkGroupBox(bossSF,2)
    mkSectionLabel(bossSelectorGroup,"Boss Aktif di Workspace",1)

    local bossRefreshBtn=Instance.new("TextButton",bossSelectorGroup)
    bossRefreshBtn.Size=UDim2.new(1,0,0,30)
    bossRefreshBtn.BackgroundColor3=Color3.fromRGB(28,24,44)
    bossRefreshBtn.Text="↻  Refresh Boss List"
    bossRefreshBtn.TextColor3=T.textSub; bossRefreshBtn.Font=Enum.Font.GothamBold
    bossRefreshBtn.TextSize=11; bossRefreshBtn.BorderSizePixel=0
    bossRefreshBtn.LayoutOrder=2; bossRefreshBtn.ZIndex=6
    Instance.new("UICorner",bossRefreshBtn).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",bossRefreshBtn).Color=T.borderBright

    local bossListContainer=Instance.new("Frame",bossSelectorGroup)
    bossListContainer.BackgroundTransparency=1
    bossListContainer.Size=UDim2.new(1,0,0,0)
    bossListContainer.AutomaticSize=Enum.AutomaticSize.Y
    bossListContainer.BorderSizePixel=0; bossListContainer.LayoutOrder=3
    local blcL=Instance.new("UIListLayout",bossListContainer)
    blcL.Padding=UDim.new(0,4); blcL.SortOrder=Enum.SortOrder.LayoutOrder

    local bossControlGroup=mkGroupBox(bossSF,3)
    mkSectionLabel(bossControlGroup,"Control",1)
    local bossOnOffBtn,setBossOnOff,getBossOn,setBossCallback=
        mkOnOffBtn(bossControlGroup,"Auto Kill Boss",2)

    local selectedBoss=nil
    local bossCards={}

    local function rebuildBossCards()
        for _,c in ipairs(bossCards) do pcall(function() c:Destroy() end) end
        bossCards={}
        local list=detectBosses()
        if #list==0 then
            local ec=Instance.new("Frame",bossListContainer)
            ec.Size=UDim2.new(1,0,0,30); ec.BackgroundColor3=Color3.fromRGB(14,13,22)
            ec.BorderSizePixel=0; ec.LayoutOrder=1; ec.ZIndex=5
            Instance.new("UICorner",ec).CornerRadius=UDim.new(0,8)
            local el=Instance.new("TextLabel",ec)
            el.Size=UDim2.new(1,0,1,0); el.BackgroundTransparency=1
            el.Text="Tidak ada boss terdeteksi"; el.TextColor3=T.textDim
            el.Font=Enum.Font.Gotham; el.TextSize=10; el.ZIndex=6
            table.insert(bossCards,ec); return
        end
        for idx,bossName in ipairs(list) do
            local isSel=(selectedBoss==bossName)
            local card=Instance.new("Frame",bossListContainer)
            card.Size=UDim2.new(1,0,0,38)
            card.BackgroundColor3=isSel and Color3.fromRGB(36,24,64) or Color3.fromRGB(15,14,23)
            card.BorderSizePixel=0; card.LayoutOrder=idx; card.ZIndex=5
            Instance.new("UICorner",card).CornerRadius=UDim.new(0,9)
            local cs=Instance.new("UIStroke",card)
            cs.Color=isSel and T.accentGlow or T.border
            cs.Transparency=isSel and 0.08 or 0.4; cs.Thickness=1.0
            local dot=Instance.new("Frame",card)
            dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,10,0.5,0)
            dot.AnchorPoint=Vector2.new(0,0.5)
            dot.BackgroundColor3=isSel and T.green or T.red
            dot.BorderSizePixel=0; dot.ZIndex=7
            Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            local nameL=Instance.new("TextLabel",card)
            nameL.Size=UDim2.new(1,-78,1,0); nameL.Position=UDim2.new(0,22,0,0)
            nameL.BackgroundTransparency=1; nameL.Text=bossName
            nameL.TextColor3=isSel and T.white or T.textSub
            nameL.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham
            nameL.TextSize=11; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
            local selBtn=Instance.new("TextButton",card)
            selBtn.Size=UDim2.new(0,52,0,24); selBtn.Position=UDim2.new(1,-56,0.5,0)
            selBtn.AnchorPoint=Vector2.new(0,0.5)
            selBtn.BackgroundColor3=isSel and T.accentSoft or Color3.fromRGB(28,24,44)
            selBtn.Text=isSel and "✓ Aktif" or "Pilih"
            selBtn.TextColor3=T.white; selBtn.Font=Enum.Font.GothamBold
            selBtn.TextSize=10; selBtn.BorderSizePixel=0; selBtn.ZIndex=7
            Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,6)
            local ci=bossName
            selBtn.MouseButton1Click:Connect(function()
                selectedBoss=ci
                setBossTarget(ci,T.accentGlow)
                ripple(selBtn,selBtn.AbsoluteSize.X*0.5,selBtn.AbsoluteSize.Y*0.5,T.accent)
                rebuildBossCards()
            end)
            table.insert(bossCards,card)
        end
    end
    bossRefreshBtn.MouseButton1Click:Connect(function()
        ripple(bossRefreshBtn,bossRefreshBtn.AbsoluteSize.X*0.5,bossRefreshBtn.AbsoluteSize.Y*0.5,T.white)
        rebuildBossCards()
        setBossStat("List diperbarui",T.accentGlow)
        task.delay(1.5,function() if not getBossOn() then setBossStat("Idle",T.textDim) end end)
    end)
    rebuildBossCards()

    -- ── DUNGEON ──────────────────────────────────────────
    local dungeonSF=subPages["Dungeon"]

    local dungeonStatusGroup=mkGroupBox(dungeonSF,1)
    mkSectionLabel(dungeonStatusGroup,"Status",1)
    local _,setDungeonStat=mkStatus(dungeonStatusGroup,"Status","Idle",2)
    local _,setDungeonNPC =mkStatus(dungeonStatusGroup,"NPC","--",3)
    local _,setDungeonHit =mkStatus(dungeonStatusGroup,"Hit","0/s",4)

    local dungeonControlGroup=mkGroupBox(dungeonSF,2)
    mkSectionLabel(dungeonControlGroup,"Control",1)
    local dungeonOnOffBtn,setDungeonOnOff,getDungeonOn,setDungeonCallback=
        mkOnOffBtn(dungeonControlGroup,"Auto Dungeon",2)

    mkSection(dungeonSF,"Info",3)
    mkStatus(dungeonSF,"Remote","RequestHit + Ability 1-3",4)
    mkStatus(dungeonSF,"Tween","Ke semua NPC (1s/NPC)",5)
    mkStatus(dungeonSF,"Spin","360° HRP setiap 0.5s",6)

    -- ════════════════════════════════
    -- PAGE: SETTINGS
    -- ════════════════════════════════
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

    return {
        getIsland=getIsland, getFarmMode=getFarmMode,
        getHeight=getHeight, getSpeed=getSpeed, getTD=getTD, getLD=getLD,
        setFarmStat=setFarmStat, setFarmPhase=setFarmPhase, setFarmNPC=setFarmNPC,
        setFarmOnOff=setFarmOnOff, getFarmOn=getFarmOn, setFarmCallback=setFarmCallback,
        getSkillOn=function(k) return skillOn[k] end,
        setHitStat=setHitStat, setHitRate=setHitRate,
        setHitOnOff=setHitOnOff, getHitOn=getHitOn, setHitCallback=setHitCallback,
        getSelectedBoss=function() return selectedBoss end,
        setBossStat=setBossStat, setBossTarget=setBossTarget, setBossPhase=setBossPhase,
        setBossOnOff=setBossOnOff, getBossOn=getBossOn, setBossCallback=setBossCallback,
        setDungeonStat=setDungeonStat, setDungeonNPC=setDungeonNPC, setDungeonHit=setDungeonHit,
        setDungeonOnOff=setDungeonOnOff, getDungeonOn=getDungeonOn, setDungeonCallback=setDungeonCallback,
    }
end
