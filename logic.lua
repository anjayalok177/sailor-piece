local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer

local ISLANDS = {
    ["Starter Island"]   ={coords={Vector3.new(194.943,16.207,-171.994),Vector3.new(164.245,16.207,-176.308),Vector3.new(159.530,16.207,-142.758),Vector3.new(177.723,16.207,-157.247),Vector3.new(189.238,16.207,-138.583)},center=4},
    ["Jungle Island"]    ={coords={Vector3.new(-566.029,4.125,425.000),Vector3.new(-567.759,4.125,399.303),Vector3.new(-585.790,3.359,397.131),Vector3.new(-575.712,3.359,381.006),Vector3.new(-549.771,4.125,395.209)},center=2},
    ["Desert Island"]    ={coords={Vector3.new(-774.852,0.777,-405.228),Vector3.new(-793.225,0.777,-433.599),Vector3.new(-768.626,0.777,-452.058),Vector3.new(-815.452,0.777,-417.817),Vector3.new(-808.365,0.777,-457.034)},center=2},
    ["Snow Island"]      ={coords={Vector3.new(-423.471,3.861,-968.619),Vector3.new(-436.772,3.859,-998.843),Vector3.new(-410.853,3.861,-990.573),Vector3.new(-402.983,3.861,-1014.348),Vector3.new(-385.389,3.861,-981.637)},center=3},
    ["Shibuya"]          ={coords={Vector3.new(1407.890,13.486,522.877),Vector3.new(1435.052,13.839,480.898),Vector3.new(1398.259,13.486,488.059),Vector3.new(1362.940,13.486,493.791),Vector3.new(1390.117,13.486,451.823)},center=3},
    ["Hollow"]           ={coords={Vector3.new(-341.802,4.559,1091.144),Vector3.new(-365.126,4.559,1097.683),Vector3.new(-358.324,4.559,1078.029),Vector3.new(-385.284,5.201,1082.955),Vector3.new(-383.171,4.559,1110.780)},center=2},
    ["Shinjuku Island#1"]={coords={Vector3.new(684.111,1.882,-1715.860),Vector3.new(687.366,1.882,-1674.726),Vector3.new(654.620,1.882,-1733.495),Vector3.new(666.407,1.882,-1695.736),Vector3.new(650.193,1.882,-1671.640)},center=4},
    ["Shinjuku Island#2"]={coords={Vector3.new(-41.329,1.880,-1816.006),Vector3.new(4.006,1.796,-1864.215),Vector3.new(-18.397,1.835,-1845.567),Vector3.new(-3.303,1.877,-1810.039),Vector3.new(-26.961,1.862,-1875.934)},center=3},
    ["Slime"]            ={coords={Vector3.new(-1144.351,18.917,364.112),Vector3.new(-1111.960,13.918,354.755),Vector3.new(-1124.753,13.918,371.231),Vector3.new(-1136.075,21.067,388.744),Vector3.new(-1103.583,13.918,379.100)},center=3},
    ["Academy"]          ={coords={Vector3.new(1074.662,2.370,1250.483),Vector3.new(1046.124,1.463,1252.839),Vector3.new(1072.546,1.778,1275.642),Vector3.new(1095.647,1.463,1296.464),Vector3.new(1058.373,1.463,1297.346)},center=3},
    ["Judgement"]        ={coords={Vector3.new(-1268.647,1.307,-1161.301),Vector3.new(-1296.867,1.157,-1201.466),Vector3.new(-1240.514,1.138,-1176.326),Vector3.new(-1274.657,1.173,-1191.390),Vector3.new(-1260.848,1.333,-1219.831)},center=4},
    ["Soul Dominion"]    ={coords={Vector3.new(-1331.364,1603.565,1567.672),Vector3.new(-1314.989,1603.565,1595.409),Vector3.new(-1373.717,1604.229,1618.792),Vector3.new(-1339.529,1603.565,1617.110),Vector3.new(-1374.362,1603.551,1584.912)},center=4},
    ["Ninja"]            ={coords={Vector3.new(-1859.595,8.505,-753.854),Vector3.new(-1895.911,8.503,-724.515),Vector3.new(-1852.629,8.552,-718.633),Vector3.new(-1876.007,8.501,-738.603),Vector3.new(-1907.969,8.497,-748.339)},center=4},
    ["Lawless"]          ={coords={Vector3.new(47.442,-0.995,1793.444),Vector3.new(59.851,0.579,1816.135),Vector3.new(38.152,-0.196,1817.528),Vector3.new(68.066,-0.262,1801.037),Vector3.new(50.611,-0.448,1843.215)},center=2},
}
local ISLAND_TP={
    ["Starter Island"]="Starter",["Jungle Island"]="Jungle",["Desert Island"]="Desert",
    ["Snow Island"]="Snow",["Shibuya"]="Shibuya",["Hollow"]="HollowIsland",
    ["Shinjuku Island#1"]="Shinjuku",["Shinjuku Island#2"]="Shinjuku",
    ["Slime"]="Slime",["Academy"]="Academy",["Judgement"]="Judgement",
    ["Soul Dominion"]="Dungeon",["Ninja"]="Ninja",["Lawless"]="Lawless",
}
local BOSS_DATA={
    {keys={"aizen"},              tpLoc="HollowIsland",coord=Vector3.new(-568.560,-1.921,1230.594),  npc="AizenBoss"},
    {keys={"alucard"},            tpLoc="Starter",     coord=Vector3.new(249.629,7.593,930.764),     npc="AlucardBoss"},
    {keys={"jinwoo"},             tpLoc="Starter",     coord=Vector3.new(249.629,7.593,930.764),     npc="JinwooBoss"},
    {keys={"sukuna"},             tpLoc="Shibuya",     coord=Vector3.new(1535.394,8.486,224.764),    npc="SukunaBoss"},
    {keys={"yuji"},               tpLoc="Shibuya",     coord=Vector3.new(1573.553,72.721,-32.995),   npc="YujiBoss"},
    {keys={"gojo"},               tpLoc="Shibuya",     coord=Vector3.new(1854.535,8.486,338.636),    npc="GojoBoss"},
    {keys={"knight"},             tpLoc=nil,           coord=Vector3.new(771.258,-0.667,-1078.480),  npc="KnightBoss"},
    {keys={"yamato"},             tpLoc="Judgement",   coord=Vector3.new(-1422.103,21.415,-1381.292),npc="YamatoBoss"},
    {keys={"shinobi","strongest"},tpLoc="Ninja",       coord=Vector3.new(-2106.966,12.801,-595.638), npc="StrongestShinobiBoss"},
}
local function getBossData(bossName)
    if not bossName then return nil end
    local lower=bossName:lower()
    for _,e in ipairs(BOSS_DATA) do
        for _,kw in ipairs(e.keys) do if lower:find(kw,1,true) then return e end end
        if e.npc and e.npc:lower()==lower then return e end
    end
    return nil
