-- ╔══════════════════════════════════╗
-- ║  YiDaMuSake — UI Library         ║
-- ╚══════════════════════════════════╝
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Players      = game:GetService("Players")
local player       = Players.LocalPlayer

-- =====================
-- THEME
-- =====================
local T = {
    bg           = Color3.fromRGB(7,  7,  13),
    surface      = Color3.fromRGB(15, 14, 23),
    card         = Color3.fromRGB(20, 18, 32),
    cardHover    = Color3.fromRGB(27, 25, 42),
    border       = Color3.fromRGB(58, 50, 88),
    borderBright = Color3.fromRGB(100, 82, 150),
    accent       = Color3.fromRGB(118, 68, 255),
    accentSoft   = Color3.fromRGB(88,  48, 188),
    accentGlow   = Color3.fromRGB(152, 92, 255),
    accentDim    = Color3.fromRGB(60,  35, 130),
    green        = Color3.fromRGB(42,  198, 108),
    greenDim     = Color3.fromRGB(25,  125, 70),
    red          = Color3.fromRGB(215, 58,  78),
    text         = Color3.fromRGB(230, 226, 248),
    textSub      = Color3.fromRGB(138, 130, 172),
    textDim      = Color3.fromRGB(72,  65,  102),
    white        = Color3.fromRGB(255, 255, 255),
    black        = Color3.fromRGB(10,  10,  16),
    amber        = Color3.fromRGB(255, 180, 40),
}

local ACCENT_PRESETS = {
    Purple = {Color3.fromRGB(118,68,255),  Color3.fromRGB(88,48,188),  Color3.fromRGB(152,92,255)},
    Blue   = {Color3.fromRGB(50,120,255),  Color3.fromRGB(35,88,200),  Color3.fromRGB(80,150,255)},
    Cyan   = {Color3.fromRGB(30,190,220),  Color3.fromRGB(20,145,175), Color3.fromRGB(60,215,240)},
    Green  = {Color3.fromRGB(40,200,100),  Color3.fromRGB(28,150,72),  Color3.fromRGB(65,225,130)},
    Red    = {Color3.fromRGB(220,55,80),   Color3.fromRGB(168,38,58),  Color3.fromRGB(245,80,105)},
}

local UISettings = {
    scale         = 1.0,
    accentPreset  = "Purple",
    cornerRadius  = 16,
    particles     = true,
    particleCount = 26,
    glow          = true,
    fontSize      = 12,
    miniBgMode    = "Solid",
    uiBgMode      = "Solid",
}

-- =====================
-- ACCENT REGISTRY
-- =====================
local accentRegistry = {}
local function regAccent(typ, obj) table.insert(accentRegistry,{t=typ,o=obj}) end

local function applyAccentLive()
    for _,e in ipairs(accentRegistry) do
        pcall(function()
            local o,t=e.o,e.t
            if     t=="bgAccent"  then TweenService:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accent}):Play()
            elseif t=="bgGlow"    then TweenService:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accentGlow}):Play()
            elseif t=="bgSoft"    then TweenService:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accentSoft}):Play()
            elseif t=="stAccent"  then TweenService:Create(o,TweenInfo.new(0.3),{Color=T.accent}):Play()
            elseif t=="stGlow"    then TweenService:Create(o,TweenInfo.new(0.3),{Color=T.accentGlow}):Play()
            elseif t=="imgAccent" then TweenService:Create(o,TweenInfo.new(0.3),{ImageColor3=T.accent}):Play()
            elseif t=="txtGlow"   then TweenService:Create(o,TweenInfo.new(0.3),{TextColor3=T.accentGlow}):Play()
            elseif t=="scrollbar" then o.ScrollBarImageColor3=T.accent
            end
        end)
    end
end

local function applyAccent(preset)
    local p=ACCENT_PRESETS[preset]; if not p then return end
    T.accent=p[1]; T.accentSoft=p[2]; T.accentGlow=p[3]
    UISettings.accentPreset=preset
    applyAccentLive()
end

