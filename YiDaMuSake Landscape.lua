local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- =====================
-- THEME
-- =====================
local T = {
    bg         = Color3.fromRGB(10, 10, 16),
    surface    = Color3.fromRGB(18, 18, 28),
    card       = Color3.fromRGB(24, 24, 36),
    cardHover  = Color3.fromRGB(30, 30, 44),
    border     = Color3.fromRGB(45, 45, 65),
    accent     = Color3.fromRGB(130, 80, 255),
    accentSoft = Color3.fromRGB(100, 60, 200),
    accentGlow = Color3.fromRGB(160, 100, 255),
    green      = Color3.fromRGB(50, 210, 120),
    greenDim   = Color3.fromRGB(30, 140, 80),
    red        = Color3.fromRGB(220, 65, 85),
    text       = Color3.fromRGB(235, 235, 250),
    textSub    = Color3.fromRGB(145, 145, 180),
    textDim    = Color3.fromRGB(85, 85, 115),
    white      = Color3.fromRGB(255, 255, 255),
}

-- =====================
-- TWEEN HELPERS
-- =====================
local function tw(obj, props, t, style, dir)
    return TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props)
end
local function spring(obj, props, t)
    return tw(obj, props, t or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end
local function smooth(obj, props, t)
    return tw(obj, props, t or 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

-- =====================
-- RIPPLE
-- =====================
local function ripple(parent, x, y, color)
    local ok, pos = pcall(function()
        return Vector2.new(
            x or parent.AbsoluteSize.X / 2,
            y or parent.AbsoluteSize.Y / 2
        )
    end)
    if not ok then return end
    local rip = Instance.new("Frame")
    rip.Size = UDim2.new(0, 0, 0, 0)
    rip.Position = UDim2.new(0, pos.X, 0, pos.Y)
    rip.AnchorPoint = Vector2.new(0.5, 0.5)
    rip.BackgroundColor3 = color or T.white
    rip.BackgroundTransparency = 0.72
    rip.BorderSizePixel = 0
    rip.ZIndex = 50
    rip.Parent = parent
    Instance.new("UICorner", rip).CornerRadius = UDim.new(1, 0)
    local sz = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.4
    local t1 = smooth(rip, {
        Size = UDim2.new(0, sz, 0, sz),
        BackgroundTransparency = 0.88
    }, 0.42)
    t1:Play()
    t1.Completed:Connect(function()
        smooth(rip, {BackgroundTransparency = 1}, 0.18):Play()
        task.wait(0.2)
        rip:Destroy()
    end)
end

-- =====================
-- SCREEN GUI
-- =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YiDaMuSake"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

-- =====================
-- ROOT WINDOW  (landscape: 720 x 420)
-- =====================
local W, H = 720, 420
local root = Instance.new("Frame")
root.Size = UDim2.new(0, W, 0, H)
root.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
root.BackgroundColor3 = T.bg
root.BorderSizePixel = 0
root.ClipsDescendants = false
root.Active = true
root.Parent = screenGui
Instance.new("UICorner", root).CornerRadius = UDim.new(0, 16)

-- Outer glow
local outerGlow = Instance.new("ImageLabel")
outerGlow.Size = UDim2.new(1, 60, 1, 60)
outerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
outerGlow.BackgroundTransparency = 1
outerGlow.Image = "rbxassetid://5028857084"
outerGlow.ImageColor3 = T.accent
outerGlow.ImageTransparency = 0.88
outerGlow.ZIndex = 0
outerGlow.Parent = root

-- Clip inner
local inner = Instance.new("Frame")
inner.Size = UDim2.new(1, 0, 1, 0)
inner.BackgroundTransparency = 1
inner.ClipsDescendants = true
inner.ZIndex = 1
inner.Parent = root

-- BG gradient
local bgGrad = Instance.new("Frame")
bgGrad.Size = UDim2.new(1, 0, 1, 0)
bgGrad.BackgroundColor3 = T.bg
bgGrad.BorderSizePixel = 0
bgGrad.ZIndex = 1
bgGrad.Parent = inner
Instance.new("UICorner", bgGrad).CornerRadius = UDim.new(0, 16)
local grad = Instance.new("UIGradient", bgGrad)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(16, 12, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,  9, 20)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(14, 10, 26)),
}
grad.Rotation = 135
task.spawn(function()
    local r = 135
    while root.Parent do r = r + 0.12; grad.Rotation = r; task.wait(0.05) end
end)

local stroke = Instance.new("UIStroke", root)
stroke.Color = T.border
stroke.Thickness = 1
stroke.Transparency = 0.45

-- =====================
-- DRAG
-- =====================
do
    local dragging, dragStart, startPos = false, nil, nil
    root.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = root.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- =====================
