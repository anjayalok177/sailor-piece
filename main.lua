-- ╔══════════════════════════════════════════╗
-- ║  Yi Da Mu Sake — Main Loader  v8.2       ║
-- ╚══════════════════════════════════════════╝

local RAW="https://raw.githubusercontent.com/anjayalok177/sailor-piece/refs/heads/main/"
local function load(file)
    local attempts=0; local lastErr
    while attempts<3 do
        attempts=attempts+1
        local ok,res=pcall(function()
            local src=game:HttpGet(RAW..file,true)
            if not src or src=="" then error("HttpGet kosong") end
            if src:sub(1,1)=="<" then error("Dapat HTML bukan Lua (404)") end
            local fn,err=loadstring(src); if not fn then error("Compile error: "..tostring(err)) end
            return fn()
        end)
        if ok then return res end
        lastErr=res; warn("[YiDaMuSake] Gagal load "..file.." attempt "..attempts..": "..tostring(res))
        if attempts<3 then task.wait(1.5) end
    end
    error("[YiDaMuSake] FATAL gagal load "..file..": "..tostring(lastErr))
end
-- Versi aman: tidak crash jika file tidak ada
local function safeLoad(file)
    local ok,res=pcall(load,file); if ok then return res end
    warn("[YiDaMuSake] safeLoad skip "..file..": "..tostring(res)); return nil
end

pcall(function() local old=game:GetService("CoreGui"):FindFirstChild("YiDaMuSake"); if old then old:Destroy() end end)
pcall(function() local old=game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("YiDaMuSake"); if old then old:Destroy() end end)
pcall(function() for _,e in ipairs(game.Workspace.CurrentCamera:GetChildren()) do if e:IsA("BlurEffect") then e:Destroy() end end end)

task.spawn(function()
    local VU=game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function() pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end) end)
    while true do task.wait(240); pcall(function() VU:MoveMouse(Vector2.new(0,0)) end) end
end)

local lib=load("ui_lib.lua"); local T=lib.T; local UISettings=lib.UISettings
local Players=game:GetService("Players"); local TweenService=game:GetService("TweenService"); local UIS=game:GetService("UserInputService"); local player=Players.LocalPlayer

local gui; local ok_gui=pcall(function() gui=Instance.new("ScreenGui"); gui.Name="YiDaMuSake"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset=true; gui.Parent=game:GetService("CoreGui") end)
if not ok_gui or not gui then gui=Instance.new("ScreenGui"); gui.Name="YiDaMuSake"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset=true; gui.Parent=player.PlayerGui end

local camera=game.Workspace.CurrentCamera
local function getViewport() local vp=camera.ViewportSize; local waited=0; while (vp.X==0 or vp.Y==0) and waited<3 do task.wait(0.05); waited=waited+0.05; vp=camera.ViewportSize end; if vp.X==0 or vp.Y==0 then return Vector2.new(812,375) end; return vp end
local vp=getViewport(); local WIN_W=math.min(math.max(vp.X*0.88,360),700); local WIN_H=math.min(math.max(vp.Y*0.64,240),440); local SIDEBAR_W=68; local TOPBAR_H=50; local BOTBAR_H=26

