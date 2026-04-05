-- ╔══════════════════════════════════╗
-- ║  YiDaMuSake — Logic Layer  v7   ║
-- ╚══════════════════════════════════╝
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer

local ISLANDS = {
    ["Starter Island"]   = {coords={Vector3.new(194.943,16.207,-171.994),Vector3.new(164.245,16.207,-176.308),Vector3.new(159.530,16.207,-142.758),Vector3.new(177.723,16.207,-157.247),Vector3.new(189.238,16.207,-138.583)},center=4},
    ["Jungle Island"]    = {coords={Vector3.new(-566.029,4.125,425.000),Vector3.new(-567.759,4.125,399.303),Vector3.new(-585.790,3.359,397.131),Vector3.new(-575.712,3.359,381.006),Vector3.new(-549.771,4.125,395.209)},center=2},
    ["Desert Island"]    = {coords={Vector3.new(-774.852,0.777,-405.228),Vector3.new(-793.225,0.777,-433.599),Vector3.new(-768.626,0.777,-452.058),Vector3.new(-815.452,0.777,-417.817),Vector3.new(-808.365,0.777,-457.034)},center=2},
    ["Snow Island"]      = {coords={Vector3.new(-423.471,3.861,-968.619),Vector3.new(-436.772,3.859,-998.843),Vector3.new(-410.853,3.861,-990.573),Vector3.new(-402.983,3.861,-1014.348),Vector3.new(-385.389,3.861,-981.637)},center=3},
    ["Shibuya"]          = {coords={Vector3.new(1407.890,13.486,522.877),Vector3.new(1435.052,13.839,480.898),Vector3.new(1398.259,13.486,488.059),Vector3.new(1362.940,13.486,493.791),Vector3.new(1390.117,13.486,451.823)},center=3},
    ["Hollow"]           = {coords={Vector3.new(-341.802,4.559,1091.144),Vector3.new(-365.126,4.559,1097.683),Vector3.new(-358.324,4.559,1078.029),Vector3.new(-385.284,5.201,1082.955),Vector3.new(-383.171,4.559,1110.780)},center=2},
    ["Shinjuku Island#1"]= {coords={Vector3.new(684.111,1.882,-1715.860),Vector3.new(687.366,1.882,-1674.726),Vector3.new(654.620,1.882,-1733.495),Vector3.new(666.407,1.882,-1695.736),Vector3.new(650.193,1.882,-1671.640)},center=4},
    ["Shinjuku Island#2"]= {coords={Vector3.new(-41.329,1.880,-1816.006),Vector3.new(4.006,1.796,-1864.215),Vector3.new(-18.397,1.835,-1845.567),Vector3.new(-3.303,1.877,-1810.039),Vector3.new(-26.961,1.862,-1875.934)},center=3},
    ["Slime"]            = {coords={Vector3.new(-1144.351,18.917,364.112),Vector3.new(-1111.960,13.918,354.755),Vector3.new(-1124.753,13.918,371.231),Vector3.new(-1136.075,21.067,388.744),Vector3.new(-1103.583,13.918,379.100)},center=3},
    ["Academy"]          = {coords={Vector3.new(1074.662,2.370,1250.483),Vector3.new(1046.124,1.463,1252.839),Vector3.new(1072.546,1.778,1275.642),Vector3.new(1095.647,1.463,1296.464),Vector3.new(1058.373,1.463,1297.346)},center=3},
    ["Judgement"]        = {coords={Vector3.new(-1268.647,1.307,-1161.301),Vector3.new(-1296.867,1.157,-1201.466),Vector3.new(-1240.514,1.138,-1176.326),Vector3.new(-1274.657,1.173,-1191.390),Vector3.new(-1260.848,1.333,-1219.831)},center=4},
    ["Soul Dominion"]    = {coords={Vector3.new(-1331.364,1603.565,1567.672),Vector3.new(-1314.989,1603.565,1595.409),Vector3.new(-1373.717,1604.229,1618.792),Vector3.new(-1339.529,1603.565,1617.110),Vector3.new(-1374.362,1603.551,1584.912)},center=4},
    ["Ninja"]            = {coords={Vector3.new(-1859.595,8.505,-753.854),Vector3.new(-1895.911,8.503,-724.515),Vector3.new(-1852.629,8.552,-718.633),Vector3.new(-1876.007,8.501,-738.603),Vector3.new(-1907.969,8.497,-748.339)},center=4},
    ["Lawless"]          = {coords={Vector3.new(47.442,-0.995,1793.444),Vector3.new(59.851,0.579,1816.135),Vector3.new(38.152,-0.196,1817.528),Vector3.new(68.066,-0.262,1801.037),Vector3.new(50.611,-0.448,1843.215)},center=2},
}

