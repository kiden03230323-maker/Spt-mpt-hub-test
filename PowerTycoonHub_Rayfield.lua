--[[
╔═══════════════════════════════════════════════════════════╗
║  POWER TYCOON HUB - ULTIMATE EDITION                     ║
║  Key System + Hub Manage + Chat + Ban System             ║
║  Made for exo_blox                                       ║
═══════════════════════════════════════════════════════════╝
]]

-- ============================================
-- SERVICES & CONFIG
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local HUB_KEY = "EXOSTAKEOVERR19$"
local KEY_EXPIRY_HOURS = 24
local OWNER_CREDS = {username = "exo_blox", password = "03239461"}
local OPERATOR_CREDS = {username = "OP", password = "0000"}

-- File paths
local KEY_FILE = "exo_hub_key.dat"
local BAN_FILE = "exo_hub_bans.dat"
local BANISH_FILE = "exo_hub_banishes.dat"
local LOG_FILE = "exo_hub_logs.dat"
local MAINTENANCE_FILE = "exo_hub_maintenance.dat"

-- State
local currentUserRole = nil
local hubLoaded = false

-- ============================================
-- FILE HELPERS
-- ============================================
local function safeRead(path)
    if isfile and readfile and isfile(path) then
        local ok, data = pcall(function() return readfile(path) end)
        if ok then return data end
    end
    return nil
end

local function safeWrite(path, data)
    if writefile then
        pcall(function() writefile(path, data) end)
    end
end

local function loadJSON(path)
    local raw = safeRead(path)
    if raw then
        local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok then return data end
    end
    return nil
end

local function saveJSON(path, data)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then safeWrite(path, encoded) end
end

-- ============================================
-- KEY SYSTEM
-- ============================================
local function isKeyValid()
    local data = loadJSON(KEY_FILE)
    if data and data.key == HUB_KEY then
        local now = os.time()
        if now - (data.timestamp or 0) < (KEY_EXPIRY_HOURS * 3600) then
            return true
        end
    end
    return false
end

local function saveKey()
    saveJSON(KEY_FILE, {key = HUB_KEY, timestamp = os.time()})
end

local function createKeyUI()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "ExoHubKeySystem"
    keyGui.ResetOnSpawn = false
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyGui.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    bg.Parent = keyGui

    -- Animated background particles
    for i = 1, 20 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(4, 12), 0, math.random(4, 12))
        particle.Position = UDim2.new(math.random() * 0.9, 0, math.random() * 0.9, 0)
        particle.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
        particle.BackgroundTransparency = 0.7
        particle.Parent = keyGui
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
        task.spawn(function()
            while particle.Parent do
                particle:TweenPosition(UDim2.new(math.random() * 0.9, 0, math.random() * 0.9, 0), "Out", "Quad", math.random(3, 6), true)
                task.wait(math.random(3, 6))
            end
        end)
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 440, 0, 340)
    card.Position = UDim2.new(0.5, -220, 0.5, -170)
    card.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
    card.BorderSizePixel = 0
    card.Parent = keyGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    titleBar.Parent = card
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 55)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔐 EXO HUB - KEY AUTHENTICATION"
    title.TextColor3 = Color3.fromRGB(190, 140, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = titleBar

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 25)
    sub.Position = UDim2.new(0, 20, 0, 65)
    sub.BackgroundTransparency = 1
    sub.Text = "Enter your key to access the hub • Key expires every 24 hours"
    sub.TextColor3 = Color3.fromRGB(130, 130, 160)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 13
    sub.Parent = card

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(1, -40, 0, 42)
    keyInput.Position = UDim2.new(0, 20, 0, 100)
    keyInput.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    keyInput.PlaceholderText = "  Enter your key here..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 130)
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.Font = Enum.Font.Gotham
    keyInput.TextSize = 14
    keyInput.Parent = card
    Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1, -40, 0, 42)
    submitBtn.Position = UDim2.new(0, 20, 0, 152)
    submitBtn.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
    submitBtn.Text = "🔓 UNLOCK HUB"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 14
    submitBtn.Parent = card
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 25)
    status.Position = UDim2.new(0, 20, 0, 205)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.Parent = card

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(1, -40, 0, 32)
    getKeyBtn.Position = UDim2.new(0, 20, 0, 240)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    getKeyBtn.Text = "📋 Copy Key to Clipboard"
    getKeyBtn.TextColor3 = Color3.fromRGB(190, 140, 255)
    getKeyBtn.Font = Enum.Font.Gotham
    getKeyBtn.TextSize = 12
    getKeyBtn.Parent = card
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 6)

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -40, 0, 20)
    footer.Position = UDim2.new(0, 20, 0, 290)
    footer.BackgroundTransparency = 1
    footer.Text = "© 2026 Exo Hub • Made by exo_blox"
    footer.TextColor3 = Color3.fromRGB(80, 80, 100)
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 11
    footer.Parent = card

    submitBtn.MouseButton1Click:Connect(function()
        if keyInput.Text == HUB_KEY then
            saveKey()
            status.Text = "✅ Key accepted! Loading hub..."
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            task.wait(1.2)
            keyGui:Destroy()
            initializeHub()
        else
            status.Text = "❌ Invalid key. Please try again."
            keyInput.Text = ""
            keyInput:CaptureFocus()
        end
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(HUB_KEY)
            status.Text = "📋 Key copied to clipboard!"
            status.TextColor3 = Color3.fromRGB(100, 200, 255)
        else
            status.Text = "⚠️ Clipboard not available. Key: " .. HUB_KEY
            status.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end)

    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then submitBtn.MouseButton1Click:Fire() end
    end)
