-- ╔══════════════════════════════════════════════════════════╗
-- ║                      Yi Da Mu Sake                       ║
-- ╚══════════════════════════════════════════════════════════╝

local RAW = "https://raw.githubusercontent.com/anjayalok177/sailor-piece/refs/heads/main/"
local function load(file)
    return loadstring(game:HttpGet(RAW..file))()
end

-- Cleanup
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("YiDaMuSake")
    if old then old:Destroy() end
end)
pcall(function()
    for _,e in ipairs(game.Workspace.CurrentCamera:GetChildren()) do
        if e:IsA("BlurEffect") then e:Destroy() end
    end
end)

local lib        = load("ui_lib.lua")
local T          = lib.T
local UISettings = lib.UISettings

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local player       = Players.LocalPlayer

-- =====================
-- SCREEN GUI
-- =====================
local gui = Instance.new("ScreenGui")
gui.Name = "YiDaMuSake"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true; gui.Parent = game:GetService("CoreGui")

local vp        = game.Workspace.CurrentCamera.ViewportSize
local WIN_W     = math.min(vp.X*0.88, 700)
local WIN_H     = math.min(vp.Y*0.64, 440)
local SIDEBAR_W = 70; local TOPBAR_H = 48; local BOTBAR_H = 28

-- =====================
-- ROOT FRAME
-- =====================
local root = Instance.new("Frame")
root.Name  = "Root"; root.Size = UDim2.new(0,WIN_W,0,WIN_H)
root.Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
root.BackgroundColor3 = T.bg; root.BorderSizePixel = 0
root.ClipsDescendants = false; root.Active = true; root.Parent = gui
local rootCorner = Instance.new("UICorner", root)
rootCorner.CornerRadius = UDim.new(0,16)

local rootGlow = Instance.new("ImageLabel", root)
rootGlow.Size = UDim2.new(1,110,1,110); rootGlow.Position = UDim2.new(0.5,0,0.5,0)
rootGlow.AnchorPoint = Vector2.new(0.5,0.5); rootGlow.BackgroundTransparency = 1
rootGlow.Image = "rbxassetid://5028857084"; rootGlow.ImageColor3 = T.accent
rootGlow.ImageTransparency = 0.85; rootGlow.ZIndex = 0
lib.regAccent("imgAccent", rootGlow)

local rootStroke = Instance.new("UIStroke", root)
rootStroke.Color = T.border; rootStroke.Thickness = 1.8; rootStroke.Transparency = 0.1
lib.regAccent("stAccent", rootStroke)

local inner = Instance.new("Frame", root)
inner.Size = UDim2.new(1,0,1,0); inner.BackgroundTransparency = 1
inner.ClipsDescendants = true; inner.ZIndex = 1

local bgF = Instance.new("Frame", inner)
bgF.Size = UDim2.new(1,0,1,0); bgF.BackgroundColor3 = T.bg
bgF.BorderSizePixel = 0; bgF.ZIndex = 1
Instance.new("UICorner", bgF).CornerRadius = UDim.new(0,16)
local bgGrad = Instance.new("UIGradient", bgF)
bgGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(13,10,25)),
    ColorSequenceKeypoint.new(0.45,Color3.fromRGB(7, 6, 15)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(11,8, 21)),
}
bgGrad.Rotation = 130
task.spawn(function()
    local r = 130
    while bgGrad and bgGrad.Parent do r=r+0.06; bgGrad.Rotation=r; task.wait(0.05) end
end)
task.spawn(function()
    while rootGlow and rootGlow.Parent do
        lib.ease(rootGlow,{ImageTransparency=0.78},1.2):Play(); task.wait(1.3)
        lib.ease(rootGlow,{ImageTransparency=0.90},1.2):Play(); task.wait(1.3)
    end
end)
task.spawn(function()
    while rootStroke and rootStroke.Parent do
        lib.ease(rootStroke,{Color=T.borderBright,Transparency=0.0},1.4):Play(); task.wait(1.5)
        lib.ease(rootStroke,{Color=T.border,Transparency=0.2},1.4):Play(); task.wait(1.5)
    end
end)

