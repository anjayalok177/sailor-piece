-- Yi Da Mu Sake | UILib.lua
-- Pure helper library: Theme + Tween + mk* functions
-- Sets: _G.YiLib

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- ===== THEME =====
local T = {
    bg=Color3.fromRGB(7,7,13),       surface=Color3.fromRGB(15,14,23),
    card=Color3.fromRGB(20,18,32),   cardHover=Color3.fromRGB(27,25,42),
    border=Color3.fromRGB(58,50,88), borderBright=Color3.fromRGB(100,82,150),
    accent=Color3.fromRGB(118,68,255),  accentSoft=Color3.fromRGB(88,48,188),
    accentGlow=Color3.fromRGB(152,92,255), accentDim=Color3.fromRGB(60,35,130),
    green=Color3.fromRGB(42,198,108),    greenDim=Color3.fromRGB(25,125,70),
    red=Color3.fromRGB(215,58,78),
    text=Color3.fromRGB(230,226,248),    textSub=Color3.fromRGB(138,130,172),
    textDim=Color3.fromRGB(72,65,102),
    white=Color3.fromRGB(255,255,255),  black=Color3.fromRGB(10,10,16),
    amber=Color3.fromRGB(255,180,40),
}

local ACCENT_PRESETS = {
    Purple={Color3.fromRGB(118,68,255),Color3.fromRGB(88,48,188), Color3.fromRGB(152,92,255)},
    Blue  ={Color3.fromRGB(50,120,255), Color3.fromRGB(35,88,200),  Color3.fromRGB(80,150,255)},
    Cyan  ={Color3.fromRGB(30,190,220), Color3.fromRGB(20,145,175), Color3.fromRGB(60,215,240)},
    Green ={Color3.fromRGB(40,200,100), Color3.fromRGB(28,150,72),  Color3.fromRGB(65,225,130)},
    Red   ={Color3.fromRGB(220,55,80),  Color3.fromRGB(168,38,58),  Color3.fromRGB(245,80,105)},
}

local accentRegistry = {}
local function regAccent(typ,obj) table.insert(accentRegistry,{t=typ,o=obj}) end

local function applyAccentLive()
    for _,e in ipairs(accentRegistry) do
        pcall(function()
            local o,t = e.o, e.t
            if     t=="bgAccent"  then TS:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accent}):Play()
            elseif t=="bgGlow"    then TS:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accentGlow}):Play()
            elseif t=="bgSoft"    then TS:Create(o,TweenInfo.new(0.3),{BackgroundColor3=T.accentSoft}):Play()
            elseif t=="stAccent"  then TS:Create(o,TweenInfo.new(0.3),{Color=T.accent}):Play()
            elseif t=="stGlow"    then TS:Create(o,TweenInfo.new(0.3),{Color=T.accentGlow}):Play()
            elseif t=="imgAccent" then TS:Create(o,TweenInfo.new(0.3),{ImageColor3=T.accent}):Play()
            elseif t=="txtGlow"   then TS:Create(o,TweenInfo.new(0.3),{TextColor3=T.accentGlow}):Play()
            elseif t=="scrollbar" then o.ScrollBarImageColor3=T.accent
            end
        end)
    end
end

local function applyAccent(preset)
    local p = ACCENT_PRESETS[preset]; if not p then return end
    T.accent=p[1]; T.accentSoft=p[2]; T.accentGlow=p[3]
    applyAccentLive()
end

