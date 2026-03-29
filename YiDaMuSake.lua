-- ======================
-- Intro Animation (slide from bottom + smooth)
-- ======================
local function createIntroAnimation()
    local TweenService = game:GetService("TweenService")
    local SoundService = game:GetService("SoundService")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "IntroScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = game:GetService("CoreGui")

    local laserSound = Instance.new("Sound")
    laserSound.SoundId = "rbxassetid://9057675920"
    laserSound.Volume = 0.5
    laserSound.Parent = SoundService

    local explosionSound = Instance.new("Sound")
    explosionSound.SoundId = "rbxassetid://112797079504478"
    explosionSound.Volume = 0.6
    explosionSound.Parent = SoundService

    -- Background fade in
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1,0,1,0)
    background.BackgroundColor3 = Color3.fromRGB(12,10,22)
    background.BorderSizePixel = 0
    background.BackgroundTransparency = 1
    background.Parent = screenGui

    TweenService:Create(background, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(28,15,48)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12,8,28)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(45,22,65))
    }
    gradient.Rotation = 45
    gradient.Parent = background

    -- Rotating gradient
    task.spawn(function()
        local r = 45
        while background.Parent do
            r = r + 0.25
            gradient.Rotation = r
            task.wait(0.03)
        end
    end)

    -- Floating particles
    for i = 1, 22 do
        local p = Instance.new("Frame")
        local sz = math.random(2,7)
        p.Size = UDim2.new(0,sz,0,sz)
        p.Position = UDim2.new(math.random(),0,math.random(),0)
        p.BackgroundColor3 = Color3.fromHSV(math.random(260,295)/360, 0.75, 0.9)
        p.BackgroundTransparency = math.random(40,75)/100
        p.BorderSizePixel = 0
        p.Parent = background
        Instance.new("UICorner",p).CornerRadius = UDim.new(1,0)
        task.spawn(function()
            while p.Parent do
                TweenService:Create(p, TweenInfo.new(math.random(28,50)/10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
                    Position = UDim2.new(math.clamp(p.Position.X.Scale+math.random(-8,8)/100,0.02,0.98),0,math.clamp(p.Position.Y.Scale+math.random(-8,8)/100,0.02,0.98),0),
                    BackgroundTransparency = math.random(20,65)/100
                }):Play()
                task.wait(math.random(28,50)/10)
            end
        end)
    end

    -- Pulse rings (behind image)
    for i = 1, 3 do
        local ring = Instance.new("ImageLabel")
        ring.Size = UDim2.new(0, 80+i*55, 0, 80+i*55)
        ring.Position = UDim2.new(0.5,0,0.42,0)
        ring.AnchorPoint = Vector2.new(0.5,0.5)
        ring.BackgroundTransparency = 1
        ring.Image = "rbxassetid://5028857084"
        ring.ImageColor3 = Color3.fromRGB(138,43,226)
        ring.ImageTransparency = 1
        ring.ZIndex = 2
        ring.Parent = background
        task.spawn(function()
            task.wait(0.8 + i*0.15)
            TweenService:Create(ring, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {ImageTransparency = 0.75}):Play()
            task.wait(0.4)
            while ring.Parent do
                TweenService:Create(ring, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
                    Size = UDim2.new(0, 100+i*65, 0, 100+i*65),
                    ImageTransparency = 0.55
                }):Play()
                task.wait(1.6)
            end
        end)
    end

    -- Image frame: mulai dari bawah layar
    local imageFrame = Instance.new("ImageLabel")
    imageFrame.Size = UDim2.new(0,220,0,220)
    imageFrame.Position = UDim2.new(0.5,0,1.35,0)
    imageFrame.AnchorPoint = Vector2.new(0.5,0.5)
    imageFrame.BackgroundTransparency = 1
    imageFrame.Image = "rbxassetid://110843044052526"
    imageFrame.ScaleType = Enum.ScaleType.Fit
    imageFrame.ImageTransparency = 0.6
    imageFrame.ZIndex = 5
    imageFrame.Parent = background
    Instance.new("UICorner",imageFrame).CornerRadius = UDim.new(0,22)

    -- Glow di belakang image
    local outerGlow = Instance.new("ImageLabel")
    outerGlow.Size = UDim2.new(1.45,0,1.45,0)
    outerGlow.Position = UDim2.new(0.5,0,0.5,0)
    outerGlow.AnchorPoint = Vector2.new(0.5,0.5)
    outerGlow.BackgroundTransparency = 1
    outerGlow.Image = "rbxassetid://5028857084"
    outerGlow.ImageColor3 = Color3.fromRGB(155,55,255)
    outerGlow.ImageTransparency = 1
    outerGlow.ZIndex = 4
    outerGlow.Parent = imageFrame

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0,520,0,68)
    titleLbl.Position = UDim2.new(0.5,0,0.76,0)
    titleLbl.AnchorPoint = Vector2.new(0.5,0.5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "YI DA MU SAKE"
    titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    titleLbl.TextSize = 48
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextTransparency = 1
    titleLbl.TextStrokeTransparency = 1
    titleLbl.TextStrokeColor3 = Color3.fromRGB(155,55,255)
    titleLbl.ZIndex = 5
    titleLbl.Parent = background

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(0,400,0,26)
    subLbl.Position = UDim2.new(0.5,0,0.83,0)
    subLbl.AnchorPoint = Vector2.new(0.5,0.5)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = "sailor piece"
    subLbl.TextColor3 = Color3.fromRGB(170,110,255)
    subLbl.TextSize = 16
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextTransparency = 1
    subLbl.ZIndex = 5
    subLbl.Parent = background

    task.wait(0.3)

    -- === SLIDE UP dari bawah dengan Elastic bounce ===
    laserSound:Play()
    TweenService:Create(imageFrame, TweenInfo.new(2.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5,0,0.42,0),
        ImageTransparency = 0
    }):Play()
    TweenService:Create(outerGlow, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0.45
    }):Play()

    -- Glow pulse saat image settle
    task.wait(1.4)
    for i = 1, 2 do
        TweenService:Create(outerGlow, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {ImageTransparency = 0.12}):Play()
        task.wait(0.22)
        TweenService:Create(outerGlow, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {ImageTransparency = 0.48}):Play()
        task.wait(0.22)
    end

    -- Fade in title setelah bounce settle
    task.wait(0.5)
    TweenService:Create(titleLbl, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0, TextStrokeTransparency = 0.45
    }):Play()
    TweenService:Create(subLbl, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    task.wait(1.6)

    -- === SHATTER outside-in dengan delay per piece ===
    local gridSize  = 6
    local imgSize   = 220
    local pieceSize = imgSize / gridSize
    local piecesWD  = {}

    for row = 0, gridSize-1 do
        for col = 0, gridSize-1 do
            local pc = Instance.new("ImageLabel")
            pc.Size = UDim2.new(0,pieceSize,0,pieceSize)
            pc.Position = UDim2.new(0.5,(col*pieceSize)-(imgSize/2), 0.42,(row*pieceSize)-(imgSize/2))
            pc.AnchorPoint = Vector2.new(0,0)
            pc.BackgroundTransparency = 1
            pc.Image = "rbxassetid://110843044052526"
            pc.ScaleType = Enum.ScaleType.Crop
            pc.ZIndex = 6
            pc.ImageRectSize = Vector2.new(420/gridSize,420/gridSize)
            pc.ImageRectOffset = Vector2.new(col*420/gridSize,row*420/gridSize)
            pc.Parent = background
            Instance.new("UICorner",pc).CornerRadius = UDim.new(0,math.random(2,5))
            local cr = (gridSize-1)/2
            table.insert(piecesWD, {piece=pc, distance=math.sqrt((row-cr)^2+(col-cr)^2)})
        end
    end
    table.sort(piecesWD, function(a,b) return a.distance>b.distance end)

    imageFrame.Visible = false
    explosionSound:Play()

    -- Flash
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1,0,1,0)
    flash.BackgroundColor3 = Color3.fromRGB(195,140,255)
    flash.BorderSizePixel = 0
    flash.BackgroundTransparency = 1
    flash.ZIndex = 15
    flash.Parent = background
    local fIn = TweenService:Create(flash, TweenInfo.new(0.07), {BackgroundTransparency=0.12})
    fIn:Play()
    fIn.Completed:Connect(function()
        TweenService:Create(flash, TweenInfo.new(0.55, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play()
    end)

    -- Scatter: outside-in, tiap piece delay berdasarkan jarak
    for i, pd in ipairs(piecesWD) do
        task.spawn(function()
            task.wait(pd.distance * 0.045)
            local pc  = pd.piece
            local rad = math.rad(math.random(0,360))
            local d   = math.random(280,680)
            TweenService:Create(pc, TweenInfo.new(1.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(pc.Position.X.Scale, pc.Position.X.Offset+math.cos(rad)*d,
                                     pc.Position.Y.Scale, pc.Position.Y.Offset+math.sin(rad)*d+math.random(60,220)),
                ImageTransparency = 1,
                Rotation = math.random(-400,400),
                Size = UDim2.new(0,pieceSize*0.18,0,pieceSize*0.18)
            }):Play()
        end)
    end

    task.wait(1.9)

    -- Fade out semua
    TweenService:Create(titleLbl, TweenInfo.new(0.55, Enum.EasingStyle.Quad), {TextTransparency=1, TextStrokeTransparency=1}):Play()
    TweenService:Create(subLbl,   TweenInfo.new(0.55, Enum.EasingStyle.Quad), {TextTransparency=1}):Play()
    TweenService:Create(background, TweenInfo.new(0.55, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play()
    task.wait(0.65)
    laserSound:Destroy(); explosionSound:Destroy(); screenGui:Destroy()
end

createIntroAnimation()

-- ======================
-- Main Script
-- ======================
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer
local character         = player.Character or player.CharacterAdded:Wait()

local repo         = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options      = Library.Options
local Toggles      = Library.Toggles

local Window = Library:CreateWindow({
    Title            = "Yi Da Mu Sake",
    Footer           = "version: sailor piece",
    Icon             = 110843044052526,
    NotifySide       = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main            = Window:AddTab("Main",        "home"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- ==================== ISLAND DATA ====================

local ISLANDS = {
    ["Starter Island"] = {
        coords  = {Vector3.new(194.943,16.207,-171.994),Vector3.new(164.245,16.207,-176.308),Vector3.new(159.530,16.207,-142.758),Vector3.new(177.723,16.207,-157.247),Vector3.new(189.238,16.207,-138.583)},
        center  = 4
    },
    ["Jungle Island"]  = {
        coords  = {Vector3.new(-566.029,4.125,425.000),Vector3.new(-567.759,4.125,399.303),Vector3.new(-585.790,3.359,397.131),Vector3.new(-575.712,3.359,381.006),Vector3.new(-549.771,4.125,395.209)},
        center  = 2
    },
    ["Desert Island"]  = {
        coords  = {Vector3.new(-774.852,0.777,-405.228),Vector3.new(-793.225,0.777,-433.599),Vector3.new(-768.626,0.777,-452.058),Vector3.new(-815.452,0.777,-417.817),Vector3.new(-808.365,0.777,-457.034)},
        center  = 2
    },
    ["Snow Island"]    = {
        coords  = {Vector3.new(-423.471,3.861,-968.619),Vector3.new(-436.772,3.859,-998.843),Vector3.new(-410.853,3.861,-990.573),Vector3.new(-402.983,3.861,-1014.348),Vector3.new(-385.389,3.861,-981.637)},
        center  = 3
    },
    ["Shibuya"]        = {
        coords  = {Vector3.new(1407.890,13.486,522.877),Vector3.new(1435.052,13.839,480.898),Vector3.new(1398.259,13.486,488.059),Vector3.new(1362.940,13.486,493.791),Vector3.new(1390.117,13.486,451.823)},
        center  = 3
    },
    ["Hollow"]         = {
        coords  = {Vector3.new(-341.802,4.559,1091.144),Vector3.new(-365.126,4.559,1097.683),Vector3.new(-358.324,4.559,1078.029),Vector3.new(-385.284,5.201,1082.955),Vector3.new(-383.171,4.559,1110.780)},
        center  = 1
    },
    ["Curse"]          = {
        coords  = {Vector3.new(-41.327,6.882,-1816.006),Vector3.new(4.006,6.882,-1864.215),Vector3.new(-18.396,6.882,-1845.568),Vector3.new(-3.303,6.882,-1810.042),Vector3.new(-26.960,6.882,-1875.933)},
        center  = 3
    },
}
local ISLAND_ORDER = {"Starter Island","Jungle Island","Desert Island","Snow Island","Shibuya","Hollow","Curse"}

-- ==================== HELPERS ====================

local function getRoot()
    character = player.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

local function fireSettings(key, value)
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SettingsToggle"):FireServer(key, value)
    end)
end

local function enableGameSettings()
    fireSettings("EnableQuestRepeat", true)
    fireSettings("AutoQuestRepeat",   true)
    fireSettings("DisablePVP",        true)
end

local function disableGameSettings()
    fireSettings("EnableQuestRepeat", false)
    fireSettings("AutoQuestRepeat",   false)
    fireSettings("DisablePVP",        false)
end

-- ==================== FLY ====================

local flyBP, flyBG = nil, nil

local function enableFly()
    character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum  = character:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum.PlatformStand = true
    if flyBP then flyBP:Destroy() end
    if flyBG then flyBG:Destroy() end
    flyBP = Instance.new("BodyPosition")
    flyBP.MaxForce = Vector3.new(1e5,1e5,1e5); flyBP.D=500; flyBP.P=5000
    flyBP.Position = root.Position; flyBP.Parent = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5); flyBG.D=400
    flyBG.CFrame = root.CFrame; flyBG.Parent = root
end

local function disableFly()
    if flyBP then flyBP:Destroy() flyBP=nil end
    if flyBG then flyBG:Destroy() flyBG=nil end
    character = player.Character
    if not character then return end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    if _G.islandFarmOn then task.wait(1) enableFly() end
end)

-- ==================== MOVE ====================

local function moveToPosition(targetPos, speedStudsPerSec)
    local root = getRoot()
    if not root then return end
    local dist = (root.Position - targetPos).Magnitude
    if dist > 100 then
        local speed    = speedStudsPerSec or 150
        local duration = math.max(0.3, dist / speed)
        if flyBP then flyBP.Position = targetPos end
        local tw = TweenService:Create(root,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(targetPos)}
        )
        tw:Play(); tw.Completed:Wait()
    else
        root.CFrame = CFrame.new(targetPos)
        if flyBP then flyBP.Position = targetPos end
    end
end

-- ==================== AUTO CLICK ====================

local autoClickRunning = false

local function startAutoClick(intervalMs)
    autoClickRunning = true
    task.spawn(function()
        local vim = game:GetService("VirtualInputManager")
        while autoClickRunning do
            pcall(function()
                vim:SendMouseButtonEvent(0,0,0,true,game,0)
                task.wait(0.02)
                vim:SendMouseButtonEvent(0,0,0,false,game,0)
            end)
            task.wait((intervalMs or 100)/1000)
        end
        pcall(function()
            vim:SendGamepadButtonEvent(0, Enum.KeyCode.ButtonL3,    false, game)
            vim:SendGamepadButtonEvent(0, Enum.KeyCode.Thumbstick1, false, game)
            vim:SendGamepadButtonEvent(0, Enum.KeyCode.Thumbstick2, false, game)
        end)
    end)
end

local function stopAutoClick()
    autoClickRunning = false
end

-- ==================== AUTO QUEST ====================

local QUEST_NPC_COUNT = 19

local function findNearestQuestNPC(radius)
    local root = getRoot()
    if not root then return nil, nil end
    local serviceNPCs = workspace:FindFirstChild("ServiceNPCs")
    if not serviceNPCs then return nil, nil end
    local nearest, nearestDist, nearestName = nil, math.huge, nil
    for i = 1, QUEST_NPC_COUNT do
        local npcName = "QuestNPC" .. i
        local npc     = serviceNPCs:FindFirstChild(npcName)
        if npc then
            local npcPos
            if npc:IsA("Model") then
                local pp = npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
                if pp then npcPos = pp.Position end
            elseif npc:IsA("BasePart") then npcPos = npc.Position end
            if npcPos then
                local d = (root.Position - npcPos).Magnitude
                if d <= radius and d < nearestDist then
                    nearestDist=d; nearest=npc; nearestName=npcName
                end
            end
        end
    end
    return nearest, nearestName
end

local function fireQuestAccept(npcName)
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept"):FireServer(npcName)
    end)
end

-- ==================== UI TABS (SubTab Navbar) ====================

-- SubTabs di dalam Main
local SubTabs = {
    Farm  = Tabs.Main:AddTab("🗺 Farm"),
    Quest = Tabs.Main:AddTab("📋 Quest"),
    Hit   = Tabs.Main:AddTab("🖱 Hit"),
}

-- ===== SUBTAB: FARM =====
local FarmBox = SubTabs.Farm:AddLeftGroupbox("Auto Farm")

FarmBox:AddDropdown("IslandSelect", {
    Values = ISLAND_ORDER, Default = 1, Multi = false, Text = "Pilih Pulau",
})

FarmBox:AddDivider()

FarmBox:AddSlider("HeightOffset", {
    Text = "Height Offset", Default = 0, Min = 0, Max = 50, Rounding = 0, Suffix = " studs",
})
FarmBox:AddSlider("TweenSpeed", {
    Text = "Kecepatan Tween", Default = 150, Min = 20, Max = 500, Rounding = 0, Suffix = " studs/s",
    Tooltip = "Kecepatan konstan saat tween (jarak >100 stud)",
})
FarmBox:AddSlider("TeleportDelay", {
    Text = "Jeda antar titik", Default = 1, Min = 1, Max = 10, Rounding = 0, Suffix = "s",
})
FarmBox:AddSlider("LoopDelay", {
    Text = "Delay setelah loop", Default = 3, Min = 0, Max = 10, Rounding = 0, Suffix = "s",
})

FarmBox:AddDivider()

local farmStatusLabel = FarmBox:AddLabel("—")

FarmBox:AddDivider()

-- V1: keliling semua titik
FarmBox:AddToggle("AutoFarm", {
    Text    = "Auto Farm V1 (semua titik)",
    Default = false,
    Tooltip = "Teleport/tween ke setiap titik koordinat secara berurutan",
})

-- V2: menetap di titik tengah
FarmBox:AddToggle("AutoFarmV2", {
    Text    = "Auto Farm V2 (titik tengah)",
    Default = false,
    Tooltip = "Menetap di titik tengah pulau yang dipilih, tidak berpindah",
})

-- ===== SUBTAB: QUEST =====
local QuestBox = SubTabs.Quest:AddLeftGroupbox("Auto Quest")

QuestBox:AddSlider("QuestRadius", {
    Text = "Radius Deteksi", Default = 50, Min = 10, Max = 200, Rounding = 0, Suffix = " studs",
})

QuestBox:AddDivider()

local questNPCLabel  = QuestBox:AddLabel("NPC  : —")
local questLastLabel = QuestBox:AddLabel("Last : —")

QuestBox:AddDivider()

QuestBox:AddToggle("AutoQuest", {
    Text    = "Enable Auto Quest",
    Default = false,
})

-- ===== SUBTAB: HIT =====
local ClickBox = SubTabs.Hit:AddLeftGroupbox("Auto Hit")

ClickBox:AddSlider("ClickInterval", {
    Text = "Interval", Default = 100, Min = 50, Max = 1000, Rounding = 0, Suffix = "ms",
    Callback = function(val)
        if Toggles.AutoClick and Toggles.AutoClick.Value then
            stopAutoClick(); task.wait(0.05); startAutoClick(val)
        end
    end,
})

ClickBox:AddDivider()

ClickBox:AddToggle("AutoClick", {
    Text    = "Enable Auto Hit",
    Default = false,
    Callback = function(val)
        if val then startAutoClick(Options.ClickInterval and Options.ClickInterval.Value or 100)
        else stopAutoClick() end
    end,
})

-- ==================== AUTO QUEST LOOP ====================

task.spawn(function()
    local lastFiredNPC = nil
    while task.wait(0.3) do
        if not (Toggles.AutoQuest and Toggles.AutoQuest.Value) then
            questNPCLabel:SetText("NPC  : —")
            lastFiredNPC = nil
            continue
        end
        local radius = Options.QuestRadius and Options.QuestRadius.Value or 50
        local _, npcName = findNearestQuestNPC(radius)
        if npcName then
            questNPCLabel:SetText("NPC  : " .. npcName)
            if npcName ~= lastFiredNPC then
                fireQuestAccept(npcName)
                fireSettings("EnableQuestRepeat", true)
                fireSettings("AutoQuestRepeat",   true)
                fireSettings("DisablePVP",        true)
                lastFiredNPC = npcName
                questLastLabel:SetText("Last : " .. npcName .. " ✔")
            end
        else
            questNPCLabel:SetText("NPC  : —")
        end
    end
end)

-- ==================== FARM V1 LOOP ====================

local isRunningV1 = false
local isRunningV2 = false
_G.islandFarmOn   = false

local function farmLoopV1()
    isRunningV1     = true
    _G.islandFarmOn = true
    enableFly()
    enableGameSettings()

    while Toggles.AutoFarm and Toggles.AutoFarm.Value do
        local island = Options.IslandSelect and Options.IslandSelect.Value
        local data   = island and ISLANDS[island]
        if not data then
            farmStatusLabel:SetText("⚠ Pilih pulau!")
            task.wait(0.5); continue
        end

        local coords     = data.coords
        local heightAdd  = Options.HeightOffset  and Options.HeightOffset.Value  or 0
        local tDelay     = Options.TeleportDelay and Options.TeleportDelay.Value or 1
        local lDelay     = Options.LoopDelay     and Options.LoopDelay.Value     or 3
        local tweenSpeed = Options.TweenSpeed    and Options.TweenSpeed.Value    or 150

        for i, pos in ipairs(coords) do
            if not (Toggles.AutoFarm and Toggles.AutoFarm.Value) then break end
            local finalPos = Vector3.new(pos.X, pos.Y + heightAdd, pos.Z)
            local root     = getRoot()
            local dist     = root and (root.Position - finalPos).Magnitude or 0
            farmStatusLabel:SetText((dist>100 and "🌀 " or "⚡ ") .. island .. " [" .. i .. "/" .. #coords .. "]")
            moveToPosition(finalPos, tweenSpeed)
            task.wait(tDelay)
        end

        if not (Toggles.AutoFarm and Toggles.AutoFarm.Value) then break end

        if lDelay > 0 then
            local endT = tick() + lDelay
            while tick() < endT and (Toggles.AutoFarm and Toggles.AutoFarm.Value) do
                farmStatusLabel:SetText("⏸ Cooldown " .. math.ceil(endT-tick()) .. "s")
                task.wait(0.1)
            end
        end
    end

    disableFly(); disableGameSettings()
    farmStatusLabel:SetText("—")
    _G.islandFarmOn = false
    isRunningV1     = false
end

-- ==================== FARM V2 LOOP ====================

local function farmLoopV2()
    isRunningV2     = true
    _G.islandFarmOn = true
    enableFly()
    enableGameSettings()

    while Toggles.AutoFarmV2 and Toggles.AutoFarmV2.Value do
        local island = Options.IslandSelect and Options.IslandSelect.Value
        local data   = island and ISLANDS[island]
        if not data then
            farmStatusLabel:SetText("⚠ Pilih pulau!")
            task.wait(0.5); continue
        end

        local heightAdd  = Options.HeightOffset and Options.HeightOffset.Value or 0
        local tweenSpeed = Options.TweenSpeed   and Options.TweenSpeed.Value   or 150
        local lDelay     = Options.LoopDelay    and Options.LoopDelay.Value    or 3

        local centerIdx = data.center
        local centerPos = data.coords[centerIdx]
        local finalPos  = Vector3.new(centerPos.X, centerPos.Y + heightAdd, centerPos.Z)

        local root = getRoot()
        local dist = root and (root.Position - finalPos).Magnitude or 0

        farmStatusLabel:SetText((dist>100 and "🌀 " or "📍 ") .. island .. " [center:" .. centerIdx .. "]")
        moveToPosition(finalPos, tweenSpeed)

        if lDelay > 0 then
            local endT = tick() + lDelay
            while tick() < endT and (Toggles.AutoFarmV2 and Toggles.AutoFarmV2.Value) do
                farmStatusLabel:SetText("📍 " .. island .. " [center:" .. centerIdx .. "] +" .. math.ceil(endT-tick()) .. "s")
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
    end

    disableFly(); disableGameSettings()
    farmStatusLabel:SetText("—")
    _G.islandFarmOn = false
    isRunningV2     = false
end

-- Watcher V1
task.spawn(function()
    local wasOn = false
    while task.wait(0.2) do
        local isOn = Toggles.AutoFarm and Toggles.AutoFarm.Value
        if isOn and not wasOn then
            if Toggles.AutoFarmV2 and Toggles.AutoFarmV2.Value then
                Toggles.AutoFarmV2:SetValue(false)
            end
            if not isRunningV1 then task.spawn(farmLoopV1) end
        elseif not isOn and wasOn then
            disableFly(); disableGameSettings()
        end
        wasOn = isOn
    end
end)

-- Watcher V2
task.spawn(function()
    local wasOn = false
    while task.wait(0.2) do
        local isOn = Toggles.AutoFarmV2 and Toggles.AutoFarmV2.Value
        if isOn and not wasOn then
            if Toggles.AutoFarm and Toggles.AutoFarm.Value then
                Toggles.AutoFarm:SetValue(false)
            end
            if not isRunningV2 then task.spawn(farmLoopV2) end
        elseif not isOn and wasOn then
            disableFly(); disableGameSettings()
        end
        wasOn = isOn
    end
end)

-- ==================== UI SETTINGS ====================

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Yi Da Mu Sake")
SaveManager:SetFolder("Yi Da Mu Sake/configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:Notify("Yi Da Mu Sake — sailor piece ✔")