local root=Instance.new("Frame"); root.Name="Root"; root.Size=UDim2.new(0,WIN_W,0,WIN_H); root.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2); root.BackgroundColor3=T.bg; root.BorderSizePixel=0; root.ClipsDescendants=false; root.Active=true; root.Parent=gui
local rootCorner=Instance.new("UICorner",root); rootCorner.CornerRadius=UDim.new(0,14)
local rootGlow=Instance.new("ImageLabel",root); rootGlow.Size=UDim2.new(1,100,1,100); rootGlow.Position=UDim2.new(0.5,0,0.5,0); rootGlow.AnchorPoint=Vector2.new(0.5,0.5); rootGlow.BackgroundTransparency=1; rootGlow.Image="rbxassetid://5028857084"; rootGlow.ImageColor3=T.accent; rootGlow.ImageTransparency=0.88; rootGlow.ZIndex=0; lib.regAccent("imgAccent",rootGlow)
local rootStroke=Instance.new("UIStroke",root); rootStroke.Color=T.border; rootStroke.Thickness=1.5; rootStroke.Transparency=0.1; lib.regAccent("stAccent",rootStroke)
task.spawn(function() while rootGlow and rootGlow.Parent do lib.ease(rootGlow,{ImageTransparency=0.80},1.4):Play(); task.wait(1.5); lib.ease(rootGlow,{ImageTransparency=0.92},1.4):Play(); task.wait(1.5) end end)
task.spawn(function() while rootStroke and rootStroke.Parent do lib.ease(rootStroke,{Color=T.borderBright,Transparency=0.0},1.6):Play(); task.wait(1.7); lib.ease(rootStroke,{Color=T.border,Transparency=0.2},1.6):Play(); task.wait(1.7) end end)
local inner=Instance.new("Frame",root); inner.Size=UDim2.new(1,0,1,0); inner.BackgroundTransparency=1; inner.ClipsDescendants=true; inner.ZIndex=1
local bgF=Instance.new("Frame",inner); bgF.Size=UDim2.new(1,0,1,0); bgF.BackgroundColor3=T.bg; bgF.BorderSizePixel=0; bgF.ZIndex=1; Instance.new("UICorner",bgF).CornerRadius=UDim.new(0,14)
local bgGrad=Instance.new("UIGradient",bgF); bgGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(14,10,26)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,7,14)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,9,20))}; bgGrad.Rotation=125
task.spawn(function() local r=125; while bgGrad and bgGrad.Parent do r=r+0.04; bgGrad.Rotation=r; task.wait(0.06) end end)

local screenBlur=Instance.new("BlurEffect"); screenBlur.Size=0; screenBlur.Parent=camera
local miniBar; local miniBarVisible=false
local function setBlur(sz,dur) TweenService:Create(screenBlur,TweenInfo.new(dur or 0.35,Enum.EasingStyle.Quint),{Size=sz}):Play() end
local function refreshBlur() if miniBarVisible and UISettings.miniBgMode=="Blur" then setBlur(12) elseif not miniBarVisible and root.Visible and UISettings.uiBgMode=="Blur" then setBlur(18) else setBlur(0) end end
local function applyUIBgMode(mode) UISettings.uiBgMode=mode; if mode=="Solid" then lib.smooth(bgF,{BackgroundTransparency=0},0.3):Play(); lib.smooth(root,{BackgroundTransparency=0},0.3):Play() elseif mode=="Transparent" then lib.smooth(bgF,{BackgroundTransparency=0.80},0.3):Play(); lib.smooth(root,{BackgroundTransparency=0.60},0.3):Play() elseif mode=="Blur" then lib.smooth(bgF,{BackgroundTransparency=0.55},0.3):Play(); lib.smooth(root,{BackgroundTransparency=0.35},0.3):Play() end; refreshBlur() end
local function applyMiniBgMode(mode) UISettings.miniBgMode=mode; if not miniBar then return end; if mode=="Solid" then miniBar.BackgroundTransparency=0 elseif mode=="Transparent" then miniBar.BackgroundTransparency=0.72 elseif mode=="Blur" then miniBar.BackgroundTransparency=0.40 end; if miniBarVisible then refreshBlur() end end

local particleList={}
local function spawnParticles(count)
    for _,p in ipairs(particleList) do pcall(function() p:Destroy() end) end; particleList={}; math.randomseed(tick())
    for i=1,count do task.spawn(function()
        task.wait(math.random(0,20)/10); local p=Instance.new("Frame"); local sz=math.random(1,4)
        p.Size=UDim2.new(0,sz,0,sz); p.Position=UDim2.new(math.random(2,98)/100,0,math.random(2,98)/100,0)
        p.BackgroundColor3=Color3.fromHSV(math.random(258,295)/360,0.65,0.88); p.BackgroundTransparency=math.random(60,82)/100; p.BorderSizePixel=0; p.ZIndex=1; p.Parent=bgF
        Instance.new("UICorner",p).CornerRadius=UDim.new(1,0); table.insert(particleList,p)
        while p and p.Parent do
            if not UISettings.particles then p.Visible=false; task.wait(0.5); continue end; p.Visible=true
            local nx=math.clamp(p.Position.X.Scale+math.random(-7,7)/100,0.01,0.99); local ny=math.clamp(p.Position.Y.Scale+math.random(-7,7)/100,0.01,0.99); local dur=math.random(40,70)/10
            TweenService:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true),{Position=UDim2.new(nx,0,ny,0),BackgroundTransparency=math.random(44,80)/100}):Play(); task.wait(dur)
        end
    end) end
