
--==================================================
-- ฆาตกร | ต้นฉบับ v1.3
-- ONE LOCAL SCRIPT
-- สำหรับแมป Roblox ของเจ้าของ
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    ESP = false,
    Aim = false,
    Flight = false,
    Speed = 55,
    MaxSpeed = 180,
    GunBusy = false,
    AimRange = 500
}

local Highlights = {}
local ItemHighlights = {}
local FlightAttachment
local FlightVelocity
local FlightButtonUpdate

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "ฆาตกร"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Ninja = Instance.new("TextButton")
Ninja.Name = "Ninja"
Ninja.Size = UDim2.fromOffset(54,54)
Ninja.Position = UDim2.new(1,-70,0,15)
Ninja.BackgroundColor3 = Color3.new(1,1,1)
Ninja.Text = "🥷"
Ninja.TextSize = 27
Ninja.Parent = Gui

Instance.new("UICorner",Ninja).CornerRadius =
    UDim.new(1,0)

local Panel = Instance.new("Frame")
Panel.Size = UDim2.fromOffset(300,410)
Panel.Position = UDim2.new(.5,-150,.5,-205)
Panel.BackgroundColor3 = Color3.fromRGB(17,17,22)
Panel.Visible = false
Panel.Parent = Gui

Instance.new("UICorner",Panel).CornerRadius =
    UDim.new(0,15)

local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(255,45,45)
Border.Thickness = 2
Border.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,55)
Title.BackgroundTransparency = 1
Title.Text = "🔪 ฆาตกร"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 23
Title.Font = Enum.Font.GothamBold
Title.Parent = Panel

local Holder = Instance.new("ScrollingFrame")
Holder.Position = UDim2.fromOffset(10,60)
Holder.Size = UDim2.new(1,-20,1,-70)
Holder.BackgroundTransparency = 1
Holder.BorderSizePixel = 0
Holder.ScrollBarThickness = 3
Holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
Holder.CanvasSize = UDim2.new()
Holder.Parent = Panel

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,8)
Layout.Parent = Holder

local function Button(name, callback, toggle)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-5,0,48)
    b.BackgroundColor3 = Color3.fromRGB(38,38,48)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.Text = name .. (toggle and " [OFF]" or "")
    b.Parent = Holder

    Instance.new("UICorner",b).CornerRadius =
        UDim.new(0,9)

    local state = false

    local function SetState(value)
        state = value
        b.Text = name .. (state and " [ON]" or " [OFF]")
        b.BackgroundColor3 = state
            and Color3.fromRGB(30,130,75)
            or Color3.fromRGB(38,38,48)
    end

    b.Activated:Connect(function()
        if toggle then
            SetState(not state)
            callback(state)
        else
            callback()
        end
    end)

    return b, SetState
end

local function TogglePanel()
    Panel.Visible = not Panel.Visible
end

Ninja.Activated:Connect(TogglePanel)

--==================================================
-- ROLE COLORS
--==================================================

local function GetRole(player)
    return string.lower(tostring(
        player:GetAttribute("Role")
        or (player.Team and player.Team.Name)
        or "innocent"
    ))
end

local function GetColor(role)
    if role:find("murder") then
        return Color3.fromRGB(255,40,40)
    elseif role:find("sheriff") then
        return Color3.fromRGB(40,140,255)
    end

    return Color3.fromRGB(40,255,90)
end

--==================================================
-- ESP
--==================================================

local function ClearESP()
    for _,v in pairs(Highlights) do
        if v then v:Destroy() end
    end

    for _,v in pairs(ItemHighlights) do
        if v then v:Destroy() end
    end

    table.clear(Highlights)
    table.clear(ItemHighlights)
end

local function AddHighlight(container, storage, color, transparency)
    local h = storage[container]

    if not h or h.Parent ~= container then
        if h then h:Destroy() end

        h = Instance.new("Highlight")
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = container
        storage[container] = h
    end

    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = transparency
    h.OutlineTransparency = 0
end

local function UpdateESP()
    if not Config.ESP then return end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            AddHighlight(
                p.Character,
                Highlights,
                GetColor(GetRole(p)),
                0.65
            )
        end
    end

    local hue = (os.clock()%4)/4

    local tags = {
        "DroppedSheriffGun",
        "Coin",
        "Candy"
    }

    for _,tag in ipairs(tags) do
        for _,item in ipairs(CollectionService:GetTagged(tag)) do
            if item:IsDescendantOf(workspace) then
                local color

                if tag == "DroppedSheriffGun" then
                    color = Color3.fromRGB(255,220,20)
                elseif tag == "Candy" then
                    color = Color3.fromRGB(185,60,255)
                else
                    color = Color3.fromHSV(hue,1,1)
                end

                AddHighlight(item,ItemHighlights,color,0.4)
            end
        end
    end