-- Boss → TP location mapping (keyword match, case-insensitive)
local BOSS_TP_MAP = {
    {match={"jinwoo","alucard"},         loc="Starter"},
    {match={"yuji","gojo","sukuna"},     loc="Shibuya"},
    {match={"aizen"},                    loc="HollowIsland"},
    {match={"yamato"},                   loc="Judgement"},
    {match={"shinobi"},                  loc="Ninja"},
}

local function getBossTPLoc(bossName)
    local lower=bossName:lower()
    for _,entry in ipairs(BOSS_TP_MAP) do
        for _,kw in ipairs(entry.match) do
            if lower:find(kw,1,true) then return entry.loc end
        end
    end
    return nil
end

return function(refs, T)
    local character=player.Character or player.CharacterAdded:Wait()

    local function getRoot()
        character=player.Character
        if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart")
    end

    local function fireSettings(k,v)
        pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents")
                :WaitForChild("SettingsToggle"):FireServer(k,v)
        end)
    end
    local function enableGS()
        fireSettings("EnableQuestRepeat",true)
        fireSettings("AutoQuestRepeat",true)
        fireSettings("DisablePVP",true)
    end
    local function disableGS()
        fireSettings("EnableQuestRepeat",false)
        fireSettings("AutoQuestRepeat",false)
        fireSettings("DisablePVP",false)
    end

    -- ── REMOTE CACHE ──────────────────────────────────────
    local requestHitRemote=nil
    local function getHitRemote()
        if requestHitRemote then return requestHitRemote end
        local ok,r=pcall(function()
            return ReplicatedStorage
                :WaitForChild("CombatSystem",5)
                :WaitForChild("Remotes",5)
                :WaitForChild("RequestHit",5)
        end)
        if ok and r then requestHitRemote=r end
        return requestHitRemote
    end

    local abilityRemote=nil
    local function getAbilityRemote()
        if abilityRemote then return abilityRemote end
        local ok,r=pcall(function()
            return ReplicatedStorage
                :WaitForChild("AbilitySystem",5)
                :WaitForChild("Remotes",5)
                :WaitForChild("RequestAbility",5)
        end)
        if ok and r then abilityRemote=r end
        return abilityRemote
    end

    -- ── HRP SPIN (360°, kamera tidak ikut) ────────────────
    -- Rotasi hanya pada HumanoidRootPart + update BodyGyro.
    -- Camera tidak di-touch, jadi posisinya tetap.
    local spinBusy=false
    local function doSpin(checkFn)
        if spinBusy then return end
        spinBusy=true
        task.spawn(function()
            local steps=24  -- 360/24 = 15° per step, ~0.6s total
            for i=1,steps do
                if not checkFn() then break end
                local r=getRoot(); if not r then break end
                local pos=r.Position
                local angle=(i/steps)*math.pi*2
                -- Rotate hanya HRP, jangan touch camera
                local newCF=CFrame.new(pos)*CFrame.fromEulerAnglesYXZ(0,angle,0)
                r.CFrame=newCF
                -- Sync BodyGyro agar tidak fight rotation
                if flyBP then flyBP.Position=pos end
                if flyBG then flyBG.CFrame=newCF end
                task.wait(0.025)
            end
            spinBusy=false
        end)
    end

    -- ── FLY (farm) ─────────────────────────────────────────
    local flyBP,flyBG=nil,nil
    local function enableFly()
        character=player.Character; if not character then return end
        local r=character:FindFirstChild("HumanoidRootPart")
        local h=character:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end
        h.PlatformStand=true
        if flyBP then flyBP:Destroy() end
        if flyBG then flyBG:Destroy() end
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
        character=nc
        if _G.islandFarmOn then task.wait(1); enableFly() end
    end)

    -- ── MOVEMENT ──────────────────────────────────────────
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

    -- ── AUTO HIT (spam RequestHit) ─────────────────────────
    local hitRunning=false
    local function startHit()
        if hitRunning then return end
        hitRunning=true
        task.spawn(function()
            local remote=getHitRemote()
            if not remote then
                refs.setHitStat("Remote tidak ditemukan!",T.red)
                hitRunning=false; refs.setHitOnOff(false); return
            end
            local count=0; local lastT=tick()
            while hitRunning do
                pcall(function() remote:FireServer() end)
                count=count+1
                if tick()-lastT>=0.5 then
                    refs.setHitRate(tostring(count*2).."/s",T.green)
                    count=0; lastT=tick()
                end
                task.wait()
            end
            refs.setHitRate("0/s",T.textDim)
        end)
    end
    local function stopHit() hitRunning=false end

    -- ── ABILITY FIRE + SPIN (farm & dungeon) ───────────────
    -- Fires RequestAbility args 1,2,3 every 2s + spins HRP.
    -- checkFn returns true while feature is active.
    local function startAbilityLoop(checkFn)
        task.spawn(function()
            local remote=getAbilityRemote()
            while checkFn() do
                -- Spin HRP (async, camera tidak ikut)
                doSpin(checkFn)
                -- Fire ability 1, 2, 3
                if remote then
                    for _,arg in ipairs({1,2,3}) do
                        if not checkFn() then break end
                        pcall(function() remote:FireServer(arg) end)
                    end
                end
                task.wait(2)
            end
        end)
    end

    -- ── AUTO QUEST (dalam farm, radius 100 studs) ──────────
    local lastQuestNPC=nil
    local function fireQuestAccept(name)
        pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents")
                :WaitForChild("QuestAccept"):FireServer(name)
        end)
    end
    local function tryAutoQuest()
        local r=getRoot(); if not r then return end
        local svc=workspace:FindFirstChild("ServiceNPCs"); if not svc then return end
        for i=1,19 do
            local name="QuestNPC"..i
            local npc=svc:FindFirstChild(name)
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
                        refs.setFarmNPC(name,T.accentGlow)
                    end
                    return
                end
            end
        end
    end

    -- ── STATE ─────────────────────────────────────────────
    local farmV1On=false; local farmV2On=false
    local isRunningV1=false; local isRunningV2=false
    _G.islandFarmOn=false

    -- ── FARM V1 ───────────────────────────────────────────
    local function farmLoopV1()
        isRunningV1=true; _G.islandFarmOn=true
        enableFly(); enableGS()
        lastQuestNPC=nil
        -- Start ability loop in parallel
        startAbilityLoop(function() return farmV1On end)
        while farmV1On do
            local island=refs.getIsland(); local data=ISLANDS[island]
            if not data then refs.setFarmStat("Pulau tidak dikenali!",T.red); task.wait(1); continue end
            local coords=data.coords
            for i,pos in ipairs(coords) do
                if not farmV1On then break end
                local fp=Vector3.new(pos.X,pos.Y+refs.getHeight(),pos.Z)
                local r=getRoot(); local dist=r and (r.Position-fp).Magnitude or 0
                refs.setFarmStat(island.." ["..i.."/"..#coords.."] "
                    ..(dist>80 and "Tween" or "TP"),T.green)
                refs.setFarmPhase((dist>80 and "Tween " or "TP ")..math.floor(dist).."st")
                moveTo(fp,refs.getSpeed())
                tryAutoQuest()   -- check quest NPC after arriving
                task.wait(refs.getTD())
            end
            if not farmV1On then break end
            local ld=refs.getLD()
            if ld>0 then
                local endT=tick()+ld
                while tick()<endT and farmV1On do
                    refs.setFarmStat("Cooldown "..math.ceil(endT-tick()).."s",T.amber)
                    refs.setFarmPhase("Next loop...")
                    tryAutoQuest()
                    task.wait(0.5)
                end
            end
        end
        disableFly(); disableGS()
        refs.setFarmStat("Idle",T.textDim); refs.setFarmPhase("--"); refs.setFarmNPC("--",T.textDim)
        _G.islandFarmOn=false; isRunningV1=false
        refs.setFarmOnOff(false)
    end

    -- ── FARM V2 ───────────────────────────────────────────
    local function farmLoopV2()
        isRunningV2=true; _G.islandFarmOn=true
        enableFly(); enableGS()
        lastQuestNPC=nil
        startAbilityLoop(function() return farmV2On end)
        while farmV2On do
            local island=refs.getIsland(); local data=ISLANDS[island]
            if not data then refs.setFarmStat("Pulau tidak dikenali!",T.red); task.wait(1); continue end
            local ci=data.center; local cpos=data.coords[ci]
            local fp=Vector3.new(cpos.X,cpos.Y+refs.getHeight(),cpos.Z)
            local r=getRoot(); local dist=r and (r.Position-fp).Magnitude or 0
            refs.setFarmStat(island.." [c:"..ci.."] "..(dist>80 and "Tween" or "TP"),T.green)
            refs.setFarmPhase("Titik tengah ["..ci.."]")
            moveTo(fp,refs.getSpeed())
            tryAutoQuest()
            local ld=refs.getLD()
            if ld>0 then
                local endT=tick()+ld
                while tick()<endT and farmV2On do
                    refs.setFarmStat(island.." [c:"..ci.."] "..math.ceil(endT-tick()).."s",T.green)
                    tryAutoQuest()
                    task.wait(0.5)
                end
            else task.wait(0.5) end
        end
        disableFly(); disableGS()
        refs.setFarmStat("Idle",T.textDim); refs.setFarmPhase("--"); refs.setFarmNPC("--",T.textDim)
        _G.islandFarmOn=false; isRunningV2=false
        refs.setFarmOnOff(false)
    end

    -- ── FARM WATCHER ──────────────────────────────────────
    task.spawn(function()
        local wasV1,wasV2=false,false
        while task.wait(0.2) do
            if farmV1On and not wasV1 then
                farmV2On=false
                if not isRunningV1 then task.spawn(farmLoopV1) end
            elseif not farmV1On and wasV1 then disableFly(); disableGS() end
            if farmV2On and not wasV2 then
                farmV1On=false
                if not isRunningV2 then task.spawn(farmLoopV2) end
            elseif not farmV2On and wasV2 then disableFly(); disableGS() end
            wasV1=farmV1On; wasV2=farmV2On
        end
    end)

    -- ── AUTO SKILL Z/X/C/V (persistent, independent) ──────
    -- Runs forever, checks refs.getSkillOn each frame
    task.spawn(function()
        local skillDefs={{key="Z",arg=1},{key="X",arg=2},{key="C",arg=3},{key="V",arg=4}}
        while true do
            local remote=getAbilityRemote()
            if remote then
                for _,s in ipairs(skillDefs) do
                    if refs.getSkillOn(s.key) then
                        pcall(function() remote:FireServer(s.arg) end)
                    end
                end
            end
            task.wait()  -- minimum (1 frame)
        end
    end)

    -- ── BOSS KILL ─────────────────────────────────────────
    local bossKillOn=false
    local bossFlyBP,bossFlyBG=nil,nil

    local function getBossPart(bossName)
        if not bossName then return nil end
        local npcs=workspace:FindFirstChild("NPCs"); if not npcs then return nil end
        local folder=npcs:FindFirstChild(bossName); if not folder then return nil end
        return folder.PrimaryPart
            or folder:FindFirstChildWhichIsA("BasePart",true)
    end

    local function enableBossFly()
        local r=getRoot()
        local h=character and character:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end
        h.PlatformStand=true
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

    local function bossKillLoop()
        local bossName=refs.getSelectedBoss()
        if not bossName then
            refs.setBossStat("Pilih boss dulu!",T.red)
            refs.setBossOnOff(false); bossKillOn=false; return
        end

        -- Step 1: TP ke lokasi boss
        local tpLoc=getBossTPLoc(bossName)
        if tpLoc then
            refs.setBossStat("TP ke "..tpLoc.."...",T.amber)
            refs.setBossPhase("Teleporting",T.amber)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                    :WaitForChild("TeleportToPortal"):FireServer(tpLoc)
            end)
            -- Tunggu load (3s)
            for i=3,1,-1 do
                if not bossKillOn then return end
                refs.setBossStat("Menunggu TP… "..i.."s",T.amber)
                task.wait(1)
            end
        end

        if not bossKillOn then return end

        -- Step 2: Enable fly + spam RequestHit
        enableBossFly()
        refs.setBossPhase("Approaching",T.accentGlow)

        local bossHitRunning=true
        task.spawn(function()
            local remote=getHitRemote()
            while bossHitRunning and bossKillOn do
                if remote then pcall(function() remote:FireServer() end) end
                task.wait()
            end
        end)

        -- Step 3: Tween ke boss sampai mati
        while bossKillOn do
            local bossPart=getBossPart(bossName)
            if not bossPart then
                refs.setBossStat("Boss mati / tidak ada",T.red)
                refs.setBossPhase("Done",T.green)
                break
            end
            local r=getRoot()
            if not r then task.wait(0.3); continue end
            local bossPos=bossPart.Position
            local dist=(r.Position-bossPos).Magnitude
            refs.setBossStat(bossName.." | "..math.floor(dist).."st",T.green)
            -- Tween ke boss 70 st/s
            local target=bossPos+Vector3.new(0,3,0)
            if bossFlyBP then bossFlyBP.Position=target end
            if dist>5 then
                local dur=math.clamp(dist/70,0.06,0.8)
                TweenService:Create(r,TweenInfo.new(dur,Enum.EasingStyle.Linear),
                    {CFrame=CFrame.new(target)}):Play()
            end
            task.wait(0.15)
        end

        bossHitRunning=false
        disableBossFly()
        refs.setBossStat("Idle",T.textDim)
        refs.setBossPhase("--",T.textDim)
        refs.setBossOnOff(false)
    end

    -- ── DUNGEON ───────────────────────────────────────────
    local dungeonOn=false
    local dungeonHitRun=false
    local activeDungeonTween=nil

    local function dungeonLoop()
        -- Spam RequestHit
        dungeonHitRun=true
        task.spawn(function()
            local remote=getHitRemote()
            if not remote then
                refs.setDungeonStat("Remote tidak ditemukan!",T.red)
                dungeonHitRun=false; dungeonOn=false
                refs.setDungeonOnOff(false); return
            end
            local count=0; local lastT=tick()
            while dungeonHitRun do
                pcall(function() remote:FireServer() end)
                count=count+1
                if tick()-lastT>=0.5 then
                    refs.setDungeonHit(tostring(count*2).."/s",T.green)
                    count=0; lastT=tick()
                end
                task.wait()
            end
            refs.setDungeonHit("0/s",T.textDim)
        end)

        -- Ability 1,2,3 + spin every 2s
        startAbilityLoop(function() return dungeonOn end)

        -- Tween ke setiap NPC
        task.spawn(function()
            while dungeonOn do
                local npcsFolder=workspace:FindFirstChild("NPCs")
                if not npcsFolder then
                    refs.setDungeonStat("NPCs tidak ada",T.red); task.wait(1); continue
                end
                local npcList=npcsFolder:GetChildren()
                if #npcList==0 then
                    refs.setDungeonStat("Tidak ada NPC",T.textDim); task.wait(0.5); continue
                end
                refs.setDungeonStat("Running — "..#npcList.." NPC",T.green)
                for _,npc in ipairs(npcList) do
                    if not dungeonOn then break end
                    if not npc or not npc.Parent then continue end
                    local part=(npc:IsA("BasePart") and npc)
                        or npc.PrimaryPart
                        or npc:FindFirstChildWhichIsA("BasePart",true)
                    if not part then continue end
                    local r=getRoot(); if not r then break end
                    refs.setDungeonNPC(npc.Name,T.green)
                    -- Tween ke NPC
                    local target=part.Position+Vector3.new(0,2,0)
                    local dist=(r.Position-target).Magnitude
                    local dur=math.max(0.2,dist/100)
                    if activeDungeonTween then
                        pcall(function() activeDungeonTween:Cancel() end)
                    end
                    activeDungeonTween=TweenService:Create(r,
                        TweenInfo.new(dur,Enum.EasingStyle.Linear),
                        {CFrame=CFrame.new(target)})
                    activeDungeonTween:Play()
                    -- Tunggu 1 detik atau NPC hilang
                    local elapsed=0
                    while elapsed<1 and dungeonOn and npc and npc.Parent do
                        task.wait(0.1); elapsed=elapsed+0.1
                    end
                    pcall(function()
                        if activeDungeonTween then
                            activeDungeonTween:Cancel(); activeDungeonTween=nil
                        end
                    end)
                end
            end
            refs.setDungeonStat("Idle",T.textDim); refs.setDungeonNPC("--",T.textDim)
        end)
    end

    -- ── CALLBACKS ─────────────────────────────────────────
    refs.setFarmCallback(function(v)
        local mode=refs.getFarmMode()
        if v then
            if mode=="V2 - Titik Tengah" then farmV2On=true; farmV1On=false
            else farmV1On=true; farmV2On=false end
            refs.setFarmStat("Starting...",T.amber)
        else
            farmV1On=false; farmV2On=false
            refs.setFarmStat("Idle",T.textDim); refs.setFarmPhase("--")
            refs.setFarmNPC("--",T.textDim); lastQuestNPC=nil
        end
    end)

    refs.setHitCallback(function(v)
        if v then startHit(); refs.setHitStat("Running",T.green)
        else stopHit(); refs.setHitStat("Idle",T.textDim) end
    end)

    refs.setBossCallback(function(v)
        bossKillOn=v
        if v then
            refs.setBossStat("Starting...",T.amber)
            task.spawn(bossKillLoop)
        else
            bossKillOn=false
            disableBossFly()
            refs.setBossStat("Idle",T.textDim)
            refs.setBossPhase("--",T.textDim)
        end
    end)

    refs.setDungeonCallback(function(v)
        dungeonOn=v
        if v then
            refs.setDungeonStat("Starting...",T.amber)
            task.spawn(dungeonLoop)
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
