-- ╔══════════════════════════════════════════════╗
-- ║  Yi Da Mu Sake — COMBINED SINGLE FILE v8.2  ║
-- ║  ui_lib + pages + logic + main digabung      ║
-- ╚══════════════════════════════════════════════╝

-- =====================
-- CLEANUP
-- =====================
pcall(function()
    local old=game:GetService("CoreGui"):FindFirstChild("YiDaMuSake"); if old then old:Destroy() end
end)
pcall(function()
    local old=game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("YiDaMuSake"); if old then old:Destroy() end
end)
pcall(function()
    for _,e in ipairs(game.Workspace.CurrentCamera:GetChildren()) do if e:IsA("BlurEffect") then e:Destroy() end end
end)

-- =====================
-- ANTI-AFK
-- =====================
task.spawn(function()
    local player=game:GetService("Players").LocalPlayer
    while true do
        task.wait(55)
        pcall(function()
            local char=player.Character
            if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.Jump=true end end
        end)
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.Space,false,game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.Space,false,game)
        end)
    end
end)

-- ╔══════════════════════════════════╗
-- ║         UI LIBRARY               ║
-- ╚══════════════════════════════════╝
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")

local T = {
    bg=Color3.fromRGB(9,8,15), card=Color3.fromRGB(16,15,25),
    cardHover=Color3.fromRGB(24,22,38), border=Color3.fromRGB(38,32,62),
    borderBright=Color3.fromRGB(72,58,118), accent=Color3.fromRGB(118,68,255),
    accentSoft=Color3.fromRGB(88,48,188), accentGlow=Color3.fromRGB(152,92,255),
    accentDim=Color3.fromRGB(52,28,115), green=Color3.fromRGB(42,198,108),
    greenDim=Color3.fromRGB(25,125,70), red=Color3.fromRGB(215,58,78),
    text=Color3.fromRGB(228,222,248), textSub=Color3.fromRGB(128,120,162),
    textDim=Color3.fromRGB(58,52,88), white=Color3.fromRGB(255,255,255),
    black=Color3.fromRGB(9,8,15), amber=Color3.fromRGB(255,178,40),
}
local ACCENT_PRESETS={
    Purple={Color3.fromRGB(118,68,255),Color3.fromRGB(88,48,188),Color3.fromRGB(152,92,255)},
    Blue  ={Color3.fromRGB(50,120,255),Color3.fromRGB(35,88,200),Color3.fromRGB(80,150,255)},
    Cyan  ={Color3.fromRGB(30,190,220),Color3.fromRGB(20,145,175),Color3.fromRGB(60,215,240)},
    Green ={Color3.fromRGB(40,200,100),Color3.fromRGB(28,150,72),Color3.fromRGB(65,225,130)},
    Red   ={Color3.fromRGB(220,55,80),Color3.fromRGB(168,38,58),Color3.fromRGB(245,80,105)},
}
local UISettings={scale=1,accentPreset="Purple",cornerRadius=14,particles=true,
    particleCount=26,glow=true,fontSize=12,miniBgMode="Solid",uiBgMode="Solid"}

local fontSizeReg={}
local function regFS(o) if o then table.insert(fontSizeReg,o) end end
local function applyFontSize(v)
    UISettings.fontSize=v
    for _,o in ipairs(fontSizeReg) do pcall(function() if o and o.Parent then o.TextSize=v end end) end
end
local accentRegistry={}
local function regAccent(t,o) table.insert(accentRegistry,{t=t,o=o}) end
local function applyAccentLive()
    for _,e in ipairs(accentRegistry) do pcall(function()
        local o,t=e.o,e.t
        if     t=="bgAccent"  then TweenService:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accent}):Play()
        elseif t=="bgGlow"    then TweenService:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accentGlow}):Play()
        elseif t=="bgSoft"    then TweenService:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accentSoft}):Play()
        elseif t=="stAccent"  then TweenService:Create(o,TweenInfo.new(0.3),{Color=T.accent}):Play()
        elseif t=="stGlow"    then TweenService:Create(o,TweenInfo.new(0.3),{Color=T.accentGlow}):Play()
        elseif t=="imgAccent" then TweenService:Create(o,TweenInfo.new(0.3),{ImageColor3=T.accent}):Play()
        elseif t=="txtGlow"   then TweenService:Create(o,TweenInfo.new(0.3),{TextColor3=T.accentGlow}):Play()
        elseif t=="scrollbar" then o.ScrollBarImageColor3=T.accent end
    end) end
end
local function applyAccent(preset)
    local p=ACCENT_PRESETS[preset]; if not p then return end
    T.accent=p[1]; T.accentSoft=p[2]; T.accentGlow=p[3]
    UISettings.accentPreset=preset; applyAccentLive()
end
local function tw(o,p,t,s,d)
    return TweenService:Create(o,TweenInfo.new(t or 0.22,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p)
end
local function smooth(o,p,t) return tw(o,p,t or 0.22) end
local function spring(o,p,t) return tw(o,p,t or 0.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out) end
local function ease(o,p,t)   return tw(o,p,t or 0.28,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut) end
local function ripple(parent,x,y,col)
    local ok,pos=pcall(function() return Vector2.new(x or parent.AbsoluteSize.X/2,y or parent.AbsoluteSize.Y/2) end)
    if not ok then return end
    local r=Instance.new("Frame")
    r.Size=UDim2.new(0,0,0,0); r.Position=UDim2.new(0,pos.X,0,pos.Y)
    r.AnchorPoint=Vector2.new(0.5,0.5); r.BackgroundColor3=col or T.white
    r.BackgroundTransparency=0.78; r.BorderSizePixel=0; r.ZIndex=60; r.Parent=parent
    Instance.new("UICorner",r).CornerRadius=UDim.new(1,0)
    local sz=math.max(parent.AbsoluteSize.X,parent.AbsoluteSize.Y)*2.2
    local t1=smooth(r,{Size=UDim2.new(0,sz,0,sz),BackgroundTransparency=0.96},0.38)
    t1:Play()
    t1.Completed:Connect(function()
        smooth(r,{BackgroundTransparency=1},0.12):Play()
        task.wait(0.14); pcall(function() r:Destroy() end)
    end)
end
local function mkScrollPage(parent)
    local sf=Instance.new("ScrollingFrame",parent)
    sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=2; sf.ScrollBarImageColor3=T.accent; sf.ScrollBarImageTransparency=0.4
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.ZIndex=3; sf.ClipsDescendants=true; sf.ScrollingEnabled=true
    regAccent("scrollbar",sf)
    local ul=Instance.new("UIListLayout",sf); ul.Padding=UDim.new(0,5); ul.SortOrder=Enum.SortOrder.LayoutOrder
    local pp=Instance.new("UIPadding",sf)
    pp.PaddingTop=UDim.new(0,5); pp.PaddingBottom=UDim.new(0,14); pp.PaddingLeft=UDim.new(0,4); pp.PaddingRight=UDim.new(0,4)
    return sf
end
local function mkTwoColLayout(parent,dividerColor)
    local VPAD=18
    local sf=Instance.new("ScrollingFrame",parent)
    sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=2; sf.ScrollBarImageColor3=T.accent; sf.ScrollBarImageTransparency=0.4
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.None
    sf.ZIndex=3; sf.ClipsDescendants=true; sf.ScrollingEnabled=true
    regAccent("scrollbar",sf)
    local pp=Instance.new("UIPadding",sf)
    pp.PaddingTop=UDim.new(0,4); pp.PaddingBottom=UDim.new(0,14); pp.PaddingLeft=UDim.new(0,3); pp.PaddingRight=UDim.new(0,3)
    local leftF=Instance.new("Frame",sf)
    leftF.Size=UDim2.new(0.5,-3,0,0); leftF.Position=UDim2.new(0,0,0,0)
    leftF.BackgroundTransparency=1; leftF.AutomaticSize=Enum.AutomaticSize.Y; leftF.BorderSizePixel=0; leftF.ZIndex=3
    local ll=Instance.new("UIListLayout",leftF); ll.Padding=UDim.new(0,5); ll.SortOrder=Enum.SortOrder.LayoutOrder
    local div=nil
    if dividerColor then
        div=Instance.new("Frame",sf); div.Size=UDim2.new(0,1,0,100)
        div.Position=UDim2.new(0.5,-0.5,0,0); div.BackgroundColor3=dividerColor
        div.BackgroundTransparency=0.5; div.BorderSizePixel=0; div.ZIndex=4
    end
    local rightF=Instance.new("Frame",sf)
    rightF.Size=UDim2.new(0.5,-3,0,0); rightF.Position=UDim2.new(0.5,3,0,0)
    rightF.BackgroundTransparency=1; rightF.AutomaticSize=Enum.AutomaticSize.Y; rightF.BorderSizePixel=0; rightF.ZIndex=3
    local rl=Instance.new("UIListLayout",rightF); rl.Padding=UDim.new(0,5); rl.SortOrder=Enum.SortOrder.LayoutOrder
    local function updateCanvas()
        local lh=ll.AbsoluteContentSize.Y+VPAD; local rh=rl.AbsoluteContentSize.Y+VPAD
        local maxH=math.max(lh,rh,40); sf.CanvasSize=UDim2.new(0,0,0,maxH)
        if div then div.Size=UDim2.new(0,1,0,maxH) end
    end
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    rl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    updateCanvas(); return leftF,rightF
end
local function mkGroupBox(parent,order)
    local grp=Instance.new("Frame",parent)
    grp.BackgroundColor3=Color3.fromRGB(13,12,21); grp.BorderSizePixel=0
    grp.LayoutOrder=order or 0; grp.AutomaticSize=Enum.AutomaticSize.Y
    grp.Size=UDim2.new(1,0,0,0); grp.ClipsDescendants=false
    Instance.new("UICorner",grp).CornerRadius=UDim.new(0,12)
    local gs=Instance.new("UIStroke",grp); gs.Color=T.border; gs.Thickness=1.0; gs.Transparency=0.2
    local gpad=Instance.new("UIPadding",grp)
    gpad.PaddingLeft=UDim.new(0,5); gpad.PaddingRight=UDim.new(0,5); gpad.PaddingTop=UDim.new(0,5); gpad.PaddingBottom=UDim.new(0,6)
    local gl=Instance.new("UIListLayout",grp); gl.Padding=UDim.new(0,4); gl.SortOrder=Enum.SortOrder.LayoutOrder
    return grp,gs
end
local function mkSectionLabel(parent,label,order)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,15); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local acc=Instance.new("Frame",f); acc.Size=UDim2.new(0,3,0,10); acc.Position=UDim2.new(0,2,0.5,0)
    acc.AnchorPoint=Vector2.new(0,0.5); acc.BackgroundColor3=T.accentGlow; acc.BorderSizePixel=0
    Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0); regAccent("bgGlow",acc)
    local t=Instance.new("TextLabel",f); t.Size=UDim2.new(1,-14,1,0); t.Position=UDim2.new(0,10,0,0)
    t.BackgroundTransparency=1; t.Text=string.upper(label); t.TextColor3=T.textSub
    t.Font=Enum.Font.GothamBold; t.TextSize=8; t.TextXAlignment=Enum.TextXAlignment.Left
    return f
end
local function mkSection(parent,label,order)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,18); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local line=Instance.new("Frame",f); line.Size=UDim2.new(0,3,0.7,0); line.Position=UDim2.new(0,0,0.15,0)
    line.BackgroundColor3=T.accentGlow; line.BorderSizePixel=0
    Instance.new("UICorner",line).CornerRadius=UDim.new(1,0); regAccent("bgGlow",line)
    local hline=Instance.new("Frame",f); hline.Size=UDim2.new(1,-10,0,1); hline.Position=UDim2.new(0,8,1,-1)
    hline.BackgroundColor3=T.border; hline.BackgroundTransparency=0.2; hline.BorderSizePixel=0
    local t=Instance.new("TextLabel",f); t.Size=UDim2.new(1,-12,0,14); t.Position=UDim2.new(0,10,0,1)
    t.BackgroundTransparency=1; t.Text=string.upper(label); t.TextColor3=T.textSub
    t.Font=Enum.Font.GothamBold; t.TextSize=9; t.TextXAlignment=Enum.TextXAlignment.Left
    return f
end
local function mkCard(parent,h,order)
    local c=Instance.new("Frame",parent)
    c.Size=UDim2.new(1,0,0,h or 50); c.BackgroundColor3=T.card
    c.BorderSizePixel=0; c.LayoutOrder=order or 0; c.ClipsDescendants=true; c.ZIndex=5
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,10)
    local cs=Instance.new("UIStroke",c); cs.Color=T.border; cs.Transparency=0.45; cs.Thickness=0.8
    local cg=Instance.new("UIGradient",c)
    cg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(22,20,34)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,13,22))}
    cg.Rotation=135
    c.MouseEnter:Connect(function() if c and c.Parent then smooth(c,{BackgroundColor3=T.cardHover},0.12):Play(); smooth(cs,{Color=T.borderBright,Transparency=0.2},0.12):Play() end end)
    c.MouseLeave:Connect(function() if c and c.Parent then smooth(c,{BackgroundColor3=T.card},0.12):Play(); smooth(cs,{Color=T.border,Transparency=0.45},0.12):Play() end end)
    return c,cs
end
local function mkStatus(parent,prefix,init,order)
    local c=Instance.new("Frame",parent)
    c.Size=UDim2.new(1,0,0,28); c.BackgroundColor3=Color3.fromRGB(13,12,20)
    c.BorderSizePixel=0; c.LayoutOrder=order or 0; c.ZIndex=5
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,7)
    local dot=Instance.new("Frame",c); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0,10,0.5,0)
    dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.textDim; dot.BorderSizePixel=0; dot.ZIndex=7
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local pfx=Instance.new("TextLabel",c); pfx.Size=UDim2.new(0,50,1,0); pfx.Position=UDim2.new(0,18,0,0)
    pfx.BackgroundTransparency=1; pfx.Text=prefix; pfx.TextColor3=T.textDim
    pfx.Font=Enum.Font.GothamBold; pfx.TextSize=8; pfx.TextXAlignment=Enum.TextXAlignment.Left; pfx.ZIndex=6
    local val=Instance.new("TextLabel",c); val.Size=UDim2.new(1,-74,1,0); val.Position=UDim2.new(0,72,0,0)
    val.BackgroundTransparency=1; val.Text=init or "--"; val.TextColor3=T.textSub
    val.Font=Enum.Font.Gotham; val.TextSize=10; val.TextXAlignment=Enum.TextXAlignment.Left; val.ZIndex=6
    local function set(text,col)
        val.Text=text or "--"
        if col then smooth(val,{TextColor3=col},0.15):Play(); smooth(dot,{BackgroundColor3=col},0.15):Play() end
    end
    return c,set
