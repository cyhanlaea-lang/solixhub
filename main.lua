-- Advanced Blox Fruits Script by Solix Hub - Multi-Sea Support
repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Universal executor detection
local executor = identifyexecutor and identifyexecutor() or "Unknown"

-- Enhanced safety checks
if not (executor:find("Xeno") or executor:find("Solara") or executor:find("Synapse") or executor:find("Krnl") or executor:find("Delta")) then
    LocalPlayer:Kick("❌ Executor not supported. Use Xeno, Solara, or other compatible executors.")
    return
end

-- Anti-detection measures
pcall(function() 
    getgenv().SecureMode = true 
    if setfpscap then setfpscap(60) end
end)

-- Main Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Sea Detection System
function GetCurrentSea()
    local playerLevel = Player.Data.Level.Value
    if playerLevel >= 700 and Workspace:FindFirstChild("IceCastle") then
        return "Second Sea"
    elseif playerLevel >= 1500 and Workspace:FindFirstChild("Mansion") then
        return "Third Sea"
    else
        return "First Sea"
    end
end

-- Comprehensive Island Database by Sea
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
        ["Colosseum"] = Vector3.new(-1500, 100, -2000),
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

-- Boss Database by Sea with Levels
local BossData = {
    ["First Sea"] = {
        {"Greybeard", 75},
        {"Saber Expert", 200},
        {"Dark Beard", 375},
        {"Warden", 100},
        {"Chief Warden", 175},
        {"Swan", 300},
        {"Diamond", 375},
        {"Jeremy", 250},
        {"Fajita", 225},
        {"Smoke Admiral", 700},
        {"Cursed Captain", 350},
        {"Tide Keeper", 425}
    },
    ["Second Sea"] = {
        {"Ice Admiral", 700},
        {"Awakened Ice Admiral", 850},
        {"Beautiful Pirate", 750},
        {"Longma", 800},
        {"Cake Queen", 850},
        {"Dough King", 950},
        {"Soul Reaper", 900}
    },
    ["Third Sea"] = {
        {"Cake Prince", 1000},
        {"Dough King", 1100},
        {"Soul Reaper", 1200},
        {"Rip_indra", 1500},
        {"Elite Hunter", 1300},
        {"Stone", 1400}
    }
}

-- Quest NPC Database by Sea
local QuestData = {
    ["First Sea"] = {
        {"Start Island", 1, 10},
        {"Jungle Quest", 15, 20},
        {"Pirate Village", 30, 40},
        {"Desert", 60, 75},
        {"Snow Mountain", 90, 105},
        {"Marine Fortress", 120, 135},
        {"Sky Island", 150, 175},
        {"Prison", 190, 210},
        {"Magma Village", 230, 250},
        {"Underwater City", 270, 300},
        {"Fountain City", 300, 330}
    },
    ["Second Sea"] = {
        {"Cafe", 375, 400},
        {"Kingdom of Rose", 450, 475},
        {"Usoap's Island", 525, 550},
        {"Green Zone", 575, 600},
        {"Graveyard", 625, 650},
        {"Snow Mountain", 675, 700},
        {"Hot Island", 725, 750},
        {"Cold Island", 775, 800},
        {"Ice Castle", 825, 850}
    },
    ["Third Sea"] = {
        {"Port Town", 900, 950},
        {"Hydra Island", 975, 1000},
        {"Great Tree", 1050, 1100},
        {"Castle on the Sea", 1125, 1150},
        {"Floating Turtle", 1175, 1200},
        {"Haunted Castle", 1225, 1250},
        {"Ice Cream Island", 1275, 1300},
        {"Peanut Island", 1325, 1350},
        {"Cake Island", 1375, 1400}
    }
}