-- =====================
-- TWEEN HELPERS
-- =====================
local function tw(o,p,t,s,d)
    return TweenService:Create(o,TweenInfo.new(t or 0.22,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p)
end
local function smooth(o,p,t) return tw(o,p,t or 0.22) end
local function spring(o,p,t) return tw(o,p,t or 0.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out) end
local function ease(o,p,t)   return tw(o,p,t or 0.28,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut) end

-- =====================
-- RIPPLE
-- =====================
local function ripple(parent,x,y,col)
    local ok,pos=pcall(function()
        return Vector2.new(x or parent.AbsoluteSize.X/2, y or parent.AbsoluteSize.Y/2)
    end)
    if not ok then return end
    local r=Instance.new("Frame")
    r.Size=UDim2.new(0,0,0,0); r.Position=UDim2.new(0,pos.X,0,pos.Y)
    r.AnchorPoint=Vector2.new(0.5,0.5); r.BackgroundColor3=col or T.white
    r.BackgroundTransparency=0.72; r.BorderSizePixel=0; r.ZIndex=60; r.Parent=parent
    Instance.new("UICorner",r).CornerRadius=UDim.new(1,0)
    local sz=math.max(parent.AbsoluteSize.X,parent.AbsoluteSize.Y)*2.6
    local t1=smooth(r,{Size=UDim2.new(0,sz,0,sz),BackgroundTransparency=0.92},0.46)
    t1:Play()
    t1.Completed:Connect(function()
        smooth(r,{BackgroundTransparency=1},0.16):Play()
        task.wait(0.18); pcall(function() r:Destroy() end)
    end)
end

-- =====================
-- COMPONENT: SCROLL PAGE
-- =====================
local function mkScrollPage(parent)
    local sf=Instance.new("ScrollingFrame",parent)
    sf.Size=UDim2.new(1,-8,1,-8); sf.Position=UDim2.new(0,4,0,4)
    sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=2; sf.ScrollBarImageColor3=T.accent
    sf.ScrollBarImageTransparency=0.4
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.ZIndex=3; sf.ClipsDescendants=true
    regAccent("scrollbar",sf)
    local ul=Instance.new("UIListLayout",sf)
    ul.Padding=UDim.new(0,6); ul.SortOrder=Enum.SortOrder.LayoutOrder
    local pp=Instance.new("UIPadding",sf)
    pp.PaddingTop=UDim.new(0,6); pp.PaddingBottom=UDim.new(0,14)
    pp.PaddingLeft=UDim.new(0,4); pp.PaddingRight=UDim.new(0,4)
    return sf
end

-- =====================
-- COMPONENT: GROUP BOX
-- Status + Dropdown + ON/OFF dalam 1 border
-- =====================
local function mkGroupBox(parent, order)
    local grp=Instance.new("Frame",parent)
    grp.BackgroundColor3=Color3.fromRGB(13,12,22)
    grp.BorderSizePixel=0; grp.LayoutOrder=order or 0
    grp.AutomaticSize=Enum.AutomaticSize.Y
    grp.Size=UDim2.new(1,0,0,0); grp.ClipsDescendants=false
    Instance.new("UICorner",grp).CornerRadius=UDim.new(0,13)
    local gs=Instance.new("UIStroke",grp)
    gs.Color=T.borderBright; gs.Thickness=1.5; gs.Transparency=0.08
    local gpad=Instance.new("UIPadding",grp)
    gpad.PaddingLeft=UDim.new(0,6); gpad.PaddingRight=UDim.new(0,6)
    gpad.PaddingTop=UDim.new(0,6); gpad.PaddingBottom=UDim.new(0,7)
    local gl=Instance.new("UIListLayout",grp)
    gl.Padding=UDim.new(0,4); gl.SortOrder=Enum.SortOrder.LayoutOrder
    return grp, gs
end

-- =====================
-- COMPONENT: SECTION LABEL (dalam group)
-- =====================
local function mkSectionLabel(parent, label, order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,18); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local acc=Instance.new("Frame",f)
    acc.Size=UDim2.new(0,3,0,12); acc.Position=UDim2.new(0,2,0.5,0)
    acc.AnchorPoint=Vector2.new(0,0.5); acc.BackgroundColor3=T.accentGlow
    acc.BorderSizePixel=0
    Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
    regAccent("bgGlow",acc)
    local t=Instance.new("TextLabel",f)
    t.Size=UDim2.new(1,-14,1,0); t.Position=UDim2.new(0,10,0,0)
    t.BackgroundTransparency=1; t.Text=string.upper(label)
    t.TextColor3=T.textSub; t.Font=Enum.Font.GothamBold
    t.TextSize=8; t.TextXAlignment=Enum.TextXAlignment.Left
    return f
end

-- =====================
-- COMPONENT: SECTION HEADER (di scroll page)
-- =====================
local function mkSection(parent,label,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local line=Instance.new("Frame",f)
    line.Size=UDim2.new(0,3,0.70,0); line.Position=UDim2.new(0,0,0.15,0)
    line.BackgroundColor3=T.accentGlow; line.BorderSizePixel=0
    Instance.new("UICorner",line).CornerRadius=UDim.new(1,0)
    regAccent("bgGlow",line)
    local hline=Instance.new("Frame",f)
    hline.Size=UDim2.new(1,-10,0,1); hline.Position=UDim2.new(0,8,1,-1)
    hline.BackgroundColor3=T.borderBright; hline.BackgroundTransparency=0.25
    hline.BorderSizePixel=0
    local t=Instance.new("TextLabel",f)
    t.Size=UDim2.new(1,-12,0,16); t.Position=UDim2.new(0,10,0,2)
    t.BackgroundTransparency=1; t.Text=string.upper(label)
    t.TextColor3=T.textSub; t.Font=Enum.Font.GothamBold
    t.TextSize=9; t.TextXAlignment=Enum.TextXAlignment.Left
    return f
end

-- =====================
-- COMPONENT: CARD
-- =====================
local function mkCard(parent,h,order)
    local c=Instance.new("Frame",parent)
    c.Size=UDim2.new(1,0,0,h or 50); c.BackgroundColor3=T.card
    c.BorderSizePixel=0; c.LayoutOrder=order or 0
    c.ClipsDescendants=true; c.ZIndex=5
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,10)
    local cs=Instance.new("UIStroke",c)
    cs.Color=T.borderBright; cs.Transparency=0.4; cs.Thickness=1.0
    Instance.new("UIGradient",c).Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(27,24,42)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(17,15,28)),
    }
    c.MouseEnter:Connect(function()
        if c and c.Parent then
            smooth(c,{BackgroundColor3=T.cardHover},0.15):Play()
            smooth(cs,{Color=T.accentGlow,Transparency=0.18},0.15):Play()
        end
    end)
    c.MouseLeave:Connect(function()
        if c and c.Parent then
            smooth(c,{BackgroundColor3=T.card},0.15):Play()
            smooth(cs,{Color=T.borderBright,Transparency=0.4},0.15):Play()
        end
    end)
    return c,cs
