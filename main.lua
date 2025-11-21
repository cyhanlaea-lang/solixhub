-- Solix Hub - Fixed Version with Venus UI
repeat wait() until game:IsLoaded()

print("🎮 Solix Hub Loading...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- Wait for character
if not Player.Character then
    Player.CharacterAdded:Wait()
end

local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("✅ Game loaded successfully")

-- Load Venus UI (more reliable alternative)
local Venus = nil
local success, errorMsg = pcall(function()
    Venus = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venus/main/Loader.lua"))()
    print("✅ Venus UI loaded successfully")
end)

if not success or not Venus then
    print("❌ Venus UI failed: " .. tostring(errorMsg))
    -- Try one more alternative
    Venus = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venus/main/Source.lua"))()
end

-- Create Window
local Window = Venus:CreateWindow({
    Title = "Solix Hub - Blox Fruits",
    Description = "Advanced Multi-Sea Script",
    LoadingTitle = "Solix Hub",
    LoadingDescription = "Loading features...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SolixHub"
    }
})

print("✅ Window created")

-- Main Tab
local MainTab = Window:CreateTab("Main", "rbxassetid://4483345998")

-- Auto Farming Section
local FarmingSection = MainTab:CreateSection("Auto Farming")

local AutoFarmToggle = MainTab:CreateToggle({
    Title = "Auto Farm Enemies",
    Default = false,
    Callback = function(Value)
        if Value then
            print("🚀 Auto Farm Started")
            spawn(function()
                while Value do
                    wait(1)
                    -- Basic auto farm logic
                    local nearest = FindNearestEnemy()
                    if nearest then
                        RootPart.CFrame = nearest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        VirtualInputManager:SendKeyEvent(true, "X", false, game)
                        wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, "X", false, game)
                    end
                end
            end)
        else
            print("⏹️ Auto Farm Stopped")
        end
    end
})

local AutoMeleeToggle = MainTab:CreateToggle({
    Title = "Auto Melee Attack", 
    Default = false,
    Callback = function(Value)
        print("🥊 Auto Melee: " .. tostring(Value))
    end
})

-- Boss Farming Section
local BossSection = MainTab:CreateSection("Boss Farming")

local BossDropdown = MainTab:CreateDropdown({
    Title = "Select Boss",
    Description = "Choose which boss to farm",
    Options = {
        "Greybeard",
        "Saber Expert", 
        "Dark Beard",
        "Warden",
        "Chief Warden"
    },
    Default = "Select Boss",
    Callback = function(Option)
        print("🎯 Selected Boss: " .. Option)
    end
})

local AutoBossToggle = MainTab:CreateToggle({
    Title = "Auto Boss Farm",
    Default = false,
    Callback = function(Value)
        if Value then
            print("👹 Auto Boss Farm Started")
        else
            print("⏹️ Auto Boss Farm Stopped")
        end
    end
})

-- Teleport Section
local TeleportSection = MainTab:CreateSection("Teleports")

local IslandDropdown = MainTab:CreateDropdown({
    Title = "Teleport to Island",
    Description = "Select an island to teleport to",
    Options = {
        "Starter Island",
        "Jungle",
        "Pirate Village", 
        "Desert",
        "Snow Mountain",
        "Marine Fortress"
    },
    Default = "Select Island",
    Callback = function(Option)
        TeleportToIsland(Option)
    end
})

-- Player Section
local PlayerSection = MainTab:CreateSection("Player")

local WalkSpeedSlider = MainTab:CreateSlider({
    Title = "Walk Speed",
    Description = "Adjust your movement speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Callback = function(Value)
        Humanoid.WalkSpeed = Value
        print("🚶 Walk Speed: " .. Value)
    end
})

local JumpPowerSlider = MainTab:CreateSlider({
    Title = "Jump Power", 
    Description = "Adjust your jump height",
    Default = 50,
    Min = 50,
    Max = 150,
    Callback = function(Value)
        Humanoid.JumpPower = Value
        print("🦘 Jump Power: " .. Value)
    end
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", "rbxassetid://4483345998")

local AimbotSection = CombatTab:CreateSection("Aimbot")

local AimbotToggle = CombatTab:CreateToggle({
    Title = "Aimbot (Press Q)",
    Default = false,
    Callback = function(Value)
        if Value then
            InitializeAimbot()
            print("🎯 Aimbot Enabled - Press Q to use")
        else
            print("🎯 Aimbot Disabled")
        end
    end
})

-- Functions
function FindNearestEnemy()
    local nearestEnemy = nil
    local shortestDistance = math.huge
    
    -- Check multiple enemy locations
    local enemyContainers = {
        Workspace.Enemies,
        Workspace.LivingThings,
        Workspace.Mobs
    }
    
    for _, container in pairs(enemyContainers) do
        if container then
            for _, enemy in pairs(container:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                    local distance = (RootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance and distance < 200 then
                        shortestDistance = distance
                        nearestEnemy = enemy
                    end
                end
            end
        end
    end
    
    return nearestEnemy
end

function TeleportToIsland(islandName)
    local islandPositions = {
        ["Starter Island"] = Vector3.new(-100, 50, 100),
        ["Jungle"] = Vector3.new(-1500, 100, 500),
        ["Pirate Village"] = Vector3.new(-1100, 100, 3800),
        ["Desert"] = Vector3.new(900, 100, 3700),
        ["Snow Mountain"] = Vector3.new(1200, 300, -1300),
        ["Marine Fortress"] = Vector3.new(-4500, 200, 3800)
    }
    
    if islandPositions[islandName] then
        RootPart.CFrame = CFrame.new(islandPositions[islandName])
        Venus:Notify({
            Title = "Teleport",
            Description = "Teleported to " .. islandName,
            Duration = 3
        })
        print("🌊 Teleported to: " .. islandName)
    end
end

function InitializeAimbot()
    RunService.Heartbeat:Connect(function()
        -- Basic aimbot logic
        local closestPlayer = GetClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = closestPlayer.Character.HumanoidRootPart.Position
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

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("🎉 Solix Hub Fully Loaded!")
Venus:Notify({
    Title = "Solix Hub",
    Description = "Successfully loaded! Enjoy the features.",
    Duration = 5
})
