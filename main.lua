repeat wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
Workspace = cloneref(game:GetService("Workspace"))
Players = cloneref(game:GetService("Players"))
PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
HttpService = cloneref(game:GetService("HttpService"))
TweenService = cloneref(game:GetService("TweenService"))
UserInputService = cloneref(game:GetService("UserInputService"))
Market = cloneref(game:GetService("MarketplaceService"))
CoreGui = cloneref(game:GetService("CoreGui"))
RunService = cloneref(game:GetService("RunService"))

-- Your supported games list (you can add more)
local ListGame = {
    ["994732206"] = "Blox Fruits",  -- Blox Fruits
    ["1511883870"] = "Shindo Life", -- Shindo Life
    ["2753915549"] = "Blox Fruits", -- Blox Fruits (Second Sea)
    ["4442272183"] = "Blox Fruits", -- Blox Fruits (Third Sea)
    -- Add more games here: ["GAME_ID"] = "Game Name"
}

-- Check if game is supported
local game_id = tostring(game.GameId)
if not ListGame[game_id] then
    Players.LocalPlayer:Kick("❌ This game is not supported.")
    return
end

-- Load the GUI
local LSMT = game:GetObjects("rbxassetid://126113170246030")[1]
LSMT.Enabled = false

-- Parent the GUI securely
if get_ui then
    LSMT.Parent = get_ui()
elseif syn and syn.protect_gui then
    syn.protect_gui(LSMT)
    LSMT.Parent = CoreGui
else
    LSMT.Parent = CoreGui
end

-- Notification system
local NotificationGUI = PlayerGui:FindFirstChild("Notifications") or Instance.new("ScreenGui")
NotificationGUI.Name = "Notifications"
NotificationGUI.Parent = PlayerGui

local Container = NotificationGUI:FindFirstChild("Container") or Instance.new("Frame")
Container.Name = "Container"
Container.AnchorPoint = Vector2.new(1, 0)
Container.Position = UDim2.new(1, -25, 0, 25)
Container.BackgroundTransparency = 1
Container.Size = UDim2.fromOffset(350, 600)
Container.Parent = NotificationGUI

if not Container:FindFirstChild("UIListLayout") then
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Layout.Parent = Container
end

function NotifyCustom(title, content, duration)
    duration = duration or 5
    local color = Color3.fromRGB(255, 188, 254)

    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.BackgroundTransparency = 0.06
    Notification.AutomaticSize = Enum.AutomaticSize.Y
    Notification.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    Notification.BorderSizePixel = 0
    Notification.Size = UDim2.fromOffset(320, 70)
    Notification.Parent = Container

    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = Notification

    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(158, 114, 158)
    NotifStroke.Transparency = 0.8
    NotifStroke.Parent = Notification

    local TitleText = Instance.new("TextLabel")
    TitleText.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold)
    TitleText.Text = title
    TitleText.TextColor3 = Color3.fromRGB(199, 199, 203)
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, -20, 0, 20)
    TitleText.Position = UDim2.fromOffset(10, 6)
    TitleText.Parent = Notification

    local ContentText = Instance.new("TextLabel")
    ContentText.FontFace = Font.new("rbxassetid://12187365364")
    ContentText.Text = content
    ContentText.TextColor3 = Color3.fromRGB(180, 180, 185)
    ContentText.TextSize = 14
    ContentText.TextXAlignment = Enum.TextXAlignment.Left
    ContentText.TextYAlignment = Enum.TextYAlignment.Top
    ContentText.BackgroundTransparency = 1
    ContentText.AutomaticSize = Enum.AutomaticSize.Y
    ContentText.TextWrapped = true
    ContentText.Size = UDim2.new(1, -20, 0, 0)
    ContentText.Position = UDim2.fromOffset(10, 28)
    ContentText.Parent = Notification

    local ProgressBar = Instance.new("Frame")
    ProgressBar.BackgroundColor3 = Color3.fromRGB(44, 38, 44)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Size = UDim2.new(1, -20, 0, 6)
    ProgressBar.Position = UDim2.new(0, 10, 1, -12)
    ProgressBar.Parent = Notification

    local ProgressFill = Instance.new("Frame")
    ProgressFill.BackgroundColor3 = color
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Size = UDim2.fromScale(1, 1)
    ProgressFill.Parent = ProgressBar

    local ProgressFillCorner = Instance.new("UICorner")
    ProgressFillCorner.Parent = ProgressFill

    TweenService:Create(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

    task.delay(duration, function()
        TweenService:Create(Notification, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        Notification:Destroy()
    end)

    return Notification
end

-- Dragging function
function DraggFunction(object, drag_object)
    local dragging = false
    local relative = nil
    local off_set = Vector2.zero

    local ScreenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
    if ScreenGui and ScreenGui.IgnoreGuiInset then
        off_set = game:GetService('GuiService'):GetGuiInset()
    end

    drag_object.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - UserInputService:GetMouseLocation()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local position = UserInputService:GetMouseLocation() + relative + off_set
            TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y)}):Play()
        end
    end)

    object.Destroying:Connect(function()
        dragging = false
    end)
end