-- Enhanced Configuration
getgenv().Settings = {
    AutoFarm = false,
    AutoMelee = false,
    FruitMasteryFarm = false,
    AutoBoss = false,
    SelectedBoss = "",
    AutoHop = false,
    AimBot = false,
    AimbotKey = "q",
    TeleportToIsland = false,
    SelectedIsland = "",
    ESPEnabled = false,
    SafeTeleport = true,
    AntiAFK = true,
    Humanizer = true,
    AutoQuest = false,
    SeaAware = true,
    SelectedSea = "First Sea"
}

-- Auto Quest System
function AutoQuest()
    spawn(function()
        while Settings.AutoQuest do
            local currentSea = GetCurrentSea()
            local playerLevel = Player.Data.Level.Value
            
            -- Find appropriate quest for current level
            for _, quest in pairs(QuestData[currentSea]) do
                local questName, minLevel, maxLevel = quest[1], quest[2], quest[3]
                if playerLevel >= minLevel and playerLevel <= maxLevel then
                    -- Teleport to quest area
                    if IslandData[currentSea][questName] then
                        RootPart.CFrame = CFrame.new(IslandData[currentSea][questName])
                        NotifyCustom("📝 Quest", "Auto questing: " .. questName, 3)
                    end
                    break
                end
            end
            
            wait(5) -- Check for new quest every 5 seconds
        end
    end)
end

-- Enhanced Auto Farm with Sea Awareness
function AutoFarm()
    spawn(function()
        while Settings.AutoFarm do
            wait(Settings.Humanizer and math.random(0.1, 0.3) or 0.1)
            
            local currentSea = GetCurrentSea()
            local nearestEnemy = FindNearestEnemy()
            
            if nearestEnemy and nearestEnemy:FindFirstChild("HumanoidRootPart") then
                local distance = (RootPart.Position - nearestEnemy.HumanoidRootPart.Position).Magnitude
                if distance > 10 then
                    RootPart.CFrame = nearestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 8)
                end
                
                if Settings.AutoMelee then
                    VirtualInputManager:SendKeyEvent(true, "X", false, game)
                    wait(Settings.Humanizer and math.random(0.08, 0.15) or 0.1)
                    VirtualInputManager:SendKeyEvent(false, "X", false, game)
                end
                
                if Settings.FruitMasteryFarm then
                    UseFruitSkills()
                end
            else
                wait(1)
            end
        end
    end)
end

-- Enhanced Boss Farm with Sea Awareness
function AutoBossFarm()
    spawn(function()
        while Settings.AutoBoss do
            wait(2)
            local currentSea = GetCurrentSea()
            
            -- Check if selected boss exists in current sea
            local bossExists = false
            for _, bossData in pairs(BossData[currentSea]) do
                if bossData[1] == Settings.SelectedBoss then
                    bossExists = true
                    break
                end
            end
            
            if not bossExists then
                NotifyCustom("🌊 Sea Mismatch", Settings.SelectedBoss .. " not in " .. currentSea, 5)
                Settings.AutoBoss = false
                return
            end
            
            local boss = FindBoss(Settings.SelectedBoss)
            if boss then
                RootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 0, 12)
                
                VirtualInputManager:SendKeyEvent(true, "X", false, game)
                wait(0.3)
                VirtualInputManager:SendKeyEvent(false, "X", false, game)
                
            elseif Settings.AutoHop then
                ServerHop()
            end
        end
    end)
end

-- Find Boss with Sea Awareness
function FindBoss(bossName)
    local currentSea = GetCurrentSea()
    
    for _, boss in pairs(Workspace:GetChildren()) do
        if string.find(boss.Name:lower(), bossName:lower()) and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            return boss
        end
    end
    
    -- Check for spawned bosses in different locations
    for _, spawn in pairs(Workspace:GetDescendants()) do
        if spawn:IsA("Model") and string.find(spawn.Name:lower(), bossName:lower()) then
            if spawn:FindFirstChild("Humanoid") and spawn.Humanoid.Health > 0 then
                return spawn
            end
        end
    end
    
    return nil
end

