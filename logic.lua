-- ╔══════════════════════════════════╗
-- ║  YiDaMuSake — Logic Layer  v6   ║
-- ╚══════════════════════════════════╝
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer

-- =====================
-- ISLAND DATA
-- center = index titik yang paling dekat dengan centroid kelima titik
-- =====================
local ISLANDS = {
    ["Starter Island"] = {
        coords={
            Vector3.new(194.943,16.207,-171.994),
            Vector3.new(164.245,16.207,-176.308),
            Vector3.new(159.530,16.207,-142.758),
            Vector3.new(177.723,16.207,-157.247),
            Vector3.new(189.238,16.207,-138.583),
        }, center=4,
    },
    ["Jungle Island"] = {
        coords={
            Vector3.new(-566.029,4.125,425.000),
            Vector3.new(-567.759,4.125,399.303),
            Vector3.new(-585.790,3.359,397.131),
            Vector3.new(-575.712,3.359,381.006),
            Vector3.new(-549.771,4.125,395.209),
        }, center=2,
    },
    ["Desert Island"] = {
        coords={
            Vector3.new(-774.852,0.777,-405.228),
            Vector3.new(-793.225,0.777,-433.599),
            Vector3.new(-768.626,0.777,-452.058),
            Vector3.new(-815.452,0.777,-417.817),
            Vector3.new(-808.365,0.777,-457.034),
        }, center=2,
    },
    ["Snow Island"] = {
        coords={
            Vector3.new(-423.471,3.861,-968.619),
            Vector3.new(-436.772,3.859,-998.843),
            Vector3.new(-410.853,3.861,-990.573),
            Vector3.new(-402.983,3.861,-1014.348),
            Vector3.new(-385.389,3.861,-981.637),
        }, center=3,
    },
    ["Shibuya"] = {
        coords={
            Vector3.new(1407.890,13.486,522.877),
            Vector3.new(1435.052,13.839,480.898),
            Vector3.new(1398.259,13.486,488.059),
            Vector3.new(1362.940,13.486,493.791),
            Vector3.new(1390.117,13.486,451.823),
        }, center=3,
    },
    ["Hollow"] = {
        coords={
            Vector3.new(-341.802,4.559,1091.144),
            Vector3.new(-365.126,4.559,1097.683),
            Vector3.new(-358.324,4.559,1078.029),
            Vector3.new(-385.284,5.201,1082.955),
            Vector3.new(-383.171,4.559,1110.780),
        }, center=2,
    },
    ["Shinjuku Island#1"] = {
        -- StrongSorcerer1-5 | center=4 (dist 3.33)
        coords={
            Vector3.new(684.111,1.882,-1715.860),
            Vector3.new(687.366,1.882,-1674.726),
            Vector3.new(654.620,1.882,-1733.495),
            Vector3.new(666.407,1.882,-1695.736),
            Vector3.new(650.193,1.882,-1671.640),
        }, center=4,
    },
    ["Shinjuku Island#2"] = {
        -- Curse1-5 | center=3 (dist 3.43)
        coords={
            Vector3.new(-41.329,1.880,-1816.006),
            Vector3.new(4.006,1.796,-1864.215),
            Vector3.new(-18.397,1.835,-1845.567),
            Vector3.new(-3.303,1.877,-1810.039),
            Vector3.new(-26.961,1.862,-1875.934),
        }, center=3,
    },
    ["Slime"] = {
        -- Slime1-5 | center=3 (dist 0.71 — paling akurat)
        coords={
            Vector3.new(-1144.351,18.917,364.112),
            Vector3.new(-1111.960,13.918,354.755),
            Vector3.new(-1124.753,13.918,371.231),
            Vector3.new(-1136.075,21.067,388.744),
            Vector3.new(-1103.583,13.918,379.100),
        }, center=3,
    },
    ["Academy"] = {
        -- AcademyTeacher1-5 | center=3 (dist 3.26)
        coords={
            Vector3.new(1074.662,2.370,1250.483),
            Vector3.new(1046.124,1.463,1252.839),
            Vector3.new(1072.546,1.778,1275.642),
            Vector3.new(1095.647,1.463,1296.464),
            Vector3.new(1058.373,1.463,1297.346),
        }, center=3,
    },
    ["Judgement"] = {
        -- Swordsman1-5 | center=4 (dist 6.49)
        coords={
            Vector3.new(-1268.647,1.307,-1161.301),
            Vector3.new(-1296.867,1.157,-1201.466),
            Vector3.new(-1240.514,1.138,-1176.326),
            Vector3.new(-1274.657,1.173,-1191.390),
            Vector3.new(-1260.848,1.333,-1219.831),
        }, center=4,
    },
    ["Soul Dominion"] = {
        -- Quincy1-5 | center=4 (dist 21.59)
        coords={
            Vector3.new(-1331.364,1603.565,1567.672),
            Vector3.new(-1314.989,1603.565,1595.409),
            Vector3.new(-1373.717,1604.229,1618.792),
            Vector3.new(-1339.529,1603.565,1617.110),
            Vector3.new(-1374.362,1603.551,1584.912),
        }, center=4,
    },
    ["Ninja"] = {
        -- Ninja1-5 | center=4 (dist 3.02)
        coords={
            Vector3.new(-1859.595,8.505,-753.854),
            Vector3.new(-1895.911,8.503,-724.515),
            Vector3.new(-1852.629,8.552,-718.633),
            Vector3.new(-1876.007,8.501,-738.603),
            Vector3.new(-1907.969,8.497,-748.339),
        }, center=4,
    },
    ["Lawless"] = {
        -- ArenaFighter1-5 | center=2 (dist 7.27)
        coords={
            Vector3.new(47.442,-0.995,1793.444),
            Vector3.new(59.851,0.579,1816.135),
            Vector3.new(38.152,-0.196,1817.528),
            Vector3.new(68.066,-0.262,1801.037),
            Vector3.new(50.611,-0.448,1843.215),
        }, center=2,
    },
}