-- =====================
-- BLUR (satu BlurEffect — frosted glass iPhone style)
-- BlurEffect memblur world 3D di belakang ScreenGui.
-- ScreenGui / UI elements sendiri tetap tajam.
-- =====================
local screenBlur = Instance.new("BlurEffect")
screenBlur.Size  = 0
screenBlur.Parent = game.Workspace.CurrentCamera

local function setBlur(targetSize, dur)
    TweenService:Create(screenBlur,
        TweenInfo.new(dur or 0.35, Enum.EasingStyle.Quint),
        {Size = targetSize}):Play()
end

-- =====================
-- FORWARD DECLARATIONS
-- Wajib dideklarasi sebelum fungsi applyMiniBgMode / refreshBlur
-- agar Lua melihatnya sebagai upvalue yang benar.
-- =====================
local miniBar           -- akan di-assign di bawah
local miniBarVisible = false

-- =====================
-- BLUR REFRESH
-- =====================
local function refreshBlur()
    if miniBarVisible and UISettings.miniBgMode == "Blur" then
        setBlur(12)
    elseif not miniBarVisible and root.Visible
        and UISettings.uiBgMode == "Blur" then
        setBlur(18)
    else
        setBlur(0)
    end
end

-- =====================
-- BG MODE FUNCTIONS
-- =====================
local function applyUIBgMode(mode)
    UISettings.uiBgMode = mode
    if mode == "Solid" then
        lib.smooth(bgF,  {BackgroundTransparency=0   }, 0.3):Play()
        lib.smooth(root, {BackgroundTransparency=0   }, 0.3):Play()
    elseif mode == "Transparent" then
        lib.smooth(bgF,  {BackgroundTransparency=0.80}, 0.3):Play()
        lib.smooth(root, {BackgroundTransparency=0.60}, 0.3):Play()
    elseif mode == "Blur" then
        lib.smooth(bgF,  {BackgroundTransparency=0.55}, 0.3):Play()
        lib.smooth(root, {BackgroundTransparency=0.35}, 0.3):Play()
    end
    refreshBlur()
end

local function applyMiniBgMode(mode)
    UISettings.miniBgMode = mode
    -- miniBar sudah pasti assigned saat fungsi ini dipanggil (user action)
    if not miniBar then return end
    if mode == "Solid" then
        miniBar.BackgroundTransparency = 0
    elseif mode == "Transparent" then
        miniBar.BackgroundTransparency = 0.72
    elseif mode == "Blur" then
        -- semi-transparan agar world 3D yang diblur terlihat di baliknya
        miniBar.BackgroundTransparency = 0.40
    end
    if miniBarVisible then refreshBlur() end
end

-- =====================
-- PARTICLES
-- =====================
local particleList = {}
local function spawnParticles(count)
    for _,p in ipairs(particleList) do pcall(function() p:Destroy() end) end
    particleList = {}
    math.randomseed(tick())
    for i = 1, count do
        task.spawn(function()
            task.wait(math.random(0,20)/10)
            local p  = Instance.new("Frame")
            local sz = math.random(2,5)
            p.Size   = UDim2.new(0,sz,0,sz)
            p.Position = UDim2.new(math.random(2,98)/100,0,math.random(2,98)/100,0)
            p.BackgroundColor3 = Color3.fromHSV(math.random(258,294)/360,0.68,0.9)
            p.BackgroundTransparency = math.random(55,80)/100
            p.BorderSizePixel = 0; p.ZIndex = 1; p.Parent = bgF
            Instance.new("UICorner",p).CornerRadius = UDim.new(1,0)
            table.insert(particleList, p)
            while p and p.Parent do
                if not UISettings.particles then p.Visible=false; task.wait(0.5); continue end
                p.Visible = true
                local nx = math.clamp(p.Position.X.Scale+math.random(-8,8)/100,0.01,0.99)
                local ny = math.clamp(p.Position.Y.Scale+math.random(-8,8)/100,0.01,0.99)
                local dur = math.random(36,62)/10
                TweenService:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut,0,true),{
                    Position=UDim2.new(nx,0,ny,0),
                    BackgroundTransparency=math.random(40,78)/100,
                }):Play()
                task.wait(dur)
            end
        end)
    end
end
spawnParticles(UISettings.particleCount)

