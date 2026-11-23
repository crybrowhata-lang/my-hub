-- Charli_Skrippt | Fling Things & People | FINAL XENO EDITION (Claw Font & Fix)
-- Вставь в Xeno → Execute

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==== ОЧИСТКА ====
if CoreGui:FindFirstChild("Charli_FTAP_Menu") then CoreGui.Charli_FTAP_Menu:Destroy() end
if CoreGui:FindFirstChild("Charli_IntroGui") then CoreGui.Charli_IntroGui:Destroy() end
if Lighting:FindFirstChild("Charli_Blur") then Lighting.Charli_Blur:Destroy() end
local oldCircle = workspace:FindFirstChild("Charli_AimRadiusVisual")
if oldCircle then oldCircle:Destroy() end

-- ==== ТЕМА ====
local THEME = {
    Bg = Color3.fromRGB(20, 20, 20),
    Secondary = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(255, 215, 0),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(170, 170, 170),
    Red = Color3.fromRGB(255, 80, 80)
}

-- ==== ПЕРЕМЕННЫЕ ====
local aimbotEnabled = false
local espEnabled = false
local antiGrabEnabled = false
local grabAuraEnabled = false
local showNames = true
local showSkeleton = true
local aimDistance = 300
local aimFov = 150
local cameraFov = 70
local aimSmoothness = 0.25
local selectedPlayers = {}
local isGrabbingTarget = false
local grabReason = ""
local draggingSlider = false
local isMinimized = false
local isMenuOpen = false

-- ==================== 1. ЭФФЕКТ РАЗМЫТИЯ И ЗВУК ====================
local blur = Instance.new("BlurEffect")
blur.Name = "Charli_Blur"
blur.Size = 0
blur.Parent = Lighting

local loadSound = Instance.new("Sound")
loadSound.SoundId = "rbxassetid://5153763872"
loadSound.Volume = 0.5
loadSound.Parent = SoundService

-- ==================== 2. ИНТРО (ЗАСТАВКА) ====================
local introGui = Instance.new("ScreenGui")
introGui.Name = "Charli_IntroGui"
introGui.IgnoreGuiInset = true
introGui.DisplayOrder = 999
introGui.Parent = CoreGui

local introBg = Instance.new("Frame")
introBg.Size = UDim2.new(1, 0, 1, 0)
introBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
introBg.BackgroundTransparency = 1
introBg.Parent = introGui

-- Стилизованный логотип (ТЕКСТ ОТДЕЛЬНО)
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 400, 0, 100)
logo.Position = UDim2.new(0.5, 0, 0.5, 0) -- В центре
logo.AnchorPoint = Vector2.new(0.5, 0.5)
logo.BackgroundTransparency = 1
logo.Text = "🔱 C T" -- Лапка + Текст
logo.TextColor3 = Color3.fromRGB(255, 255, 0)
logo.TextTransparency = 1
logo.Font = Enum.Font.Creepster -- Шрифт "процарапанный когтями"
logo.TextSize = 80
logo.Parent = introBg

-- Обводка для эффекта царапин (кроваво-красная)
local logoStroke = Instance.new("UIStroke", logo)
logoStroke.Color = Color3.fromRGB(255, 255, 0)
logoStroke.Thickness = 3
logoStroke.Transparency = 1

-- Градиент, чтобы буквы были желто-золотыми
local logoGradient = Instance.new("UIGradient", logo)
logoGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEME.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 100, 0))
})

-- Полоса загрузки (ОТДЕЛЬНО ОТ ТЕКСТА)
local loadBg = Instance.new("Frame")
loadBg.Size = UDim2.new(0, 0, 0, 3) -- Изначально нулевая
loadBg.Position = UDim2.new(0.5, 0, 0.5, 0) -- Появляется ровно там, где был текст
loadBg.AnchorPoint = Vector2.new(0.5, 0.5)
loadBg.BackgroundColor3 = THEME.Secondary
loadBg.BackgroundTransparency = 1
loadBg.Parent = introBg
Instance.new("UICorner", loadBg).CornerRadius = UDim.new(0, 2)

local loadFill = Instance.new("Frame")
loadFill.Size = UDim2.new(0, 0, 1, 0)
loadFill.BackgroundColor3 = THEME.Accent
loadFill.BorderSizePixel = 0
loadFill.Parent = loadBg
Instance.new("UICorner", loadFill).CornerRadius = UDim.new(0, 2)

