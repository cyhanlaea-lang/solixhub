-- Solix Hub - PROPER WORKING VERSION
repeat wait() until game:IsLoaded()

print("🎮 Solix Hub - Professional Edition Loading...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

-- Wait for character
if not Player.Character then
    Player.CharacterAdded:Wait()
end

local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("✅ Game loaded successfully")

-- Sea Detection
function GetCurrentSea()
    local playerLevel = 1
    if Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Level") then
        playerLevel = Player.Data.Level.Value
    end
    
    if playerLevel >= 700 and Workspace:FindFirstChild("IceCastle") then
        return "Second Sea"
    elseif playerLevel >= 1500 and (Workspace:FindFirstChild("Mansion") or Workspace:FindFirstChild("HauntedCastle")) then
        return "Third Sea"
    else
        return "First Sea"
    end
end

-- Sea-Specific Data
local IslandData = {
    ["First Sea"] = {
        ["Starter Island"] = Vector3.new(-100, 50, 100),
        ["Jungle"] = Vector3.new(-1500, 100, 500),
        ["Pirate Village"] = Vector3.new(-1100, 100, 3800),
        ["Desert"] = Vector3.new(900, 100, 3700),
        ["Snow Mountain"] = Vector3.new(1200, 300, -1300),
        ["Marine Fortress"] = Vector3.new(-4500, 200, 3800),
        ["Sky Island"] = Vector3.new(4500, 1500, -1500),
        ["Prison"] = Vector3.new(5000, 100, 300),
        ["Magma Village"] = Vector3.new(5500, 100, -800),
        ["Underwater City"] = Vector3.new(2500, -500, -2500),
        ["Fountain City"] = Vector3.new(5000, 100, 5000)
    },
    ["Second Sea"] = {
        ["Cafe"] = Vector3.new(-400, 100, 300),
        ["Kingdom of Rose"] = Vector3.new(-1500, 100, 100),
        ["Usoap's Island"] = Vector3.new(-5000, 100, 3000),
        ["Mansion"] = Vector3.new(-12000, 300, 2000),
        ["Green Zone"] = Vector3.new(-2000, 100, -3000),
        ["Graveyard"] = Vector3.new(-6000, 100, -7000),
        ["Snow Mountain"] = Vector3.new(1000, 400, -2000),
        ["Hot Island"] = Vector3.new(-5000, 100, -4000),
        ["Cold Island"] = Vector3.new(-5000, 100, -1000),
        ["Ice Castle"] = Vector3.new(6000, 200, -6000)
    },
    ["Third Sea"] = {
        ["Port Town"] = Vector3.new(-600, 100, 5000),
        ["Hydra Island"] = Vector3.new(5000, 100, 4000),
        ["Great Tree"] = Vector3.new(2000, 500, 3000),
        ["Castle on the Sea"] = Vector3.new(-5000, 100, 2000),
        ["Floating Turtle"] = Vector3.new(10000, 3000, 1000),
        ["Haunted Castle"] = Vector3.new(-10000, 100, 5000),
        ["Ice Cream Island"] = Vector3.new(-800, 100, -10000),
        ["Peanut Island"] = Vector3.new(-2000, 100, -5000),
        ["Cake Island"] = Vector3.new(-4000, 100, -7000)
    }
}

-- Load FluxUI - Professional and Reliable
local Flux = loadstring(game:HttpGet"https://raw.githubusercontent.com/Robobo2022/script/main/FluxLib.lua")()

-- Create Window
local Window = Flux:Window("Solix Hub", "Blox Fruits - Professional", "By YourName", true)

-- Settings
local Settings = {
    AutoFarm = false,
    AutoMelee = false,
    FruitMastery = false,
    AutoBoss = false,
    SelectedBoss = "",
    AutoHop = false,
    Aimbot = false,
    ESP = false
}

-- Main Tab
local MainTab = Window:Tab("Main", "http://www.roblox.com/asset/?id=6023426915")

MainTab:Section("Auto Farming")

local FarmToggle = MainTab:Toggle("Auto Farm Enemies", "Start auto farming nearby enemies", false, function(t)
    Settings.AutoFarm = t
    if t then
        StartAutoFarm()
        Flux:Notification("Auto Farm", "Auto farming started!", "OK")
    else
        Flux:Notification("Auto Farm", "Auto farming stopped!", "OK")
    end
end)

local MeleeToggle = MainTab:Toggle("Auto Melee Attack", "Automatically use melee attacks", false, function(t)
    Settings.AutoMelee = t
end)

local FruitToggle = MainTab:Toggle("Fruit Mastery Farm", "Use fruit skills for mastery", false, function(t)
    Settings.FruitMastery = t
end)

MainTab:Section("Boss Farming")

local Bosses = {"Greybeard", "Saber Expert", "Dark Beard", "Warden", "Ice Admiral", "Cake Queen"}
local BossDropdown = MainTab:Dropdown("Select Boss", "Choose boss to farm", Bosses, function(selected)
    Settings.SelectedBoss = selected
end)

local BossToggle = MainTab:Toggle("Auto Boss Farm", "Farm selected boss automatically", false, function(t)
    Settings.AutoBoss = t
    if t and Settings.SelectedBoss ~= "" then
        StartBossFarm()
        Flux:Notification("Boss Farm", "Started farming: " .. Settings.SelectedBoss, "OK")
    elseif t then
        Flux:Notification("Error", "Please select a boss first!", "OK")
        Settings.AutoBoss = false
    end
end)

local HopToggle = MainTab:Toggle("Auto Server Hop", "Hop if boss not found", false, function(t)
    Settings.AutoHop = t
end)

-- Combat Tab
local CombatTab = Window:Tab("Combat", "http://www.roblox.com/asset/?id=6023426915")

CombatTab:Section("Aimbot & ESP")

local AimbotToggle = CombatTab:Toggle("Aimbot (Hold RightClick)", "Lock onto players", false, function(t)
    Settings.Aimbot = t
    if t then
        StartAimbot()
        Flux:Notification("Aimbot", "Aimbot enabled - Hold RightClick", "OK")
    end
end)

local ESPToggle = CombatTab:Toggle("Player ESP", "Highlight other players", false, function(t)
    Settings.ESP = t
    if t then
        StartESP()
        Flux:Notification("ESP", "Player ESP enabled", "OK")
    else
        ClearESP()
    end
end)

-- Teleport Tab
local TeleportTab = Window:Tab("Teleport", "http://www.roblox.com/asset/?id=6023426915")

TeleportTab:Section("Island Teleports")

-- Create teleport buttons for current sea only
local currentSea = GetCurrentSea()
Flux:Notification("Sea Detection", "Detected: " .. currentSea, "OK")

for islandName, position in pairs(IslandData[currentSea]) do
    TeleportTab:Button("Teleport to " .. islandName, "Teleport to " .. islandName, function()
        TeleportToIsland(islandName, position)
    end)
end

-- Player Tab
local PlayerTab = Window:Tab("Player", "http://www.roblox.com/asset/?id=6023426915")

PlayerTab:Section("Movement")

local WalkSpeedSlider = PlayerTab:Slider("Walk Speed", "Adjust movement speed", 16, 100, 16, function(value)
    Humanoid.WalkSpeed = value
end)

local JumpPowerSlider = PlayerTab:Slider("Jump Power", "Adjust jump height", 50, 200, 50, function(value)
    Humanoid.JumpPower = value
end)

-- FUNCTIONS THAT ACTUALLY WORK

function FindNearestEnemy()
    local nearestEnemy = nil
    local shortestDistance = math.huge
    
    -- Check all possible enemy containers
    local enemyContainers = {
        Workspace.Enemies,
        Workspace.LivingThings,
        Workspace.Mobs,
        Workspace._DESPAWNED
    }
    
    for _, container in pairs(enemyContainers) do
        if container then
            for _, enemy in pairs(container:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                    local distance = (RootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance and distance < 500 then
                        shortestDistance = distance
                        nearestEnemy = enemy
                    end
                end
            end
        end
    end
    
    return nearestEnemy
end

function StartAutoFarm()
    spawn(function()
        while Settings.AutoFarm do
            local enemy = FindNearestEnemy()
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                -- Teleport to enemy
                RootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 8)
                
                -- Auto attack
                if Settings.AutoMelee then
                    VirtualInputManager:SendKeyEvent(true, "X", false, game)
                    wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "X", false, game)
                end
                
                -- Fruit skills
                if Settings.FruitMastery then
                    UseFruitSkills()
                end
            else
                -- No enemies found, wait a bit
                wait(1)
            end
            wait(0.2)
        end
    end)
end

function StartBossFarm()
    spawn(function()
        while Settings.AutoBoss and Settings.SelectedBoss ~= "" do
            local boss = FindBoss(Settings.SelectedBoss)
            if boss and boss:FindFirstChild("HumanoidRootPart") then
                -- Teleport to boss
                RootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 0, 12)
                
                -- Attack boss
                VirtualInputManager:SendKeyEvent(true, "X", false, game)
                wait(0.2)
                VirtualInputManager:SendKeyEvent(false, "X", false, game)
                
                -- Use fruit skills
                if Settings.FruitMastery then
                    UseFruitSkills()
                end
            elseif Settings.AutoHop then
                -- Boss not found, server hop
                ServerHop()
                break
            else
                wait(2)
            end
            wait(0.3)
        end
    end)