-- =====================
-- TOPBAR
-- =====================
local topBar = Instance.new("Frame", inner)
topBar.Name = "TopBar"; topBar.Size = UDim2.new(1,0,0,TOPBAR_H)
topBar.BackgroundColor3 = Color3.fromRGB(11,9,20)
topBar.BorderSizePixel = 0; topBar.ZIndex = 5
Instance.new("UICorner",topBar).CornerRadius = UDim.new(0,16)
local topFix = Instance.new("Frame",topBar)
topFix.Size = UDim2.new(1,0,0,16); topFix.Position = UDim2.new(0,0,1,-16)
topFix.BackgroundColor3 = Color3.fromRGB(11,9,20); topFix.BorderSizePixel=0; topFix.ZIndex=5
Instance.new("UIGradient",topBar).Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(18,14,32)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(10,8,18)),
}
local topSep = Instance.new("Frame",inner)
topSep.Size = UDim2.new(1,0,0,1.5); topSep.Position = UDim2.new(0,0,0,TOPBAR_H)
topSep.BackgroundColor3 = T.borderBright; topSep.BackgroundTransparency = 0.05
topSep.BorderSizePixel = 0; topSep.ZIndex = 6

local iconBg = Instance.new("Frame",topBar)
iconBg.Size = UDim2.new(0,30,0,30); iconBg.Position = UDim2.new(0,13,0.5,0)
iconBg.AnchorPoint = Vector2.new(0,0.5); iconBg.BackgroundColor3 = T.accentSoft
iconBg.BorderSizePixel = 0; iconBg.ZIndex = 7
Instance.new("UICorner",iconBg).CornerRadius = UDim.new(0,8)
lib.regAccent("bgSoft",iconBg)
local iconImg = Instance.new("ImageLabel",iconBg)
iconImg.Size = UDim2.new(0.76,0,0.76,0); iconImg.Position = UDim2.new(0.5,0,0.5,0)
iconImg.AnchorPoint = Vector2.new(0.5,0.5); iconImg.BackgroundTransparency = 1
iconImg.Image = "rbxassetid://110843044052526"; iconImg.ZIndex = 8

local titleL = Instance.new("TextLabel",topBar)
titleL.Size = UDim2.new(0,170,0,18); titleL.Position = UDim2.new(0,51,0,7)
titleL.BackgroundTransparency = 1; titleL.Text = "Yi Da Mu Sake"
titleL.TextColor3 = T.text; titleL.Font = Enum.Font.GothamBold
titleL.TextSize = 13; titleL.TextXAlignment = Enum.TextXAlignment.Left; titleL.ZIndex = 7
local subL = Instance.new("TextLabel",topBar)
subL.Size = UDim2.new(0,170,0,13); subL.Position = UDim2.new(0,51,0,27)
subL.BackgroundTransparency = 1; subL.Text = "sailor piece  •  v6"
subL.TextColor3 = T.textDim; subL.Font = Enum.Font.Gotham
subL.TextSize = 10; subL.TextXAlignment = Enum.TextXAlignment.Left; subL.ZIndex = 7

local function mkWinBtn(offX,col,sym)
    local b = Instance.new("TextButton",topBar)
    b.Size = UDim2.new(0,20,0,20); b.Position = UDim2.new(1,offX,0.5,0)
    b.AnchorPoint = Vector2.new(1,0.5); b.BackgroundColor3 = col
    b.Text = ""; b.BorderSizePixel = 0; b.ZIndex = 8
    Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
    local lbl = Instance.new("TextLabel",b)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = sym
    lbl.TextColor3 = T.white; lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10; lbl.TextTransparency = 0.3; lbl.ZIndex = 9
    b.MouseEnter:Connect(function()
        lib.smooth(b,{BackgroundTransparency=0.22},0.13):Play()
        lib.smooth(lbl,{TextTransparency=0},0.13):Play()
    end)
    b.MouseLeave:Connect(function()
        lib.smooth(b,{BackgroundTransparency=0},0.13):Play()
        lib.smooth(lbl,{TextTransparency=0.3},0.13):Play()
    end)
    return b
end
local closeBtn = mkWinBtn(-10, Color3.fromRGB(200,52,65), "×")
local minBtn   = mkWinBtn(-38, Color3.fromRGB(190,140,25), "—")