-- SIDEBAR (kiri)  lebar 130px
-- =====================
local SIDE_W = 130

local sidebar = Instance.new("Frame", inner)
sidebar.Size = UDim2.new(0, SIDE_W, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 22)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 5
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 16)

-- kanan sidebar potong sudut
local sideRight = Instance.new("Frame", inner)
sideRight.Size = UDim2.new(0, 16, 1, 0)
sideRight.Position = UDim2.new(0, SIDE_W - 16, 0, 0)
sideRight.BackgroundColor3 = Color3.fromRGB(13, 13, 22)
sideRight.BorderSizePixel = 0
sideRight.ZIndex = 4

-- garis pemisah
local sideLine = Instance.new("Frame", inner)
sideLine.Size = UDim2.new(0, 1, 1, 0)
sideLine.Position = UDim2.new(0, SIDE_W, 0, 0)
sideLine.BackgroundColor3 = T.border
sideLine.BackgroundTransparency = 0.5
sideLine.BorderSizePixel = 0
sideLine.ZIndex = 6

-- =====================
-- LOGO di sidebar
-- =====================
local iconBg = Instance.new("Frame", sidebar)
iconBg.Size = UDim2.new(0, 36, 0, 36)
iconBg.Position = UDim2.new(0.5, 0, 0, 16)
iconBg.AnchorPoint = Vector2.new(0.5, 0)
iconBg.BackgroundColor3 = T.accentSoft
iconBg.BorderSizePixel = 0
iconBg.ZIndex = 7
Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 10)
local iconGrd = Instance.new("UIGradient", iconBg)
iconGrd.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, T.accentGlow),
    ColorSequenceKeypoint.new(1, T.accentSoft),
}
iconGrd.Rotation = 135
local iconImg = Instance.new("ImageLabel", iconBg)
iconImg.Size = UDim2.new(0.78, 0, 0.78, 0)
iconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
iconImg.AnchorPoint = Vector2.new(0.5, 0.5)
iconImg.BackgroundTransparency = 1
iconImg.Image = "rbxassetid://110843044052526"
iconImg.ZIndex = 8

local sideTitleTxt = Instance.new("TextLabel", sidebar)
sideTitleTxt.Size = UDim2.new(1, -8, 0, 16)
sideTitleTxt.Position = UDim2.new(0, 4, 0, 58)
sideTitleTxt.BackgroundTransparency = 1
sideTitleTxt.Text = "Yi Da Mu"
sideTitleTxt.TextColor3 = T.text
sideTitleTxt.Font = Enum.Font.GothamBold
sideTitleTxt.TextSize = 11
sideTitleTxt.ZIndex = 7

local sideSubTxt = Instance.new("TextLabel", sidebar)
sideSubTxt.Size = UDim2.new(1, -8, 0, 12)
sideSubTxt.Position = UDim2.new(0, 4, 0, 75)
sideSubTxt.BackgroundTransparency = 1
sideSubTxt.Text = "sailor piece"
sideSubTxt.TextColor3 = T.textDim
sideSubTxt.Font = Enum.Font.Gotham
sideSubTxt.TextSize = 9
sideSubTxt.ZIndex = 7

-- =====================
-- SIDEBAR NAV BUTTONS
-- =====================
-- Tab kiri: Info (0), Main (1), UI Settings (2)
local SIDE_TABS = {
    {icon = "☰", label = "Info"},
    {icon = "⚡", label = "Main"},
    {icon = "⚙", label = "Settings"},
}
local sideTabBtns = {}
local activeSideTab = 2  -- default Main

-- pill aktif di sidebar
local sidePill = Instance.new("Frame", sidebar)
sidePill.Size = UDim2.new(1, -12, 0, 34)
sidePill.Position = UDim2.new(0, 6, 0, 95 + (activeSideTab-1)*40)
sidePill.BackgroundColor3 = T.accent
sidePill.BorderSizePixel = 0
sidePill.ZIndex = 6
Instance.new("UICorner", sidePill).CornerRadius = UDim.new(0, 9)
local spGrad = Instance.new("UIGradient", sidePill)
spGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, T.accentGlow),
    ColorSequenceKeypoint.new(1, T.accentSoft),
}
spGrad.Rotation = 135

