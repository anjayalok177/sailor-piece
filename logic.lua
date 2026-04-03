-- ╔══════════════════════════════════╗
-- ║  YiDaMuSake — Logic Layer        ║
-- ╚══════════════════════════════════╝
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer

local ISLANDS = {
    ["Starter Island"] = {
        coords={
            Vector3.new(194.943,16.207,-171.994), Vector3.new(164.245,16.207,-176.308),
            Vector3.new(159.530,16.207,-142.758), Vector3.new(177.723,16.207,-157.247),
            Vector3.new(189.238,16.207,-138.583),
        }, center=4,
    },
    ["Jungle Island"] = {
        coords={
            Vector3.new(-566.029,4.125,425.000), Vector3.new(-567.759,4.125,399.303),
            Vector3.new(-585.790,3.359,397.131), Vector3.new(-575.712,3.359,381.006),
            Vector3.new(-549.771,4.125,395.209),
        }, center=2,
    },
    ["Desert Island"] = {
        coords={
            Vector3.new(-774.852,0.777,-405.228), Vector3.new(-793.225,0.777,-433.599),
            Vector3.new(-768.626,0.777,-452.058), Vector3.new(-815.452,0.777,-417.817),
            Vector3.new(-808.365,0.777,-457.034),
        }, center=2,
    },
    ["Snow Island"] = {
        coords={
            Vector3.new(-423.471,3.861,-968.619), Vector3.new(-436.772,3.859,-998.843),
            Vector3.new(-410.853,3.861,-990.573), Vector3.new(-402.983,3.861,-1014.348),
            Vector3.new(-385.389,3.861,-981.637),
        }, center=3,
    },
    ["Shibuya"] = {
        coords={
            Vector3.new(1407.890,13.486,522.877), Vector3.new(1435.052,13.839,480.898),
            Vector3.new(1398.259,13.486,488.059), Vector3.new(1362.940,13.486,493.791),
            Vector3.new(1390.117,13.486,451.823),
        }, center=3,
    },
    ["Hollow"] = {
        coords={
            Vector3.new(-341.802,4.559,1091.144), Vector3.new(-365.126,4.559,1097.683),
            Vector3.new(-358.324,4.559,1078.029), Vector3.new(-385.284,5.201,1082.955),
            Vector3.new(-383.171,4.559,1110.780),
        }, center=1,
    },
    ["Curse"] = {
        coords={
            Vector3.new(-41.327,6.882,-1816.006), Vector3.new(4.006,6.882,-1864.215),
            Vector3.new(-18.396,6.882,-1845.568), Vector3.new(-3.303,6.882,-1810.042),
            Vector3.new(-26.960,6.882,-1875.933),
        }, center=3,
    },
}

return function(refs, T)
    local character = player.Character or player.CharacterAdded:Wait()

    local function getRoot()
        character=player.Character
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

    local function moveTo(targetPos,speed)
        local r=getRoot(); if not r then return end
        local dist=(r.Position-targetPos).Magnitude
        if dist>100 then
            local dur=math.max(0.3,dist/(speed or 150))
            if flyBP then flyBP.Position=targetPos end
            local tw=TweenService:Create(r,TweenInfo.new(dur,Enum.EasingStyle.Linear),{CFrame=CFrame.new(targetPos)})
            tw:Play(); tw.Completed:Wait()
        else
            r.CFrame=CFrame.new(targetPos)
            if flyBP then flyBP.Position=targetPos end
        end
    end

    local autoClickRunning=false
    local function startClick(ms)
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
    local function stopClick() autoClickRunning=false end

    local function findNPC(radius)
        local r=getRoot(); if not r then return nil,nil end
        local svc=workspace:FindFirstChild("ServiceNPCs"); if not svc then return nil,nil end
        local best,bestD,bestName=nil,math.huge,nil
        for i=1,19 do
            local n=svc:FindFirstChild("QuestNPC"..i)
            if n then
                local pos
                if n:IsA("Model") then
                    local pp=n.PrimaryPart or n:FindFirstChildWhichIsA("BasePart")
                    if pp then pos=pp.Position end
                elseif n:IsA("BasePart") then pos=n.Position end
                if pos then
                    local d=(r.Position-pos).Magnitude
                    if d<=radius and d<bestD then bestD=d; best=n; bestName="QuestNPC"..i end
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

    -- STATE
    local farmV1On=false; local farmV2On=false
    local isRunningV1=false; local isRunningV2=false
    _G.islandFarmOn=false
    local questOn=false; local lastFiredNPC=nil

    local function farmLoopV1()
        isRunningV1=true; _G.islandFarmOn=true
        enableFly(); enableGS()
        while farmV1On do
            local island=refs.getIsland(); local data=ISLANDS[island]
            if not data then refs.setFarmStat("Pilih pulau!"); task.wait(0.5); continue end
            local coords=data.coords
            for i,pos in ipairs(coords) do
                if not farmV1On then break end
                local fp=Vector3.new(pos.X,pos.Y+refs.getHeight(),pos.Z)
                local r=getRoot(); local dist=r and (r.Position-fp).Magnitude or 0
                refs.setFarmStat(island.." ["..i.."/"..#coords.."] "..(dist>100 and "Tween" or "TP"),T.green)
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

    local function farmLoopV2()
        isRunningV2=true; _G.islandFarmOn=true
        enableFly(); enableGS()
        while farmV2On do
            local island=refs.getIsland(); local data=ISLANDS[island]
            if not data then refs.setFarmStat("Pilih pulau!"); task.wait(0.5); continue end
            local ci=data.center; local cpos=data.coords[ci]
            local fp=Vector3.new(cpos.X,cpos.Y+refs.getHeight(),cpos.Z)
            local r=getRoot(); local dist=r and (r.Position-fp).Magnitude or 0
            refs.setFarmStat(island.." [c:"..ci.."] "..(dist>100 and "Tween" or "TP"),T.green)
            refs.setFarmPhase("Titik tengah"); moveTo(fp,refs.getSpeed())
            local ld=refs.getLD()
            if ld>0 then
                local endT=tick()+ld
                while tick()<endT and farmV2On do
                    refs.setFarmStat(island.." [c:"..ci.."] "..math.ceil(endT-tick()).."s",T.green)
                    task.wait(0.1)
                end
            else task.wait(0.5) end
        end
        disableFly(); disableGS()
        refs.setFarmStat("Idle",T.textDim); refs.setFarmPhase("--")
        _G.islandFarmOn=false; isRunningV2=false
        refs.setFarmOnOff(false)
    end

    -- Quest loop
    task.spawn(function()
        while task.wait(0.3) do
            if not questOn then refs.setQNPC("--"); lastFiredNPC=nil; continue end
            local _,name=findNPC(refs.getQR())
            if name then
                refs.setQNPC(name,T.green)
                if name~=lastFiredNPC then
                    fireQuestAccept(name); fireSettings("EnableQuestRepeat",true)
                    fireSettings("AutoQuestRepeat",true); fireSettings("DisablePVP",true)
                    lastFiredNPC=name; refs.setQLast(name,T.accentGlow)
                end
            else refs.setQNPC("--",T.textDim) end
        end
    end)

    -- Farm watcher
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

    -- Connect callbacks
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
        if not v then lastFiredNPC=nil; refs.setQNPC("--",T.textDim); refs.setQLast("--",T.textDim) end
    end)

    refs.setHitCallback(function(v)
        if v then startClick(refs.getCI()); refs.setHitStat("Running",T.green)
        else stopClick(); refs.setHitStat("Idle",T.textDim) end
    end)
end