-- =====================
-- DRAG
-- =====================
do
    local drag,dragStart,startPos = false,nil,nil
    topBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; dragStart=i.Position; startPos=root.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

-- =====================
-- RESIZE HANDLE
-- =====================
local rh = Instance.new("TextButton",root)
rh.Name = "ResizeHandle"; rh.Size = UDim2.new(0,22,0,22)
rh.Position = UDim2.new(1,-2,1,-2); rh.AnchorPoint = Vector2.new(1,1)
rh.BackgroundColor3 = Color3.fromRGB(28,24,44); rh.BackgroundTransparency = 0.3
rh.Text = ""; rh.BorderSizePixel = 0; rh.ZIndex = 20
Instance.new("UICorner",rh).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke",rh).Color = T.border
for di = 1,3 do
    local dot = Instance.new("Frame",rh)
    dot.Size = UDim2.new(0,3,0,3); dot.Position = UDim2.new(0,3+di*4,0,3+di*4)
    dot.BackgroundColor3 = T.accentGlow; dot.BackgroundTransparency = 0.3
    dot.BorderSizePixel = 0; dot.ZIndex = 21
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)
end
do
    local resizing,rsStart,rStartW,rStartH = false,nil,nil,nil
    local MIN_W,MIN_H = 400,280
    rh.MouseButton1Down:Connect(function()
        resizing=true; rsStart=UIS:GetMouseLocation()
        rStartW=root.AbsoluteSize.X; rStartH=root.AbsoluteSize.Y
    end)
    UIS.InputChanged:Connect(function(i)
        if resizing and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local cur=(i.UserInputType==Enum.UserInputType.Touch) and i.Position or UIS:GetMouseLocation()
            WIN_W=math.clamp(rStartW+(cur.X-rsStart.X),MIN_W,vp.X*0.96)
            WIN_H=math.clamp(rStartH+(cur.Y-rsStart.Y),MIN_H,vp.Y*0.96)
            root.Size=UDim2.new(0,WIN_W,0,WIN_H)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then resizing=false end
    end)
end

-- =====================
-- MINIMIZE BAR
-- (miniBar di-assign di sini, setelah forward declaration di atas)
-- =====================
local miniExpLbl = nil

miniBar = Instance.new("Frame", gui)   -- assign ke forward-declared local
miniBar.Size     = UDim2.new(0,46,0,46)
miniBar.Position = UDim2.new(0.5,-23,0,8)
miniBar.BackgroundColor3 = Color3.fromRGB(13,11,22)
miniBar.BorderSizePixel  = 0
miniBar.ZIndex   = 200
miniBar.Visible  = false
Instance.new("UICorner",miniBar).CornerRadius = UDim.new(0,23)
local miniStroke = Instance.new("UIStroke",miniBar)
miniStroke.Color = T.borderBright; miniStroke.Thickness = 1.8; miniStroke.Transparency = 0.1

local miniGlow = Instance.new("ImageLabel",miniBar)
miniGlow.Size = UDim2.new(1,36,1,36); miniGlow.Position = UDim2.new(0.5,0,0.5,0)
miniGlow.AnchorPoint = Vector2.new(0.5,0.5); miniGlow.BackgroundTransparency = 1
miniGlow.Image = "rbxassetid://5028857084"; miniGlow.ImageColor3 = T.accent
miniGlow.ImageTransparency = 0.82; miniGlow.ZIndex = 0
lib.regAccent("imgAccent",miniGlow)