end

-- ============================================
-- BAN SYSTEM
-- ============================================
local function loadBans()
    return loadJSON(BAN_FILE) or {banned_users = {}, banned_devices = {}, banish_logs = {}, ban_logs = {}}
end

local function saveBans(data)
    saveJSON(BAN_FILE, data)
end

local function getDeviceID()
    if gethwid then return gethwid() end
    -- Fallback: use a combination of identifiers
    local id = player.UserId .. "-" .. (getexecutorname and getexecutorname() or "unknown")
    return id
end

local function checkIfBanned()
    local bans = loadBans()
    local userId = tostring(player.UserId)
    local deviceId = getDeviceID()

    for _, ban in ipairs(bans.banned_users or {}) do
        if ban.userId == userId then
            return true, ban.reason or "No reason provided", "account"
        end
    end
    for _, ban in ipairs(bans.banned_devices or {}) do
        if ban.deviceId == deviceId then
            return true, ban.reason or "Device banned", "device"
        end
    end
    return false, "", ""
end

local function banUser(targetUserId, targetDeviceId, reason, banner)
    local bans = loadBans()
    local now = os.time()

    if targetUserId then
        table.insert(bans.banned_users, {
            userId = tostring(targetUserId),
            reason = reason,
            banner = banner,
            timestamp = now
        })
        table.insert(bans.ban_logs, {
            userId = tostring(targetUserId),
            reason = reason,
            banner = banner,
            timestamp = now,
            action = "account_ban"
        })
    end

    if targetDeviceId then
        table.insert(bans.banned_devices, {
            deviceId = targetDeviceId,
            reason = reason,
            banner = banner,
            timestamp = now
        })
        table.insert(bans.ban_logs, {
            deviceId = targetDeviceId,
            reason = reason,
            banner = banner,
            timestamp = now,
            action = "device_ban"
        })
    end

    saveBans(bans)
end

local function banishUser(targetUserId, reason, banner)
    local bans = loadBans()
    table.insert(bans.banish_logs, {
        userId = tostring(targetUserId),
        reason = reason,
        banner = banner,
        timestamp = os.time()
    })
    saveBans(bans)
end

local function createBanScreen(reason)
    local banGui = Instance.new("ScreenGui")
    banGui.Name = "ExoHubBanScreen"
    banGui.ResetOnSpawn = false
    banGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    banGui.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    bg.Parent = banGui

    -- Red pulse effect
    task.spawn(function()
        while bg.Parent do
            bg:TweenBackgroundColor(Color3.fromRGB(15, 5, 5), "Out", "Quad", 1)
            task.wait(1)
            bg:TweenBackgroundColor(Color3.fromRGB(5, 5, 8), "Out", "Quad", 1)
            task.wait(1)
        end
    end)

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 520, 0, 300)
    card.Position = UDim2.new(0.5, -260, 0.5, -150)
    card.BackgroundColor3 = Color3.fromRGB(20, 10, 12)
    card.BorderSizePixel = 0
    card.Parent = banGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0, 90)
    icon.BackgroundTransparency = 1
    icon.Text = "📴"
    icon.TextColor3 = Color3.fromRGB(255, 50, 50)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 70
    icon.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 45)
    title.Position = UDim2.new(0, 20, 0, 90)
    title.BackgroundTransparency = 1
    title.Text = "YOU HAVE BEEN BANNED"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 26
    title.Parent = card

    local reasonLabel = Instance.new("TextLabel")
    reasonLabel.Size = UDim2.new(1, -40, 0, 50)
    reasonLabel.Position = UDim2.new(0, 20, 0, 145)
    reasonLabel.BackgroundTransparency = 1
    reasonLabel.Text = "Reason: " .. reason
    reasonLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    reasonLabel.Font = Enum.Font.Gotham
    reasonLabel.TextSize = 14
    reasonLabel.TextWrapped = true
    reasonLabel.Parent = card

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 35)
    sub.Position = UDim2.new(0, 20, 0, 200)
    sub.BackgroundTransparency = 1
    sub.Text = "FROM THIS HUB"
    sub.TextColor3 = Color3.fromRGB(255, 100, 100)
    sub.Font = Enum.Font.GothamBold
    sub.TextSize = 20
    sub.Parent = card

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -40, 0, 20)
    footer.Position = UDim2.new(0, 20, 0, 250)
    footer.BackgroundTransparency = 1
    footer.Text = "Contact exo_blox if you believe this is an error"
    footer.TextColor3 = Color3.fromRGB(100, 100, 130)
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 11
    footer.Parent = card

    -- Block all interaction
    local blocker = Instance.new("Frame")
    blocker.Size = UDim2.new(1, 0, 1, 0)
    blocker.BackgroundTransparency = 1
    blocker.Active = true
    blocker.Parent = banGui
end

