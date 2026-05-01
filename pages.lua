-- ╔══════════════════════════════════════════════════════╗
-- ║  pages.lua  — Yi Da Mu Sake  v8.3                   ║
-- ║  Refactored: each section is its own function        ║
-- ║  to stay under Lua's 200 local-register limit.      ║
-- ╚══════════════════════════════════════════════════════╝

-- ── Module-level constants ────────────────────────────────────────────────────
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
local GUI_LIST_MENU = {
    {name="Enchant UI",     path="EnchantUI"},
    {name="Tower Merchant", path="InfiniteTowerMerchantUI"},
    {name="Power Reroll",   path="PowerRerollUI"},
    {name="Reroll Stats",   path="RerollStatsUI"},
    {name="Spec Passive",   path="SpecPassiveUI"},
    {name="Trait Reroll",   path="TraitRerollUI"},
    {name="Blessing",       path="BlessingUI"},
}

-- ── Timer helpers ─────────────────────────────────────────────────────────────
local function findTimerLabel(container)
    for _,d in ipairs(container:GetDescendants()) do
        if d:IsA("TextLabel") then
            local t = d.Text or ""
            if t:match("^%d+:%d%d$") or t:match("^%d+:%d%d:%d%d$") then return d end
        end
    end
end

local function parseTimerSecs(text)
    if not text then return -1 end
    local h,m,s = text:match("^(%d+):(%d+):(%d+)$")
    if h then return tonumber(h)*3600+tonumber(m)*60+tonumber(s) end
    local m2,s2 = text:match("^(%d+):(%d+)$")
    if m2 then return tonumber(m2)*60+tonumber(s2) end
    return -1
end

-- ── Notification system ───────────────────────────────────────────────────────
local function makeNotifier(gui, T, TweenService)
    local W=272; local H=60; local GAP=5; local MX=10; local MY=10
    local stack = {}

    local function recalc()
        local baseY = -MY
        for i=#stack,1,-1 do
            local e=stack[i]
            if e and e.f and e.f.Parent then
                local tY=baseY-H
                TweenService:Create(e.f,TweenInfo.new(0.20,Enum.EasingStyle.Quint),
                    {Position=UDim2.new(1,-(W+MX),1,tY)}):Play()
                baseY=baseY-H-GAP
            end
        end
    end

    local function dismiss(entry)
        if entry.done then return end
        entry.done=true
        if entry.f and entry.f.Parent then
            TweenService:Create(entry.f,TweenInfo.new(0.18,Enum.EasingStyle.Quint),
                {Position=UDim2.new(1,MX,entry.f.Position.Y.Scale,entry.f.Position.Y.Offset)}):Play()
            task.delay(0.20,function() pcall(function() entry.f:Destroy() end) end)
        end
        for i,e in ipairs(stack) do if e==entry then table.remove(stack,i); break end end
        recalc()
    end

    return function(title,subtitle,col)
        pcall(function()
            local snd=Instance.new("Sound"); snd.SoundId="rbxassetid://9118377284"; snd.Volume=0.55
            snd.Parent=game:GetService("SoundService"); game:GetService("SoundService"):PlayLocalSound(snd)
            game:GetService("Debris"):AddItem(snd,4)
        end)
        local ac=col or T.green
        local f=Instance.new("Frame",gui)
        f.Size=UDim2.new(0,W,0,H); f.Position=UDim2.new(1,MX,1,-MY-H)
        f.BackgroundColor3=Color3.fromRGB(13,12,22); f.BorderSizePixel=0; f.ZIndex=650; f.ClipsDescendants=true
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,12)
        local ns=Instance.new("UIStroke",f); ns.Color=ac; ns.Thickness=1.4; ns.Transparency=0.05
        local prog=Instance.new("Frame",f); prog.Size=UDim2.new(1,0,0,2); prog.Position=UDim2.new(0,0,1,-2)
        prog.BackgroundColor3=ac; prog.BorderSizePixel=0; prog.ZIndex=652; Instance.new("UICorner",prog).CornerRadius=UDim.new(1,0)
        local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,3,1,-14); bar.Position=UDim2.new(0,8,0,7)
        bar.BackgroundColor3=ac; bar.BorderSizePixel=0; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
        local tl=Instance.new("TextLabel",f); tl.Size=UDim2.new(1,-28,0,22); tl.Position=UDim2.new(0,18,0,6)
        tl.BackgroundTransparency=1; tl.Text=title or ""; tl.TextColor3=T.white; tl.Font=Enum.Font.GothamBold
        tl.TextSize=13; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.TextTruncate=Enum.TextTruncate.AtEnd; tl.ZIndex=651
        local sl=Instance.new("TextLabel",f); sl.Size=UDim2.new(1,-28,0,14); sl.Position=UDim2.new(0,18,0,32)
        sl.BackgroundTransparency=1; sl.Text=subtitle or ""; sl.TextColor3=T.textSub; sl.Font=Enum.Font.Gotham
        sl.TextSize=10; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.TextTruncate=Enum.TextTruncate.AtEnd; sl.ZIndex=651
        local xb=Instance.new("TextButton",f); xb.Size=UDim2.new(0,16,0,16); xb.Position=UDim2.new(1,-19,0,4)
        xb.BackgroundTransparency=1; xb.Text="x"; xb.TextColor3=T.textDim; xb.Font=Enum.Font.GothamBold; xb.TextSize=10; xb.ZIndex=653
        local entry={f=f,done=false}
        table.insert(stack,entry); recalc()
        TweenService:Create(prog,TweenInfo.new(4.5,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,2)}):Play()
        task.delay(4.5,function() dismiss(entry) end)
        xb.MouseButton1Click:Connect(function() dismiss(entry) end)
    end
end

-- ════════════════════════════════════════════════════════════════════════════
-- SECTION BUILDERS  (each is its own function → own register pool)
-- ════════════════════════════════════════════════════════════════════════════