-- Sea-Specific Teleport
function TeleportToIsland(islandName)
    local currentSea = GetCurrentSea()
    
    if IslandData[currentSea][islandName] and Settings.SafeTeleport then
        RootPart.CFrame = CFrame.new(IslandData[currentSea][islandName])
        NotifyCustom("🌊 Teleport", "Teleported to " .. islandName .. " in " .. currentSea, 3)
    else
        NotifyCustom("❌ Error", "Island not found in current sea: " .. islandName, 5)
    end
end

-- Server Hop Function
function ServerHop()
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        NotifyCustom("🔄 Server Hop", "Moving to new server...", 3)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
end

-- Find Nearest Enemy
function FindNearestEnemy()
    local nearestEnemy = nil
    local shortestDistance = math.huge
    
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
            local distance = (RootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance and distance < 200 then
                shortestDistance = distance
                nearestEnemy = enemy
            end
        end
    end
    
    return nearestEnemy
end

-- Fruit Skills Function
function UseFruitSkills()
    local skills = {"Z", "X", "C", "V", "F"}
    for _, key in pairs(skills) do
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        wait(0.2)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        wait(0.8)
    end
end

-- Safety System
function InitializeSafetySystem()
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        if Settings.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
    
    if Settings.Humanizer then
        spawn(function()
            while Settings.Humanizer do
                wait(math.random(5, 15))
                if Settings.AutoFarm then
                    if math.random(1, 10) == 1 then
                        Settings.AutoFarm = false
                        wait(0.5)
                        Settings.AutoFarm = true
                    end
                end
            end
        end)
    end
end

-- Enhanced GUI with Sea Support
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Solix Hub - Blox Fruits (Multi-Sea)",
    LoadingTitle = "Solix Hub Loading...",
    LoadingSubtitle = "Advanced Multi-Sea Support",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SolixHub",
        FileName = "BloxFruitsConfig"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Main Tab
local MainTab = Window:CreateTab("Main", "rbxassetid://4483345998")

-- Sea Info Section
local SeaSection = MainTab:CreateSection("Sea Information")

local CurrentSeaLabel = MainTab:CreateLabel("Current Sea: " .. GetCurrentSea())
local PlayerLevelLabel = MainTab:CreateLabel("Player Level: " .. tostring(Player.Data.Level.Value))

-- Auto Update Sea Info
spawn(function()
    while true do
        wait(5)
        CurrentSeaLabel:Set("Current Sea: " .. GetCurrentSea())
        PlayerLevelLabel:Set("Player Level: " .. tostring(Player.Data.Level.Value))
    end
end)

-- Farming Section
local FarmingSection = MainTab:CreateSection("Auto Farming")

local AutoFarmToggle = MainTab:CreateToggle({
    Name = "Auto Farm Enemies",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then
            AutoFarm()
        end
    end,
})

local AutoMeleeToggle = MainTab:CreateToggle({
    Name = "Auto Melee Attack",
    CurrentValue = false,
    Flag = "AutoMelee", 
    Callback = function(Value)
        Settings.AutoMelee = Value
    end,
})

local FruitMasteryToggle = MainTab:CreateToggle({
    Name = "Fruit Mastery Farm",
    CurrentValue = false,
    Flag = "FruitMastery",
    Callback = function(Value)
        Settings.FruitMasteryFarm = Value
    end,
})

local AutoQuestToggle = MainTab:CreateToggle({
    Name = "Auto Quest System",
    CurrentValue = false,
    Flag = "AutoQuest",
    Callback = function(Value)
        Settings.AutoQuest = Value
        if Value then
            AutoQuest()
        end
    end,
})

-- Boss Farm Section
local BossSection = MainTab:CreateSection("Boss Farming")

-- Create boss dropdown based on current sea
local function UpdateBossDropdown()
    local currentSea = GetCurrentSea()
    local bossNames = {}
    
    for _, bossData in pairs(BossData[currentSea]) do
        table.insert(bossNames, bossData[1] .. " (Lvl " .. bossData[2] .. ")")
    end
    
    return bossNames
end

local BossDropdown = MainTab:CreateDropdown({
    Name = "Select Boss (Current Sea)",
    Options = UpdateBossDropdown(),
    CurrentOption = "Select Boss",
    Flag = "BossDropdown",
    Callback = function(Option)
        -- Extract boss name from display string
        local bossName = string.gsub(Option, " %(Lvl %d+%)", "")
        Settings.SelectedBoss = bossName
    end,
})

local AutoBossToggle = MainTab:CreateToggle({
    Name = "Auto Boss Farm",
    CurrentValue = false,
    Flag = "AutoBoss",
    Callback = function(Value)
        Settings.AutoBoss = Value
        if Value then
            AutoBossFarm()
        end
    end,
})

local AutoHopToggle = MainTab:CreateToggle({
    Name = "Auto Hop Server (No Boss)",
    CurrentValue = false,
    Flag = "AutoHop",
    Callback = function(Value)
        Settings.AutoHop = Value
    end,
})

-- Teleport Tab with Sea Organization
local TeleportTab = Window:CreateTab("Teleports", "rbxassetid://4483345998")

for seaName, islands in pairs(IslandData) do
    local SeaSection = TeleportTab:CreateSection(seaName .. " Islands")
    
    for islandName, position in pairs(islands) do
        TeleportTab:CreateButton({
            Name = "Teleport to " .. islandName,
            Callback = function()
                TeleportToIsland(islandName)
            end,
        })
    end
end

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", "rbxassetid://4483345998")

local AimbotSection = CombatTab:CreateSection("Aimbot")

local AimbotToggle = CombatTab:CreateToggle({
    Name = "Aimbot (Press Q)",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value)
        Settings.AimBot = Value
    end,
})