-- Close function
function Close(Objectftween)
    TweenService:Create(Objectftween, TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()

    task.wait(0.1)
    LSMT:Destroy()
end

-- Your custom key validation system
local validKeys = {
    -- Add your valid keys here
    "SOLIXHUB2024",
    "PREMIUMKEY123",
    "FREETRIALKEY",
    "WELCOME2024",
    "SOLIXBEST",
    -- Users will get keys from your Linkvertise
}

local usedKeys = {} -- Track used keys to prevent sharing

function ValidateKey(key)
    local cleanedKey = key:upper():gsub("%s+", "")
    
    -- Check if key is valid
    for _, validKey in pairs(validKeys) do
        if cleanedKey == validKey then
            -- Check if key was already used
            if usedKeys[cleanedKey] then
                return false, "This key has already been used!"
            end
            usedKeys[cleanedKey] = true
            return true, "Key validated successfully! Welcome to Solix Hub!"
        end
    end
    
    return false, "Invalid key! Get a valid key from our Linkvertise."
end

-- Main GUI setup
local Main = LSMT.Main
local DragBar = Main.Movebar
local Top = Main.Top
local InputBox = Main.Input
local Buttons = Main.ButtonContainer
local CloseBT = Top.CloseButton
local Title = Top.Title
local Keybox = InputBox.TextBox
local GetDiscord = Buttons.Discord
local Links = Buttons.Links
local YouTube = Links.LootLabs
local Linkvertise = Links.Linkvertise

-- Styling
Title.UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(180, 91, 255)),
    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(88, 26, 181))
}
Title.UIGradient.Rotation = 90

YouTube.UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromHex("#FF0000")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#CC0000"))
}
YouTube.UIGradient.Rotation = 195

Linkvertise.UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(215, 112, 61)),
    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(77, 43, 14))
}
Linkvertise.UIGradient.Rotation = 195

GetDiscord.UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(114, 137, 218)),
    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(88, 101, 242))
}
GetDiscord.UIGradient.Rotation = 195

-- Change button text
YouTube:FindFirstChildOfClass("TextLabel").Text = "YouTube"
Linkvertise:FindFirstChildOfClass("TextLabel").Text = "Get Key"

-- Clipboard function
local coppy = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)

-- Window setup
LSMT.Enabled = true

-- Close button
CloseBT.ImageButton.MouseButton1Click:Connect(function()
    Close(Main)
end)

-- Key validation
Keybox.FocusLost:Connect(function(enterPressed)
    if enterPressed and Keybox.Text ~= "" then
        local isValid, message = ValidateKey(Keybox.Text)
        if isValid then
            TweenService:Create(Keybox, TweenInfo.new(0.65), {BackgroundColor3 = Color3.fromRGB(60, 255, 60), BackgroundTransparency = 0.4}):Play()
            NotifyCustom("✅ Success", message, 5)
            task.wait(1)
            
            -- Close GUI and load your script
            Close(Main)
            
            -- Load your main script here
            NotifyCustom("🚀 Loading", "Loading Solix Hub...", 3)
            
            -- ADD YOUR MAIN SCRIPT HERE:
            -- Example: loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yourscript/main/script.lua"))()
            
            -- For now, just show a success message
            NotifyCustom("🎉 Ready", "Solix Hub loaded successfully! Enjoy!", 5)
            
        else
            Keybox.Text = ""
            TweenService:Create(Keybox, TweenInfo.new(0.65), {BackgroundColor3 = Color3.fromRGB(255, 60, 60), BackgroundTransparency = 0.4}):Play()
            NotifyCustom("❌ Error", message, 5)
            task.wait(0.65)
            TweenService:Create(Keybox, TweenInfo.new(0.65), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.9}):Play()
        end
    end
end)

-- Button actions
YouTube.MouseButton1Click:Connect(function()
    coppy("https://youtube.com/@SolixHub") -- Replace with your YouTube
    NotifyCustom("📺 YouTube", "YouTube link copied to clipboard!", 3)
end)

Linkvertise.MouseButton1Click:Connect(function()
    coppy("https://linkvertise.com/123456/solix-hub-key") -- Replace with your Linkvertise
    NotifyCustom("🔑 Get Key", "LinkVertise link copied! Complete the offer to get your key!", 5)
end)

GetDiscord.MouseButton1Click:Connect(function()
    coppy("https://discord.gg/solixhub") -- Replace with your Discord
    NotifyCustom("💬 Discord", "Discord invite copied to clipboard!", 3)
end)

-- Make window draggable
DraggFunction(Main, DragBar)

-- Set window title and icon
Title.Text = "               Solix Hub Key System"
Top.Logo.Image = "rbxassetid://9e9" -- You can change this icon

-- Auto-focus on keybox when GUI opens
task.spawn(function()
    wait(1)
    Keybox:CaptureFocus()
end)

NotifyCustom("🎮 Welcome", "Solix Hub loaded for: " .. ListGame[game_id], 3)

-- Add some instructions
task.wait(4)
NotifyCustom("💡 How to Use", "1. Get key from Linkvertise\n2. Enter key to activate\n3. Enjoy the features!", 6)