local miniIconBg = Instance.new("Frame",miniBar)
miniIconBg.Size = UDim2.new(0,36,0,36); miniIconBg.Position = UDim2.new(0,5,0.5,0)
miniIconBg.AnchorPoint = Vector2.new(0,0.5); miniIconBg.BackgroundColor3 = T.accentSoft
miniIconBg.BorderSizePixel = 0; miniIconBg.ZIndex = 201
Instance.new("UICorner",miniIconBg).CornerRadius = UDim.new(0,9)
lib.regAccent("bgSoft",miniIconBg)
local miniIconStroke = Instance.new("UIStroke",miniIconBg)
miniIconStroke.Color = T.accentGlow; miniIconStroke.Thickness = 1.5; miniIconStroke.Transparency = 0.3
lib.regAccent("stGlow",miniIconStroke)
Instance.new("UIGradient",miniIconBg).Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,T.accentGlow),
    ColorSequenceKeypoint.new(1,T.accentSoft),
}
local miniIconImg = Instance.new("ImageLabel",miniIconBg)
miniIconImg.Size = UDim2.new(0.82,0,0.82,0); miniIconImg.Position = UDim2.new(0.5,0,0.5,0)
miniIconImg.AnchorPoint = Vector2.new(0.5,0.5); miniIconImg.BackgroundTransparency = 1
miniIconImg.Image = "rbxassetid://110843044052526"; miniIconImg.ZIndex = 202

local miniHit = Instance.new("TextButton",miniBar)
miniHit.Size = UDim2.new(1,0,1,0); miniHit.BackgroundTransparency = 1
miniHit.Text = ""; miniHit.ZIndex = 203

task.spawn(function()
    while miniBar and miniBar.Parent do
        if miniBar.Visible then
            lib.ease(miniGlow,{ImageTransparency=0.72},0.9):Play(); task.wait(1.0)
            lib.ease(miniGlow,{ImageTransparency=0.88},0.9):Play(); task.wait(1.0)
        else task.wait(0.5) end
    end
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    setBlur(0, 0.2)
    lib.smooth(root,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.24):Play()
    task.wait(0.26); gui:Destroy()
    pcall(function() screenBlur:Destroy() end)
end)

-- Minimize
minBtn.MouseButton1Click:Connect(function()
    miniBarVisible = true
    lib.smooth(root,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.24):Play()
    task.wait(0.22)
    root.Visible = false
    -- Apply BG mode dan blur
    applyMiniBgMode(UISettings.miniBgMode)
    -- Reset size dan position, lalu tampilkan
    miniBar.Size     = UDim2.new(0,46,0,46)
    miniBar.Position = UDim2.new(0.5,-23,0,8)
    miniBar.Visible  = true
    -- Animasi expand ke kanan
    lib.spring(miniBar,{Size=UDim2.new(0,230,0,46)},0.46):Play()
    task.spawn(function()
        task.wait(0.12)
        lib.smooth(miniBar,{Position=UDim2.new(0.5,-115,0,8)},0.22):Play()
    end)
    -- Teks label
    task.spawn(function()
        task.wait(0.22)
        if miniExpLbl then miniExpLbl:Destroy(); miniExpLbl=nil end
        miniExpLbl = Instance.new("TextLabel",miniBar)
        miniExpLbl.Size = UDim2.new(1,-50,1,0)
        miniExpLbl.Position = UDim2.new(0,46,0,0)
        miniExpLbl.BackgroundTransparency = 1
        miniExpLbl.Text = "Yi Da Mu Sake"
        miniExpLbl.TextColor3 = T.text
        miniExpLbl.Font = Enum.Font.GothamBold
        miniExpLbl.TextSize = 13
        miniExpLbl.TextXAlignment = Enum.TextXAlignment.Center
        miniExpLbl.TextTransparency = 1; miniExpLbl.ZIndex = 202
        lib.smooth(miniExpLbl,{TextTransparency=0},0.26):Play()
    end)
end)

-- Restore dari minimize
miniHit.MouseButton1Click:Connect(function()
    miniBarVisible = false
    refreshBlur()   -- matikan blur
    if miniExpLbl then
        lib.smooth(miniExpLbl,{TextTransparency=1},0.14):Play()
        task.wait(0.12)
        pcall(function()
            if miniExpLbl then miniExpLbl:Destroy(); miniExpLbl=nil end
        end)
    end
    lib.smooth(miniBar,
        {Size=UDim2.new(0,46,0,46),Position=UDim2.new(0.5,-23,0,8)},
        0.20):Play()
    task.wait(0.20)
    miniBar.Visible = false
    root.Visible    = true
    root.Size       = UDim2.new(0,WIN_W,0,0)
    root.BackgroundTransparency = 1
    lib.spring(root,{Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0},0.44):Play()
    task.delay(0.5, function() applyUIBgMode(UISettings.uiBgMode) end)
end)