-- ==================== 3. ГЛАВНОЕ МЕНЮ ====================
local gui = Instance.new("ScreenGui")
gui.Name = "Charli_FTAP_Menu"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 0)
main.Position = UDim2.new(0.5, -140, 0.2, 0)
main.BackgroundColor3 = THEME.Bg
main.BackgroundTransparency = 1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.AutomaticSize = Enum.AutomaticSize.Y
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME.Accent
stroke.Thickness = 1.5
stroke.Transparency = 1

local uiScale = Instance.new("UIScale")
uiScale.Parent = main
uiScale.Scale = 0.95

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = main
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = main

-- Шапка
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = THEME.Secondary
header.BackgroundTransparency = 0.5
header.BorderSizePixel = 0
header.Parent = main
header.LayoutOrder = 1
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FTAP Hub | F9"
title.TextColor3 = THEME.Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -60, 0, 5)
minBtn.BackgroundColor3 = THEME.Accent
minBtn.BackgroundTransparency = 0.8
minBtn.BorderSizePixel = 0
minBtn.Text = "-"
minBtn.TextColor3 = THEME.Text
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = THEME.Red
closeBtn.BackgroundTransparency = 0.8
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = THEME.Text
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 15)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Статус: Ожидание..."
statusLabel.TextColor3 = THEME.SubText
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = main
statusLabel.LayoutOrder = 2

-- Сворачивание
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    minBtn.Text = isMinimized and "+" or "-"
    for _, child in pairs(main:GetChildren()) do
        if child ~= header and child:IsA("GuiObject") then
            child.Visible = not isMinimized
        end
    end
end)

-- ==== АНИМИРОВАННАЯ СЕКЦИЯ ====
local function createExpandableSection(text, defaultState, callback, order)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 30)
    sectionFrame.BackgroundColor3 = THEME.Secondary
    sectionFrame.BackgroundTransparency = 0.5
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Parent = main
    sectionFrame.LayoutOrder = order
    Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sectionFrame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 36, 0, 18)
    switch.Position = UDim2.new(1, -46, 0.5, -9)
    switch.BackgroundColor3 = defaultState and THEME.Accent or Color3.fromRGB(50, 50, 50)
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.Parent = sectionFrame
    Instance.new("UICorner", switch).CornerRadius = UDim.new(0, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)

    local settingsContainer = Instance.new("Frame")
    settingsContainer.Size = UDim2.new(1, 0, 0, 0)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.ClipsDescendants = true
    settingsContainer.Parent = main
    settingsContainer.LayoutOrder = order + 1
    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.Padding = UDim.new(0, 5)
    settingsLayout.Parent = settingsContainer

    local function toggleSettings(show)
        local targetSize = show and UDim2.new(1, 0, 0, settingsLayout.AbsoluteContentSize.Y + 5) or UDim2.new(1, 0, 0, 0)
        if show then task.wait(0.05) end
        if show then targetSize = UDim2.new(1, 0, 0, settingsLayout.AbsoluteContentSize.Y + 5) end
        TweenService:Create(settingsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = targetSize }):Play()
    end

    if defaultState then task.spawn(function() toggleSettings(true) end) end

    local state = defaultState
    switch.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switch, TweenInfo.new(0.2), { BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(50, 50, 50) }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }):Play()
        toggleSettings(state)
        callback(state)
    end)
    
    return settingsContainer
end

-- ==== ХЕЛПЕР ПОЛЗУНКА ====
local function createSlider(parent, text, minVal, maxVal, defaultVal, callback, isFloat)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = THEME.Bg
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 15)
    lbl.Position = UDim2.new(0, 5, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. (isFloat and string.format("%.2f", defaultVal) or tostring(defaultVal))
    lbl.TextColor3 = THEME.Accent
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -10, 0, 6)
    bg.Position = UDim2.new(0, 5, 0, 25)
    bg.BackgroundColor3 = THEME.Secondary
    bg.BorderSizePixel = 0
    bg.Parent = frame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)

    local percent = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 16, 0, 16)
    btn.Position = UDim2.new(percent, -8, 0.5, -8)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = bg
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relX = math.clamp(mousePos.X - bg.AbsolutePosition.X, 0, bg.AbsoluteSize.X)
            local p = relX / bg.AbsoluteSize.X
            local val = minVal + (p * (maxVal - minVal))
            
            if not isFloat then val = math.floor(val) end
            
            fill.Size = UDim2.new(p, 0, 1, 0)
            btn.Position = UDim2.new(p, -8, 0.5, -8)
            lbl.Text = text .. ": " .. (isFloat and string.format("%.2f", val) or tostring(val))
            callback(val)
        end
    end)