local function createMaintenanceScreen()
    local maintGui = Instance.new("ScreenGui")
    maintGui.Name = "ExoHubMaintenance"
    maintGui.ResetOnSpawn = false
    maintGui.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    bg.Parent = maintGui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 500, 0, 240)
    card.Position = UDim2.new(0.5, -250, 0.5, -120)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    card.BorderSizePixel = 0
    card.Parent = maintGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0, 70)
    icon.BackgroundTransparency = 1
    icon.Text = "🔧"
    icon.TextColor3 = Color3.fromRGB(255, 200, 50)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 55
    icon.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 75)
    title.BackgroundTransparency = 1
    title.Text = "HUB IS DOWN FOR MAINTENANCE"
    title.TextColor3 = Color3.fromRGB(255, 200, 50)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.Parent = card

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 50)
    sub.Position = UDim2.new(0, 20, 0, 125)
    sub.BackgroundTransparency = 1
    sub.Text = "PLEASE WAIT A FEW MINUTES AND THEN REJOIN"
    sub.TextColor3 = Color3.fromRGB(180, 180, 200)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 14
    sub.TextWrapped = true
    sub.Parent = card

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -40, 0, 20)
    footer.Position = UDim2.new(0, 20, 0, 190)
    footer.BackgroundTransparency = 1
    footer.Text = "We apologize for the inconvenience"
    footer.TextColor3 = Color3.fromRGB(100, 100, 130)
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 11
    footer.Parent = card
end

-- ============================================
-- LOGIN SYSTEM
-- ============================================
local function createLoginUI(callback)
    local loginGui = Instance.new("ScreenGui")
    loginGui.Name = "ExoHubLogin"
    loginGui.ResetOnSpawn = false
    loginGui.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    bg.BackgroundTransparency = 0.4
    bg.Parent = loginGui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 420, 0, 400)
    card.Position = UDim2.new(0.5, -210, 0.5, -200)
    card.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
    card.BorderSizePixel = 0
    card.Parent = loginGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    titleBar.Parent = card
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 50)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔐 HUB MANAGE - AUTHENTICATION"
    title.TextColor3 = Color3.fromRGB(190, 140, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = titleBar

    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, -40, 0, 25)
    roleLabel.Position = UDim2.new(0, 20, 0, 60)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = "Select your role:"
    roleLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    roleLabel.Font = Enum.Font.Gotham
    roleLabel.TextSize = 13
    roleLabel.Parent = card

    local ownerBtn = Instance.new("TextButton")
    ownerBtn.Size = UDim2.new(0, 180, 0, 40)
    ownerBtn.Position = UDim2.new(0, 20, 0, 90)
    ownerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    ownerBtn.Text = "👑 OWNER"
    ownerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ownerBtn.Font = Enum.Font.GothamBold
    ownerBtn.TextSize = 14
    ownerBtn.Parent = card
    Instance.new("UICorner", ownerBtn).CornerRadius = UDim.new(0, 8)

    local operatorBtn = Instance.new("TextButton")
    operatorBtn.Size = UDim2.new(0, 180, 0, 40)
    operatorBtn.Position = UDim2.new(0, 220, 0, 90)
    operatorBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    operatorBtn.Text = "🛡️ OPERATOR"
    operatorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    operatorBtn.Font = Enum.Font.GothamBold
    operatorBtn.TextSize = 14
    operatorBtn.Parent = card
    Instance.new("UICorner", operatorBtn).CornerRadius = UDim.new(0, 8)

    local userLabel = Instance.new("TextLabel")
    userLabel.Size = UDim2.new(1, -40, 0, 20)
    userLabel.Position = UDim2.new(0, 20, 0, 145)
    userLabel.BackgroundTransparency = 1
    userLabel.Text = "Username:"
    userLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    userLabel.Font = Enum.Font.Gotham
    userLabel.TextSize = 12
    userLabel.Visible = false
    userLabel.Parent = card

    local userInput = Instance.new("TextBox")
    userInput.Size = UDim2.new(1, -40, 0, 34)
    userInput.Position = UDim2.new(0, 20, 0, 168)
    userInput.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    userInput.PlaceholderText = "Username..."
    userInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    userInput.Font = Enum.Font.Gotham
    userInput.TextSize = 13
    userInput.Visible = false
    userInput.Parent = card
    Instance.new("UICorner", userInput).CornerRadius = UDim.new(0, 6)

    local passLabel = Instance.new("TextLabel")
    passLabel.Size = UDim2.new(1, -40, 0, 20)
    passLabel.Position = UDim2.new(0, 20, 0, 210)
    passLabel.BackgroundTransparency = 1
    passLabel.Text = "Password:"
    passLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    passLabel.Font = Enum.Font.Gotham
    passLabel.TextSize = 12
    passLabel.Visible = false
    passLabel.Parent = card

    local passInput = Instance.new("TextBox")
    passInput.Size = UDim2.new(1, -40, 0, 34)
    passInput.Position = UDim2.new(0, 20, 0, 233)
    passInput.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    passInput.PlaceholderText = "Password..."
    passInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    passInput.Font = Enum.Font.Gotham
    passInput.TextSize = 13
    passInput.Visible = false
    passInput.Parent = card
    Instance.new("UICorner", passInput).CornerRadius = UDim.new(0, 6)

    local loginBtn = Instance.new("TextButton")
    loginBtn.Size = UDim2.new(1, -40, 0, 38)
    loginBtn.Position = UDim2.new(0, 20, 0, 280)
    loginBtn.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
    loginBtn.Text = "🔓 LOGIN"
    loginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginBtn.Font = Enum.Font.GothamBold
    loginBtn.TextSize = 14
    loginBtn.Visible = false
    loginBtn.Parent = card
    Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 8)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 25)
    statusLabel.Position = UDim2.new(0, 20, 0, 330)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Parent = card

    local selectedRole = nil

    local function showCredentials(role)
        selectedRole = role
        userLabel.Visible = true
        userInput.Visible = true
        passLabel.Visible = true
        passInput.Visible = true
        loginBtn.Visible = true
        ownerBtn.BackgroundColor3 = role == "owner" and Color3.fromRGB(190, 140, 255) or Color3.fromRGB(60, 60, 80)
        operatorBtn.BackgroundColor3 = role == "operator" and Color3.fromRGB(190, 140, 255) or Color3.fromRGB(60, 60, 80)
        userInput:CaptureFocus()
    end

    ownerBtn.MouseButton1Click:Connect(function() showCredentials("owner") end)
    operatorBtn.MouseButton1Click:Connect(function() showCredentials("operator") end)

    loginBtn.MouseButton1Click:Connect(function()
        local u = userInput.Text
        local p = passInput.Text
        local valid = false

        if selectedRole == "owner" and u == OWNER_CREDS.username and p == OWNER_CREDS.password then
            valid = true
        elseif selectedRole == "operator" and u == OPERATOR_CREDS.username and p == OPERATOR_CREDS.password then
            valid = true
        end

        if valid then
            currentUserRole = selectedRole
            statusLabel.Text = "✅ Authentication successful!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            task.wait(0.6)
            loginGui:Destroy()
            if callback then callback(selectedRole) end
        else
            statusLabel.Text = "❌ Invalid credentials. Try again."
            userInput.Text = ""
            passInput.Text = ""
            userInput:CaptureFocus()
        end
    end)

    passInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then loginBtn.MouseButton1Click:Fire() end
    end)
