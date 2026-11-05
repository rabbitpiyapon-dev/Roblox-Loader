
--========================================================
-- OGHub | EMERGENCY HAMBURG
-- ต้นฉบับ v1.0
-- PC + MOBILE
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local PURPLE = Color3.fromRGB(155, 75, 255)
local DARK = Color3.fromRGB(15, 12, 23)
local BLUE = Color3.fromRGB(25, 115, 255)
local WHITE = Color3.fromRGB(255,255,255)

local old = PlayerGui:FindFirstChild("OGHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "OGHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius)
    c.Parent = obj
end

local function stroke(obj,color,thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1.5
    s.Parent = obj
end

local function label(parent,text,size,color)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextSize = size
    t.TextColor3 = color
    t.Font = Enum.Font.GothamBold
    t.Parent = parent
    return t
end

--========================================================
-- INTRO
--========================================================

local intro = Instance.new("Frame")
intro.Size = UDim2.fromScale(1,1)
intro.BackgroundColor3 = Color3.new(0,0,0)
intro.BackgroundTransparency = 0.28
intro.Parent = gui

local introText = label(intro,"OGHub",34,PURPLE)
introText.Size = UDim2.new(1,0,0,65)
introText.Position = UDim2.fromScale(0,0.43)

local introStroke = Instance.new("UIStroke")
introStroke.Color = Color3.fromRGB(220,190,255)
introStroke.Thickness = 0.7
introStroke.Parent = introText

task.delay(3,function()
    TweenService:Create(intro,TweenInfo.new(0.5),{
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(introText,TweenInfo.new(0.5),{
        TextTransparency = 1
    }):Play()
    task.wait(0.55)
    intro:Destroy()
end)

--========================================================
-- OPEN BUTTON
--========================================================

local open = Instance.new("TextButton")
open.Name = "OpenButton"
open.Size = UDim2.fromOffset(49,49)
open.Position = UDim2.new(1,-65,0,25)
open.BackgroundColor3 = BLUE
open.Text = "OG"
open.TextColor3 = WHITE
open.TextSize = 15
open.Font = Enum.Font.GothamBlack
open.Parent = gui
corner(open,100)
stroke(open,Color3.fromRGB(130,190,255),2)

--========================================================
-- MAIN WINDOW
--========================================================

local main = Instance.new("Frame")
main.Name = "MainWindow"
main.Size = UDim2.new(0.85,0,0,390)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = DARK
main.Visible = false
main.Parent = gui
corner(main,14)
stroke(main,PURPLE,2)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(430,500)
sizeConstraint.MinSize = Vector2.new(280,300)
sizeConstraint.Parent = main

-- Header

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,58)
header.BackgroundColor3 = Color3.fromRGB(42,24,62)
header.Parent = main
corner(header,12)

local title = label(header,"EMERGENCY HAMBURG",17,WHITE)
title.Position = UDim2.new(0,15,0,0)
title.Size = UDim2.new(1,-65,1,0)
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35,35)
close.Position = UDim2.new(1,-43,0,11)
close.BackgroundColor3 = Color3.fromRGB(100,35,55)
close.Text = "X"
close.TextColor3 = WHITE
close.Font = Enum.Font.GothamBold
close.TextSize = 17
close.Parent = header
corner(close,9)

-- Content

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1,-24,1,-75)
content.Position = UDim2.new(0,12,0,67)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = PURPLE
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new()
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,9)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function makeButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-5,0,43)
    b.BackgroundColor3 = Color3.fromRGB(39,29,53)
    b.Text = text
    b.TextColor3 = WHITE
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = content
    corner(b,9)
    stroke(b,Color3.fromRGB(80,55,110),1)
    return b
end

local function section(text)
    local t = label(content,text,13,PURPLE)
    t.Size = UDim2.new(1,0,0,25)
    t.TextXAlignment = Enum.TextXAlignment.Left
    return t
end

--========================================================
-- ESP
--========================================================

section("01  |  PLAYER & VEHICLE ESP")

local espEnabled = false
local vehicleEnabled = false

local espButton = makeButton("PLAYER ESP : OFF")
local vehicleButton = makeButton("VEHICLE ESP : OFF")

local teamColors = {
    police = Color3.fromRGB(65,160,255),
    firefighter = Color3.fromRGB(255,65,65),
    fire = Color3.fromRGB(255,65,65),
    medic = Color3.fromRGB(255,65,65),
    criminal = Color3.fromRGB(255,220,40)
}