end
spawnParticles(UISettings.particleCount)

local topBar=Instance.new("Frame",inner); topBar.Size=UDim2.new(1,0,0,TOPBAR_H); topBar.BackgroundColor3=Color3.fromRGB(9,8,16); topBar.BorderSizePixel=0; topBar.ZIndex=5; Instance.new("UICorner",topBar).CornerRadius=UDim.new(0,14)
local topFix=Instance.new("Frame",topBar); topFix.Size=UDim2.new(1,0,0,14); topFix.Position=UDim2.new(0,0,1,-14); topFix.BackgroundColor3=Color3.fromRGB(9,8,16); topFix.BorderSizePixel=0; topFix.ZIndex=5
local topSep=Instance.new("Frame",inner); topSep.Size=UDim2.new(1,0,0,1); topSep.Position=UDim2.new(0,0,0,TOPBAR_H); topSep.BackgroundColor3=T.border; topSep.BackgroundTransparency=0.1; topSep.BorderSizePixel=0; topSep.ZIndex=6
local iconBg=Instance.new("Frame",topBar); iconBg.Size=UDim2.new(0,30,0,30); iconBg.Position=UDim2.new(0,12,0.5,0); iconBg.AnchorPoint=Vector2.new(0,0.5); iconBg.BackgroundColor3=T.accentSoft; iconBg.BorderSizePixel=0; iconBg.ZIndex=7; Instance.new("UICorner",iconBg).CornerRadius=UDim.new(0,8); lib.regAccent("bgSoft",iconBg); Instance.new("UIGradient",iconBg).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accentSoft)}
local iconImg=Instance.new("ImageLabel",iconBg); iconImg.Size=UDim2.new(0.76,0,0.76,0); iconImg.Position=UDim2.new(0.5,0,0.5,0); iconImg.AnchorPoint=Vector2.new(0.5,0.5); iconImg.BackgroundTransparency=1; iconImg.Image="rbxassetid://110843044052526"; iconImg.ZIndex=8
local titleL=Instance.new("TextLabel",topBar); titleL.Size=UDim2.new(0,160,0,16); titleL.Position=UDim2.new(0,50,0,7); titleL.BackgroundTransparency=1; titleL.Text="Yi Da Mu Sake"; titleL.TextColor3=T.text; titleL.Font=Enum.Font.GothamBold; titleL.TextSize=13; titleL.TextXAlignment=Enum.TextXAlignment.Left; titleL.ZIndex=7
local subTitleL=Instance.new("TextLabel",topBar); subTitleL.Size=UDim2.new(0,160,0,12); subTitleL.Position=UDim2.new(0,50,0,26); subTitleL.BackgroundTransparency=1; subTitleL.Text="sailor piece  v8.2"; subTitleL.TextColor3=T.textDim; subTitleL.Font=Enum.Font.Gotham; subTitleL.TextSize=9; subTitleL.TextXAlignment=Enum.TextXAlignment.Left; subTitleL.ZIndex=7
local function mkWinBtn(offX,col,sym) local b=Instance.new("TextButton",topBar); b.Size=UDim2.new(0,18,0,18); b.Position=UDim2.new(1,offX,0.5,0); b.AnchorPoint=Vector2.new(1,0.5); b.BackgroundColor3=col; b.Text=""; b.BorderSizePixel=0; b.ZIndex=8; Instance.new("UICorner",b).CornerRadius=UDim.new(1,0); local lbl=Instance.new("TextLabel",b); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=sym; lbl.TextColor3=T.white; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextTransparency=0.35; lbl.ZIndex=9; b.MouseEnter:Connect(function() lib.smooth(b,{BackgroundTransparency=0.18},0.12):Play(); lib.smooth(lbl,{TextTransparency=0},0.12):Play() end); b.MouseLeave:Connect(function() lib.smooth(b,{BackgroundTransparency=0},0.12):Play(); lib.smooth(lbl,{TextTransparency=0.35},0.12):Play() end); return b end
local closeBtn=mkWinBtn(-10,Color3.fromRGB(198,50,62),"x"); local minBtn=mkWinBtn(-34,Color3.fromRGB(185,138,22),"-")
do local drag,dragStart,startPos=false,nil,nil; topBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; dragStart=i.Position; startPos=root.Position end end); UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dragStart; root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end); UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end) end
local rh=Instance.new("TextButton",root); rh.Size=UDim2.new(0,20,0,20); rh.Position=UDim2.new(1,-2,1,-2); rh.AnchorPoint=Vector2.new(1,1); rh.BackgroundColor3=Color3.fromRGB(22,20,34); rh.BackgroundTransparency=0.4; rh.Text=""; rh.BorderSizePixel=0; rh.ZIndex=20; Instance.new("UICorner",rh).CornerRadius=UDim.new(0,6)
for di=1,3 do local dot=Instance.new("Frame",rh); dot.Size=UDim2.new(0,2,0,2); dot.Position=UDim2.new(0,2+di*4,0,2+di*4); dot.BackgroundColor3=T.accentGlow; dot.BackgroundTransparency=0.4; dot.BorderSizePixel=0; dot.ZIndex=21; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0) end
do local resizing,rsStart,rStartW,rStartH=false,nil,nil,nil; local MIN_W,MIN_H=360,240; rh.MouseButton1Down:Connect(function() resizing=true; rsStart=UIS:GetMouseLocation(); rStartW=root.AbsoluteSize.X; rStartH=root.AbsoluteSize.Y end); UIS.InputChanged:Connect(function(i) if resizing and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local cur=(i.UserInputType==Enum.UserInputType.Touch) and i.Position or UIS:GetMouseLocation(); WIN_W=math.clamp(rStartW+(cur.X-rsStart.X),MIN_W,vp.X*0.96); WIN_H=math.clamp(rStartH+(cur.Y-rsStart.Y),MIN_H,vp.Y*0.96); root.Size=UDim2.new(0,WIN_W,0,WIN_H) end end); UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then resizing=false end end) end