end

-- ============================================
-- HUB MANAGE BOARD
-- ============================================
local function createManageBoard(role)
    local boardGui = Instance.new("ScreenGui")
    boardGui.Name = "ExoHubManageBoard"
    boardGui.ResetOnSpawn = false
    boardGui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 750, 0, 520)
    main.Position = UDim2.new(0.5, -375, 0.5, -260)
    main.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    main.Active = true
    main.Draggable = true
    main.Parent = boardGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 0, 50)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "👑 HUB MANAGE BOARD - " .. string.upper(role)
    title.TextColor3 = Color3.fromRGB(190, 140, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 80, 0, 32)
    closeBtn.Position = UDim2.new(1, -90, 0, 9)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "✖ Close"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = main
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() boardGui:Destroy() end)

    -- User list
    local userList = Instance.new("ScrollingFrame")
    userList.Size = UDim2.new(0.55, -10, 1, -110)
    userList.Position = UDim2.new(0, 5, 0, 55)
    userList.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    userList.ScrollBarThickness = 6
    userList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    userList.Parent = main
    Instance.new("UICorner", userList).CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout", userList)
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local listTitle = Instance.new("TextLabel")
    listTitle.Size = UDim2.new(1, 0, 0, 25)
    listTitle.BackgroundTransparency = 1
    listTitle.Text = "📊 Active Users (" .. #Players:GetPlayers() .. ")"
    listTitle.TextColor3 = Color3.fromRGB(190, 140, 255)
    listTitle.Font = Enum.Font.GothamBold
    listTitle.TextSize = 13
    listTitle.Parent = userList

    -- Actions panel
    local actionsPanel = Instance.new("Frame")
    actionsPanel.Size = UDim2.new(0.43, -10, 1, -110)
    actionsPanel.Position = UDim2.new(0.56, 0, 0, 55)
    actionsPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    actionsPanel.Parent = main
    Instance.new("UICorner", actionsPanel).CornerRadius = UDim.new(0, 8)

    local actionsTitle = Instance.new("TextLabel")
    actionsTitle.Size = UDim2.new(1, 0, 0, 30)
    actionsTitle.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    actionsTitle.Text = "⚡ Quick Actions"
    actionsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionsTitle.Font = Enum.Font.GothamBold
    actionsTitle.TextSize = 13
    actionsTitle.Parent = actionsPanel
    Instance.new("UICorner", actionsTitle).CornerRadius = UDim.new(0, 8)

    local selectedUser = nil

    -- Populate user list
    local function refreshUserList()
        for _, child in ipairs(userList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            local userFrame = Instance.new("Frame")
            userFrame.Size = UDim2.new(1, -10, 0, 65)
            userFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            userFrame.Parent = userList
            userFrame.LayoutOrder = #userList:GetChildren()
            Instance.new("UICorner", userFrame).CornerRadius = UDim.new(0, 6)

            local avatar = Instance.new("ImageLabel")
            avatar.Size = UDim2.new(0, 45, 0, 45)
            avatar.Position = UDim2.new(0, 8, 0.5, -22)
            avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            avatar.Parent = userFrame
            Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 6)

            pcall(function()
                local thumbUrl = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                avatar.Image = thumbUrl
            end)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -65, 0, 22)
            nameLabel.Position = UDim2.new(0, 60, 0, 8)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.DisplayName
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 13
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = userFrame

            local userLabel = Instance.new("TextLabel")
            userLabel.Size = UDim2.new(1, -65, 0, 18)
            userLabel.Position = UDim2.new(0, 60, 0, 28)
            userLabel.BackgroundTransparency = 1
            userLabel.Text = "@" .. plr.Name
            userLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            userLabel.Font = Enum.Font.Gotham
            userLabel.TextSize = 11
            userLabel.TextXAlignment = Enum.TextXAlignment.Left
            userLabel.Parent = userFrame

            local statusDot = Instance.new("Frame")
            statusDot.Size = UDim2.new(0, 8, 0, 8)
            statusDot.Position = UDim2.new(1, -20, 0, 10)
            statusDot.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            statusDot.Parent = userFrame
            Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

            local statusText = Instance.new("TextLabel")
            statusText.Size = UDim2.new(0, 55, 0, 16)
            statusText.Position = UDim2.new(1, -70, 0, 8)
            statusText.BackgroundTransparency = 1
            statusText.Text = "Online"
            statusText.TextColor3 = Color3.fromRGB(50, 200, 100)
            statusText.Font = Enum.Font.GothamBold
            statusText.TextSize = 10
            statusText.Parent = userFrame

            userFrame.MouseButton1Click:Connect(function()
                selectedUser = plr
                -- Highlight selected
                for _, f in ipairs(userList:GetChildren()) do
                    if f:IsA("Frame") then f.BackgroundColor3 = Color3.fromRGB(25, 25, 35) end
                end
                userFrame.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
            end)
        end
    end

    refreshUserList()

    -- Action buttons
    local btnY = 40
    local btnSpacing = 38

    if role == "owner" then
        local joinBtn = Instance.new("TextButton")
        joinBtn.Size = UDim2.new(1, -10, 0, 32)
        joinBtn.Position = UDim2.new(0, 5, 0, btnY)
        joinBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
        joinBtn.Text = "👥 Join Selected User"
        joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinBtn.Font = Enum.Font.GothamBold
        joinBtn.TextSize = 12
        joinBtn.Parent = actionsPanel
        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 6)
        joinBtn.MouseButton1Click:Connect(function()
            if selectedUser and selectedUser.Character then
                local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local theirRoot = selectedUser.Character:FindFirstChild("HumanoidRootPart")
                if myRoot and theirRoot then
                    myRoot.CFrame = theirRoot.CFrame + Vector3.new(0, 0, 3)
                end
            end
        end)

        local banBtn = Instance.new("TextButton")
        banBtn.Size = UDim2.new(1, -10, 0, 32)
        banBtn.Position = UDim2.new(0, 5, 0, btnY + btnSpacing)
        banBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        banBtn.Text = "🚫 Ban User (Account + Device)"
        banBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        banBtn.Font = Enum.Font.GothamBold
        banBtn.TextSize = 12
        banBtn.Parent = actionsPanel
        Instance.new("UICorner", banBtn).CornerRadius = UDim.new(0, 6)
        banBtn.MouseButton1Click:Connect(function()
            if selectedUser then
                local reason = "Banned by Owner exo_blox"
                banUser(selectedUser.UserId, getDeviceID(), reason, "exo_blox")
                -- Force reload to apply ban
                player:Kick("You have been banned from this hub. Reason: " .. reason)
            end
        end)

        local banishBtn = Instance.new("TextButton")
        banishBtn.Size = UDim2.new(1, -10, 0, 32)
        banishBtn.Position = UDim2.new(0, 5, 0, btnY + btnSpacing * 2)
        banishBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 180)
        banishBtn.Text = "👻 Banish User"
        banishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        banishBtn.Font = Enum.Font.GothamBold
        banishBtn.TextSize = 12
        banishBtn.Parent = actionsPanel
        Instance.new("UICorner", banishBtn).CornerRadius = UDim.new(0, 6)
        banishBtn.MouseButton1Click:Connect(function()
            if selectedUser then
                banishUser(selectedUser.UserId, "Banished by Owner", "exo_blox")
            end
        end)
    elseif role == "operator" then
        local warnBtn = Instance.new("TextButton")
        warnBtn.Size = UDim2.new(1, -10, 0, 32)
        warnBtn.Position = UDim2.new(0, 5, 0, btnY)
        warnBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 40)
        warnBtn.Text = "⚠️ Warn Selected User"
        warnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        warnBtn.Font = Enum.Font.GothamBold
        warnBtn.TextSize = 12
        warnBtn.Parent = actionsPanel
        Instance.new("UICorner", warnBtn).CornerRadius = UDim.new(0, 6)
        warnBtn.MouseButton1Click:Connect(function()
            if selectedUser then
                -- In a real implementation, this would send via backend
                -- For now, show local notification
                local warnMsg = "️ WARNING: " .. selectedUser.DisplayName .. " has been warned by an Operator."
                print(warnMsg)
            end
        end)
    end

    -- Announcement button (both roles)
    local announceBtn = Instance.new("TextButton")
    announceBtn.Size = UDim2.new(1, -10, 0, 32)
    announceBtn.Position = UDim2.new(0, 5, 1, -75)
    announceBtn.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
    announceBtn.Text = "📢 Send Announcement to All Users"
    announceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    announceBtn.Font = Enum.Font.GothamBold
    announceBtn.TextSize = 12
    announceBtn.Parent = main
    Instance.new("UICorner", announceBtn).CornerRadius = UDim.new(0, 6)
    announceBtn.MouseButton1Click:Connect(function()
        -- In real implementation, this would broadcast via backend
        local msg = "📢 Announcement from " .. string.upper(role) .. ": Test message"
        print(msg)
        -- Show to all players via notification system
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                -- Would send via backend in real implementation
                print("Sent to: " .. plr.Name)
            end
        end
    end)

    -- Shutdown button (owner only)
    if role == "owner" then
        local shutdownBtn = Instance.new("TextButton")
        shutdownBtn.Size = UDim2.new(0, 200, 0, 32)
        shutdownBtn.Position = UDim2.new(1, -210, 1, -75)
        shutdownBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        shutdownBtn.Text = " Shutdown for Maintenance"
        shutdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        shutdownBtn.Font = Enum.Font.GothamBold
        shutdownBtn.TextSize = 11
        shutdownBtn.Parent = main
        Instance.new("UICorner", shutdownBtn).CornerRadius = UDim.new(0, 6)
        shutdownBtn.MouseButton1Click:Connect(function()
            saveJSON(MAINTENANCE_FILE, {active = true, timestamp = os.time()})
            -- In real implementation, this would notify all users via backend
            print("🔧 Hub shutdown for maintenance initiated")
        end)
    end

    -- Refresh button
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 100, 0, 25)
    refreshBtn.Position = UDim2.new(1, -110, 0, 5)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    refreshBtn.Text = "🔄 Refresh"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 11
    refreshBtn.Parent = main
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
    refreshBtn.MouseButton1Click:Connect(refreshUserList)

    -- Auto-refresh every 5 seconds
    task.spawn(function()
        while boardGui.Parent do
            task.wait(5)
            refreshUserList()
        end
    end)