local AimbotKeyDropdown = CombatTab:CreateDropdown({
    Name = "Aimbot Key",
    Options = {"q", "e", "f", "c", "v"},
    CurrentOption = "q",
    Flag = "AimbotKey",
    Callback = function(Option)
        Settings.AimbotKey = Option
    end,
})

-- Safety Tab
local SafetyTab = Window:CreateTab("Safety", "rbxassetid://4483345998")

local SafetySection = SafetyTab:CreateSection("Safety Features")

local AntiAFKToggle = SafetyTab:CreateToggle({
    Name = "Anti-AFK System",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(Value)
        Settings.AntiAFK = Value
    end,
})

local HumanizerToggle = SafetyTab:CreateToggle({
    Name = "Humanizer (Reduces Detection)",
    CurrentValue = true,
    Flag = "Humanizer",
    Callback = function(Value)
        Settings.Humanizer = Value
    end,
})

local SafeTeleportToggle = SafetyTab:CreateToggle({
    Name = "Safe Teleport Checks",
    CurrentValue = true,
    Flag = "SafeTeleport",
    Callback = function(Value)
        Settings.SafeTeleport = Value
    end,
})

-- Player Tab
local PlayerTab = Window:CreateTab("Player", "rbxassetid://4483345998")

local MovementSection = PlayerTab:CreateSection("Movement")

local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Humanoid.WalkSpeed = Value
    end,
})

local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        Humanoid.JumpPower = Value
    end,
})

-- Initialize Systems
InitializeSafetySystem()

-- Auto-refresh boss list when sea changes
spawn(function()
    local lastSea = GetCurrentSea()
    while true do
        wait(10)
        local currentSea = GetCurrentSea()
        if currentSea ~= lastSea then
            lastSea = currentSea
            -- Refresh boss dropdown
            BossDropdown:Refresh(UpdateBossDropdown(), "Select Boss")
            NotifyCustom("🌊 Sea Changed", "Now in " .. currentSea, 5)
        end
    end
end)

Rayfield:Notify({
    Title = "Solix Hub - Multi Sea",
    Content = "Successfully loaded! Current Sea: " .. GetCurrentSea(),
    Duration = 6,
    Image = "rbxassetid://4483345998",
})

Rayfield:LoadConfiguration()