end

function FindBoss(bossName)
    -- Check regular bosses
    for _, boss in pairs(Workspace:GetChildren()) do
        if string.find(string.lower(boss.Name), string.lower(bossName)) and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            return boss
        end
    end
    
    -- Check in enemy containers
    local containers = {Workspace.Enemies, Workspace.LivingThings, Workspace.Mobs}
    for _, container in pairs(containers) do
        if container then
            for _, boss in pairs(container:GetChildren()) do
                if string.find(string.lower(boss.Name), string.lower(bossName)) and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                    return boss
                end
            end
        end
    end
    
    return nil
end

function UseFruitSkills()
    local skills = {"Z", "X", "C", "V", "F"}
    for _, key in pairs(skills) do
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        wait(0.15)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        wait(0.5)
    end
end

function StartAimbot()
    RunService.Heartbeat:Connect(function()
        if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local closestPlayer = GetClosestPlayer()
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = closestPlayer.Character.HumanoidRootPart.Position
                local camera = Workspace.CurrentCamera
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
            end
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
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "SolixESP"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = player.Character
        end
    end
    
    -- Add ESP for new players
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            if Settings.ESP then
                wait(1)
                local highlight = Instance.new("Highlight")
                highlight.Name = "SolixESP"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.Parent = character
            end
        end)
    end)