-- =====================
-- MAIN FUNCTION
-- =====================
return function(refs, T)
    local character = player.Character or player.CharacterAdded:Wait()

    local function getRoot()
        character = player.Character
        if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart")
    end

    local function fireSettings(key,value)
        pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents")
                :WaitForChild("SettingsToggle"):FireServer(key,value)
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

    -- ── FLY (farm) ─────────────────────────────────────────
    local flyBP, flyBG = nil, nil
    local function enableFly()
        character = player.Character; if not character then return end
        local r = character:FindFirstChild("HumanoidRootPart")
        local h = character:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end
        h.PlatformStand = true
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

    -- ── MOVEMENT ───────────────────────────────────────────
    local function moveTo(targetPos, speed)
        local r=getRoot(); if not r then return end
        local dist=(r.Position-targetPos).Magnitude
        if dist>100 then
            local dur=math.max(0.3,dist/(speed or 150))
            if flyBP then flyBP.Position=targetPos end
            local tw=TweenService:Create(r,
                TweenInfo.new(dur,Enum.EasingStyle.Linear),
                {CFrame=CFrame.new(targetPos)})
            tw:Play(); tw.Completed:Wait()
        else
            r.CFrame=CFrame.new(targetPos)
            if flyBP then flyBP.Position=targetPos end
        end
    end

    -- ── AUTO CLICK (shared) ────────────────────────────────
    local autoClickRunning = false
    local function startClick(ms)
        if autoClickRunning then return end
        autoClickRunning=true
        task.spawn(function()
            local vim=game:GetService("VirtualInputManager")
            while autoClickRunning do
                pcall(function()
                    vim:SendMouseButtonEvent(0,0,0,true,game,0)
                    task.wait(0.02)
                    vim:SendMouseButtonEvent(0,0,0,false,game,0)
                end)
                task.wait((ms or 100)/1000)
            end
            pcall(function()
                local v2=game:GetService("VirtualInputManager")
                v2:SendGamepadButtonEvent(0,Enum.KeyCode.ButtonL3,false,game)
                v2:SendGamepadButtonEvent(0,Enum.KeyCode.Thumbstick1,false,game)
                v2:SendGamepadButtonEvent(0,Enum.KeyCode.Thumbstick2,false,game)
            end)
        end)
    end
    local function stopClick()
        autoClickRunning=false
    end

    -- ── QUEST ──────────────────────────────────────────────
    local function findNPC(radius)
        local r=getRoot(); if not r then return nil,nil end
        local svc=workspace:FindFirstChild("ServiceNPCs"); if not svc then return nil,nil end
        local best,bestD,bestName=nil,math.huge,nil
        for i=1,19 do
            local npc=svc:FindFirstChild("QuestNPC"..i)
            if npc then
                local pos
                if npc:IsA("Model") then
                    local pp=npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
                    if pp then pos=pp.Position end
                elseif npc:IsA("BasePart") then pos=npc.Position end
                if pos then
                    local d=(r.Position-pos).Magnitude
                    if d<=radius and d<bestD then bestD=d; best=npc; bestName="QuestNPC"..i end
                end
            end
        end
        return best,bestName
    end
    local function fireQuestAccept(name)
        pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents")
                :WaitForChild("QuestAccept"):FireServer(name)
        end)
    end

    -- ── STATE ──────────────────────────────────────────────
    local farmV1On=false; local farmV2On=false
    local isRunningV1=false; local isRunningV2=false
    _G.islandFarmOn=false
    local questOn=false; local lastFiredNPC=nil

    -- ── FARM V1 ────────────────────────────────────────────
    local function farmLoopV1()
        isRunningV1=true; _G.islandFarmOn=true
        enableFly(); enableGS()
        while farmV1On do
            local island=refs.getIsland(); local data=ISLANDS[island]
            if not data then
                refs.setFarmStat("Pulau tidak dikenali!",T.red)
                task.wait(1); continue
            end
            local coords=data.coords
            for i,pos in ipairs(coords) do
                if not farmV1On then break end
                local fp=Vector3.new(pos.X,pos.Y+refs.getHeight(),pos.Z)
                local r=getRoot(); local dist=r and (r.Position-fp).Magnitude or 0
                refs.setFarmStat(island.." ["..i.."/"..#coords.."] "
                    ..(dist>100 and "Tween" or "TP"),T.green)
                refs.setFarmPhase((dist>100 and "Tween " or "TP ")..math.floor(dist).."st")
                moveTo(fp,refs.getSpeed()); task.wait(refs.getTD())
            end
            if not farmV1On then break end
            local ld=refs.getLD()
            if ld>0 then
                local endT=tick()+ld
                while tick()<endT and farmV1On do
                    refs.setFarmStat("Cooldown "..math.ceil(endT-tick()).."s",T.amber)
                    refs.setFarmPhase("Next loop..."); task.wait(0.1)
                end
            end
        end
        disableFly(); disableGS()
        refs.setFarmStat("Idle",T.textDim); refs.setFarmPhase("--")
        _G.islandFarmOn=false; isRunningV1=false
        refs.setFarmOnOff(false)
    end

    -- ── FARM V2 ────────────────────────────────────────────
    local function farmLoopV2()
        isRunningV2=true; _G.islandFarmOn=true
        enableFly(); enableGS()
        while farmV2On do
            local island=refs.getIsland(); local data=ISLANDS[island]
            if not data then
                refs.setFarmStat("Pulau tidak dikenali!",T.red)
                task.wait(1); continue
            end
            local ci=data.center; local cpos=data.coords[ci]
            local fp=Vector3.new(cpos.X,cpos.Y+refs.getHeight(),cpos.Z)
            local r=getRoot(); local dist=r and (r.Position-fp).Magnitude or 0
            refs.setFarmStat(island.." [c:"..ci.."] "
                ..(dist>100 and "Tween" or "TP"),T.green)
            refs.setFarmPhase("Titik tengah ["..ci.."]")
            moveTo(fp,refs.getSpeed())
            local ld=refs.getLD()
            if ld>0 then
                local endT=tick()+ld
                while tick()<endT and farmV2On do
                    refs.setFarmStat(island.." [c:"..ci.."] "
                        ..math.ceil(endT-tick()).."s",T.green)
                    task.wait(0.1)
                end
            else task.wait(0.5) end
        end
        disableFly(); disableGS()
        refs.setFarmStat("Idle",T.textDim); refs.setFarmPhase("--")
        _G.islandFarmOn=false; isRunningV2=false
        refs.setFarmOnOff(false)
    end

    -- ── QUEST LOOP ─────────────────────────────────────────
    task.spawn(function()
        while task.wait(0.3) do
            if not questOn then refs.setQNPC("--"); lastFiredNPC=nil; continue end
            local _,name=findNPC(refs.getQR())
            if name then
                refs.setQNPC(name,T.green)
                if name~=lastFiredNPC then
                    fireQuestAccept(name)
                    fireSettings("EnableQuestRepeat",true)
                    fireSettings("AutoQuestRepeat",true)
                    fireSettings("DisablePVP",true)
                    lastFiredNPC=name; refs.setQLast(name,T.accentGlow)
                end
            else refs.setQNPC("--",T.textDim) end
        end
    end)

    -- ── FARM WATCHER ───────────────────────────────────────
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

    -- ── BOSS KILL ──────────────────────────────────────────
    local bossKillOn    = false
    local bossClicking  = false
    local bossFlyBP, bossFlyBG = nil, nil

    -- Helper: ambil BasePart representatif dari boss model
    local function getBossPart(bossName)
        if not bossName then return nil end
        local npcs = workspace:FindFirstChild("NPCs")
        if not npcs then return nil end
        local folder = npcs:FindFirstChild(bossName)
        if not folder then return nil end
        local bossModel = folder:FindFirstChild("Boss")
        if not bossModel then return nil end
        return bossModel.PrimaryPart
            or bossModel:FindFirstChildWhichIsA("BasePart")
    end

    local function enableBossFly()
        local r=getRoot()
        local h=character and character:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end
        h.PlatformStand=true
        if bossFlyBP then bossFlyBP:Destroy() end
        if bossFlyBG then bossFlyBG:Destroy() end
        bossFlyBP=Instance.new("BodyPosition")
        bossFlyBP.MaxForce=Vector3.new(1e5,1e5,1e5)
        bossFlyBP.D=600; bossFlyBP.P=6000
        bossFlyBP.Position=r.Position; bossFlyBP.Parent=r
        bossFlyBG=Instance.new("BodyGyro")
        bossFlyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
        bossFlyBG.D=500; bossFlyBG.CFrame=r.CFrame; bossFlyBG.Parent=r
    end

    local function disableBossFly()
        if bossFlyBP then bossFlyBP:Destroy(); bossFlyBP=nil end
        if bossFlyBG then bossFlyBG:Destroy(); bossFlyBG=nil end
        local h=character and character:FindFirstChildOfClass("Humanoid")
        -- hanya set PlatformStand=false jika farm juga tidak aktif
        if h and not _G.islandFarmOn then h.PlatformStand=false end
    end

    local function bossKillLoop()
        enableBossFly()

        while bossKillOn do
            local bossName = refs.getSelectedBoss()

            if not bossName then
                refs.setBossStat("Pilih boss dulu", T.amber)
                task.wait(0.5); continue
            end

            local bossPart = getBossPart(bossName)
            if not bossPart then
                -- Boss tidak ada / sudah mati
                refs.setBossStat("Boss tidak ditemukan / mati", T.red)
                task.wait(0.3)
                -- Cek sekali lagi sebelum berhenti
                if not getBossPart(bossName) then break end
                continue
            end

            local r = getRoot()
            if not r then task.wait(0.3); continue end

            local bossPos = bossPart.Position
            local dist    = (r.Position - bossPos).Magnitude

            -- Status display
            refs.setBossStat(bossName.." | "..math.floor(dist).."st", T.green)

            -- Target position: sedikit di atas boss agar tidak stuck di ground
            local targetPos = bossPos + Vector3.new(0, 4, 0)

            -- Selalu tween menuju boss di 70 st/s
            if bossFlyBP then
                bossFlyBP.Position = targetPos
            end
            local moveDist = (r.Position - targetPos).Magnitude
            if moveDist > 3 then
                local dur = math.clamp(moveDist / 70, 0.05, 0.5)
                TweenService:Create(r,
                    TweenInfo.new(dur, Enum.EasingStyle.Linear),
                    {CFrame = CFrame.new(targetPos)}):Play()
            end

            -- Aktifkan auto click ketika dalam radius 50 studs
            if dist <= 50 then
                if not bossClicking then
                    bossClicking = true
                    startClick(80)  -- 80ms interval untuk boss kill
                end
            else
                if bossClicking then
                    bossClicking = false
                    stopClick()
                end
            end

            task.wait(0.15)
        end

        -- Cleanup setelah loop berhenti
        if bossClicking then
            bossClicking = false
            stopClick()
        end
        disableBossFly()
        refs.setBossStat("Idle", T.textDim)
        refs.setBossOnOff(false)
    end

    -- ── CALLBACKS ──────────────────────────────────────────
    refs.setFarmCallback(function(v)
        local mode=refs.getFarmMode()
        if v then
            if mode=="V2 - Titik Tengah" then farmV2On=true; farmV1On=false
            else farmV1On=true; farmV2On=false end
            refs.setFarmStat("Starting...",T.amber)
        else
            farmV1On=false; farmV2On=false
            refs.setFarmStat("Idle",T.textDim); refs.setFarmPhase("--")
        end
    end)

    refs.setQuestCallback(function(v)
        questOn=v
        if not v then
            lastFiredNPC=nil
            refs.setQNPC("--",T.textDim); refs.setQLast("--",T.textDim)
        end
    end)

    refs.setHitCallback(function(v)
        if v then startClick(refs.getCI()); refs.setHitStat("Running",T.green)
        else stopClick(); refs.setHitStat("Idle",T.textDim) end
    end)

    refs.setBossCallback(function(v)
        bossKillOn = v
        if v then
            local bossName = refs.getSelectedBoss()
            if not bossName then
                refs.setBossStat("Pilih boss dulu!", T.red)
                refs.setBossOnOff(false)
                bossKillOn = false
                return
            end
            refs.setBossStat("Starting...", T.amber)
            task.spawn(bossKillLoop)
        else
            bossKillOn = false
            if bossClicking then
                bossClicking = false
                stopClick()
            end
            disableBossFly()
            refs.setBossStat("Idle", T.textDim)
        end
    end)
end
