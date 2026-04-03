-- Yi Da Mu Sake | UIFrame.lua
-- Creates GUI frame + builds all pages
-- Requires: _G.YiLib, _G.YiData
-- Sets: _G.YiUI

local lib  = _G.YiLib
local data = _G.YiData
local T    = lib.T

local smooth=lib.smooth; local spring=lib.spring; local ease=lib.ease; local ripple=lib.ripple
local regAccent=lib.regAccent
local mkScrollPage=lib.mkScrollPage; local mkGroupBox=lib.mkGroupBox; local mkSectionLabel=lib.mkSectionLabel
local mkSection=lib.mkSection; local mkStatus=lib.mkStatus; local mkToggle=lib.mkToggle
local mkSlider=lib.mkSlider; local mkOnOffBtn=lib.mkOnOffBtn; local mkDropdownV2=lib.mkDropdownV2; local mkSubTabBar=lib.mkSubTabBar

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local vp  = game.Workspace.CurrentCamera.ViewportSize

local WIN_W=math.min(vp.X*0.88,700); local WIN_H=math.min(vp.Y*0.64,440)
local MIN_W,MIN_H=400,280; local MAX_W=vp.X*0.96; local MAX_H=vp.Y*0.96
local SIDEBAR_W=70; local TOPBAR_H=48; local BOTBAR_H=28

local UISettings={particles=true,particleCount=26,uiBgMode="Solid",miniBgMode="Solid"}
_G.YiSettings=UISettings

pcall(function() local o=game:GetService("CoreGui"):FindFirstChild("YiDaMuSake"); if o then o:Destroy() end end)

-- GUI ROOT
local gui=Instance.new("ScreenGui"); gui.Name="YiDaMuSake"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset=true; gui.Parent=game:GetService("CoreGui")
local root=Instance.new("Frame"); root.Name="Root"; root.Size=UDim2.new(0,WIN_W,0,WIN_H); root.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2); root.BackgroundColor3=T.bg; root.BorderSizePixel=0; root.ClipsDescendants=false; root.Active=true; root.Parent=gui
local rootCorner=Instance.new("UICorner",root); rootCorner.CornerRadius=UDim.new(0,16)
local rootGlow=Instance.new("ImageLabel"); rootGlow.Size=UDim2.new(1,110,1,110); rootGlow.Position=UDim2.new(0.5,0,0.5,0); rootGlow.AnchorPoint=Vector2.new(0.5,0.5); rootGlow.BackgroundTransparency=1; rootGlow.Image="rbxassetid://5028857084"; rootGlow.ImageColor3=T.accent; rootGlow.ImageTransparency=0.85; rootGlow.ZIndex=0; rootGlow.Parent=root
regAccent("imgAccent",rootGlow)
task.spawn(function() while rootGlow and rootGlow.Parent do ease(rootGlow,{ImageTransparency=0.78},1.2):Play(); task.wait(1.3); ease(rootGlow,{ImageTransparency=0.90},1.2):Play(); task.wait(1.3) end end)
local rootStroke=Instance.new("UIStroke",root); rootStroke.Color=T.border; rootStroke.Thickness=1.8; rootStroke.Transparency=0.1; regAccent("stAccent",rootStroke)
task.spawn(function() while rootStroke and rootStroke.Parent do ease(rootStroke,{Color=T.borderBright,Transparency=0.0},1.4):Play(); task.wait(1.5); ease(rootStroke,{Color=T.border,Transparency=0.2},1.4):Play(); task.wait(1.5) end end)
local inner=Instance.new("Frame"); inner.Name="Inner"; inner.Size=UDim2.new(1,0,1,0); inner.BackgroundTransparency=1; inner.ClipsDescendants=true; inner.ZIndex=1; inner.Parent=root
local bgF=Instance.new("Frame"); bgF.Size=UDim2.new(1,0,1,0); bgF.BackgroundColor3=T.bg; bgF.BorderSizePixel=0; bgF.ZIndex=1; bgF.Parent=inner; Instance.new("UICorner",bgF).CornerRadius=UDim.new(0,16)
local bgGrad=Instance.new("UIGradient",bgF); bgGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(13,10,25)),ColorSequenceKeypoint.new(0.45,Color3.fromRGB(7,6,15)),ColorSequenceKeypoint.new(1,Color3.fromRGB(11,8,21))}; bgGrad.Rotation=130
task.spawn(function() local r=130; while bgGrad and bgGrad.Parent do r=r+0.06; bgGrad.Rotation=r; task.wait(0.05) end end)