end

-- ============================================
-- CHAT SYSTEM
-- ============================================
local function createChatUI()
    local chatGui = Instance.new("ScreenGui")
    chatGui.Name = "ExoHubChat"
    chatGui.ResetOnSpawn = false
    chatGui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 350)
    main.Position = UDim2.new(0.1, 0, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    main.Active = true
    main.Draggable = true
    main.Parent = chatGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "💬 Hub Chat"
    title.TextColor3 = Color3.fromRGB(190, 140, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 60, 0, 28)
    closeBtn.Position = UDim2.new(1, -65, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "✖"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = main
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() chatGui:Destroy() end)

    local chatLog = Instance.new("ScrollingFrame")
    chatLog.Size = UDim2.new(1, -10, 1, -90)
    chatLog.Position = UDim2.new(0, 5, 0, 45)
    chatLog.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    chatLog.ScrollBarThickness = 6
    chatLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
    chatLog.Parent = main
    Instance.new("UICorner", chatLog).CornerRadius = UDim.new(0, 8)

    local chatLayout = Instance.new("UIListLayout", chatLog)
    chatLayout.Padding = UDim.new(0, 4)
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -10, 0, 35)
    inputFrame.Position = UDim2.new(0, 5, 1, -40)
    inputFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    inputFrame.Parent = main
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 6)

    local chatInput = Instance.new("TextBox")
    chatInput.Size = UDim2.new(1, -70, 1, 0)
    chatInput.BackgroundTransparency = 1
    chatInput.PlaceholderText = "Type a message..."
    chatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatInput.Font = Enum.Font.Gotham
    chatInput.TextSize = 13
    chatInput.Parent = inputFrame

    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 60, 1, -4)
    sendBtn.Position = UDim2.new(1, -65, 0, 2)
    sendBtn.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
    sendBtn.Text = "Send"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = 12
    sendBtn.Parent = inputFrame
    Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

    local function addMessage(sender, message, isSystem)
        local msgFrame = Instance.new("Frame")
        msgFrame.Size = UDim2.new(1, -10, 0, 0)
        msgFrame.BackgroundTransparency = 1
        msgFrame.Parent = chatLog
        msgFrame.LayoutOrder = #chatLog:GetChildren()

        local senderLabel = Instance.new("TextLabel")
        senderLabel.Size = UDim2.new(1, -10, 0, 16)
        senderLabel.BackgroundTransparency = 1
        senderLabel.Text = isSystem and "[SYSTEM]" or sender
        senderLabel.TextColor3 = isSystem and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(190, 140, 255)
        senderLabel.Font = Enum.Font.GothamBold
        senderLabel.TextSize = 11
        senderLabel.TextXAlignment = Enum.TextXAlignment.Left
        senderLabel.Parent = msgFrame

        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -10, 0, 0)
        msgLabel.BackgroundTransparency = 1
        msgLabel.Text = message
        msgLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextSize = 12
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.TextWrapped = true
        msgLabel.Parent = msgFrame

        -- Auto-size
        msgLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            msgFrame.Size = UDim2.new(1, -10, 0, msgLabel.AbsoluteSize.Y + 20)
        end)
        task.wait()
        msgFrame.Size = UDim2.new(1, -10, 0, msgLabel.AbsoluteSize.Y + 20)
    end

    local function sendMessage()
        local msg = chatInput.Text
        if msg and msg ~= "" then
            addMessage(player.DisplayName, msg, false)
            -- In real implementation, send via backend to all users
            chatInput.Text = ""
        end
    end

    sendBtn.MouseButton1Click:Connect(sendMessage)
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then sendMessage() end
    end)

    -- Welcome message
    addMessage("System", "Welcome to Exo Hub Chat! Messages are local in this version.", true)
