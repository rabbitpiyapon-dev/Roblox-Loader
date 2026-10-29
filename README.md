
--========================================================
-- CAR CRUSHERS 2 | NEON CONTROL HUB
-- ต้นฉบับ v1.0
-- ประเภท: LocalScript
-- ตำแหน่ง: StarterPlayer > StarterPlayerScripts
-- รองรับ: PC / Mobile
-- สถานะ: สคริปต์อิสระสำหรับเกมของคุณเอง
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--========================================================
-- CONFIG
--========================================================

local CONFIG = {
    PlayerESP = true,
    VehicleESP = true,

    -- ความเร็วแนวราบเป้าหมาย (studs/second)
    Speed = 1000,

    -- ความสูงที่ยกรถ
    FarmHeight = 10,

    -- ความเร็วหมุนเป็นองศาต่อวินาที
    FarmRotation = 999,

    RainbowSpeed = 1.5,
}

--========================================================
-- STATE
--========================================================

local running = true
local minimized = false
local espEnabled = false
local farmEnabled = false
local speedEnabled = false

local playerHighlights = {}
local vehicleBoxes = {}
local currentVehicle = nil
local farmAttachment = nil
local farmPosition = nil
local farmRotation = nil
local farmTarget = nil
local farmOrigin = nil

local connections = {}
local featureConnections = {}
local rainbowConnections = {}

local function track(connection, list)
    table.insert(list or connections, connection)
    return connection
end

local function make(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

--========================================================
-- GUI
--========================================================

local gui = make("ScreenGui", {
    Name = "NeonControlHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 390, 0, 310),
    BackgroundColor3 = Color3.fromRGB(8, 9, 14),
    BorderSizePixel = 0,
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(0, 16),
}, main)

local mainStroke = make("UIStroke", {
    Thickness = 2,
    Color = Color3.fromRGB(160, 70, 255),
}, main)

local mainGradient = make("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(130, 50, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 40, 140)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 240, 255)),
    }),
}, mainStroke)

track(RunService.RenderStepped:Connect(function(dt)
    if not running then return end
    mainGradient.Rotation = (mainGradient.Rotation + dt * 90 * CONFIG.RainbowSpeed) % 360
end), rainbowConnections)

local header = make("Frame", {
    Position = UDim2.fromOffset(10, 10),
    Size = UDim2.new(1, -20, 0, 55),
    BackgroundTransparency = 1,
}, main)

make("TextLabel", {
    Position = UDim2.fromOffset(5, 0),
    Size = UDim2.new(1, -100, 0, 30),
    BackgroundTransparency = 1,
    Text = "CAR CRUSHERS 2",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

make("TextLabel", {
    Position = UDim2.fromOffset(6, 29),
    Size = UDim2.new(1, -100, 0, 18),
    BackgroundTransparency = 1,
    Text = "NEON CONTROL HUB  •  v1.0",
    TextColor3 = Color3.fromRGB(170, 120, 255),
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

-- ปุ่มย่อ
local minimizeButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -40, 0, 5),
    Size = UDim2.fromOffset(32, 30),
    BackgroundColor3 = Color3.fromRGB(25, 26, 34),
    Text = "—",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true,
}, header)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, minimizeButton)

-- ปุ่มปิด
local closeButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -3, 0, 5),
    Size = UDim2.fromOffset(32, 30),
    BackgroundColor3 = Color3.fromRGB(35, 14, 20),
    Text = "X",
    TextColor3 = Color3.fromRGB(255, 60, 80),
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true,
}, header)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, closeButton)

local divider = make("Frame", {
    Position = UDim2.fromOffset(14, 73),
    Size = UDim2.new(1, -28, 0, 1),
    BackgroundColor3 = Color3.fromRGB(65, 43, 94),
    BorderSizePixel = 0,
}, main)