for i, data in ipairs(SIDE_TABS) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.Position = UDim2.new(0, 6, 0, 95 + (i-1)*40)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 8

    local iconL = Instance.new("TextLabel", btn)
    iconL.Size = UDim2.new(0, 22, 1, 0)
    iconL.Position = UDim2.new(0, 8, 0, 0)
    iconL.BackgroundTransparency = 1
    iconL.Text = data.icon
    iconL.TextColor3 = i == activeSideTab and T.white or T.textDim
    iconL.Font = Enum.Font.GothamBold
    iconL.TextSize = 13
    iconL.ZIndex = 9

    local nameL = Instance.new("TextLabel", btn)
    nameL.Size = UDim2.new(1, -34, 1, 0)
    nameL.Position = UDim2.new(0, 32, 0, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = data.label
    nameL.TextColor3 = i == activeSideTab and T.white or T.textDim
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 11
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.ZIndex = 9

    sideTabBtns[i] = {btn = btn, icon = iconL, name = nameL}

    btn.MouseButton1Click:Connect(function()
        ripple(btn, btn.AbsoluteSize.X*0.5, btn.AbsoluteSize.Y*0.5, T.accent)
        -- akan diset oleh switchSideTab
        _G._switchSideTab(i)
    end)
end

-- =====================
-- WINDOW BUTTONS (top-right)
-- =====================
local winBtnArea = Instance.new("Frame", inner)
winBtnArea.Size = UDim2.new(0, 70, 0, 30)
winBtnArea.Position = UDim2.new(1, -76, 0, 8)
winBtnArea.BackgroundTransparency = 1
winBtnArea.ZIndex = 20

local function makeWinBtn(posX, bg, symbol)
    local btn = Instance.new("TextButton", winBtnArea)
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(0, posX, 0.5, 0)
    btn.AnchorPoint = Vector2.new(0, 0.5)
    btn.BackgroundColor3 = bg
    btn.Text = symbol
    btn.TextColor3 = T.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.ZIndex = 21
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.MouseEnter:Connect(function()  smooth(btn, {BackgroundTransparency = 0.3}, 0.15):Play() end)
    btn.MouseLeave:Connect(function() smooth(btn, {BackgroundTransparency = 0},   0.15):Play() end)
    return btn
end

local minBtn   = makeWinBtn(0,  Color3.fromRGB(200, 150, 30), "-")
local closeBtn = makeWinBtn(28, Color3.fromRGB(210, 55, 70),  "x")

local minimized = false
closeBtn.MouseButton1Click:Connect(function()
    smooth(root, {Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 1}, 0.28):Play()
    task.wait(0.3); screenGui:Destroy()
end)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    smooth(root, {Size = UDim2.new(0, minimized and SIDE_W or W, 0, minimized and 40 or H)}, 0.32):Play()
end)

-- =====================
-- CONTENT AREA (kanan sidebar)
-- =====================
local contentX = SIDE_W + 8

local contentArea = Instance.new("Frame", inner)
contentArea.Size = UDim2.new(1, -(SIDE_W + 12), 1, -8)
contentArea.Position = UDim2.new(0, SIDE_W + 4, 0, 4)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = false
contentArea.ZIndex = 4

-- =====================
-- HELPER: make scrolling page
-- =====================
local function makePage(parent)
    local sf = Instance.new("ScrollingFrame", parent)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2
    sf.ScrollBarImageColor3 = T.accent
    sf.ScrollBarImageTransparency = 0.6
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    sf.ZIndex = 4
    local ul = Instance.new("UIListLayout", sf)
    ul.Padding = UDim.new(0, 5)
    ul.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", sf)
    pad.PaddingRight = UDim.new(0, 4)
    return sf
end

-- =====================
-- COMPONENT LIBRARY
-- =====================
local function makeSection(parent, label, order)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 16)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = label
    t.TextColor3 = T.textDim
    t.Font = Enum.Font.GothamBold
    t.TextSize = 9
    t.TextXAlignment = Enum.TextXAlignment.Left
    return f
end

local function makeCard(parent, h, order)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, 0, 0, h or 46)
    c.BackgroundColor3 = T.card
    c.BorderSizePixel = 0
    c.LayoutOrder = order or 0
    c.ClipsDescendants = true
    c.ZIndex = 5
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 10)
    local cs = Instance.new("UIStroke", c)
    cs.Color = T.border; cs.Transparency = 0.6
    local cg = Instance.new("UIGradient", c)
    cg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 28, 44)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 18, 32)),
    }
    cg.Rotation = 135
    c.MouseEnter:Connect(function() smooth(c, {BackgroundColor3 = T.cardHover}, 0.18):Play() end)
    c.MouseLeave:Connect(function() smooth(c, {BackgroundColor3 = T.card}, 0.18):Play() end)
    return c
end