-- ===== TWEEN HELPERS =====
local function tw(o,p,t,s,d)
    return TS:Create(o,TweenInfo.new(t or 0.22,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p)
end
local function smooth(o,p,t) return tw(o,p,t or 0.22) end
local function spring(o,p,t) return tw(o,p,t or 0.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out) end
local function ease(o,p,t)   return tw(o,p,t or 0.28,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut) end

-- ===== RIPPLE =====
local function ripple(parent,x,y,col)
    local ok,pos=pcall(function() return Vector2.new(x or parent.AbsoluteSize.X/2,y or parent.AbsoluteSize.Y/2) end)
    if not ok then return end
    local r=Instance.new("Frame")
    r.Size=UDim2.new(0,0,0,0); r.Position=UDim2.new(0,pos.X,0,pos.Y)
    r.AnchorPoint=Vector2.new(0.5,0.5); r.BackgroundColor3=col or T.white
    r.BackgroundTransparency=0.72; r.BorderSizePixel=0; r.ZIndex=60; r.Parent=parent
    Instance.new("UICorner",r).CornerRadius=UDim.new(1,0)
    local sz=math.max(parent.AbsoluteSize.X,parent.AbsoluteSize.Y)*2.6
    local t1=smooth(r,{Size=UDim2.new(0,sz,0,sz),BackgroundTransparency=0.92},0.46); t1:Play()
    t1.Completed:Connect(function() smooth(r,{BackgroundTransparency=1},0.16):Play(); task.wait(0.18); pcall(function() r:Destroy() end) end)
end

-- ===== mkScrollPage =====
local function mkScrollPage(parent)
    local sf=Instance.new("ScrollingFrame",parent)
    sf.Size=UDim2.new(1,-8,1,-8); sf.Position=UDim2.new(0,4,0,4)
    sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=2; sf.ScrollBarImageColor3=T.accent; sf.ScrollBarImageTransparency=0.4
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y; sf.ZIndex=3; sf.ClipsDescendants=true
    regAccent("scrollbar",sf)
    local ul=Instance.new("UIListLayout",sf); ul.Padding=UDim.new(0,6); ul.SortOrder=Enum.SortOrder.LayoutOrder
    local pp=Instance.new("UIPadding",sf); pp.PaddingTop=UDim.new(0,6); pp.PaddingBottom=UDim.new(0,14); pp.PaddingLeft=UDim.new(0,4); pp.PaddingRight=UDim.new(0,4)
    return sf
end

-- ===== mkGroupBox (border bersama) =====
local function mkGroupBox(parent,order)
    local g=Instance.new("Frame",parent)
    g.BackgroundColor3=Color3.fromRGB(13,12,22); g.BorderSizePixel=0; g.LayoutOrder=order or 0
    g.AutomaticSize=Enum.AutomaticSize.Y; g.Size=UDim2.new(1,0,0,0); g.ClipsDescendants=false
    Instance.new("UICorner",g).CornerRadius=UDim.new(0,13)
    local gs=Instance.new("UIStroke",g); gs.Color=T.borderBright; gs.Thickness=1.5; gs.Transparency=0.08
    local gp=Instance.new("UIPadding",g); gp.PaddingLeft=UDim.new(0,6); gp.PaddingRight=UDim.new(0,6); gp.PaddingTop=UDim.new(0,6); gp.PaddingBottom=UDim.new(0,7)
    local gl=Instance.new("UIListLayout",g); gl.Padding=UDim.new(0,4); gl.SortOrder=Enum.SortOrder.LayoutOrder
    return g,gs
end

-- ===== mkSectionLabel (label kecil di dalam group) =====
local function mkSectionLabel(parent,label,order)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,18); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local acc=Instance.new("Frame",f); acc.Size=UDim2.new(0,3,0,12); acc.Position=UDim2.new(0,2,0.5,0); acc.AnchorPoint=Vector2.new(0,0.5); acc.BackgroundColor3=T.accentGlow; acc.BorderSizePixel=0
    Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0); regAccent("bgGlow",acc)
    local t=Instance.new("TextLabel",f); t.Size=UDim2.new(1,-14,1,0); t.Position=UDim2.new(0,10,0,0); t.BackgroundTransparency=1; t.Text=string.upper(label); t.TextColor3=T.textSub; t.Font=Enum.Font.GothamBold; t.TextSize=8; t.TextXAlignment=Enum.TextXAlignment.Left
    return f
end

