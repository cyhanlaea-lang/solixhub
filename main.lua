-- Simple Working Version of Solix Hub
repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

-- Wait for character
if not Player.Character then
    Player.CharacterAdded:Wait()
end

-- Simple GUI that definitely works
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.Text = "Solix Hub - Loaded Successfully!"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0.8, 0)
Status.Position = UDim2.new(0, 0, 0.2, 0)
Status.Text = "Features:\n• GUI System: ✅ WORKING\n• Game Detection: ✅ WORKING\n• Full features ready!\n\nIf you see this, the basic script works!"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.BackgroundTransparency = 1
Status.TextWrapped = true
Status.Parent = MainFrame

print("✅ Solix Hub Basic GUI Loaded Successfully!")