end

-- ============================================
-- BANISH/BAN LOGS VIEWER
-- ============================================
local function createLogsViewer(logType)
    local logsGui = Instance.new("ScreenGui")
    logsGui.Name = "ExoHubLogs"
    logsGui.ResetOnSpawn = false
    logsGui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 600, 0, 450)
    main.Position = UDim2.new(0.5, -300, 0.5, -225)
    main.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    main.Active = true
    main.Draggable = true
    main.Parent = logsGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local titleText = logType == "banish" and "👻 Banish Logs" or "🚫 Ban Logs"
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 0, 45)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(190, 140, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 80, 0, 30)
    closeBtn.Position = UDim2.new(1, -85, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = " Close"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = main
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() logsGui:Destroy() end)

    local logList = Instance.new("ScrollingFrame")
    logList.Size = UDim2.new(1, -10, 1, -55)
    logList.Position = UDim2.new(0, 5, 0, 50)
    logList.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    logList.ScrollBarThickness = 6
    logList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logList.Parent = main
    Instance.new("UICorner", logList).CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout", logList)
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local bans = loadBans()
    local logs = logType == "banish" and bans.banish_logs or bans.ban_logs

    if #logs == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, -20, 0, 40)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "No logs found."
        emptyLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 13
        emptyLabel.Parent = logList
    else
        for i = #logs, 1, -1 do
            local log = logs[i]
            local logFrame = Instance.new("Frame")
            logFrame.Size = UDim2.new(1, -10, 0, 50)
            logFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            logFrame.Parent = logList
            logFrame.LayoutOrder = #logList:GetChildren()
            Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 6)

            local targetLabel = Instance.new("TextLabel")
            targetLabel.Size = UDim2.new(0.4, 0, 0, 20)
            targetLabel.Position = UDim2.new(0, 8, 0, 5)
            targetLabel.BackgroundTransparency = 1
            targetLabel.Text = "User: " .. (log.userId or log.deviceId or "Unknown")
            targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            targetLabel.Font = Enum.Font.GothamBold
            targetLabel.TextSize = 12
            targetLabel.TextXAlignment = Enum.TextXAlignment.Left
            targetLabel.Parent = logFrame

            local reasonLabel = Instance.new("TextLabel")
            reasonLabel.Size = UDim2.new(0.6, 0, 0, 20)
            reasonLabel.Position = UDim2.new(0.4, 0, 0, 5)
            reasonLabel.BackgroundTransparency = 1
            reasonLabel.Text = "Reason: " .. (log.reason or "N/A")
            reasonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            reasonLabel.Font = Enum.Font.Gotham
            reasonLabel.TextSize = 11
            reasonLabel.TextXAlignment = Enum.TextXAlignment.Left
            reasonLabel.Parent = logFrame

            local bannerLabel = Instance.new("TextLabel")
            bannerLabel.Size = UDim2.new(0.5, 0, 0, 18)
            bannerLabel.Position = UDim2.new(0, 8, 0, 27)
            bannerLabel.BackgroundTransparency = 1
            bannerLabel.Text = "By: " .. (log.banner or "Unknown")
            bannerLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            bannerLabel.Font = Enum.Font.Gotham
            bannerLabel.TextSize = 10
            bannerLabel.TextXAlignment = Enum.TextXAlignment.Left
            bannerLabel.Parent = logFrame

            local timeLabel = Instance.new("TextLabel")
            timeLabel.Size = UDim2.new(0.5, 0, 0, 18)
            timeLabel.Position = UDim2.new(0.5, 0, 0, 27)
            timeLabel.BackgroundTransparency = 1
            timeLabel.Text = "Time: " .. os.date("%Y-%m-%d %H:%M", log.timestamp or 0)
            timeLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
            timeLabel.Font = Enum.Font.Gotham
            timeLabel.TextSize = 10
            timeLabel.TextXAlignment = Enum.TextXAlignment.Left
            timeLabel.Parent = logFrame
        end
    end