local function getTeamInfo(plr)
    local name = plr.Team and plr.Team.Name:lower() or ""

    if name:find("police") then
        return "POLICE",teamColors.police
    elseif name:find("fire") then
        return "FIREFIGHTER",teamColors.firefighter
    elseif name:find("medic") or name:find("doctor") then
        return "MEDIC",teamColors.medic
    elseif name:find("criminal") or name:find("robber") then
        return "CRIMINAL",teamColors.criminal
    end

    return "PLAYER",Color3.fromRGB(210,210,210)
end

local playerObjects = {}

local function clearPlayer(plr)
    local data = playerObjects[plr]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        playerObjects[plr] = nil
    end
end

local function createPlayerESP(plr)
    if plr == Player then return end

    local char = plr.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    if not head then return end

    if not playerObjects[plr] then
        local h = Instance.new("Highlight")
        h.Name = "OGHubHighlight"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char

        local bill = Instance.new("BillboardGui")
        bill.Name = "OGHubPlayerInfo"
        bill.Size = UDim2.fromOffset(180,48)
        bill.StudsOffset = Vector3.new(0,3,0)
        bill.AlwaysOnTop = true
        bill.Adornee = head
        bill.Parent = gui

        local txt = label(bill,"",12,WHITE)
        txt.Size = UDim2.fromScale(1,1)
        txt.TextStrokeTransparency = 0.2

        playerObjects[plr] = {
            highlight = h,
            billboard = bill,
            text = txt
        }
    end

    local data = playerObjects[plr]
    local team,color = getTeamInfo(plr)

    data.highlight.Adornee = char
    data.highlight.FillColor = color
    data.highlight.OutlineColor = color
    data.highlight.FillTransparency = 0.55
    data.highlight.OutlineTransparency = 0.1

    data.billboard.Adornee = head

    local myChar = Player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local root = char:FindFirstChild("HumanoidRootPart")

    if myRoot and root then
        local meters = math.floor((myRoot.Position-root.Position).Magnitude*0.28)
        data.text.Text = team.." | "..plr.Name.."\n"..meters.." M"
    end
end

local function updateESP()
    if not espEnabled then
        for plr in pairs(playerObjects) do
            clearPlayer(plr)
        end
        return
    end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            createPlayerESP(plr)
        end
    end

    for plr in pairs(playerObjects) do
        if not plr.Parent then
            clearPlayer(plr)
        end
    end
end

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "PLAYER ESP : "..(espEnabled and "ON" or "OFF")
    espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(65,35,100) or Color3.fromRGB(39,29,53)
    if not espEnabled then updateESP() end
end)

--========================================================
-- VEHICLE ESP
-- Models must have CollectionService tag:
-- OGHubVehicle
-- OwnerUserId attribute = vehicle owner's UserId
--========================================================

local vehicleObjects = {}

local function clearVehicles()
    for model,data in pairs(vehicleObjects) do
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        vehicleObjects[model] = nil
    end
end

local function updateVehicles()
    if not vehicleEnabled then
        clearVehicles()
        return
    end

    local myChar = Player.Character
    local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _,model in ipairs(CollectionService:GetTagged("OGHubVehicle")) do
        if model:IsA("Model") and model.Parent then
            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart",true)
            if part then
                local data = vehicleObjects[model]

                if not data then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255,45,45)
                    h.OutlineColor = Color3.fromRGB(255,100,100)
                    h.FillTransparency = 0.55
                    h.Parent = model

                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.fromOffset(200,45)
                    bill.StudsOffset = Vector3.new(0,4,0)
                    bill.AlwaysOnTop = true
                    bill.Adornee = part
                    bill.Parent = gui

                    local txt = label(bill,"",12,Color3.fromRGB(255,100,100))
                    txt.Size = UDim2.fromScale(1,1)

                    data = {highlight=h,billboard=bill,text=txt}
                    vehicleObjects[model] = data
                end

                data.billboard.Adornee = part

                local ownerId = model:GetAttribute("OwnerUserId")
                local owner = ownerId and Players:GetPlayerByUserId(ownerId)
                local ownerName = owner and owner.Name or "UNKNOWN"

                local meters = math.floor((root.Position-part.Position).Magnitude*0.28)
                data.text.Text = "VEHICLE: "..ownerName.."\n"..meters.." M"
            end
        end
    end

    for model,data in pairs(vehicleObjects) do
        if not model.Parent or not CollectionService:HasTag(model,"OGHubVehicle") then
            data.highlight:Destroy()
            data.billboard:Destroy()
            vehicleObjects[model] = nil
        end
    end
end

vehicleButton.MouseButton1Click:Connect(function()
    vehicleEnabled = not vehicleEnabled
    vehicleButton.Text = "VEHICLE ESP : "..(vehicleEnabled and "ON" or "OFF")
    if not vehicleEnabled then clearVehicles() end
end)