-- ── INFO page ────────────────────────────────────────────────────────────────
local function buildInfoPage(page, lib, showNotif)
    local T=lib.T; local smooth=lib.smooth; local ripple=lib.ripple
    local mkScrollPage=lib.mkScrollPage; local mkSection=lib.mkSection
    local infoSF=mkScrollPage(page)
    mkSection(infoSF,"Boss Countdown",1)
    local irBtn=Instance.new("TextButton",infoSF)
    irBtn.Size=UDim2.new(1,0,0,30); irBtn.BackgroundColor3=Color3.fromRGB(20,18,34)
    irBtn.Text="Refresh Timer"; irBtn.TextColor3=T.textSub; irBtn.Font=Enum.Font.GothamBold
    irBtn.TextSize=11; irBtn.BorderSizePixel=0; irBtn.LayoutOrder=2; irBtn.ZIndex=6
    Instance.new("UICorner",irBtn).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",irBtn).Color=T.borderBright
    local tc=Instance.new("Frame",infoSF); tc.BackgroundTransparency=1
    tc.Size=UDim2.new(1,0,0,0); tc.AutomaticSize=Enum.AutomaticSize.Y
    tc.BorderSizePixel=0; tc.LayoutOrder=3
    local tcL=Instance.new("UIListLayout",tc); tcL.Padding=UDim.new(0,5); tcL.SortOrder=Enum.SortOrder.LayoutOrder
    local entries={}
    local function buildCards()
        for _,c in ipairs(tc:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        entries={}; local found=0
        for _,child in ipairs(workspace:GetChildren()) do
            local bn=child.Name:match("^TimedBossSpawn_(.+)_Container$")
            if bn then
                found=found+1; local tl=findTimerLabel(child)
                local card=Instance.new("Frame",tc); card.Size=UDim2.new(1,0,0,52)
                card.BackgroundColor3=Color3.fromRGB(14,13,22); card.BorderSizePixel=0
                card.LayoutOrder=found; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
                local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.25; cs.Thickness=0.8
                local ab=Instance.new("Frame",card); ab.Size=UDim2.new(0,3,1,-14); ab.Position=UDim2.new(0,8,0,7)
                ab.BackgroundColor3=T.accentDim; ab.BorderSizePixel=0; Instance.new("UICorner",ab).CornerRadius=UDim.new(1,0)
                local nL=Instance.new("TextLabel",card); nL.Size=UDim2.new(0.55,0,0,20); nL.Position=UDim2.new(0,18,0,8)
                nL.BackgroundTransparency=1; nL.Text=bn; nL.TextColor3=T.text
                nL.Font=Enum.Font.GothamBold; nL.TextSize=12; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
                local dT=Instance.new("TextLabel",card); dT.Size=UDim2.new(0.45,-18,0,20); dT.Position=UDim2.new(0.55,0,0,8)
                dT.BackgroundTransparency=1; dT.Text=tl and tl.Text or "..."
                dT.TextColor3=T.accentGlow; dT.Font=Enum.Font.GothamBold; dT.TextSize=13
                dT.TextXAlignment=Enum.TextXAlignment.Right; dT.ZIndex=6
                local dS=Instance.new("TextLabel",card); dS.Size=UDim2.new(1,-24,0,12); dS.Position=UDim2.new(0,18,0,32)
                dS.BackgroundTransparency=1; dS.Text=tl and "Timer aktif" or "Belum ditemukan"
                dS.TextColor3=tl and T.textDim or T.amber; dS.Font=Enum.Font.Gotham; dS.TextSize=9
                dS.TextXAlignment=Enum.TextXAlignment.Left; dS.ZIndex=6
                table.insert(entries,{container=child,bossName=bn,timerLbl=tl,
                    dispTimer=dT,dispStatus=dS,cardStroke=cs,accentBar=ab,prevSecs=-1})
            end
        end
        if found==0 then
            local el=Instance.new("TextLabel",tc); el.Size=UDim2.new(1,0,0,30); el.BackgroundTransparency=1
            el.Text="Tidak ada TimedBossSpawn di workspace"; el.TextColor3=T.textDim
            el.Font=Enum.Font.Gotham; el.TextSize=10; el.LayoutOrder=1; el.TextXAlignment=Enum.TextXAlignment.Center
        end
    end
    buildCards()
    irBtn.MouseButton1Click:Connect(function() ripple(irBtn,irBtn.AbsoluteSize.X*0.5,irBtn.AbsoluteSize.Y*0.5,T.accent); buildCards() end)
    task.spawn(function()
        while infoSF and infoSF.Parent do
            for _,e in ipairs(entries) do pcall(function()
                if not e.timerLbl or not e.timerLbl.Parent then
                    local f=findTimerLabel(e.container)
                    if f then e.timerLbl=f; e.dispStatus.Text="Timer OK"; e.dispStatus.TextColor3=T.green
                    else e.dispTimer.Text="?"; e.dispStatus.Text="Belum ada timer"; e.dispStatus.TextColor3=T.amber; return end
                end
                local txt=e.timerLbl.Text or ""; e.dispTimer.Text=txt~="" and txt or "?"
                local secs=parseTimerSecs(txt)
                if secs==0 and e.prevSecs>0 then showNotif(e.bossName.." Spawned!","Boss muncul di map!",T.green) end
                e.prevSecs=secs
                if secs<0 then e.dispTimer.TextColor3=T.textDim; e.dispStatus.Text="Format: "..txt; smooth(e.cardStroke,{Color=T.border},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.textDim},0.3):Play()
                elseif secs==0 then e.dispTimer.TextColor3=T.green; e.dispStatus.Text="Spawn sekarang!"; smooth(e.cardStroke,{Color=T.green},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.green},0.3):Play()
                elseif secs<60 then e.dispTimer.TextColor3=T.amber; e.dispStatus.Text="Segera spawn!"; smooth(e.cardStroke,{Color=T.amber},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.amber},0.3):Play()
                else e.dispTimer.TextColor3=T.accentGlow; e.dispStatus.Text="Menunggu..."; smooth(e.cardStroke,{Color=T.border},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.accentDim},0.3):Play() end
            end) end
            task.wait(1)
        end
    end)
end