local uiBlur=Instance.new("BlurEffect"); uiBlur.Size=0; uiBlur.Parent=game.Workspace.CurrentCamera
local miniBlur=Instance.new("BlurEffect"); miniBlur.Size=0; miniBlur.Parent=game.Workspace.CurrentCamera

-- BG MODE FUNCTIONS
local function applyUIBgMode(mode)
    UISettings.uiBgMode=mode
    if mode=="Solid" then smooth(bgF,{BackgroundTransparency=0},0.3):Play(); smooth(root,{BackgroundTransparency=0},0.3):Play(); uiBlur.Size=0
    elseif mode=="Transparent" then smooth(bgF,{BackgroundTransparency=0.82},0.3):Play(); smooth(root,{BackgroundTransparency=0.65},0.3):Play(); uiBlur.Size=0
    elseif mode=="Blur" then smooth(bgF,{BackgroundTransparency=0.55},0.3):Play(); smooth(root,{BackgroundTransparency=0.35},0.3):Play(); TS:Create(uiBlur,TweenInfo.new(0.4),{Size=20}):Play() end
end

-- PARTICLES
local particleList={}
local function spawnParticles(count)
    for _,p in ipairs(particleList) do pcall(function() p:Destroy() end) end; particleList={}; math.randomseed(tick())
    for i=1,count do
        task.spawn(function()
            task.wait(math.random(0,20)/10)
            local p=Instance.new("Frame"); local sz=math.random(2,5)
            p.Size=UDim2.new(0,sz,0,sz); p.Position=UDim2.new(math.random(2,98)/100,0,math.random(2,98)/100,0)
            p.BackgroundColor3=Color3.fromHSV(math.random(258,294)/360,0.68,0.9); p.BackgroundTransparency=math.random(55,80)/100; p.BorderSizePixel=0; p.ZIndex=1; p.Parent=bgF; Instance.new("UICorner",p).CornerRadius=UDim.new(1,0); table.insert(particleList,p)
            while p and p.Parent do
                if not UISettings.particles then p.Visible=false; task.wait(0.5); continue end; p.Visible=true
                local nx=math.clamp(p.Position.X.Scale+math.random(-8,8)/100,0.01,0.99); local ny=math.clamp(p.Position.Y.Scale+math.random(-8,8)/100,0.01,0.99); local dur=math.random(36,62)/10
                TS:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true),{Position=UDim2.new(nx,0,ny,0),BackgroundTransparency=math.random(40,78)/100}):Play(); task.wait(dur)
            end
        end)
    end
end
spawnParticles(26)

-- TOPBAR
local topBar=Instance.new("Frame"); topBar.Name="TopBar"; topBar.Size=UDim2.new(1,0,0,TOPBAR_H); topBar.BackgroundColor3=Color3.fromRGB(11,9,20); topBar.BorderSizePixel=0; topBar.ZIndex=5; topBar.Parent=inner; Instance.new("UICorner",topBar).CornerRadius=UDim.new(0,16)
local topFix=Instance.new("Frame",topBar); topFix.Size=UDim2.new(1,0,0,16); topFix.Position=UDim2.new(0,0,1,-16); topFix.BackgroundColor3=Color3.fromRGB(11,9,20); topFix.BorderSizePixel=0; topFix.ZIndex=5
Instance.new("UIGradient",topBar).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(18,14,32)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,8,18))}
local topSep=Instance.new("Frame",inner); topSep.​​​​​​​​​​​​​​​​