end

Button("ESP | ผู้เล่นและไอเทม",function(v)
    Config.ESP = v
    if not v then ClearESP() end
end,true)

--==================================================
-- GUN FINDER
-- ค้นหาปืนที่ Sheriff ทำตก
--==================================================

local GunLabel = Instance.new("TextLabel")
GunLabel.Size = UDim2.new(1,-5,0,38)
GunLabel.BackgroundTransparency = 1
GunLabel.TextColor3 = Color3.new(1,1,1)
GunLabel.TextSize = 12
GunLabel.Text = "Gun: ยังไม่ได้ค้นหา"
GunLabel.Parent = Holder

local function GetPart(item)
    if item:IsA("BasePart") then
        return item
    end

    return item:FindFirstChildWhichIsA("BasePart",true)
end

local function FindNearestGun()
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then return nil end

    local nearest
    local distance = math.huge

    for _,gun in ipairs(
        CollectionService:GetTagged("DroppedSheriffGun")
    ) do
        local part = GetPart(gun)

        if part and part:IsDescendantOf(workspace) then
            local d = (root.Position-part.Position).Magnitude

            if d < distance then
                nearest = gun
                distance = d
            end
        end
    end

    return nearest,distance
end

local function FindPrompt(item)
    if item:IsA("ProximityPrompt") then
        return item
    end

    return item:FindFirstChildWhichIsA(
        "ProximityPrompt",true
    )
end

local function CollectGun()
    if Config.GunBusy then return end

    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        GunLabel.Text = "Gun: ไม่พบตัวละคร"
        return
    end

    local gun,distance = FindNearestGun()

    if not gun then
        GunLabel.Text = "Gun: ไม่พบปืนที่ตก"
        return
    end

    local part = GetPart(gun)

    if not part then
        GunLabel.Text = "Gun: ไม่พบตำแหน่งปืน"
        return
    end

    Config.GunBusy = true
    GunLabel.Text = "Gun: กำลังไปยังปืน..."

    local oldPosition = root.CFrame

    local success,err = pcall(function()
        character:PivotTo(
            CFrame.new(part.Position + Vector3.new(0,3,0))
        )

        task.wait(0.5)

        local prompt = FindPrompt(gun)

        if prompt and prompt.Enabled then
            prompt:InputHoldBegin()
            task.wait(math.max(prompt.HoldDuration,0.2))
            prompt:InputHoldEnd()
            GunLabel.Text = "Gun: ส่งคำสั่งเก็บปืนแล้ว"
        else
            GunLabel.Text = "Gun: ไม่พบ ProximityPrompt"
        end

        task.wait(0.5)

        if Player.Character then
            Player.Character:PivotTo(oldPosition)
        end
    end)

    if not success then
        GunLabel.Text = "Gun: เกิดข้อผิดพลาด"
        warn("Gun Finder:",err)

        if Player.Character then
            Player.Character:PivotTo(oldPosition)
        end
    end

    Config.GunBusy = false
end

Button("🔫 ค้นหาและเก็บปืนที่ตก",CollectGun)

--==================================================
-- AIM
-- เล็งเป้าหมาย Murder และใช้อาวุธที่ถืออยู่
--==================================================

local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.fromOffset(55,55)
AimButton.Position = UDim2.new(1,-75,1,-190)
AimButton.BackgroundColor3 = Color3.fromRGB(30,30,35)
AimButton.Text = "⊙"
AimButton.TextSize = 34
AimButton.TextColor3 = Color3.new(1,1,1)
AimButton.Visible = false
AimButton.Parent = Gui

Instance.new("UICorner",AimButton).CornerRadius =
    UDim.new(1,0)

local AimStroke = Instance.new("UIStroke")
AimStroke.Color = Color3.fromRGB(255,45,45)
AimStroke.Thickness = 2
AimStroke.Parent = AimButton