end

function ClearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local esp = player.Character:FindFirstChild("SolixESP")
            if esp then
                esp:Destroy()
            end
        end
    end
end

function TeleportToIsland(islandName, position)
    local currentSea = GetCurrentSea()
    if IslandData[currentSea][islandName] then
        RootPart.CFrame = CFrame.new(position)
        Flux:Notification("Teleport", "Teleported to " .. islandName .. " in " .. currentSea, "OK")
        print("🌊 Teleported to: " .. islandName)
    else
        Flux:Notification("Error", "Island not available in current sea!", "OK")
    end
end

function ServerHop()
    local servers = {}
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            Flux:Notification("Server Hop", "Moving to new server...", "OK")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
        end
    end
end

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("🎉 Solix Hub - Professional Edition Loaded!")
print("🌊 Current Sea: " .. GetCurrentSea())
print("✅ All features should work properly now!")

-- Auto-refresh teleports if sea changes
spawn(function()
    local lastSea = GetCurrentSea()
    while true do
        wait(10)
        local currentSea = GetCurrentSea()
        if currentSea ~= lastSea then
            lastSea = currentSea
            Flux:Notification("Sea Changed", "Now in " .. currentSea, "OK")
            print("🌊 Sea changed to: " .. currentSea)
        end
    end
end)