local function makeToggle(parent, label, default, onChange, order)
    local card = makeCard(parent, 44, order)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -68, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = T.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6

    local track = Instance.new("Frame", card)
    track.Size = UDim2.new(0, 38, 0, 22)
    track.Position = UDim2.new(1, -48, 0.5, 0)
    track.AnchorPoint = Vector2.new(0, 0.5)
    track.BackgroundColor3 = T.border
    track.BorderSizePixel = 0; track.ZIndex = 6
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(0, 3, 0.5, 0)
    thumb.AnchorPoint = Vector2.new(0, 0.5)
    thumb.BackgroundColor3 = T.white
    thumb.BorderSizePixel = 0; thumb.ZIndex = 7
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local value = default or false
    local function apply(v)
        value = v
        smooth(track, {BackgroundColor3 = v and T.accent or T.border}, 0.22):Play()
        smooth(thumb, {Position = UDim2.new(v and 1 or 0, v and -19 or 3, 0.5, 0)}, 0.22):Play()
        if onChange then onChange(v) end
    end
    apply(value)

    local hit = Instance.new("TextButton", card)
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 10
    hit.MouseButton1Click:Connect(function()
        ripple(card, card.AbsoluteSize.X*0.5, card.AbsoluteSize.Y*0.5, T.accent)
        spring(thumb, {Size = UDim2.new(0, 20, 0, 16)}, 0.18):Play()
        task.delay(0.12, function() spring(thumb, {Size = UDim2.new(0, 16, 0, 16)}, 0.2):Play() end)
        apply(not value)
    end)
    return card, apply, function() return value end
end