end
local function fireTP(loc)
    pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(loc) end)
end

return function(refs,T)
    local character=player.Character or player.CharacterAdded:Wait()

    local function getRoot()
        character=player.Character; if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart")
    end
    local function fireSettings(k,v)
        pcall(function() ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SettingsToggle"):FireServer(k,v) end)
    end
    local function enableGS()
        fireSettings("EnableQuestRepeat",true); fireSettings("AutoQuestRepeat",true); fireSettings("DisablePVP",true)
    end
    local function disableGS()
        fireSettings("EnableQuestRepeat",false); fireSettings("AutoQuestRepeat",false); fireSettings("DisablePVP",false)
    end

    -- =====================
    -- REMOTE: RequestHit
    -- Path dikonfirmasi dari contoh user:
    -- ReplicatedStorage.CombatSystem.Remotes.RequestHit
    -- =====================
    local hitRemote=nil
    local function getHitRemote()
        if hitRemote and hitRemote.Parent then return hitRemote end
        local ok,r=pcall(function()
            return ReplicatedStorage
                :WaitForChild("CombatSystem",5)
                :WaitForChild("Remotes",5)
                :WaitForChild("RequestHit",5)
        end)
        if ok and r then hitRemote=r end
        return hitRemote
    end

    local abilityRemote=nil
    local function getAbilityRemote()
        if abilityRemote and abilityRemote.Parent then return abilityRemote end
        local paths={
            {"AbilitySystem","Remotes","RequestAbility"},
            {"Remotes","RequestAbility"},
        }
        for _,path in ipairs(paths) do
            local ok,r=pcall(function()
                local n=ReplicatedStorage
                for _,s in ipairs(path) do n=n:WaitForChild(s,2) end
                return n
            end)
            if ok and r then abilityRemote=r; return abilityRemote end
        end
        local f=ReplicatedStorage:FindFirstChild("RequestAbility",true)
        if f then abilityRemote=f end
        return abilityRemote
    end

    -- =====================
    -- CORE HIT FUNCTION
    -- Sesuai contoh remote event user:
    -- local args = { vector.create(x, y, z) }
    -- RequestHit:FireServer(unpack(args))
    -- =====================
    local function fireHitAt(vec3)
        if not vec3 then return end
        local remote=getHitRemote(); if not remote then return end
        pcall(function()
            remote:FireServer(vector.create(vec3.X, vec3.Y, vec3.Z))
        end)
    end

    -- =====================
    -- HELPER: posisi NPC terdekat dari workspace.NPCs
    -- Dipakai standalone hit dan dungeon
    -- =====================
    local function getNearestNPCPosition()
        local r=getRoot(); if not r then return nil end
        local folder=workspace:FindFirstChild("NPCs"); if not folder then return nil end
        local best,bestDist=nil,math.huge
        for _,npc in ipairs(folder:GetChildren()) do
            local part=(npc:IsA("BasePart") and npc)
                or (npc:IsA("Model") and (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart",true)))
            if part then
                local d=(r.Position-part.Position).Magnitude
                if d<bestDist then bestDist=d; best=part end
            end
        end
        return best and best.Position or nil
    end

    -- =====================
    -- HELPER: NPC model terdekat (untuk dungeon tween)
    -- =====================
    local function getNearestNPCModel()
        local r=getRoot(); if not r then return nil end
        local folder=workspace:FindFirstChild("NPCs"); if not folder then return nil end
        local best,bestDist=nil,math.huge
        for _,npc in ipairs(folder:GetChildren()) do
            local part=(npc:IsA("BasePart") and npc)
                or (npc:IsA("Model") and (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart",true)))
            if part then
                local d=(r.Position-part.Position).Magnitude
                if d<bestDist then bestDist=d; best=npc end
            end
        end
        return best
    end

    local flyBP,flyBG=nil,nil

    -- Spin task
    task.spawn(function()
        while true do
            if refs and refs.getSpinOn and refs.getSpinOn() then
                local r=getRoot()
                if r then
                    for i=1,20 do
                        if not (refs.getSpinOn and refs.getSpinOn()) then break end
                        local rr=getRoot(); if not rr then break end
                        local xTilt=(refs.getFaceDown and refs.getFaceDown()) and (math.pi/2) or 0
                        local angle=(i/20)*math.pi*2
                        local newCF=CFrame.new(rr.Position)*CFrame.fromEulerAnglesXYZ(xTilt,angle,0)
                        rr.CFrame=newCF
                        if flyBP then flyBP.Position=rr.Position end
                        if flyBG then flyBG.CFrame=newCF end
                        task.wait(0.003)
                    end
                else task.wait(0.1) end
            else task.wait(0.3) end
        end
    end)

    task.spawn(function()
        while true do
            if _G.islandFarmOn and refs and refs.getFaceDown and refs.getFaceDown() then
                local r=getRoot()
                if r and flyBG then
                    flyBG.CFrame=CFrame.new(r.Position)*CFrame.fromEulerAnglesXYZ(math.pi/2,0,0)
                end
            end
            task.wait(0.05)
        end
    end)

    local function enableFly()
        character=player.Character; if not character then return end
        local r=character:FindFirstChild("HumanoidRootPart")
        local h=character:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end; h.PlatformStand=true
        if flyBP then flyBP:Destroy() end; if flyBG then flyBG:Destroy() end
        flyBP=Instance.new("BodyPosition")
        flyBP.MaxForce=Vector3.new(1e5,1e5,1e5); flyBP.D=500; flyBP.P=5000
        flyBP.Position=r.Position; flyBP.Parent=r
        flyBG=Instance.new("BodyGyro")
        flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); flyBG.D=400
        flyBG.CFrame=r.CFrame; flyBG.Parent=r
    end
    local function disableFly()
        if flyBP then flyBP:Destroy(); flyBP=nil end
        if flyBG then flyBG:Destroy(); flyBG=nil end
        character=player.Character; if not character then return end
        local h=character:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand=false end
    end
    player.CharacterAdded:Connect(function(nc)
        character=nc; if _G.islandFarmOn then task.wait(1); enableFly() end
    end)

    local function moveTo(targetPos,speed)
        local r=getRoot(); if not r then return end
        local dist=(r.Position-targetPos).Magnitude
        if dist>80 then
            local dur=math.max(0.3,dist/(speed or 150))
            if flyBP then flyBP.Position=targetPos end
            local tw=TweenService:Create(r,TweenInfo.new(dur,Enum.EasingStyle.Linear),
                {CFrame=CFrame.new(targetPos)})
            tw:Play(); tw.Completed:Wait()
        else
            r.CFrame=CFrame.new(targetPos)
            if flyBP then flyBP.Position=targetPos end
        end
    end

    -- =====================
    -- FARM HIT SPAM
    -- Argumen: vector.create dari koordinat titik farm saat ini
    -- currentFarmVec diupdate setiap berpindah titik
    -- =====================
    local currentFarmVec=nil
    local farmHitRunning=false

    local function startFarmHitSpam()
        if farmHitRunning then return end
        farmHitRunning=true
        task.spawn(function()
            while farmHitRunning do
                -- currentFarmVec adalah Vector3 titik farm aktif
                if currentFarmVec then
                    fireHitAt(currentFarmVec)
                end
                task.wait()
            end
        end)
    end
    local function stopFarmHitSpam()
        farmHitRunning=false; currentFarmVec=nil
    end

    -- =====================
    -- NEAREST NPC HIT SPAM
    -- Argumen: vector.create dari posisi NPC terdekat (diperbarui tiap iterasi)
    -- Dipakai oleh standalone Auto Hit dan dungeon
    -- =====================
    local npcHitRunning=false

    local function startNearestHitSpam()
        if npcHitRunning then return end
        npcHitRunning=true
        task.spawn(function()
            while npcHitRunning do
                local pos=getNearestNPCPosition()
                -- pos adalah Vector3, fireHitAt akan convert ke vector.create
                if pos then fireHitAt(pos) end
                task.wait()
            end
        end)
    end
    local function stopNearestHitSpam()
        npcHitRunning=false
    end

    local function startAbilityLoop(checkFn)
        task.spawn(function()
            local remote=getAbilityRemote()
            while checkFn() do
                if remote then
                    for _,arg in ipairs({1,2,3}) do
                        if not checkFn() then break end
                        pcall(function() remote:FireServer(arg) end)
                    end
                end
                task.wait(0.5)
            end
        end)
    end

    -- Auto Skill Z/X/C/V
    task.spawn(function()
        local defs={{key="Z",arg=1},{key="X",arg=2},{key="C",arg=3},{key="V",arg=4}}
        while true do
            if refs and refs.getSkillOn then
                local remote=getAbilityRemote()
                if remote then
                    for _,s in ipairs(defs) do
                        if refs.getSkillOn(s.key) then
                            pcall(function() remote:FireServer(s.arg) end)
                        end
                    end
                end
            end
            task.wait()
        end
    end)

    -- Auto Quest
    local lastQuestNPC=nil
    local function fireQuestAccept(name)
        pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept"):FireServer(name)
        end)
    end
    local function tryAutoQuest()
        local r=getRoot(); if not r then return end
        local svc=workspace:FindFirstChild("ServiceNPCs"); if not svc then return end
        for i=1,19 do
            local name="QuestNPC"..i; local npc=svc:FindFirstChild(name)
            if npc then
                local pos
                if npc:IsA("Model") then
                    local pp=npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
                    if pp then pos=pp.Position end
                elseif npc:IsA("BasePart") then pos=npc.Position end
                if pos and (r.Position-pos).Magnitude<=100 then
                    if name~=lastQuestNPC then
                        fireQuestAccept(name)
                        fireSettings("EnableQuestRepeat",true)
                        fireSettings("AutoQuestRepeat",true)
                        lastQuestNPC=name
                    end
                    return
                end
            end
        end
    end

    local function tpAndWait(loc,secs) fireTP(loc); task.wait(secs or 3) end

    local farmV1On=false; local farmV2On=false
    local isRunningV1=false; local isRunningV2=false
    _G.islandFarmOn=false

    local function farmSetup(island)
        lastQuestNPC=nil
        local tpLoc=ISLAND_TP[island]; enableFly()
        if tpLoc then tpAndWait(tpLoc,3) end
        enableGS()
    end
    local function farmTeardown()
        disableFly(); disableGS(); lastQuestNPC=nil
        stopFarmHitSpam()
    end

    -- =====================
    -- FARM V1
    -- currentFarmVec = koordinat setiap titik farm saat berpindah
    -- fireHitAt(currentFarmVec) → vector.create(x,y,z)
    -- =====================
    local function farmLoopV1()
        isRunningV1=true
        -- Bug#5 fix: cek state sebelum setup
        if not farmV1On then
            isRunningV1=false
            if refs then refs.setFarmOnOff(false) end
            return
        end
        _G.islandFarmOn=true
        local island=refs.getIsland(); farmSetup(island)
        if refs.getAutoHitOn and refs.getAutoHitOn() then startFarmHitSpam() end
        startAbilityLoop(function() return farmV1On end)

        while farmV1On do
            island=refs.getIsland(); local data=ISLANDS[island]
            if not data then task.wait(1); continue end
            for i,pos in ipairs(data.coords) do
                if not farmV1On then break end
                local fp=Vector3.new(pos.X, pos.Y+refs.getHeight(), pos.Z)
                -- Update vector hit ke koordinat titik ini
                currentFarmVec=fp
                moveTo(fp,refs.getSpeed())
                tryAutoQuest()
                task.wait(refs.getTD())
            end
            if not farmV1On then break end
            local ld=refs.getLD()
            if ld>0 then
                local endT=tick()+ld
                while tick()<endT and farmV1On do
                    tryAutoQuest(); task.wait(0.5)
                end
            end
        end

        farmTeardown(); _G.islandFarmOn=false; isRunningV1=false
        if refs then refs.setFarmOnOff(false) end
    end

    -- =====================
    -- FARM V2
    -- currentFarmVec = koordinat titik tengah pulau
    -- =====================
    local function farmLoopV2()
        isRunningV2=true
        if not farmV2On then
            isRunningV2=false
            if refs then refs.setFarmOnOff(false) end
            return
        end
        _G.islandFarmOn=true
        local island=refs.getIsland(); farmSetup(island)
        if refs.getAutoHitOn and refs.getAutoHitOn() then startFarmHitSpam() end
        startAbilityLoop(function() return farmV2On end)

        while farmV2On do
            island=refs.getIsland(); local data=ISLANDS[island]
            if not data then task.wait(1); continue end
            local ci=data.center; local cpos=data.coords[ci]
            local fp=Vector3.new(cpos.X, cpos.Y+refs.getHeight(), cpos.Z)
            -- Update vector hit ke titik tengah
            currentFarmVec=fp
            moveTo(fp,refs.getSpeed())
            tryAutoQuest()
            local ld=refs.getLD()
            if ld>0 then
                local endT=tick()+ld
                while tick()<endT and farmV2On do
                    tryAutoQuest(); task.wait(0.5)
                end
            else task.wait(0.5) end
        end

        farmTeardown(); _G.islandFarmOn=false; isRunningV2=false
        if refs then refs.setFarmOnOff(false) end
    end

    task.spawn(function()
        local wasV1,wasV2=false,false
        while task.wait(0.2) do
            if farmV1On and not wasV1 then
                farmV2On=false; if not isRunningV1 then task.spawn(farmLoopV1) end
            elseif not farmV1On and wasV1 then disableFly(); disableGS() end
            if farmV2On and not wasV2 then
                farmV1On=false; if not isRunningV2 then task.spawn(farmLoopV2) end
            elseif not farmV2On and wasV2 then disableFly(); disableGS() end
            wasV1=farmV1On; wasV2=farmV2On
        end
    end)

    -- =====================
    -- STANDALONE AUTO HIT (toggle di bawah Auto Farm)
    -- Pakai vector NPC terdekat, sama seperti dungeon
    -- Aktif hanya saat farm TIDAK berjalan
    -- =====================
    task.spawn(function()
        while true do
            task.wait(0.2)
            local hitOn=refs and refs.getAutoHitOn and refs.getAutoHitOn()
            if hitOn and not _G.islandFarmOn then
                -- Farm tidak jalan, gunakan nearest NPC
                if not npcHitRunning then startNearestHitSpam() end
            else
                -- Farm jalan (farm yang handle via currentFarmVec)
                -- atau toggle off → stop nearest hit
                if npcHitRunning then stopNearestHitSpam() end
            end
        end
    end)

    -- Boss Kill
    local bossKillOn=false; local bossFlyBP,bossFlyBG=nil,nil
    local function enableBossFly()
        local r=getRoot()
        local h=character and character:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end; h.PlatformStand=true
        if bossFlyBP then bossFlyBP:Destroy() end
        if bossFlyBG then bossFlyBG:Destroy() end
        bossFlyBP=Instance.new("BodyPosition")
        bossFlyBP.MaxForce=Vector3.new(1e5,1e5,1e5); bossFlyBP.D=600; bossFlyBP.P=6000
        bossFlyBP.Position=r.Position; bossFlyBP.Parent=r
        bossFlyBG=Instance.new("BodyGyro")
        bossFlyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); bossFlyBG.D=500
        bossFlyBG.CFrame=r.CFrame; bossFlyBG.Parent=r
    end
    local function disableBossFly()
        if bossFlyBP then bossFlyBP:Destroy(); bossFlyBP=nil end
        if bossFlyBG then bossFlyBG:Destroy(); bossFlyBG=nil end
        local h=character and character:FindFirstChildOfClass("Humanoid")
        if h and not _G.islandFarmOn then h.PlatformStand=false end
    end
    local function getBossPart(npcName)
        -- Cari di workspace.NPCs dulu
        local npcs=workspace:FindFirstChild("NPCs")
        if npcs then
            local folder=npcs:FindFirstChild(npcName)
            if folder then
                if folder:IsA("Model") then
                    return folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart",true)
                elseif folder:IsA("BasePart") then return folder end
            end
        end
        -- Fallback: recursive workspace search
        local found=workspace:FindFirstChild(npcName,true)
        if found then
            if found:IsA("Model") then
                return found.PrimaryPart or found:FindFirstChildWhichIsA("BasePart",true)
            elseif found:IsA("BasePart") then return found end
        end
        return nil
    end

    local function bossKillLoop()
        local bossName=refs.getSelectedBoss()
        if not bossName then
            refs.setBossStat("Pilih boss dulu!",T.red); refs.setBossOnOff(false); bossKillOn=false; return
        end
        local data=getBossData(bossName)
        if not data then
            refs.setBossStat("Data tidak ditemukan!",T.red); refs.setBossOnOff(false); bossKillOn=false; return
        end
        local npcName=data.npc; local bossCoord=data.coord; local tpLoc=data.tpLoc
        if tpLoc then
            refs.setBossPhase("Teleporting...",T.amber); refs.setBossStat("TP ke "..tpLoc,T.amber)
            fireTP(tpLoc)
            for i=3,1,-1 do
                if not bossKillOn then disableBossFly(); refs.setBossOnOff(false); return end
                refs.setBossStat("Loading "..i.."s",T.amber); task.wait(1)
            end
        end
        if not bossKillOn then disableBossFly(); refs.setBossOnOff(false); return end
        enableBossFly(); refs.setBossPhase("Mendekat...",T.accentGlow)
      local function moveToBoss(targetPos)
    local rr=getRoot(); if not rr then return end
    local dist=(rr.Position-targetPos).Magnitude
    if dist>500 then
        rr.CFrame=CFrame.new(targetPos)
        if bossFlyBP then bossFlyBP.Position=targetPos end
        task.wait(0.3)
    else
        local speed=refs.getSpeed and refs.getSpeed() or 150
        local dur=math.max(0.3,dist/speed)
        if bossFlyBP then bossFlyBP.Position=targetPos end
        local tw=TweenService:Create(rr,TweenInfo.new(dur,Enum.EasingStyle.Linear),
            {CFrame=CFrame.new(targetPos)})
        tw:Play(); tw.Completed:Wait()
    end
end

local r=getRoot()
if r then moveToBoss(bossCoord+Vector3.new(0,5,0)) end
task.wait(0.3)

        -- Boss hit: vector.create dari posisi boss, diperbarui tiap iterasi
        local bossHitRun=true
        task.spawn(function()
            while bossHitRun and bossKillOn do
                local bossPart=getBossPart(npcName)
                if bossPart then
                    -- Gunakan posisi boss terkini
                    fireHitAt(bossPart.Position)
                end
                task.wait()
            end
        end)

        refs.setBossPhase("Menyerang",T.green)
        while bossKillOn do
            local bossPart=getBossPart(npcName)
            if not bossPart then
                refs.setBossStat(npcName.." selesai!",T.green)
                refs.setBossPhase("Boss hilang",T.green)
                break
            end
            local rr=getRoot(); if not rr then task.wait(0.2); continue end
            local bossPos=bossPart.Position
            local dist=(rr.Position-bossPos).Magnitude
            refs.setBossStat(npcName.." | "..math.floor(dist).."st",T.green)
            local target=bossPos+Vector3.new(0,3,0)
            if bossFlyBP then bossFlyBP.Position=target end
            if dist>4 then
                TweenService:Create(rr,TweenInfo.new(math.clamp(dist/20,0.8,3.5),Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
    {CFrame=CFrame.new(target)}):Play()
            end
            task.wait(0.15)
        end
        bossHitRun=false; disableBossFly()
        refs.setBossStat("Idle",T.textDim); refs.setBossPhase("--",T.textDim)
        refs.setBossOnOff(false); bossKillOn=false
    end

    -- =====================
    -- DUNGEON
    -- Hit: vector.create dari posisi NPC terdekat (diperbarui tiap task.wait)
    -- Tween: mendekat ke NPC terdekat tiap siklus
    -- =====================
    local dungeonOn=false; local dungeonHitRun=false; local activeDungeonTween=nil

    local function dungeonLoop()
        dungeonHitRun=true

        -- Hit loop: terus-menerus fire ke NPC terdekat
        task.spawn(function()
            local count=0; local lastT=tick()
            while dungeonHitRun do
                local pos=getNearestNPCPosition()
                if pos then
                    -- vector.create dari posisi NPC terdekat
                    fireHitAt(pos)
                    count=count+1
                end
                if tick()-lastT>=0.5 then
                    refs.setDungeonHit(tostring(count*2).."/s",T.green)
                    count=0; lastT=tick()
                end
                task.wait()
            end
            refs.setDungeonHit("0/s",T.textDim)
        end)

        startAbilityLoop(function() return dungeonOn end)

        -- Tween loop: tween ke NPC terdekat tiap siklus
        task.spawn(function()
            while dungeonOn do
                local npc=getNearestNPCModel()
                if not npc or not npc.Parent then task.wait(0.3); continue end
                local part=(npc:IsA("BasePart") and npc)
                    or (npc:IsA("Model") and (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart",true)))
                if not part then task.wait(0.3); continue end
                local r=getRoot(); if not r then task.wait(0.2); continue end
                refs.setDungeonStat("Running",T.green)
                refs.setDungeonNPC(npc.Name,T.accentGlow)
                local target=part.Position+Vector3.new(0,2,0)
                local dist=(r.Position-target).Magnitude
                if activeDungeonTween then pcall(function() activeDungeonTween:Cancel() end) end
                activeDungeonTween=TweenService:Create(r,
                    TweenInfo.new(math.max(0.15,dist/100),Enum.EasingStyle.Linear),
                    {CFrame=CFrame.new(target)})
                activeDungeonTween:Play()
                local elapsed=0
                while elapsed<1 and dungeonOn and npc and npc.Parent do
                    task.wait(0.1); elapsed=elapsed+0.1
                end
                pcall(function()
                    if activeDungeonTween then activeDungeonTween:Cancel(); activeDungeonTween=nil end
                end)
                task.wait(0.05)
            end
            refs.setDungeonStat("Idle",T.textDim)
            refs.setDungeonNPC("--",T.textDim)
        end)
    end

    -- Callbacks
    refs.setFarmCallback(function(v)
        local mode=refs.getFarmMode()
        if v then
            if mode=="V2 - Titik Tengah" then farmV2On=true; farmV1On=false
            else farmV1On=true; farmV2On=false end
        else
            farmV1On=false; farmV2On=false; stopFarmHitSpam()
        end
    end)

    refs.setBossCallback(function(v)
        bossKillOn=v
        if v then task.spawn(bossKillLoop)
        else
            bossKillOn=false; disableBossFly()
            refs.setBossStat("Idle",T.textDim); refs.setBossPhase("--",T.textDim)
        end
    end)

    refs.setDungeonCallback(function(v)
        dungeonOn=v
        if v then task.spawn(dungeonLoop)
        else
            dungeonOn=false; dungeonHitRun=false
            if activeDungeonTween then
                pcall(function() activeDungeonTween:Cancel(); activeDungeonTween=nil end)
            end
            refs.setDungeonStat("Idle",T.textDim)
            refs.setDungeonNPC("--",T.textDim)
            refs.setDungeonHit("0/s",T.textDim)
        end
    end)
end