end

-- ==================== СЕКЦИИ ====================
local aimSettings = createExpandableSection("Enable Aimbot", false, function(state) aimbotEnabled = state end, 3)
createSlider(aimSettings, "Aim Distance (Studs)", 50, 1000, aimDistance, function(val) aimDistance = val end)
createSlider(aimSettings, "Aim FOV (Pixels)", 50, 500, aimFov, function(val) aimFov = val end)
createSlider(aimSettings, "Smoothness (1=Fast)", 0.05, 1.0, aimSmoothness, function(val) aimSmoothness = val end, true)

local showAimFovToggle = Instance.new("TextButton")
showAimFovToggle.Size = UDim2.new(1, 0, 0, 25)
showAimFovToggle.BackgroundColor3 = THEME.Bg
showAimFovToggle.BackgroundTransparency = 0.5
showAimFovToggle.Text = " Show Aim FOV Circle"
showAimFovToggle.TextColor3 = THEME.Accent
showAimFovToggle.Font = Enum.Font.Gotham
showAimFovToggle.TextSize = 11
showAimFovToggle.TextXAlignment = Enum.TextXAlignment.Left
showAimFovToggle.Parent = aimSettings
Instance.new("UICorner", showAimFovToggle).CornerRadius = UDim.new(0, 4)

local ftapSettings = createExpandableSection("FTAP Features", false, function(state) end, 5)
local function createSimpleToggle(parent, text, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.BackgroundColor3 = THEME.Bg
    btn.BackgroundTransparency = 0.5
    btn.Text = " " .. text
    btn.TextColor3 = defaultState and THEME.Accent or THEME.SubText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.TextColor3 = state and THEME.Accent or THEME.SubText
        callback(state)
    end)
end
createSimpleToggle(ftapSettings, "Anti-Grab (Защита от захвата)", false, function(s) antiGrabEnabled = s end)
createSimpleToggle(ftapSettings, "Grab Aura (Авто-наводка)", false, function(s) grabAuraEnabled = s end)

local espSettings = createExpandableSection("Enable ESP (Wallhack)", false, function(state) espEnabled = state end, 7)
createSimpleToggle(espSettings, "Show Names", true, function(s) showNames = s end)
createSimpleToggle(espSettings, "Show Skeleton", true, function(s) showSkeleton = s end)

local camFovSettings = createExpandableSection("Camera Settings", false, function(state) end, 9)
createSlider(camFovSettings, "Camera FOV", 30, 120, cameraFov, function(val) cameraFov = val; if Camera then Camera.FieldOfView = val end end)

local miscSettings = createExpandableSection("Misc (Noclip / Jump)", false, function(state) end, 11)
createSimpleToggle(miscSettings, "Noclip (Проход сквозь стены)", false, function(s) noclipEnabled = s end)
createSimpleToggle(miscSettings, "Infinite Jump (Беск. прыжок)", false, function(s) infJumpEnabled = s end)

-- ==================== СПИСОК ЦЕЛЕЙ & ПОИСК ====================
local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, 0, 0, 20)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "TARGETS"
targetLabel.TextColor3 = THEME.Accent
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextSize = 11
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = main
targetLabel.LayoutOrder = 13

local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(1, 0, 0, 25)
searchBar.BackgroundColor3 = THEME.Secondary
searchBar.BackgroundTransparency = 0.5
searchBar.BorderSizePixel = 0
searchBar.Text = ""
searchBar.PlaceholderText = "Поиск игрока..."
searchBar.PlaceholderColor3 = THEME.SubText
searchBar.TextColor3 = THEME.Text
searchBar.Font = Enum.Font.Gotham
searchBar.TextSize = 11
searchBar.Parent = main
searchBar.LayoutOrder = 14
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 4)

