-- Solix Hub - Debug Version
repeat wait() until game:IsLoaded()

print("🔧 Solix Hub Debug Mode Starting...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- Wait for character properly
if not Player.Character then
    print("⏳ Waiting for character...")
    Player.CharacterAdded:Wait()
end

local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("✅ Character loaded successfully")

-- Test if we're in Blox Fruits
local isBloxFruits = (game.PlaceId == 2753915549 or game.PlaceId == 4442272183 or game.PlaceId == 7449423635)
print("🎮 Game Check - Blox Fruits: " .. tostring(isBloxFruits))
print("📋 Current Game ID: " .. game.PlaceId)

-- Check for essential Blox Fruits objects
local essentialObjects = {
    "Map",
    "Enemies", 
    "Live",
    "SpawnLoca",
    "_DESPAWNED"
}

print("🔍 Checking for game objects...")
for _, objName in pairs(essentialObjects) do
    local found = Workspace:FindFirstChild(objName)
    print((found and "✅" or "❌") .. " " .. objName .. ": " .. tostring(found))
end

-- Safe Rayfield Load
local Rayfield = nil
local success, errorMsg = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    print("✅ Rayfield loaded successfully")
end)

if not success or not Rayfield then
    print("❌ Rayfield failed to load: " .. tostring(errorMsg))
    -- Create fallback GUI
    local FallbackGUI = Instance.new("ScreenGui")
    FallbackGUI.Parent = game.CoreGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 400, 0, 300)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.Parent = FallbackGUI
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0.2, 0)
    Title.Text = "Solix Hub - Rayfield Failed"
    Title.TextColor3 = Color3.fromRGB(255, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Parent = Frame
    
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0.8, 0)
    Status.Position = UDim2.new(0, 0, 0.2, 0)
    Status.Text = "Rayfield UI failed to load.\nError: " .. tostring(errorMsg) .. "\n\nUsing basic mode..."
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.BackgroundTransparency = 1
    Status.TextWrapped = true
    Status.Parent = Frame
    return
end

-- Create Window with Error Handling
local Window = nil
local windowSuccess, windowError = pcall(function()
    Window = Rayfield:CreateWindow({
        Name = "Solix Hub - Blox Fruits",
        LoadingTitle = "Solix Hub Loading...",
        LoadingSubtitle = "Debug Mode",
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
    print("✅ Window created successfully")
end)

if not windowSuccess or not Window then
    print("❌ Window creation failed: " .. tostring(windowError))
    return
end

-- Create Main Tab
local MainTab = nil
local tabSuccess, tabError = pcall(function()
    MainTab = Window:CreateTab("Main", "rbxassetid://4483345998")
    print("✅ Main tab created")
end)

if not tabSuccess then
    print("❌ Main tab failed: " .. tostring(tabError))
    return
end

-- Create a simple test section first
local testSection = MainTab:CreateSection("Debug Features")

-- Test Button 1
local testBtn1 = MainTab:CreateButton({
    Name = "Test Button 1 - Basic Function",
    Callback = function()
        print("✅ Test Button 1 Clicked!")
        Rayfield:Notify({
            Title = "Test Success",
            Content = "Basic button is working!",
            Duration = 3
        })
    end,
})

-- Test Button 2 - Check Player Data
local testBtn2 = MainTab:CreateButton({
    Name = "Test Button 2 - Check Player Data",
    Callback = function()
        print("🔍 Checking player data...")
        
        -- Check for player data
        local dataFound = Player:FindFirstChild("Data")
        print("Player Data Found: " .. tostring(dataFound))
        
        if dataFound then
            local level = dataFound:FindFirstChild("Level")
            print("Level Data Found: " .. tostring(level))
            if level then
                print("Player Level: " .. tostring(level.Value))
            end
        end
        
        Rayfield:Notify({
            Title = "Player Data Check",
            Content = "Data Found: " .. tostring(dataFound),
            Duration = 5
        })
    end,
})

-- Test Toggle
local testToggle = MainTab:CreateToggle({
    Name = "Test Toggle - Walk Speed Boost",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Humanoid.WalkSpeed = 50
            print("✅ Walk speed boosted to 50")
        else
            Humanoid.WalkSpeed = 16
            print("✅ Walk speed reset to 16")
        end
    end,
})

-- Try to create farming section
local farmSectionSuccess, farmSectionError = pcall(function()
    local FarmingSection = MainTab:CreateSection("Auto Farming")
    print("✅ Farming section created")
    
    local FarmToggle = MainTab:CreateToggle({
        Name = "Auto Farm (Basic)",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                print("🚀 Auto Farm Started")
                -- Simple farm function
                spawn(function()
                    while Value do
                        wait(1)
                        print("🔄 Auto Farm Running...")
                    end
                end)
            else
                print("⏹️ Auto Farm Stopped")
            end
        end,
    })
end)

if not farmSectionSuccess then
    print("❌ Farming section failed: " .. tostring(farmSectionError))
end

-- Try to create boss section
local bossSectionSuccess, bossSectionError = pcall(function()
    local BossSection = MainTab:CreateSection("Boss Farming")
    
    local BossDropdown = MainTab:CreateDropdown({
        Name = "Select Boss",
        Options = {"Test Boss 1", "Test Boss 2", "Test Boss 3"},
        CurrentOption = "Select Boss",
        Callback = function(Option)
            print("🎯 Selected Boss: " .. Option)
        end,
    })
    
    print("✅ Boss section created")
end)

if not bossSectionSuccess then
    print("❌ Boss section failed: " .. tostring(bossSectionError))
end

-- Final success message
print("🎉 Solix Hub Debug GUI Loaded Successfully!")
print("📊 Summary:")
print("   - Rayfield: ✅")
print("   - Window: ✅") 
print("   - Main Tab: ✅")
print("   - Farming Section: " .. (farmSectionSuccess and "✅" or "❌"))
print("   - Boss Section: " .. (bossSectionSuccess and "✅" or "❌"))

Rayfield:Notify({
    Title = "Solix Hub - Debug Mode",
    Content = "Debug GUI loaded successfully!\nCheck console for details.",
    Duration = 6,
})

Rayfield:LoadConfiguration()