-- ===== mkSection (header dengan hline, untuk scroll page) =====
local function mkSection(parent,label,order)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local line=Instance.new("Frame",f); line.Size=UDim2.new(0,3,0,13); line.Position=UDim2.new(0,0,0.5,0); line.AnchorPoint=Vector2.new(0,0.5); line.BackgroundColor3=T.accentGlow; line.BorderSizePixel=0
    Instance.new("UICorner",line).CornerRadius=UDim.new(1,0); regAccent("bgGlow",line)
    local hl=Instance.new("Frame",f); hl.Size=UDim2.new(1,-10,0,1); hl.Position=UDim2.new(0,8,1,-1); hl.BackgroundColor3=T.borderBright; hl.BackgroundTransparency=0.25; hl.BorderSizePixel=0
    local t=Instance.new("TextLabel",f); t.Size=UDim2.new(1,-12,1,0); t.Position=UDim2.new(0,10,0,0); t.BackgroundTransparency=1; t.Text=string.upper(label); t.TextColor3=T.textSub; t.Font=Enum.Font.GothamBold; t.TextSize=9; t.TextXAlignment=Enum.TextXAlignment.Left
    return f
end

-- ===== mkCard =====
local function mkCard(parent,h,order)
    local c=Instance.new("Frame",parent)
    c.Size=UDim2.new(1,0,0,h or 50); c.BackgroundColor3=T.card; c.BorderSizePixel=0; c.LayoutOrder=order or 0; c.ClipsDescendants=true; c.ZIndex=5
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,10)
    local cs=Instance.new("UIStroke",c); cs.Color=T.borderBright; cs.Transparency=0.4; cs.Thickness=1.0
    Instance.new("UIGradient",c).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(27,24,42)),ColorSequenceKeypoint.new(1,Color3.fromRGB(17,15,28))}
    c.MouseEnter:Connect(function() if c and c.Parent then smooth(c,{BackgroundColor3=T.cardHover},0.15):Play(); smooth(cs,{Color=T.accentGlow,Transparency=0.18},0.15):Play() end end)
    c.MouseLeave:Connect(function() if c and c.Parent then smooth(c,{BackgroundColor3=T.card},0.15):Play(); smooth(cs,{Color=T.borderBright,Transparency=0.4},0.15):Play() end end)
    return c,cs
end

-- ===== mkStatus =====
local function mkStatus(parent,prefix,init,order)
    local c=Instance.new("Frame",parent); c.Size=UDim2.new(1,0,0,32); c.BackgroundColor3=Color3.fromRGB(17,15,27); c.BorderSizePixel=0; c.LayoutOrder=order or 0; c.ZIndex=5
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,8)
    local dot=Instance.new("Frame",c); dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,10,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.textDim; dot.BorderSizePixel=0; dot.ZIndex=7; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local pfx=Instance.new("TextLabel",c); pfx.Size=UDim2.new(0,52,1,0); pfx.Position=UDim2.new(0,22,0,0); pfx.BackgroundTransparency=1; pfx.Text=prefix; pfx.TextColor3=T.textDim; pfx.Font=Enum.Font.GothamBold; pfx.TextSize=9; pfx.TextXAlignment=Enum.TextXAlignment.Left; pfx.ZIndex=6
    local val=Instance.new("TextLabel",c); val.Size=UDim2.new(1,-80,1,0); val.Position=UDim2.new(0,76,0,0); val.BackgroundTransparency=1; val.Text=init or "--"; val.TextColor3=T.textSub; val.Font=Enum.Font.Gotham; val.TextSize=10; val.TextXAlignment=Enum.TextXAlignment.Left; val.ZIndex=6
    local function set(text,col) val.Text=text or "--"; if col then smooth(val,{TextColor3=col},0.2):Play(); smooth(dot,{BackgroundColor3=col},0.2):Play() end end
    return c,set
end