end
local function mkToggle(parent,label,default,onChange,order)
    local card=mkCard(parent,38,order)
    local lbl=Instance.new("TextLabel",card); lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.text
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=UISettings.fontSize; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6; regFS(lbl)
    local track=Instance.new("Frame",card); track.Size=UDim2.new(0,34,0,18); track.Position=UDim2.new(1,-42,0.5,0)
    track.AnchorPoint=Vector2.new(0,0.5); track.BackgroundColor3=T.border; track.BorderSizePixel=0; track.ZIndex=6
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local thumb=Instance.new("Frame",track); thumb.Size=UDim2.new(0,12,0,12); thumb.Position=UDim2.new(0,3,0.5,0)
    thumb.AnchorPoint=Vector2.new(0,0.5); thumb.BackgroundColor3=T.white; thumb.BorderSizePixel=0; thumb.ZIndex=7
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local val=default or false
    local function apply(v)
        val=v; smooth(track,{BackgroundColor3=v and T.accent or T.border},0.18):Play()
        smooth(thumb,{Position=UDim2.new(v and 1 or 0,v and -15 or 3,0.5,0)},0.18):Play()
        if onChange then onChange(v) end
    end
    apply(val)
    local hit=Instance.new("TextButton",card); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=10
    hit.MouseButton1Click:Connect(function() ripple(card,card.AbsoluteSize.X*0.5,card.AbsoluteSize.Y*0.5,T.accent); apply(not val) end)
    return card,apply,function() return val end
end
local function mkSlider(parent,label,min,max,default,suffix,onChange,order)
    local card=mkCard(parent,58,order)
    local lbl=Instance.new("TextLabel",card); lbl.Size=UDim2.new(0.62,0,0,17); lbl.Position=UDim2.new(0,12,0,6)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.text
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=UISettings.fontSize; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6; regFS(lbl)
    local valLbl=Instance.new("TextLabel",card); valLbl.Size=UDim2.new(0.38,-12,0,17); valLbl.Position=UDim2.new(0.62,0,0,6)
    valLbl.BackgroundTransparency=1; valLbl.TextColor3=T.accentGlow; valLbl.Font=Enum.Font.GothamBold
    valLbl.TextSize=UISettings.fontSize; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=6
    regAccent("txtGlow",valLbl); regFS(valLbl)
    local trackBg=Instance.new("Frame",card); trackBg.Size=UDim2.new(1,-24,0,4); trackBg.Position=UDim2.new(0,12,0,40)
    trackBg.BackgroundColor3=T.border; trackBg.BorderSizePixel=0; trackBg.ZIndex=6
    Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",trackBg); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=T.accent; fill.BorderSizePixel=0; fill.ZIndex=7
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    Instance.new("UIGradient",fill).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accent)}
    regAccent("bgAccent",fill)
    local knob=Instance.new("Frame",trackBg); knob.Size=UDim2.new(0,12,0,12); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(0,0,0.5,0); knob.BackgroundColor3=T.white; knob.BorderSizePixel=0; knob.ZIndex=8
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local ks=Instance.new("UIStroke",knob); ks.Color=T.accent; ks.Thickness=1.5; regAccent("stAccent",ks)
    local curVal=math.clamp(default or min,min,max); local dragging=false
    local function setVal(v)
        curVal=math.clamp(math.floor(v+0.5),min,max); local r2=(curVal-min)/(max-min)
        valLbl.Text=tostring(curVal)..(suffix or "")
        smooth(fill,{Size=UDim2.new(r2,0,1,0)},0.08):Play(); smooth(knob,{Position=UDim2.new(r2,0,0.5,0)},0.08):Play()
        if onChange then onChange(curVal) end
    end
    setVal(curVal)
    local sHit=Instance.new("TextButton",card); sHit.Size=UDim2.new(1,-20,0,26); sHit.Position=UDim2.new(0,10,0,30)
    sHit.BackgroundTransparency=1; sHit.Text=""; sHit.ZIndex=12
    sHit.MouseButton1Down:Connect(function() dragging=true; spring(knob,{Size=UDim2.new(0,16,0,16)},0.18):Play() end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            if trackBg and trackBg.Parent then
                local r2=math.clamp((i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1)
                setVal(min+r2*(max-min))
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            if dragging then dragging=false; spring(knob,{Size=UDim2.new(0,12,0,12)},0.2):Play() end
        end
    end)
    return card,setVal,function() return curVal end
end
local function mkOnOffBtn(parent,label,order)
    local BTN_H=44
    local wrapper=Instance.new("Frame",parent)
    wrapper.Size=UDim2.new(1,0,0,BTN_H); wrapper.BackgroundColor3=Color3.fromRGB(14,12,22)
    wrapper.BorderSizePixel=0; wrapper.LayoutOrder=order or 0; wrapper.ClipsDescendants=false; wrapper.ZIndex=6
    Instance.new("UICorner",wrapper).CornerRadius=UDim.new(0,10)
    local wStroke=Instance.new("UIStroke",wrapper); wStroke.Color=T.border; wStroke.Thickness=1.0; wStroke.Transparency=0.3
    local wGlow=Instance.new("ImageLabel",wrapper)
    wGlow.Size=UDim2.new(1,20,1,20); wGlow.Position=UDim2.new(0.5,0,0.5,0); wGlow.AnchorPoint=Vector2.new(0.5,0.5)
    wGlow.BackgroundTransparency=1; wGlow.Image="rbxassetid://5028857084"; wGlow.ImageColor3=T.green; wGlow.ImageTransparency=1; wGlow.ZIndex=0
    local dot=Instance.new("Frame",wrapper); dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,12,0.5,0)
    dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.red; dot.BorderSizePixel=0; dot.ZIndex=8
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local dotStroke=Instance.new("UIStroke",dot); dotStroke.Color=T.red; dotStroke.Thickness=1.5; dotStroke.Transparency=0.5
    local lbl=Instance.new("TextLabel",wrapper); lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,24,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.textSub
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=UISettings.fontSize; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=8; regFS(lbl)
    local statusTxt=Instance.new("TextLabel",wrapper); statusTxt.Size=UDim2.new(0,36,1,0); statusTxt.Position=UDim2.new(1,-40,0,0)
    statusTxt.BackgroundTransparency=1; statusTxt.Text="OFF"; statusTxt.TextColor3=T.textDim
    statusTxt.Font=Enum.Font.GothamBold; statusTxt.TextSize=10; statusTxt.ZIndex=8
    local on=false; local externalCb=nil
    local function applyVisual(v)
        if v then
            smooth(wrapper,{BackgroundColor3=T.white},0.18):Play(); smooth(wStroke,{Color=T.green,Transparency=0.0,Thickness=1.4},0.18):Play()
            smooth(lbl,{TextColor3=T.black},0.18):Play(); smooth(dot,{BackgroundColor3=T.green},0.18):Play()
            smooth(dotStroke,{Color=T.green},0.18):Play(); smooth(wGlow,{ImageTransparency=0.76},0.26):Play()
            statusTxt.Text="ON"; smooth(statusTxt,{TextColor3=Color3.fromRGB(20,20,20)},0.1):Play()
        else
            smooth(wrapper,{BackgroundColor3=Color3.fromRGB(14,12,22)},0.18):Play(); smooth(wStroke,{Color=T.border,Transparency=0.3,Thickness=1.0},0.18):Play()
            smooth(lbl,{TextColor3=T.textSub},0.18):Play(); smooth(dot,{BackgroundColor3=T.red},0.18):Play()
            smooth(dotStroke,{Color=T.red},0.18):Play(); smooth(wGlow,{ImageTransparency=1},0.18):Play()
            statusTxt.Text="OFF"; smooth(statusTxt,{TextColor3=T.textDim},0.1):Play()
        end
    end
    local function setOn(v) on=v; applyVisual(v) end
    local function setCallback(cb) externalCb=cb end
    local hit=Instance.new("TextButton",wrapper); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=10
    hit.MouseEnter:Connect(function() if not on then smooth(wrapper,{BackgroundColor3=Color3.fromRGB(20,18,32)},0.1):Play() end end)
    hit.MouseLeave:Connect(function() if not on then smooth(wrapper,{BackgroundColor3=Color3.fromRGB(14,12,22)},0.1):Play() end end)
    hit.MouseButton1Click:Connect(function()
        on=not on; ripple(wrapper,wrapper.AbsoluteSize.X*0.5,wrapper.AbsoluteSize.Y*0.5,on and T.accent or T.black)
        applyVisual(on); if externalCb then externalCb(on) end
    end)
    task.spawn(function()
        while wrapper and wrapper.Parent do
            if on then ease(wGlow,{ImageTransparency=0.66},0.7):Play(); task.wait(0.82); ease(wGlow,{ImageTransparency=0.84},0.7):Play(); task.wait(0.82)
            else task.wait(0.5) end
        end
    end)
    return wrapper,setOn,function() return on end,setCallback
end
local function mkDropdownV2(parent,label,icon,iconCol,items,default,onChange,order)
    local HEADER_H=42; local ITEM_H=32
    local wrapper=Instance.new("Frame",parent)
    wrapper.Size=UDim2.new(1,0,0,HEADER_H); wrapper.BackgroundColor3=T.card; wrapper.BorderSizePixel=0
    wrapper.LayoutOrder=order or 0; wrapper.ClipsDescendants=true; wrapper.ZIndex=5
    Instance.new("UICorner",wrapper).CornerRadius=UDim.new(0,10)
    local wStroke=Instance.new("UIStroke",wrapper); wStroke.Color=T.border; wStroke.Transparency=0.45; wStroke.Thickness=0.8
    Instance.new("UIGradient",wrapper).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(22,20,34)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,13,22))}
    local header=Instance.new("TextButton",wrapper); header.Size=UDim2.new(1,0,0,HEADER_H); header.BackgroundTransparency=1; header.Text=""; header.ZIndex=8
    local icCircle=Instance.new("Frame",header); icCircle.Size=UDim2.new(0,22,0,22); icCircle.Position=UDim2.new(0,9,0.5,0)
    icCircle.AnchorPoint=Vector2.new(0,0.5); icCircle.BackgroundColor3=iconCol or T.accentSoft; icCircle.BorderSizePixel=0; icCircle.ZIndex=9
    Instance.new("UICorner",icCircle).CornerRadius=UDim.new(1,0)
    local icSym=Instance.new("TextLabel",icCircle); icSym.Size=UDim2.new(1,0,1,0); icSym.BackgroundTransparency=1; icSym.Text=icon or "?"
    icSym.TextColor3=T.white; icSym.Font=Enum.Font.GothamBold; icSym.TextSize=10; icSym.ZIndex=10
    local labelL=Instance.new("TextLabel",header); labelL.Size=UDim2.new(1,-104,1,0); labelL.Position=UDim2.new(0,38,0,0)
    labelL.BackgroundTransparency=1; labelL.Text=label; labelL.TextColor3=T.text
    labelL.Font=Enum.Font.GothamBold; labelL.TextSize=UISettings.fontSize; labelL.TextXAlignment=Enum.TextXAlignment.Left; labelL.ZIndex=9; regFS(labelL)
    local selValL=Instance.new("TextLabel",header); selValL.Size=UDim2.new(0,64,1,0); selValL.Position=UDim2.new(1,-88,0,0)
    selValL.BackgroundTransparency=1; selValL.Text=default or (items[1] or ""); selValL.TextColor3=T.accentGlow
    selValL.Font=Enum.Font.Gotham; selValL.TextSize=9; selValL.TextXAlignment=Enum.TextXAlignment.Right; selValL.ZIndex=9; regAccent("txtGlow",selValL)
    local arrowL=Instance.new("TextLabel",header); arrowL.Size=UDim2.new(0,22,1,0); arrowL.Position=UDim2.new(1,-24,0,0)
    arrowL.BackgroundTransparency=1; arrowL.Text="v"; arrowL.TextColor3=T.textSub; arrowL.Font=Enum.Font.GothamBold; arrowL.TextSize=10; arrowL.ZIndex=9
    local selected=default or items[1]; local itemFrames={}; local open=false
    local CLOSED_H=HEADER_H; local OPEN_H=HEADER_H+#items*ITEM_H+2
    local function setOpen(state)
        open=state; smooth(wrapper,{Size=UDim2.new(1,0,0,state and OPEN_H or CLOSED_H)},0.24):Play()
        smooth(arrowL,{Rotation=state and 180 or 0},0.18):Play()
        if state then smooth(wStroke,{Color=T.accentGlow,Transparency=0.05,Thickness=1.2},0.18):Play(); smooth(wrapper,{BackgroundColor3=T.cardHover},0.18):Play()
        else smooth(wStroke,{Color=T.border,Transparency=0.45,Thickness=0.8},0.18):Play(); smooth(wrapper,{BackgroundColor3=T.card},0.18):Play() end
    end
    for idx,item in ipairs(items) do
        local yOff=HEADER_H+(idx-1)*ITEM_H
        local sep=Instance.new("Frame",wrapper); sep.Size=UDim2.new(1,-12,0,1); sep.Position=UDim2.new(0,6,0,yOff)
        sep.BackgroundColor3=T.border; sep.BackgroundTransparency=0.25; sep.BorderSizePixel=0; sep.ZIndex=6
        local itemBtn=Instance.new("TextButton",wrapper); itemBtn.Size=UDim2.new(1,0,0,ITEM_H); itemBtn.Position=UDim2.new(0,0,0,yOff+1)
        itemBtn.BackgroundTransparency=1; itemBtn.Text=""; itemBtn.ZIndex=7
        local hlBg=Instance.new("Frame",itemBtn); hlBg.Size=UDim2.new(1,-12,1,-6); hlBg.Position=UDim2.new(0,6,0,3)
        hlBg.BackgroundColor3=T.accent; hlBg.BackgroundTransparency=(item==selected) and 0.78 or 1; hlBg.BorderSizePixel=0; hlBg.ZIndex=7
        Instance.new("UICorner",hlBg).CornerRadius=UDim.new(0,6); regAccent("bgAccent",hlBg)
        local itemDot=Instance.new("Frame",itemBtn); itemDot.Size=UDim2.new(0,4,0,4); itemDot.Position=UDim2.new(0,13,0.5,0)
        itemDot.AnchorPoint=Vector2.new(0,0.5); itemDot.BackgroundColor3=(item==selected) and T.accentGlow or T.textDim
        itemDot.BackgroundTransparency=(item==selected) and 0 or 0.6; itemDot.BorderSizePixel=0; itemDot.ZIndex=8
        Instance.new("UICorner",itemDot).CornerRadius=UDim.new(1,0)
        local itemTxt=Instance.new("TextLabel",itemBtn); itemTxt.Size=UDim2.new(1,-44,1,0); itemTxt.Position=UDim2.new(0,22,0,0)
        itemTxt.BackgroundTransparency=1; itemTxt.Text=item; itemTxt.TextColor3=(item==selected) and T.white or T.textSub
        itemTxt.Font=(item==selected) and Enum.Font.GothamBold or Enum.Font.Gotham; itemTxt.TextSize=10; itemTxt.TextXAlignment=Enum.TextXAlignment.Left; itemTxt.ZIndex=8
        local checkL=Instance.new("TextLabel",itemBtn); checkL.Size=UDim2.new(0,20,1,0); checkL.Position=UDim2.new(1,-22,0,0)
        checkL.BackgroundTransparency=1; checkL.Text=(item==selected) and "v" or ""; checkL.TextColor3=T.accentGlow
        checkL.Font=Enum.Font.GothamBold; checkL.TextSize=10; checkL.ZIndex=8; regAccent("txtGlow",checkL)
        itemFrames[idx]={btn=itemBtn,hlBg=hlBg,dot=itemDot,txt=itemTxt,check=checkL}
        itemBtn.MouseEnter:Connect(function()
            if item~=selected then smooth(hlBg,{BackgroundTransparency=0.88},0.08):Play(); smooth(itemTxt,{TextColor3=T.text},0.08):Play() end
        end)
        itemBtn.MouseLeave:Connect(function()
            if item~=selected then smooth(hlBg,{BackgroundTransparency=1},0.08):Play(); smooth(itemTxt,{TextColor3=T.textSub},0.08):Play() end
        end)
        local ci=item
        itemBtn.MouseButton1Click:Connect(function()
            selected=ci; selValL.Text=ci; ripple(itemBtn,itemBtn.AbsoluteSize.X*0.5,itemBtn.AbsoluteSize.Y*0.5,T.accent)
            for i2,d in ipairs(itemFrames) do
                local isSel=(items[i2]==selected)
                smooth(d.hlBg,{BackgroundTransparency=isSel and 0.78 or 1},0.14):Play()
                smooth(d.dot,{BackgroundColor3=isSel and T.accentGlow or T.textDim,BackgroundTransparency=isSel and 0 or 0.6},0.14):Play()
                smooth(d.txt,{TextColor3=isSel and T.white or T.textSub},0.14):Play()
                d.txt.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham; d.check.Text=isSel and "v" or ""
            end
            if onChange then onChange(ci) end; setOpen(false)
        end)
    end
    header.MouseButton1Click:Connect(function() ripple(header,header.AbsoluteSize.X*0.5,header.AbsoluteSize.Y*0.5,T.accent); setOpen(not open) end)
    header.MouseEnter:Connect(function() if not open then smooth(wrapper,{BackgroundColor3=T.cardHover},0.1):Play() end end)
    header.MouseLeave:Connect(function() if not open then smooth(wrapper,{BackgroundColor3=T.card},0.1):Play() end end)
    return wrapper,function() return selected end