end

-- =====================
-- COMPONENT: STATUS ROW
-- =====================
local function mkStatus(parent,prefix,init,order)
    local c=Instance.new("Frame",parent)
    c.Size=UDim2.new(1,0,0,32); c.BackgroundColor3=Color3.fromRGB(17,15,27)
    c.BorderSizePixel=0; c.LayoutOrder=order or 0; c.ZIndex=5
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,8)
    local dot=Instance.new("Frame",c)
    dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,10,0.5,0)
    dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.textDim
    dot.BorderSizePixel=0; dot.ZIndex=7
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local pfx=Instance.new("TextLabel",c)
    pfx.Size=UDim2.new(0,52,1,0); pfx.Position=UDim2.new(0,22,0,0)
    pfx.BackgroundTransparency=1; pfx.Text=prefix; pfx.TextColor3=T.textDim
    pfx.Font=Enum.Font.GothamBold; pfx.TextSize=9
    pfx.TextXAlignment=Enum.TextXAlignment.Left; pfx.ZIndex=6
    local val=Instance.new("TextLabel",c)
    val.Size=UDim2.new(1,-80,1,0); val.Position=UDim2.new(0,76,0,0)
    val.BackgroundTransparency=1; val.Text=init or "--"; val.TextColor3=T.textSub
    val.Font=Enum.Font.Gotham; val.TextSize=10
    val.TextXAlignment=Enum.TextXAlignment.Left; val.ZIndex=6
    local function set(text,col)
        val.Text=text or "--"
        if col then
            smooth(val,{TextColor3=col},0.2):Play()
            smooth(dot,{BackgroundColor3=col},0.2):Play()
        end
    end
    return c,set
end