local selectAllBtn = Instance.new("TextButton")
selectAllBtn.Size = UDim2.new(1, 0, 0, 25)
selectAllBtn.BackgroundColor3 = THEME.Secondary
selectAllBtn.BackgroundTransparency = 0.5
selectAllBtn.BorderSizePixel = 0
selectAllBtn.Text = "Выбрать всех / Снять всех"
selectAllBtn.TextColor3 = THEME.Accent
selectAllBtn.Font = Enum.Font.GothamBold
selectAllBtn.TextSize = 11
selectAllBtn.Parent = main
selectAllBtn.LayoutOrder = 15
Instance.new("UICorner", selectAllBtn).CornerRadius = UDim.new(0, 4)

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, 0, 0, 100)
playerListFrame.BackgroundColor3 = THEME.Secondary
playerListFrame.BackgroundTransparency = 0.5
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 4
playerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.Parent = main
playerListFrame.LayoutOrder = 16
Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 6)
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = playerListFrame

local playerButtons = {}
local function refreshPlayerList()
    for _, btn in pairs(playerButtons) do btn:Destroy() end
    playerButtons = {}
    
    local searchText = string.lower(searchBar.Text)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if searchText == "" or string.find(string.lower(player.Name), searchText) then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 24)
                btn.BackgroundColor3 = selectedPlayers[player] and THEME.Accent or THEME.Bg
                btn.BackgroundTransparency = 0.7
                btn.BorderSizePixel = 0
                btn.Text = player.Name
                btn.TextColor3 = selectedPlayers[player] and THEME.Accent or THEME.SubText
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = playerListFrame
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                btn.MouseButton1Click:Connect(function()
                    selectedPlayers[player] = not selectedPlayers[player]
                    btn.BackgroundColor3 = selectedPlayers[player] and THEME.Accent or THEME.Bg
                    btn.TextColor3 = selectedPlayers[player] and THEME.Accent or THEME.SubText
                end)
                table.insert(playerButtons, btn)
            end
        end
    end
end

searchBar:GetPropertyChangedSignal("Text"):Connect(refreshPlayerList)

selectAllBtn.MouseButton1Click:Connect(function()
    local anySelected = false
    for _, isSel in pairs(selectedPlayers) do if isSel then anySelected = true break end end
    local newState = not anySelected
    
    local searchText = string.lower(searchBar.Text)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if searchText == "" or string.find(string.lower(player.Name), searchText) then
                selectedPlayers[player] = newState
            end
        end
    end
    refreshPlayerList()
end)

refreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(1) refreshPlayerList() end)
Players.PlayerRemoving:Connect(function(player) selectedPlayers[player] = nil; refreshPlayerList() end)

-- ==================== ДЕТЕКТОР ЗАХВАТА ====================
local function isGrabbing()
    local char = LocalPlayer.Character
    if not char then return false, "" end
    if char:FindFirstChildOfClass("Tool") then return true, "Tool" end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                local animName = track.Animation.Name:lower()
                if animName:find("grab") or animName:find("hold") or animName:find("fling") or animName:find("carry") then
                    return true, "Anim"
                end
            end
        end
    end

    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") or v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
            local p0 = v.Part0 or v.Attachment0
            local p1 = v.Part1 or v.Attachment1
            if p0 and p1 then
                if p1.Parent ~= char and p1.Parent and p1.Parent:FindFirstChild("Humanoid") then return true, "Weld" end
                if p0.Parent ~= char and p0.Parent and p0.Parent:FindFirstChild("Humanoid") then return true, "Weld" end
            end
        end
    end
    return false, ""
end

-- ==================== ANTI-GRAB & GRAB AURA ====================
RunService.Heartbeat:Connect(function()
    if antiGrabEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                for _, joint in pairs(part:GetJoints()) do
                    if joint:IsA("Weld") or joint:IsA("WeldConstraint") or joint:IsA("AlignPosition") then
                        local p1 = joint.Part1
                        if p1 and p1.Parent ~= LocalPlayer.Character and p1.Parent:FindFirstChild("Humanoid") then joint:Destroy() end
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if grabAuraEnabled and not isGrabbingTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        local closest = nil
        local minDist = 50
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local dist = (myPos - player.Character.Head.Position).Magnitude
                if dist < minDist then minDist = dist; closest = player.Character.Head end
            end
        end
        if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
    end
end)