local miniExpLbl=nil; miniBar=Instance.new("Frame",gui); miniBar.Size=UDim2.new(0,46,0,46); miniBar.Position=UDim2.new(0.5,-23,0,10); miniBar.BackgroundColor3=Color3.fromRGB(11,10,18); miniBar.BorderSizePixel=0; miniBar.ZIndex=200; miniBar.Visible=false; Instance.new("UICorner",miniBar).CornerRadius=UDim.new(0,23)
local miniStroke=Instance.new("UIStroke",miniBar); miniStroke.Color=T.borderBright; miniStroke.Thickness=1.5; miniStroke.Transparency=0.12
local miniGlow=Instance.new("ImageLabel",miniBar); miniGlow.Size=UDim2.new(1,34,1,34); miniGlow.Position=UDim2.new(0.5,0,0.5,0); miniGlow.AnchorPoint=Vector2.new(0.5,0.5); miniGlow.BackgroundTransparency=1; miniGlow.Image="rbxassetid://5028857084"; miniGlow.ImageColor3=T.accent; miniGlow.ImageTransparency=0.84; miniGlow.ZIndex=0; lib.regAccent("imgAccent",miniGlow)
local miniIconBg=Instance.new("Frame",miniBar); miniIconBg.Size=UDim2.new(0,36,0,36); miniIconBg.Position=UDim2.new(0,5,0.5,0); miniIconBg.AnchorPoint=Vector2.new(0,0.5); miniIconBg.BackgroundColor3=T.accentSoft; miniIconBg.BorderSizePixel=0; miniIconBg.ZIndex=201; Instance.new("UICorner",miniIconBg).CornerRadius=UDim.new(0,9); lib.regAccent("bgSoft",miniIconBg); Instance.new("UIGradient",miniIconBg).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accentSoft)}
local miniIconImg=Instance.new("ImageLabel",miniIconBg); miniIconImg.Size=UDim2.new(0.82,0,0.82,0); miniIconImg.Position=UDim2.new(0.5,0,0.5,0); miniIconImg.AnchorPoint=Vector2.new(0.5,0.5); miniIconImg.BackgroundTransparency=1; miniIconImg.Image="rbxassetid://110843044052526"; miniIconImg.ZIndex=202
local miniHit=Instance.new("TextButton",miniBar); miniHit.Size=UDim2.new(1,0,1,0); miniHit.BackgroundTransparency=1; miniHit.Text=""; miniHit.ZIndex=203
task.spawn(function() while miniBar and miniBar.Parent do if miniBar.Visible then lib.ease(miniGlow,{ImageTransparency=0.70},0.9):Play(); task.wait(1.0); lib.ease(miniGlow,{ImageTransparency=0.86},0.9):Play(); task.wait(1.0) else task.wait(0.5) end end end)
closeBtn.MouseButton1Click:Connect(function() setBlur(0,0.18); lib.smooth(root,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.22):Play(); task.wait(0.24); gui:Destroy(); pcall(function() screenBlur:Destroy() end) end)
minBtn.MouseButton1Click:Connect(function() miniBarVisible=true; lib.smooth(root,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.22):Play(); task.wait(0.24); root.Visible=false; applyMiniBgMode(UISettings.miniBgMode); miniBar.Size=UDim2.new(0,46,0,46); miniBar.Position=UDim2.new(0.5,-23,0,10); miniBar.Visible=true; lib.spring(miniBar,{Size=UDim2.new(0,228,0,46)},0.44):Play(); task.spawn(function() task.wait(0.12); lib.smooth(miniBar,{Position=UDim2.new(0.5,-114,0,10)},0.20):Play() end); task.spawn(function() task.wait(0.20); if miniExpLbl then miniExpLbl:Destroy(); miniExpLbl=nil end; miniExpLbl=Instance.new("TextLabel",miniBar); miniExpLbl.Size=UDim2.new(1,-50,1,0); miniExpLbl.Position=UDim2.new(0,46,0,0); miniExpLbl.BackgroundTransparency=1; miniExpLbl.Text="Yi Da Mu Sake"; miniExpLbl.TextColor3=T.text; miniExpLbl.Font=Enum.Font.GothamBold; miniExpLbl.TextSize=13; miniExpLbl.TextXAlignment=Enum.TextXAlignment.Center; miniExpLbl.TextTransparency=1; miniExpLbl.ZIndex=202; lib.smooth(miniExpLbl,{TextTransparency=0},0.24):Play() end) end)
miniHit.MouseButton1Click:Connect(function() miniBarVisible=false; refreshBlur(); if miniExpLbl then lib.smooth(miniExpLbl,{TextTransparency=1},0.12):Play(); task.wait(0.14); pcall(function() if miniExpLbl then miniExpLbl:Destroy(); miniExpLbl=nil end end) end; lib.smooth(miniBar,{Size=UDim2.new(0,46,0,46),Position=UDim2.new(0.5,-23,0,10)},0.18):Play(); task.wait(0.20); miniBar.Visible=false; root.Visible=true; root.Size=UDim2.new(0,WIN_W,0,0); root.BackgroundTransparency=1; lib.spring(root,{Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0},0.42):Play(); task.delay(0.5,function() applyUIBgMode(UISettings.uiBgMode) end) end)