-- =====================
-- COMPONENT: TOGGLE
-- =====================
local function mkToggle(parent,label,default,onChange,order)
    local card=mkCard(parent,42,order)
    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(1,-70,1,0); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.text
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=UISettings.fontSize
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    local track=Instance.new("Frame",card)
    track.Size=UDim2.new(0,38,0,20); track.Position=UDim2.new(1,-48,0.5,0)
    track.AnchorPoint=Vector2.new(0,0.5); track.BackgroundColor3=T.border
    track.BorderSizePixel=0; track.ZIndex=6
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",track).Color=T.borderBright
    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,14,0,14); thumb.Position=UDim2.new(0,3,0.5,0)
    thumb.AnchorPoint=Vector2.new(0,0.5); thumb.BackgroundColor3=T.white
    thumb.BorderSizePixel=0; thumb.ZIndex=7
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local val=default or false
    local function apply(v)
        val=v
        smooth(track,{BackgroundColor3=v and T.accent or T.border},0.22):Play()
        smooth(thumb,{Position=UDim2.new(v and 1 or 0,v and -17 or 3,0.5,0)},0.22):Play()
        if onChange then onChange(v) end
    end
    apply(val)
    local hit=Instance.new("TextButton",card)
    hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=10
    hit.MouseButton1Click:Connect(function()
        ripple(card,card.AbsoluteSize.X*0.5,card.AbsoluteSize.Y*0.5,T.accent)
        spring(thumb,{Size=UDim2.new(0,18,0,14)},0.18):Play()
        task.delay(0.12,function() spring(thumb,{Size=UDim2.new(0,14,0,14)},0.2):Play() end)
        apply(not val)
    end)
    return card,apply,function() return val end
end