-- ==================== 3D РАДИУС & 2D FOV ====================
local radiusVisual = Instance.new("Part")
radiusVisual.Name = "Charli_AimRadiusVisual"
radiusVisual.Shape = Enum.PartType.Cylinder
radiusVisual.Size = Vector3.new(aimDistance * 2, 0.1, aimDistance * 2)
radiusVisual.CFrame = CFrame.new(0, -100, 0)
radiusVisual.Anchored = true
radiusVisual.CanCollide = false
radiusVisual.Transparency = 1
radiusVisual.Color = THEME.Accent
radiusVisual.Material = Enum.Material.Neon
radiusVisual.Parent = workspace

local aimFovCircle = Drawing.new("Circle")
aimFovCircle.Thickness = 2
aimFovCircle.NumSides = 64
aimFovCircle.Radius = aimFov
aimFovCircle.Filled = false
aimFovCircle.Color = THEME.Accent
aimFovCircle.Transparency = 1
aimFovCircle.Visible = false

local showAimFov = false
showAimFovToggle.MouseButton1Click:Connect(function()
    showAimFov = not showAimFov
    showAimFovToggle.TextColor3 = showAimFov and THEME.Accent or THEME.SubText
    aimFovCircle.Visible = showAimFov
end)

-- ==================== NOCLIP & JUMP ====================
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ==================== ESP РЕНДЕР ====================
local espDrawings = {}
local function clearESP() for _, d in pairs(espDrawings) do d:Remove() end; espDrawings = {} end
local function drawESP()
    clearESP()
    if not espEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                if showNames then
                    local text = Drawing.new("Text")
                    text.Text = player.Name
                    text.Color = THEME.Accent
                    text.Size = 14
                    text.Center = true
                    text.Outline = true
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    text.Position = Vector2.new(pos.X, pos.Y - 20)
                    text.Visible = onScreen
                    table.insert(espDrawings, text)
                end
                if showSkeleton then
                    local parts = {
                        Head = head,
                        Torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso"),
                        Lower = player.Character:FindFirstChild("LowerTorso") or player.Character:FindFirstChild("Torso"),
                        LArm = player.Character:FindFirstChild("LeftUpperArm") or player.Character:FindFirstChild("Left Arm"),
                        RArm = player.Character:FindFirstChild("RightUpperArm") or player.Character:FindFirstChild("Right Arm"),
                        LLeg = player.Character:FindFirstChild("LeftUpperLeg") or player.Character:FindFirstChild("Left Leg"),
                        RLeg = player.Character:FindFirstChild("RightUpperLeg") or player.Character:FindFirstChild("Right Leg"),
                    }
                    local lines = {{"Head","Torso"},{"Torso","Lower"},{"Torso","LArm"},{"Torso","RArm"},{"Lower","LLeg"},{"Lower","RLeg"}}
                    for _, pair in pairs(lines) do
                        local p1, p2 = parts[pair[1]], parts[pair[2]]
                        if p1 and p2 then
                            local pos1, on1 = Camera:WorldToViewportPoint(p1.Position)
                            local pos2, on2 = Camera:WorldToViewportPoint(p2.Position)
                            local line = Drawing.new("Line")
                            line.Thickness = 1
                            line.Color = THEME.Accent
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                            line.Visible = on1 and on2
                            table.insert(espDrawings, line)
                        end
                    end
                end
            end
        end
    end
end