local sidebar=Instance.new("Frame",inner); sidebar.Size=UDim2.new(0,SIDEBAR_W,1,-TOPBAR_H-1); sidebar.Position=UDim2.new(0,0,0,TOPBAR_H+1); sidebar.BackgroundColor3=Color3.fromRGB(9,8,16); sidebar.BorderSizePixel=0; sidebar.ZIndex=4; sidebar.ClipsDescendants=true; Instance.new("UICorner",sidebar).CornerRadius=UDim.new(0,14)
local sideFix=Instance.new("Frame",sidebar); sideFix.Size=UDim2.new(0,14,1,0); sideFix.Position=UDim2.new(1,-14,0,0); sideFix.BackgroundColor3=Color3.fromRGB(9,8,16); sideFix.BorderSizePixel=0; sideFix.ZIndex=4
local sideVLine=Instance.new("Frame",inner); sideVLine.Size=UDim2.new(0,1,1,-TOPBAR_H-1); sideVLine.Position=UDim2.new(0,SIDEBAR_W,0,TOPBAR_H+1); sideVLine.BackgroundColor3=T.border; sideVLine.BackgroundTransparency=0.1; sideVLine.BorderSizePixel=0; sideVLine.ZIndex=6
local sideList=Instance.new("Frame",sidebar); sideList.Size=UDim2.new(1,0,1,-8); sideList.Position=UDim2.new(0,0,0,10); sideList.BackgroundTransparency=1; sideList.ZIndex=5
local slL=Instance.new("UIListLayout",sideList); slL.Padding=UDim.new(0,4); slL.SortOrder=Enum.SortOrder.LayoutOrder; slL.HorizontalAlignment=Enum.HorizontalAlignment.Center
local slP=Instance.new("UIPadding",sideList); slP.PaddingLeft=UDim.new(0,6); slP.PaddingRight=UDim.new(0,6)
local contentArea=Instance.new("Frame",inner); contentArea.Size=UDim2.new(1,-SIDEBAR_W-1,1,-TOPBAR_H-1); contentArea.Position=UDim2.new(0,SIDEBAR_W+1,0,TOPBAR_H+1); contentArea.BackgroundTransparency=1; contentArea.ZIndex=3

