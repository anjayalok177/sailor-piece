-- YiDaMuSake Main Loader v8
local RAW = "https://raw.githubusercontent.com/anjayalok177/sailor-piece/refs/heads/main/"
local function load(file)
    return loadstring(game:HttpGet(RAW..file))()
end

-- Cleanup
pcall(function()
    local old=game:GetService("CoreGui"):FindFirstChild("YiDaMuSake")
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

-- Screen GUI
local gui = Instance.new("ScreenGui")
gui.Name = "YiDaMuSake"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true; gui.Parent = game:GetService("CoreGui")

local vp       = game.Workspace.CurrentCamera.ViewportSize
local WIN_W    = math.min(vp.X*0.88, 680)
local WIN_H    = math.min(vp.Y*0.64, 440)
local SIDEBAR_W = 64
local TOPBAR_H  = 48
local BOTBAR_H  = 24

-- Root
local root = Instance.new("Frame")
root.Name = "Root"; root.Size = UDim2.new(0,WIN_W,0,WIN_H)
root.Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
root.BackgroundColor3 = T.bg; root.BorderSizePixel = 0
root.ClipsDescendants = false; root.Active = true; root.Parent = gui
local rootCorner = Instance.new("UICorner",root)
rootCorner.CornerRadius = UDim.new(0,14)

local rootGlow = Instance.new("ImageLabel",root)
rootGlow.Size=UDim2.new(1,100,1,100); rootGlow.Position=UDim2.new(0.5,0,0.5,0)
rootGlow.AnchorPoint=Vector2.new(0.5,0.5); rootGlow.BackgroundTransparency=1
rootGlow.Image="rbxassetid://5028857084"; rootGlow.ImageColor3=T.accent
rootGlow.ImageTransparency=0.88; rootGlow.ZIndex=0
lib.regAccent("imgAccent",rootGlow)

local rootStroke = Instance.new("UIStroke",root)
rootStroke.Color=T.border; rootStroke.Thickness=1.5; rootStroke.Transparency=0.1
lib.regAccent("stAccent",rootStroke)

task.spawn(function()
    while rootGlow and rootGlow.Parent do
        lib.ease(rootGlow,{ImageTransparency=0.80},1.4):Play(); task.wait(1.5)
        lib.ease(rootGlow,{ImageTransparency=0.92},1.4):Play(); task.wait(1.5)
    end
end)
task.spawn(function()
    while rootStroke and rootStroke.Parent do
        lib.ease(rootStroke,{Color=T.borderBright,Transparency=0.0},1.6):Play(); task.wait(1.7)
        lib.ease(rootStroke,{Color=T.border,Transparency=0.2},1.6):Play(); task.wait(1.7)
    end
end)

local inner = Instance.new("Frame",root)
inner.Size=UDim2.new(1,0,1,0); inner.BackgroundTransparency=1
inner.ClipsDescendants=true; inner.ZIndex=1

local bgF = Instance.new("Frame",inner)
bgF.Size=UDim2.new(1,0,1,0); bgF.BackgroundColor3=T.bg
bgF.BorderSizePixel=0; bgF.ZIndex=1
Instance.new("UICorner",bgF).CornerRadius=UDim.new(0,14)
local bgGrad=Instance.new("UIGradient",bgF)
bgGrad.Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(14,10,26)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,7,14)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(12,9,20)),
}; bgGrad.Rotation=125

-- Blur
local screenBlur = Instance.new("BlurEffect")
screenBlur.Size=0; screenBlur.Parent=game.Workspace.CurrentCamera

-- KRITIS: miniBar forward-declared SEBELUM applyMiniBgMode/refreshBlur
local miniBar
local miniBarVisible=false

local function setBlur(sz,dur)
    TweenService:Create(screenBlur,TweenInfo.new(dur or 0.35,Enum.EasingStyle.Quint),{Size=sz}):Play()
end
local function refreshBlur()
    if miniBarVisible and UISettings.miniBgMode=="Blur" then setBlur(12)
    elseif not miniBarVisible and root.Visible and UISettings.uiBgMode=="Blur" then setBlur(18)
    else setBlur(0) end
end
local function applyUIBgMode(mode)
    UISettings.uiBgMode=mode
    if mode=="Solid" then
        lib.smooth(bgF,{BackgroundTransparency=0},0.3):Play()
        lib.smooth(root,{BackgroundTransparency=0},0.3):Play()
    elseif mode=="Transparent" then
        lib.smooth(bgF,{BackgroundTransparency=0.80},0.3):Play()
        lib.smooth(root,{BackgroundTransparency=0.60},0.3):Play()
    elseif mode=="Blur" then
        lib.smooth(bgF,{BackgroundTransparency=0.55},0.3):Play()
        lib.smooth(root,{BackgroundTransparency=0.35},0.3):Play()
    end; refreshBlur()
