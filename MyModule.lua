--========================================================
-- VIOLENCE DISTRICT | ต้นฉบับ v1.0
-- UI PROTOTYPE
-- สถานะ: สคริปต์อิสระ ไม่เชื่อมโยงระบบเกม
-- ประเภท: LocalScript
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("VD_MainUI")
if old then old:Destroy() end

local C = {
    bg = Color3.fromRGB(25, 19, 21),
    panel = Color3.fromRGB(43, 25, 27),
    red = Color3.fromRGB(151, 39, 43),
    red2 = Color3.fromRGB(190, 58, 49),
    gold = Color3.fromRGB(232, 184, 95),
    white = Color3.fromRGB(255, 255, 255),
    muted = Color3.fromRGB(176, 160, 160),
    blue = Color3.fromRGB(35, 125, 245),
    green = Color3.fromRGB(74, 205, 115)
}

local gui = Instance.new("ScreenGui")
gui.Name = "VD_MainUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 50
gui.Parent = playerGui

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function stroke(parent, color, thickness)
    make("UIStroke", {
        Color = color or C.white,
        Thickness = thickness or 1,
        Transparency = 0
    }, parent)
end

local function label(parent, text, size, position, font)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = C.white,
        TextSize = size or 14,
        Font = font or Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 24),
        Position = position or UDim2.new(),
    }, parent)
end

-- Floating launcher button
local launcher = make("TextButton", {
    Name = "Launcher",
    Text = "VD",
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextColor3 = C.white,
    BackgroundColor3 = C.blue,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -18, 0, 70),
    Size = UDim2.fromOffset(52, 52),
    AutoButtonColor = true,
}, gui)
corner(launcher, 100)
stroke(launcher, C.white, 1)

-- Main window
local window = make("Frame", {
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.84, 0, 0.72, 0),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
    Visible = false,
}, gui)
corner(window, 12)
stroke(window, C.white, 1)

local inner = make("Frame", {
    Name = "Inner",
    Position = UDim2.fromOffset(2, 2),
    Size = UDim2.new(1, -4, 1, -4),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
}, window)
corner(inner, 10)

local scale = make("UIScale", {
    Scale = 1
}, window)

local function fit()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize

    if viewport.X < 600 then
        window.Size = UDim2.new(0.92, 0, 0.76, 0)
    else
        window.Size = UDim2.fromOffset(650, 460)
    end
end

fit()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
end

-- Header
local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 54),
    BackgroundColor3 = C.red,
    BorderSizePixel = 0,
}, inner)
corner(header, 9)

label(header, "VIOLENCE DISTRICT", 17,
    UDim2.fromOffset(16, 5), Enum.Font.GothamBold)

local subtitle = label(header, "PERSONAL CONTROL PANEL  •  v1.0", 9,
    UDim2.fromOffset(17, 29), Enum.Font.Gotham)
subtitle.TextColor3 = C.gold

local close = make("TextButton", {
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = C.white,
    BackgroundColor3 = C.red2,
    Position = UDim2.new(1, -42, 0, 9),
    Size = UDim2.fromOffset(30, 30),
}, header)
corner(close, 7)

-- Tabs
local tabs = make("Frame", {
    Position = UDim2.fromOffset(12, 64),
    Size = UDim2.new(1, -24, 0, 38),
    BackgroundTransparency = 1,
}, inner)

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, tabs)

