-- Solix Hub - Single-file Sea-Aware Blox Fruits (Executor-safe)
-- Features: AutoFarm, AutoMelee, AutoQuest, AutoBoss, Teleports, Aimbot, ESP, Anti-AFK
-- Paste into an executor and run client-side.

-- ====== Debug & Safe Helpers ======
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function try_get_service(name)
    local ok, s = pcall(function() return game:GetService(name) end)
    if ok then return s end
    return nil
end

local Players = try_get_service("Players")
local Workspace = try_get_service("Workspace")
local RunService = try_get_service("RunService")
local UserInputService = try_get_service("UserInputService")
local TeleportService = try_get_service("TeleportService")
local HttpService = try_get_service("HttpService")
local StarterGui = try_get_service("StarterGui")

if not Players or not Workspace then
    warn("[Solix] essential services missing - aborting.")
    return
end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[Solix] LocalPlayer not found. Make sure this runs client-side.")
    return
end

-- Safe identify executor
local function identify_executor()
    local ok, id = pcall(function() return identifyexecutor and identifyexecutor() end)
    if ok and id then return tostring(id) end
    return "Unknown"
end

print("[Solix] Starting - Executor:", identify_executor())

-- ====== Config & State ======
local Config = {
    Humanizer = true, -- adds small random delays
    SafeTeleport = true,
    AutoAFK = true
}
local Settings = {
    AutoFarm = false,
    AutoMelee = false,
    AutoQuest = false,
    AutoBoss = false,
    AutoHop = false,
    FruitMastery = false,
    Aimbot = false,
    ESP = false,
    SelectedBoss = "",
    SelectedIsland = nil
}

-- Player Character helpers
local function getCharacter()
    return LocalPlayer and LocalPlayer.Character
end
local function getHumanoid()
    local c = getCharacter()
    return c and c:FindFirstChildWhichIsA("Humanoid")
end
local function getRoot()
    local c = getCharacter()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Wait for initial character
if not getCharacter() then
    LocalPlayer.CharacterAdded:Wait()
end

-- ====== Sea Detection & Data ======
local IslandData = {
    ["First Sea"] = {
        ["Starter Island"] = Vector3.new(-100, 50, 100),
        ["Jungle"] = Vector3.new(-1500, 100, 500),
        ["Pirate Village"] = Vector3.new(-1100, 100, 3800),
    },
    ["Second Sea"] = {
        ["Cafe"] = Vector3.new(-400, 100, 300),
        ["Kingdom of Rose"] = Vector3.new(-1500, 100, 100),
        ["Usoap's Island"] = Vector3.new(-5000, 100, 3000),
        ["Mansion"] = Vector3.new(-12000, 300, 2000),
        ["Ice Castle"] = Vector3.new(6000, 200, -6000)
    },
    ["Third Sea"] = {
        ["Port Town"] = Vector3.new(-600, 100, 5000),
        ["Hydra Island"] = Vector3.new(5000, 100, 4000)
    }
}

local BossData = {
    ["First Sea"] = {"Greybeard", "Saber Expert", "Dark Beard", "Warden"},
    ["Second Sea"] = {"Ice Admiral", "Beautiful Pirate", "Cake Queen"},
    ["Third Sea"] = {"Cake Prince", "Dough King"}
}

local function GetPlayerLevel()
    local lvl = 1
    if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then
        local ok, v = pcall(function() return LocalPlayer.Data.Level.Value end)
        if ok and type(v) == "number" then lvl = v end
    end
    return lvl
end

local function GetCurrentSea()
    local lvl = GetPlayerLevel()
    -- robust environment checks
    if lvl >= 1500 and (Workspace:FindFirstChild("Mansion") or Workspace:FindFirstChild("HauntedCastle")) then
        return "Third Sea"
    elseif lvl >= 700 and (Workspace:FindFirstChild("IceCastle") or Workspace:FindFirstChild("Mansion")) then
        return "Second Sea"
    else
        return "First Sea"
    end
end

-- ====== Utility: Safe VirtualInput usage ======
local VirtualInputManager = nil
local vim_ok = pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local function safe_send_key(key)
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            wait(0.05)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end)
    else
        -- fallback: attempt to fire UserInputService (may not work)
        pcall(function()
            UserInputService.InputBegan:Wait()
        end)
    end
end

-- ====== Anti AFK ======
do
    local VirtualUser = try_get_service("VirtualUser")
    if VirtualUser and Config.AutoAFK then
        pcall(function()
            LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0,0))
                    print("[Solix] Anti-AFK triggered")
                end)
            end)
        end)
    end
end