end
local function applyMiniBgMode(mode)
    UISettings.miniBgMode=mode
    if not miniBar then return end
    if mode=="Solid" then miniBar.BackgroundTransparency=0
    elseif mode=="Transparent" then miniBar.BackgroundTransparency=0.72
    elseif mode=="Blur" then miniBar.BackgroundTransparency=0.40 end
    if miniBarVisible then refreshBlur() end
end

-- Particles
local particleList={}
local function spawnParticles(count)
    for _,p in ipairs(particleList) do pcall(function() p:Destroy() end) end
    particleList={}; math.randomseed(tick())
    for i=1,count do
        task.spawn(function()
            task.wait(math.random(0,20)/10)
            local p=Instance.new("Frame")
            local sz=math.random(1,4)
            p.Size=UDim2.new(0,sz,0,sz)
            p.Position=UDim2.new(math.random(2,98)/100,0,math.random(2,98)/100,0)
            p.BackgroundColor3=Color3.fromHSV(math.random(258,295)/360,0.65,0.88)
            p.BackgroundTransparency=math.random(60,82)/100
            p.BorderSizePixel=0; p.ZIndex=1; p.Parent=bgF
            Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
            table.insert(particleList,p)
            while p and p.Parent do
                if not UISettings.particles then p.Visible=false; task.wait(0.5); continue end
                p.Visible=true
                local nx=math.clamp(p.Position.X.Scale+math.random(-7,7)/100,0.01,0.99)
                local ny=math.clamp(p.Position.Y.Scale+math.random(-7,7)/100,0.01,0.99)
                local dur=math.random(40,70)/10
                TweenService:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut,0,true),{
                    Position=UDim2.new(nx,0,ny,0),
                    BackgroundTransparency=math.random(44,80)/100,
                }):Play(); task.wait(dur)
            end
        end)
    end
end
spawnParticles(UISettings.particleCount)

-- Topbar
local topBar=Instance.new("Frame",inner)
topBar.Name="TopBar"; topBar.Size=UDim2.new(1,0,0,TOPBAR_H)
topBar.BackgroundColor3=Color3.fromRGB(9,8,16)
topBar.BorderSizePixel=0; topBar.ZIndex=5
Instance.new("UICorner",topBar).CornerRadius=UDim.new(0,14)
local topFix=Instance.new("Frame",topBar)
topFix.Size=UDim2.new(1,0,0,14); topFix.Position=UDim2.new(0,0,1,-14)
topFix.BackgroundColor3=Color3.fromRGB(9,8,16); topFix.BorderSizePixel=0; topFix.ZIndex=5
local topSep=Instance.new("Frame",inner)
topSep.Size=UDim2.new(1,0,0,1); topSep.Position=UDim2.new(0,0,0,TOPBAR_H)
topSep.BackgroundColor3=T.border; topSep.BackgroundTransparency=0.1
topSep.BorderSizePixel=0; topSep.ZIndex=6

-- Icon
local iconBg=Instance.new("Frame",topBar)
iconBg.Size=UDim2.new(0,28,0,28); iconBg.Position=UDim2.new(0,10,0.5,0)
iconBg.AnchorPoint=Vector2.new(0,0.5); iconBg.BackgroundColor3=T.accentSoft
iconBg.BorderSizePixel=0; iconBg.ZIndex=7
Instance.new("UICorner",iconBg).CornerRadius=UDim.new(0,7)
lib.regAccent("bgSoft",iconBg)
Instance.new("UIGradient",iconBg).Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accentSoft)
}
local iconImg=Instance.new("ImageLabel",iconBg)
iconImg.Size=UDim2.new(0.8,0,0.8,0); iconImg.Position=UDim2.new(0.5,0,0.5,0)
iconImg.AnchorPoint=Vector2.new(0.5,0.5); iconImg.BackgroundTransparency=1
iconImg.Image="rbxassetid://110843044052526"; iconImg.ZIndex=8