-- ── FARM / TP page ────────────────────────────────────────────────────────────
local function buildFarmPage(farmPage, lib, LocalPlayer)
    local T=lib.T; local smooth=lib.smooth; local ripple=lib.ripple
    local mkTwoColLayout=lib.mkTwoColLayout; local mkGroupBox=lib.mkGroupBox
    local mkSectionLabel=lib.mkSectionLabel; local mkSection=lib.mkSection
    local mkSlider=lib.mkSlider; local mkToggle=lib.mkToggle
    local mkOnOffBtn=lib.mkOnOffBtn; local mkDropdownV2=lib.mkDropdownV2

    local leftF,rightF=mkTwoColLayout(farmPage,T.border)

    -- Farm group
    local farmGroup=mkGroupBox(leftF,1); mkSectionLabel(farmGroup,"Pulau & Mode",1)
    local _,getIsland  =mkDropdownV2(farmGroup,"Pulau","*",Color3.fromRGB(78,46,200),FARM_ISLANDS,"Starter Island",nil,2)
    local _,getFarmMode=mkDropdownV2(farmGroup,"Mode","o",Color3.fromRGB(50,130,200),{"V1 - Semua Titik","V2 - Titik Tengah"},"V1 - Semua Titik",nil,3)
    local _,setFarmOnOff,getFarmOn,setFarmCallback=mkOnOffBtn(farmGroup,"Auto Farm + Quest",4)
    local _,_,getAutoHitOn=mkToggle(farmGroup,"Kill Aura",false,nil,5)

    -- TP Loop group
    local tpGroup=mkGroupBox(leftF,2); mkSectionLabel(tpGroup,"TP Loop (2 Titik)",1)
    local DEF_A={x=-203.174,y=22.093,z=-420.721}
    local DEF_B={x=-309.006,y=-3.667,z=-148.328}

    local statFr=Instance.new("Frame",tpGroup); statFr.Size=UDim2.new(1,0,0,18); statFr.BackgroundTransparency=1; statFr.BorderSizePixel=0; statFr.LayoutOrder=2
    local statLbl=Instance.new("TextLabel",statFr); statLbl.Size=UDim2.new(1,0,1,0); statLbl.BackgroundTransparency=1; statLbl.Text="Idle"; statLbl.TextColor3=T.textDim; statLbl.Font=Enum.Font.Gotham; statLbl.TextSize=9; statLbl.TextXAlignment=Enum.TextXAlignment.Center; statLbl.ZIndex=6
    local function setTpLoopStat(txt,col)
        if statLbl and statLbl.Parent then statLbl.Text=txt or "Idle"; if col then smooth(statLbl,{TextColor3=col},0.15):Play() end end
    end

    local _,setTpLoopOnOff,getTpLoopOn,setTpLoopCallback=mkOnOffBtn(tpGroup,"TP Loop",3)

    local function mkCoordBox(parent,lbl,val,order)
        local row=Instance.new("Frame",parent); row.Size=UDim2.new(1,0,0,26); row.BackgroundColor3=Color3.fromRGB(14,13,22); row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=5; Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
        local rs=Instance.new("UIStroke",row); rs.Color=T.border; rs.Transparency=0.45; rs.Thickness=0.7
        local nl=Instance.new("TextLabel",row); nl.Size=UDim2.new(0,18,1,0); nl.Position=UDim2.new(0,8,0,0); nl.BackgroundTransparency=1; nl.Text=lbl; nl.TextColor3=T.accentGlow; nl.Font=Enum.Font.GothamBold; nl.TextSize=10; nl.ZIndex=6; lib.regAccent("txtGlow",nl)
        local box=Instance.new("TextBox",row); box.Size=UDim2.new(1,-30,1,-6); box.Position=UDim2.new(0,26,0,3); box.BackgroundTransparency=1; box.Text=tostring(val); box.TextColor3=T.text; box.PlaceholderColor3=T.textDim; box.Font=Enum.Font.Gotham; box.TextSize=10; box.TextXAlignment=Enum.TextXAlignment.Left; box.ClearTextOnFocus=false; box.ZIndex=7
        box.Focused:Connect(function() smooth(rs,{Color=T.accentGlow,Transparency=0.05},0.15):Play() end)
        box.FocusLost:Connect(function() smooth(rs,{Color=T.border,Transparency=0.45},0.15):Play() end)
        return box
    end

    mkSectionLabel(tpGroup,"Koordinat A",4)
    local afr=Instance.new("Frame",tpGroup); afr.Size=UDim2.new(1,0,0,0); afr.AutomaticSize=Enum.AutomaticSize.Y; afr.BackgroundTransparency=1; afr.BorderSizePixel=0; afr.LayoutOrder=5
    local al=Instance.new("UIListLayout",afr); al.Padding=UDim.new(0,3); al.SortOrder=Enum.SortOrder.LayoutOrder
    local axBox=mkCoordBox(afr,"X",DEF_A.x,1); local ayBox=mkCoordBox(afr,"Y",DEF_A.y,2); local azBox=mkCoordBox(afr,"Z",DEF_A.z,3)

    mkSectionLabel(tpGroup,"Koordinat B",6)
    local bfr=Instance.new("Frame",tpGroup); bfr.Size=UDim2.new(1,0,0,0); bfr.AutomaticSize=Enum.AutomaticSize.Y; bfr.BackgroundTransparency=1; bfr.BorderSizePixel=0; bfr.LayoutOrder=7
    local bl=Instance.new("UIListLayout",bfr); bl.Padding=UDim.new(0,3); bl.SortOrder=Enum.SortOrder.LayoutOrder
    local bxBox=mkCoordBox(bfr,"X",DEF_B.x,1); local byBox=mkCoordBox(bfr,"Y",DEF_B.y,2); local bzBox=mkCoordBox(bfr,"Z",DEF_B.z,3)

    local function mkSetBtn(parent,lbl,order,cb)
        local btn=Instance.new("TextButton",parent); btn.Size=UDim2.new(1,0,0,24); btn.BackgroundColor3=Color3.fromRGB(20,18,38); btn.Text=lbl; btn.TextColor3=T.accentGlow; btn.Font=Enum.Font.GothamBold; btn.TextSize=9; btn.BorderSizePixel=0; btn.LayoutOrder=order; btn.ZIndex=6; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        local bs=Instance.new("UIStroke",btn); bs.Color=T.accentDim; bs.Transparency=0.2; bs.Thickness=0.8
        btn.MouseEnter:Connect(function() smooth(bs,{Color=T.accentGlow,Transparency=0.0},0.1):Play() end)
        btn.MouseLeave:Connect(function() smooth(bs,{Color=T.accentDim,Transparency=0.2},0.1):Play() end)
        btn.MouseButton1Down:Connect(function() smooth(btn,{BackgroundTransparency=0.3},0.06):Play() end)
        btn.MouseButton1Up:Connect(function()   smooth(btn,{BackgroundTransparency=0},  0.1):Play() end)
        btn.MouseButton1Click:Connect(function() ripple(btn,btn.AbsoluteSize.X*0.5,btn.AbsoluteSize.Y*0.5,T.accent); if cb then cb() end end)
    end
    mkSetBtn(tpGroup,"[ Set A = Posisi Saat Ini ]",8,function()
        local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hrp then local p=hrp.Position; axBox.Text=string.format("%.3f",p.X); ayBox.Text=string.format("%.3f",p.Y); azBox.Text=string.format("%.3f",p.Z); setTpLoopStat("Titik A diperbarui!",T.green)
        else setTpLoopStat("Karakter tidak ditemukan",T.red) end
    end)
    mkSetBtn(tpGroup,"[ Set B = Posisi Saat Ini ]",9,function()
        local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hrp then local p=hrp.Position; bxBox.Text=string.format("%.3f",p.X); byBox.Text=string.format("%.3f",p.Y); bzBox.Text=string.format("%.3f",p.Z); setTpLoopStat("Titik B diperbarui!",T.green)
        else setTpLoopStat("Karakter tidak ditemukan",T.red) end
    end)

    local function getTpLoopCoordA() return Vector3.new(tonumber(axBox.Text) or DEF_A.x,tonumber(ayBox.Text) or DEF_A.y,tonumber(azBox.Text) or DEF_A.z) end
    local function getTpLoopCoordB() return Vector3.new(tonumber(bxBox.Text) or DEF_B.x,tonumber(byBox.Text) or DEF_B.y,tonumber(bzBox.Text) or DEF_B.z) end

    -- Testing & Skill groups
    local modeGroup=mkGroupBox(leftF,3); mkSectionLabel(modeGroup,"Testing Mode",1)
    local _,_,getFaceDown=mkToggle(modeGroup,"Face Down",false,nil,2)
    local _,_,getSpinOn  =mkToggle(modeGroup,"Auto Spin HRP",false,nil,3)
    local skillGroup=mkGroupBox(leftF,4); mkSectionLabel(skillGroup,"Auto Skill",1)
    local skillOn={Z=false,X=false,C=false,V=false}
    mkToggle(skillGroup,"Z",false,function(v) skillOn.Z=v end,2)
    mkToggle(skillGroup,"X",false,function(v) skillOn.X=v end,3)
    mkToggle(skillGroup,"C",false,function(v) skillOn.C=v end,4)
    mkToggle(skillGroup,"V",false,function(v) skillOn.V=v end,5)

    -- Right column
    mkSection(rightF,"Adjust",1)
    local _,_,getHeight=mkSlider(rightF,"Height",0,50,0," st",nil,2)
    local _,_,getSpeed =mkSlider(rightF,"Speed",20,500,150," st/s",nil,3)
    local _,_,getTD    =mkSlider(rightF,"Jeda",1,10,1,"s",nil,4)
    local _,_,getLD    =mkSlider(rightF,"Loop Delay",0,10,3,"s",nil,5)
    mkSection(rightF,"TP Loop",6)
    local _,_,getTpDelay=mkSlider(rightF,"Jeda Titik",1,30,5,"s",nil,7)

    return {
        getIsland=getIsland, getFarmMode=getFarmMode,
        getHeight=getHeight, getSpeed=getSpeed, getTD=getTD, getLD=getLD,
        setFarmOnOff=setFarmOnOff, getFarmOn=getFarmOn, setFarmCallback=setFarmCallback,
        getAutoHitOn=function() return getAutoHitOn() end,
        getFaceDown=function() return getFaceDown() end,
        getSpinOn=function() return getSpinOn() end,
        getSkillOn=function(k) return skillOn[k] end,
        getTpLoopOn=getTpLoopOn, setTpLoopOnOff=setTpLoopOnOff,
        setTpLoopCallback=setTpLoopCallback, getTpLoopCoordA=getTpLoopCoordA,
        getTpLoopCoordB=getTpLoopCoordB, getTpDelay=getTpDelay, setTpLoopStat=setTpLoopStat,
    }
end

-- ── TP tab ────────────────────────────────────────────────────────────────────
local function buildTPPage(tpPage, lib)
    local T=lib.T; local smooth=lib.smooth; local ripple=lib.ripple
    local mkTwoColLayout=lib.mkTwoColLayout
    local tpLeftF,tpRightF=mkTwoColLayout(tpPage,T.border)
    local statCard=Instance.new("Frame",tpLeftF); statCard.Size=UDim2.new(1,0,0,22); statCard.BackgroundTransparency=1; statCard.BorderSizePixel=0; statCard.LayoutOrder=0
    local statLbl=Instance.new("TextLabel",statCard); statLbl.Size=UDim2.new(1,0,1,0); statLbl.BackgroundTransparency=1; statLbl.Text="Pilih lokasi"; statLbl.TextColor3=T.textDim; statLbl.Font=Enum.Font.Gotham; statLbl.TextSize=10; statLbl.TextXAlignment=Enum.TextXAlignment.Center
    local function setStat(txt,col) statLbl.Text=txt or "--"; if col then smooth(statLbl,{TextColor3=col},0.15):Play() end end
    local function makeTpCard(parent,loc,order)
        local card=Instance.new("Frame",parent); card.Size=UDim2.new(1,0,0,40); card.BackgroundColor3=T.card; card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,9)
        local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.5; cs.Thickness=0.8
        local ib=Instance.new("Frame",card); ib.Size=UDim2.new(0,2,0,20); ib.Position=UDim2.new(0,6,0.5,0); ib.AnchorPoint=Vector2.new(0,0.5); ib.BackgroundColor3=T.textDim; ib.BorderSizePixel=0; Instance.new("UICorner",ib).CornerRadius=UDim.new(1,0)
        local nL=Instance.new("TextLabel",card); nL.Size=UDim2.new(1,-54,1,0); nL.Position=UDim2.new(0,14,0,0); nL.BackgroundTransparency=1; nL.Text=loc; nL.TextColor3=T.text; nL.Font=Enum.Font.GothamBold; nL.TextSize=11; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
        local go=Instance.new("TextButton",card); go.Size=UDim2.new(0,36,0,22); go.Position=UDim2.new(1,-40,0.5,0); go.AnchorPoint=Vector2.new(0,0.5); go.BackgroundColor3=Color3.fromRGB(35,155,110); go.Text="GO"; go.TextColor3=T.white; go.Font=Enum.Font.GothamBold; go.TextSize=10; go.BorderSizePixel=0; go.ZIndex=7; Instance.new("UICorner",go).CornerRadius=UDim.new(0,6)
        Instance.new("UIGradient",go).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(50,188,135)),ColorSequenceKeypoint.new(1,Color3.fromRGB(28,138,92))}
        card.MouseEnter:Connect(function() smooth(card,{BackgroundColor3=T.cardHover},0.1):Play(); smooth(cs,{Color=T.accentGlow,Transparency=0.15},0.1):Play() end)
        card.MouseLeave:Connect(function() smooth(card,{BackgroundColor3=T.card},0.1):Play(); smooth(cs,{Color=T.border,Transparency=0.5},0.1):Play() end)
        go.MouseButton1Down:Connect(function() smooth(go,{Size=UDim2.new(0,32,0,18)},0.07):Play() end)
        go.MouseButton1Up:Connect(function()   smooth(go,{Size=UDim2.new(0,36,0,22)},0.12):Play() end)
        local ci=loc; go.MouseButton1Click:Connect(function()
            ripple(go,go.AbsoluteSize.X*0.5,go.AbsoluteSize.Y*0.5,T.white); setStat("Teleporting to "..ci,T.amber)
            pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(ci) end)
            task.delay(1.5,function() setStat("Arrived: "..ci,T.green) end)
        end)
    end
    for i=1,8  do makeTpCard(tpLeftF, TELEPORT_LOCATIONS[i],   i)   end
    for i=9,16 do makeTpCard(tpRightF,TELEPORT_LOCATIONS[i], i-8)   end