local MAIN_TABS = {
    {name="Info", sym="ⓘ", tip="Info"}, {name="Main", sym="⌂", tip="Main"},
    {name="Menu", sym="☰", tip="Menu"}, {name="Settings", sym="⚙︎", tip="Settings"},
}
local sideData={}
local function switchMainTab(name) for _,d in pairs(sideData) do local on=(d.name==name); lib.smooth(d.iconBg,{BackgroundTransparency=on and 0 or 1},0.20):Play(); lib.smooth(d.iconL,{TextColor3=on and T.white or T.textDim},0.20):Play(); d.bar.Visible=on; d.page.Visible=on end end
for i,tab in ipairs(MAIN_TABS) do
    local btn=Instance.new("TextButton",sideList); btn.Size=UDim2.new(1,0,0,52); btn.BackgroundTransparency=1; btn.Text=""; btn.BorderSizePixel=0; btn.LayoutOrder=i; btn.ZIndex=6; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    local bar=Instance.new("Frame",btn); bar.Size=UDim2.new(0,3,0.45,0); bar.Position=UDim2.new(0,-4,0.5,0); bar.AnchorPoint=Vector2.new(0,0.5); bar.BackgroundColor3=T.accentGlow; bar.BorderSizePixel=0; bar.Visible=false; bar.ZIndex=7; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0); lib.regAccent("bgGlow",bar)
    local iconBg2=Instance.new("Frame",btn); iconBg2.Size=UDim2.new(0,40,0,40); iconBg2.Position=UDim2.new(0.5,0,0.5,0); iconBg2.AnchorPoint=Vector2.new(0.5,0.5); iconBg2.BackgroundColor3=T.accentSoft; iconBg2.BackgroundTransparency=1; iconBg2.BorderSizePixel=0; iconBg2.ZIndex=6; Instance.new("UICorner",iconBg2).CornerRadius=UDim.new(0,10); lib.regAccent("bgSoft",iconBg2)
    local iconL=Instance.new("TextLabel",btn); iconL.Size=UDim2.new(1,0,1,0); iconL.BackgroundTransparency=1; iconL.Text=tab.sym; iconL.TextColor3=T.textDim; iconL.Font=Enum.Font.GothamBold; iconL.TextSize=20; iconL.ZIndex=7
    local tooltip=Instance.new("TextLabel",btn); tooltip.Size=UDim2.new(0,70,0,22); tooltip.Position=UDim2.new(1,6,0.5,0); tooltip.AnchorPoint=Vector2.new(0,0.5); tooltip.BackgroundColor3=Color3.fromRGB(20,18,32); tooltip.TextColor3=T.text; tooltip.Text=tab.tip; tooltip.Font=Enum.Font.GothamBold; tooltip.TextSize=10; tooltip.Visible=false; tooltip.ZIndex=50; tooltip.BorderSizePixel=0; Instance.new("UICorner",tooltip).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",tooltip).Color=T.borderBright
    btn.MouseEnter:Connect(function() tooltip.Visible=true; lib.smooth(iconBg2,{BackgroundTransparency=0.85},0.14):Play() end)
    btn.MouseLeave:Connect(function() tooltip.Visible=false; local isActive=(sideData[tab.name] and sideData[tab.name].bar.Visible); if not isActive then lib.smooth(iconBg2,{BackgroundTransparency=1},0.14):Play() end end)
    local page=Instance.new("Frame",contentArea); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.Visible=false; page.ZIndex=3
    sideData[tab.name]={name=tab.name,btn=btn,bar=bar,iconL=iconL,iconBg=iconBg2,page=page}
    btn.MouseButton1Click:Connect(function() lib.ripple(btn,btn.AbsoluteSize.X*0.5,btn.AbsoluteSize.Y*0.5,T.accent); switchMainTab(tab.name) end)