local titleL=Instance.new("TextLabel",topBar)
titleL.Size=UDim2.new(0,140,0,15); titleL.Position=UDim2.new(0,46,0,7)
titleL.BackgroundTransparency=1; titleL.Text="Yi Da Mu Sake"
titleL.TextColor3=T.text; titleL.Font=Enum.Font.GothamBold
titleL.TextSize=13; titleL.TextXAlignment=Enum.TextXAlignment.Left; titleL.ZIndex=7
local subL=Instance.new("TextLabel",topBar)
subL.Size=UDim2.new(0,140,0,11); subL.Position=UDim2.new(0,46,0,25)
subL.BackgroundTransparency=1; subL.Text="sailor piece  •  v8"
subL.TextColor3=T.textDim; subL.Font=Enum.Font.Gotham
subL.TextSize=9; subL.TextXAlignment=Enum.TextXAlignment.Left; subL.ZIndex=7

-- Search
local searchFrame=Instance.new("Frame",topBar)
searchFrame.Size=UDim2.new(0,140,0,26); searchFrame.Position=UDim2.new(0.5,-40,0.5,0)
searchFrame.AnchorPoint=Vector2.new(0,0.5); searchFrame.BackgroundColor3=Color3.fromRGB(14,13,22)
searchFrame.BorderSizePixel=0; searchFrame.ZIndex=8
Instance.new("UICorner",searchFrame).CornerRadius=UDim.new(0,7)
local searchStroke=Instance.new("UIStroke",searchFrame)
searchStroke.Color=T.border; searchStroke.Thickness=1.0; searchStroke.Transparency=0.2
local searchIcon=Instance.new("TextLabel",searchFrame)
searchIcon.Size=UDim2.new(0,22,1,0); searchIcon.BackgroundTransparency=1
searchIcon.Text="⌕"; searchIcon.TextColor3=T.textDim
searchIcon.Font=Enum.Font.GothamBold; searchIcon.TextSize=14; searchIcon.ZIndex=9
local searchBox=Instance.new("TextBox",searchFrame)
searchBox.Size=UDim2.new(1,-24,1,0); searchBox.Position=UDim2.new(0,22,0,0)
searchBox.BackgroundTransparency=1; searchBox.PlaceholderText="Search..."
searchBox.Text=""; searchBox.TextColor3=T.text
searchBox.PlaceholderColor3=T.textDim; searchBox.Font=Enum.Font.Gotham
searchBox.TextSize=11; searchBox.ZIndex=9; searchBox.ClearTextOnFocus=false

-- Window buttons
local function mkWinBtn(offX,col,sym)
    local b=Instance.new("TextButton",topBar)
    b.Size=UDim2.new(0,16,0,16); b.Position=UDim2.new(1,offX,0.5,0)
    b.AnchorPoint=Vector2.new(1,0.5); b.BackgroundColor3=col
    b.Text=""; b.BorderSizePixel=0; b.ZIndex=8
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    local l=Instance.new("TextLabel",b)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Text=sym
    l.TextColor3=T.white; l.Font=Enum.Font.GothamBold; l.TextSize=9; l.TextTransparency=0.4; l.ZIndex=9
    b.MouseEnter:Connect(function() lib.smooth(b,{BackgroundTransparency=0.15},0.1):Play(); lib.smooth(l,{TextTransparency=0},0.1):Play() end)
    b.MouseLeave:Connect(function() lib.smooth(b,{BackgroundTransparency=0},0.1):Play(); lib.smooth(l,{TextTransparency=0.4},0.1):Play() end)
    return b
end
local closeBtn=mkWinBtn(-10,Color3.fromRGB(198,50,62),"×")
local minBtn  =mkWinBtn(-32,Color3.fromRGB(185,138,22),"—")

-- Drag
do
    local drag,dragStart,startPos=false,nil,nil
    topBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; dragStart=i.Position; startPos=root.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

-- Resize
local rh=Instance.new("TextButton",root)
rh.Size=UDim2.new(0,18,0,18); rh.Position=UDim2.new(1,-2,1,-2); rh.AnchorPoint=Vector2.new(1,1)
rh.BackgroundColor3=Color3.fromRGB(22,20,34); rh.BackgroundTransparency=0.4
rh.Text=""; rh.BorderSizePixel=0; rh.ZIndex=20
Instance.new("UICorner",rh).CornerRadius=UDim.new(0,5)
for di=1,3 do
    local dot=Instance.new("Frame",rh)
    dot.Size=UDim2.new(0,2,0,2); dot.Position=UDim2.new(0,2+di*4,0,2+di*4)
    dot.BackgroundColor3=T.accentGlow; dot.BackgroundTransparency=0.4; dot.BorderSizePixel=0; dot.ZIndex=21
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
end
do
    local resizing,rsStart,rStartW,rStartH=false,nil,nil,nil
    local MIN_W,MIN_H=400,280
    rh.MouseButton1Down:Connect(function()
        resizing=true; rsStart=UIS:GetMouseLocation()
        rStartW=root.AbsoluteSize.X; rStartH=root.AbsoluteSize.Y
    end)
    UIS.InputChanged:Connect(function(i)
        if resizing and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local cur=(i.UserInputType==Enum.UserInputType.Touch) and i.Position or UIS:GetMouseLocation()
            WIN_W=math.clamp(rStartW+(cur.X-rsStart.X),MIN_W,vp.X*0.96)
            WIN_H=math.clamp(rStartH+(cur.Y-rsStart.Y),MIN_H,vp.Y*0.96)
            root.Size=UDim2.new(0,WIN_W,0,WIN_H)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then resizing=false end
    end)