local function makeSlider(parent, label, min, max, default, suffix, onChange, order)
    local card = makeCard(parent, 60, order)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.58, 0, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = T.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size = UDim2.new(0.42, -12, 0, 22)
    valLbl.Position = UDim2.new(0.58, 0, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = T.accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 6

    local trackBg = Instance.new("Frame", card)
    trackBg.Size = UDim2.new(1, -24, 0, 4)
    trackBg.Position = UDim2.new(0, 12, 0, 38)
    trackBg.BackgroundColor3 = T.border
    trackBg.BorderSizePixel = 0; trackBg.ZIndex = 6
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", trackBg)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = T.accent
    fill.BorderSizePixel = 0; fill.ZIndex = 7
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local fg = Instance.new("UIGradient", fill)
    fg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, T.accentGlow),
        ColorSequenceKeypoint.new(1, T.accent),
    }

    local knob = Instance.new("Frame", trackBg)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = T.white
    knob.BorderSizePixel = 0; knob.ZIndex = 8
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", knob)
    ks.Color = T.accent; ks.Thickness = 2

    local value = math.clamp(default or min, min, max)
    local dragging = false

    local function setVal(v)
        value = math.clamp(math.floor(v + 0.5), min, max)
        local r = (value - min) / (max - min)
        valLbl.Text = tostring(value) .. (suffix or "")
        smooth(fill,  {Size     = UDim2.new(r, 0, 1, 0)},   0.1):Play()
        smooth(knob,  {Position = UDim2.new(r, 0, 0.5, 0)}, 0.1):Play()
        if onChange then onChange(value) end
    end
    setVal(value)

    local sliderHit = Instance.new("TextButton", card)
    sliderHit.Size = UDim2.new(1, -24, 0, 22)
    sliderHit.Position = UDim2.new(0, 12, 0, 30)
    sliderHit.BackgroundTransparency = 1; sliderHit.Text = ""; sliderHit.ZIndex = 12

    sliderHit.MouseButton1Down:Connect(function()
        dragging = true
        spring(knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.2):Play()
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local r = math.clamp((i.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
            setVal(min + r * (max - min))
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then dragging = false; spring(knob, {Size = UDim2.new(0, 12, 0, 12)}, 0.25):Play() end
        end
    end)
    return card, setVal, function() return value end
end

local function makeDropdown(parent, label, items, default, onChange, order)
    local card = makeCard(parent, 44, order)
    card.ClipsDescendants = false

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.42, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = T.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6

    local selBtn = Instance.new("TextButton", card)
    selBtn.Size = UDim2.new(0, 148, 0, 28)
    selBtn.Position = UDim2.new(1, -158, 0.5, 0)
    selBtn.AnchorPoint = Vector2.new(0, 0.5)
    selBtn.BackgroundColor3 = T.surface
    selBtn.Text = ""; selBtn.BorderSizePixel = 0; selBtn.ZIndex = 10
    Instance.new("UICorner", selBtn).CornerRadius = UDim.new(0, 8)
    local ss = Instance.new("UIStroke", selBtn); ss.Color = T.border; ss.Transparency = 0.4

    local selLbl = Instance.new("TextLabel", selBtn)
    selLbl.Size = UDim2.new(1, -26, 1, 0)
    selLbl.Position = UDim2.new(0, 8, 0, 0)
    selLbl.BackgroundTransparency = 1
    selLbl.TextColor3 = T.text
    selLbl.Font = Enum.Font.GothamBold
    selLbl.TextSize = 10
    selLbl.TextXAlignment = Enum.TextXAlignment.Left
    selLbl.ZIndex = 11

    local arrowLbl = Instance.new("TextLabel", selBtn)
    arrowLbl.Size = UDim2.new(0, 16, 1, 0)
    arrowLbl.Position = UDim2.new(1, -18, 0, 0)
    arrowLbl.BackgroundTransparency = 1
    arrowLbl.Text = "v"; arrowLbl.TextColor3 = T.textSub
    arrowLbl.Font = Enum.Font.GothamBold; arrowLbl.TextSize = 10; arrowLbl.ZIndex = 11

    local selected = default or items[1]
    selLbl.Text = selected

    local open = false
    local dropF = nil

    local function closeDrop()
        if dropF then
            smooth(dropF, {Size = UDim2.new(0, 148, 0, 0)}, 0.2):Play()
            smooth(arrowLbl, {Rotation = 0}, 0.2):Play()
            task.wait(0.22)
            if dropF then dropF:Destroy(); dropF = nil end
        end
        open = false
    end

    local function openDrop()
        open = true
        smooth(arrowLbl, {Rotation = 180}, 0.2):Play()
        dropF = Instance.new("Frame", screenGui)
        dropF.Size = UDim2.new(0, 148, 0, 0)
        dropF.Position = UDim2.new(0,
            selBtn.AbsolutePosition.X,
            0,
            selBtn.AbsolutePosition.Y + selBtn.AbsoluteSize.Y + 4)
        dropF.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
        dropF.BorderSizePixel = 0; dropF.ClipsDescendants = true; dropF.ZIndex = 100
        Instance.new("UICorner", dropF).CornerRadius = UDim.new(0, 10)
        local ds = Instance.new("UIStroke", dropF); ds.Color = T.border; ds.Transparency = 0.4
        Instance.new("UIListLayout", dropF).Padding = UDim.new(0, 2)
        local dp = Instance.new("UIPadding", dropF)
        dp.PaddingTop = UDim.new(0, 4); dp.PaddingBottom = UDim.new(0, 4)
        dp.PaddingLeft = UDim.new(0, 4); dp.PaddingRight = UDim.new(0, 4)

        for _, item in ipairs(items) do
            local ib = Instance.new("TextButton", dropF)
            ib.Size = UDim2.new(1, 0, 0, 28)
            ib.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
            ib.BackgroundTransparency = 1
            ib.Text = item
            ib.TextColor3 = item == selected and T.accent or T.text
            ib.Font = Enum.Font.GothamBold; ib.TextSize = 10; ib.ZIndex = 101
            Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 7)
            ib.MouseEnter:Connect(function()
                smooth(ib, {BackgroundTransparency = 0.7, BackgroundColor3 = T.accent}, 0.14):Play()
                smooth(ib, {TextColor3 = T.white}, 0.14):Play()
            end)
            ib.MouseLeave:Connect(function()
                smooth(ib, {BackgroundTransparency = 1}, 0.14):Play()
                smooth(ib, {TextColor3 = item==selected and T.accent or T.text}, 0.14):Play()
            end)
            ib.MouseButton1Click:Connect(function()
                selected = item; selLbl.Text = item
                if onChange then onChange(item) end
                closeDrop()
            end)
        end

        local th = math.min(#items * 32 + 8, 180)
        smooth(dropF, {Size = UDim2.new(0, 148, 0, th)}, 0.24):Play()
    end

    selBtn.MouseButton1Click:Connect(function()
        ripple(selBtn, selBtn.AbsoluteSize.X*0.5, selBtn.AbsoluteSize.Y*0.5, T.accent)
        if open then closeDrop() else openDrop() end
    end)
    selBtn.MouseEnter:Connect(function() smooth(selBtn, {BackgroundColor3 = T.cardHover}, 0.15):Play() end)
    selBtn.MouseLeave:Connect(function() smooth(selBtn, {BackgroundColor3 = T.surface}, 0.15):Play() end)
    return card, function() return selected end
end

local function makeStatus(parent, prefix, initText, order)
    local card = makeCard(parent, 36, order)
    card.BackgroundColor3 = Color3.fromRGB(16, 16, 26)

    local pfx = Instance.new("TextLabel", card)
    pfx.Size = UDim2.new(0, 55, 1, 0)
    pfx.Position = UDim2.new(0, 10, 0, 0)
    pfx.BackgroundTransparency = 1
    pfx.Text = prefix; pfx.TextColor3 = T.textDim
    pfx.Font = Enum.Font.GothamBold; pfx.TextSize = 10
    pfx.TextXAlignment = Enum.TextXAlignment.Left; pfx.ZIndex = 6

    local val = Instance.new("TextLabel", card)
    val.Size = UDim2.new(1, -70, 1, 0)
    val.Position = UDim2.new(0, 65, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = initText or "—"; val.TextColor3 = T.textSub
    val.Font = Enum.Font.Gotham; val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Left; val.ZIndex = 6

    local function set(text, color)
        val.Text = text
        if color then smooth(val, {TextColor3 = color}, 0.2):Play() end
    end
    return card, set
end

local function makeActionBtn(parent, label, color, onClick, order)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = color or T.accent
    btn.Text = ""; btn.BorderSizePixel = 0
    btn.LayoutOrder = order or 0; btn.ZIndex = 6
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local bg = Instance.new("UIGradient", btn)
    bg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(210,210,210)),
    }
    bg.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.18),
        NumberSequenceKeypoint.new(1, 0.32),
    }
    bg.Rotation = 90

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = T.white
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.ZIndex = 7

    btn.MouseButton1Down:Connect(function()
        smooth(btn, {BackgroundTransparency = 0.12, Size = UDim2.new(0.97,0,0,34)}, 0.12):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        smooth(btn, {BackgroundTransparency = 0, Size = UDim2.new(1,0,0,38)}, 0.2):Play()
    end)
    btn.MouseLeave:Connect(function() smooth(btn, {Size = UDim2.new(1,0,0,38)}, 0.18):Play() end)
    btn.MouseButton1Click:Connect(function()
        ripple(btn, btn.AbsoluteSize.X*0.5, btn.AbsoluteSize.Y*0.5, T.white)
        if onClick then onClick() end
    end)
    local function setLabel(t) lbl.Text = t end
    local function setColor(c) smooth(btn, {BackgroundColor3 = c}, 0.22):Play() end
    return btn, setLabel, setColor