end
local function mkSubTabBar(parent,tabs)
    local BAR_H=30
    local barContainer=Instance.new("Frame",parent); barContainer.Size=UDim2.new(1,0,0,BAR_H)
    barContainer.BackgroundColor3=Color3.fromRGB(11,10,18); barContainer.BorderSizePixel=0; barContainer.ZIndex=8
    Instance.new("UICorner",barContainer).CornerRadius=UDim.new(0,9)
    local bcStroke=Instance.new("UIStroke",barContainer); bcStroke.Color=T.border; bcStroke.Transparency=0.2; bcStroke.Thickness=1.0
    for i=1,#tabs-1 do
        local ts=Instance.new("Frame",barContainer); ts.Size=UDim2.new(0,1,0.5,0); ts.Position=UDim2.new(i/#tabs,0,0.25,0)
        ts.BackgroundColor3=T.border; ts.BackgroundTransparency=0.4; ts.BorderSizePixel=0; ts.ZIndex=9
    end
    local sep=Instance.new("Frame",parent); sep.Size=UDim2.new(1,0,0,1); sep.Position=UDim2.new(0,0,0,BAR_H+2)
    sep.BackgroundColor3=T.border; sep.BackgroundTransparency=0.3; sep.BorderSizePixel=0; sep.ZIndex=8
    local pill=Instance.new("Frame",barContainer); pill.Size=UDim2.new(1/#tabs,-6,0,BAR_H-8); pill.Position=UDim2.new(0,3,0,4)
    pill.BackgroundColor3=T.accent; pill.BorderSizePixel=0; pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(0,6)
    Instance.new("UIGradient",pill).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accent)}
    regAccent("bgAccent",pill)
    local tabTextSize=#tabs>=5 and 9 or 10; local subBtns={}; local subPages={}
    local function switchSub(idx)
        smooth(pill,{Position=UDim2.new((idx-1)/#tabs,3,0,4)},0.22):Play()
        for i2,d in ipairs(subBtns) do smooth(d.lbl,{TextColor3=(i2==idx) and T.white or T.textSub},0.18):Play(); d.subPage.Visible=(i2==idx) end
    end
    for i,name in ipairs(tabs) do
        local sbtn=Instance.new("TextButton",barContainer); sbtn.Size=UDim2.new(1/#tabs,0,1,0); sbtn.Position=UDim2.new((i-1)/#tabs,0,0,0)
        sbtn.BackgroundTransparency=1; sbtn.Text=""; sbtn.ZIndex=10
        local slbl=Instance.new("TextLabel",sbtn); slbl.Size=UDim2.new(1,0,1,0); slbl.BackgroundTransparency=1; slbl.Text=name
        slbl.TextColor3=(i==1) and T.white or T.textSub; slbl.Font=Enum.Font.GothamBold; slbl.TextSize=tabTextSize; slbl.ZIndex=11
        local subOuter=Instance.new("Frame",parent); subOuter.Size=UDim2.new(1,0,1,-BAR_H-4); subOuter.Position=UDim2.new(0,0,0,BAR_H+4)
        subOuter.BackgroundTransparency=1; subOuter.Visible=(i==1); subOuter.ZIndex=3
        subPages[name]=subOuter; subBtns[i]={lbl=slbl,subPage=subOuter}
        local ci=i
        sbtn.MouseButton1Click:Connect(function() ripple(sbtn,sbtn.AbsoluteSize.X*0.5,sbtn.AbsoluteSize.Y*0.5,T.white); switchSub(ci) end)
    end
    return subPages
end

-- lib table untuk dipakai pages
local lib={
    T=T, UISettings=UISettings,
    regAccent=regAccent, applyAccent=applyAccent,
    regFS=regFS, applyFontSize=applyFontSize,
    smooth=smooth, spring=spring, ease=ease, ripple=ripple,
    mkScrollPage=mkScrollPage, mkTwoColLayout=mkTwoColLayout,
    mkGroupBox=mkGroupBox, mkSectionLabel=mkSectionLabel,
    mkSection=mkSection, mkCard=mkCard, mkStatus=mkStatus,
    mkToggle=mkToggle, mkSlider=mkSlider, mkOnOffBtn=mkOnOffBtn,
    mkDropdownV2=mkDropdownV2, mkSubTabBar=mkSubTabBar,
}

-- ╔══════════════════════════════════╗
-- ║         MAIN SETUP               ║
-- ╚══════════════════════════════════╝
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local player       = Players.LocalPlayer

-- Viewport size dengan fallback
local camera = game.Workspace.CurrentCamera
local function getViewport()
    local vp=camera.ViewportSize; local waited=0
    while (vp.X==0 or vp.Y==0) and waited<3 do task.wait(0.05); waited=waited+0.05; vp=camera.ViewportSize end
    if vp.X==0 or vp.Y==0 then return Vector2.new(812,375) end
    return vp
end
local vp        = getViewport()
local WIN_W     = math.min(math.max(vp.X*0.88,360),700)
local WIN_H     = math.min(math.max(vp.Y*0.64,240),440)
local SIDEBAR_W = 68
local TOPBAR_H  = 50
local BOTBAR_H  = 26

-- Screen GUI dengan fallback CoreGui → PlayerGui
local gui
local ok_gui = pcall(function()
    gui=Instance.new("ScreenGui"); gui.Name="YiDaMuSake"; gui.ResetOnSpawn=false
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset=true
    gui.Parent=game:GetService("CoreGui")
end)
if not ok_gui or not gui then
    gui=Instance.new("ScreenGui"); gui.Name="YiDaMuSake"; gui.ResetOnSpawn=false
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset=true
    gui.Parent=player.PlayerGui
end

-- ROOT
local root=Instance.new("Frame"); root.Name="Root"
root.Size=UDim2.new(0,WIN_W,0,WIN_H); root.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
root.BackgroundColor3=T.bg; root.BorderSizePixel=0; root.ClipsDescendants=false; root.Active=true; root.Parent=gui
local rootCorner=Instance.new("UICorner",root); rootCorner.CornerRadius=UDim.new(0,14)
local rootGlow=Instance.new("ImageLabel",root)
rootGlow.Size=UDim2.new(1,100,1,100); rootGlow.Position=UDim2.new(0.5,0,0.5,0); rootGlow.AnchorPoint=Vector2.new(0.5,0.5)
rootGlow.BackgroundTransparency=1; rootGlow.Image="rbxassetid://5028857084"; rootGlow.ImageColor3=T.accent
rootGlow.ImageTransparency=0.88; rootGlow.ZIndex=0; regAccent("imgAccent",rootGlow)
local rootStroke=Instance.new("UIStroke",root); rootStroke.Color=T.border; rootStroke.Thickness=1.5; rootStroke.Transparency=0.1
regAccent("stAccent",rootStroke)
task.spawn(function() while rootGlow and rootGlow.Parent do ease(rootGlow,{ImageTransparency=0.80},1.4):Play(); task.wait(1.5); ease(rootGlow,{ImageTransparency=0.92},1.4):Play(); task.wait(1.5) end end)
task.spawn(function() while rootStroke and rootStroke.Parent do ease(rootStroke,{Color=T.borderBright,Transparency=0.0},1.6):Play(); task.wait(1.7); ease(rootStroke,{Color=T.border,Transparency=0.2},1.6):Play(); task.wait(1.7) end end)

local inner=Instance.new("Frame",root); inner.Size=UDim2.new(1,0,1,0); inner.BackgroundTransparency=1; inner.ClipsDescendants=true; inner.ZIndex=1
local bgF=Instance.new("Frame",inner); bgF.Size=UDim2.new(1,0,1,0); bgF.BackgroundColor3=T.bg; bgF.BorderSizePixel=0; bgF.ZIndex=1
Instance.new("UICorner",bgF).CornerRadius=UDim.new(0,14)
local bgGrad=Instance.new("UIGradient",bgF)
bgGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(14,10,26)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,7,14)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,9,20))}
bgGrad.Rotation=125
task.spawn(function() local r=125; while bgGrad and bgGrad.Parent do r=r+0.04; bgGrad.Rotation=r; task.wait(0.06) end end)

-- Blur
local screenBlur=Instance.new("BlurEffect"); screenBlur.Size=0; screenBlur.Parent=camera
local miniBar; local miniBarVisible=false
local function setBlur(sz,dur) TweenService:Create(screenBlur,TweenInfo.new(dur or 0.35,Enum.EasingStyle.Quint),{Size=sz}):Play() end
local function refreshBlur()
    if miniBarVisible and UISettings.miniBgMode=="Blur" then setBlur(12)
    elseif not miniBarVisible and root.Visible and UISettings.uiBgMode=="Blur" then setBlur(18)
    else setBlur(0) end
end
local function applyUIBgMode(mode)
    UISettings.uiBgMode=mode
    if mode=="Solid" then smooth(bgF,{BackgroundTransparency=0},0.3):Play(); smooth(root,{BackgroundTransparency=0},0.3):Play()
    elseif mode=="Transparent" then smooth(bgF,{BackgroundTransparency=0.80},0.3):Play(); smooth(root,{BackgroundTransparency=0.60},0.3):Play()
    elseif mode=="Blur" then smooth(bgF,{BackgroundTransparency=0.55},0.3):Play(); smooth(root,{BackgroundTransparency=0.35},0.3):Play() end
    refreshBlur()
end
local function applyMiniBgMode(mode)
    UISettings.miniBgMode=mode; if not miniBar then return end
    if mode=="Solid" then miniBar.BackgroundTransparency=0
    elseif mode=="Transparent" then miniBar.BackgroundTransparency=0.72
    elseif mode=="Blur" then miniBar.BackgroundTransparency=0.40 end
    if miniBarVisible then refreshBlur() end
end