--========================================================
-- POLICE PROXIMITY ALERT
-- Always active - does not require ESP
--========================================================

local alertBillboard
local alertText
local blink = false

local function setupAlert(character)
    if alertBillboard then
        alertBillboard:Destroy()
    end

    local head = character:WaitForChild("Head",5)
    if not head then return end

    alertBillboard = Instance.new("BillboardGui")
    alertBillboard.Name = "OGHubPoliceAlert"
    alertBillboard.Size = UDim2.fromOffset(65,65)
    alertBillboard.StudsOffset = Vector3.new(0,3.5,0)
    alertBillboard.AlwaysOnTop = true
    alertBillboard.Adornee = head
    alertBillboard.Parent = gui

    alertText = label(alertBillboard,"!",35,WHITE)
    alertText.Size = UDim2.fromScale(1,1)
    alertText.TextStrokeTransparency = 0.2
end

if Player.Character then
    task.spawn(setupAlert,Player.Character)
end

Player.CharacterAdded:Connect(function(char)
    task.spawn(setupAlert,char)
end)

local function updatePoliceAlert()
    if not alertText then return end

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local nearest = math.huge

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local team = getTeamInfo(plr)

            if team == "POLICE" then
                local other = plr.Character
                local otherRoot = other and other:FindFirstChild("HumanoidRootPart")

                if otherRoot then
                    local distance = (root.Position-otherRoot.Position).Magnitude*0.28
                    nearest = math.min(nearest,distance)
                end
            end
        end
    end

    if nearest <= 5 then
        blink = not blink
        alertText.TextColor3 = blink and Color3.fromRGB(255,0,0) or Color3.new(0,0,0)
    elseif nearest <= 50 then
        alertText.TextColor3 = Color3.fromRGB(255,30,30)
    elseif nearest <= 100 then
        alertText.TextColor3 = Color3.fromRGB(255,220,0)
    elseif nearest <= 1000 then
        alertText.TextColor3 = WHITE
    else
        alertText.TextColor3 = WHITE
    end

    alertText.Visible = nearest <= 1000
end

--========================================================
-- WEAPON SETTINGS
-- UI ONLY - server weapon logic required
--========================================================

section("02  |  WEAPON SETTINGS")

local weaponButton = makeButton("WEAPON SETTINGS : OPEN")

local weaponPanel = Instance.new("Frame")
weaponPanel.Size = UDim2.new(1,-5,0,0)
weaponPanel.BackgroundColor3 = Color3.fromRGB(29,21,41)
weaponPanel.ClipsDescendants = true
weaponPanel.Parent = content
corner(weaponPanel,9)

local weaponLayout = Instance.new("UIListLayout")
weaponLayout.Padding = UDim.new(0,4)
weaponLayout.Parent = weaponPanel

local weaponNames = {
    "G36",
    "GLOCK 17",
    "SNIPER",
    "M58B SHOTGUN",
    "MP5",
    "M4 CARBINE"
}

local selectedWeapon = "G36"

local weaponLabel = label(weaponPanel,"SELECTED: G36",13,PURPLE)
weaponLabel.Size = UDim2.new(1,-10,0,30)

for _,name in ipairs(weaponNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,32)
    b.Position = UDim2.new(0,5,0,0)
    b.BackgroundColor3 = Color3.fromRGB(53,35,72)
    b.Text = name
    b.TextColor3 = WHITE
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = weaponPanel
    corner(b,6)

    b.MouseButton1Click:Connect(function()
        selectedWeapon = name
        weaponLabel.Text = "SELECTED: "..name
    end)
end

local weaponOpen = false

weaponButton.MouseButton1Click:Connect(function()
    weaponOpen = not weaponOpen
    weaponButton.Text = "WEAPON SETTINGS : "..(weaponOpen and "CLOSE" or "OPEN")
    weaponPanel.Size = UDim2.new(1,-5,0,weaponOpen and 245 or 0)
end)

--========================================================
-- GUI CONTROL
--========================================================

local function toggleGUI()
    main.Visible = not main.Visible
end

open.MouseButton1Click:Connect(toggleGUI)

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

UIS.InputBegan:Connect(function(input,processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.F1 then
        toggleGUI()
    end
end)

--========================================================
-- UPDATE LOOP
--========================================================

task.spawn(function()
    while gui.Parent do
        updateESP()
        updateVehicles()
        updatePoliceAlert()
        task.wait(0.25)
    end
end)

print("OGHub Emergency Hamburg v1.0 Loaded")
