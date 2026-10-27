--!strict
-- NoirUI v1.0 — Reusable Roblox UI Library
-- Single file, no dependencies. Copy & use.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--============================================================
-- THEME (đổi ở đây là đổi toàn bộ)
--============================================================
local Theme = {
    -- Colors
    Accent        = Color3.fromRGB(140, 80, 255),
    AccentDark    = Color3.fromRGB(90, 40, 180),
    Background    = Color3.fromRGB(18, 18, 22),
    Surface       = Color3.fromRGB(28, 28, 34),
    SurfaceHover  = Color3.fromRGB(38, 38, 46),
    Border        = Color3.fromRGB(45, 45, 55),
    Text          = Color3.fromRGB(240, 240, 245),
    TextDim       = Color3.fromRGB(150, 150, 165),
    Danger        = Color3.fromRGB(240, 70, 90),

    -- Shape
    CornerRadius  = UDim.new(0, 8),
    CornerLarge   = UDim.new(0, 12),
    Padding       = 10,
    RowHeight     = 32,

    -- Fonts
    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold,

    -- Animation
    TweenFast     = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TweenNormal   = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

--============================================================
-- HELPERS
--============================================================
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.CornerRadius
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function Pad(parent, all, extra)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, all)
    p.PaddingBottom = UDim.new(0, all)
    p.PaddingLeft   = UDim.new(0, all)
    p.PaddingRight  = UDim.new(0, all)
    if extra then
        if extra.Top then p.PaddingTop = UDim.new(0, extra.Top) end
        if extra.Left then p.PaddingLeft = UDim.new(0, extra.Left) end
        if extra.Right then p.PaddingRight = UDim.new(0, extra.Right) end
        if extra.Bottom then p.PaddingBottom = UDim.new(0, extra.Bottom) end
    end
    p.Parent = parent
    return p
end

local function ListLayout(parent, padding)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--============================================================
-- NOIRUI CLASS
--============================================================
local NoirUI = {}
NoirUI.__index = NoirUI

function NoirUI.new(opts)
    opts = opts or {}
    local self = setmetatable({}, NoirUI)

    self.Title      = opts.Title or "Noir UI"
    self.Subtitle   = opts.Subtitle or nil
    self.Size       = opts.Size or UDim2.new(0, 320, 0, 420)
    self.ToggleKey  = opts.ToggleKey or Enum.KeyCode.RightShift
    self.Components = {}
    self.Tabs       = {}
    self.ActiveTab  = nil

    self:_build()
    return self
end