-- Particles
local particleList={}
local function spawnParticles(count)
    for _,p in ipairs(particleList) do pcall(function() p:Destroy() end) end; particleList={}; math.randomseed(tick())
    for i=1,count do
        task.spawn(function()
            task.wait(math.random(0,20)/10)
            local p=Instance.new("Frame"); local sz=math.random(1,4)
            p.Size=UDim2.new(0,sz,0,sz); p.Position=UDim2.new(math.random(2,98)/100,0,math.random(2,98)/100,0)
            p.BackgroundColor3=Color3.fromHSV(math.random(258,295)/360,0.65,0.88)
            p.BackgroundTransparency=math.random(60,82)/100; p.BorderSizePixel=0; p.ZIndex=1; p.Parent=bgF
            Instance.new("UICorner",p).CornerRadius=UDim.new(1,0); table.insert(particleList,p)
            while p and p.Parent do
                if not UISettings.particles then p.Visible=false; task.wait(0.5); continue end
                p.Visible=true
                local nx=math.clamp(p.Position.X.Scale+math.random(-7,7)/100,0.01,0.99)
                local ny=math.clamp(p.Position.Y.Scale+math.random(-7,7)/100,0.01,0.99)
                local dur=math.random(40,70)/10
                TweenService:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true),{Position=UDim2.new(nx,0,ny,0),BackgroundTransparency=math.random(44,80)/100}):Play()
                task.wait(dur)
            end
        end)
    end
end
spawnParticles(UISettings.particleCount)

-- TOPBAR
local topBar=Instance.new("Frame",inner); topBar.Size=UDim2.new(1,0,0,TOPBAR_H)
topBar.BackgroundColor3=Color3.fromRGB(9,8,16); topBar.BorderSizePixel=0; topBar.ZIndex=5
Instance.new("UICorner",topBar).CornerRadius=UDim.new(0,14)
local topFix=Instance.new("Frame",topBar); topFix.Size=UDim2.new(1,0,0,14); topFix.Position=UDim2.new(0,0,1,-14)
topFix.BackgroundColor3=Color3.fromRGB(9,8,16); topFix.BorderSizePixel=0; topFix.ZIndex=5
local topSep=Instance.new("Frame",inner); topSep.Size=UDim2.new(1,0,0,1); topSep.Position=UDim2.new(0,0,0,TOPBAR_H)
topSep.BackgroundColor3=T.border; topSep.BackgroundTransparency=0.1; topSep.BorderSizePixel=0; topSep.ZIndex=6

local iconBg=Instance.new("Frame",topBar); iconBg.Size=UDim2.new(0,30,0,30); iconBg.Position=UDim2.new(0,12,0.5,0)
iconBg.AnchorPoint=Vector2.new(0,0.5); iconBg.BackgroundColor3=T.accentSoft; iconBg.BorderSizePixel=0; iconBg.ZIndex=7
Instance.new("UICorner",iconBg).CornerRadius=UDim.new(0,8); regAccent("bgSoft",iconBg)
Instance.new("UIGradient",iconBg).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accentSoft)}
local iconImg=Instance.new("ImageLabel",iconBg); iconImg.Size=UDim2.new(0.76,0,0.76,0); iconImg.Position=UDim2.new(0.5,0,0.5,0)
iconImg.AnchorPoint=Vector2.new(0.5,0.5); iconImg.BackgroundTransparency=1; iconImg.Image="rbxassetid://110843044052526"; iconImg.ZIndex=8
local titleL=Instance.new("TextLabel",topBar); titleL.Size=UDim2.new(0,160,0,16); titleL.Position=UDim2.new(0,50,0,7)
titleL.BackgroundTransparency=1; titleL.Text="Yi Da Mu Sake"; titleL.TextColor3=T.text
titleL.Font=Enum.Font.GothamBold; titleL.TextSize=13; titleL.TextXAlignment=Enum.TextXAlignment.Left; titleL.ZIndex=7
local subTitleL=Instance.new("TextLabel",topBar); subTitleL.Size=UDim2.new(0,160,0,12); subTitleL.Position=UDim2.new(0,50,0,26)
subTitleL.BackgroundTransparency=1; subTitleL.Text="sailor piece  v8.2"; subTitleL.TextColor3=T.textDim
subTitleL.Font=Enum.Font.Gotham; subTitleL.TextSize=9; subTitleL.TextXAlignment=Enum.TextXAlignment.Left; subTitleL.ZIndex=7

local function mkWinBtn(offX,col,sym)
    local b=Instance.new("TextButton",topBar); b.Size=UDim2.new(0,18,0,18); b.Position=UDim2.new(1,offX,0.5,0)
    b.AnchorPoint=Vector2.new(1,0.5); b.BackgroundColor3=col; b.Text=""; b.BorderSizePixel=0; b.ZIndex=8
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",b); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=sym
    lbl.TextColor3=T.white; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextTransparency=0.35; lbl.ZIndex=9
    b.MouseEnter:Connect(function() smooth(b,{BackgroundTransparency=0.18},0.12):Play(); smooth(lbl,{TextTransparency=0},0.12):Play() end)
    b.MouseLeave:Connect(function() smooth(b,{BackgroundTransparency=0},0.12):Play(); smooth(lbl,{TextTransparency=0.35},0.12):Play() end)
    return b
end
local closeBtn=mkWinBtn(-10,Color3.fromRGB(198,50,62),"x")
local minBtn  =mkWinBtn(-34,Color3.fromRGB(185,138,22),"-")

-- Drag
do
    local drag,dragStart,startPos=false,nil,nil
    topBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; dragStart=i.Position; startPos=root.Position end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart; root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

-- Resize
local rh=Instance.new("TextButton",root); rh.Size=UDim2.new(0,20,0,20); rh.Position=UDim2.new(1,-2,1,-2); rh.AnchorPoint=Vector2.new(1,1)
rh.BackgroundColor3=Color3.fromRGB(22,20,34); rh.BackgroundTransparency=0.4; rh.Text=""; rh.BorderSizePixel=0; rh.ZIndex=20
Instance.new("UICorner",rh).CornerRadius=UDim.new(0,6)
for di=1,3 do
    local dot=Instance.new("Frame",rh); dot.Size=UDim2.new(0,2,0,2); dot.Position=UDim2.new(0,2+di*4,0,2+di*4)
    dot.BackgroundColor3=T.accentGlow; dot.BackgroundTransparency=0.4; dot.BorderSizePixel=0; dot.ZIndex=21
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
end
do
    local resizing,rsStart,rStartW,rStartH=false,nil,nil,nil; local MIN_W,MIN_H=360,240
    rh.MouseButton1Down:Connect(function() resizing=true; rsStart=UIS:GetMouseLocation(); rStartW=root.AbsoluteSize.X; rStartH=root.AbsoluteSize.Y end)
    UIS.InputChanged:Connect(function(i)
        if resizing and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local cur=(i.UserInputType==Enum.UserInputType.Touch) and i.Position or UIS:GetMouseLocation()
            WIN_W=math.clamp(rStartW+(cur.X-rsStart.X),MIN_W,vp.X*0.96); WIN_H=math.clamp(rStartH+(cur.Y-rsStart.Y),MIN_H,vp.Y*0.96)
            root.Size=UDim2.new(0,WIN_W,0,WIN_H)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then resizing=false end
    end)
end

-- Minibar
local miniExpLbl=nil
miniBar=Instance.new("Frame",gui); miniBar.Size=UDim2.new(0,46,0,46); miniBar.Position=UDim2.new(0.5,-23,0,10)
miniBar.BackgroundColor3=Color3.fromRGB(11,10,18); miniBar.BorderSizePixel=0; miniBar.ZIndex=200; miniBar.Visible=false
Instance.new("UICorner",miniBar).CornerRadius=UDim.new(0,23)
local miniStroke=Instance.new("UIStroke",miniBar); miniStroke.Color=T.borderBright; miniStroke.Thickness=1.5; miniStroke.Transparency=0.12
local miniGlow=Instance.new("ImageLabel",miniBar); miniGlow.Size=UDim2.new(1,34,1,34); miniGlow.Position=UDim2.new(0.5,0,0.5,0)
miniGlow.AnchorPoint=Vector2.new(0.5,0.5); miniGlow.BackgroundTransparency=1; miniGlow.Image="rbxassetid://5028857084"
miniGlow.ImageColor3=T.accent; miniGlow.ImageTransparency=0.84; miniGlow.ZIndex=0; regAccent("imgAccent",miniGlow)
local miniIconBg=Instance.new("Frame",miniBar); miniIconBg.Size=UDim2.new(0,36,0,36); miniIconBg.Position=UDim2.new(0,5,0.5,0)
miniIconBg.AnchorPoint=Vector2.new(0,0.5); miniIconBg.BackgroundColor3=T.accentSoft; miniIconBg.BorderSizePixel=0; miniIconBg.ZIndex=201
Instance.new("UICorner",miniIconBg).CornerRadius=UDim.new(0,9); regAccent("bgSoft",miniIconBg)
Instance.new("UIGradient",miniIconBg).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accentSoft)}
local miniIconImg=Instance.new("ImageLabel",miniIconBg); miniIconImg.Size=UDim2.new(0.82,0,0.82,0); miniIconImg.Position=UDim2.new(0.5,0,0.5,0)
miniIconImg.AnchorPoint=Vector2.new(0.5,0.5); miniIconImg.BackgroundTransparency=1; miniIconImg.Image="rbxassetid://110843044052526"; miniIconImg.ZIndex=202
local miniHit=Instance.new("TextButton",miniBar); miniHit.Size=UDim2.new(1,0,1,0); miniHit.BackgroundTransparency=1; miniHit.Text=""; miniHit.ZIndex=203
task.spawn(function()
    while miniBar and miniBar.Parent do
        if miniBar.Visible then ease(miniGlow,{ImageTransparency=0.70},0.9):Play(); task.wait(1.0); ease(miniGlow,{ImageTransparency=0.86},0.9):Play(); task.wait(1.0)
        else task.wait(0.5) end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    setBlur(0,0.18); smooth(root,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.22):Play()
    task.wait(0.24); gui:Destroy(); pcall(function() screenBlur:Destroy() end)
end)
minBtn.MouseButton1Click:Connect(function()
    miniBarVisible=true; smooth(root,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.22):Play()
    task.wait(0.24); root.Visible=false; applyMiniBgMode(UISettings.miniBgMode)
    miniBar.Size=UDim2.new(0,46,0,46); miniBar.Position=UDim2.new(0.5,-23,0,10); miniBar.Visible=true
    spring(miniBar,{Size=UDim2.new(0,228,0,46)},0.44):Play()
    task.spawn(function() task.wait(0.12); smooth(miniBar,{Position=UDim2.new(0.5,-114,0,10)},0.20):Play() end)
    task.spawn(function()
        task.wait(0.20); if miniExpLbl then miniExpLbl:Destroy(); miniExpLbl=nil end
        miniExpLbl=Instance.new("TextLabel",miniBar); miniExpLbl.Size=UDim2.new(1,-50,1,0); miniExpLbl.Position=UDim2.new(0,46,0,0)
        miniExpLbl.BackgroundTransparency=1; miniExpLbl.Text="Yi Da Mu Sake"; miniExpLbl.TextColor3=T.text
        miniExpLbl.Font=Enum.Font.GothamBold; miniExpLbl.TextSize=13; miniExpLbl.TextXAlignment=Enum.TextXAlignment.Center
        miniExpLbl.TextTransparency=1; miniExpLbl.ZIndex=202; smooth(miniExpLbl,{TextTransparency=0},0.24):Play()
    end)
end)
miniHit.MouseButton1Click:Connect(function()
    miniBarVisible=false; refreshBlur()
    if miniExpLbl then smooth(miniExpLbl,{TextTransparency=1},0.12):Play(); task.wait(0.14); pcall(function() if miniExpLbl then miniExpLbl:Destroy(); miniExpLbl=nil end end) end
    smooth(miniBar,{Size=UDim2.new(0,46,0,46),Position=UDim2.new(0.5,-23,0,10)},0.18):Play()
    task.wait(0.20); miniBar.Visible=false; root.Visible=true
    root.Size=UDim2.new(0,WIN_W,0,0); root.BackgroundTransparency=1
    spring(root,{Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0},0.42):Play()
    task.delay(0.5,function() applyUIBgMode(UISettings.uiBgMode) end)
end)

-- SIDEBAR
local sidebar=Instance.new("Frame",inner); sidebar.Size=UDim2.new(0,SIDEBAR_W,1,-TOPBAR_H-1); sidebar.Position=UDim2.new(0,0,0,TOPBAR_H+1)
sidebar.BackgroundColor3=Color3.fromRGB(9,8,16); sidebar.BorderSizePixel=0; sidebar.ZIndex=4; sidebar.ClipsDescendants=true
Instance.new("UICorner",sidebar).CornerRadius=UDim.new(0,14)
local sideFix=Instance.new("Frame",sidebar); sideFix.Size=UDim2.new(0,14,1,0); sideFix.Position=UDim2.new(1,-14,0,0)
sideFix.BackgroundColor3=Color3.fromRGB(9,8,16); sideFix.BorderSizePixel=0; sideFix.ZIndex=4
local sideVLine=Instance.new("Frame",inner); sideVLine.Size=UDim2.new(0,1,1,-TOPBAR_H-1); sideVLine.Position=UDim2.new(0,SIDEBAR_W,0,TOPBAR_H+1)
sideVLine.BackgroundColor3=T.border; sideVLine.BackgroundTransparency=0.1; sideVLine.BorderSizePixel=0; sideVLine.ZIndex=6
local sideList=Instance.new("Frame",sidebar); sideList.Size=UDim2.new(1,0,1,-8); sideList.Position=UDim2.new(0,0,0,10)
sideList.BackgroundTransparency=1; sideList.ZIndex=5
local slL=Instance.new("UIListLayout",sideList); slL.Padding=UDim.new(0,4); slL.SortOrder=Enum.SortOrder.LayoutOrder; slL.HorizontalAlignment=Enum.HorizontalAlignment.Center
local slP=Instance.new("UIPadding",sideList); slP.PaddingLeft=UDim.new(0,6); slP.PaddingRight=UDim.new(0,6)
local contentArea=Instance.new("Frame",inner); contentArea.Size=UDim2.new(1,-SIDEBAR_W-1,1,-TOPBAR_H-1); contentArea.Position=UDim2.new(0,SIDEBAR_W+1,0,TOPBAR_H+1)
contentArea.BackgroundTransparency=1; contentArea.ZIndex=3