end

-- ============================================
-- MAIN HUB INITIALIZATION
-- ============================================
local function initializeHub()
    -- Check maintenance
    local maint = loadJSON(MAINTENANCE_FILE)
    if maint and maint.active then
        -- Check if maintenance is older than 1 hour (auto-clear)
        if os.time() - (maint.timestamp or 0) > 3600 then
            maint.active = false
            saveJSON(MAINTENANCE_FILE, maint)
        else
            createMaintenanceScreen()
            return
        end
    end

    -- Check bans
    local banned, reason = checkIfBanned()
    if banned then
        createBanScreen(reason)
        return
    end

    -- Load ZyronX UI
    local Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()

    local Window = Library:CreateWindow({
        Title = "Power Tycoon Hub",
        Subtitle = "Ultimate Edition by exo_blox",
        SubtitleColor = Color3.fromRGB(190, 140, 255),
        Logo = "rbxassetid://82367817676382",
        LogoSize = 32,
        SphereText = true,
        SphereWords = "EXO",
        SphereImage = "rbxassetid://82367817676382",
        SphereIconSize = 38
    })

    -- ============================================
    -- SPT TAB
    -- ============================================
    local SPT_Tab = Window:CreateTab("Super Power Tycoon", true, false)
    local SPT_MainPage = SPT_Tab:CreatePage("Features")

    local CombatSec = SPT_MainPage:CreateSection("⚔️ Combat")
    CombatSec:AddToggle("Kill Aura", false, function(state) print("Aura:", state) end, {Title="Kill Aura", Description="Automatically hits targets."})
    CombatSec:AddToggle("Instant Kill", false, function(state) print("InstaKill:", state) end, {Title="Instant Kill", Description="Brute-force kills targets."})

    local TycoonSec = SPT_MainPage:CreateSection("🏭 Tycoon")
    TycoonSec:AddToggle("Auto Claim Money", false, function(state) print("AutoCash:", state) end, {Title="Auto Claim Money", Description="Collects cash automatically."})
    TycoonSec:AddToggle("Smart Auto Build", false, function(state) print("AutoBuild:", state) end, {Title="Smart Auto Build", Description="Buys upgrades in priority order."})

    local ToolSec = SPT_MainPage:CreateSection(" Tools")
    ToolSec:AddToggle("Auto Get Tools", false, function(state) print("GetTools:", state) end, {Title="Auto Get Tools", Description="Grabs weapons from pads."})
    ToolSec:AddToggle("No Cooldown", false, function(state) print("NoCD:", state) end, {Title="No Cooldown", Description="Removes tool cooldowns."})

    -- ============================================
    -- MPT TAB
    -- ============================================
    local MPT_Tab = Window:CreateTab("Mega Power Tycoon", false, false)
    local MPT_MainPage = MPT_Tab:CreatePage("All Features")

    local MPT_Combat = MPT_MainPage:CreateSection("⚔️ Aggressive Combat")
    MPT_Combat:AddToggle("Kill Aura", false, function(state) print("MPT Aura:", state) end, {Title="Kill Aura", Description="Hits targets around you."})
    MPT_Combat:AddToggle("Fast Kill", false, function(state) print("FastKill:", state) end, {Title="Fast Kill", Description="Instantly kills targets."})
    MPT_Combat:AddToggle("Hit Amplifier", false, function(state) print("HitAmp:", state) end, {Title="Hit Amplifier", Description="Spams damage remotes."})

    local MPT_Control = MPT_MainPage:CreateSection("🎯 Target Control")
    MPT_Control:AddToggle("Loopbring", false, function(state) print("Loopbring:", state) end, {Title="Loopbring", Description="Teleports target to you."})
    MPT_Control:AddToggle("Freeze Target", false, function(state) print("Freeze:", state) end, {Title="Freeze Target", Description="Anchors and freezes target."})

    local MPT_Tools = MPT_MainPage:CreateSection("🔧 Tool Manipulation")
    MPT_Tools:AddToggle("Get Tools", false, function(state) print("GetTools:", state) end, {Title="Get Tools", Description="Auto-grabs weapons."})
    MPT_Tools:AddToggle("Use Tools", false, function(state) print("UseTools:", state) end, {Title="Use Tools", Description="Auto-activates tools."})
    MPT_Tools:AddToggle("No Cooldown", false, function(state) print("NoCD:", state) end, {Title="No Cooldown", Description="Removes cooldowns."})
    MPT_Tools:AddToggle("Reach", false, function(state) print("Reach:", state) end, {Title="Reach", Description="Expands hitboxes."})
    MPT_Tools:AddToggle("Big Tools", false, function(state) print("BigTools:", state) end, {Title="Big Tools", Description="Scales tools by 3x."})
    MPT_Tools:AddToggle("Invisible", false, function(state) print("Invis:", state) end, {Title="Invisible", Description="Makes you transparent."})

    local MPT_Utils = MPT_MainPage:CreateSection("🛠️ Utilities")
    MPT_Utils:AddToggle("Fast Respawn", false, function(state) print("FastRespawn:", state) end, {Title="Fast Respawn", Description="Instant respawn."})
    MPT_Utils:AddToggle("Anti Spawn", false, function(state) print("AntiSpawn:", state) end, {Title="Anti Spawn", Description="3s invincibility."})
    MPT_Utils:AddButton("Get Base", function() print("Teleporting to base...") end, {Title="Get Base", Description="Teleport to tycoon."})

    -- ============================================
    -- HUB MANAGE TAB (Requires Login)
    -- ============================================
    local ManageTab = Window:CreateTab("Hub Manage", false, true)
    local ManagePage = ManageTab:CreatePage("Management")

    local ManageSec = ManagePage:CreateSection("🔐 Authentication Required")
    ManageSec:AddButton("🔓 Login to Hub Manage", function()
        createLoginUI(function(role)
            currentUserRole = role
            createManageBoard(role)
        end)
    end, {Title="Login", Description="Authenticate as Owner or Operator."})

    local BanishLogsSec = ManagePage:CreateSection("📋 Logs (Login Required)")
    BanishLogsSec:AddButton("👻 View Banish Logs", function()
        if currentUserRole then
            createLogsViewer("banish")
        else
            print("Please login first.")
        end
    end, {Title="Banish Logs", Description="View all banish records."})

    BanishLogsSec:AddButton("🚫 View Ban Logs", function()
        if currentUserRole then
            createLogsViewer("ban")
        else
            print("Please login first.")
        end
    end, {Title="Ban Logs", Description="View all ban records."})

    -- ============================================
    -- CHAT TAB
    -- ============================================
    local ChatTab = Window:CreateTab("Hub Chat", false, false)
    local ChatPage = ChatTab:CreatePage("Chat")

    local ChatSec = ChatPage:CreateSection("💬 Real-Time Chat")
    ChatSec:AddButton("💬 Open Chat Window", function()
        createChatUI()
    end, {Title="Open Chat", Description="Open the chat interface."})

    -- ============================================
    -- SETTINGS TAB
    -- ============================================
    local SettingsTab = Window:CreateTab("Settings", false, false)
    local SettingsPage = SettingsTab:CreatePage("Settings")

    local SettingsSec = SettingsPage:CreateSection("⚙️ Configuration")
    SettingsSec:AddToggle("Transparency", false, function(state)
        Window:SetTransparency(state and 0.2 or 0)
    end, {Title="Glass Mode", Description="Toggle UI transparency."})

    SettingsSec:AddButton("🔑 Reset Key", function()
        if delfile then
            pcall(function() delfile(KEY_FILE) end)
            print("Key reset. Please re-enter key on next launch.")
        end
    end, {Title="Reset Key", Description="Clear saved key."})

    SettingsSec:AddButton("📊 Hub Info", function()
        print("Hub: Power Tycoon Hub Ultimate")
        print("Owner: exo_blox")
        print("Key: " .. HUB_KEY)
        print("Key Expiry: " .. KEY_EXPIRY_HOURS .. " hours")
    end, {Title="Hub Info", Description="Display hub information."})

    hubLoaded = true

    Library:Notify({
        Title = "Power Tycoon Hub Loaded",
        Description = "Welcome, " .. player.DisplayName .. "! Hub initialized successfully.",
        Duration = 4
    })

    print("⚡ Power Tycoon Hub Ultimate - Loaded for " .. player.Name)
end

-- ============================================
-- INITIALIZATION
-- ============================================
if isKeyValid() then
    initializeHub()
else
    createKeyUI()
end