function NoirUI:_build()
    local parent = (pcall(function() return CoreGui end) and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "NoirUI_" .. self.Title
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = parent
    self.Gui = gui

    -- Main window
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = self.Size
    main.Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.Parent = gui
    Corner(main, Theme.CornerLarge)
    Stroke(main, Theme.Accent, 1.5)
    self.Main = main

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = Theme.Surface
    header.BorderSizePixel = 0
    header.Parent = main
    Corner(header, Theme.CornerLarge)
    -- chỉ bo góc trên
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 12)
    headerFix.Position = UDim2.new(0, 0, 1, -12)
    headerFix.BackgroundColor3 = Theme.Surface
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.TextColor3 = Theme.Text
    title.Font = Theme.FontBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0, 18)
    accentBar.Position = UDim2.new(0, 8, 0.5, -9)
    accentBar.BackgroundColor3 = Theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = header
    Corner(accentBar, UDim.new(1, 0))

    title.Position = UDim2.new(0, 18, 0, 0)

    -- Minimize & Close
    local function headerBtn(text, xOffset, color)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 26, 0, 26)
        b.Position = UDim2.new(1, xOffset, 0.5, -13)
        b.BackgroundColor3 = Theme.SurfaceHover
        b.Text = text
        b.TextColor3 = color or Theme.TextDim
        b.Font = Theme.FontBold
        b.TextSize = 16
        b.AutoButtonColor = false
        b.Parent = header
        Corner(b, UDim.new(1, 0))
        return b
    end

    local closeBtn = headerBtn("×", -34, Theme.TextDim)
    local minBtn   = headerBtn("–", -66, Theme.TextDim)

    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Theme.Danger end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Theme.TextDim end)
    minBtn.MouseEnter:Connect(function() minBtn.TextColor3 = Theme.Accent end)
    minBtn.MouseLeave:Connect(function() minBtn.TextColor3 = Theme.TextDim end)

    closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)

    self.Minimized = false
    minBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        local targetSize = self.Minimized
            and UDim2.new(0, self.Size.X.Offset, 0, 42)
            or self.Size
        TweenService:Create(main, Theme.TweenNormal, { Size = targetSize }):Play()
        minBtn.Text = self.Minimized and "+" or "–"
    end)

    MakeDraggable(main, header)

    -- Content container (chứa tab bar + tab content)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -42)
    content.Position = UDim2.new(0, 0, 0, 42)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.Content = content

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -20, 0, 32)
    tabBar.Position = UDim2.new(0, 10, 0, 10)
    tabBar.BackgroundColor3 = Theme.Surface
    tabBar.BorderSizePixel = 0
    tabBar.Parent = content
    Corner(tabBar)
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabBar
    Pad(tabBar, 4)

    self.TabBar = tabBar

    -- Tab content holder
    local tabHolder = Instance.new("Frame")
    tabHolder.Name = "TabHolder"
    tabHolder.Size = UDim2.new(1, -20, 1, -52)
    tabHolder.Position = UDim2.new(0, 10, 0, 50)
    tabHolder.BackgroundTransparency = 1
    tabHolder.Parent = content
    self.TabHolder = tabHolder

    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)

    -- Intro animation
    main.BackgroundTransparency = 1
    task.spawn(function()
        TweenService:Create(main, Theme.TweenNormal, { BackgroundTransparency = 0 }):Play()
    end)
end

function NoirUI:Toggle()
    self.Gui.Enabled = not self.Gui.Enabled
end

function NoirUI:Tab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, 0)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = Theme.Background
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.FontBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = self.TabBar
    Corner(btn)
    Pad(btn, 0, { Left = 14, Right = 14 })

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = self.TabHolder
    page.Visible = false
    ListLayout(page, 6)

    local tab = {
        Name = name, Button = btn, Page = page, Container = page,
        _ui = self,
    }

    -- Tab methods sẽ được gắn ở dưới
    setmetatable(tab, { __index = TabMethods })

    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    return tab
end

function NoirUI:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Page.Visible = (t == tab)
        TweenService:Create(t.Button, Theme.TweenFast, {
            TextColor3 = (t == tab) and Theme.Text or Theme.TextDim,
            BackgroundTransparency = (t == tab) and 0 or 1,
        }):Play()
        t.Button.BackgroundColor3 = Theme.SurfaceHover
    end
    self.ActiveTab = tab
end

function NoirUI:Destroy()
    if self.Gui then
        self.Gui:Destroy()
    end
end

--============================================================
-- TAB METHODS (Section, Toggle, Slider, Input, ColorPicker)
--============================================================
TabMethods = {}
TabMethods.__index = TabMethods

function TabMethods:Section(title)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundTransparency = 1
    holder.Parent = self.Container
    ListLayout(holder, 6)
    Pad(holder, 0, { Top = 6, Bottom = 4 })

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -4, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(title)
    lbl.TextColor3 = Theme.Accent
    lbl.Font = Theme.FontBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    -- Container cho các component bên trong section
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1, 0, 0, 0)
    inner.AutomaticSize = Enum.AutomaticSize.Y
    inner.BackgroundTransparency = 1
    inner.Parent = holder
    ListLayout(inner, 5)

    self._activeSection = inner
    return inner
end

local function getSection(self)
    return self._activeSection or self.Container
end