local MAIN_TABS={{name="Info",sym="i",tip="Info"},{name="Main",sym="M",tip="Main"},{name="Settings",sym="S",tip="Settings"}}
local sideData={}
local function switchMainTab(name)
    for _,d in pairs(sideData) do
        local on=(d.name==name); smooth(d.iconBg,{BackgroundTransparency=on and 0 or 1},0.20):Play()
        smooth(d.iconL,{TextColor3=on and T.white or T.textDim},0.20):Play(); d.bar.Visible=on; d.page.Visible=on
    end
end
for i,tab in ipairs(MAIN_TABS) do
    local btn=Instance.new("TextButton",sideList); btn.Size=UDim2.new(1,0,0,52); btn.BackgroundTransparency=1
    btn.Text=""; btn.BorderSizePixel=0; btn.LayoutOrder=i; btn.ZIndex=6
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    local bar=Instance.new("Frame",btn); bar.Size=UDim2.new(0,3,0.45,0); bar.Position=UDim2.new(0,-4,0.5,0)
    bar.AnchorPoint=Vector2.new(0,0.5); bar.BackgroundColor3=T.accentGlow; bar.BorderSizePixel=0; bar.Visible=false; bar.ZIndex=7
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0); regAccent("bgGlow",bar)
    local iconBg2=Instance.new("Frame",btn); iconBg2.Size=UDim2.new(0,40,0,40); iconBg2.Position=UDim2.new(0.5,0,0.5,0)
    iconBg2.AnchorPoint=Vector2.new(0.5,0.5); iconBg2.BackgroundColor3=T.accentSoft; iconBg2.BackgroundTransparency=1; iconBg2.BorderSizePixel=0; iconBg2.ZIndex=6
    Instance.new("UICorner",iconBg2).CornerRadius=UDim.new(0,10); regAccent("bgSoft",iconBg2)
    local iconL=Instance.new("TextLabel",btn); iconL.Size=UDim2.new(1,0,1,0); iconL.BackgroundTransparency=1
    iconL.Text=tab.sym; iconL.TextColor3=T.textDim; iconL.Font=Enum.Font.GothamBold; iconL.TextSize=20; iconL.ZIndex=7
    local tooltip=Instance.new("TextLabel",btn); tooltip.Size=UDim2.new(0,70,0,22); tooltip.Position=UDim2.new(1,6,0.5,0)
    tooltip.AnchorPoint=Vector2.new(0,0.5); tooltip.BackgroundColor3=Color3.fromRGB(20,18,32); tooltip.TextColor3=T.text
    tooltip.Text=tab.tip; tooltip.Font=Enum.Font.GothamBold; tooltip.TextSize=10; tooltip.Visible=false; tooltip.ZIndex=50; tooltip.BorderSizePixel=0
    Instance.new("UICorner",tooltip).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",tooltip).Color=T.borderBright
    btn.MouseEnter:Connect(function() tooltip.Visible=true; smooth(iconBg2,{BackgroundTransparency=0.85},0.14):Play() end)
    btn.MouseLeave:Connect(function()
        tooltip.Visible=false
        local isActive=(sideData[tab.name] and sideData[tab.name].bar.Visible)
        if not isActive then smooth(iconBg2,{BackgroundTransparency=1},0.14):Play() end
    end)
    local page=Instance.new("Frame",contentArea); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.Visible=false; page.ZIndex=3
    sideData[tab.name]={name=tab.name,btn=btn,bar=bar,iconL=iconL,iconBg=iconBg2,page=page}
    btn.MouseButton1Click:Connect(function() ripple(btn,btn.AbsoluteSize.X*0.5,btn.AbsoluteSize.Y*0.5,T.accent); switchMainTab(tab.name) end)
end

-- Bottom bar
local botBar=Instance.new("Frame",inner); botBar.Size=UDim2.new(1,0,0,BOTBAR_H); botBar.Position=UDim2.new(0,0,1,-BOTBAR_H)
botBar.BackgroundColor3=Color3.fromRGB(8,7,14); botBar.BorderSizePixel=0; botBar.ZIndex=5
local botFix=Instance.new("Frame",botBar); botFix.Size=UDim2.new(1,0,0,14); botFix.BackgroundColor3=Color3.fromRGB(8,7,14); botFix.BorderSizePixel=0; botFix.ZIndex=5
Instance.new("UICorner",botBar).CornerRadius=UDim.new(0,14); Instance.new("UIStroke",botBar).Color=T.border
local verL=Instance.new("TextLabel",botBar); verL.Size=UDim2.new(0.5,0,1,0); verL.Position=UDim2.new(0,12,0,0)
verL.BackgroundTransparency=1; verL.Text="sailor piece  v8.2 | Anti-AFK ON"; verL.TextColor3=T.textDim
verL.Font=Enum.Font.Gotham; verL.TextSize=9; verL.TextXAlignment=Enum.TextXAlignment.Left; verL.ZIndex=6
local dotL=Instance.new("TextLabel",botBar); dotL.Size=UDim2.new(0.5,-12,1,0); dotL.Position=UDim2.new(0.5,0,0,0)
dotL.BackgroundTransparency=1; dotL.Text="* online"; dotL.TextColor3=T.green; dotL.Font=Enum.Font.GothamBold; dotL.TextSize=9; dotL.TextXAlignment=Enum.TextXAlignment.Right; dotL.ZIndex=6
task.spawn(function() while dotL and dotL.Parent do ease(dotL,{TextColor3=T.green},0.9):Play(); task.wait(1.0); ease(dotL,{TextColor3=T.greenDim},0.9):Play(); task.wait(1.0) end end)

-- ╔══════════════════════════════════╗
-- ║         PAGES BUILDER            ║
-- ╚══════════════════════════════════╝
local TELEPORT_LOCATIONS={"Starter","Jungle","Desert","Snow","Sailor","Shibuya","HollowIsland","Boss","Dungeon","Shinjuku","Slime","Academy","Judgement","Ninja","Lawless","Tower"}
local FARM_ISLANDS={"Starter Island","Jungle Island","Desert Island","Snow Island","Shibuya","Hollow","Shinjuku Island#1","Shinjuku Island#2","Slime","Academy","Judgement","Soul Dominion","Ninja","Lawless"}
local KNOWN_BOSSES={"AizenBoss","AlucardBoss","JinwooBoss","SukunaBoss","YujiBoss","GojoBoss","KnightBoss","YamatoBoss","StrongestShinobiBoss"}

local function findTimerTextLabel(container)
    for _,desc in ipairs(container:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local txt=desc.Text or ""
            if txt:match("^%d+:%d%d$") or txt:match("^%d+:%d%d:%d%d$") then return desc end
        end
    end
    return nil
end
local function parseTimerSecs(text)
    if not text then return -1 end
    local h,m,s=text:match("^(%d+):(%d+):(%d+)$")
    if h then return tonumber(h)*3600+tonumber(m)*60+tonumber(s) end
    local m2,s2=text:match("^(%d+):(%d+)$"); if m2 then return tonumber(m2)*60+tonumber(s2) end
    return -1
end
local function showNotif(title,subtitle,col)
    pcall(function()
        local snd=Instance.new("Sound"); snd.SoundId="rbxassetid://82845990304289"; snd.Volume=0.65
        snd.RollOffMaxDistance=1000; snd.Parent=game:GetService("SoundService")
        game:GetService("SoundService"):PlayLocalSound(snd); game:GetService("Debris"):AddItem(snd,6)
    end)
    local notif=Instance.new("Frame",gui); notif.Size=UDim2.new(0,290,0,60); notif.Position=UDim2.new(0.5,-145,0,-72)
    notif.BackgroundColor3=Color3.fromRGB(12,11,20); notif.BorderSizePixel=0; notif.ZIndex=600
    Instance.new("UICorner",notif).CornerRadius=UDim.new(0,12)
    local ns=Instance.new("UIStroke",notif); ns.Color=col or T.green; ns.Thickness=1.4; ns.Transparency=0.1
    local bar=Instance.new("Frame",notif); bar.Size=UDim2.new(0,3,1,-14); bar.Position=UDim2.new(0,8,0,7)
    bar.BackgroundColor3=col or T.green; bar.BorderSizePixel=0; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local tl=Instance.new("TextLabel",notif); tl.Size=UDim2.new(1,-28,0,22); tl.Position=UDim2.new(0,20,0,8)
    tl.BackgroundTransparency=1; tl.Text=title; tl.TextColor3=T.white; tl.Font=Enum.Font.GothamBold; tl.TextSize=13; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=601
    local sl=Instance.new("TextLabel",notif); sl.Size=UDim2.new(1,-28,0,14); sl.Position=UDim2.new(0,20,0,34)
    sl.BackgroundTransparency=1; sl.Text=subtitle or ""; sl.TextColor3=T.textSub; sl.Font=Enum.Font.Gotham; sl.TextSize=10; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=601
    TweenService:Create(notif,TweenInfo.new(0.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-145,0,12)}):Play()
    task.delay(4.5,function()
        if notif and notif.Parent then
            TweenService:Create(notif,TweenInfo.new(0.28,Enum.EasingStyle.Quint),{Position=UDim2.new(0.5,-145,0,-72)}):Play()
            task.wait(0.32); pcall(function() notif:Destroy() end)
        end
    end)
end

-- INFO PAGE
local infoSF=mkScrollPage(sideData["Info"].page)
mkSection(infoSF,"Boss Countdown",1)
local irBtn=Instance.new("TextButton",infoSF); irBtn.Size=UDim2.new(1,0,0,30); irBtn.BackgroundColor3=Color3.fromRGB(20,18,34)
irBtn.Text="Refresh Timer"; irBtn.TextColor3=T.textSub; irBtn.Font=Enum.Font.GothamBold; irBtn.TextSize=11; irBtn.BorderSizePixel=0; irBtn.LayoutOrder=2; irBtn.ZIndex=6
Instance.new("UICorner",irBtn).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",irBtn).Color=T.borderBright
local timerContainer=Instance.new("Frame",infoSF); timerContainer.BackgroundTransparency=1; timerContainer.Size=UDim2.new(1,0,0,0)
timerContainer.AutomaticSize=Enum.AutomaticSize.Y; timerContainer.BorderSizePixel=0; timerContainer.LayoutOrder=3
local tcL=Instance.new("UIListLayout",timerContainer); tcL.Padding=UDim.new(0,5); tcL.SortOrder=Enum.SortOrder.LayoutOrder
local timerEntries={}
local function buildTimerCards()
    for _,c in ipairs(timerContainer:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    timerEntries={}; local found=0
    for _,child in ipairs(workspace:GetChildren()) do
        local bossName=child.Name:match("^TimedBossSpawn_(.+)_Container$")
        if bossName then
            found=found+1; local timerLbl=findTimerTextLabel(child)
            local card=Instance.new("Frame",timerContainer); card.Size=UDim2.new(1,0,0,50); card.BackgroundColor3=Color3.fromRGB(14,13,22)
            card.BorderSizePixel=0; card.LayoutOrder=found; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
            local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.25; cs.Thickness=0.8
            local abar=Instance.new("Frame",card); abar.Size=UDim2.new(0,3,1,-14); abar.Position=UDim2.new(0,8,0,7)
            abar.BackgroundColor3=T.accentDim; abar.BorderSizePixel=0; Instance.new("UICorner",abar).CornerRadius=UDim.new(1,0)
            local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(0.55,0,0,20); nameL.Position=UDim2.new(0,18,0,7)
            nameL.BackgroundTransparency=1; nameL.Text=bossName; nameL.TextColor3=T.text; nameL.Font=Enum.Font.GothamBold; nameL.TextSize=12; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
            local dispTimer=Instance.new("TextLabel",card); dispTimer.Size=UDim2.new(0.45,-18,0,20); dispTimer.Position=UDim2.new(0.55,0,0,7)
            dispTimer.BackgroundTransparency=1; dispTimer.Text=timerLbl and timerLbl.Text or "..."; dispTimer.TextColor3=T.accentGlow
            dispTimer.Font=Enum.Font.GothamBold; dispTimer.TextSize=13; dispTimer.TextXAlignment=Enum.TextXAlignment.Right; dispTimer.ZIndex=6
            local dispStatus=Instance.new("TextLabel",card); dispStatus.Size=UDim2.new(1,-24,0,12); dispStatus.Position=UDim2.new(0,18,0,30)
            dispStatus.BackgroundTransparency=1; dispStatus.Text=timerLbl and "Timer aktif" or "Belum ditemukan"
            dispStatus.TextColor3=timerLbl and T.textDim or T.amber; dispStatus.Font=Enum.Font.Gotham; dispStatus.TextSize=9; dispStatus.TextXAlignment=Enum.TextXAlignment.Left; dispStatus.ZIndex=6
            table.insert(timerEntries,{container=child,bossName=bossName,timerLbl=timerLbl,dispTimer=dispTimer,dispStatus=dispStatus,cardStroke=cs,accentBar=abar,prevSecs=-1})
        end
    end
    if found==0 then
        local el=Instance.new("TextLabel",timerContainer); el.Size=UDim2.new(1,0,0,30); el.BackgroundTransparency=1
        el.Text="Tidak ada TimedBossSpawn di workspace"; el.TextColor3=T.textDim; el.Font=Enum.Font.Gotham; el.TextSize=10; el.LayoutOrder=1
    end
end
buildTimerCards()
irBtn.MouseButton1Click:Connect(function() ripple(irBtn,irBtn.AbsoluteSize.X*0.5,irBtn.AbsoluteSize.Y*0.5,T.accent); buildTimerCards() end)
task.spawn(function()
    while infoSF and infoSF.Parent do
        for _,e in ipairs(timerEntries) do pcall(function()
            if not e.timerLbl or not e.timerLbl.Parent then
                local f=findTimerTextLabel(e.container)
                if f then e.timerLbl=f; e.dispStatus.Text="Timer OK"; e.dispStatus.TextColor3=T.green
                else e.dispTimer.Text="?"; e.dispStatus.Text="Belum ada timer"; e.dispStatus.TextColor3=T.amber; return end
            end
            local txt=e.timerLbl.Text or ""; e.dispTimer.Text=(txt~="" and txt or "?")
            local secs=parseTimerSecs(txt)
            if secs==0 and e.prevSecs>0 then showNotif(e.bossName.." spawned!","Boss telah muncul!",T.green) end
            e.prevSecs=secs
            if secs<0 then e.dispTimer.TextColor3=T.textDim; e.dispStatus.Text="Format: "..txt; smooth(e.cardStroke,{Color=T.border},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.textDim},0.3):Play()
            elseif secs==0 then e.dispTimer.TextColor3=T.green; e.dispStatus.Text="Spawn sekarang!"; smooth(e.cardStroke,{Color=T.green},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.green},0.3):Play()
            elseif secs<60 then e.dispTimer.TextColor3=T.amber; e.dispStatus.Text="Segera spawn!"; smooth(e.cardStroke,{Color=T.amber},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.amber},0.3):Play()
            else e.dispTimer.TextColor3=T.accentGlow; e.dispStatus.Text="Menunggu..."; smooth(e.cardStroke,{Color=T.border},0.3):Play(); smooth(e.accentBar,{BackgroundColor3=T.accentDim},0.3):Play() end
        end) end
        task.wait(1)
    end