-- =====================
-- SIDEBAR
-- =====================
local sidebar = Instance.new("Frame",inner)
sidebar.Name = "Sidebar"; sidebar.Size = UDim2.new(0,SIDEBAR_W,1,-TOPBAR_H-1)
sidebar.Position = UDim2.new(0,0,0,TOPBAR_H+1)
sidebar.BackgroundColor3 = Color3.fromRGB(10,9,18)
sidebar.BorderSizePixel = 0; sidebar.ZIndex = 4; sidebar.ClipsDescendants = true
Instance.new("UICorner",sidebar).CornerRadius = UDim.new(0,16)
local sideFix = Instance.new("Frame",sidebar)
sideFix.Size = UDim2.new(0,16,1,0); sideFix.Position = UDim2.new(1,-16,0,0)
sideFix.BackgroundColor3 = Color3.fromRGB(10,9,18); sideFix.BorderSizePixel=0; sideFix.ZIndex=4

local sideVLine = Instance.new("Frame",inner)
sideVLine.Size = UDim2.new(0,1.5,1,-TOPBAR_H-1)
sideVLine.Position = UDim2.new(0,SIDEBAR_W,0,TOPBAR_H+1)
sideVLine.BackgroundColor3 = T.borderBright; sideVLine.BackgroundTransparency = 0.0
sideVLine.BorderSizePixel = 0; sideVLine.ZIndex = 6

local sideList = Instance.new("Frame",sidebar)
sideList.Size = UDim2.new(1,0,1,-8); sideList.Position = UDim2.new(0,0,0,8)
sideList.BackgroundTransparency = 1; sideList.ZIndex = 5
local slL = Instance.new("UIListLayout",sideList)
slL.Padding = UDim.new(0,2); slL.SortOrder = Enum.SortOrder.LayoutOrder
slL.HorizontalAlignment = Enum.HorizontalAlignment.Center
local slP = Instance.new("UIPadding",sideList)
slP.PaddingLeft=UDim.new(0,5); slP.PaddingRight=UDim.new(0,5); slP.PaddingTop=UDim.new(0,4)

local contentArea = Instance.new("Frame",inner)
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1,-SIDEBAR_W-1.5,1,-TOPBAR_H-1)
contentArea.Position = UDim2.new(0,SIDEBAR_W+1.5,0,TOPBAR_H+1)
contentArea.BackgroundTransparency = 1; contentArea.ZIndex = 3

-- =====================
-- MAIN SIDEBAR TABS
-- =====================
local MAIN_TABS = {
    {name="Info",     sym="i", label="Info"},
    {name="Main",     sym="⚙", label="Main"},
    {name="Settings", sym="≡", label="Set"},
}
local sideData = {}
local function switchMainTab(name)
    for _,d in pairs(sideData) do
        local on = (d.name == name)
        lib.smooth(d.btn,{BackgroundColor3=on and T.accent or Color3.fromRGB(20,18,32)},0.22):Play()
        lib.smooth(d.btn,{BackgroundTransparency=on and 0 or 1},0.22):Play()
        lib.smooth(d.nameLbl,{TextColor3=on and T.white or T.textDim},0.22):Play()
        lib.smooth(d.iconLbl,{TextColor3=on and T.white or T.textDim},0.22):Play()
        d.bar.Visible=on; d.page.Visible=on
    end