-- Toggle
function TabMethods:Toggle(label, default, callback)
    local parent = getSection(self)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
    row.BackgroundColor3 = Theme.Surface
    row.BorderSizePixel = 0
    row.Parent = parent
    Corner(row)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Theme.Font
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Toggle switch
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -50, 0.5, -10)
    track.BackgroundColor3 = default and Theme.Accent or Theme.SurfaceHover
    track.BorderSizePixel = 0
    track.Parent = row
    Corner(track, UDim.new(1, 0))
    Stroke(track, Theme.Border)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default
        and UDim2.new(1, -18, 0.5, -8)
        or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    Corner(knob, UDim.new(1, 0))

    local clickable = Instance.new("TextButton")
    clickable.Size = UDim2.new(1, 0, 1, 0)
    clickable.BackgroundTransparency = 1
    clickable.Text = ""
    clickable.Parent = row

    local state = default
    local function set(v)
        state = v
        TweenService:Create(track, Theme.TweenFast, {
            BackgroundColor3 = v and Theme.Accent or Theme.SurfaceHover
        }):Play()
        TweenService:Create(knob, Theme.TweenFast, {
            Position = v
                and UDim2.new(1, -18, 0.5, -8)
                or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if callback then callback(v) end
    end

    clickable.MouseButton1Click:Connect(function() set(not state) end)
    row.MouseEnter:Connect(function()
        TweenService:Create(row, Theme.TweenFast, { BackgroundColor3 = Theme.SurfaceHover }):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, Theme.TweenFast, { BackgroundColor3 = Theme.Surface }):Play()
    end)

    return { Set = set, Get = function() return state end }
end

-- Slider
function TabMethods:Slider(label, opts, callback)
    opts = opts or {}
    local min = opts.Min or 0
    local max = opts.Max or 100
    local default = opts.Default or min
    local step = opts.Step or 0.01
    local decimals = opts.Decimals or 2

    local parent = getSection(self)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 52)
    holder.BackgroundColor3 = Theme.Surface
    holder.BorderSizePixel = 0
    holder.Parent = parent
    Corner(holder)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Theme.Font
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 20)
    valLbl.Position = UDim2.new(1, -68, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format("%." .. decimals .. "f", default)
    valLbl.TextColor3 = Theme.Accent
    valLbl.Font = Theme.FontBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 1, -18)
    track.BackgroundColor3 = Theme.SurfaceHover
    track.BorderSizePixel = 0
    track.Parent = holder
    Corner(track, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Corner(fill, UDim.new(1, 0))

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    Corner(knob, UDim.new(1, 0))
    Stroke(knob, Theme.Accent, 1.5)

    local dragging = false
    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * rel
        local snapped = math.floor(raw / step + 0.5) * step
        local pct = (snapped - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        valLbl.Text = string.format("%." .. decimals .. "f", snapped)
        if callback then callback(snapped) end
        return snapped
    end

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 0, 20)
    hitbox.Position = UDim2.new(0, 0, 1, -20)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = holder

    hitbox.MouseButton1Down:Connect(function()
        dragging = true
        updateFromX(UserInputService:GetMouseLocation().X)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromX(UserInputService:GetMouseLocation().X)
        end
    end)

    return { Set = function(v) updateFromX(track.AbsolutePosition.X + (v - min)/(max-min) * track.AbsoluteSize.X) end }
end

-- Text Input
function TabMethods:Input(label, default, callback)
    local parent = getSection(self)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 52)
    holder.BackgroundColor3 = Theme.Surface
    holder.BorderSizePixel = 0
    holder.Parent = parent
    Corner(holder)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Theme.Font
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 0, 22)
    box.Position = UDim2.new(0, 12, 1, -26)
    box.BackgroundColor3 = Theme.Background
    box.Text = default or ""
    box.PlaceholderText = "..."
    box.TextColor3 = Theme.Text
    box.PlaceholderColor3 = Theme.TextDim
    box.Font = Theme.Font
    box.TextSize = 12
    box.ClearTextOnFocus = false
    box.Parent = holder
    Corner(box, UDim.new(0, 6))
    Stroke(box, Theme.Border)

    box.Focused:Connect(function()
        TweenService:Create(box, Theme.TweenFast, { BackgroundColor3 = Theme.SurfaceHover }):Play()
    end)
    box.FocusLost:Connect(function()
        TweenService:Create(box, Theme.TweenFast, { BackgroundColor3 = Theme.Background }):Play()
        if callback then callback(box.Text) end
    end)

    return { Set = function(v) box.Text = v end, Get = function() return box.Text end }