-- =====================
-- COMPONENT: SLIDER
-- =====================
local function mkSlider(parent,label,min,max,default,suffix,onChange,order)
    local card=mkCard(parent,62,order)
    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(0.62,0,0,20); lbl.Position=UDim2.new(0,12,0,6)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.text
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=UISettings.fontSize
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    local valLbl=Instance.new("TextLabel",card)
    valLbl.Size=UDim2.new(0.38,-12,0,20); valLbl.Position=UDim2.new(0.62,0,0,6)
    valLbl.BackgroundTransparency=1; valLbl.TextColor3=T.accentGlow
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=UISettings.fontSize
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=6
    regAccent("txtGlow",valLbl)
    local trackBg=Instance.new("Frame",card)
    trackBg.Size=UDim2.new(1,-24,0,4); trackBg.Position=UDim2.new(0,12,0,44)
    trackBg.BackgroundColor3=T.border; trackBg.BorderSizePixel=0; trackBg.ZIndex=6
    Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",trackBg)
    fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=T.accent
    fill.BorderSizePixel=0; fill.ZIndex=7
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    Instance.new("UIGradient",fill).Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,T.accentGlow),
        ColorSequenceKeypoint.new(1,T.accent),
    }
    regAccent("bgAccent",fill)
    local knob=Instance.new("Frame",trackBg)
    knob.Size=UDim2.new(0,14,0,14); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(0,0,0.5,0); knob.BackgroundColor3=T.white
    knob.BorderSizePixel=0; knob.ZIndex=8
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local ks=Instance.new("UIStroke",knob); ks.Color=T.accent; ks.Thickness=2
    regAccent("stAccent",ks)
    local curVal=math.clamp(default or min,min,max); local dragging=false
    local function setVal(v)
        curVal=math.clamp(math.floor(v+0.5),min,max)
        local r=(curVal-min)/(max-min)
        valLbl.Text=tostring(curVal)..(suffix or "")
        smooth(fill,{Size=UDim2.new(r,0,1,0)},0.1):Play()
        smooth(knob,{Position=UDim2.new(r,0,0.5,0)},0.1):Play()
        if onChange then onChange(curVal) end
    end
    setVal(curVal)
    local sHit=Instance.new("TextButton",card)
    sHit.Size=UDim2.new(1,-20,0,30); sHit.Position=UDim2.new(0,10,0,30)
    sHit.BackgroundTransparency=1; sHit.Text=""; sHit.ZIndex=12
    sHit.MouseButton1Down:Connect(function()
        dragging=true; spring(knob,{Size=UDim2.new(0,18,0,18)},0.2):Play()
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            if trackBg and trackBg.Parent then
                local r=math.clamp((i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1)
                setVal(min+r*(max-min))
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            if dragging then dragging=false; spring(knob,{Size=UDim2.new(0,14,0,14)},0.24):Play() end
        end
    end)
    return card,setVal,function() return curVal end
end

-- =====================
-- COMPONENT: ON/OFF BUTTON (state-safe)
-- =====================
local function mkOnOffBtn(parent,label,order)
    local BTN_H=48
    local wrapper=Instance.new("Frame",parent)
    wrapper.Size=UDim2.new(1,0,0,BTN_H)
    wrapper.BackgroundColor3=Color3.fromRGB(14,12,24)
    wrapper.BorderSizePixel=0; wrapper.LayoutOrder=order or 0
    wrapper.ClipsDescendants=false; wrapper.ZIndex=6
    Instance.new("UICorner",wrapper).CornerRadius=UDim.new(0,11)
    local wStroke=Instance.new("UIStroke",wrapper)
    wStroke.Color=T.borderBright; wStroke.Thickness=1.5; wStroke.Transparency=0.15
    local wGlow=Instance.new("ImageLabel",wrapper)
    wGlow.Size=UDim2.new(1,24,1,24); wGlow.Position=UDim2.new(0.5,0,0.5,0)
    wGlow.AnchorPoint=Vector2.new(0.5,0.5); wGlow.BackgroundTransparency=1
    wGlow.Image="rbxassetid://5028857084"; wGlow.ImageColor3=T.green
    wGlow.ImageTransparency=1; wGlow.ZIndex=0
    local dot=Instance.new("Frame",wrapper)
    dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(0,13,0.5,0)
    dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.red
    dot.BorderSizePixel=0; dot.ZIndex=8
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local dotGlow=Instance.new("UIStroke",dot)
    dotGlow.Color=T.red; dotGlow.Thickness=2; dotGlow.Transparency=0.5
    local lbl=Instance.new("TextLabel",wrapper)
    lbl.Size=UDim2.new(1,-68,1,0); lbl.Position=UDim2.new(0,28,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=T.textSub; lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=UISettings.fontSize; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=8
    local statusTxt=Instance.new("TextLabel",wrapper)
    statusTxt.Size=UDim2.new(0,42,1,0); statusTxt.Position=UDim2.new(1,-46,0,0)
    statusTxt.BackgroundTransparency=1; statusTxt.Text="OFF"
    statusTxt.TextColor3=T.textDim; statusTxt.Font=Enum.Font.GothamBold
    statusTxt.TextSize=11; statusTxt.ZIndex=8

    local on=false
    local externalCb=nil

    local function applyVisual(v)
        if v then
            smooth(wrapper,{BackgroundColor3=T.white},0.22):Play()
            smooth(wStroke,{Color=T.green,Transparency=0.0,Thickness=1.8},0.22):Play()
            smooth(lbl,{TextColor3=T.black},0.22):Play()
            smooth(dot,{BackgroundColor3=T.green},0.22):Play()
            smooth(dotGlow,{Color=T.green},0.22):Play()
            smooth(wGlow,{ImageTransparency=0.72},0.3):Play()
            statusTxt.Text="ON"
            smooth(statusTxt,{TextColor3=Color3.fromRGB(25,25,25)},0.1):Play()
        else
            smooth(wrapper,{BackgroundColor3=Color3.fromRGB(14,12,24)},0.22):Play()
            smooth(wStroke,{Color=T.borderBright,Transparency=0.15,Thickness=1.5},0.22):Play()
            smooth(lbl,{TextColor3=T.textSub},0.22):Play()
            smooth(dot,{BackgroundColor3=T.red},0.22):Play()
            smooth(dotGlow,{Color=T.red},0.22):Play()
            smooth(wGlow,{ImageTransparency=1},0.22):Play()
            statusTxt.Text="OFF"
            smooth(statusTxt,{TextColor3=T.textDim},0.1):Play()
        end
    end

    local function setOn(v) on=v; applyVisual(v) end
    local function setCallback(cb) externalCb=cb end

    local hit=Instance.new("TextButton",wrapper)
    hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=10
    hit.MouseEnter:Connect(function()
        if not on then smooth(wrapper,{BackgroundColor3=Color3.fromRGB(22,20,36)},0.14):Play() end
    end)
    hit.MouseLeave:Connect(function()
        if not on then smooth(wrapper,{BackgroundColor3=Color3.fromRGB(14,12,24)},0.14):Play() end
    end)
    hit.MouseButton1Click:Connect(function()
        on=not on
        ripple(wrapper,wrapper.AbsoluteSize.X*0.5,wrapper.AbsoluteSize.Y*0.5,on and T.accent or T.black)
        applyVisual(on)
        if externalCb then externalCb(on) end
    end)
    task.spawn(function()
        while wrapper and wrapper.Parent do
            if on then
                ease(wGlow,{ImageTransparency=0.62},0.7):Play(); task.wait(0.82)
                ease(wGlow,{ImageTransparency=0.82},0.7):Play(); task.wait(0.82)
            else task.wait(0.5) end
        end
    end)
    return wrapper, setOn, function() return on end, setCallback
end

-- =====================
-- COMPONENT: DROPDOWN V2
-- =====================
local function mkDropdownV2(parent,label,icon,iconCol,items,default,onChange,order)
    local HEADER_H=46; local ITEM_H=36
    local wrapper=Instance.new("Frame",parent)
    wrapper.Size=UDim2.new(1,0,0,HEADER_H)
    wrapper.BackgroundColor3=T.card; wrapper.BorderSizePixel=0
    wrapper.LayoutOrder=order or 0; wrapper.ClipsDescendants=true; wrapper.ZIndex=5
    Instance.new("UICorner",wrapper).CornerRadius=UDim.new(0,10)
    local wStroke=Instance.new("UIStroke",wrapper)
    wStroke.Color=T.borderBright; wStroke.Transparency=0.35; wStroke.Thickness=1.0
    Instance.new("UIGradient",wrapper).Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(27,24,42)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(17,15,28)),
    }
    local header=Instance.new("TextButton",wrapper)
    header.Size=UDim2.new(1,0,0,HEADER_H)
    header.BackgroundTransparency=1; header.Text=""; header.ZIndex=8
    local icCircle=Instance.new("Frame",header)
    icCircle.Size=UDim2.new(0,26,0,26); icCircle.Position=UDim2.new(0,10,0.5,0)
    icCircle.AnchorPoint=Vector2.new(0,0.5); icCircle.BackgroundColor3=iconCol or T.accentSoft
    icCircle.BorderSizePixel=0; icCircle.ZIndex=9
    Instance.new("UICorner",icCircle).CornerRadius=UDim.new(1,0)
    local icSym=Instance.new("TextLabel",icCircle)
    icSym.Size=UDim2.new(1,0,1,0); icSym.BackgroundTransparency=1
    icSym.Text=icon or "?"; icSym.TextColor3=T.white
    icSym.Font=Enum.Font.GothamBold; icSym.TextSize=12; icSym.ZIndex=10
    local labelL=Instance.new("TextLabel",header)
    labelL.Size=UDim2.new(1,-110,1,0); labelL.Position=UDim2.new(0,44,0,0)
    labelL.BackgroundTransparency=1; labelL.Text=label; labelL.TextColor3=T.text
    labelL.Font=Enum.Font.GothamBold; labelL.TextSize=UISettings.fontSize
    labelL.TextXAlignment=Enum.TextXAlignment.Left; labelL.ZIndex=9
    local selValL=Instance.new("TextLabel",header)
    selValL.Size=UDim2.new(0,72,1,0); selValL.Position=UDim2.new(1,-96,0,0)
    selValL.BackgroundTransparency=1; selValL.Text=default or (items[1] or "")
    selValL.TextColor3=T.accentGlow; selValL.Font=Enum.Font.Gotham
    selValL.TextSize=10; selValL.TextXAlignment=Enum.TextXAlignment.Right; selValL.ZIndex=9
    regAccent("txtGlow",selValL)
    local arrowL=Instance.new("TextLabel",header)
    arrowL.Size=UDim2.new(0,24,1,0); arrowL.Position=UDim2.new(1,-26,0,0)
    arrowL.BackgroundTransparency=1; arrowL.Text="▾"
    arrowL.TextColor3=T.textSub; arrowL.Font=Enum.Font.GothamBold
    arrowL.TextSize=12; arrowL.ZIndex=9
    local selected=default or items[1]
    local itemFrames={}
    for idx,item in ipairs(items) do
        local yOff=HEADER_H+(idx-1)*ITEM_H
        local sep=Instance.new("Frame",wrapper)
        sep.Size=UDim2.new(1,-12,0,1); sep.Position=UDim2.new(0,6,0,yOff)
        sep.BackgroundColor3=T.borderBright; sep.BackgroundTransparency=0.2
        sep.BorderSizePixel=0; sep.ZIndex=6
        local itemBtn=Instance.new("TextButton",wrapper)
        itemBtn.Size=UDim2.new(1,0,0,ITEM_H); itemBtn.Position=UDim2.new(0,0,0,yOff+1)
        itemBtn.BackgroundTransparency=1; itemBtn.Text=""; itemBtn.ZIndex=7
        local hlBg=Instance.new("Frame",itemBtn)
        hlBg.Size=UDim2.new(1,-12,1,-6); hlBg.Position=UDim2.new(0,6,0,3)
        hlBg.BackgroundColor3=T.accent
        hlBg.BackgroundTransparency=(item==selected) and 0.72 or 1
        hlBg.BorderSizePixel=0; hlBg.ZIndex=7
        Instance.new("UICorner",hlBg).CornerRadius=UDim.new(0,6)
        regAccent("bgAccent",hlBg)
        local itemDot=Instance.new("Frame",itemBtn)
        itemDot.Size=UDim2.new(0,5,0,5); itemDot.Position=UDim2.new(0,14,0.5,0)
        itemDot.AnchorPoint=Vector2.new(0,0.5)
        itemDot.BackgroundColor3=(item==selected) and T.accentGlow or T.textDim
        itemDot.BackgroundTransparency=(item==selected) and 0 or 0.6
        itemDot.BorderSizePixel=0; itemDot.ZIndex=8
        Instance.new("UICorner",itemDot).CornerRadius=UDim.new(1,0)
        local itemTxt=Instance.new("TextLabel",itemBtn)
        itemTxt.Size=UDim2.new(1,-50,1,0); itemTxt.Position=UDim2.new(0,26,0,0)
        itemTxt.BackgroundTransparency=1; itemTxt.Text=item
        itemTxt.TextColor3=(item==selected) and T.white or T.textSub
        itemTxt.Font=(item==selected) and Enum.Font.GothamBold or Enum.Font.Gotham
        itemTxt.TextSize=11; itemTxt.TextXAlignment=Enum.TextXAlignment.Left; itemTxt.ZIndex=8
        local checkL=Instance.new("TextLabel",itemBtn)
        checkL.Size=UDim2.new(0,24,1,0); checkL.Position=UDim2.new(1,-26,0,0)
        checkL.BackgroundTransparency=1; checkL.Text=(item==selected) and "✓" or ""
        checkL.TextColor3=T.accentGlow; checkL.Font=Enum.Font.GothamBold
        checkL.TextSize=12; checkL.ZIndex=8
        regAccent("txtGlow",checkL)
        itemFrames[idx]={btn=itemBtn,hlBg=hlBg,dot=itemDot,txt=itemTxt,check=checkL}
        itemBtn.MouseEnter:Connect(function()
            if item~=selected then
                smooth(hlBg,{BackgroundTransparency=0.84},0.12):Play()
                smooth(itemTxt,{TextColor3=T.text},0.12):Play()
            end
        end)
        itemBtn.MouseLeave:Connect(function()
            if item~=selected then
                smooth(hlBg,{BackgroundTransparency=1},0.12):Play()
                smooth(itemTxt,{TextColor3=T.textSub},0.12):Play()
            end
        end)
        local ci=item
        itemBtn.MouseButton1Click:Connect(function()
            selected=ci; selValL.Text=ci
            ripple(itemBtn,itemBtn.AbsoluteSize.X*0.5,itemBtn.AbsoluteSize.Y*0.5,T.accent)
            for i2,d in ipairs(itemFrames) do
                local isSel=(items[i2]==selected)
                smooth(d.hlBg,{BackgroundTransparency=isSel and 0.72 or 1},0.18):Play()
                smooth(d.dot,{BackgroundColor3=isSel and T.accentGlow or T.textDim,
                    BackgroundTransparency=isSel and 0 or 0.6},0.18):Play()
                smooth(d.txt,{TextColor3=isSel and T.white or T.textSub},0.18):Play()
                d.txt.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham
                d.check.Text=isSel and "✓" or ""
            end
            if onChange then onChange(ci) end
        end)
    end
    local open=false
    local CLOSED_H=HEADER_H; local OPEN_H=HEADER_H+#items*ITEM_H+2
    local function setOpen(state)
        open=state
        smooth(wrapper,{Size=UDim2.new(1,0,0,state and OPEN_H or CLOSED_H)},0.28):Play()
        smooth(arrowL,{Rotation=state and 180 or 0},0.22):Play()
        if state then
            smooth(wStroke,{Color=T.accentGlow,Transparency=0.05,Thickness=1.4},0.22):Play()
            smooth(wrapper,{BackgroundColor3=T.cardHover},0.22):Play()
        else
            smooth(wStroke,{Color=T.borderBright,Transparency=0.35,Thickness=1.0},0.22):Play()
            smooth(wrapper,{BackgroundColor3=T.card},0.22):Play()
        end
    end
    header.MouseButton1Click:Connect(function()
        ripple(header,header.AbsoluteSize.X*0.5,header.AbsoluteSize.Y*0.5,T.accent)
        setOpen(not open)
    end)
    header.MouseEnter:Connect(function()
        if not open then smooth(wrapper,{BackgroundColor3=T.cardHover},0.14):Play() end
    end)
    header.MouseLeave:Connect(function()
        if not open then smooth(wrapper,{BackgroundColor3=T.card},0.14):Play() end
    end)
    return wrapper,function() return selected end