local content = make("Frame", {
    Position = UDim2.fromOffset(12, 111),
    Size = UDim2.new(1, -24, 1, -123),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, inner)
corner(content, 8)

local pages = {}
local tabButtons = {}
local activeTab = "HOME"

local function newPage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.gold,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)

    make("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, page)

    make("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    pages[name] = page
    return page
end

local home = newPage("HOME")
local survivors = newPage("SURVIVORS")
local killer = newPage("KILLER")
local settings = newPage("SETTINGS")

local function switchTab(name)
    activeTab = name
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
    for tabName, button in pairs(tabButtons) do
        button.BackgroundColor3 =
            tabName == name and C.gold or C.red
        button.TextColor3 =
            tabName == name and C.bg or C.white
    end
end

local function createTab(name, title)
    local button = make("TextButton", {
        Name = name .. "Tab",
        Text = title,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextColor3 = C.white,
        BackgroundColor3 = C.red,
        Size = UDim2.new(0.333, -5, 1, 0),
        BorderSizePixel = 0,
    }, tabs)
    corner(button, 7)
    tabButtons[name] = button
    button.Activated:Connect(function()
        switchTab(name)
    end)
end

createTab("SURVIVORS", "SURVIVORS")
createTab("KILLER", "KILLER")
createTab("SETTINGS", "SETTINGS")

-- Home page
local welcome = label(home, "WELCOME", 20, nil, Enum.Font.GothamBold)
welcome.Position = UDim2.fromOffset(4, 0)
welcome.TextColor3 = C.gold

local description = label(home,
    "Personal interface for your own game.", 13,
    UDim2.fromOffset(4, 0), Enum.Font.Gotham)
description.Size = UDim2.new(1, -8, 0, 30)
description.TextColor3 = C.muted

local discord = make("TextButton", {
    Text = "DISCORD  •  LINK NOT SET",
    Size = UDim2.new(1, -8, 0, 40),
    BackgroundColor3 = C.red,
    TextColor3 = C.white,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
}, home)
corner(discord, 7)
discord.Activated:Connect(function()
    -- ใส่ลิงก์ Discord ของตัวเองภายหลัง
end)

-- Feature cards: UI toggles only, no gameplay manipulation
local function featureCard(parent, title, detail, initial)
    local card = make("Frame", {
        Size = UDim2.new(1, -8, 0, 64),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
    }, parent)
    corner(card, 8)
    stroke(card, Color3.fromRGB(105, 54, 49), 1)

    local titleLabel = label(card, title, 13,
        UDim2.fromOffset(10, 6), Enum.Font.GothamBold)
    titleLabel.Size = UDim2.new(1, -90, 0, 22)

    local detailLabel = label(card, detail, 10,
        UDim2.fromOffset(10, 31), Enum.Font.Gotham)
    detailLabel.Size = UDim2.new(1, -90, 0, 20)
    detailLabel.TextColor3 = C.muted

    local enabled = initial or false
    local toggle = make("TextButton", {
        Text = enabled and "ON" or "OFF",
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextColor3 = C.white,
        BackgroundColor3 = enabled and C.green or C.red,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(54, 28),
        BorderSizePixel = 0,
    }, card)
    corner(toggle, 7)

    toggle.Activated:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "ON" or "OFF"
        toggle.BackgroundColor3 = enabled and C.green or C.red
    end)

    return card
end

label(survivors, "SURVIVOR FEATURES", 15, nil,
    Enum.Font.GothamBold).TextColor3 = C.gold

featureCard(survivors, "ESP PREVIEW",
    "UI placeholder • not connected to player data", false)

featureCard(survivors, "AUTO GENERATOR",
    "UI placeholder • no automated minigame input", false)

featureCard(survivors, "PLAYER SPEED",
    "UI preview • slider 0–120", false)

-- Slider preview
local speedLabel = label(survivors, "Speed: 16", 12, nil,
    Enum.Font.GothamBold)
speedLabel.TextColor3 = C.gold

local slider = make("Frame", {
    Size = UDim2.new(1, -8, 0, 8),
    BackgroundColor3 = C.red,
    BorderSizePixel = 0,
}, survivors)
corner(slider, 5)

local fill = make("Frame", {
    Size = UDim2.new(16 / 120, 0, 1, 0),
    BackgroundColor3 = C.gold,
    BorderSizePixel = 0,
}, slider)
corner(fill, 5)

local knob = make("TextButton", {
    Text = "",
    Size = UDim2.fromOffset(18, 18),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(16 / 120, 0, 0.5, 0),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
}, slider)
corner(knob, 20)

local dragging = false
local speed = 16

local function updateSlider(x)
    local alpha = math.clamp(
        (x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1
    )
    speed = math.floor(alpha * 120 + 0.5)
    fill.Size = UDim2.new(alpha, 0, 1, 0)
    knob.Position = UDim2.new(alpha, 0, 0.5, 0)
    speedLabel.Text = "Speed: " .. speed
end

knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateSlider(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

featureCard(survivors, "KILLER ALERT",
    "UI placeholder • requires authorized game data", false)

label(killer, "KILLER FEATURES", 15, nil,
    Enum.Font.GothamBold).TextColor3 = C.gold

featureCard(killer, "NEAREST PLAYER",
    "Combat automation is not implemented", false)

local locked = make("Frame", {
    Size = UDim2.new(1, -8, 0, 64),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
}, killer)
corner(locked, 8)
stroke(locked, C.gold, 1)

local lockedText = label(locked, "FEATURE LOCKED", 13,
    UDim2.fromOffset(10, 5), Enum.Font.GothamBold)
lockedText.TextColor3 = C.gold

local lockedDetail = label(locked,
    "Not available in this prototype.", 10,
    UDim2.fromOffset(10, 30), Enum.Font.Gotham)
lockedDetail.TextColor3 = C.muted

label(settings, "SETTINGS", 15, nil,
    Enum.Font.GothamBold).TextColor3 = C.gold

featureCard(settings, "UI ANIMATIONS",
    "Visual toggle preview", true)

featureCard(settings, "COMPACT MODE",
    "Visual toggle preview", false)

-- Window open / close
local function openWindow()
    launcher.Visible = false
    window.Visible = true
    window.BackgroundTransparency = 1
    window.Size = UDim2.new(0.78, 0, 0.66, 0)

    TweenService:Create(window,
        TweenInfo.new(0.2, Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0.84, 0, 0.72, 0),
            BackgroundTransparency = 0
        }
    ):Play()
end

local function closeWindow()
    window.Visible = false
    launcher.Visible = true
end

launcher.Activated:Connect(openWindow)
close.Activated:Connect(closeWindow)

switchTab("HOME")

print("VIOLENCE DISTRICT UI v1.0 loaded")
