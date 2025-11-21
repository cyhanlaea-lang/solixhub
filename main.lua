-- MINIMAL DIAGNOSTIC TEST (should ALWAYS show a GUI)
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Basic test: print
print("Diagnostic script started.")

-- Test GUI creation
local gui = Instance.new("ScreenGui")
gui.Name = "DiagUI"
gui.ResetOnSpawn = false

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 320, 0, 40)
label.Position = UDim2.new(0, 20, 0, 20)
label.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.Text = "Diagnostic loaded successfully."

label.Parent = gui
gui.Parent = lp:WaitForChild("PlayerGui")

-- HttpGet test
local ok, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/")
end)

print("HttpGet:", ok and "WORKING" or "FAILED")
label.Text = "GUI OK | HttpGet: " .. (ok and "WORKING" or "FAILED")