local function FindMurderTarget()
    local myCharacter = Player.Character
    local myRoot = myCharacter
        and myCharacter:FindFirstChild("HumanoidRootPart")

    if not myRoot then return nil end

    local nearest
    local nearestDistance = Config.AimRange

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= Player and GetRole(p):find("murder") then
            local character = p.Character
            local root = character
                and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")

            if root and humanoid and humanoid.Health > 0 then
                local distance =
                    (myRoot.Position-root.Position).Magnitude

                if distance < nearestDistance then
                    nearest = p
                    nearestDistance = distance
                end
            end
        end
    end

    return nearest
end

local function GetEquippedTool()
    local character = Player.Character
    if not character then return nil end

    for _,obj in ipairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            return obj
        end
    end

    return nil
end

AimButton.Activated:Connect(function()
    if not Config.Aim then return end

    local target = FindMurderTarget()

    if not target then
        AimButton.Text = "?"
        task.delay(1,function()
            AimButton.Text = "⊙"
        end)
        return
    end

    local character = target.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    Camera.CFrame = CFrame.lookAt(
        Camera.CFrame.Position,
        root.Position
    )

    local tool = GetEquippedTool()

    if tool then
        tool:Activate()
    end
end)

Button("🎯 AIM BUTTON",function(v)
    Config.Aim = v
    AimButton.Visible = v
end,true)

--==================================================
-- FLIGHT
--==================================================

local function StopFlight()
    Config.Flight = false

    if FlightVelocity then
        FlightVelocity:Destroy()
        FlightVelocity = nil
    end

    if FlightAttachment then
        FlightAttachment:Destroy()
        FlightAttachment = nil
    end

    local character = Player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    if FlightButtonUpdate then
        FlightButtonUpdate(false)
    end
end

local function StartFlight()
    local character = Player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return end

    Config.Flight = true

    FlightAttachment = Instance.new("Attachment")
    FlightAttachment.Parent = root

    FlightVelocity = Instance.new("LinearVelocity")
    FlightVelocity.Attachment0 = FlightAttachment
    FlightVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FlightVelocity.MaxForce = 100000
    FlightVelocity.VectorVelocity = Vector3.new(0,3,0)
    FlightVelocity.Parent = root

    humanoid.PlatformStand = true

    if FlightButtonUpdate then
        FlightButtonUpdate(true)
    end
end

local function ToggleFlight()
    if Config.Flight then
        StopFlight()
    else
        StartFlight()
    end
end

local _,setFlightButton = Button("✈ FLIGHT",ToggleFlight,true)
FlightButtonUpdate = setFlightButton

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1,-5,0,28)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.Text = "Speed: 55"
SpeedLabel.Parent = Holder

local function ChangeSpeed(amount)
    Config.Speed = math.clamp(
        Config.Speed+amount,15,Config.MaxSpeed
    )

    SpeedLabel.Text = "Speed: "..Config.Speed
end

Button("➕ เพิ่มความเร็ว",function()
    ChangeSpeed(10)
end)

Button("➖ ลดความเร็ว",function()
    ChangeSpeed(-10)
end)

--==================================================
-- MAIN UPDATE
--==================================================

local espTimer = 0

RunService.RenderStepped:Connect(function(dt)
    espTimer += dt

    if espTimer >= 0.2 then
        espTimer = 0
        UpdateESP()
    end

    if Config.Flight and FlightVelocity then
        local character = Player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            StopFlight()
            return
        end

        FlightVelocity.VectorVelocity =
            humanoid.MoveDirection*Config.Speed
            + Vector3.new(0,3,0)
    end
end)

--==================================================
-- INPUT PC / CONSOLE
--==================================================

UIS.InputBegan:Connect(function(input,processed)
    if processed then return end

    local key = input.KeyCode

    if key == Enum.KeyCode.T
        or key == Enum.KeyCode.ButtonR1 then

        TogglePanel()

    elseif key == Enum.KeyCode.F2
        or key == Enum.KeyCode.ButtonL2 then

        ToggleFlight()

    elseif key == Enum.KeyCode.F1
        or key == Enum.KeyCode.ButtonR2 then

        ChangeSpeed(10)

    elseif key == Enum.KeyCode.F3
        or key == Enum.KeyCode.ButtonL1 then

        ChangeSpeed(-10)
    end
end)

--==================================================
-- RESPAWN CLEANUP
--==================================================

Player.CharacterAdded:Connect(function()
    StopFlight()
    ClearESP()
end)

Players.PlayerRemoving:Connect(function(p)
    if Highlights[p] then
        Highlights[p]:Destroy()
        Highlights[p] = nil
    end
end)

print("ฆาตกร | ต้นฉบับ v1.3 โหลดสำเร็จ")