end

-- Sidebar
local sidebar=Instance.new("Frame",inner)
sidebar.Name="Sidebar"; sidebar.Size=UDim2.new(0,SIDEBAR_W,1,-TOPBAR_H-1)
sidebar.Position=UDim2.new(0,0,0,TOPBAR_H+1)
sidebar.BackgroundColor3=Color3.fromRGB(9,8,16)
sidebar.BorderSizePixel=0; sidebar.ZIndex=4; sidebar.ClipsDescendants=true
Instance.new("UICorner",sidebar).CornerRadius=UDim.new(0,14)
local sideFix=Instance.new("Frame",sidebar)
sideFix.Size=UDim2.new(0,14,1,0); sideFix.Position=UDim2.new(1,-14,0,0)
sideFix.BackgroundColor3=Color3.fromRGB(9,8,16); sideFix.BorderSizePixel=0; sideFix.ZIndex=4
local sideVLine=Instance.new("Frame",inner)
sideVLine.Size=UDim2.new(0,1,1,-TOPBAR_H-1); sideVLine.Position=UDim2.new(0,SIDEBAR_W,0,TOPBAR_H+1)
sideVLine.BackgroundColor3=T.border; sideVLine.BackgroundTransparency=0.1
sideVLine.BorderSizePixel=0; sideVLine.ZIndex=6
local sideList=Instance.new("Frame",sidebar)
sideList.Size=UDim2.new(1,0,1,-8); sideList.Position=UDim2.new(0,0,0,10)
sideList.BackgroundTransparency=1; sideList.ZIndex=5
local slL=Instance.new("UIListLayout",sideList)
slL.Padding=UDim.new(0,4); slL.SortOrder=Enum.SortOrder.LayoutOrder
slL.HorizontalAlignment=Enum.HorizontalAlignment.Center
local slP=Instance.new("UIPadding",sideList)
slP.PaddingLeft=UDim.new(0,6); slP.PaddingRight=UDim.new(0,6)

local contentArea=Instance.new("Frame",inner)
contentArea.Name="ContentArea"
contentArea.Size=UDim2.new(1,-SIDEBAR_W-1,1,-TOPBAR_H-1)
contentArea.Position=UDim2.new(0,SIDEBAR_W+1,0,TOPBAR_H+1)
contentArea.BackgroundTransparency=1; contentArea.ZIndex=3

-- Sidebar tabs
local MAIN_TABS={
    {name="Info", sym="ⓘ", tip="Info"},
    {name="Main", sym="⌂",tip="Main"},
    {name="Settings",sym="⚙",tip="Settings"},
}
local sideData={}
local function switchMainTab(name)
    for _,d in pairs(sideData) do
        local on=(d.name==name)
        lib.smooth(d.iconBg,{BackgroundTransparency=on and 0 or 1},0.18):Play()
        lib.smooth(d.iconL,{TextColor3=on and T.white or T.textDim},0.18):Play()
        d.bar.Visible=on; d.page.Visible=on
    end