end

-- Color Picker (preset swatches + hex input)
function TabMethods:ColorPicker(label, default, callback)
    local parent = getSection(self)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 46)
    holder.BackgroundColor3 = Theme.Surface
    holder.BorderSizePixel = 0
    holder.Parent = parent
    Corner(holder)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Theme.Font
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 40, 0, 24)
    swatch.Position = UDim2.new(1, -52, 0.5, -12)
    swatch.BackgroundColor3 = default
    swatch.BorderSizePixel = 0
    swatch.Parent = holder
    Corner(swatch, UDim.new(0, 6))
    Stroke(swatch, Theme.Border)

    -- Popup palette
    local currentColor = default

    local function setColor(c, fire)
        currentColor = c
        swatch.BackgroundColor3 = c
        if fire and callback then callback(c) end
    end

    local clickable = Instance.new("TextButton")
    clickable.Size = UDim2.new(1, 0, 1, 0)
    clickable.BackgroundTransparency = 1
    clickable.Text = ""
    clickable.Parent = holder

    clickable.MouseButton1Click:Connect(function()
        -- Simple popup with preset swatches
        local existing = self._ui.Gui:FindFirstChild("ColorPopup")
        if existing then existing:Destroy() end

        local popup = Instance.new("Frame")
        popup.Name = "ColorPopup"
        popup.Size = UDim2.new(0, 200, 0, 160)
        popup.Position = UDim2.new(0.5, -100, 0.5, -80)
        popup.BackgroundColor3 = Theme.Surface
        popup.BorderSizePixel = 0
        popup.Parent = self._ui.Gui
        popup.ZIndex = 10
        Corner(popup)
        Stroke(popup, Theme.Accent, 1.5)

        local presetColors = {
            Color3.fromRGB(0, 0, 0),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(240, 70, 90),
            Color3.fromRGB(140, 80, 255),
            Color3.fromRGB(70, 140, 240),
            Color3.fromRGB(70, 220, 140),
            Color3.fromRGB(240, 180, 60),
            Color3.fromRGB(240, 120, 200),
        }

        local grid = Instance.new("Frame")
        grid.Size = UDim2.new(1, -20, 0, 90)
        grid.Position = UDim2.new(0, 10, 0, 10)
        grid.BackgroundTransparency = 1
        grid.Parent = popup
        local gl = Instance.new("UIGridLayout")
        gl.CellSize = UDim2.new(0, 38, 0, 38)
        gl.CellPadding = UDim2.new(0, 6, 0, 6)
        gl.Parent = grid

        for _, c in ipairs(presetColors) do
            local b = Instance.new("TextButton")
            b.BackgroundColor3 = c
            b.Text = ""
            b.Parent = grid
            Corner(b, UDim.new(0, 6))
            Stroke(b, Theme.Border)
            b.MouseButton1Click:Connect(function()
                setColor(c, true)
                popup:Destroy()
            end)
        end

        -- Hex input
        local hex = Instance.new("TextBox")
        hex.Size = UDim2.new(1, -20, 0, 30)
        hex.Position = UDim2.new(0, 10, 1, -40)
        hex.BackgroundColor3 = Theme.Background
        hex.Text = string.format("#%02X%02X%02X",
            currentColor.R*255, currentColor.G*255, currentColor.B*255)
        hex.TextColor3 = Theme.Text
        hex.Font = Theme.Font
        hex.TextSize = 12
        hex.Parent = popup
        Corner(hex, UDim.new(0, 6))
        Stroke(hex, Theme.Border)
        hex.FocusLost:Connect(function()
            local s = hex.Text:gsub("#", "")
            if #s == 6 then
                local r = tonumber(s:sub(1,2), 16)
                local g = tonumber(s:sub(3,4), 16)
                local b = tonumber(s:sub(5,6), 16)
                if r and g and b then
                    setColor(Color3.fromRGB(r, g, b), true)
                    popup:Destroy()
                end
            end
        end)
    end)

    return { Set = function(c) setColor(c, false) end }
end

return NoirUI