end)

-- MAIN PAGE
local mainPage=sideData["Main"].page
local mainInner=Instance.new("Frame",mainPage); mainInner.Size=UDim2.new(1,-8,1,-8); mainInner.Position=UDim2.new(0,4,0,4)
mainInner.BackgroundTransparency=1; mainInner.ZIndex=3
local subPages=mkSubTabBar(mainInner,{"Farm","TP","Boss","Dungeon"})

-- FARM
local leftF,rightF=mkTwoColLayout(subPages["Farm"],T.border)
local farmGroup=mkGroupBox(leftF,1); mkSectionLabel(farmGroup,"Pulau & Mode",1)
local _,getIsland=mkDropdownV2(farmGroup,"Pulau","*",Color3.fromRGB(78,46,200),FARM_ISLANDS,"Starter Island",nil,2)
local _,getFarmMode=mkDropdownV2(farmGroup,"Mode","o",Color3.fromRGB(50,130,200),{"V1 - Semua Titik","V2 - Titik Tengah"},"V1 - Semua Titik",nil,3)
local farmOnOffBtn,setFarmOnOff,getFarmOn,setFarmCallback=mkOnOffBtn(farmGroup,"Auto Farm + Quest",4)
local _,_,getAutoHitOn=mkToggle(farmGroup,"Kill Aura",false,nil,5)
local modeGroup=mkGroupBox(leftF,2); mkSectionLabel(modeGroup,"Testing Mode",1)
local _,_,getFaceDown=mkToggle(modeGroup,"Face Down",false,nil,2)
local _,_,getSpinOn=mkToggle(modeGroup,"Auto Spin HRP",false,nil,3)
local skillGroup=mkGroupBox(leftF,3); mkSectionLabel(skillGroup,"Auto Skill",1)
local skillOn={Z=false,X=false,C=false,V=false}
mkToggle(skillGroup,"Z",false,function(v) skillOn.Z=v end,2)
mkToggle(skillGroup,"X",false,function(v) skillOn.X=v end,3)
mkToggle(skillGroup,"C",false,function(v) skillOn.C=v end,4)
mkToggle(skillGroup,"V",false,function(v) skillOn.V=v end,5)
mkSection(rightF,"Adjust",1)
local _,setHeight,getHeight=mkSlider(rightF,"Height",0,50,0," st",nil,2)
local _,setSpeed,getSpeed=mkSlider(rightF,"Speed",20,500,150," st/s",nil,3)
local _,setTD,getTD=mkSlider(rightF,"Jeda",1,10,1,"s",nil,4)
local _,setLD,getLD=mkSlider(rightF,"Loop Delay",0,10,3,"s",nil,5)

-- TP
local tpLeftF,tpRightF=mkTwoColLayout(subPages["TP"],T.border)
local tpStatCard=Instance.new("Frame",tpLeftF); tpStatCard.Size=UDim2.new(1,0,0,24); tpStatCard.BackgroundTransparency=1; tpStatCard.BorderSizePixel=0; tpStatCard.LayoutOrder=0
local tpStatLbl=Instance.new("TextLabel",tpStatCard); tpStatLbl.Size=UDim2.new(1,0,1,0); tpStatLbl.BackgroundTransparency=1
tpStatLbl.Text="Pilih lokasi"; tpStatLbl.TextColor3=T.textDim; tpStatLbl.Font=Enum.Font.Gotham; tpStatLbl.TextSize=10; tpStatLbl.TextXAlignment=Enum.TextXAlignment.Center
local tpStatR=Instance.new("Frame",tpRightF); tpStatR.Size=UDim2.new(1,0,0,24); tpStatR.BackgroundTransparency=1; tpStatR.BorderSizePixel=0; tpStatR.LayoutOrder=0
local function setTPStat(txt,col) tpStatLbl.Text=txt or "--"; if col then smooth(tpStatLbl,{TextColor3=col},0.15):Play() end end
local function makeTpCard(parent,loc,order)
    local card=Instance.new("Frame",parent); card.Size=UDim2.new(1,0,0,40); card.BackgroundColor3=T.card
    card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,9)
    local cs=Instance.new("UIStroke",card); cs.Color=T.border; cs.Transparency=0.5; cs.Thickness=0.8
    local ibar=Instance.new("Frame",card); ibar.Size=UDim2.new(0,2,0,20); ibar.Position=UDim2.new(0,6,0.5,0)
    ibar.AnchorPoint=Vector2.new(0,0.5); ibar.BackgroundColor3=T.textDim; ibar.BorderSizePixel=0; Instance.new("UICorner",ibar).CornerRadius=UDim.new(1,0)
    local nameLbl=Instance.new("TextLabel",card); nameLbl.Size=UDim2.new(1,-54,1,0); nameLbl.Position=UDim2.new(0,14,0,0)
    nameLbl.BackgroundTransparency=1; nameLbl.Text=loc; nameLbl.TextColor3=T.text; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=11; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=6
    local goBtn=Instance.new("TextButton",card); goBtn.Size=UDim2.new(0,36,0,22); goBtn.Position=UDim2.new(1,-40,0.5,0)
    goBtn.AnchorPoint=Vector2.new(0,0.5); goBtn.BackgroundColor3=Color3.fromRGB(35,155,110); goBtn.Text="GO"; goBtn.TextColor3=T.white
    goBtn.Font=Enum.Font.GothamBold; goBtn.TextSize=10; goBtn.BorderSizePixel=0; goBtn.ZIndex=7; Instance.new("UICorner",goBtn).CornerRadius=UDim.new(0,6)
    Instance.new("UIGradient",goBtn).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(50,188,135)),ColorSequenceKeypoint.new(1,Color3.fromRGB(28,138,92))}
    card.MouseEnter:Connect(function() smooth(card,{BackgroundColor3=T.cardHover},0.1):Play(); smooth(cs,{Color=T.accentGlow,Transparency=0.15},0.1):Play(); smooth(ibar,{BackgroundColor3=T.accentGlow},0.1):Play() end)
    card.MouseLeave:Connect(function() smooth(card,{BackgroundColor3=T.card},0.1):Play(); smooth(cs,{Color=T.border,Transparency=0.5},0.1):Play(); smooth(ibar,{BackgroundColor3=T.textDim},0.1):Play() end)
    goBtn.MouseButton1Down:Connect(function() smooth(goBtn,{Size=UDim2.new(0,32,0,18)},0.07):Play() end)
    goBtn.MouseButton1Up:Connect(function() smooth(goBtn,{Size=UDim2.new(0,36,0,22)},0.12):Play() end)
    goBtn.MouseLeave:Connect(function() smooth(goBtn,{Size=UDim2.new(0,36,0,22)},0.12):Play() end)
    local ci=loc
    goBtn.MouseButton1Click:Connect(function()
        ripple(goBtn,goBtn.AbsoluteSize.X*0.5,goBtn.AbsoluteSize.Y*0.5,T.white); setTPStat("Teleporting to "..ci,T.amber)
        pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(ci) end)
        task.delay(1.5,function() setTPStat("Arrived: "..ci,T.green) end)
    end)
    return card
end
for i=1,8  do makeTpCard(tpLeftF,TELEPORT_LOCATIONS[i],i)   end
for i=9,16 do makeTpCard(tpRightF,TELEPORT_LOCATIONS[i],i-8) end

-- BOSS
local bossLeftF,bossRightF=mkTwoColLayout(subPages["Boss"],T.border)
local bossCtrlGroup=mkGroupBox(bossLeftF,1); mkSectionLabel(bossCtrlGroup,"Control",1)
local _,setBossStatFn=mkStatus(bossCtrlGroup,"Status","Idle",2)
local _,setBossPhaseFn=mkStatus(bossCtrlGroup,"Phase","--",3)
local bossOnOffBtn,setBossOnOff,getBossOn,setBossCallback=mkOnOffBtn(bossCtrlGroup,"Auto Kill Boss",4)
local bossPickGroup=mkGroupBox(bossRightF,1); mkSectionLabel(bossPickGroup,"Pilih Boss",1)
local bossSelCard=Instance.new("Frame",bossPickGroup); bossSelCard.Size=UDim2.new(1,0,0,22); bossSelCard.BackgroundTransparency=1; bossSelCard.BorderSizePixel=0; bossSelCard.LayoutOrder=2
local bossSelLbl=Instance.new("TextLabel",bossSelCard); bossSelLbl.Size=UDim2.new(1,0,1,0); bossSelLbl.BackgroundTransparency=1
bossSelLbl.Text="Belum dipilih"; bossSelLbl.TextColor3=T.textDim; bossSelLbl.Font=Enum.Font.GothamBold; bossSelLbl.TextSize=10; bossSelLbl.TextXAlignment=Enum.TextXAlignment.Center
local selectedBoss=nil; local bossCards={}
local rebuildBossCards
rebuildBossCards=function()
    for _,c in ipairs(bossCards) do pcall(function() c:Destroy() end) end; bossCards={}
    local order=3
    for idx,bossName in ipairs(KNOWN_BOSSES) do
        local isSel=(selectedBoss==bossName)
        local card=Instance.new("Frame",bossPickGroup); card.Size=UDim2.new(1,0,0,34)
        card.BackgroundColor3=isSel and Color3.fromRGB(28,18,52) or Color3.fromRGB(14,13,22)
        card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
        local cs=Instance.new("UIStroke",card); cs.Color=isSel and T.accentGlow or T.border; cs.Transparency=isSel and 0.05 or 0.5; cs.Thickness=isSel and 1.4 or 0.8
        local lbar=Instance.new("Frame",card); lbar.Size=UDim2.new(0,2,0,16); lbar.Position=UDim2.new(0,6,0.5,0)
        lbar.AnchorPoint=Vector2.new(0,0.5); lbar.BackgroundColor3=isSel and T.accentGlow or T.textDim; lbar.BorderSizePixel=0; Instance.new("UICorner",lbar).CornerRadius=UDim.new(1,0)
        local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(1,-52,1,0); nameL.Position=UDim2.new(0,14,0,0)
        nameL.BackgroundTransparency=1; nameL.Text=bossName; nameL.TextColor3=isSel and T.white or T.textSub
        nameL.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham; nameL.TextSize=10; nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=6
        local selBtn=Instance.new("TextButton",card); selBtn.Size=UDim2.new(0,40,0,20); selBtn.Position=UDim2.new(1,-44,0.5,0)
        selBtn.AnchorPoint=Vector2.new(0,0.5); selBtn.BackgroundColor3=isSel and T.accentSoft or Color3.fromRGB(22,20,36)
        selBtn.Text=isSel and "ON" or "Set"; selBtn.TextColor3=T.white; selBtn.Font=Enum.Font.GothamBold; selBtn.TextSize=9; selBtn.BorderSizePixel=0; selBtn.ZIndex=7
        Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,5)
        local ci=bossName
        selBtn.MouseButton1Click:Connect(function()
            selectedBoss=ci; bossSelLbl.Text="Target: "..ci; smooth(bossSelLbl,{TextColor3=T.accentGlow},0.2):Play()
            ripple(selBtn,selBtn.AbsoluteSize.X*0.5,selBtn.AbsoluteSize.Y*0.5,T.accent); rebuildBossCards()
        end)
        table.insert(bossCards,card); order=order+1
    end
end
rebuildBossCards()
task.spawn(function()
    while bossPickGroup and bossPickGroup.Parent do task.wait(3); if bossPickGroup and bossPickGroup.Parent then rebuildBossCards() end end
end)

