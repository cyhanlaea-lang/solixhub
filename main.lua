-- Solix Hub - No Dependencies Version
repeat wait() until game:IsLoaded()

print("🎮 Solix Hub - Standalone Version Loading...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- Wait for character
if not Player.Character then
    Player.CharacterAdded:Wait()
end

local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("✅ Game loaded successfully")

-- Create COMPLETELY CUSTOM GUI (no external libraries)
local function CreateCustomGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SolixHub"
    ScreenGui.Parent = game.CoreGui

    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = UDim2.new(0, 450, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 100, 100)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Position = UDim2.new(0.1, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Solix Hub - Blox Fruits"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = TitleBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Parent = TitleBar

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Tab Buttons
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local Tabs = {"Main", "Combat", "Teleport", "Player"}
    local CurrentTab = "Main"

    for i, tabName in pairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Tab"
        TabButton.Size = UDim2.new(0.25, 0, 1, 0)
        TabButton.Position = UDim2.new(0.25 * (i-1), 0, 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 14
        TabButton.Parent = TabContainer

        TabButton.MouseButton1Click:Connect(function()
            CurrentTab = tabName
            UpdateTabContent(tabName)
        end)
    end

    -- Content Area
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -100)
    ContentFrame.Position = UDim2.new(0, 10, 0, 90)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    -- Dragging Function
    local dragging = false
    local dragInput, dragStart, startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Create Tab Content
    local function CreateMainTab()
        local MainContent = Instance.new("Frame")
        MainContent.Name = "MainContent"
        MainContent.Size = UDim2.new(1, 0, 1, 0)
        MainContent.BackgroundTransparency = 1
        MainContent.Visible = false
        MainContent.Parent = ContentFrame

        -- Auto Farming Section
        local FarmingLabel = Instance.new("TextLabel")
        FarmingLabel.Size = UDim2.new(1, 0, 0, 30)
        FarmingLabel.Position = UDim2.new(0, 0, 0, 0)
        FarmingLabel.BackgroundTransparency = 1
        FarmingLabel.Text = "🎯 AUTO FARMING"
        FarmingLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        FarmingLabel.TextSize = 16
        FarmingLabel.Font = Enum.Font.GothamBold
        FarmingLabel.Parent = MainContent

        -- Auto Farm Toggle
        local AutoFarmToggle = Instance.new("TextButton")
        AutoFarmToggle.Name = "AutoFarmToggle"
        AutoFarmToggle.Size = UDim2.new(1, 0, 0, 35)
        AutoFarmToggle.Position = UDim2.new(0, 0, 0, 35)
        AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        AutoFarmToggle.Text = "❌ Auto Farm: OFF"
        AutoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        AutoFarmToggle.TextSize = 14
        AutoFarmToggle.Parent = MainContent

        local AutoFarmEnabled = false
        AutoFarmToggle.MouseButton1Click:Connect(function()
            AutoFarmEnabled = not AutoFarmEnabled
            if AutoFarmEnabled then
                AutoFarmToggle.Text = "✅ Auto Farm: ON"
                AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                StartAutoFarm()
            else
                AutoFarmToggle.Text = "❌ Auto Farm: OFF"
                AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end)

        -- Auto Melee Toggle
        local AutoMeleeToggle = Instance.new("TextButton")
        AutoMeleeToggle.Name = "AutoMeleeToggle"
        AutoMeleeToggle.Size = UDim2.new(1, 0, 0, 35)
        AutoMeleeToggle.Position = UDim2.new(0, 0, 0, 75)
        AutoMeleeToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        AutoMeleeToggle.Text = "❌ Auto Melee: OFF"
        AutoMeleeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        AutoMeleeToggle.TextSize = 14
        AutoMeleeToggle.Parent = MainContent

        local AutoMeleeEnabled = false
        AutoMeleeToggle.MouseButton1Click:Connect(function()
            AutoMeleeEnabled = not AutoMeleeEnabled
            if AutoMeleeEnabled then
                AutoMeleeToggle.Text = "✅ Auto Melee: ON"
                AutoMeleeToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            else
                AutoMeleeToggle.Text = "❌ Auto Melee: OFF"
                AutoMeleeToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end)

        -- Boss Farming Section
        local BossLabel = Instance.new("TextLabel")
        BossLabel.Size = UDim2.new(1, 0, 0, 30)
        BossLabel.Position = UDim2.new(0, 0, 0, 125)
        BossLabel.BackgroundTransparency = 1
        BossLabel.Text = "👹 BOSS FARMING"
        BossLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        BossLabel.TextSize = 16
        BossLabel.Font = Enum.Font.GothamBold
        BossLabel.Parent = MainContent

        -- Boss Dropdown
        local BossDropdown = Instance.new("TextButton")
        BossDropdown.Name = "BossDropdown"
        BossDropdown.Size = UDim2.new(1, 0, 0, 35)
        BossDropdown.Position = UDim2.new(0, 0, 0, 160)
        BossDropdown.BackgroundColor3 = Color3.fromRGB(80, 60, 0)
        BossDropdown.Text = "Select Boss ▼"
        BossDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        BossDropdown.TextSize = 14
        BossDropdown.Parent = MainContent

        local BossOptions = {"Greybeard", "Saber Expert", "Dark Beard", "Warden"}
        local SelectedBoss = ""

        BossDropdown.MouseButton1Click:Connect(function()
            -- Simple boss selection
            for i, boss in pairs(BossOptions) do
                wait(0.1)
                BossDropdown.Text = "> " .. boss
            end
            BossDropdown.Text = "Select Boss ▼"
            SelectedBoss = BossOptions[1] -- Just select first for demo
        end)

        -- Auto Boss Toggle
        local AutoBossToggle = Instance.new("TextButton")
        AutoBossToggle.Name = "AutoBossToggle"
        AutoBossToggle.Size = UDim2.new(1, 0, 0, 35)
        AutoBossToggle.Position = UDim2.new(0, 0, 0, 200)
        AutoBossToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        AutoBossToggle.Text = "❌ Auto Boss: OFF"
        AutoBossToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        AutoBossToggle.TextSize = 14
        AutoBossToggle.Parent = MainContent

        local AutoBossEnabled = false
        AutoBossToggle.MouseButton1Click:Connect(function()
            AutoBossEnabled = not AutoBossEnabled
            if AutoBossEnabled then
                AutoBossToggle.Text = "✅ Auto Boss: ON"
                AutoBossToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                StartBossFarm(SelectedBoss)
            else
                AutoBossToggle.Text = "❌ Auto Boss: OFF"
                AutoBossToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end)

        return MainContent
    end

    local function CreateCombatTab()
        local CombatContent = Instance.new("Frame")
        CombatContent.Name = "CombatContent"
        CombatContent.Size = UDim2.new(1, 0, 1, 0)
        CombatContent.BackgroundTransparency = 1
        CombatContent.Visible = false
        CombatContent.Parent = ContentFrame

        local CombatLabel = Instance.new("TextLabel")
        CombatLabel.Size = UDim2.new(1, 0, 0, 30)
        CombatLabel.Position = UDim2.new(0, 0, 0, 0)
        CombatLabel.BackgroundTransparency = 1
        CombatLabel.Text = "⚔️ COMBAT FEATURES"
        CombatLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        CombatLabel.TextSize = 16
        CombatLabel.Font = Enum.Font.GothamBold
        CombatLabel.Parent = CombatContent

        -- Aimbot Toggle
        local AimbotToggle = Instance.new("TextButton")
        AimbotToggle.Name = "AimbotToggle"
        AimbotToggle.Size = UDim2.new(1, 0, 0, 35)
        AimbotToggle.Position = UDim2.new(0, 0, 0, 40)
        AimbotToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        AimbotToggle.Text = "🎯 Aimbot: OFF (Press Q)"
        AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        AimbotToggle.TextSize = 14
        AimbotToggle.Parent = CombatContent

        local AimbotEnabled = false
        AimbotToggle.MouseButton1Click:Connect(function()
            AimbotEnabled = not AimbotEnabled
            if AimbotEnabled then
                AimbotToggle.Text = "🎯 Aimbot: ON (Press Q)"
                AimbotToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                StartAimbot()
            else
                AimbotToggle.Text = "🎯 Aimbot: OFF (Press Q)"
                AimbotToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end)

        -- ESP Toggle
        local ESPToggle = Instance.new("TextButton")
        ESPToggle.Name = "ESPToggle"
        ESPToggle.Size = UDim2.new(1, 0, 0, 35)
        ESPToggle.Position = UDim2.new(0, 0, 0, 80)
        ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ESPToggle.Text = "👁️ ESP: OFF"
        ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        ESPToggle.TextSize = 14
        ESPToggle.Parent = CombatContent

        local ESPEnabled = false
        ESPToggle.MouseButton1Click:Connect(function()
            ESPEnabled = not ESPEnabled
            if ESPEnabled then
                ESPToggle.Text = "👁️ ESP: ON"
                ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                StartESP()
            else
                ESPToggle.Text = "👁️ ESP: OFF"
                ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end)

        return CombatContent
    end

    local function CreateTeleportTab()
        local TeleportContent = Instance.new("Frame")
        TeleportContent.Name = "TeleportContent"
        TeleportContent.Size = UDim2.new(1, 0, 1, 0)
        TeleportContent.BackgroundTransparency = 1
        TeleportContent.Visible = false
        TeleportContent.Parent = ContentFrame

        local TeleportLabel = Instance.new("TextLabel")
        TeleportLabel.Size = UDim2.new(1, 0, 0, 30)
        TeleportLabel.Position = UDim2.new(0, 0, 0, 0)
        TeleportLabel.BackgroundTransparency = 1
        TeleportLabel.Text = "🌊 TELEPORT LOCATIONS"
        TeleportLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        TeleportLabel.TextSize = 16
        TeleportLabel.Font = Enum.Font.GothamBold
        TeleportLabel.Parent = TeleportContent

        local Islands = {
            {"Starter Island", Vector3.new(-100, 50, 100)},
            {"Jungle", Vector3.new(-1500, 100, 500)},
            {"Pirate Village", Vector3.new(-1100, 100, 3800)},
            {"Desert", Vector3.new(900, 100, 3700)},
            {"Snow Mountain", Vector3.new(1200, 300, -1300)},
            {"Marine Fortress", Vector3.new(-4500, 200, 3800)}
        }

        for i, islandData in pairs(Islands) do
            local islandName, position = islandData[1], islandData[2]
            local IslandButton = Instance.new("TextButton")
            IslandButton.Name = islandName .. "Button"
            IslandButton.Size = UDim2.new(1, 0, 0, 30)
            IslandButton.Position = UDim2.new(0, 0, 0, 35 + (i-1)*35)
            IslandButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            IslandButton.Text = "📍 " .. islandName
            IslandButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            IslandButton.TextSize = 14
            IslandButton.Parent = TeleportContent

            IslandButton.MouseButton1Click:Connect(function()
                RootPart.CFrame = CFrame.new(position)
                print("🌊 Teleported to: " .. islandName)
            end)
        end

        return TeleportContent
    end

    local function CreatePlayerTab()
        local PlayerContent = Instance.new("Frame")
        PlayerContent.Name = "PlayerContent"
        PlayerContent.Size = UDim2.new(1, 0, 1, 0)
        PlayerContent.BackgroundTransparency = 1
        PlayerContent.Visible = false
        PlayerContent.Parent = ContentFrame

        local PlayerLabel = Instance.new("TextLabel")
        PlayerLabel.Size = UDim2.new(1, 0, 0, 30)
        PlayerLabel.Position = UDim2.new(0, 0, 0, 0)
        PlayerLabel.BackgroundTransparency = 1
        PlayerLabel.Text = "👤 PLAYER SETTINGS"
        PlayerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        PlayerLabel.TextSize = 16
        PlayerLabel.Font = Enum.Font.GothamBold
        PlayerLabel.Parent = PlayerContent

        -- Walk Speed
        local WalkSpeedLabel = Instance.new("TextLabel")
        WalkSpeedLabel.Size = UDim2.new(1, 0, 0, 25)
        WalkSpeedLabel.Position = UDim2.new(0, 0, 0, 40)
        WalkSpeedLabel.BackgroundTransparency = 1
        WalkSpeedLabel.Text = "Walk Speed: " .. Humanoid.WalkSpeed
        WalkSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        WalkSpeedLabel.TextSize = 14
        WalkSpeedLabel.Parent = PlayerContent

        local WalkSpeedSlider = Instance.new("TextButton")
        WalkSpeedSlider.Name = "WalkSpeedSlider"
        WalkSpeedSlider.Size = UDim2.new(1, 0, 0, 30)
        WalkSpeedSlider.Position = UDim2.new(0, 0, 0, 70)
        WalkSpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        WalkSpeedSlider.Text = "▲ Increase Walk Speed ▲"
        WalkSpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        WalkSpeedSlider.TextSize = 12
        WalkSpeedSlider.Parent = PlayerContent

        WalkSpeedSlider.MouseButton1Click:Connect(function()
            Humanoid.WalkSpeed = Humanoid.WalkSpeed + 10
            if Humanoid.WalkSpeed > 100 then
                Humanoid.WalkSpeed = 16
            end
            WalkSpeedLabel.Text = "Walk Speed: " .. Humanoid.WalkSpeed
        end)

        -- Jump Power
        local JumpPowerLabel = Instance.new("TextLabel")
        JumpPowerLabel.Size = UDim2.new(1, 0, 0, 25)
        JumpPowerLabel.Position = UDim2.new(0, 0, 0, 110)
        JumpPowerLabel.BackgroundTransparency = 1
        JumpPowerLabel.Text = "Jump Power: " .. Humanoid.JumpPower
        JumpPowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        JumpPowerLabel.TextSize = 14
        JumpPowerLabel.Parent = PlayerContent

        local JumpPowerSlider = Instance.new("TextButton")
        JumpPowerSlider.Name = "JumpPowerSlider"
        JumpPowerSlider.Size = UDim2.new(1, 0, 0, 30)
        JumpPowerSlider.Position = UDim2.new(0, 0, 0, 140)
        JumpPowerSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        JumpPowerSlider.Text = "▲ Increase Jump Power ▲"
        JumpPowerSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        JumpPowerSlider.TextSize = 12
        JumpPowerSlider.Parent = PlayerContent

        JumpPowerSlider.MouseButton1Click:Connect(function()
            Humanoid.JumpPower = Humanoid.JumpPower + 10
            if Humanoid.JumpPower > 150 then
                Humanoid.JumpPower = 50
            end
            JumpPowerLabel.Text = "Jump Power: " .. Humanoid.JumpPower
        end)

        return PlayerContent
    end

    -- Create all tabs
    local MainTabContent = CreateMainTab()
    local CombatTabContent = CreateCombatTab()
    local TeleportTabContent = CreateTeleportTab()
    local PlayerTabContent = CreatePlayerTab()

    -- Tab switching function
    function UpdateTabContent(tabName)
        MainTabContent.Visible = (tabName == "Main")
        CombatTabContent.Visible = (tabName == "Combat")
        TeleportTabContent.Visible = (tabName == "Teleport")
        PlayerTabContent.Visible = (tabName == "Player")
    end

    -- Start with Main tab
    UpdateTabContent("Main")

    return ScreenGui
end

-- Feature Functions
function FindNearestEnemy()
    local nearestEnemy = nil
    local shortestDistance = math.huge
    
    if Workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                local distance = (RootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestEnemy = enemy
                end
            end
        end
    end
    
    return nearestEnemy
end

function StartAutoFarm()
    spawn(function()
        while true do
            wait(0.5)
            local enemy = FindNearestEnemy()
            if enemy then
                RootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                VirtualInputManager:SendKeyEvent(true, "X", false, game)
                wait(0.1)
                VirtualInputManager:SendKeyEvent(false, "X", false, game)
            end
        end
    end)
end

function StartBossFarm(bossName)
    print("👹 Starting boss farm for: " .. bossName)
    -- Boss farm logic would go here
end

function StartAimbot()
    RunService.Heartbeat:Connect(function()
        -- Basic aimbot implementation
        local closest = GetClosestPlayer()
        if closest and UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            local targetPos = closest.Character.HumanoidRootPart.Position
            local camera = Workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
        end
    end)
end

function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

function StartESP()
    -- Basic ESP implementation
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = player.Character
        end
    end
end

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Create the GUI
CreateCustomGUI()
print("🎉 Solix Hub - Custom GUI Loaded Successfully!")
print("✅ All features should now be visible!")
print("📱 Tabs: Main, Combat, Teleport, Player")