-- ===== mkToggle =====
local function mkToggle(parent,label,default,onChange,order)
    local card=mkCard(parent,42,order)
    local lbl=Instance.new("TextLabel",card); lbl.Size=UDim2.new(1,-70,1,0); lbl.Position=UDim2.new(0,12,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.text; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    local track=Instance.new("Frame",card); track.Size=UDim2.new(0,38,0,20); track.Position=UDim2.new(1,-48,0.5,0); track.AnchorPoint=Vector2.new(0,0.5); track.BackgroundColor3=T.border; track.BorderSizePixel=0; track.ZIndex=6; Instance.new("UICorner",track).CornerRadius=UDim.new(1,0); Instance.new("UIStroke",track).Color=T.borderBright
    local thumb=Instance.new("Frame",track); thumb.Size=UDim2.new(0,14,0,14); thumb.Position=UDim2.new(0,3,0.5,0); thumb.AnchorPoint=Vector2.new(0,0.5); thumb.BackgroundColor3=T.white; thumb.BorderSizePixel=0; thumb.ZIndex=7; Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local val=default or false
    local function apply(v) val=v; smooth(track,{BackgroundColor3=v and T.accent or T.border},0.22):Play(); smooth(thumb,{Position=UDim2.new(v and 1 or 0,v and -17 or 3,0.5,0)},0.22):Play(); if onChange then onChange(v) end end
    apply(val)
    local hit=Instance.new("TextButton",card); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=10
    hit.MouseButton1Click:Connect(function() ripple(card,card.AbsoluteSize.X*0.5,card.AbsoluteSize.Y*0.5,T.accent); spring(thumb,{Size=UDim2.new(0,18,0,14)},0.18):Play(); task.delay(0.12,function() spring(thumb,{Size=UDim2.new(0,14,0,14)},0.2):Play() end); apply(not val) end)
    return card,apply,function() return val end
end

-- ===== mkSlider =====
local function mkSlider(parent,label,minV,maxV,default,suffix,onChange,order)
    local card=mkCard(parent,62,order)
    local lbl=Instance.new("TextLabel",card); lbl.Size=UDim2.new(0.62,0,0,20); lbl.Position=UDim2.new(0,12,0,6); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.text; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    local valLbl=Instance.new("TextLabel",card); valLbl.Size=UDim2.new(0.38,-12,0,20); valLbl.Position=UDim2.new(0.62,0,0,6); valLbl.BackgroundTransparency=1; valLbl.TextColor3=T.accentGlow; valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=12; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=6
    regAccent("txtGlow",valLbl)
    local trackBg=Instance.new("Frame",card); trackBg.Size=UDim2.new(1,-24,0,4); trackBg.Position=UDim2.new(0,12,0,44); trackBg.BackgroundColor3=T.border; trackBg.BorderSizePixel=0; trackBg.ZIndex=6; Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",trackBg); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=T.accent; fill.BorderSizePixel=0; fill.ZIndex=7; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    Instance.new("UIGradient",fill).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accent)}; regAccent("bgAccent",fill)
    local knob=Instance.new("Frame",trackBg); knob.Size=UDim2.new(0,14,0,14); knob.AnchorPoint=Vector2.new(0.5,0.5); knob.Position=UDim2.new(0,0,0.5,0); knob.BackgroundColor3=T.white; knob.BorderSizePixel=0; knob.ZIndex=8; Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local ks=Instance.new("UIStroke",knob); ks.Color=T.accent; ks.Thickness=2; regAccent("stAccent",ks)
    local curVal=math.clamp(default or minV,minV,maxV); local dragging=false
    local function setVal(v)
        curVal=math.clamp(math.floor(v+0.5),minV,maxV); local r=(curVal-minV)/(maxV-minV)
        valLbl.Text=tostring(curVal)..(suffix or ""); smooth(fill,{Size=UDim2.new(r,0,1,0)},0.1):Play(); smooth(knob,{Position=UDim2.new(r,0,0.5,0)},0.1):Play()
        if onChange then onChange(curVal) end
    end
    setVal(curVal)
    local sHit=Instance.new("TextButton",card); sHit.Size=UDim2.new(1,-20,0,30); sHit.Position=UDim2.new(0,10,0,30); sHit.BackgroundTransparency=1; sHit.Text=""; sHit.ZIndex=12
    sHit.MouseButton1Down:Connect(function() dragging=true; spring(knob,{Size=UDim2.new(0,18,0,18)},0.2):Play() end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            if trackBg and trackBg.Parent then local r=math.clamp((i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1); setVal(minV+r*(maxV-minV)) end
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if dragging then dragging=false; spring(knob,{Size=UDim2.new(0,14,0,14)},0.24):Play() end end end)
    return card,setVal,function() return curVal end
end

-- ===== mkOnOffBtn =====
local function mkOnOffBtn(parent,label,order)
    local w=Instance.new("Frame",parent)
    w.Size=UDim2.new(1,0,0,48); w.BackgroundColor3=Color3.fromRGB(14,12,24); w.BorderSizePixel=0; w.LayoutOrder=order or 0; w.ClipsDescendants=false; w.ZIndex=6
    Instance.new("UICorner",w).CornerRadius=UDim.new(0,11)
    local ws=Instance.new("UIStroke",w); ws.Color=T.borderBright; ws.Thickness=1.5; ws.Transparency=0.15
    local wGlow=Instance.new("ImageLabel",w); wGlow.Size=UDim2.new(1,24,1,24); wGlow.Position=UDim2.new(0.5,0,0.5,0); wGlow.AnchorPoint=Vector2.new(0.5,0.5); wGlow.BackgroundTransparency=1; wGlow.Image="rbxassetid://5028857084"; wGlow.ImageColor3=T.green; wGlow.ImageTransparency=1; wGlow.ZIndex=0
    local dot=Instance.new("Frame",w); dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(0,13,0.5,0); dot.AnchorPoint=Vector2.new(0,0.5); dot.BackgroundColor3=T.red; dot.BorderSizePixel=0; dot.ZIndex=8; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local dg=Instance.new("UIStroke",dot); dg.Color=T.red; dg.Thickness=2; dg.Transparency=0.5
    local lbl=Instance.new("TextLabel",w); lbl.Size=UDim2.new(1,-68,1,0); lbl.Position=UDim2.new(0,28,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.textSub; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=8
    local stxt=Instance.new("TextLabel",w); stxt.Size=UDim2.new(0,42,1,0); stxt.Position=UDim2.new(1,-46,0,0); stxt.BackgroundTransparency=1; stxt.Text="OFF"; stxt.TextColor3=T.textDim; stxt.Font=Enum.Font.GothamBold; stxt.TextSize=11; stxt.ZIndex=8
    local on=false; local exCb=nil
    local function applyV(v)
        if v then
            smooth(w,{BackgroundColor3=T.white},0.22):Play(); smooth(ws,{Color=T.green,Transparency=0,Thickness=1.8},0.22):Play()
            smooth(lbl,{TextColor3=T.black},0.22):Play(); smooth(dot,{BackgroundColor3=T.green},0.22):Play(); smooth(dg,{Color=T.green},0.22):Play(); smooth(wGlow,{ImageTransparency=0.72},0.3):Play()
            stxt.Text="ON"; smooth(stxt,{TextColor3=Color3.fromRGB(25,25,25)},0.1):Play()
        else
            smooth(w,{BackgroundColor3=Color3.fromRGB(14,12,24)},0.22):Play(); smooth(ws,{Color=T.borderBright,Transparency=0.15,Thickness=1.5},0.22):Play()
            smooth(lbl,{TextColor3=T.textSub},0.22):Play(); smooth(dot,{BackgroundColor3=T.red},0.22):Play(); smooth(dg,{Color=T.red},0.22):Play(); smooth(wGlow,{ImageTransparency=1},0.22):Play()
            stxt.Text="OFF"; smooth(stxt,{TextColor3=T.textDim},0.1):Play()
        end
    end
    local function setOn(v) on=v; applyV(v) end
    local function setCb(cb) exCb=cb end
    local hit=Instance.new("TextButton",w); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=10
    hit.MouseEnter:Connect(function() if not on then smooth(w,{BackgroundColor3=Color3.fromRGB(22,20,36)},0.14):Play() end end)
    hit.MouseLeave:Connect(function() if not on then smooth(w,{BackgroundColor3=Color3.fromRGB(14,12,24)},0.14):Play() end end)
    hit.MouseButton1Click:Connect(function() on=not on; ripple(w,w.AbsoluteSize.X*0.5,w.AbsoluteSize.Y*0.5,on and T.accent or T.black); applyV(on); if exCb then exCb(on) end end)
    task.spawn(function() while w and w.Parent do if on then ease(wGlow,{ImageTransparency=0.62},0.7):Play(); task.wait(0.82); ease(wGlow,{ImageTransparency=0.82},0.7):Play(); task.wait(0.82) else task.wait(0.5) end end end)
    return w,setOn,function() return on end,setCb
end

-- ===== mkDropdownV2 =====
local function mkDropdownV2(parent,label,icon,iconCol,items,default,onChange,order)
    local HH=46; local IH=36
    local w=Instance.new("Frame",parent); w.Size=UDim2.new(1,0,0,HH); w.BackgroundColor3=T.card; w.BorderSizePixel=0; w.LayoutOrder=order or 0; w.ClipsDescendants=true; w.ZIndex=5
    Instance.new("UICorner",w).CornerRadius=UDim.new(0,10)
    local ws=Instance.new("UIStroke",w); ws.Color=T.borderBright; ws.Transparency=0.35; ws.Thickness=1.0
    Instance.new("UIGradient",w).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(27,24,42)),ColorSequenceKeypoint.new(1,Color3.fromRGB(17,15,28))}
    local hdr=Instance.new("TextButton",w); hdr.Size=UDim2.new(1,0,0,HH); hdr.BackgroundTransparency=1; hdr.Text=""; hdr.ZIndex=8
    local ic=Instance.new("Frame",hdr); ic.Size=UDim2.new(0,26,0,26); ic.Position=UDim2.new(0,10,0.5,0); ic.AnchorPoint=Vector2.new(0,0.5); ic.BackgroundColor3=iconCol or T.accentSoft; ic.BorderSizePixel=0; ic.ZIndex=9; Instance.new("UICorner",ic).CornerRadius=UDim.new(1,0)
    local icS=Instance.new("TextLabel",ic); icS.Size=UDim2.new(1,0,1,0); icS.BackgroundTransparency=1; icS.Text=icon or "?"; icS.TextColor3=T.white; icS.Font=Enum.Font.GothamBold; icS.TextSize=12; icS.ZIndex=10
    local lblL=Instance.new("TextLabel",hdr); lblL.Size=UDim2.new(1,-110,1,0); lblL.Position=UDim2.new(0,44,0,0); lblL.BackgroundTransparency=1; lblL.Text=label; lblL.TextColor3=T.text; lblL.Font=Enum.Font.GothamBold; lblL.TextSize=12; lblL.TextXAlignment=Enum.TextXAlignment.Left; lblL.ZIndex=9
    local selL=Instance.new("TextLabel",hdr); selL.Size=UDim2.new(0,72,1,0); selL.Position=UDim2.new(1,-96,0,0); selL.BackgroundTransparency=1; selL.Text=default or (items[1] or ""); selL.TextColor3=T.accentGlow; selL.Font=Enum.Font.Gotham; selL.TextSize=10; selL.TextXAlignment=Enum.TextXAlignment.Right; selL.ZIndex=9; regAccent("txtGlow",selL)
    local arrL=Instance.new("TextLabel",hdr); arrL.Size=UDim2.new(0,24,1,0); arrL.Position=UDim2.new(1,-26,0,0); arrL.BackgroundTransparency=1; arrL.Text="▾"; arrL.TextColor3=T.textSub; arrL.Font=Enum.Font.GothamBold; arrL.TextSize=12; arrL.ZIndex=9
    local sel=default or items[1]; local iFs={}
    for idx,item in ipairs(items) do
        local yO=HH+(idx-1)*IH
        local sep=Instance.new("Frame",w); sep.Size=UDim2.new(1,-12,0,1); sep.Position=UDim2.new(0,6,0,yO); sep.BackgroundColor3=T.borderBright; sep.BackgroundTransparency=0.2; sep.BorderSizePixel=0; sep.ZIndex=6
        local ib=Instance.new("TextButton",w); ib.Size=UDim2.new(1,0,0,IH); ib.Position=UDim2.new(0,0,0,yO+1); ib.BackgroundTransparency=1; ib.Text=""; ib.ZIndex=7
        local hl=Instance.new("Frame",ib); hl.Size=UDim2.new(1,-12,1,-6); hl.Position=UDim2.new(0,6,0,3); hl.BackgroundColor3=T.accent; hl.BackgroundTransparency=(item==sel) and 0.72 or 1; hl.BorderSizePixel=0; hl.ZIndex=7; Instance.new("UICorner",hl).CornerRadius=UDim.new(0,6); regAccent("bgAccent",hl)
        local id=Instance.new("Frame",ib); id.Size=UDim2.new(0,5,0,5); id.Position=UDim2.new(0,14,0.5,0); id.AnchorPoint=Vector2.new(0,0.5); id.BackgroundColor3=(item==sel) and T.accentGlow or T.textDim; id.BackgroundTransparency=(item==sel) and 0 or 0.6; id.BorderSizePixel=0; id.ZIndex=8; Instance.new("UICorner",id).CornerRadius=UDim.new(1,0)
        local it=Instance.new("TextLabel",ib); it.Size=UDim2.new(1,-50,1,0); it.Position=UDim2.new(0,26,0,0); it.BackgroundTransparency=1; it.Text=item; it.TextColor3=(item==sel) and T.white or T.textSub; it.Font=(item==sel) and Enum.Font.GothamBold or Enum.Font.Gotham; it.TextSize=11; it.TextXAlignment=Enum.TextXAlignment.Left; it.ZIndex=8
        local ck=Instance.new("TextLabel",ib); ck.Size=UDim2.new(0,24,1,0); ck.Position=UDim2.new(1,-26,0,0); ck.BackgroundTransparency=1; ck.Text=(item==sel) and "✓" or ""; ck.TextColor3=T.accentGlow; ck.Font=Enum.Font.GothamBold; ck.TextSize=12; ck.ZIndex=8; regAccent("txtGlow",ck)
        iFs[idx]={hlBg=hl,dot=id,txt=it,check=ck}
        ib.MouseEnter:Connect(function() if item~=sel then smooth(hl,{BackgroundTransparency=0.84},0.12):Play(); smooth(it,{TextColor3=T.text},0.12):Play() end end)
        ib.MouseLeave:Connect(function() if item~=sel then smooth(hl,{BackgroundTransparency=1},0.12):Play(); smooth(it,{TextColor3=T.textSub},0.12):Play() end end)
        local ci=item
        ib.MouseButton1Click:Connect(function()
            sel=ci; selL.Text=ci; ripple(ib,ib.AbsoluteSize.X*0.5,ib.AbsoluteSize.Y*0.5,T.accent)
            for i2,d in ipairs(iFs) do local iS=(items[i2]==sel); smooth(d.hlBg,{BackgroundTransparency=iS and 0.72 or 1},0.18):Play(); smooth(d.dot,{BackgroundColor3=iS and T.accentGlow or T.textDim,BackgroundTransparency=iS and 0 or 0.6},0.18):Play(); smooth(d.txt,{TextColor3=iS and T.white or T.textSub},0.18):Play(); d.txt.Font=iS and Enum.Font.GothamBold or Enum.Font.Gotham; d.check.Text=iS and "✓" or "" end
            if onChange then onChange(ci) end
        end)
    end
    local open=false; local CH=HH; local OH=HH+#items*IH+2
    local function setOpen(s)
        open=s; smooth(w,{Size=UDim2.new(1,0,0,s and OH or CH)},0.28):Play(); smooth(arrL,{Rotation=s and 180 or 0},0.22):Play()
        if s then smooth(ws,{Color=T.accentGlow,Transparency=0.05,Thickness=1.4},0.22):Play(); smooth(w,{BackgroundColor3=T.cardHover},0.22):Play()
        else smooth(ws,{Color=T.borderBright,Transparency=0.35,Thickness=1.0},0.22):Play(); smooth(w,{BackgroundColor3=T.card},0.22):Play() end
    end
    hdr.MouseButton1Click:Connect(function() ripple(hdr,hdr.AbsoluteSize.X*0.5,hdr.AbsoluteSize.Y*0.5,T.accent); setOpen(not open) end)
    hdr.MouseEnter:Connect(function() if not open then smooth(w,{BackgroundColor3=T.cardHover},0.14):Play() end end)
    hdr.MouseLeave:Connect(function() if not open then smooth(w,{BackgroundColor3=T.card},0.14):Play() end end)
    return w,function() return sel end
end

-- ===== mkSubTabBar =====
local function mkSubTabBar(parent,tabs)
    local BH=34
    local bc=Instance.new("Frame",parent); bc.Size=UDim2.new(1,0,0,BH); bc.BackgroundColor3=Color3.fromRGB(12,10,21); bc.BorderSizePixel=0; bc.ZIndex=8
    Instance.new("UICorner",bc).CornerRadius=UDim.new(0,10)
    local bcs=Instance.new("UIStroke",bc); bcs.Color=T.borderBright; bcs.Transparency=0.08; bcs.Thickness=1.5
    for i=1,#tabs-1 do local ts=Instance.new("Frame",bc); ts.Size=UDim2.new(0,1,0.5,0); ts.Position=UDim2.new(i/#tabs,0,0.25,0); ts.BackgroundColor3=T.border; ts.BackgroundTransparency=0.25; ts.BorderSizePixel=0; ts.ZIndex=9 end
    local sep=Instance.new("Frame",parent); sep.Size=UDim2.new(1,0,0,1); sep.Position=UDim2.new(0,0,0,BH+2); sep.BackgroundColor3=T.borderBright; sep.BackgroundTransparency=0.2; sep.BorderSizePixel=0; sep.ZIndex=8
    local pill=Instance.new("Frame",bc); pill.Size=UDim2.new(1/#tabs,-6,0,BH-8); pill.Position=UDim2.new(0,3,0,4); pill.BackgroundColor3=T.accent; pill.BorderSizePixel=0; pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(0,7)
    Instance.new("UIGradient",pill).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.accentGlow),ColorSequenceKeypoint.new(1,T.accent)}
    regAccent("bgAccent",pill)
    local sBtns={}; local sPages={}
    local function sw(idx)
        smooth(pill,{Position=UDim2.new((idx-1)/#tabs,3,0,4)},0.26):Play()
        for i2,d in ipairs(sBtns) do smooth(d.lbl,{TextColor3=(i2==idx) and T.white or T.textSub},0.22):Play(); d.sp.Visible=(i2==idx) end
    end
    for i,name in ipairs(tabs) do
        local sb=Instance.new("TextButton",bc); sb.Size=UDim2.new(1/#tabs,0,1,0); sb.Position=UDim2.new((i-1)/#tabs,0,0,0); sb.BackgroundTransparency=1; sb.Text=""; sb.ZIndex=10
        local sl=Instance.new("TextLabel",sb); sl.Size=UDim2.new(1,0,1,0); sl.BackgroundTransparency=1; sl.Text=name; sl.TextColor3=(i==1) and T.white or T.textSub; sl.Font=Enum.Font.GothamBold; sl.TextSize=11; sl.ZIndex=11
        local so=Instance.new("Frame",parent); so.Size=UDim2.new(1,0,1,-BH-4); so.Position=UDim2.new(0,0,0,BH+4); so.BackgroundTransparency=1; so.Visible=(i==1); so.ZIndex=3
        local sf=mkScrollPage(so); sBtns[i]={lbl=sl,sp=so}; sPages[name]=sf
        local ci=i; sb.MouseButton1Click:Connect(function() ripple(sb,sb.AbsoluteSize.X*0.5,sb.AbsoluteSize.Y*0.5,T.white); sw(ci) end)
    end
    return sPages
end

-- ===== EXPOSE =====
_G.YiLib = {
    T=T,
    regAccent=regAccent, applyAccent=applyAccent, applyAccentLive=applyAccentLive,
    smooth=smooth, spring=spring, ease=ease, ripple=ripple,
    mkScrollPage=mkScrollPage, mkGroupBox=mkGroupBox,
    mkSectionLabel=mkSectionLabel, mkSection=mkSection,
    mkCard=mkCard, mkStatus=mkStatus, mkToggle=mkToggle,
    mkSlider=mkSlider, mkOnOffBtn=mkOnOffBtn,
    mkDropdownV2=mkDropdownV2, mkSubTabBar=mkSubTabBar,
}
print("[YiLib] loaded")