end
for i,tab in ipairs(MAIN_TABS) do
    local btn=Instance.new("TextButton",sideList)
    btn.Size=UDim2.new(1,0,0,50); btn.BackgroundTransparency=1
    btn.Text=""; btn.BorderSizePixel=0; btn.LayoutOrder=i; btn.ZIndex=6
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    local bar=Instance.new("Frame",btn)
    bar.Size=UDim2.new(0,3,0.45,0); bar.Position=UDim2.new(0,-4,0.5,0)
    bar.AnchorPoint=Vector2.new(0,0.5); bar.BackgroundColor3=T.accentGlow
    bar.BorderSizePixel=0; bar.Visible=false; bar.ZIndex=7
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    lib.regAccent("bgGlow",bar)
    local iconBg2=Instance.new("Frame",btn)
    iconBg2.Size=UDim2.new(0,38,0,38); iconBg2.Position=UDim2.new(0.5,0,0.5,0)
    iconBg2.AnchorPoint=Vector2.new(0.5,0.5); iconBg2.BackgroundColor3=T.accentSoft
    iconBg2.BackgroundTransparency=1; iconBg2.BorderSizePixel=0; iconBg2.ZIndex=6
    Instance.new("UICorner",iconBg2).CornerRadius=UDim.new(0,10)
    lib.regAccent("bgSoft",iconBg2)
    local iconL=Instance.new("TextLabel",btn)
    iconL.Size=UDim2.new(1,0,1,0); iconL.BackgroundTransparency=1
    iconL.Text=tab.sym; iconL.TextColor3=T.textDim
    iconL.Font=Enum.Font.GothamBold; iconL.TextSize=20; iconL.ZIndex=7
    local tooltip=Instance.new("TextLabel",btn)
    tooltip.Size=UDim2.new(0,65,0,20); tooltip.Position=UDim2.new(1,6,0.5,0)
    tooltip.AnchorPoint=Vector2.new(0,0.5); tooltip.BackgroundColor3=Color3.fromRGB(20,18,32)
    tooltip.TextColor3=T.text; tooltip.Text=tab.tip; tooltip.Font=Enum.Font.GothamBold
    tooltip.TextSize=10; tooltip.Visible=false; tooltip.ZIndex=50; tooltip.BorderSizePixel=0
    Instance.new("UICorner",tooltip).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",tooltip).Color=T.borderBright
    btn.MouseEnter:Connect(function() tooltip.Visible=true; lib.smooth(iconBg2,{BackgroundTransparency=0.85},0.12):Play() end)
    btn.MouseLeave:Connect(function()
        tooltip.Visible=false
        if not (sideData[tab.name] and sideData[tab.name].bar.Visible) then
            lib.smooth(iconBg2,{BackgroundTransparency=1},0.12):Play()
        end
    end)
    if i<#MAIN_TABS then
        local sep=Instance.new("Frame",btn)
        sep.Size=UDim2.new(0.5,0,0,1); sep.Position=UDim2.new(0.25,0,1,-1)
        sep.BackgroundColor3=T.border; sep.BackgroundTransparency=0.4; sep.BorderSizePixel=0; sep.ZIndex=7
    end
    local page=Instance.new("Frame",contentArea)
    page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.Visible=false; page.ZIndex=3
    sideData[tab.name]={name=tab.name,btn=btn,bar=bar,iconL=iconL,iconBg=iconBg2,page=page}
    btn.MouseButton1Click:Connect(function()
        lib.ripple(btn,btn.AbsoluteSize.X*0.5,btn.AbsoluteSize.Y*0.5,T.accent)
        switchMainTab(tab.name)
    end)
end

-- Search
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q=searchBox.Text:lower()
    local function scan(frame)
        for _,child in ipairs(frame:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                for _,item in ipairs(child:GetChildren()) do
                    if item:IsA("Frame") or item:IsA("TextButton") then
                        if q=="" then item.Visible=true
                        else
                            local hit=false
                            for _,desc in ipairs(item:GetDescendants()) do
                                if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text:lower():find(q,1,true) then
                                    hit=true; break
                                end
                            end
                            item.Visible=hit
                        end
                    end
                end
            elseif child:IsA("Frame") then scan(child) end
        end
    end
    for _,d in pairs(sideData) do if d.page then scan(d.page) end end
end)

-- Bottom bar
local botBar=Instance.new("Frame",inner)
botBar.Size=UDim2.new(1,0,0,BOTBAR_H); botBar.Position=UDim2.new(0,0,1,-BOTBAR_H)
botBar.BackgroundColor3=Color3.fromRGB(8,7,14); botBar.BorderSizePixel=0; botBar.ZIndex=5
Instance.new("UICorner",botBar).CornerRadius=UDim.new(0,14)
local botFix=Instance.new("Frame",botBar)
botFix.Size=UDim2.new(1,0,0,14); botFix.BackgroundColor3=Color3.fromRGB(8,7,14); botFix.BorderSizePixel=0; botFix.ZIndex=5
local verL=Instance.new("TextLabel",botBar)
verL.Size=UDim2.new(0.5,0,1,0); verL.Position=U​​​​​​​​​​​​​​​​