end

-- =====================
-- SIDE TAB PAGES
-- =====================
-- 3 halaman utama untuk sidebar: Info(1), Main(2), Settings(3)
local sidePages = {}
for i = 1, 3 do
    local pg = Instance.new("Frame", contentArea)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.Visible = i == activeSideTab
    pg.ZIndex = 4
    sidePages[i] = pg
end

-- =====================
-- PAGE 2 (Main): sub-tab Farm/Quest/Hit
-- =====================
local mainPage = sidePages[2]

-- Sub-tab bar di atas mainPage
local SUB_TABS = {"Farm", "Quest", "Hit"}
local subTabBtns = {}
local subPages = {}
local activeSubTab = 1

local subBar = Instance.new("Frame", mainPage)
subBar.Size = UDim2.new(1, 0, 0, 30)
subBar.BackgroundColor3 = T.surface
subBar.BorderSizePixel = 0; subBar.ZIndex = 5
Instance.new("UICorner", subBar).CornerRadius = UDim.new(0, 9)
local subStroke = Instance.new("UIStroke", subBar)
subStroke.Color = T.border; subStroke.Transparency = 0.5

local subPill = Instance.new("Frame", subBar)
subPill.Size = UDim2.new(1/3, -6, 1, -6)
subPill.Position = UDim2.new(0, 3, 0, 3)
subPill.BackgroundColor3 = T.accent
subPill.BorderSizePixel = 0; subPill.ZIndex = 6
Instance.new("UICorner", subPill).CornerRadius = UDim.new(0, 7)
local spg = Instance.new("UIGradient", subPill)
spg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, T.accentGlow),
    ColorSequenceKeypoint.new(1, T.accentSoft),
}
spg.Rotation = 90