-- DUNGEON
local dungeonSF=mkScrollPage(subPages["Dungeon"])
local dStatCard=Instance.new("Frame",dungeonSF); dStatCard.Size=UDim2.new(1,0,0,18); dStatCard.BackgroundTransparency=1; dStatCard.LayoutOrder=1; dStatCard.BorderSizePixel=0
local dungeonStatLbl=Instance.new("TextLabel",dStatCard); dungeonStatLbl.Size=UDim2.new(1,0,1,0); dungeonStatLbl.BackgroundTransparency=1
dungeonStatLbl.Text="Idle"; dungeonStatLbl.TextColor3=T.textDim; dungeonStatLbl.Font=Enum.Font.Gotham; dungeonStatLbl.TextSize=10; dungeonStatLbl.TextXAlignment=Enum.TextXAlignment.Center
local dNPCCard=Instance.new("Frame",dungeonSF); dNPCCard.Size=UDim2.new(1,0,0,14); dNPCCard.BackgroundTransparency=1; dNPCCard.LayoutOrder=2; dNPCCard.BorderSizePixel=0
local dungeonNPCLbl=Instance.new("TextLabel",dNPCCard); dungeonNPCLbl.Size=UDim2.new(1,0,1,0); dungeonNPCLbl.BackgroundTransparency=1
dungeonNPCLbl.Text="NPC: --"; dungeonNPCLbl.TextColor3=T.textDim; dungeonNPCLbl.Font=Enum.Font.Gotham; dungeonNPCLbl.TextSize=9; dungeonNPCLbl.TextXAlignment=Enum.TextXAlignment.Center
local dHitCard=Instance.new("Frame",dungeonSF); dHitCard.Size=UDim2.new(1,0,0,14); dHitCard.BackgroundTransparency=1; dHitCard.LayoutOrder=3; dHitCard.BorderSizePixel=0
local dungeonHitLbl=Instance.new("TextLabel",dHitCard); dungeonHitLbl.Size=UDim2.new(1,0,1,0); dungeonHitLbl.BackgroundTransparency=1
dungeonHitLbl.Text="0/s"; dungeonHitLbl.TextColor3=T.textDim; dungeonHitLbl.Font=Enum.Font.Gotham; dungeonHitLbl.TextSize=9; dungeonHitLbl.TextXAlignment=Enum.TextXAlignment.Center
local function setDungeonStat(txt,col) dungeonStatLbl.Text=txt or "Idle"; if col then smooth(dungeonStatLbl,{TextColor3=col},0.15):Play() end end
local function setDungeonNPC(txt,col)  dungeonNPCLbl.Text="NPC: "..(txt or "--"); if col then smooth(dungeonNPCLbl,{TextColor3=col},0.15):Play() end end
local function setDungeonHit(txt,col)  dungeonHitLbl.Text=txt or "0/s"; if col then smooth(dungeonHitLbl,{TextColor3=col},0.15):Play() end end
local dungeonOnOffBtn,setDungeonOnOff,getDungeonOn,setDungeonCallback=mkOnOffBtn(dungeonSF,"Auto Dungeon",4)

-- SETTINGS
local settingsSF=mkScrollPage(sideData["Settings"].page)
mkSection(settingsSF,"Appearance",1)
local baseW=root.AbsoluteSize.X; local baseH=root.AbsoluteSize.Y
mkSlider(settingsSF,"UI Scale",70,130,100,"%",function(v) root.Size=UDim2.new(0,baseW*(v/100),0,baseH*(v/100)) end,2)
mkSlider(settingsSF,"Border Opacity",0,100,90,"%",function(v) rootStroke.Transparency=1-(v/100) end,3)
mkSlider(settingsSF,"Corner Radius",6,24,14,"px",function(v) rootCorner.CornerRadius=UDim.new(0,v) end,4)
mkSection(settingsSF,"Font",5)
mkSlider(settingsSF,"Font Size",8,18,12,"px",function(v) applyFontSize(v) end,6)
mkSection(settingsSF,"Accent Color",7)
mkDropdownV2(settingsSF,"Accent","*",Color3.fromRGB(118,68,255),{"Purple","Blue","Cyan","Green","Red"},"Purple",function(v) applyAccent(v) end,8)
mkSection(settingsSF,"Particles",9)
mkToggle(settingsSF,"Enable Particles",true,function(v) UISettings.particles=v; for _,p in ipairs(particleList) do if p and p.Parent then p.Visible=v end end end,10)
mkSlider(settingsSF,"Jumlah Partikel",5,80,26,"",function(v) UISettings.particleCount=v; spawnParticles(v) end,11)
mkSection(settingsSF,"UI Background",12)
mkDropdownV2(settingsSF,"Mode BG Window","o",Color3.fromRGB(80,80,180),{"Solid","Transparent","Blur"},"Solid",function(v) applyUIBgMode(v) end,13)
mkSection(settingsSF,"Minimize Bar",14)
mkDropdownV2(settingsSF,"Mode BG Minimize","o",Color3.fromRGB(60,120,200),{"Solid","Transparent","Blur"},"Solid",function(v) applyMiniBgMode(v) end,15)
mkSection(settingsSF,"Effects",16)
mkToggle(settingsSF,"Window Glow",true,function(v) UISettings.glow=v; smooth(rootGlow,{ImageTransparency=v and 0.85 or 1},0.3):Play() end,17)

-- refs table
local refs={
    getIsland=getIsland, getFarmMode=getFarmMode,
    getHeight=getHeight, getSpeed=getSpeed, getTD=getTD, getLD=getLD,
    setFarmOnOff=setFarmOnOff, getFarmOn=getFarmOn, setFarmCallback=setFarmCallback,
    getAutoHitOn=function() return getAutoHitOn() end,
    getFaceDown=function() return getFaceDown() end,
    getSpinOn=function() return getSpinOn() end,
    getSkillOn=function(k) return skillOn[k] end,
    setFarmStat=function() end, setFarmPhase=function() end, setFarmNPC=function() end,
    getSelectedBoss=function() return selectedBoss end,
    setBossStat=setBossStatFn, setBossPhase=setBossPhaseFn, setBossTarget=function() end,
    setBossOnOff=setBossOnOff, getBossOn=getBossOn, setBossCallback=setBossCallback,
    setDungeonStat=setDungeonStat, setDungeonNPC=setDungeonNPC, setDungeonHit=setDungeonHit,
    setDungeonOnOff=setDungeonOnOff, getDungeonOn=getDungeonOn, setDungeonCallback=setDungeonCallback,
}

-- ╔══════════════════════════════════╗
-- ║         LOGIC LAYER              ║
-- ╚══════════════════════════════════╝
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player2           = game:GetService("Players").LocalPlayer

local ISLANDS={
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
    ["Starter Island"]="Starter",["Jungle Island"]="Jungle",["Desert Island"]="Desert",["Snow Island"]="Snow",
    ["Shibuya"]="Shibuya",["Hollow"]="HollowIsland",["Shinjuku Island#1"]="Shinjuku",["Shinjuku Island#2"]="Shinjuku",
    ["Slime"]="Slime",["Academy"]="Academy",["Judgement"]="Judgement",["Soul Dominion"]="Dungeon",["Ninja"]="Ninja",["Lawless"]="Lawless",
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
    if not bossName then return nil end; local lower=bossName:lower()
    for _,e in ipairs(BOSS_DATA) do
        for _,kw in ipairs(e.keys) do if lower:find(kw,1,true) then return e end end
        if e.npc and e.npc:lower()==lower then return e end
    end; return nil
end
local function fireTPRemote(loc) pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(loc) end) end

local function getHealth(obj)
    if not obj or not obj.Parent then return 0 end
    local model=obj:IsA("Model") and obj or obj.Parent; if not model then return 0 end
    local hum=model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildWhichIsA("Humanoid",true)
    if hum then return hum.Health end; return -1
end
local function isAlive(obj) local hp=getHealth(obj); return hp~=0 end

local character2=player2.Character or player2.CharacterAdded:Wait()
local function getRoot()
    character2=player2.Character; if not character2 then return nil end
    return character2:FindFirstChild("HumanoidRootPart")