-- ====== Combat & Farming Functions ======
local function FindNearestEnemy(maxDistance)
    maxDistance = maxDistance or 500
    local root = getRoot()
    if not root then return nil end
    local candidate = nil
    local best = math.huge
    local containers = {
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("_ENEMIES"),
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("LivingThings"),
        Workspace:FindFirstChild("_DESPAWNED")
    }
    for _, cont in pairs(containers) do
        if cont then
            for _, v in pairs(cont:GetChildren()) do
                local hrp = v:FindFirstChild("HumanoidRootPart")
                local hum = v:FindFirstChildWhichIsA("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local d = (root.Position - hrp.Position).Magnitude
                    if d < best and d <= maxDistance then
                        best = d
                        candidate = v
                    end
                end
            end
        end
    end
    return candidate
end

local function UseFruitSkills()
    -- attempt to press keys for fruit skills safely
    for _, k in ipairs({"Z","X","C","V","F"}) do
        safe_pcall(function() safe_send_key(k) end)
        wait(0.15 + (Config.Humanizer and math.random() * 0.1 or 0))
    end
end

local function AttackMelee()
    safe_pcall(function() safe_send_key("X") end)
end

-- Teleport helper (safe)
local function SafeTeleportTo(pos)
    local root = getRoot()
    if not root then return false end
    pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end)
    return true
end

-- Teleport to island by name in current sea
local function TeleportToIsland(islandName)
    local sea = GetCurrentSea()
    local islands = IslandData[sea] or {}
    if islands[islandName] then
        SafeTeleportTo(islands[islandName])
        print("[Solix] Teleported to", islandName, "in", sea)
        return true
    else
        warn("[Solix] Island not found in", sea, ":", islandName)
        return false
    end
end

-- Boss finder (simple string match)
local function FindBossByName(name)
    -- search workspace children and enemy containers
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildWhichIsA("Humanoid") then
            if string.find(string.lower(v.Name), string.lower(name)) then
                return v
            end
        end
    end
    return nil
end

-- ====== Background Loops (controlled by Settings) ======
local loops = {}

local function StartAutoFarmLoop()
    if loops.autofarm then return end
    loops.autofarm = true
    spawn(function()
        while Settings.AutoFarm do
            local root = getRoot()
            if root then
                local enemy = FindNearestEnemy(500)
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    -- approach
                    pcall(function()
                        root.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,8)
                    end)
                    if Settings.AutoMelee then AttackMelee() end
                    if Settings.FruitMastery then UseFruitSkills() end
                else
                    -- try auto quest: teleport to quest area (very basic)
                    if Settings.AutoQuest then
                        local sea = GetCurrentSea()
                        -- pick a random island within sea as "quest area"
                        local islands = IslandData[sea]
                        if islands then
                            for n,pos in pairs(islands) do
                                SafeTeleportTo(pos)
                                break
                            end
                        end
                    end
                    wait(1.2)
                end
            end
            wait(0.25 + (Config.Humanizer and math.random()*0.2 or 0))
        end
        loops.autofarm = nil
    end)
end

local function StartBossFarmLoop()
    if loops.bossfarm then return end
    loops.bossfarm = true
    spawn(function()
        while Settings.AutoBoss do
            local boss = nil
            if Settings.SelectedBoss ~= "" then
                boss = FindBossByName(Settings.SelectedBoss)
            else
                -- pick first BossData entry of current sea
                local sea = GetCurrentSea()
                local b = BossData[sea]
                if b and #b > 0 then
                    Settings.SelectedBoss = b[1]
                end
            end
            if boss and boss:FindFirstChild("HumanoidRootPart") then
                local root = getRoot()
                pcall(function()
                    if root then root.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0,0,12) end
                end)
                -- attack
                AttackMelee()
                if Settings.FruitMastery then UseFruitSkills() end
            else
                if Settings.AutoHop then
                    -- best-effort server hop using Roblox public API (may be rate limited)
                    pcall(function()
                        local ok, data = pcall(function()
                            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
                        end)
                        if ok and data and data.data then
                            local ids = {}
                            for _,sv in pairs(data.data) do
                                if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                                    table.insert(ids, sv.id)
                                end
                            end
                            if #ids > 0 then
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, ids[math.random(1,#ids)])
                                break
                            end
                        end
                    end)
                else
                    wait(2)
                end
            end
            wait(0.4)
        end
        loops.bossfarm = nil
    end)
end

-- ====== Aimbot & ESP ======
local aimbot_conn = nil
local esp_added = {}

local function StartAimbot()
    if aimbot_conn then return end
    aimbot_conn = RunService.Heartbeat:Connect(function()
        if not Settings.Aimbot then return end
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local closest = nil
            local best = math.huge
            local root = getRoot()
            if root then
                for _,pl in pairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (root.Position - pl.Character.HumanoidRootPart.Position).Magnitude
                        if d < best then best = d; closest = pl end
                    end
                end
                if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                    local cam = Workspace.CurrentCamera
                    pcall(function()
                        cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Character.HumanoidRootPart.Position)
                    end)
                end
            end
        end
    end)