end

local botBar=Instance.new("Frame",inner); botBar.Size=UDim2.new(1,0,0,BOTBAR_H); botBar.Position=UDim2.new(0,0,1,-BOTBAR_H); botBar.BackgroundColor3=Color3.fromRGB(8,7,14); botBar.BorderSizePixel=0; botBar.ZIndex=5
local botFix=Instance.new("Frame",botBar); botFix.Size=UDim2.new(1,0,0,14); botFix.BackgroundColor3=Color3.fromRGB(8,7,14); botFix.BorderSizePixel=0; botFix.ZIndex=5; Instance.new("UICorner",botBar).CornerRadius=UDim.new(0,14); Instance.new("UIStroke",botBar).Color=T.border
local verL=Instance.new("TextLabel",botBar); verL.Size=UDim2.new(0.5,0,1,0); verL.Position=UDim2.new(0,12,0,0); verL.BackgroundTransparency=1; verL.Text="sailor piece  v8.2 | Anti-AFK ON"; verL.TextColor3=T.textDim; verL.Font=Enum.Font.Gotham; verL.TextSize=9; verL.TextXAlignment=Enum.TextXAlignment.Left; verL.ZIndex=6
local dotL=Instance.new("TextLabel",botBar); dotL.Size=UDim2.new(0.5,-12,1,0); dotL.Position=UDim2.new(0.5,0,0,0); dotL.BackgroundTransparency=1; dotL.Text="* online"; dotL.TextColor3=T.green; dotL.Font=Enum.Font.GothamBold; dotL.TextSize=9; dotL.TextXAlignment=Enum.TextXAlignment.Right; dotL.ZIndex=6
task.spawn(function() while dotL and dotL.Parent do lib.ease(dotL,{TextColor3=T.green},0.9):Play(); task.wait(1.0); lib.ease(dotL,{TextColor3=T.greenDim},0.9):Play(); task.wait(1.0) end end)

root.BackgroundTransparency=1; root.Size=UDim2.new(0,WIN_W,0,0); root.Visible=true; task.wait(0.08)
lib.spring(root,{Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0,Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)},0.50):Play()
task.delay(0.1,function() switchMainTab("Info") end)

local buildPages=load("pages.lua")
local ok,refs=pcall(buildPages,lib,sideData,contentArea,bgF,root,rootCorner,rootStroke,rootGlow,particleList,spawnParticles,applyUIBgMode,applyMiniBgMode,gui)
if not ok then error("[YiDaMuSake] pages.lua gagal build: "..tostring(refs)) end

local startLogic=load("logic.lua")
local ok2,err2=pcall(startLogic,refs,T)
if not ok2 then error("[YiDaMuSake] logic.lua gagal start: "..tostring(err2)) end

-- Webhook: tidak crash jika belum ada di GitHub
local startWebhook=safeLoad("webhook.lua")
if startWebhook then
    local ok3,err3=pcall(startWebhook,refs,T,gui)
    if not ok3 then warn("[YiDaMuSake] webhook.lua error: "..tostring(err3)) end
else
    warn("[YiDaMuSake] webhook.lua tidak ditemukan, fitur webhook dinonaktifkan")
end

_G.YiUI=refs
print("[YiDaMuSake] v8.2 loaded! Parent: "..gui.Parent.Name)
print("[YiDaMuSake] v8.2 loaded! Parent: "..gui.Parent.Name)