end

-- ── BOSS page ─────────────────────────────────────────────────────────────────
local function buildBossPage(bossPage, lib)
    local T=lib.T; local smooth=lib.smooth; local ripple=lib.ripple
    local mkTwoColLayout=lib.mkTwoColLayout; local mkGroupBox=lib.mkGroupBox
    local mkSectionLabel=lib.mkSectionLabel; local mkStatus=lib.mkStatus
    local mkOnOffBtn=lib.mkOnOffBtn; local mkCard=lib.mkCard
    local bossLeftF,bossRightF=mkTwoColLayout(bossPage,T.border)

    local killGroup=mkGroupBox(bossLeftF,1); mkSectionLabel(killGroup,"Kill Boss",1)
    local _,setBossStatFn =mkStatus(killGroup,"Status","Idle",2)
    local _,setBossPhaseFn=mkStatus(killGroup,"Phase","--",3)
    local _,setBossOnOff,getBossOn,setBossCallback=mkOnOffBtn(killGroup,"Kill Boss",4)
    local abc=Instance.new("Frame",killGroup); abc.BackgroundTransparency=1; abc.Size=UDim2.new(1,0,0,0); abc.AutomaticSize=Enum.AutomaticSize.Y; abc.BorderSizePixel=0; abc.LayoutOrder=5
    local abcL=Instance.new("UIListLayout",abc); abcL.Padding=UDim.new(0,3); abcL.SortOrder=Enum.SortOrder.LayoutOrder
    local selBoss=nil; local bCards={}

    local function getActiveNames()
        local active={}; local npcs=workspace:FindFirstChild("NPCs")
        for _,bn in ipairs(KNOWN_BOSSES) do
            local found=(npcs and npcs:FindFirstChild(bn)) or workspace:FindFirstChild(bn,true)
            if found then table.insert(active,bn) end
        end; return active
    end

    local function rebuildBossCards()
        for _,c in ipairs(bCards) do pcall(function() c:Destroy() end) end; bCards={}
        local active=getActiveNames()
        if #active==0 then
            local el=Instance.new("TextLabel",abc); el.Size=UDim2.new(1,0,0,22); el.LayoutOrder=1; el.BackgroundTransparency=1; el.Text="Tidak ada boss aktif"; el.TextColor3=T.textDim; el.Font=Enum.Font.Gotham; el.TextSize=9; el.TextXAlignment=Enum.TextXAlignment.Center; table.insert(bCards,el); return
        end
        if selBoss then local ok=false; for _,n in ipairs(active) do if n==selBoss then ok=true; break end end; if not ok then selBoss=nil end end
        for idx,bn in ipairs(active) do
            local isSel=(selBoss==bn)
            local card=Instance.new("Frame",abc); card.Size=UDim2.new(1,0,0,30); card.BackgroundColor3=isSel and Color3.fromRGB(28,18,52) or Color3.fromRGB(14,13,22); card.BorderSizePixel=0; card.LayoutOrder=idx; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,7)
            local cs=Instance.new("UIStroke",card); cs.Color=isSel and T.accentGlow or T.border; cs.Transparency=isSel and 0.05 or 0.5; cs.Thickness=isSel and 1.3 or 0.8
            local dot=Instance.new("Frame",card); dot.Size=UDim2.new(0,5,0,5); dot.Position=UDim2.new(0,7,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.green; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            local nL=Instance.new("TextLabel",card); nL.Size=UDim2.new(1,-46,1,0); nL.Position=UDim2.new(0,17,0,0); nL.BackgroundTransparency=1; nL.Text=bn; nL.TextColor3=isSel and T.white or T.textSub; nL.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham; nL.TextSize=9; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
            local sb=Instance.new("TextButton",card); sb.Size=UDim2.new(0,34,0,16); sb.Position=UDim2.new(1,-38,0.5,0); sb.AnchorPoint=Vector2.new(0,0.5); sb.BackgroundColor3=isSel and T.accentSoft or Color3.fromRGB(22,20,36); sb.Text=isSel and "ON" or "Set"; sb.TextColor3=T.white; sb.Font=Enum.Font.GothamBold; sb.TextSize=8; sb.BorderSizePixel=0; sb.ZIndex=7; Instance.new("UICorner",sb).CornerRadius=UDim.new(0,4)
            local ci=bn; sb.MouseButton1Click:Connect(function() selBoss=ci; ripple(sb,sb.AbsoluteSize.X*0.5,sb.AbsoluteSize.Y*0.5,T.accent); rebuildBossCards() end)
            table.insert(bCards,card)
        end
    end
    rebuildBossCards()
    task.spawn(function() while killGroup and killGroup.Parent do task.wait(3); if killGroup and killGroup.Parent then rebuildBossCards() end end end)

    local autoGroup=mkGroupBox(bossRightF,1); mkSectionLabel(autoGroup,"Auto Kill Boss",1)
    local _,setAutoBossStatFn =mkStatus(autoGroup,"Status","Idle",2)
    local _,setAutoBossPhaseFn=mkStatus(autoGroup,"Phase","--",3)
    local _,setAutoBossOnOff,getAutoBossOn,setAutoBossCallback=mkOnOffBtn(autoGroup,"Auto Kill Boss",4)
    mkSectionLabel(autoGroup,"Pilih Boss (multi)",5)
    local abSel={}; for _,n in ipairs(KNOWN_BOSSES) do abSel[n]=false end
    for idx,bn in ipairs(KNOWN_BOSSES) do
        local card,ccs=mkCard(autoGroup,28,idx+5)
        local dot=Instance.new("Frame",card); dot.Size=UDim2.new(0,5,0,5); dot.Position=UDim2.new(0,8,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.textDim; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local nL=Instance.new("TextLabel",card); nL.Size=UDim2.new(1,-36,1,0); nL.Position=UDim2.new(0,18,0,0); nL.BackgroundTransparency=1; nL.Text=bn; nL.TextColor3=T.textSub; nL.Font=Enum.Font.Gotham; nL.TextSize=9; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
        local chk=Instance.new("TextLabel",card); chk.Size=UDim2.new(0,18,1,0); chk.Position=UDim2.new(1,-20,0,0); chk.BackgroundTransparency=1; chk.Text=""; chk.TextColor3=T.green; chk.Font=Enum.Font.GothamBold; chk.TextSize=12; chk.ZIndex=7
        local hit=Instance.new("TextButton",card); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=8
        local ci=bn; local cd=dot; local cn=nL; local cc=chk; local cs=ccs
        hit.MouseButton1Click:Connect(function()
            abSel[ci]=not abSel[ci]; local on=abSel[ci]
            ripple(card,card.AbsoluteSize.X*0.5,card.AbsoluteSize.Y*0.5,T.accent)
            smooth(cd,{BackgroundColor3=on and T.green or T.textDim},0.15):Play()
            smooth(cn,{TextColor3=on and T.white or T.textSub},0.15):Play()
            smooth(cs,{Color=on and T.accentGlow or T.border,Transparency=on and 0.1 or 0.45},0.15):Play()
            cc.Text=on and "v" or ""; cn.Font=on and Enum.Font.GothamBold or Enum.Font.Gotham
        end)
    end

    local function getAutoBossSelectedList() local list={}; for _,n in ipairs(KNOWN_BOSSES) do if abSel[n] then table.insert(list,n) end end; return list end

    return {
        getSelectedBoss=function() return selBoss end,
        setBossStat=setBossStatFn, setBossPhase=setBossPhaseFn, setBossTarget=function() end,
        setBossOnOff=setBossOnOff, getBossOn=getBossOn, setBossCallback=setBossCallback,
        getAutoBossSelectedList=getAutoBossSelectedList,
        setAutoBossStat=setAutoBossStatFn, setAutoBossPhase=setAutoBossPhaseFn,
        setAutoBossOnOff=setAutoBossOnOff, getAutoBossOn=getAutoBossOn, setAutoBossCallback=setAutoBossCallback,
    }
end

-- ── DUNGEON page ──────────────────────────────────────────────────────────────
local function buildDungeonPage(dungeonPage, lib)
    local T=lib.T; local smooth=lib.smooth
    local mkScrollPage=lib.mkScrollPage; local mkOnOffBtn=lib.mkOnOffBtn
    local sf=mkScrollPage(dungeonPage)
    local function mkStatRow(parent,txt,order)
        local fr=Instance.new("Frame",parent); fr.Size=UDim2.new(1,0,0,16); fr.BackgroundTransparency=1; fr.LayoutOrder=order; fr.BorderSizePixel=0
        local lbl=Instance.new("TextLabel",fr); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=txt; lbl.TextColor3=T.textDim; lbl.Font=Enum.Font.Gotham; lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Center; return lbl
    end
    local statLbl=mkStatRow(sf,"Idle",1)
    local npcLbl =mkStatRow(sf,"NPC: --",2)
    local hitLbl =mkStatRow(sf,"0/s",3)
    local function setDungeonStat(t,c) if statLbl and statLbl.Parent then statLbl.Text=t or "Idle"; if c then smooth(statLbl,{TextColor3=c},0.15):Play() end end end
    local function setDungeonNPC(t,c)  if npcLbl  and npcLbl.Parent  then npcLbl.Text="NPC: "..(t or "--"); if c then smooth(npcLbl,{TextColor3=c},0.15):Play() end end end
    local function setDungeonHit(t,c)  if hitLbl  and hitLbl.Parent  then hitLbl.Text=t or "0/s"; if c then smooth(hitLbl,{TextColor3=c},0.15):Play() end end end
    local _,setDungeonOnOff,getDungeonOn,setDungeonCallback=mkOnOffBtn(sf,"Auto Dungeon",4)
    return {setDungeonStat=setDungeonStat,setDungeonNPC=setDungeonNPC,setDungeonHit=setDungeonHit,
            setDungeonOnOff=setDungeonOnOff,getDungeonOn=getDungeonOn,setDungeonCallback=setDungeonCallback}
end

-- ── MENU page ─────────────────────────────────────────────────────────────────
local function buildMenuPage(page, lib, LocalPlayer)
    local T=lib.T; local smooth=lib.smooth; local ripple=lib.ripple
    local mkScrollPage=lib.mkScrollPage; local mkSection=lib.mkSection
    local sf=mkScrollPage(page)
    local statLbl=Instance.new("TextLabel",sf); statLbl.Size=UDim2.new(1,0,0,16); statLbl.BackgroundTransparency=1; statLbl.Text=""; statLbl.TextColor3=T.textDim; statLbl.Font=Enum.Font.Gotham; statLbl.TextSize=9; statLbl.TextXAlignment=Enum.TextXAlignment.Center; statLbl.LayoutOrder=1; statLbl.ZIndex=5; statLbl.TextWrapped=true
    local function setStat(msg,col,dur)
        if not statLbl or not statLbl.Parent then return end
        statLbl.Text=msg or ""; smooth(statLbl,{TextColor3=col or T.textDim},0.12):Play()
        local cap=msg; task.delay(dur or 5,function() if statLbl and statLbl.Parent and statLbl.Text==cap then smooth(statLbl,{TextColor3=T.textDim},0.2):Play(); task.delay(0.25,function() if statLbl and statLbl.Parent and statLbl.Text==cap then statLbl.Text="" end end) end end)
    end
    local openState={}
    local function getUIOpen(path)
        local pg=LocalPlayer:FindFirstChild("PlayerGui"); if not pg then return false end
        local ui=pg:FindFirstChild(path)
        if not ui then local low=path:lower(); for _,c in ipairs(pg:GetChildren()) do if c.Name:lower()==low then ui=c; break end end end
        if not ui then return false end
        if ui:IsA("ScreenGui") and not ui.Enabled then return false end
        for _,c in ipairs(ui:GetChildren()) do if c:IsA("GuiObject") and c.Visible then return true end end
        for _,c in ipairs(ui:GetChildren()) do for _,g in ipairs(c:GetChildren()) do if g:IsA("GuiObject") and g.Visible then return true end end end
        return false
    end
    local function tryToggle(path,btn)
        local want=not getUIOpen(path)
        local pg=LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then setStat("PlayerGui tidak ditemukan",T.red); return false end
        local ui=pg:FindFirstChild(path)
        if not ui then local low=path:lower(); for _,c in ipairs(pg:GetChildren()) do if c.Name:lower()==low then ui=c; break end end end
        if not ui then
            local names={}; for _,c in ipairs(pg:GetChildren()) do table.insert(names,c.Name) end
            setStat("["..path.."] tidak ada. Ada: "..table.concat(names,", "):sub(1,80),T.red,8); return false
        end
        local ok,err=pcall(function()
            if want then
                if ui:IsA("ScreenGui") then ui.Enabled=true end
                local shown=0
                for _,c in ipairs(ui:GetChildren()) do if c:IsA("GuiObject") then c.Visible=true; shown=shown+1 end end
                if shown==0 then for _,c in ipairs(ui:GetChildren()) do for _,g in ipairs(c:GetChildren()) do if g:IsA("GuiObject") then g.Visible=true; shown=shown+1 end end end end
                if shown==0 then local f=ui:FindFirstChildWhichIsA("GuiObject",true); if f then f.Visible=true end end
                task.spawn(function() for _=1,4 do task.wait(0.25); if not openState[path] then break end; pcall(function() if ui:IsA("ScreenGui") then ui.Enabled=true end; for _,c in ipairs(ui:GetChildren()) do if c:IsA("GuiObject") then c.Visible=true end end end) end end)
            else
                if ui:IsA("ScreenGui") then ui.Enabled=false end
                for _,c in ipairs(ui:GetChildren()) do if c:IsA("GuiObject") then c.Visible=false end; for _,g in ipairs(c:GetChildren()) do if g:IsA("GuiObject") then g.Visible=false end end end
            end
        end)
        if ok then
            openState[path]=want
            if btn and btn.Parent then btn.Text=want and "Close" or "Open"; smooth(btn,{BackgroundColor3=want and Color3.fromRGB(180,50,50) or Color3.fromRGB(40,100,200)},0.18):Play() end
            setStat((want and "Dibuka: " or "Ditutup: ")..path, want and T.green or T.amber); return true
        else setStat(tostring(err):sub(1,80),T.red,8); return false end
    end
    local function mkCard(parent,lbl,btnTxt,btnCol,order)
        local card=Instance.new("Frame",parent); card.Size=UDim2.new(1,0,0,38); card.BackgroundColor3=Color3.fromRGB(14,13,22); card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,9)
        local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.45; cs.Thickness=0.8
        local dot=Instance.new("Frame",card); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0,8,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.accentDim; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local lb=Instance.new("TextLabel",card); lb.Size=UDim2.new(1,-76,1,0); lb.Position=UDim2.new(0,18,0,0); lb.BackgroundTransparency=1; lb.Text=lbl; lb.TextColor3=T.text; lb.Font=Enum.Font.GothamBold; lb.TextSize=10; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.ZIndex=6; lb.TextTruncate=Enum.TextTruncate.AtEnd
        local btn=Instance.new("TextButton",card); btn.Size=UDim2.new(0,58,0,22); btn.Position=UDim2.new(1,-62,0.5,0); btn.AnchorPoint=Vector2.new(0,0.5); btn.BackgroundColor3=btnCol or T.accentSoft; btn.Text=btnTxt; btn.TextColor3=T.white; btn.Font=Enum.Font.GothamBold; btn.TextSize=10; btn.BorderSizePixel=0; btn.ZIndex=7; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        card.MouseEnter:Connect(function() smooth(card,{BackgroundColor3=Color3.fromRGB(18,17,30)},0.08):Play(); smooth(cs,{Color=T.accentGlow,Transparency=0.2},0.08):Play(); smooth(dot,{BackgroundColor3=T.accentGlow},0.08):Play() end)
        card.MouseLeave:Connect(function() smooth(card,{BackgroundColor3=Color3.fromRGB(14,13,22)},0.08):Play(); smooth(cs,{Color=T.border,Transparency=0.45},0.08):Play(); smooth(dot,{BackgroundColor3=T.accentDim},0.08):Play() end)
        btn.MouseButton1Down:Connect(function() smooth(btn,{Size=UDim2.new(0,52,0,18)},0.07):Play() end)
        btn.MouseButton1Up:Connect(function()   smooth(btn,{Size=UDim2.new(0,58,0,22)},0.10):Play() end)
        return card,btn
    end
    mkSection(sf,"Open GUI",2)
    for i,g in ipairs(GUI_LIST_MENU) do
        local ci=g.path; local _,btn=mkCard(sf,g.name,"Open",Color3.fromRGB(40,100,200),i+2)
        btn.MouseButton1Click:Connect(function() ripple(btn,btn.AbsoluteSize.X*0.5,btn.AbsoluteSize.Y*0.5,T.white); tryToggle(ci,btn) end)
    end
    local SO=#GUI_LIST_MENU+4
    mkSection(sf,"Debug Tools",SO)
    local _,scanBtn=mkCard(sf,"Scan Semua ScreenGui","Scan",Color3.fromRGB(80,60,180),SO+1)
    scanBtn.MouseButton1Click:Connect(function()
        ripple(scanBtn,scanBtn.AbsoluteSize.X*0.5,scanBtn.AbsoluteSize.Y*0.5,T.white)
        local pg=LocalPlayer:FindFirstChild("PlayerGui"); if not pg then setStat("PlayerGui tidak ditemukan",T.red); return end
        local names={}; for _,c in ipairs(pg:GetChildren()) do if c:IsA("ScreenGui") then table.insert(names,c.Name) end end
        setStat(#names>0 and table.concat(names,"  |  "):sub(1,200) or "Tidak ada ScreenGui",T.accentGlow,10)
    end)
    local _,openAnyBtn=mkCard(sf,"Buka GUI by Name","Buka",Color3.fromRGB(60,140,80),SO+2)
    local oaRow=Instance.new("Frame",sf); oaRow.Size=UDim2.new(1,0,0,34); oaRow.BackgroundColor3=Color3.fromRGB(14,13,22); oaRow.BorderSizePixel=0; oaRow.LayoutOrder=SO+3; oaRow.ZIndex=5; Instance.new("UICorner",oaRow).CornerRadius=UDim.new(0,9)
    local oaStr=Instance.new("UIStroke",oaRow); oaStr.Color=T.border; oaStr.Transparency=0.35; oaStr.Thickness=0.9
    local oaBox=Instance.new("TextBox",oaRow); oaBox.Size=UDim2.new(1,-76,1,-8); oaBox.Position=UDim2.new(0,10,0,4); oaBox.BackgroundTransparency=1; oaBox.Text=""; oaBox.PlaceholderText="Nama GUI (contoh: EnchantUI)"; oaBox.TextColor3=T.text; oaBox.PlaceholderColor3=T.textDim; oaBox.Font=Enum.Font.Gotham; oaBox.TextSize=10; oaBox.TextXAlignment=Enum.TextXAlignment.Left; oaBox.ClearTextOnFocus=false; oaBox.ZIndex=7
    local oaOK=Instance.new("TextButton",oaRow); oaOK.Size=UDim2.new(0,58,0,22); oaOK.Position=UDim2.new(1,-62,0.5,0); oaOK.AnchorPoint=Vector2.new(0,0.5); oaOK.BackgroundColor3=Color3.fromRGB(40,100,200); oaOK.Text="Buka"; oaOK.TextColor3=T.white; oaOK.Font=Enum.Font.GothamBold; oaOK.TextSize=10; oaOK.BorderSizePixel=0; oaOK.ZIndex=8; Instance.new("UICorner",oaOK).CornerRadius=UDim.new(0,6)
    oaBox.Focused:Connect(function()   smooth(oaStr,{Color=T.accentGlow,Transparency=0.0},0.15):Play() end)
    oaBox.FocusLost:Connect(function() smooth(oaStr,{Color=T.border,Transparency=0.35},0.15):Play() end)
    oaOK.MouseButton1Down:Connect(function() smooth(oaOK,{Size=UDim2.new(0,52,0,18)},0.07):Play() end)
    oaOK.MouseButton1Up:Connect(function()   smooth(oaOK,{Size=UDim2.new(0,58,0,22)},0.10):Play() end)
    oaOK.MouseButton1Click:Connect(function()
        ripple(oaOK,oaOK.AbsoluteSize.X*0.5,oaOK.AbsoluteSize.Y*0.5,T.white)
        local raw=oaBox.Text:match("^%s*(.-)%s*$") or ""
        if raw=="" then setStat("Masukkan nama GUI!",T.amber); return end
        tryToggle(raw,oaOK)
    end)
    mkSection(sf,"Open Boss UI",SO+4)
    local bHint=Instance.new("TextLabel",sf); bHint.Size=UDim2.new(1,0,0,14); bHint.BackgroundTransparency=1; bHint.Text="Format: NamaBossUI  (e.g. TheWorldBossUI)"; bHint.TextColor3=T.textDim; bHint.Font=Enum.Font.Gotham; bHint.TextSize=9; bHint.TextXAlignment=Enum.TextXAlignment.Center; bHint.LayoutOrder=SO+5; bHint.ZIndex=5
    local bRow=Instance.new("Frame",sf); bRow.Size=UDim2.new(1,0,0,38); bRow.BackgroundColor3=Color3.fromRGB(14,13,22); bRow.BorderSizePixel=0; bRow.LayoutOrder=SO+6; bRow.ZIndex=5; Instance.new("UICorner",bRow).CornerRadius=UDim.new(0,9)
    local bStr=Instance.new("UIStroke",bRow); bStr.Color=T.border; bStr.Transparency=0.35; bStr.Thickness=0.9
    local bBox=Instance.new("TextBox",bRow); bBox.Size=UDim2.new(1,-74,1,-10); bBox.Position=UDim2.new(0,10,0,5); bBox.BackgroundTransparency=1; bBox.Text=""; bBox.PlaceholderText="Nama boss (contoh: TheWorld)"; bBox.TextColor3=T.text; bBox.PlaceholderColor3=T.textDim; bBox.Font=Enum.Font.Gotham; bBox.TextSize=10; bBox.TextXAlignment=Enum.TextXAlignment.Left; bBox.ClearTextOnFocus=false; bBox.ZIndex=7
    local bBtn=Instance.new("TextButton",bRow); bBtn.Size=UDim2.new(0,60,0,24); bBtn.Position=UDim2.new(1,-64,0.5,0); bBtn.AnchorPoint=Vector2.new(0,0.5); bBtn.BackgroundColor3=Color3.fromRGB(40,100,200); bBtn.Text="Open"; bBtn.TextColor3=T.white; bBtn.Font=Enum.Font.GothamBold; bBtn.TextSize=10; bBtn.BorderSizePixel=0; bBtn.ZIndex=8; Instance.new("UICorner",bBtn).CornerRadius=UDim.new(0,6)
    bBox.Focused:Connect(function()   smooth(bStr,{Color=T.accentGlow,Transparency=0.0},0.15):Play() end)
    bBox.FocusLost:Connect(function() smooth(bStr,{Color=T.border,Transparency=0.35},0.15):Play() end)
    bBtn.MouseButton1Down:Connect(function() smooth(bBtn,{Size=UDim2.new(0,54,0,20)},0.07):Play() end)
    bBtn.MouseButton1Up:Connect(function()   smooth(bBtn,{Size=UDim2.new(0,60,0,24)},0.10):Play() end)
    bBtn.MouseButton1Click:Connect(function()
        ripple(bBtn,bBtn.AbsoluteSize.X*0.5,bBtn.AbsoluteSize.Y*0.5,T.white)
        local raw=bBox.Text:match("^%s*(.-)%s*$") or ""
        if raw=="" then setStat("Masukkan nama boss dulu!",T.amber); return end
        local attempts={raw.."BossUI",raw:sub(1,1):upper()..raw:sub(2).."BossUI",raw}
        local pg=LocalPlayer:FindFirstChild("PlayerGui")
        if pg then local low=raw:lower(); for _,c in ipairs(pg:GetChildren()) do local cl=c.Name:lower(); if cl:find(low,1,true) and (cl:find("boss",1,true) or cl:find("ui",1,true)) then local dup=false; for _,a in ipairs(attempts) do if a==c.Name then dup=true; break end end; if not dup then table.insert(attempts,c.Name) end end end end
        local ok2=false; for _,a in ipairs(attempts) do if tryToggle(a,bBtn) then ok2=true; break end end
        if not ok2 then setStat("["..raw.."BossUI] tidak ditemukan. Coba Scan.",T.red,8) end
    end)
end

-- ── SETTINGS + WEBHOOK ────────────────────────────────────────────────────────
local function buildSettingsPage(page, lib, root, rootCorner, rootStroke, rootGlow, particleList, spawnParticles, applyUIBgMode, applyMiniBgMode)
    local T=lib.T; local smooth=lib.smooth; local ripple=lib.ripple
    local mkScrollPage=lib.mkScrollPage; local mkSubTabBar=lib.mkSubTabBar
    local mkSection=lib.mkSection; local mkSlider=lib.mkSlider; local mkToggle=lib.mkToggle
    local mkDropdownV2=lib.mkDropdownV2; local mkStatus=lib.mkStatus; local mkOnOffBtn=lib.mkOnOffBtn
    local UISettings=lib.UISettings

    local subs=mkSubTabBar(page,{"Tampilan","Webhook"})
    local sf=mkScrollPage(subs["Tampilan"])
    mkSection(sf,"Appearance",1)
    mkSlider(sf,"UI Scale",70,130,100,"%",function(v) local bW=root.AbsoluteSize.X>0 and root.AbsoluteSize.X or 460; local bH=root.AbsoluteSize.Y>0 and root.AbsoluteSize.Y or 340; root.Size=UDim2.new(0,bW*(v/100),0,bH*(v/100)) end,2)
    mkSlider(sf,"Border Opacity",0,100,90,"%",function(v) rootStroke.Transparency=1-(v/100) end,3)
    mkSlider(sf,"Corner Radius",6,24,14,"px",function(v) rootCorner.CornerRadius=UDim.new(0,v) end,4)
    mkSection(sf,"Font",5)
    mkSlider(sf,"Font Size",8,18,12,"px",function(v) lib.applyFontSize(v) end,6)
    mkSection(sf,"Accent Color",7)
    mkDropdownV2(sf,"Accent","*",Color3.fromRGB(118,68,255),{"Purple","Blue","Cyan","Green","Red"},"Purple",function(v) lib.applyAccent(v) end,8)
    mkSection(sf,"Particles",9)
    mkToggle(sf,"Enable Particles",true,function(v) UISettings.particles=v; for _,p in ipairs(particleList) do if p and p.Parent then p.Visible=v end end end,10)
    mkSlider(sf,"Jumlah Partikel",5,80,26,"",function(v) UISettings.particleCount=v; spawnParticles(v) end,11)
    mkSection(sf,"Background Window",12)
    mkDropdownV2(sf,"Mode BG","o",Color3.fromRGB(80,80,180),{"Solid","Transparent","Blur"},"Solid",function(v) applyUIBgMode(v) end,13)
    mkSection(sf,"Background Minimize Bar",14)
    mkDropdownV2(sf,"Mode Mini BG","o",Color3.fromRGB(60,60,160),{"Solid","Transparent"},"Solid",function(v) applyMiniBgMode(v) end,15)
    mkSection(sf,"Effects",16)
    mkToggle(sf,"Window Glow",true,function(v) UISettings.glow=v; lib.smooth(rootGlow,{ImageTransparency=v and 0.85 or 1},0.3):Play() end,17)

    -- Webhook subtab
    local wsf=mkScrollPage(subs["Webhook"])
    mkSection(wsf,"Kontrol",1)
    local _,setWhStatFn               =mkStatus(wsf,"Status","Nonaktif",2)
    local _,setWhOnOff,getWhOn,setWhCallback=mkOnOffBtn(wsf,"Kirim Webhook",3)
    mkSection(wsf,"Filter Item",4)
    local sRow=Instance.new("Frame",wsf); sRow.Size=UDim2.new(1,0,0,34); sRow.BackgroundColor3=Color3.fromRGB(14,13,22); sRow.BorderSizePixel=0; sRow.LayoutOrder=5; sRow.ZIndex=5; Instance.new("UICorner",sRow).CornerRadius=UDim.new(0,8)
    local srSt=Instance.new("UIStroke",sRow); srSt.Color=T.border; srSt.Transparency=0.35; srSt.Thickness=0.9
    local sBox=Instance.new("TextBox",sRow); sBox.Size=UDim2.new(1,-76,1,-8); sBox.Position=UDim2.new(0,10,0,4); sBox.BackgroundTransparency=1; sBox.Text=""; sBox.PlaceholderText="Cari item..."; sBox.TextColor3=T.text; sBox.PlaceholderColor3=T.textDim; sBox.Font=Enum.Font.Gotham; sBox.TextSize=10; sBox.TextXAlignment=Enum.TextXAlignment.Left; sBox.ClearTextOnFocus=false; sBox.ZIndex=6
    local function mkSBtn(parent,xOff,bg,sym,col)
        local b=Instance.new("TextButton",parent); b.Size=UDim2.new(0,28,0,22); b.Position=UDim2.new(1,xOff,0.5,0); b.AnchorPoint=Vector2.new(0,0.5); b.BackgroundColor3=bg; b.Text=sym; b.TextColor3=col or T.white; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.BorderSizePixel=0; b.ZIndex=7; Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        b.MouseEnter:Connect(function() smooth(b,{BackgroundTransparency=0.22},0.08):Play() end); b.MouseLeave:Connect(function() smooth(b,{BackgroundTransparency=0},0.08):Play() end); return b
    end
    local rfBtn=mkSBtn(sRow,-66,Color3.fromRGB(28,26,46),"R",T.textSub)
    local cfBtn=mkSBtn(sRow,-34,T.accentSoft,"v",T.white); lib.regAccent("bgSoft",cfBtn)
    local scLbl=Instance.new("TextLabel",wsf); scLbl.Size=UDim2.new(1,-4,0,14); scLbl.BackgroundTransparency=1; scLbl.Text="Belum ada item dipilih"; scLbl.TextColor3=T.textDim; scLbl.Font=Enum.Font.Gotham; scLbl.TextSize=9; scLbl.TextXAlignment=Enum.TextXAlignment.Right; scLbl.LayoutOrder=6; scLbl.ZIndex=5
    local ilSF=Instance.new("ScrollingFrame",wsf); ilSF.Size=UDim2.new(1,0,0,164); ilSF.BackgroundTransparency=1; ilSF.BorderSizePixel=0; ilSF.ScrollBarThickness=2; ilSF.ScrollBarImageColor3=T.accent; ilSF.ScrollBarImageTransparency=0.4; ilSF.CanvasSize=UDim2.new(0,0,0,0); ilSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; ilSF.ZIndex=3; ilSF.ClipsDescendants=true; ilSF.LayoutOrder=7; lib.regAccent("scrollbar",ilSF)
    local ilL=Instance.new("UIListLayout",ilSF); ilL.Padding=UDim.new(0,3); ilL.SortOrder=Enum.SortOrder.LayoutOrder
    local ilP=Instance.new("UIPadding",ilSF); ilP.PaddingTop=UDim.new(0,3); ilP.PaddingBottom=UDim.new(0,4); ilP.PaddingLeft=UDim.new(0,2); ilP.PaddingRight=UDim.new(0,2)
    local LocalPlayer=game:GetService("Players").LocalPlayer
    local selItems={}; local iCards={}; local cachedNames={}
    local function loadNames()
        local names={}; local ok,st=pcall(function() local pg=LocalPlayer:FindFirstChild("PlayerGui"); if not pg then error("") end; local ui=pg:FindFirstChild("InventoryPanelUI"); if not ui then error("") end; return ui.MainFrame.Frame.Content.Holder.StorageHolder.Storage end); if not ok or not st then return names end
        for _,c in ipairs(st:GetChildren()) do local n=c.Name:match("^Item_(.+)$"); if n then table.insert(names,n) end end; table.sort(names); return names
    end
    local function updateCount() local n=0; for _,v in pairs(selItems) do if v then n=n+1 end end; if n>0 then scLbl.Text=n.." item dipilih"; smooth(scLbl,{TextColor3=T.accentGlow},0.15):Play() else scLbl.Text="Belum ada item dipilih"; smooth(scLbl,{TextColor3=T.textDim},0.15):Play() end end
    local function rebuildList(filter)
        for _,c in ipairs(iCards) do pcall(function() c:Destroy() end) end; iCards={}
        if #cachedNames==0 then cachedNames=loadNames() end
        local fl=(filter or ""):lower(); local ord=0
        for _,nm in ipairs(cachedNames) do
            if fl=="" or nm:lower():find(fl,1,true) then
                ord=ord+1; local isSel=selItems[nm]==true
                local card=Instance.new("Frame",ilSF); card.Size=UDim2.new(1,-2,0,26); card.BackgroundColor3=isSel and Color3.fromRGB(20,15,38) or Color3.fromRGB(14,13,22); card.BorderSizePixel=0; card.LayoutOrder=ord; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,6)
                local cs=Instance.new("UIStroke",card); cs.Color=isSel and T.accentGlow or T.border; cs.Transparency=isSel and 0.10 or 0.55; cs.Thickness=isSel and 1.1 or 0.7
                local dot=Instance.new("Frame",card); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0,7,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=isSel and T.green or T.textDim; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
                local nL=Instance.new("TextLabel",card); nL.Size=UDim2.new(1,-36,1,0); nL.Position=UDim2.new(0,16,0,0); nL.BackgroundTransparency=1; nL.Text=nm; nL.TextColor3=isSel and T.white or T.textSub; nL.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham; nL.TextSize=9; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
                local ck=Instance.new("TextLabel",card); ck.Size=UDim2.new(0,18,1,0); ck.Position=UDim2.new(1,-20,0,0); ck.BackgroundTransparency=1; ck.Text=isSel and "v" or ""; ck.TextColor3=T.green; ck.Font=Enum.Font.GothamBold; ck.TextSize=11; ck.ZIndex=7
                local hit=Instance.new("TextButton",card); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=8
                local ci=nm; local cc=card; local ccs=cs; local cd=dot; local cn=nL; local cck=ck
                hit.MouseEnter:Connect(function() if not selItems[ci] then smooth(cc,{BackgroundColor3=Color3.fromRGB(18,17,30)},0.08):Play() end end)
                hit.MouseLeave:Connect(function() if not selItems[ci] then smooth(cc,{BackgroundColor3=Color3.fromRGB(14,13,22)},0.08):Play() end end)
                hit.MouseButton1Click:Connect(function()
                    selItems[ci]=not selItems[ci]; local on=selItems[ci]==true
                    ripple(cc,cc.AbsoluteSize.X*0.5,cc.AbsoluteSize.Y*0.5,T.accent)
                    smooth(cc,{BackgroundColor3=on and Color3.fromRGB(20,15,38) or Color3.fromRGB(14,13,22)},0.15):Play()
                    smooth(ccs,{Color=on and T.accentGlow or T.border,Transparency=on and 0.10 or 0.55},0.15):Play()
                    smooth(cd,{BackgroundColor3=on and T.green or T.textDim},0.15):Play()
                    smooth(cn,{TextColor3=on and T.white or T.textSub},0.15):Play()
                    cn.Font=on and Enum.Font.GothamBold or Enum.Font.Gotham; cck.Text=on and "v" or ""; updateCount()
                end)
                table.insert(iCards,card)
            end
        end
        if ord==0 then local el=Instance.new("TextLabel",ilSF); el.Size=UDim2.new(1,-2,0,26); el.BackgroundTransparency=1; el.LayoutOrder=1; el.Text=#cachedNames==0 and "Storage tidak ditemukan (buka Inventory dulu)" or "Tidak ada item cocok"; el.TextColor3=T.textDim; el.Font=Enum.Font.Gotham; el.TextSize=9; el.TextXAlignment=Enum.TextXAlignment.Center; table.insert(iCards,el) end
    end
    sBox:GetPropertyChangedSignal("Text"):Connect(function() rebuildList(sBox.Text) end)
    sBox.Focused:Connect(function()   smooth(srSt,{Color=T.accentGlow,Transparency=0.0},0.15):Play() end)
    sBox.FocusLost:Connect(function() smooth(srSt,{Color=T.border,Transparency=0.35},0.15):Play() end)
    rfBtn.MouseButton1Click:Connect(function() ripple(rfBtn,rfBtn.AbsoluteSize.X*0.5,rfBtn.AbsoluteSize.Y*0.5,T.accent); cachedNames=loadNames(); rebuildList(sBox.Text) end)
    cfBtn.MouseButton1Click:Connect(function()
        ripple(cfBtn,cfBtn.AbsoluteSize.X*0.5,cfBtn.AbsoluteSize.Y*0.5,T.green)
        local n=0; for _,v in pairs(selItems) do if v then n=n+1 end end
        setWhStatFn(n>0 and (n.." item dikunci untuk dipantau") or "Belum ada item dipilih", n>0 and T.green or T.amber)
    end)
    rebuildList("")
    local function getSelectedWhItems() local list={}; for name,v in pairs(selItems) do if v then table.insert(list,name) end end; table.sort(list); return list end
    return {getSelectedWhItems=getSelectedWhItems, getWhOn=getWhOn, setWhOnOff=setWhOnOff, setWhCallback=setWhCallback, setWhStat=setWhStatFn}
end

-- ════════════════════════════════════════════════════════════════════════════
-- MAIN EXPORT  (thin orchestrator — minimal locals here)
-- ════════════════════════════════════════════════════════════════════════════
return function(lib, sideData, contentArea, bgF, root, rootCorner, rootStroke, rootGlow, particleList, spawnParticles, applyUIBgMode, applyMiniBgMode, gui)
    local T           = lib.T
    local TweenService = game:GetService("TweenService")
    local LocalPlayer  = game:GetService("Players").LocalPlayer
    local mkSubTabBar  = lib.mkSubTabBar

    local showNotif = makeNotifier(gui, T, TweenService)

    -- INFO
    buildInfoPage(sideData["Info"].page, lib, showNotif)

    -- MAIN (Farm / TP / Boss / Dungeon) via subtabs
    local mainInner = Instance.new("Frame", sideData["Main"].page)
    mainInner.Size=UDim2.new(1,-8,1,-8); mainInner.Position=UDim2.new(0,4,0,4); mainInner.BackgroundTransparency=1; mainInner.ZIndex=3
    local subPages = mkSubTabBar(mainInner,{"Farm","TP","Boss","Dungeon"})

    local farmRefs = buildFarmPage(subPages["Farm"], lib, LocalPlayer)
    buildTPPage(subPages["TP"], lib)
    local bossRefs = buildBossPage(subPages["Boss"], lib)
    local dungRefs = buildDungeonPage(subPages["Dungeon"], lib)

    -- MENU
    buildMenuPage(sideData["Menu"].page, lib, LocalPlayer)

    -- SETTINGS
    local wRefs = buildSettingsPage(
        sideData["Settings"].page, lib,
        root, rootCorner, rootStroke, rootGlow,
        particleList, spawnParticles, applyUIBgMode, applyMiniBgMode
    )

    -- Return all refs for logic.lua
    return {
        -- Farm
        getIsland        = farmRefs.getIsland,
        getFarmMode      = farmRefs.getFarmMode,
        getHeight        = farmRefs.getHeight,
        getSpeed         = farmRefs.getSpeed,
        getTD            = farmRefs.getTD,
        getLD            = farmRefs.getLD,
        setFarmOnOff     = farmRefs.setFarmOnOff,
        getFarmOn        = farmRefs.getFarmOn,
        setFarmCallback  = farmRefs.setFarmCallback,
        getAutoHitOn     = farmRefs.getAutoHitOn,
        getFaceDown      = farmRefs.getFaceDown,
        getSpinOn        = farmRefs.getSpinOn,
        getSkillOn       = farmRefs.getSkillOn,
        setFarmStat      = function() end,
        setFarmPhase     = function() end,
        setFarmNPC       = function() end,
        -- TP Loop
        getTpLoopOn       = farmRefs.getTpLoopOn,
        setTpLoopOnOff    = farmRefs.setTpLoopOnOff,
        setTpLoopCallback = farmRefs.setTpLoopCallback,
        getTpLoopCoordA   = farmRefs.getTpLoopCoordA,
        getTpLoopCoordB   = farmRefs.getTpLoopCoordB,
        getTpDelay        = farmRefs.getTpDelay,
        setTpLoopStat     = farmRefs.setTpLoopStat,
        -- Boss
        getSelectedBoss         = bossRefs.getSelectedBoss,
        setBossStat             = bossRefs.setBossStat,
        setBossPhase            = bossRefs.setBossPhase,
        setBossTarget           = bossRefs.setBossTarget,
        setBossOnOff            = bossRefs.setBossOnOff,
        getBossOn               = bossRefs.getBossOn,
        setBossCallback         = bossRefs.setBossCallback,
        getAutoBossSelectedList = bossRefs.getAutoBossSelectedList,
        setAutoBossStat         = bossRefs.setAutoBossStat,
        setAutoBossPhase        = bossRefs.setAutoBossPhase,
        setAutoBossOnOff        = bossRefs.setAutoBossOnOff,
        getAutoBossOn           = bossRefs.getAutoBossOn,
        setAutoBossCallback     = bossRefs.setAutoBossCallback,
        -- Dungeon
        setDungeonStat     = dungRefs.setDungeonStat,
        setDungeonNPC      = dungRefs.setDungeonNPC,
        setDungeonHit      = dungRefs.setDungeonHit,
        setDungeonOnOff    = dungRefs.setDungeonOnOff,
        getDungeonOn       = dungRefs.getDungeonOn,
        setDungeonCallback = dungRefs.setDungeonCallback,
        -- Webhook
        getSelectedWhItems = wRefs.getSelectedWhItems,
        getWhOn            = wRefs.getWhOn,
        setWhOnOff         = wRefs.setWhOnOff,
        setWhCallback      = wRefs.setWhCallback,
        setWhStat          = wRefs.setWhStat,
    }
end