end

local function StartESP()
    if Settings.ESP then
        for _,pl in pairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character and not esp_added[pl] then
                local ok, highlight = pcall(function()
                    local h = Instance.new("Highlight")
                    h.Name = "SolixHighlight"
                    h.Parent = pl.Character
                    h.Adornee = pl.Character:FindFirstChildWhichIsA("Model") or pl.Character
                    return h
                end)
                if ok then esp_added[pl] = true end
            end
        end
        -- connect new players
        Players.PlayerAdded:Connect(function(pl)
            pl.CharacterAdded:Connect(function(c)
                if Settings.ESP then
                    pcall(function()
                        local h = Instance.new("Highlight")
                        h.Name = "SolixHighlight"
                        h.Parent = c
                        esp_added[pl] = true
                    end)
                end
            end)
        end)
    else
        -- Clear existing highlights
        for _,pl in pairs(Players:GetPlayers()) do
            if pl.Character then
                for _,c in pairs(pl.Character:GetChildren()) do
                    if c:IsA("Highlight") and c.Name == "SolixHighlight" then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end
        esp_added = {}
    end
end

-- ====== Simple Fallback GUI ======
local function CreateMainUI()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    -- check existing
    local existing = playerGui:FindFirstChild("SolixHubUI")
    if existing then existing:Destroy() end

    local screen = Instance.new("ScreenGui")
    screen.Name = "SolixHubUI"
    screen.ResetOnSpawn = false
    screen.Parent = playerGui

    local main = Instance.new("Frame", screen)
    main.AnchorPoint = Vector2.new(0,0)
    main.Position = UDim2.new(0,0,0,60)
    main.Size = UDim2.new(0,380,0,420)
    main.BackgroundTransparency = 0.15
    main.BackgroundColor3 = Color3.fromRGB(20,20,28)
    main.BorderSizePixel = 0
    main.Name = "Main"

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,36)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = "Solix Hub — Blox Fruits (Sea-aware)"
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(255,255,255)

    local function makeToggle(y, text, initial, cb)
        local frame = Instance.new("Frame", main)
        frame.Position = UDim2.new(0,8,0,y)
        frame.Size = UDim2.new(1,-16,0,34)
        frame.BackgroundTransparency = 1
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.68,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(230,230,230)
        lbl.TextScaled = false
        lbl.Font = Enum.Font.SourceSans
        lbl.TextSize = 16

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.28,0,0.8,0)
        btn.Position = UDim2.new(0.7,0,0.1,0)
        btn.Text = initial and "On" or "Off"
        btn.TextScaled = true
        btn.BackgroundColor3 = initial and Color3.fromRGB(30,150,80) or Color3.fromRGB(120,120,120)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.MouseButton1Click:Connect(function()
            local new = not (btn.Text == "On")
            btn.Text = new and "On" or "Off"
            btn.BackgroundColor3 = new and Color3.fromRGB(30,150,80) or Color3.fromRGB(120,120,120)
            pcall(cb, new)
        end)
        return frame, btn
    end

    local ypos = 46
    local tf1 = makeToggle(ypos, "Auto Farm", Settings.AutoFarm, function(v)
        Settings.AutoFarm = v
        if v then StartAutoFarmLoop() else Settings.AutoFarm = false end
    end)
    ypos = ypos + 40
    local tf2 = makeToggle(ypos, "Auto Melee", Settings.AutoMelee, function(v) Settings.AutoMelee = v end)
    ypos = ypos + 40
    local tf3 = makeToggle(ypos, "Auto Quest", Settings.AutoQuest, function(v) Settings.AutoQuest = v end)
    ypos = ypos + 40
    local tf4 = makeToggle(ypos, "Auto Boss", Settings.AutoBoss, function(v)
        Settings.AutoBoss = v
        if v then StartBossFarmLoop() end
    end)
    ypos = ypos + 40
    local tf5 = makeToggle(ypos, "Aimbot (Hold RMB)", Settings.Aimbot, function(v)
        Settings.Aimbot = v
        if v then StartAimbot() end
    end)
    ypos = ypos + 40
    local tf6 = makeToggle(ypos, "ESP", Settings.ESP, function(v)
        Settings.ESP = v
        StartESP()
    end)

    -- Boss dropdown
    local seaLabel = Instance.new("TextLabel", main)
    seaLabel.Size = UDim2.new(1,-16,0,22)
    seaLabel.Position = UDim2.new(0,8,0, ypos + 14)
    seaLabel.BackgroundTransparency = 1
    seaLabel.Text = "Detected Sea: " .. GetCurrentSea()
    seaLabel.TextColor3 = Color3.fromRGB(200,200,200)
    seaLabel.TextXAlignment = Enum.TextXAlignment.Left
    ypos = ypos + 40

    local bossDropdown = Instance.new("TextButton", main)
    bossDropdown.Size = UDim2.new(1,-16,0,28)
    bossDropdown.Position = UDim2.new(0,8,0,ypos+40)
    bossDropdown.Text = "Select Boss"
    bossDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    bossDropdown.BackgroundColor3 = Color3.fromRGB(40,40,50)
    bossDropdown.MouseButton1Click:Connect(function()
        -- build simple selection menu
        local sea = GetCurrentSea()
        local list = BossData[sea] or {}
        local menu = Instance.new("Frame", main)
        menu.Size = UDim2.new(1,-16,0, #list * 28)
        menu.Position = UDim2.new(0,8,0,ypos+72)
        menu.BackgroundColor3 = Color3.fromRGB(30,30,38)
        for i,name in ipairs(list) do
            local b = Instance.new("TextButton", menu)
            b.Size = UDim2.new(1, -4, 0, 24)
            b.Position = UDim2.new(0,2,0,(i-1)*28)
            b.Text = name
            b.BackgroundColor3 = Color3.fromRGB(60,60,70)
            b.TextColor3 = Color3.fromRGB(255,255,255)
            b.MouseButton1Click:Connect(function()
                Settings.SelectedBoss = name
                bossDropdown.Text = "Boss: "..name
                menu:Destroy()
            end)
        end
        -- auto-destroy after 6s
        delay(6, function() if menu and menu.Parent then pcall(function() menu:Destroy() end) end end)
    end)

    -- Teleport buttons area
    local teleLabel = Instance.new("TextLabel", main)
    teleLabel.Size = UDim2.new(1,-16,0,20)
    teleLabel.Position = UDim2.new(0,8,0, 320)
    teleLabel.BackgroundTransparency = 1
    teleLabel.Text = "Teleports (current sea):"
    teleLabel.TextColor3 = Color3.fromRGB(220,220,220)
    teleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local tpContainer = Instance.new("Frame", main)
    tpContainer.Position = UDim2.new(0,8,0, 345)
    tpContainer.Size = UDim2.new(1,-16,0,64)
    tpContainer.BackgroundTransparency = 1

    -- populate teleport buttons
    spawn(function()
        local sea = GetCurrentSea()
        local islands = IslandData[sea] or {}
        local i = 0
        for name,pos in pairs(islands) do
            local b = Instance.new("TextButton", tpContainer)
            b.Size = UDim2.new(0.5, -6, 0, 28)
            b.Position = UDim2.new((i%2)*0.5 + 0.01, 0, math.floor(i/2)*0.5, 0)
            b.Text = name
            b.AutomaticSize = Enum.AutomaticSize.None
            b.BackgroundColor3 = Color3.fromRGB(50,50,60)
            b.TextColor3 = Color3.fromRGB(255,255,255)
            b.MouseButton1Click:Connect(function()
                Settings.SelectedIsland = name
                TeleportToIsland(name)
            end)
            i = i + 1
        end
    end)

    -- small footer
    local footer = Instance.new("TextLabel", main)
    footer.Size = UDim2.new(1,0,0,20)
    footer.Position = UDim2.new(0,0,1,-20)
    footer.BackgroundTransparency = 1
    footer.Text = "Solix Hub — Basic Edition | Sea: " .. GetCurrentSea()
    footer.TextScaled = false
    footer.TextColor3 = Color3.fromRGB(170,170,170)
end

-- Create UI
CreateMainUI()

-- Toggle watchers and safety: connect toggles to functions
-- A simple monitor loop to start features when toggles are changed (ensures toggles from UI start loops)
spawn(function()
    while true do
        if Settings.AutoFarm and not loops.autofarm then
            StartAutoFarmLoop()
        end
        if Settings.AutoBoss and not loops.bossfarm then
            StartBossFarmLoop()
        end
        if Settings.Aimbot then StartAimbot() end
        wait(1)
    end
end)

-- Final prints
print("[Solix] UI created. Current Sea:", GetCurrentSea())
print("[Solix] Available features: AutoFarm, AutoMelee, AutoQuest, AutoBoss, Teleports, Aimbot, ESP, Anti-AFK")