for i, name in ipairs(SUB_TABS) do
    local btn = Instance.new("TextButton", subBar)
    btn.Size = UDim2.new(1/3, 0, 1, 0)
    btn.Position = UDim2.new((i-1)/3, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = i == 1 and T.white or T.textDim
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.ZIndex = 7
    subTabBtns[i] = btn

    -- sub-pages
    local sf = makePage(mainPage)
    sf.Size = UDim2.new(1, 0, 1, -36)
    sf.Position = UDim2.new(0, 0, 0, 36)
    sf.Visible = i == 1
    subPages[i] = sf

    btn.MouseButton1Click:Connect(function()
        ripple(subBar,
            btn.AbsolutePosition.X - subBar.AbsolutePosition.X + btn.AbsoluteSize.X*0.5,
            subBar.AbsoluteSize.Y*0.5, T.accent)
        activeSubTab = i
        smooth(subPill, {Position = UDim2.new((i-1)/3, 3, 0, 3)}, 0.28):Play()
        for j, b in ipairs(subTabBtns) do
            smooth(b, {TextColor3 = j==i and T.white or T.textDim}, 0.2):Play()
        end
        for j, sp in ipairs(subPages) do sp.Visible = j == i end
    end)
end

-- =====================
-- SUB-PAGE 1: FARM
-- =====================
local farmPage = subPages[1]
makeSection(farmPage, "ISLAND", 1)
local _, getIsland = makeDropdown(farmPage, "Pulau",
    {"Starter Island","Jungle Island","Desert Island","Snow Island","Shibuya","Hollow","Curse"},
    "Starter Island", nil, 2)

makeSection(farmPage, "MOVEMENT", 3)
local _, setHeight, getHeight   = makeSlider(farmPage, "Height Offset",  0,   50, 0,   " st",   nil, 4)
local _, setSpeed,  getSpeed    = makeSlider(farmPage, "Tween Speed",    20, 500, 150, " st/s", nil, 5)
local _, setTDelay, getTDelay   = makeSlider(farmPage, "Jeda per Titik", 1,   10, 1,   "s",     nil, 6)
local _, setLDelay, getLDelay   = makeSlider(farmPage, "Loop Delay",     0,   10, 3,   "s",     nil, 7)

makeSection(farmPage, "STATUS", 8)
local _, setFarmStat  = makeStatus(farmPage, "Status", "Idle",  9)
local _, setFarmPhase = makeStatus(farmPage, "Phase",  "—",    10)

makeSection(farmPage, "CONTROLS", 11)
local v1Btn, setV1Lbl, setV1Color = makeActionBtn(farmPage, "Auto Farm V1  (Semua Titik)",  T.accentSoft,                      nil, 12)
local v2Btn, setV2Lbl, setV2Color = makeActionBtn(farmPage, "Auto Farm V2  (Titik Tengah)", Color3.fromRGB(75,55,175), nil, 13)

-- =====================
-- SUB-PAGE 2: QUEST
-- =====================
local questPage = subPages[2]
makeSection(questPage, "DETECTION", 1)
local _, setQR, getQRadius = makeSlider(questPage, "Radius", 10, 200, 50, " st", nil, 2)

makeSection(questPage, "STATUS", 3)
local _, setQNPC  = makeStatus(questPage, "NPC",  "—", 4)
local _, setQLast = makeStatus(questPage, "Last", "—", 5)

makeSection(questPage, "CONTROLS", 6)
local qBtn, setQLbl, setQColor = makeActionBtn(questPage, "Auto Quest", T.accentSoft, nil, 7)

-- =====================
-- SUB-PAGE 3: HIT
-- =====================
local hitPage = subPages[3]
makeSection(hitPage, "SETTINGS", 1)
local _, setCI, getClickInt = makeSlider(hitPage, "Interval", 50, 1000, 100, "ms", nil, 2)

makeSection(hitPage, "STATUS", 3)
local _, setHitStat = makeStatus(hitPage, "Status", "Idle", 4)

makeSection(hitPage, "CONTROLS", 5)
local hBtn, setHLbl, setHColor = makeActionBtn(hitPage, "Auto Hit", T.accentSoft, nil, 6)

-- =====================
-- PAGE 1 (Info)
-- =====================
local infoPage = sidePages[1]
local infoSF = makePage(infoPage)
infoSF.Size = UDim2.new(1, 0, 1, 0)
infoSF.Visible = true

makeSection(infoSF, "ABOUT", 1)
makeStatus(infoSF, "Script",   "Yi Da Mu Sake",    2)
makeStatus(infoSF, "Version",  "sailor piece",     3)
makeStatus(infoSF, "UI",       "Custom / No lib",  4)
makeStatus(infoSF, "Layout",   "Landscape v2",     5)

makeSection(infoSF, "CONTACT", 6)
makeStatus(infoSF, "Author",   "YiDaMu",           7)
makeStatus(infoSF, "Game",     "Blox Fruits",      8)

-- =====================
-- PAGE 3 (UI Settings)
-- =====================
local settingsPage = sidePages[3]
local settingsSF = makePage(settingsPage)
settingsSF.Size = UDim2.new(1, 0, 1, 0)
settingsSF.Visible = true

makeSection(settingsSF, "DISPLAY", 1)
local _, setGlow, getGlow = makeToggle(settingsSF, "Outer Glow",       true,  function(v) outerGlow.Visible = v end, 2)
local _, setAnim, getAnim = makeToggle(settingsSF, "BG Rotation",      true,  nil, 3)
local _, setBotP, getBotP = makeToggle(settingsSF, "Show Status Bar",  true,  nil, 4)

makeSection(settingsSF, "THEME COLOR", 5)
local _, setTC, getTC = makeDropdown(settingsSF, "Accent",
    {"Purple","Blue","Green","Red","Orange"},
    "Purple",
    function(v)
        local map = {
            Purple = Color3.fromRGB(130,80,255),
            Blue   = Color3.fromRGB(60,130,255),
            Green  = Color3.fromRGB(50,200,120),
            Red    = Color3.fromRGB(220,65,85),
            Orange = Color3.fromRGB(255,140,50),
        }
        if map[v] then
            T.accent = map[v]
            smooth(sidePill, {BackgroundColor3 = map[v]}, 0.3):Play()
            smooth(subPill,  {BackgroundColor3 = map[v]}, 0.3):Play()
            smooth(outerGlow,{ImageColor3      = map[v]}, 0.3):Play()
            smooth(stroke,   {Color            = map[v]}, 0.3):Play()
        end
    end, 6)

-- =====================
-- SWITCH SIDE TAB
-- =====================
function _G._switchSideTab(idx)
    activeSideTab = idx
    -- pill
    smooth(sidePill, {Position = UDim2.new(0, 6, 0, 95 + (idx-1)*40)}, 0.28):Play()
    -- button colors
    for i, d in ipairs(sideTabBtns) do
        smooth(d.icon, {TextColor3 = i==idx and T.white or T.textDim}, 0.2):Play()
        smooth(d.name, {TextColor3 = i==idx and T.white or T.textDim}, 0.2):Play()
    end
    -- pages
    for i, pg in ipairs(sidePages) do pg.Visible = i == idx end
end

-- =====================
-- BOTTOM STATUS BAR
-- =====================
local botBar = Instance.new("Frame", inner)
botBar.Size = UDim2.new(1, -SIDE_W, 0, 24)
botBar.Position = UDim2.new(0, SIDE_W, 1, -24)
botBar.BackgroundColor3 = T.surface
botBar.BorderSizePixel = 0; botBar.ZIndex = 5

local verLbl = Instance.new("TextLabel", botBar)
verLbl.Size = UDim2.new(0.5, 0, 1, 0)
verLbl.Position = UDim2.new(0, 10, 0, 0)
verLbl.BackgroundTransparency = 1
verLbl.Text = "sailor piece"
verLbl.TextColor3 = T.textDim
verLbl.Font = Enum.Font.Gotham; verLbl.TextSize = 9
verLbl.TextXAlignment = Enum.TextXAlignment.Left; verLbl.ZIndex = 6

local dotLbl = Instance.new("TextLabel", botBar)
dotLbl.Size = UDim2.new(0.5, -10, 1, 0)
dotLbl.Position = UDim2.new(0.5, 0, 0, 0)
dotLbl.BackgroundTransparency = 1
dotLbl.Text = "* online"
dotLbl.TextColor3 = T.green
dotLbl.Font = Enum.Font.GothamBold; dotLbl.TextSize = 9
dotLbl.TextXAlignment = Enum.TextXAlignment.Right; dotLbl.ZIndex = 6

task.spawn(function()
    while dotLbl.Parent do
        smooth(dotLbl, {TextColor3 = T.green},    0.7):Play(); task.wait(0.8)
        smooth(dotLbl, {TextColor3 = T.greenDim}, 0.7):Play(); task.wait(0.8)
    end
end)

-- =====================
-- ENTRANCE ANIMATION
-- =====================
root.BackgroundTransparency = 1
root.Size = UDim2.new(0, W, 0, 0)
root.Position = UDim2.new(0.5, -W/2, 0.5, -H/4)
task.wait(0.06)
spring(root, {
    Size = UDim2.new(0, W, 0, H),
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
}, 0.55):Play()

-- =====================
-- EXPOSE
-- =====================
_G.YiUI = {
    getIsland   = getIsland,
    getHeight   = getHeight,
    getSpeed    = getSpeed,
    getTDelay   = getTDelay,
    getLDelay   = getLDelay,
    getQRadius  = getQRadius,
    getClickInt = getClickInt,
    setFarmStat  = setFarmStat,
    setFarmPhase = setFarmPhase,
    setQNPC      = setQNPC,
    setQLast     = setQLast,
    setHitStat   = setHitStat,
    v1Btn = v1Btn, setV1Lbl = setV1Lbl, setV1Color = setV1Color,
    v2Btn = v2Btn, setV2Lbl = setV2Lbl, setV2Color = setV2Color,
    qBtn  = qBtn,  setQLbl  = setQLbl,  setQColor  = setQColor,
    hBtn  = hBtn,  setHLbl  = setHLbl,  setHColor  = setHColor,
}

print("Yi Da Mu Sake UI (Landscape) ready")