end
for i,tab in ipairs(MAIN_TABS) do
    local btn = Instance.new("TextButton",sideList)
    btn.Size = UDim2.new(1,0,0,54); btn.BackgroundColor3 = Color3.fromRGB(20,18,32)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.BorderSizePixel = 0
    btn.LayoutOrder = i; btn.ZIndex = 6
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,10)
    local bar = Instance.new("Frame",btn)
    bar.Size = UDim2.new(0,3,0.50,0); bar.Position = UDim2.new(0,-3,0.5,0)
    bar.AnchorPoint = Vector2.new(0,0.5); bar.BackgroundColor3 = T.accentGlow
    bar.BorderSizePixel = 0; bar.Visible = false; bar.ZIndex = 7
    Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)
    lib.regAccent("bgGlow",bar)
    if i < #MAIN_TABS then
        local sep = Instance.new("Frame",btn)
        sep.Size = UDim2.new(0.65,0,0,1); sep.Position = UDim2.new(0.175,0,1,-1)
        sep.BackgroundColor3 = T.border; sep.BackgroundTransparency = 0.35
        sep.BorderSizePixel = 0; sep.ZIndex = 7
    end
    local iconL = Instance.new("TextLabel",btn)
    iconL.Size = UDim2.new(1,0,0,22); iconL.Position = UDim2.new(0,0,0,6)
    iconL.BackgroundTransparency=1; iconL.Text=tab.sym; iconL.TextColor3=T.textDim
    iconL.Font=Enum.Font.GothamBold; iconL.TextSize=15; iconL.ZIndex=7
    local nameL = Instance.new("TextLabel",btn)
    nameL.Size = UDim2.new(1,0,0,13); nameL.Position = UDim2.new(0,0,0,30)
    nameL.BackgroundTransparency=1; nameL.Text=tab.label; nameL.TextColor3=T.textDim
    nameL.Font=Enum.Font.GothamBold; nameL.TextSize=9; nameL.ZIndex=7
    local page = Instance.new("Frame",contentArea)
    page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1
    page.Visible=false; page.ZIndex=3
    sideData[tab.name]={name=tab.name,btn=btn,bar=bar,iconLbl=iconL,nameLbl=nameL,page=page}
    btn.MouseButton1Click:Connect(function()
        lib.ripple(btn,btn.AbsoluteSize.X*0.5,btn.AbsoluteSize.Y*0.5,T.accent)
        switchMainTab(tab.name)
    end)
end

-- =====================
-- BOTTOM BAR
-- =====================
local botBar = Instance.new("Frame",inner)
botBar.Size = UDim2.new(1,0,0,BOTBAR_H); botBar.Position = UDim2.new(0,0,1,-BOTBAR_H)
botBar.BackgroundColor3 = Color3.fromRGB(9,8,17); botBar.BorderSizePixel=0; botBar.ZIndex=5
Instance.new("UICorner",botBar).CornerRadius = UDim.new(0,16)
local botFix = Instance.new("Frame",botBar)
botFix.Size = UDim2.new(1,0,0,16); botFix.BackgroundColor3=Color3.fromRGB(9,8,17)
botFix.BorderSizePixel=0; botFix.ZIndex=5
local verL = Instance.new("TextLabel",botBar)
verL.Size=UDim2.new(0.5,0,1,0); verL.Position=UDim2.new(0,12,0,0)
verL.BackgroundTransparency=1; verL.Text="sailor piece  v6"
verL.TextColor3=T.textDim; verL.Font=Enum.Font.Gotham; verL.TextSize=9
verL.TextXAlignment=Enum.TextXAlignment.Left; verL.ZIndex=6
local dotL = Instance.new("TextLabel",botBar)
dotL.Size=UDim2.new(0.5,-12,1,0); dotL.Position=UDim2.new(0.5,0,0,0)
dotL.BackgroundTransparency=1; dotL.Text="● online"
dotL.TextColor3=T.green; dotL.Font=Enum.Font.GothamBold
dotL.TextSize=9; dotL.TextXAlignment=Enum.TextXAlignment.Right; dotL.ZIndex=6
task.spawn(function()
    while dotL and dotL.Parent do
        lib.ease(dotL,{TextColor3=T.green},0.8):Play(); task.wait(0.95)
        lib.ease(dotL,{TextColor3=T.greenDim},0.8):Play(); task.wait(0.95)
    end
end)

-- =====================
-- ENTRANCE
-- =====================
root.BackgroundTransparency=1; root.Size=UDim2.new(0,WIN_W,0,0)
task.wait(0.1)
lib.spring(root,{Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0},0.54):Play()
switchMainTab("Info")

-- =====================
-- LOAD PAGES + LOGIC
-- =====================
local buildPages = load("pages.lua")
local refs = buildPages(
    lib, sideData, contentArea,
    bgF, root, rootCorner, rootStroke, rootGlow,
    particleList, spawnParticles,
    applyUIBgMode, applyMiniBgMode
)

local startLogic = load("logic.lua")
startLogic(refs, T)

_G.YiUI = refs
print("[YiDaMuSake] v6 loaded!")