-- ==================== ОСНОВНОЙ ЦИКЛ ====================
RunService.RenderStepped:Connect(function()
    if showAimFov then
        aimFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        aimFovCircle.Radius = aimFov
    end

    if draggingSlider and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        radiusVisual.Size = Vector3.new(aimDistance * 2, 0.1, aimDistance * 2)
        radiusVisual.Transparency = 0.5
        radiusVisual.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 2.8, 0))
    else
        radiusVisual.Transparency = 1
    end

    isGrabbingTarget, grabReason = isGrabbing()
    if isGrabbingTarget then
        statusLabel.Text = "Статус: Захват [" .. grabReason .. "] (Аим выкл)"
        statusLabel.TextColor3 = THEME.Red
    else
        statusLabel.Text = "Статус: Ожидание..."
        statusLabel.TextColor3 = THEME.SubText
    end

    if aimbotEnabled and not isGrabbingTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        local closest = nil
        local minDist = aimDistance
        for player, isSel in pairs(selectedPlayers) do
            if isSel and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local targetPos = player.Character.Head.Position
                local dist = (myPos - targetPos).Magnitude
                if dist <= aimDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if onScreen and (not showAimFov or distToCenter <= aimFov) then
                        if dist < minDist then minDist = dist; closest = player.Character.Head end
                    end
                end
            end
        end
        if closest then
            local lookAt = CFrame.new(Camera.CFrame.Position, closest.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, aimSmoothness)
        end
    end
    drawESP()
end)

-- ==================== 4. ПЛАВНЫЕ АНИМАЦИИ МЕНЮ ====================
local function playOpenAnimation()
    main.Visible = true
    main.BackgroundTransparency = 1
    stroke.Transparency = 1
    uiScale.Scale = 0.95
    isMenuOpen = true
    
    TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.1 }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.3 }):Play()
    TweenService:Create(uiScale, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

local function playCloseAnimation()
    isMenuOpen = false
    local tween = TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
    local tweenStroke = TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 })
    local tweenScale = TweenService:Create(uiScale, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.95 })
    
    tween:Play()
    tweenStroke:Play()
    tweenScale:Play()
    
    tween.Completed:Connect(function()
        main.Visible = false
        main.BackgroundTransparency = 0.1
        stroke.Transparency = 0.3
        uiScale.Scale = 1
    end)
end

-- ==================== 5. ЛОГИКА ИНТРО ====================
local function runIntro()
    pcall(function() loadSound:Play() end)
    task.wait(0.5)
    
    -- 1. Размытие и затемнение
    TweenService:Create(blur, TweenInfo.new(1, Enum.EasingStyle.Quad), { Size = 24 }):Play()
    TweenService:Create(introBg, TweenInfo.new(1, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.4 }):Play()
    task.wait(0.5)
    
    -- 2. Плавное появление логотипа
    TweenService:Create(logo, TweenInfo.new(1.2, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
    TweenService:Create(logoStroke, TweenInfo.new(1.2, Enum.EasingStyle.Quad), { Transparency = 0 }):Play()
    task.wait(1.5)
    
    -- 3. Текст уезжает вверх, а полоса загрузки появляется на ЕГО МЕСТЕ (по центру)
    TweenService:Create(logo, TweenInfo.new(0.8, Enum.EasingStyle.Quad), { Position = UDim2.new(0.5, 0, 0.42, 0) }):Play()
    TweenService:Create(loadBg, TweenInfo.new(0.8, Enum.EasingStyle.Quad), { 
        BackgroundTransparency = 0.3, Size = UDim2.new(0, 200, 0, 4) 
    }):Play()
    task.wait(0.8)
    
    -- 4. Заполнение полосы
    TweenService:Create(loadFill, TweenInfo.new(2, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) }):Play()
    task.wait(2.2)
    
    -- 5. Плавное затухание
    TweenService:Create(loadFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(loadBg, TweenInfo.new(1.5, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(logo, TweenInfo.new(1.5, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
    TweenService:Create(logoStroke, TweenInfo.new(1.5, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()
    TweenService:Create(introBg, TweenInfo.new(1.5, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(blur, TweenInfo.new(1.5, Enum.EasingStyle.Quad), { Size = 0 }):Play()
    TweenService:Create(loadSound, TweenInfo.new(1.5, Enum.EasingStyle.Quad), { Volume = 0 }):Play()
    task.wait(1.6)
    
    -- 6. Удаляем интро
    introGui:Destroy()
    loadSound:Destroy()
    playOpenAnimation()
end

-- ==================== F9 / ЗАКРЫТИЕ ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        if isMenuOpen then
            playCloseAnimation()
        else
            playOpenAnimation()
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    playCloseAnimation()
    clearESP()
    aimFovCircle.Visible = false
end)

-- ==================== ЗАПУСК ====================
task.spawn(runIntro)

print("[Charli_Skrippt] FTAP FINAL Edition loaded. Claw Font & Fixed Loading Bar.")