end
local function fireSettings(k,v) pcall(function() ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SettingsToggle"):FireServer(k,v) end) end
local function enableGS() fireSettings("EnableQuestRepeat",true); fireSettings("AutoQuestRepeat",true); fireSettings("DisablePVP",true) end
local function disableGS() fireSettings("EnableQuestRepeat",false); fireSettings("AutoQuestRepeat",false); fireSettings("DisablePVP",false) end

local hitRemote=nil
local function getHitRemote()
    if hitRemote and hitRemote.Parent then return hitRemote end
    local ok,r=pcall(function() return ReplicatedStorage:WaitForChild("CombatSystem",5):WaitForChild("Remotes",5):WaitForChild("RequestHit",5) end)
    if ok and r then hitRemote=r end; return hitRemote
end
local abilityRemote=nil
local function getAbilityRemote()
    if abilityRemote and abilityRemote.Parent then return abilityRemote end
    local paths={{"AbilitySystem","Remotes","RequestAbility"},{"Remotes","RequestAbility"}}
    for _,path in ipairs(paths) do
        local ok,r=pcall(function() local n=ReplicatedStorage; for _,s in ipairs(path) do n=n:WaitForChild(s,2) end; return n end)
        if ok and r then abilityRemote=r; return abilityRemote end
    end
    local f=ReplicatedStorage:FindFirstChild("RequestAbility",true); if f then abilityRemote=f end; return abilityRemote
end
local function fireHitAt(vec3)
    if not vec3 then return end; local remote=getHitRemote(); if not remote then return end
    pcall(function() remote:FireServer(vector.create(vec3.X,vec3.Y,vec3.Z)) end)
end
local function getNearestNPCPosition()
    local r=getRoot(); if not r then return nil end
    local folder=workspace:FindFirstChild("NPCs"); if not folder then return nil end
    local best,bestDist=nil,math.huge
    for _,npc in ipairs(folder:GetChildren()) do
        local part=(npc:IsA("BasePart") and npc) or (npc:IsA("Model") and (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart",true)))
        if part and isAlive(npc) then local d=(r.Position-part.Position).Magnitude; if d<bestDist then bestDist=d; best=part end end
    end; return best and best.Position or nil
end
local function getNearestNPCModel()
    local r=getRoot(); if not r then return nil end
    local folder=workspace:FindFirstChild("NPCs"); if not folder then return nil end
    local best,bestDist=nil,math.huge
    for _,npc in ipairs(folder:GetChildren()) do
        local part=(npc:IsA("BasePart") and npc) or (npc:IsA("Model") and (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart",true)))
        if part and isAlive(npc) then local d=(r.Position-part.Position).Magnitude; if d<bestDist then bestDist=d; best=npc end end
    end; return best
end

local flyBP,flyBG=nil,nil
task.spawn(function()
    while true do
        if refs and refs.getSpinOn and refs.getSpinOn() then
            local r=getRoot()
            if r then
                for i=1,20 do
                    if not (refs.getSpinOn and refs.getSpinOn()) then break end
                    local rr=getRoot(); if not rr then break end
                    local xTilt=(refs.getFaceDown and refs.getFaceDown()) and (math.pi/2) or 0
                    local angle=(i/20)*math.pi*2; local newCF=CFrame.new(rr.Position)*CFrame.fromEulerAnglesXYZ(xTilt,angle,0)
                    rr.CFrame=newCF; if flyBP then flyBP.Position=rr.Position end; if flyBG then flyBG.CFrame=newCF end; task.wait(0.003)
                end
            else task.wait(0.1) end
        else task.wait(0.3) end
    end
end)
task.spawn(function()
    while true do
        if _G.islandFarmOn and refs and refs.getFaceDown and refs.getFaceDown() then
            local r=getRoot(); if r and flyBG then flyBG.CFrame=CFrame.new(r.Position)*CFrame.fromEulerAnglesXYZ(math.pi/2,0,0) end
        end; task.wait(0.05)
    end
end)
local function enableFly()
    character2=player2.Character; if not character2 then return end
    local r=character2:FindFirstChild("HumanoidRootPart"); local h=character2:FindFirstChildOfClass("Humanoid")
    if not r or not h then return end; h.PlatformStand=true
    if flyBP then flyBP:Destroy() end; if flyBG then flyBG:Destroy() end
    flyBP=Instance.new("BodyPosition"); flyBP.MaxForce=Vector3.new(1e5,1e5,1e5); flyBP.D=500; flyBP.P=5000; flyBP.Position=r.Position; flyBP.Parent=r
    flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); flyBG.D=400; flyBG.CFrame=r.CFrame; flyBG.Parent=r
end
local function disableFly()
    if flyBP then flyBP:Destroy(); flyBP=nil end; if flyBG then flyBG:Destroy(); flyBG=nil end
    character2=player2.Character; if not character2 then return end
    local h=character2:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end
end
player2.CharacterAdded:Connect(function(nc) character2=nc; if _G.islandFarmOn then task.wait(1); enableFly() end end)

local function moveTo(targetPos,speed)
    local r=getRoot(); if not r then return end; local dist=(r.Position-targetPos).Magnitude
    if dist>80 then
        local dur=math.max(0.3,dist/(speed or 150)); if flyBP then flyBP.Position=targetPos end
        local tw=TweenService:Create(r,TweenInfo.new(dur,Enum.EasingStyle.Linear),{CFrame=CFrame.new(targetPos)}); tw:Play(); tw.Completed:Wait()
    else r.CFrame=CFrame.new(targetPos); if flyBP then flyBP.Position=targetPos end end
end

local currentFarmVec=nil; local farmHitRunning=false
local function startFarmHitSpam()
    if farmHitRunning then return end; farmHitRunning=true
    task.spawn(function()
        while farmHitRunning do
            if currentFarmVec then
                local folder=workspace:FindFirstChild("NPCs"); local targetVec=currentFarmVec
                if folder then
                    local best,bestDist=nil,math.huge
                    for _,npc in ipairs(folder:GetChildren()) do
                        local part=(npc:IsA("BasePart") and npc) or (npc:IsA("Model") and (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart",true)))
                        if part and isAlive(npc) then local d=(currentFarmVec-part.Position).Magnitude; if d<80 and d<bestDist then bestDist=d; best=part end end
                    end; if best then targetVec=best.Position end
                end; fireHitAt(targetVec)
            end; task.wait()
        end
    end)
end
local function stopFarmHitSpam() farmHitRunning=false; currentFarmVec=nil end
local npcHitRunning=false
local function startNearestHitSpam()
    if npcHitRunning then return end; npcHitRunning=true
    task.spawn(function() while npcHitRunning do local pos=getNearestNPCPosition(); if pos then fireHitAt(pos) end; task.wait() end end)
end
local function stopNearestHitSpam() npcHitRunning=false end
local function startAbilityLoop(checkFn)
    task.spawn(function()
        local remote=getAbilityRemote()
        while checkFn() do
            if remote then for _,arg in ipairs({1,2,3}) do if not checkFn() then break end; pcall(function() remote:FireServer(arg) end) end end; task.wait(0.5)
        end
    end)
end
task.spawn(function()
    local defs={{key="Z",arg=1},{key="X",arg=2},{key="C",arg=3},{key="V",arg=4}}
    while true do
        if refs and refs.getSkillOn then
            local remote=getAbilityRemote()
            if remote then for _,s in ipairs(defs) do if refs.getSkillOn(s.key) then pcall(function() remote:FireServer(s.arg) end) end end end
        end; task.wait()
    end
end)
local lastQuestNPC=nil
local function fireQuestAccept(name) pcall(function() ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept"):FireServer(name) end) end
local function tryAutoQuest()
    local r=getRoot(); if not r then return end; local svc=workspace:FindFirstChild("ServiceNPCs"); if not svc then return end
    for i=1,19 do
        local name="QuestNPC"..i; local npc=svc:FindFirstChild(name)
        if npc then
            local pos
            if npc:IsA("Model") then local pp=npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart"); if pp then pos=pp.Position end
            elseif npc:IsA("BasePart") then pos=npc.Position end
            if pos and (r.Position-pos).Magnitude<=100 then
                if name~=lastQuestNPC then fireQuestAccept(name); fireSettings("EnableQuestRepeat",true); fireSettings("AutoQuestRepeat",true); lastQuestNPC=name end; return
            end
        end
    end
end
local function tpAndWait(loc,secs) fireTPRemote(loc); task.wait(secs or 3) end
local farmV1On=false; local farmV2On=false; local isRunningV1=false; local isRunningV2=false; _G.islandFarmOn=false
local function farmSetup(island) lastQuestNPC=nil; local tpLoc=ISLAND_TP[island]; enableFly(); if tpLoc then tpAndWait(tpLoc,3) end; enableGS() end
local function farmTeardown() disableFly(); disableGS(); lastQuestNPC=nil; stopFarmHitSpam() end
local function farmLoopV1()
    isRunningV1=true; if not farmV1On then isRunningV1=false; refs.setFarmOnOff(false); return end
    _G.islandFarmOn=true; local island=refs.getIsland(); farmSetup(island)
    if refs.getAutoHitOn and refs.getAutoHitOn() then startFarmHitSpam() end
    startAbilityLoop(function() return farmV1On end)
    while farmV1On do
        island=refs.getIsland(); local data=ISLANDS[island]; if not data then task.wait(1); continue end
        for i,pos in ipairs(data.coords) do
            if not farmV1On then break end
            local fp=Vector3.new(pos.X,pos.Y+refs.getHeight(),pos.Z); currentFarmVec=fp
            moveTo(fp,refs.getSpeed()); tryAutoQuest(); task.wait(refs.getTD())
        end
        if not farmV1On then break end; local ld=refs.getLD()
        if ld>0 then local endT=tick()+ld; while tick()<endT and farmV1On do tryAutoQuest(); task.wait(0.5) end end
    end
    farmTeardown(); _G.islandFarmOn=false; isRunningV1=false; refs.setFarmOnOff(false)
end
local function farmLoopV2()
    isRunningV2=true; if not farmV2On then isRunningV2=false; refs.setFarmOnOff(false); return end
    _G.islandFarmOn=true; local island=refs.getIsland(); farmSetup(island)
    if refs.getAutoHitOn and refs.getAutoHitOn() then startFarmHitSpam() end
    startAbilityLoop(function() return farmV2On end)
    while farmV2On do
        island=refs.getIsland(); local data=ISLANDS[island]; if not data then task.wait(1); continue end
        local ci=data.center; local cpos=data.coords[ci]; local fp=Vector3.new(cpos.X,cpos.Y+refs.getHeight(),cpos.Z)
        currentFarmVec=fp; moveTo(fp,refs.getSpeed()); tryAutoQuest()
        local ld=refs.getLD()
        if ld>0 then local endT=tick()+ld; while tick()<endT and farmV2On do tryAutoQuest(); task.wait(0.5) end else task.wait(0.5) end
    end
    farmTeardown(); _G.islandFarmOn=false; isRunningV2=false; refs.setFarmOnOff(false)
end
task.spawn(function()
    local wasV1,wasV2=false,false
    while task.wait(0.2) do
        if farmV1On and not wasV1 then farmV2On=false; if not isRunningV1 then task.spawn(farmLoopV1) end
        elseif not farmV1On and wasV1 then disableFly(); disableGS() end
        if farmV2On and not wasV2 then farmV1On=false; if not isRunningV2 then task.spawn(farmLoopV2) end
        elseif not farmV2On and wasV2 then disableFly(); disableGS() end
        wasV1=farmV1On; wasV2=farmV2On
    end
end)
task.spawn(function()
    while true do
        task.wait(0.2); local hitOn=refs and refs.getAutoHitOn and refs.getAutoHitOn()
        if hitOn and not _G.islandFarmOn then if not npcHitRunning then startNearestHitSpam() end
        else if npcHitRunning then stopNearestHitSpam() end end
    end
end)

local bossKillOn=false; local bossFlyBP,bossFlyBG=nil,nil
local function enableBossFly()
    local r=getRoot(); local h=character2 and character2:FindFirstChildOfClass("Humanoid"); if not r or not h then return end; h.PlatformStand=true
    if bossFlyBP then bossFlyBP:Destroy() end; if bossFlyBG then bossFlyBG:Destroy() end
    bossFlyBP=Instance.new("BodyPosition"); bossFlyBP.MaxForce=Vector3.new(1e5,1e5,1e5); bossFlyBP.D=600; bossFlyBP.P=6000; bossFlyBP.Position=r.Position; bossFlyBP.Parent=r
    bossFlyBG=Instance.new("BodyGyro"); bossFlyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); bossFlyBG.D=500; bossFlyBG.CFrame=r.CFrame; bossFlyBG.Parent=r
end
local function disableBossFly()
    if bossFlyBP then bossFlyBP:Destroy(); bossFlyBP=nil end; if bossFlyBG then bossFlyBG:Destroy(); bossFlyBG=nil end
    local h=character2 and character2:FindFirstChildOfClass("Humanoid"); if h and not _G.islandFarmOn then h.PlatformStand=false end
end
local function getBossPart(npcName)
    local npcs=workspace:FindFirstChild("NPCs")
    if npcs then local folder=npcs:FindFirstChild(npcName); if folder then if folder:IsA("Model") then return folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart",true) elseif folder:IsA("BasePart") then return folder end end end
    local found=workspace:FindFirstChild(npcName,true); if found then if found:IsA("Model") then return found.PrimaryPart or found:FindFirstChildWhichIsA("BasePart",true) elseif found:IsA("BasePart") then return found end end; return nil
end
local function bossKillLoop()
    local bossName=refs.getSelectedBoss(); if not bossName then refs.setBossStat("Pilih boss dulu!",T.red); refs.setBossOnOff(false); bossKillOn=false; return end
    local data=getBossData(bossName); if not data then refs.setBossStat("Data tidak ditemukan!",T.red); refs.setBossOnOff(false); bossKillOn=false; return end
    local npcName=data.npc; local bossCoord=data.coord; local tpLoc=data.tpLoc
    if tpLoc then
        refs.setBossPhase("Teleporting...",T.amber); refs.setBossStat("TP ke "..tpLoc,T.amber); fireTPRemote(tpLoc)
        for i=3,1,-1 do if not bossKillOn then disableBossFly(); refs.setBossOnOff(false); return end; refs.setBossStat("Loading "..i.."s",T.amber); task.wait(1) end
    end
    if not bossKillOn then disableBossFly(); refs.setBossOnOff(false); return end
    enableBossFly(); refs.setBossPhase("Mendekat...",T.accentGlow)
    local function moveToBoss(targetPos)
        local rr=getRoot(); if not rr then return end; local dist=(rr.Position-targetPos).Magnitude
        if dist>500 then rr.CFrame=CFrame.new(targetPos); if bossFlyBP then bossFlyBP.Position=targetPos end; task.wait(0.3)
        else local speed=refs.getSpeed and refs.getSpeed() or 150; local dur=math.max(0.3,dist/speed)
            if bossFlyBP then bossFlyBP.Position=targetPos end
            local tw=TweenService:Create(rr,TweenInfo.new(dur,Enum.EasingStyle.Linear),{CFrame=CFrame.new(targetPos)}); tw:Play(); tw.Completed:Wait() end
    end
    local r=getRoot(); if r then moveToBoss(bossCoord+Vector3.new(0,5,0)) end; task.wait(0.3)
    local bossHitRun=true
    task.spawn(function()
        while bossHitRun and bossKillOn do
            local bossPart=getBossPart(npcName)
            if bossPart then if not isAlive(bossPart.Parent or bossPart) then bossHitRun=false; break end; fireHitAt(bossPart.Position) end; task.wait()
        end
    end)
    refs.setBossPhase("Menyerang",T.green)
    while bossKillOn do
        local bossPart=getBossPart(npcName)
        if not bossPart then refs.setBossStat(npcName.." selesai!",T.green); refs.setBossPhase("Boss mati",T.green); break end
        if not isAlive(bossPart.Parent or bossPart) then refs.setBossStat(npcName.." health 0!",T.green); refs.setBossPhase("Boss mati",T.green); break end
        local rr=getRoot(); if not rr then task.wait(0.2); continue end
        local bossPos=bossPart.Position; local dist=(rr.Position-bossPos).Magnitude
        local hp=getHealth(bossPart.Parent or bossPart); local hpStr=hp>=0 and (" HP:"..math.floor(hp)) or ""
        refs.setBossStat(npcName.." "..math.floor(dist).."st"..hpStr,T.green)
        local target=bossPos+Vector3.new(0,3,0)
        if dist>500 then rr.CFrame=CFrame.new(target); if bossFlyBP then bossFlyBP.Position=target end
        elseif dist>4 then
            local speed=refs.getSpeed and refs.getSpeed() or 150; local dur=math.max(0.05,dist/speed)
            if bossFlyBP then bossFlyBP.Position=target end
            TweenService:Create(rr,TweenInfo.new(dur,Enum.EasingStyle.Linear),{CFrame=CFrame.new(target)}):Play()
        end; task.wait(0.15)
    end
    bossHitRun=false; disableBossFly(); refs.setBossStat("Idle",T.textDim); refs.setBossPhase("--",T.textDim); refs.setBossOnOff(false); bossKillOn=false
end

local dungeonOn=false; local dungeonHitRun=false; local activeDungeonTween=nil
local function dungeonLoop()
    dungeonHitRun=true
    task.spawn(function()
        local count=0; local lastT=tick()
        while dungeonHitRun do
            local pos=getNearestNPCPosition(); if pos then fireHitAt(pos); count=count+1 end
            if tick()-lastT>=0.5 then refs.setDungeonHit(tostring(count*2).."/s",T.green); count=0; lastT=tick() end; task.wait()
        end; refs.setDungeonHit("0/s",T.textDim)
    end)
    startAbilityLoop(function() return dungeonOn end)
    task.spawn(function()
        while dungeonOn do
            local npc=getNearestNPCModel(); if not npc or not npc.Parent then refs.setDungeonStat("Cari NPC...",T.amber); task.wait(0.5); continue end
            if not isAlive(npc) then refs.setDungeonStat("NPC mati, ganti target",T.amber); task.wait(0.2); continue end
            local part=(npc:IsA("BasePart") and npc) or (npc:IsA("Model") and (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart",true)))
            if not part then task.wait(0.3); continue end
            local r=getRoot(); if not r then task.wait(0.2); continue end
            refs.setDungeonStat("Running",T.green); refs.setDungeonNPC(npc.Name,T.accentGlow)
            local target=part.Position+Vector3.new(0,2,0); local dist=(r.Position-target).Magnitude
            if activeDungeonTween then pcall(function() activeDungeonTween:Cancel() end) end
            activeDungeonTween=TweenService:Create(r,TweenInfo.new(math.max(0.15,dist/100),Enum.EasingStyle.Linear),{CFrame=CFrame.new(target)}); activeDungeonTween:Play()
            local elapsed=0
            while elapsed<1 and dungeonOn and npc and npc.Parent and isAlive(npc) do task.wait(0.1); elapsed=elapsed+0.1 end
            pcall(function() if activeDungeonTween then activeDungeonTween:Cancel(); activeDungeonTween=nil end end)
            if not isAlive(npc) then refs.setDungeonNPC("Mati, ganti...",T.amber) end; task.wait(0.05)
        end; refs.setDungeonStat("Idle",T.textDim); refs.setDungeonNPC("--",T.textDim)
    end)
end

refs.setFarmCallback(function(v)
    local mode=refs.getFarmMode()
    if v then if mode=="V2 - Titik Tengah" then farmV2On=true; farmV1On=false else farmV1On=true; farmV2On=false end
    else farmV1On=false; farmV2On=false; stopFarmHitSpam() end
end)
refs.setBossCallback(function(v)
    bossKillOn=v
    if v then task.spawn(bossKillLoop)
    else bossKillOn=false; disableBossFly(); refs.setBossStat("Idle",T.textDim); refs.setBossPhase("--",T.textDim) end
end)
refs.setDungeonCallback(function(v)
    dungeonOn=v
    if v then task.spawn(dungeonLoop)
    else dungeonOn=false; dungeonHitRun=false
        if activeDungeonTween then pcall(function() activeDungeonTween:Cancel(); activeDungeonTween=nil end) end
        refs.setDungeonStat("Idle",T.textDim); refs.setDungeonNPC("--",T.textDim); refs.setDungeonHit("0/s",T.textDim)
    end
end)

-- ╔══════════════════════════════════╗
-- ║         ENTRANCE & FINISH        ║
-- ╚══════════════════════════════════╝
root.BackgroundTransparency=1; root.Size=UDim2.new(0,WIN_W,0,0); root.Visible=true; task.wait(0.08)
spring(root,{Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0,Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)},0.50):Play()
task.delay(0.1,function() switchMainTab("Info") end)

_G.YiUI=refs
print("[YiDaMuSake] v8.2 COMBINED loaded! Parent: "..gui.Parent.Name)