local statusLabel = make("TextLabel", {
    Position = UDim2.fromOffset(16, 82),
    Size = UDim2.new(1, -32, 0, 20),
    BackgroundTransparency = 1,
    Text = "SYSTEM READY",
    TextColor3 = Color3.fromRGB(90, 255, 170),
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, main)

local list = make("Frame", {
    Position = UDim2.fromOffset(14, 110),
    Size = UDim2.new(1, -28, 0, 158),
    BackgroundTransparency = 1,
}, main)

make("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, list)

--========================================================
-- FLOATING BUTTON
--========================================================

local floating = make("TextButton", {
    Name = "FloatingButton",
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 18, 0.5, 0),
    Size = UDim2.fromOffset(58, 58),
    BackgroundColor3 = Color3.fromRGB(5, 6, 10),
    Text = "CC2",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBlack,
    TextSize = 15,
    AutoButtonColor = false,
    ZIndex = 5,
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(1, 0),
}, floating)

local floatingStroke = make("UIStroke", {
    Thickness = 2.5,
    Color = Color3.fromRGB(0, 230, 255),
}, floating)

local floatingGradient = make("UIGradient", {
    Color = mainGradient.Color,
}, floatingStroke)

track(RunService.RenderStepped:Connect(function(dt)
    if not running then return end
    floatingGradient.Rotation = (floatingGradient.Rotation + dt * 100) % 360
end), rainbowConnections)

--========================================================
-- FEATURE ROWS
--========================================================

local function makeFeature(name, description, order, callback)
    local row = make("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(18, 19, 27),
        BorderSizePixel = 0,
        LayoutOrder = order,
    }, list)

    make("UICorner", {
        CornerRadius = UDim.new(0, 9),
    }, row)

    make("TextLabel", {
        Position = UDim2.fromOffset(12, 4),
        Size = UDim2.new(1, -85, 0, 20),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    make("TextLabel", {
        Position = UDim2.fromOffset(12, 23),
        Size = UDim2.new(1, -85, 0, 15),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = Color3.fromRGB(145, 147, 160),
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local toggle = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(49, 25),
        BackgroundColor3 = Color3.fromRGB(43, 44, 53),
        Text = "OFF",
        TextColor3 = Color3.fromRGB(180, 180, 190),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        AutoButtonColor = true,
    }, row)

    make("UICorner", {
        CornerRadius = UDim.new(1, 0),
    }, toggle)

    local enabled = false

    toggle.Activated:Connect(function()
        if not running then return end
        enabled = not enabled

        toggle.Text = enabled and "ON" or "OFF"
        toggle.BackgroundColor3 = enabled
            and Color3.fromRGB(91, 38, 160)
            or Color3.fromRGB(43, 44, 53)
        toggle.TextColor3 = enabled
            and Color3.new(1, 1, 1)
            or Color3.fromRGB(180, 180, 190)

        callback(enabled)
    end)

    return toggle
end

--========================================================
-- VEHICLE DETECTION
--========================================================

local function getVehicle()
    local character = player.Character
    if not character then return nil end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    local seat = humanoid.SeatPart
    if not seat then return nil end

    local model = seat:FindFirstAncestorOfClass("Model")
    while model and model ~= Workspace do
        if model:FindFirstChildWhichIsA("VehicleSeat", true) then
            return model
        end
        model = model.Parent and model.Parent:FindFirstAncestorOfClass("Model")
    end

    return nil
end

local function getVehicleRoot(model)
    if not model then return nil end

    if model.PrimaryPart then
        return model.PrimaryPart
    end

    local seat = model:FindFirstChildWhichIsA("VehicleSeat", true)
    if seat then return seat end

    return model:FindFirstChildWhichIsA("BasePart", true)
end

--========================================================
-- PLAYER ESP
-- เขียว = ตัวเอง / น้ำเงิน = ผู้เล่นอื่น
--========================================================

local function removePlayerESP(target)
    local highlight = playerHighlights[target]
    if highlight then
        highlight:Destroy()
        playerHighlights[target] = nil
    end
end

local function addPlayerESP(target)
    if not espEnabled or not target.Character then return end

    removePlayerESP(target)

    local highlight = make("Highlight", {
        Name = "NeonPlayerESP",
        Adornee = target.Character,
        FillColor = target == player
            and Color3.fromRGB(50, 255, 110)
            or Color3.fromRGB(45, 135, 255),
        OutlineColor = target == player
            and Color3.fromRGB(140, 255, 170)
            or Color3.fromRGB(110, 190, 255),
        FillTransparency = 0.72,
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    }, gui)

    playerHighlights[target] = highlight
end

local function refreshPlayerESP()
    for _, target in ipairs(Players:GetPlayers()) do
        addPlayerESP(target)
    end
end

local function stopPlayerESP()
    for target in pairs(playerHighlights) do
        removePlayerESP(target)
    end
end

--========================================================
-- OWN VEHICLE ESP
-- เน้นขอบชิ้นส่วนรถที่ผู้เล่นกำลังขับเท่านั้น
--========================================================

local function clearVehicleESP()
    for part, selection in pairs(vehicleBoxes) do
        if selection then selection:Destroy() end
        vehicleBoxes[part] = nil
    end
    currentVehicle = nil
end

local function refreshVehicleESP()
    if not espEnabled then return end

    local model = getVehicle()
    if model ~= currentVehicle then
        clearVehicleESP()
        currentVehicle = model
    end

    if not model then return end

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and not vehicleBoxes[part] then
            local box = make("SelectionBox", {
                Name = "NeonVehicleESP",
                Adornee = part,
                Color3 = Color3.fromRGB(0, 255, 210),
                LineThickness = 0.035,
                SurfaceTransparency = 1,
                AlwaysOnTop = true,
            }, gui)

            vehicleBoxes[part] = box
        end
    end

    for part, box in pairs(vehicleBoxes) do
        if not part.Parent or not part:IsDescendantOf(model) then
            box:Destroy()
            vehicleBoxes[part] = nil
        end
    end
end

--========================================================
-- FARM MODE
-- ยกรถ 10 studs และหมุนรถ
--========================================================

local function stopFarm()
    if farmPosition then farmPosition:Destroy() end
    if farmRotation then farmRotation:Destroy() end
    if farmAttachment then farmAttachment:Destroy() end

    farmPosition = nil
    farmRotation = nil
    farmAttachment = nil
    farmTarget = nil
    farmOrigin = nil
end

local function startFarm()
    stopFarm()

    local model = getVehicle()
    local root = getVehicleRoot(model)

    if not model or not root then
        statusLabel.Text = "FARM: SIT IN YOUR VEHICLE FIRST"
        return
    end

    farmTarget = model
    farmOrigin = root.Position

    farmAttachment = make("Attachment", {
        Name = "NeonFarmAttachment",
    }, root)

    farmPosition = make("AlignPosition", {
        Name = "NeonFarmLift",
        Mode = Enum.PositionAlignmentMode.OneAttachment,
        Attachment0 = farmAttachment,
        Position = farmOrigin + Vector3.new(0, CONFIG.FarmHeight, 0),
        MaxForce = 100000000,
        MaxVelocity = 100,
        Responsiveness = 15,
        ApplyAtCenterOfMass = true,
    }, root)

    farmRotation = make("AngularVelocity", {
        Name = "NeonFarmSpin",
        Attachment0 = farmAttachment,
        RelativeTo = Enum.ActuatorRelativeTo.World,
        AngularVelocity = Vector3.new(
            0,
            math.rad(CONFIG.FarmRotation),
            0
        ),
        MaxTorque = 100000000,
    }, root)

    statusLabel.Text = "FARM: ACTIVE"
end

--========================================================
-- SPEED MODE
-- ทำงานเฉพาะรถที่กำลังขับอยู่
--========================================================

local function applySpeed()
    local model = getVehicle()
    local root = getVehicleRoot(model)

    if not root then
        statusLabel.Text = "SPEED: SIT IN YOUR VEHICLE FIRST"
        return
    end

    local forward = root.CFrame.LookVector
    local velocity = root.AssemblyLinearVelocity

    -- เปลี่ยนเฉพาะความเร็วแนวราบ รักษาความเร็วแนวดิ่งไว้
    root.AssemblyLinearVelocity = Vector3.new(
        forward.X * CONFIG.Speed,
        velocity.Y,
        forward.Z * CONFIG.Speed
    )
end

--========================================================
-- ENABLE / DISABLE FEATURES
--========================================================

makeFeature("ESP", "Players + Your Vehicle", 1, function(enabled)
    espEnabled = enabled

    if enabled then
        refreshPlayerESP()
        refreshVehicleESP()
        statusLabel.Text = "ESP: ACTIVE"
    else
        stopPlayerESP()
        clearVehicleESP()
        statusLabel.Text = "ESP: OFF"
    end
end)

makeFeature("FARM", "Lift + Vehicle Spin", 2, function(enabled)
    farmEnabled = enabled

    if enabled then
        startFarm()
    else
        stopFarm()
        statusLabel.Text = "FARM: OFF"
    end
end)

makeFeature("SPEED", "Boost While Driving", 3, function(enabled)
    speedEnabled = enabled
    statusLabel.Text = enabled and "SPEED: ACTIVE" or "SPEED: OFF"
end)

--========================================================
-- BUTTONS
--========================================================

floating.Activated:Connect(function()
    if not running then return end

    main.Visible = not main.Visible
    minimized = false
end)

minimizeButton.Activated:Connect(function()
    minimized = not minimized

    list.Visible = not minimized
    divider.Visible = not minimized
    statusLabel.Visible = not minimized

    main.Size = minimized
        and UDim2.new(0, 390, 0, 75)
        or UDim2.new(0, 390, 0, 310)
end)

local function shutdown()
    if not running then return end

    running = false
    espEnabled = false
    farmEnabled = false
    speedEnabled = false

    stopPlayerESP()
    clearVehicleESP()
    stopFarm()

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    for _, connection in ipairs(featureConnections) do
        connection:Disconnect()
    end

    for _, connection in ipairs(rainbowConnections) do
        connection:Disconnect()
    end

    gui:Destroy()
end

closeButton.Activated:Connect(shutdown)

--========================================================
-- UPDATE LOOP
--========================================================

local espTimer = 0

track(RunService.Heartbeat:Connect(function(dt)
    if not running then return end

    if speedEnabled then
        applySpeed()
    end

    if farmEnabled then
        local model = getVehicle()
        local root = getVehicleRoot(model)

        if not model or model ~= farmTarget or not root then
            stopFarm()
            farmEnabled = false
            statusLabel.Text = "FARM: VEHICLE UNAVAILABLE"
        end
    end

    if espEnabled then
        espTimer += dt

        if espTimer >= 0.5 then
            espTimer = 0
            refreshVehicleESP()
        end
    end
end))

track(Players.PlayerAdded:Connect(function(target)
    if espEnabled then
        target.CharacterAdded:Connect(function()
            task.wait(0.5)
            if running and espEnabled then
                addPlayerESP(target)
            end
        end)
    end
end))

track(Players.PlayerRemoving:Connect(function(target)
    removePlayerESP(target)
end))

-- ปรับขนาดสำหรับหน้าจอมือถือ
local function updateLayout()
    local camera = Workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize

    if viewport.X < 450 then
        main.Size = UDim2.new(1, -30, 0, minimized and 75 or 310)
    else
        main.Size = UDim2.new(0, 390, 0, minimized and 75 or 310)
    end
end

track(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateLayout))
updateLayout()

print("[NEON CONTROL HUB] ต้นฉบับ v1.0 loaded")