end

-- =====================
-- COMPONENT: SUB-TAB BAR
-- =====================
local function mkSubTabBar(parent,tabs)
    local BAR_H=34
    local barContainer=Instance.new("Frame",parent)
    barContainer.Size=UDim2.new(1,0,0,BAR_H)
    barContainer.BackgroundColor3=Color3.fromRGB(12,10,21)
    barContainer.BorderSizePixel=0; barContainer.ZIndex=8
    Instance.new("UICorner",barContainer).CornerRadius=UDim.new(0,10)
    local bcStroke=Instance.new("UIStroke",barContainer)
    bcStroke.Color=T.borderBright; bcStroke.Transparency=0.08; bcStroke.Thickness=1.5
    for i=1,#tabs-1 do
        local ts=Instance.new("Frame",barContainer)
        ts.Size=UDim2.new(0,1,0.5,0); ts.Position=UDim2.new(i/#tabs,0,0.25,0)
        ts.BackgroundColor3=T.border; ts.BackgroundTransparency=0.25
        ts.BorderSizePixel=0; ts.ZIndex=9
    end
    local sep=Instance.new("Frame",parent)
    sep.Size=UDim2.new(1,0,0,1); sep.Position=UDim2.new(0,0,0,BAR_H+2)
    sep.BackgroundColor3=T.borderBright; sep.BackgroundTransparency=0.2
    sep.BorderSizePixel=0; sep.ZIndex=8
    local pill=Instance.new("Frame",barContainer)
    pill.Size=UDim2.new(1/#tabs,-6,0,BAR_H-8); pill.Position=UDim2.new(0,3,0,4)
    pill.BackgroundColor3=T.accent; pill.BorderSizePixel=0; pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(0,7)
    Instance.new("UIGradient",pill).Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,T.accentGlow),
        ColorSequenceKeypoint.new(1,T.accent),
    }
    regAccent("bgAccent",pill)
    local subBtns={}; local subPages={}
    local function switchSub(idx)
        smooth(pill,{Position=UDim2.new((idx-1)/#tabs,3,0,4)},0.26):Play()
        for i2,d in ipairs(subBtns) do
            smooth(d.lbl,{TextColor3=(i2==idx) and T.white or T.textSub},0.22):Play()
            d.subPage.Visible=(i2==idx)
        end
    end
    for i,name in ipairs(tabs) do
        local sbtn=Instance.new("TextButton",barContainer)
        sbtn.Size=UDim2.new(1/#tabs,0,1,0); sbtn.Position=UDim2.new((i-1)/#tabs,0,0,0)
        sbtn.BackgroundTransparency=1; sbtn.Text=""; sbtn.ZIndex=10
        local slbl=Instance.new("TextLabel",sbtn)
        slbl.Size=UDim2.new(1,0,1,0); slbl.BackgroundTransparency=1; slbl.Text=name
        slbl.TextColor3=(i==1) and T.white or T.textSub
        slbl.Font=Enum.Font.GothamBold; slbl.TextSize=11; slbl.ZIndex=11
        local subOuter=Instance.new("Frame",parent)
        subOuter.Size=UDim2.new(1,0,1,-BAR_H-4); subOuter.Position=UDim2.new(0,0,0,BAR_H+4)
        subOuter.BackgroundTransparency=1; subOuter.Visible=(i==1); subOuter.ZIndex=3
        local sf=mkScrollPage(subOuter)
        subBtns[i]={lbl=slbl,subPage=subOuter}; subPages[name]=sf
        local ci=i
        sbtn.MouseButton1Click:Connect(function()
            ripple(sbtn,sbtn.AbsoluteSize.X*0.5,sbtn.AbsoluteSize.Y*0.5,T.white)
            switchSub(ci)
        end)
    end
    return subPages
end

-- =====================
-- RETURN MODULE
-- =====================
return {
    T=T, UISettings=UISettings,
    regAccent=regAccent, applyAccent=applyAccent,
    smooth=smooth, spring=spring, ease=ease, ripple=ripple,
    mkScrollPage=mkScrollPage,
    mkGroupBox=mkGroupBox,
    mkSectionLabel=mkSectionLabel,
    mkSection=mkSection,
    mkCard=mkCard,
    mkStatus=mkStatus,
    mkToggle=mkToggle,
    mkSlider=mkSlider,
    mkOnOffBtn=mkOnOffBtn,
    mkDropdownV2=mkDropdownV2,
    mkSubTabBar=mkSubTabBar,
}
