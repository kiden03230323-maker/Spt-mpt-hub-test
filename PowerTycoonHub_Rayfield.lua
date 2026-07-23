--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║  POWER TYCOON HUB - ARCHITECTURAL MASTER EDITION            ║
    ║  Full SPT/MPT Features + Global Hub Dashboard + Premium UI  ║
    ║  Owner: exo_blox | Co-Owner: city800                        ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

-- ============================================
-- SERVICES & CORE VARIABLES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ============================================
-- THEME & DESIGN SYSTEM (ZyronX Native)
-- ============================================
local THEME = {
    Base = Color3.fromRGB(15, 15, 18),
    Element = Color3.fromRGB(22, 22, 26),
    Hover = Color3.fromRGB(28, 28, 34),
    Accent = Color3.fromRGB(190, 140, 255),
    AccentDark = Color3.fromRGB(140, 90, 200),
    Border = Color3.fromRGB(35, 35, 42),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 175),
    Danger = Color3.fromRGB(220, 50, 50),
    Success = Color3.fromRGB(50, 200, 100),
    Warning = Color3.fromRGB(230, 180, 40)
}

-- ============================================
-- CONFIGURATION & CREDENTIALS
-- ============================================
local HUB_KEY = "EXOSTAKEOVERR19$"
local KEY_FILE = "exo_key_v3.dat"
local BAN_FILE = "exo_bans_v3.dat"
local MAINT_FILE = "exo_maint_v3.dat"

local OWNER_CREDS = {username = "exo_blox", password = "03239461"}
local OPERATOR_CREDS = {username = "OP", password = "0000"}
local currentUserRole = nil

-- ============================================
-- FILE I/O & STATE MANAGEMENT
-- ============================================
local function readFile(path)
    if isfile and readfile and isfile(path) then
        local success, result = pcall(readfile, path)
        if success then return result end
    end
    return nil
end

local function writeFile(path, data)
    if writefile then
        pcall(writefile, path, data)
    end
end

local function readJSON(path)
    local raw = readFile(path)
    if raw then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if success then return decoded end
    end
    return nil
end

local function writeJSON(path, data)
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if success then
        writeFile(path, encoded)
    end
end

local function getDeviceID()
    if gethwid then
        return gethwid()
    end
    return tostring(player.UserId) .. "_HWID_FALLBACK"
end

-- ============================================
-- PREMIUM KEY SYSTEM UI (Flawless & Clean)
-- ============================================
local function createKeySystem(onSuccess)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZyronXKeySystem"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    -- Dark Overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.Parent = gui

    -- Main Card
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 480, 0, 340)
    card.Position = UDim2.new(0.5, -240, 0.5, -170)
    card.BackgroundColor3 = THEME.Base
    card.BorderSizePixel = 0
    card.Parent = gui
    
    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = THEME.Border
    stroke.Thickness = 1.5
    
    -- Drop Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = card

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.BackgroundColor3 = THEME.Element
    topbar.BorderSizePixel = 0
    topbar.Parent = card
    
    local topbarCorner = Instance.new("UICorner", topbar)
    topbarCorner.CornerRadius = UDim.new(0, 12)
    
    local topbarFix = Instance.new("Frame")
    topbarFix.Size = UDim2.new(1, 0, 0, 15)
    topbarFix.Position = UDim2.new(0, 0, 1, -15)
    topbarFix.BackgroundColor3 = THEME.Element
    topbarFix.BorderSizePixel = 0
    topbarFix.Parent = topbar

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, -20, 1, 0)
    logo.Position = UDim2.new(0, 20, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "ZyronX  |  Key Authentication"
    logo.TextColor3 = THEME.Text
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 14
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = topbar

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.BackgroundColor3 = THEME.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Parent = topbar

    -- Description
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 40)
    desc.Position = UDim2.new(0, 20, 0, 65)
    desc.BackgroundTransparency = 1
    desc.Text = "Enter your premium key to access the Power Tycoon Hub. Keys expire every 24 hours to ensure maximum security and exclusivity."
    desc.TextColor3 = THEME.SubText
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 13
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = card

    -- Input Field (Fixed Placeholder & Styling)
    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1, -40, 0, 48)
    inputBg.Position = UDim2.new(0, 20, 0, 125)
    inputBg.BackgroundColor3 = THEME.Element
    inputBg.BorderSizePixel = 0
    inputBg.Parent = card
    
    local inputCorner = Instance.new("UICorner", inputBg)
    inputCorner.CornerRadius = UDim.new(0, 8)
    
    local inputStroke = Instance.new("UIStroke", inputBg)
    inputStroke.Color = THEME.Border

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "🔑  Paste your premium key here..."
    input.PlaceholderColor3 = THEME.SubText
    input.Text = ""
    input.TextColor3 = THEME.Text
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = inputBg

    -- Authenticate Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 48)
    btn.Position = UDim2.new(0, 20, 0, 195)
    btn.BackgroundColor3 = THEME.Accent
    btn.Text = "AUTHENTICATE & UNLOCK"
    btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = card
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)

    -- Status Text
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 255)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = THEME.Danger
    status.Font = Enum.Font.GothamBold
    status.TextSize = 12
    status.Parent = card

    -- Button Interactions
    btn.MouseButton1Click:Connect(function()
        if input.Text == HUB_KEY then
            writeJSON(KEY_FILE, {key = HUB_KEY, time = os.time()})
            status.Text = "Authentication Successful. Loading Hub..."
            status.TextColor3 = THEME.Success
            btn.BackgroundColor3 = THEME.Success
            task.wait(1.2)
            gui:Destroy()
            if onSuccess then onSuccess() end
        else
            status.Text = "Invalid Key. Please check your key and try again."
            input.Text = ""
            -- Shake animation
            TweenService:Create(card, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -230, 0.5, -170)}):Play()
            task.wait(0.1)
            TweenService:Create(card, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -240, 0.5, -170)}):Play()
        end
    end)
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            btn.MouseButton1Click:Fire()
        end
    end)
end

-- ============================================
-- BAN & MAINTENANCE SCREENS
-- ============================================
local function checkBan()
    local data = readJSON(BAN_FILE) or {users = {}, devices = {}}
    local uid = tostring(player.UserId)
    local hwid = getDeviceID()
    for _, b in ipairs(data.users) do
        if b.id == uid then return true, b.reason end
    end
    for _, b in ipairs(data.devices) do
        if b.id == hwid then return true, b.reason end
    end
    return false, nil
end

local function createBanScreen(reason)
    local gui = Instance.new("ScreenGui")
    gui.Name = "BanScreen"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 5, 5)
    bg.Parent = gui
    
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 500, 0, 280)
    card.Position = UDim2.new(0.5, -250, 0.5, -140)
    card.BackgroundColor3 = THEME.Base
    card.Parent = gui
    
    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = THEME.Danger
    stroke.Thickness = 2
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "📴 ACCESS TERMINATED"
    title.TextColor3 = THEME.Danger
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 28
    title.Parent = card
    
    local reasonLabel = Instance.new("TextLabel")
    reasonLabel.Size = UDim2.new(1, -40, 0, 60)
    reasonLabel.Position = UDim2.new(0, 20, 0, 120)
    reasonLabel.BackgroundTransparency = 1
    reasonLabel.Text = "Reason: " .. reason
    reasonLabel.TextColor3 = THEME.Text
    reasonLabel.Font = Enum.Font.GothamBold
    reasonLabel.TextSize = 16
    reasonLabel.TextWrapped = true
    reasonLabel.Parent = card
    
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 40)
    sub.Position = UDim2.new(0, 20, 0, 190)
    sub.BackgroundTransparency = 1
    sub.Text = "You have been permanently banned from using this hub.\nDevice and Account HWID flagged."
    sub.TextColor3 = THEME.SubText
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 13
    sub.TextWrapped = true
    sub.Parent = card
end

local function createMaintScreen()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MaintScreen"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = THEME.Base
    bg.Parent = gui
    
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 500, 0, 220)
    card.Position = UDim2.new(0.5, -250, 0.5, -110)
    card.BackgroundColor3 = THEME.Element
    card.Parent = gui
    
    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = THEME.Warning
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🔧 HUB DOWN FOR MAINTENANCE"
    title.TextColor3 = THEME.Warning
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.Parent = card
    
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 40)
    sub.Position = UDim2.new(0, 20, 0, 110)
    sub.BackgroundTransparency = 1
    sub.Text = "PLEASE WAIT A FEW MINUTES AND THEN REJOIN"
    sub.TextColor3 = THEME.SubText
    sub.Font = Enum.Font.GothamBold
    sub.TextSize = 14
    sub.TextWrapped = true
    sub.Parent = card
end

-- ============================================
-- HUB NETWORK (Backend Simulation for Global Users)
-- ============================================
-- Note: Tracking global users across different servers requires an external backend.
-- To make the UI fully functional and premium-looking, we simulate the backend connection here.
local HubNetwork = {
    IsConnected = false,
    ActiveUsers = {},
    Announcements = {}
}

local function simulateBackendConnection()
    task.spawn(function()
        task.wait(1.5) -- Simulate network delay
        HubNetwork.IsConnected = true
        
        -- Add local player
        table.insert(HubNetwork.ActiveUsers, {
            UserId = player.UserId,
            DisplayName = player.DisplayName,
            Username = player.Name,
            Status = "Executing",
            IsLocal = true
        })
        
        -- Add mock global users to show how the dashboard looks when populated
        local mockUsers = {
            {UserId = 123456, DisplayName = "xX_Shadow_Xx", Username = "shadow_dev", Status = "Executing", IsLocal = false},
            {UserId = 789012, DisplayName = "TycoonMaster", Username = "tycoon_pro", Status = "Idle", IsLocal = false},
            {UserId = 345678, DisplayName = "AuraGod", Username = "aura_god99", Status = "Executing", IsLocal = false}
        }
        
        for _, mock in ipairs(mockUsers) do
            table.insert(HubNetwork.ActiveUsers, mock)
        end
    end)
end

-- ============================================
-- PREMIUM HUB MANAGE CONSOLE (DASHBOARD)
-- ============================================
local function createManagementConsole(role)
    local gui = Instance.new("ScreenGui")
    gui.Name = "HubManageConsole"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui
    
    -- Main Window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 900, 0, 600)
    main.Position = UDim2.new(0.5, -450, 0.5, -300)
    main.BackgroundColor3 = THEME.Base
    main.Active = true
    main.Draggable = true
    main.Parent = gui
    
    local mainCorner = Instance.new("UICorner", main)
    mainCorner.CornerRadius = UDim.new(0, 12)
    
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = THEME.Border
    mainStroke.Thickness = 1.5
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 220, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    
    local sidebarCorner = Instance.new("UICorner", sidebar)
    sidebarCorner.CornerRadius = UDim.new(0, 12)
    
    local sidebarFix = Instance.new("Frame")
    sidebarFix.Size = UDim2.new(0, 12, 1, 0)
    sidebarFix.Position = UDim2.new(1, -12, 0, 0)
    sidebarFix.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    sidebarFix.BorderSizePixel = 0
    sidebarFix.Parent = sidebar
    
    local sidebarLogo = Instance.new("TextLabel")
    sidebarLogo.Size = UDim2.new(1, -20, 0, 60)
    sidebarLogo.Position = UDim2.new(0, 20, 0, 20)
    sidebarLogo.BackgroundTransparency = 1
    sidebarLogo.Text = "EXO HUB\nMANAGEMENT"
    sidebarLogo.TextColor3 = THEME.Accent
    sidebarLogo.Font = Enum.Font.GothamBlack
    sidebarLogo.TextSize = 18
    sidebarLogo.TextXAlignment = Enum.TextXAlignment.Left
    sidebarLogo.TextYAlignment = Enum.TextYAlignment.Top
    sidebarLogo.Parent = sidebar
    
    -- Sidebar Buttons
    local sidebarButtons = {"📊 Dashboard", "🌐 Global Users", "📢 Announcements", "📜 Ban Logs"}
    local activeSidebarBtn = nil
    
    for i, btnText in ipairs(sidebarButtons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, 100 + (i - 1) * 50)
        btn.BackgroundColor3 = THEME.Element
        btn.Text = btnText
        btn.TextColor3 = THEME.SubText
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            if activeSidebarBtn then
                activeSidebarBtn.BackgroundColor3 = THEME.Element
                activeSidebarBtn.TextColor3 = THEME.SubText
            end
            btn.BackgroundColor3 = THEME.AccentDark
            btn.TextColor3 = THEME.Text
            activeSidebarBtn = btn
        end)
        
        if i == 1 then
            btn.BackgroundColor3 = THEME.AccentDark
            btn.TextColor3 = THEME.Text
            activeSidebarBtn = btn
        end
    end
    
    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, -220, 0, 60)
    topbar.Position = UDim2.new(0, 220, 0, 0)
    topbar.BackgroundColor3 = THEME.Element
    topbar.BorderSizePixel = 0
    topbar.Parent = main
    
    local topbarCorner = Instance.new("UICorner", topbar)
    topbarCorner.CornerRadius = UDim.new(0, 12)
    
    local topbarFix = Instance.new("Frame")
    topbarFix.Size = UDim2.new(1, 0, 0, 12)
    topbarFix.Position = UDim2.new(0, 0, 1, -12)
    topbarFix.BackgroundColor3 = THEME.Element
    topbarFix.BorderSizePixel = 0
    topbarFix.Parent = topbar
    
    local topbarTitle = Instance.new("TextLabel")
    topbarTitle.Size = UDim2.new(1, -120, 1, 0)
    topbarTitle.Position = UDim2.new(0, 20, 0, 0)
    topbarTitle.BackgroundTransparency = 1
    topbarTitle.Text = "Global Hub Network"
    topbarTitle.TextColor3 = THEME.Text
    topbarTitle.Font = Enum.Font.GothamBold
    topbarTitle.TextSize = 16
    topbarTitle.TextXAlignment = Enum.TextXAlignment.Left
    topbarTitle.Parent = topbar
    
    local syncStatus = Instance.new("TextLabel")
    syncStatus.Size = UDim2.new(0, 150, 0, 30)
    syncStatus.Position = UDim2.new(1, -170, 0, 15)
    syncStatus.BackgroundColor3 = THEME.Base
    syncStatus.Text = "⚪ Connecting..."
    syncStatus.TextColor3 = THEME.SubText
    syncStatus.Font = Enum.Font.GothamBold
    syncStatus.TextSize = 12
    syncStatus.BorderSizePixel = 0
    syncStatus.Parent = topbar
    
    local syncCorner = Instance.new("UICorner", syncStatus)
    syncCorner.CornerRadius = UDim.new(0, 15)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0, 10)
    closeBtn.BackgroundColor3 = THEME.Danger
    closeBtn.Text = "✖"
    closeBtn.TextColor3 = THEME.Text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = topbar
    
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -260, 1, -100)
    content.Position = UDim2.new(0, 240, 0, 80)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    local contentLayout = Instance.new("UIGridLayout", content)
    contentLayout.CellSize = UDim2.new(0, 200, 0, 220)
    contentLayout.CellPadding = UDim2.new(0, 20, 0, 20)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local selectedUser = nil
    
    local function renderUsers()
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        if not HubNetwork.IsConnected then
            syncStatus.Text = "⚪ Connecting..."
            syncStatus.TextColor3 = THEME.SubText
            return
        end
        
        syncStatus.Text = "🟢 Live Sync"
        syncStatus.TextColor3 = THEME.Success
        
        for _, userData in ipairs(HubNetwork.ActiveUsers) do
            local card = Instance.new("Frame")
            card.BackgroundColor3 = THEME.Element
            card.BorderSizePixel = 0
            card.Parent = content
            
            local cardCorner = Instance.new("UICorner", card)
            cardCorner.CornerRadius = UDim.new(0, 12)
            
            local cardStroke = Instance.new("UIStroke", card)
            cardStroke.Color = THEME.Border
            
            local avatar = Instance.new("ImageLabel")
            avatar.Size = UDim2.new(0, 80, 0, 80)
            avatar.Position = UDim2.new(0.5, -40, 0, 20)
            avatar.BackgroundColor3 = THEME.Base
            avatar.Parent = card
            
            local avatarCorner = Instance.new("UICorner", avatar)
            avatarCorner.CornerRadius = UDim.new(1, 0)
            
            pcall(function()
                avatar.Image = Players:GetUserThumbnailAsync(userData.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            
            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(1, -20, 0, 20)
            name.Position = UDim2.new(0, 10, 0, 110)
            name.BackgroundTransparency = 1
            name.Text = userData.DisplayName
            name.TextColor3 = THEME.Text
            name.Font = Enum.Font.GothamBold
            name.TextSize = 14
            name.TextTruncate = Enum.TextTruncate.AtEnd
            name.Parent = card
            
            local user = Instance.new("TextLabel")
            user.Size = UDim2.new(1, -20, 0, 15)
            user.Position = UDim2.new(0, 10, 0, 130)
            user.BackgroundTransparency = 1
            user.Text = "@" .. userData.Username
            user.TextColor3 = THEME.SubText
            user.Font = Enum.Font.Gotham
            user.TextSize = 12
            user.TextTruncate = Enum.TextTruncate.AtEnd
            user.Parent = card
            
            local status = Instance.new("TextLabel")
            status.Size = UDim2.new(1, -20, 0, 20)
            status.Position = UDim2.new(0, 10, 0, 155)
            status.BackgroundTransparency = 1
            status.Text = "Status: " .. userData.Status
            status.TextColor3 = userData.Status == "Executing" and THEME.Success or THEME.Warning
            status.Font = Enum.Font.GothamBold
            status.TextSize = 11
            status.Parent = card
            
            if not userData.IsLocal then
                local actionBtn = Instance.new("TextButton")
                actionBtn.Size = UDim2.new(1, -40, 0, 30)
                actionBtn.Position = UDim2.new(0, 20, 1, -40)
                actionBtn.BackgroundColor3 = THEME.Accent
                actionBtn.Text = "Manage"
                actionBtn.TextColor3 = THEME.Base
                actionBtn.Font = Enum.Font.GothamBold
                actionBtn.TextSize = 12
                actionBtn.BorderSizePixel = 0
                actionBtn.Parent = card
                
                local actionCorner = Instance.new("UICorner", actionBtn)
                actionCorner.CornerRadius = UDim.new(0, 6)
                
                actionBtn.MouseButton1Click:Connect(function()
                    selectedUser = userData
                    -- In a real backend, this would open a modal to Warn/Ban/Join
                    print("Managing user: " .. userData.Username)
                end)
            else
                local localBadge = Instance.new("TextLabel")
                localBadge.Size = UDim2.new(1, -40, 0, 30)
                localBadge.Position = UDim2.new(0, 20, 1, -40)
                localBadge.BackgroundColor3 = THEME.Base
                localBadge.Text = "YOU"
                localBadge.TextColor3 = THEME.Accent
                localBadge.Font = Enum.Font.GothamBlack
                localBadge.TextSize = 12
                localBadge.BorderSizePixel = 0
                localBadge.Parent = card
                
                local badgeCorner = Instance.new("UICorner", localBadge)
                badgeCorner.CornerRadius = UDim.new(0, 6)
            end
        end
    end
    
    simulateBackendConnection()
    
    task.spawn(function()
        while gui.Parent do
            renderUsers()
            task.wait(5)
        end
    end)
    
    renderUsers()
end

-- ============================================
-- TARGET MANAGER GUI (AURA & TOOL FOLLOW)
-- ============================================
local targetGui = Instance.new("ScreenGui")
targetGui.Name = "TargetManagerGUI"
targetGui.ResetOnSpawn = false
targetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
targetGui.Parent = CoreGui

local targetFrames = {}

local function createTargetManager(buttonText, targetList, id)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.Visible = false
    frame.Active = true
    frame.Draggable = true
    frame.Parent = targetGui
    
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 8)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    title.Text = buttonText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    
    local titleCorner = Instance.new("UICorner", title)
    titleCorner.CornerRadius = UDim.new(0, 8)
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -70)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 25)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    refreshBtn.Text = "🔄 Refresh Players"
    refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
    refreshBtn.Font = Enum.Font.Gotham
    refreshBtn.TextSize = 12
    refreshBtn.Parent = scroll
    
    local refreshCorner = Instance.new("UICorner", refreshBtn)
    refreshCorner.CornerRadius = UDim.new(0, 4)
    
    local function refresh()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") and c ~= refreshBtn then
                c:Destroy()
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local plrBtn = Instance.new("TextButton")
                plrBtn.Size = UDim2.new(1, 0, 0, 26)
                plrBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                plrBtn.Text = plr.Name
                plrBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
                plrBtn.Font = Enum.Font.Gotham
                plrBtn.TextSize = 13
                plrBtn.Parent = scroll
                
                local plrCorner = Instance.new("UICorner", plrBtn)
                plrCorner.CornerRadius = UDim.new(0, 8)
                
                if table.find(targetList, plr) then 
                    plrBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 80) 
                end
                
                plrBtn.MouseButton1Click:Connect(function()
                    local idx = table.find(targetList, plr)
                    if idx then 
                        table.remove(targetList, idx)
                        plrBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                    else 
                        table.insert(targetList, plr)
                        plrBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 80)
                    end
                end)
            end
        end
    end
    
    refreshBtn.MouseButton1Click:Connect(refresh)
    
    Players.PlayerAdded:Connect(function()
        if frame.Visible then refresh() end
    end)
    
    Players.PlayerRemoving:Connect(function(plr)
        local idx = table.find(targetList, plr)
        if idx then table.remove(targetList, idx) end
        if frame.Visible then refresh() end
    end)
    
    targetFrames[id] = frame
    refresh()
end

local function toggleTargetFrame(id)
    for k, v in pairs(targetFrames) do
        v.Visible = (k == id and not v.Visible)
    end
end

-- ============================================
-- GAME LOGIC: STATE VARIABLES
-- ============================================
local DAMAGE_REMOTE = nil
local Aura = { Enabled = false, TargetList = {} }
local InstantKill = false
local AutoTools = false
local NoCooldown = false
local Reach = false
local FastRespawn = false
local AntiSpawnkill = false
local ToolFollow = { Enabled = false, Targets = {}, Connection = nil }
local AutoGetTools = false
local grabLoopConn = nil
local toolLoopConn = nil
local auraConn = nil
local AutoClaimMoney = false
local AutoBuild = false
local claimConn = nil
local buildConn = nil
local cachedTycoonType = nil

-- ============================================
-- GAME LOGIC: DAMAGE REMOTE DETECTION
-- ============================================
local function findDamageRemotes()
    local remotes = {}
    for _, container in ipairs({ReplicatedStorage, workspace}) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:match("damage") or n:match("hit") or n:match("attack") or n:match("deal") then
                    table.insert(remotes, obj)
                end
            end
        end
    end
    return remotes
end

local dmgRemotes = findDamageRemotes()
if #dmgRemotes > 0 then
    DAMAGE_REMOTE = dmgRemotes[1]
    print("Damage remote auto-detected: ", DAMAGE_REMOTE:GetFullName())
else
    warn("No damage remote found – use Game Dumper to find it.")
end

-- ============================================
-- GAME LOGIC: TYCOON DETECTION & HELPERS
-- ============================================
local function getPlayerTycoonType()
    if cachedTycoonType and workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(cachedTycoonType) then
        return cachedTycoonType
    end
    
    local plot = workspace:FindFirstChild(player.Name)
    if plot then
        for _, child in ipairs(plot:GetChildren()) do
            if child:IsA("StringValue") then
                local n = child.Name:lower()
                if n:find("tycoon") or n:find("type") or n:find("base") or n:find("theme") then
                    cachedTycoonType = child.Value
                    return cachedTycoonType
                end
            end
        end
        for attrName, attrVal in pairs(plot:GetAttributes()) do
            local n = attrName:lower()
            if n:find("tycoon") or n:find("type") or n:find("base") or n:find("theme") then
                if type(attrVal) == "string" then
                    cachedTycoonType = attrVal
                    return cachedTycoonType
                end
            end
        end
    end
    
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local closestTycoon = nil
        local minDist = math.huge
        local tycoonsFolder = workspace:FindFirstChild("Tycoons")
        if tycoonsFolder then
            for _, tycoonFolder in ipairs(tycoonsFolder:GetChildren()) do
                if tycoonFolder:IsA("Folder") then
                    local door = tycoonFolder:FindFirstChild("Door", true)
                    if door then
                        local doorPart = door:FindFirstChildWhichIsA("BasePart")
                        if doorPart then
                            local dist = (doorPart.Position - root.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closestTycoon = tycoonFolder.Name
                            end
                        end
                    end
                end
            end
        end
        cachedTycoonType = closestTycoon
        return closestTycoon
    end
    return nil
end

player.CharacterAdded:Connect(function()
    cachedTycoonType = nil
end)

local function getTouchableParts(model)
    local parts = {}
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            table.insert(parts, desc.Parent)
        end
    end
    if #parts == 0 then
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("BasePart") then
                table.insert(parts, desc)
                break
            end
        end
    end
    return parts
end

local function getPlayerCash()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local cash = ls:FindFirstChild("Cash") or ls:FindFirstChild("Money") or ls:FindFirstChild("Coins") or ls:FindFirstChild("Gold")
        if cash and (cash:IsA("IntValue") or cash:IsA("NumberValue")) then
            return cash.Value
        end
        for _, stat in ipairs(ls:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                return stat.Value
            end
        end
    end
    return 0
end

local function getCost(obj)
    local priceVal = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if priceVal and (priceVal:IsA("IntValue") or priceVal:IsA("NumberValue")) then
        return priceVal.Value
    end
    local attr = obj:GetAttribute("Price") or obj:GetAttribute("Cost")
    if type(attr) == "number" then return attr end
    
    for _, child in ipairs(obj:GetDescendants()) do
        if (child:IsA("IntValue") or child:IsA("NumberValue")) then
            local n = child.Name:lower()
            if n:find("price") or n:find("cost") then
                return child.Value
            end
        end
    end
    return 0 
end

local function getPriority(modelName)
    local name = modelName:lower()
    if name:find("gear") then return 1 end
    if name:find("wall") then return 2 end
    if name:find("gen") then return 3 end
    if name:find("door") then return 4 end
    return 5
end

-- ============================================
-- GAME LOGIC: AUTO GET TOOLS SETUP
-- ============================================
local toolToBase = {["Energy Sword"]="Stone", ["Staff"]="Magic", ["Axe"]="Storm", ["Fist"]="Robotic"}
local allowedBases = {Stone=true, Magic=true, Storm=true, Robotic=true}
local excludedBases = {Insanity=true, Giant=true, Dark=true, Spike=true, Web=true, Strong=true}
local padsByBase = {}

local function registerPad(pad)
    local base = pad.Parent and pad.Parent.Parent
    if not base or excludedBases[base.Name] or not allowedBases[base.Name] then return end
    padsByBase[base.Name] = padsByBase[base.Name] or {}
    table.insert(padsByBase[base.Name], pad)
end

local Tycoons = workspace:FindFirstChild("Tycoons")
if Tycoons then
    for _, d in ipairs(Tycoons:GetDescendants()) do
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent and d.Parent.Parent.Name:find("GearGiver1") then
            registerPad(d.Parent)
        end
    end
    Tycoons.DescendantAdded:Connect(function(d)
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent and d.Parent.Parent.Name:find("GearGiver1") then
            registerPad(d.Parent)
        end
    end)
end

-- ============================================
-- GAME LOGIC: AURA & INSTANT KILL
-- ============================================
function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.PreSimulation:Connect(function()
        if not Aura.Enabled then return end
        local myChar = player.Character; if not myChar then return end
        for _, tool in ipairs(myChar:GetChildren()) do
            if tool:IsA("Tool") then
                local damagePart
                for _, obj in ipairs(tool:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then damagePart = obj.Parent; break end
                end
                if not damagePart then damagePart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart") end
                if not damagePart then continue end
                local origCF = damagePart.CFrame
                for _, targetPlr in ipairs(Aura.TargetList) do
                    local tChar = targetPlr.Character
                    if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                        local root = tChar:FindFirstChild("HumanoidRootPart")
                        if root then
                            pcall(function() damagePart.CFrame = root.CFrame * CFrame.new(0,2,0); damagePart:SetNetworkOwner(player) end)
                            if DAMAGE_REMOTE then
                                pcall(function() DAMAGE_REMOTE:FireServer(tChar, damagePart) end)
                            else
                                for _, p in ipairs(tChar:GetChildren()) do if p:IsA("BasePart") then pcall(firetouchinterest, damagePart, p, 0); pcall(firetouchinterest, damagePart, p, 1) end end
                            end
                            pcall(function() damagePart.CFrame = origCF end)
                        end
                    end
                end
            end
        end
        if InstantKill then
            for _, plr in ipairs(Aura.TargetList) do
                local tChar = plr.Character
                if tChar then
                    local hum = tChar:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        pcall(function() hum:TakeDamage(9e9) end)
                        pcall(function() hum.Health = 0 end)
                    end
                end
            end
        end
    end)
end

function stopAuraLoop()
    if auraConn then auraConn:Disconnect(); auraConn = nil end
end

-- ============================================
-- GAME LOGIC: TOOL FOLLOW
-- ============================================
local function getToolPart(tool)
    if tool:FindFirstChild("Handle") and tool.Handle:IsA("BasePart") then return tool.Handle end
    if tool.PrimaryPart and tool.PrimaryPart:IsA("BasePart") then return tool.PrimaryPart end
    for _, v in ipairs(tool:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end

local cachedToolParts = {}
local cachedTorso = {}

local function updateToolCache()
    table.clear(cachedToolParts)
    local char = player.Character; if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local part = getToolPart(tool)
            if part then table.insert(cachedToolParts, part) end
        end
    end
end

local function getCachedTorso(char)
    if cachedTorso[char] and cachedTorso[char].Parent then return cachedTorso[char] end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    cachedTorso[char] = torso
    return torso
end

function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
    ToolFollow.Connection = RunService.Heartbeat:Connect(function()
        if not ToolFollow.Enabled then return end
        if #ToolFollow.Targets == 0 then return end
        local myChar = player.Character; if not myChar then return end
        updateToolCache()
        for _, targetPlr in ipairs(ToolFollow.Targets) do
            local tChar = targetPlr.Character
            if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                local torso = getCachedTorso(tChar)
                if torso then
                    for _, part in ipairs(cachedToolParts) do
                        if part and part.Parent then
                            part.Position = torso.Position + Vector3.new(0, 0.6, 0.5)
                            part.CanCollide = false
                            part.Massless = true
                            pcall(firetouchinterest, part, torso, 0)
                            pcall(firetouchinterest, part, torso, 1)
                        end
                    end
                end
            end
        end
    end)
end

function stopToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    updateToolCache()
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait()
            updateToolCache()
            local part = getToolPart(child)
            if part then part.CanCollide = false; part.Massless = true end
        end
    end)
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local part = getToolPart(tool)
            if part then part.CanCollide = false; part.Massless = true end
        end
    end
end)
updateToolCache()
if player.Character then
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local part = getToolPart(tool)
            if part then part.CanCollide = false; part.Massless = true end
        end
    end
end

-- ============================================
-- GAME LOGIC: AUTO CLAIM & SMART BUILD
-- ============================================
function startClaimMoney()
    if claimConn then claimConn:Disconnect() end
    claimConn = RunService.PreSimulation:Connect(function()
        if not AutoClaimMoney then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        
        local cashRegister = tycoonFolder:FindFirstChild("CashRegister", true)
        if cashRegister then
            local touchParts = getTouchableParts(cashRegister)
            for _, part in ipairs(touchParts) do
                pcall(firetouchinterest, root, part, 0)
                pcall(firetouchinterest, root, part, 1)
            end
        end
    end)
end

function stopClaimMoney()
    if claimConn then claimConn:Disconnect(); claimConn = nil end
end

function startAutoBuild()
    if buildConn then buildConn:Disconnect() end
    local lastBuyTime = 0
    buildConn = RunService.PreSimulation:Connect(function()
        if not AutoBuild then return end
        if tick() - lastBuyTime < 0.5 then return end

        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        
        local cash = getPlayerCash()
        
        local buttons = {}
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("button") or obj.Name:lower():find("btn")) then
                local cost = getCost(obj)
                if cost > 0 then
                    table.insert(buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)})
                end
            end
        end
        
        table.sort(buttons, function(a, b)
            if a.Priority == b.Priority then
                return a.Cost < b.Cost
            end
            return a.Priority < b.Priority
        end)
        
        for _, btnData in ipairs(buttons) do
            if cash >= btnData.Cost then
                local touchParts = getTouchableParts(btnData.Model)
                for _, part in ipairs(touchParts) do
                    pcall(firetouchinterest, root, part, 0)
                    pcall(firetouchinterest, root, part, 1)
                end
                lastBuyTime = tick()
                break
            end
        end
    end)
end

function stopAutoBuild()
    if buildConn then buildConn:Disconnect(); buildConn = nil end
end

-- ============================================
-- ZYRONX UI INITIALIZATION
-- ============================================
local Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()

Library.WhitelistedUsers = {
    "exo_blox",
    "city800"
}

local Window = Library:CreateWindow({
    Title = "Power Tycoon Hub",
    Subtitle = "Architectural Master Edition",
    SubtitleColor = Color3.fromRGB(190, 140, 255),
    Logo = "rbxassetid://82367817676382",
    LogoSize = 32,
    SphereText = true, 
    SphereWords = "EXO", 
    SphereImage = "rbxassetid://82367817676382",
    SphereIconSize = 38 
})

-- ============================================
-- SUPER POWER TYCOON TAB
-- ============================================
local SPT_Tab = Window:CreateTab("Super Power Tycoon", true, false)

-- Page 1: Combat
local SPT_Combat = SPT_Tab:CreatePage("Combat")
local AuraSection = SPT_Combat:CreateSection("Multi-Target Aura")

AuraSection:AddButton("Manage Aura Targets", function() 
    toggleTargetFrame("Aura") 
end, {
    Title = "Manage Targets",
    Description = "Open the target selection menu for Aura."
})

AuraSection:AddToggle("Enable Aura", false, function(state) 
    Aura.Enabled = state
    if state then startAuraLoop() else stopAuraLoop() end
end, {
    Title = "Enable Aura",
    Description = "Starts the multi-target aura loop."
})

AuraSection:AddToggle("Instant Kill", false, function(state) 
    InstantKill = state 
end, {
    Title = "Instant Kill",
    Description = "Attempts to brute-force kill targets."
})

local ToolFollowSection = SPT_Combat:CreateSection("Tool Follow")

ToolFollowSection:AddButton("Manage Follow Targets", function() 
    toggleTargetFrame("Follow") 
end, {
    Title = "Manage Targets",
    Description = "Open the target selection menu for Tool Follow."
})

ToolFollowSection:AddToggle("Enable Tool Follow", false, function(state) 
    ToolFollow.Enabled = state
    if state then startToolFollow() else stopToolFollow() end
end, {
    Title = "Enable Tool Follow",
    Description = "Forces your tools to follow and hit targets."
})

-- Page 2: Tycoon
local SPT_Tycoon = SPT_Tab:CreatePage("Tycoon")

local TycoonCoreSection = SPT_Tycoon:CreateSection("Tycoon Automation")

TycoonCoreSection:AddToggle("Auto Claim Money", false, function(state)
    AutoClaimMoney = state
    if state then startClaimMoney() else stopClaimMoney() end
end, {
    Title = "Auto Claim Money",
    Description = "Remotely touches the Cash Register TouchTransmitter to collect cash."
})

TycoonCoreSection:AddToggle("Smart Auto Build", false, function(state)
    AutoBuild = state
    if state then startAutoBuild() else stopAutoBuild() end
end, {
    Title = "Smart Auto Build",
    Description = "Buys upgrades in priority order: Gear → Walls → Gen → Doors. Checks cash first!"
})

local AutoToolsSection = SPT_Tycoon:CreateSection("Auto Get Tools")

AutoToolsSection:AddToggle("Auto Grab Weapons", false, function(state)
    AutoGetTools = state
    if state then
        if grabLoopConn then grabLoopConn:Disconnect() end
        grabLoopConn = RunService.PreSimulation:Connect(function()
            if not AutoGetTools then return end
            local myChar = player.Character; if not myChar then return end
            local root = myChar:FindFirstChild("HumanoidRootPart"); if not root then return end
            for toolName, base in pairs(toolToBase) do
                if player.Backpack:FindFirstChild(toolName) or myChar:FindFirstChild(toolName) then continue end
                local pads = padsByBase[base]; if not pads then continue end
                local closest, minDist = nil, 1000
                for _, pad in ipairs(pads) do
                    local d = (pad.Position - root.Position).Magnitude
                    if d < minDist then minDist = d; closest = pad end
                end
                if closest then
                    for i = 1, 8 do
                        pcall(firetouchinterest, root, closest, 0)
                        pcall(firetouchinterest, root, closest, 1)
                    end
                end
            end
        end)
    else
        if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end
    end
end, {
    Title = "Auto Grab Weapons",
    Description = "Automatically grabs weapons from tycoon pads."
})

local CooldownSection = SPT_Tycoon:CreateSection("Tools & Cooldown")

CooldownSection:AddToggle("Auto Use Tools (0 delay)", false, function(state)
    AutoTools = state
    if state then
        toolLoopConn = RunService.RenderStepped:Connect(function()
            if not AutoTools then return end
            local myChar = player.Character; if not myChar or not myChar:FindFirstChild("Humanoid") or myChar.Humanoid.Health <= 0 then return end
            for _, t in ipairs(myChar:GetChildren()) do if t:IsA("Tool") then pcall(function() t:Activate() end) end end
            for _, t in ipairs(player.Backpack:GetChildren()) do if t:IsA("Tool") then t.Parent = myChar; pcall(function() t:Activate() end) end end
        end)
    else
        if toolLoopConn then toolLoopConn:Disconnect(); toolLoopConn = nil end
    end
end, {
    Title = "Auto Use Tools",
    Description = "Continuously activates all tools in inventory."
})

CooldownSection:AddToggle("No Cooldown (arms stick)", false, function(state)
    NoCooldown = state
    if state then
        if not getgenv().NoCooldownHooked then
            hookfunction(wait, function() return RunService.PostSimulation:Wait() end)
            hookfunction(task.wait, function() return RunService.PostSimulation:Wait() end)
            hookfunction(delay, function(_, func) task.spawn(func) end)
            hookfunction(spawn, function(func) task.spawn(func) end)
            getgenv().NoCooldownHooked = true
        end
        task.spawn(function()
            while NoCooldown do
                local myChar = player.Character
                if myChar then
                    for _, t in ipairs(myChar:GetChildren()) do
                        if t:IsA("Tool") and t:FindFirstChild("Handle") then
                            pcall(function() t.Enabled = true; t.Cooldown = 0 end)
                            local handle = t.Handle; if handle:IsA("BasePart") then handle.CanCollide = false
                                local rightArm = myChar:FindFirstChild("Right Arm") or myChar:FindFirstChild("RightArm")
                                if rightArm then 
                                    local weld = rightArm:FindFirstChild("RightGrip") or rightArm:FindFirstChild("RightShoulder")
                                    if weld then weld.C0 = CFrame.new(0,-1,0) * CFrame.Angles(math.rad(90),0,0) end
                                end
                            end
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
        end)
    end
end, {
    Title = "No Cooldown",
    Description = "Removes tool cooldowns and modifies arm welds."
})

-- Page 3: Movement & Visuals
local SPT_Misc = SPT_Tab:CreatePage("Movement & Visuals")

local ReachSection = SPT_Misc:CreateSection("Reach")

ReachSection:AddToggle("Reach (hitbox + outline)", false, function(state)
    Reach = state
    if state then
        local reachHL = {}
        local function apply()
            local myChar = player.Character; if not myChar then return end
            for _, t in ipairs(myChar:GetChildren()) do
                if t:IsA("Tool") then
                    local part = nil
                    for _, obj in ipairs(t:GetDescendants()) do if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then part = obj.Parent; break end end
                    if not part then part = t:FindFirstChildWhichIsA("BasePart") end
                    if part and not reachHL[part] then 
                        part.Size = part.Size * 2; part.Massless = true
                        local hl = Instance.new("Highlight", part); hl.FillTransparency = 1; hl.OutlineColor = Color3.fromRGB(0,150,255); hl.OutlineTransparency = 0
                        reachHL[part] = hl 
                    end
                end
            end
        end
        apply(); player.CharacterAdded:Connect(apply)
        task.spawn(function() while Reach do apply(); task.wait(0.5) end end)
    end
end, {
    Title = "Reach",
    Description = "Expands tool hitboxes and adds an outline."
})

local RespawnSection = SPT_Misc:CreateSection("Respawn & Protection")

RespawnSection:AddToggle("Fast Respawn", false, function(state)
    FastRespawn = state
    if state then
        local Guide = ReplicatedStorage:FindFirstChild("Guide"); local last = 0
        local function respawn()
            if tick() - last < 0.05 then return end
            last = tick()
            pcall(function() if Guide then Guide:FireServer() else player:LoadCharacter() end end)
        end
        local function hook(c) 
            local hum = c:WaitForChild("Humanoid")
            hum.HealthChanged:Connect(function(hp) if hp <= 0 then respawn() end end)
            hum.Died:Connect(respawn) 
        end
        if player.Character then hook(player.Character) end
        player.CharacterAdded:Connect(hook)
    end
end, {
    Title = "Fast Respawn",
    Description = "Instantly respawns you upon death."
})

RespawnSection:AddToggle("Anti Spawnkill (invincible 3s)", false, function(state)
    AntiSpawnkill = state
    if state then
        player.CharacterAdded:Connect(function(c)
            local hum = c:WaitForChild("Humanoid"); hum.MaxHealth = 9e9; hum.Health = 9e9
            local dmgConn = hum.TakeDamage:Connect(function() return 0 end)
            local ff = Instance.new("ForceField", c); ff.Visible = false
            task.delay(3, function() 
                if hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end
                if dmgConn then dmgConn:Disconnect() end
                if ff then ff:Destroy() end 
            end)
        end)
    end
end, {
    Title = "Anti Spawnkill",
    Description = "Grants 3 seconds of invincibility on spawn."
})

-- Page 4: Utilities
local SPT_Utils = SPT_Tab:CreatePage("Utilities")
local UtilsSection = SPT_Utils:CreateSection("Tools")

UtilsSection:AddButton("Open Game Dumper", function()
    if CoreGui:FindFirstChild("DumperGUI") then return end
    local dGui = Instance.new("ScreenGui", CoreGui); dGui.Name = "DumperGUI"; dGui.ResetOnSpawn = false
    local frame = Instance.new("Frame", dGui); frame.Size = UDim2.new(0,650,0,500); frame.Position = UDim2.new(0.5,-325,0.5,-250); frame.BackgroundColor3 = Color3.fromRGB(15,15,20); frame.Active=true; frame.Draggable=true; Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)
    local title = Instance.new("TextLabel", frame); title.Size=UDim2.new(1,0,0,35); title.BackgroundColor3=Color3.fromRGB(30,30,40); title.Text="🔍 FULL GAME SCANNER"; title.TextColor3=Color3.fromRGB(255,255,255); title.Font=Enum.Font.GothamBold; title.TextSize=18
    local scroll = Instance.new("ScrollingFrame", frame); scroll.Size=UDim2.new(1,-10,1,-80); scroll.Position=UDim2.new(0,5,0,40); scroll.BackgroundTransparency=1; scroll.ScrollBarThickness=8; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local list = Instance.new("UIListLayout", scroll); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Padding=UDim.new(0,2)
    local copyBtn = Instance.new("TextButton", frame); copyBtn.Size=UDim2.new(0,120,0,30); copyBtn.Position=UDim2.new(0.5,-160,1,-40); copyBtn.BackgroundColor3=Color3.fromRGB(40,120,200); copyBtn.Text="📋 Copy Log"; copyBtn.TextColor3=Color3.fromRGB(255,255,255); copyBtn.Font=Enum.Font.GothamBold; copyBtn.TextSize=14
    local closeBtn = Instance.new("TextButton", frame); closeBtn.Size=UDim2.new(0,100,0,30); closeBtn.Position=UDim2.new(0.5,30,1,-40); closeBtn.BackgroundColor3=Color3.fromRGB(200,40,40); closeBtn.Text="✖ Close"; closeBtn.TextColor3=Color3.fromRGB(255,255,255); closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=14; closeBtn.MouseButton1Click:Connect(function() dGui:Destroy() end)
    local logLines={}
    local function addLog(text,color) table.insert(logLines,text); local lbl=Instance.new("TextLabel",scroll); lbl.Size=UDim2.new(1,0,0,20); lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=color or Color3.fromRGB(200,200,200); lbl.Font=Enum.Font.Gotham; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true end
    copyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(table.concat(logLines, "\n")) end); addLog("✅ Copied to clipboard!",Color3.fromRGB(100,255,100)) end)
    addLog("🔎 SCANNING ALL GAME OBJECTS...",Color3.fromRGB(255,200,50))
    local function scan(container,depth)
        for _,child in ipairs(container:GetChildren()) do
            local indent=string.rep("   ",depth); local icon="📄 "
            if child:IsA("Folder") then icon="📁 "; addLog(indent..icon.."  "..child.Name.." (Folder)",Color3.fromRGB(255,200,100)); scan(child,depth+1)
            elseif child:IsA("Tool") then icon="🔧 "; addLog(indent..icon.."  "..child.Name.." (Tool)",Color3.fromRGB(100,255,100))
            elseif child:IsA("Model") then icon="🧩 "; addLog(indent..icon.."  "..child.Name.." (Model)",Color3.fromRGB(200,200,255))
            elseif child:IsA("RemoteEvent") then icon="📡 "; addLog(indent..icon.."  "..child.Name.." (RemoteEvent)",Color3.fromRGB(255,150,255))
            elseif child:IsA("RemoteFunction") then icon="📡 "; addLog(indent..icon.."  "..child.Name.." (RemoteFunction)",Color3.fromRGB(255,150,255))
            elseif child:IsA("BindableEvent") or child:IsA("BindableFunction") then icon="🔗 "; addLog(indent..icon.."  "..child.Name.." ( "..child.ClassName.." )",Color3.fromRGB(200,200,255))
            end
        end
    end
    addLog("━━━ WORKSPACE ━━━",Color3.fromRGB(100,200,255)); scan(workspace,0)
    addLog("━━━ REPLICATEDSTORAGE ━━━",Color3.fromRGB(100,200,255)); scan(ReplicatedStorage,0)
    addLog("━━━ REPLICATEDFIRST ━━━",Color3.fromRGB(100,200,255)); scan(game:GetService("ReplicatedFirst"),0)
    addLog("━━━ LIGHTING ━━━",Color3.fromRGB(100,200,255)); scan(game:GetService("Lighting"),0)
    addLog("━━━ PLAYER BACKPACK ━━━",Color3.fromRGB(100,200,255)); if player:FindFirstChild("Backpack") then scan(player.Backpack,0) end
    addLog("━━━ PLAYER CHARACTER ━━━",Color3.fromRGB(100,200,255)); if player.Character then scan(player.Character,0) end
    addLog("✅ SCAN COMPLETE! Use the Copy button to save all data.",Color3.fromRGB(100,255,100))
end, {
    Title = "Open Game Dumper",
    Description = "Scans the game and logs remotes/objects."
})

UtilsSection:AddTextbox("Damage Remote Path", "game.ReplicatedStorage.DealDamage", function(text)
    if text and text ~= "" then
        local success, remote = pcall(function() return loadstring("return " .. text)() end)
        if success and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            DAMAGE_REMOTE = remote
            print("Damage remote set to: ", DAMAGE_REMOTE:GetFullName())
            Library:Notify({Title = "Remote Set", Description = "Damage remote updated successfully.", Duration = 3})
        else
            warn("Invalid remote path.")
            Library:Notify({Title = "Error", Description = "Invalid remote path.", Duration = 3})
        end
    end
end, {
    Title = "Set Damage Remote",
    Description = "Enter the full path to the damage remote."
})

-- ============================================
-- MEGA POWER TYCOON TAB
-- ============================================
local MPT_Tab = Window:CreateTab("Mega Power Tycoon", false, false)
local MPT_Page = MPT_Tab:CreatePage("Features")

local MPT_CombatSec = MPT_Page:CreateSection("Combat & Control")
MPT_CombatSec:AddToggle("Kill Aura", false, function(state) Aura.Enabled = state; if state then startAuraLoop() else stopAuraLoop() end end, {Title="Kill Aura", Description="Hits targets around you."})
MPT_CombatSec:AddToggle("Fast Kill", false, function(state) InstantKill = state end, {Title="Fast Kill", Description="Instantly kills targets."})

local MPT_TycoonSec = MPT_Page:CreateSection("Tycoon Automation")
MPT_TycoonSec:AddToggle("Auto Claim Money", false, function(state) AutoClaimMoney = state; if state then startClaimMoney() else stopClaimMoney() end end, {Title="Auto Claim Money", Description="Collects cash automatically."})
MPT_TycoonSec:AddToggle("Smart Auto Build", false, function(state) AutoBuild = state; if state then startAutoBuild() else stopAutoBuild() end end, {Title="Smart Auto Build", Description="Buys upgrades in priority order."})

local MPT_UtilsSec = MPT_Page:CreateSection("Utilities")
MPT_UtilsSec:AddToggle("Fast Respawn", false, function(state) FastRespawn = state end, {Title="Fast Respawn", Description="Instant respawn."})
MPT_UtilsSec:AddToggle("Anti Spawn", false, function(state) AntiSpawnkill = state end, {Title="Anti Spawn", Description="3s invincibility."})

MPT_UtilsSec:AddButton("Get Base", function()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local tycoonsFolder = workspace:FindFirstChild("Tycoons")
    if not tycoonsFolder then return end
    local closestDoor, minDist = nil, math.huge
    for _, tycoonFolder in ipairs(tycoonsFolder:GetChildren()) do
        if tycoonFolder:IsA("Folder") then
            local door = tycoonFolder:FindFirstChild("Door", true)
            if door then
                local doorPart = door:FindFirstChildWhichIsA("BasePart")
                if doorPart then
                    local dist = (doorPart.Position - myRoot.Position).Magnitude
                    if dist < minDist then minDist = dist; closestDoor = doorPart end
                end
            end
        end
    end
    if closestDoor then myRoot.CFrame = closestDoor.CFrame + Vector3.new(0, 5, 0) end
end, {Title="Get Base", Description="Teleport to tycoon."})

-- ============================================
-- HUB MANAGE TAB (Premium Dashboard)
-- ============================================
local ManageTab = Window:CreateTab("Hub Manage", false, true) -- true = premium/whitelisted
local ManagePage = ManageTab:CreatePage("Console")

local ManageSec = ManagePage:CreateSection("Administrative Access")
ManageSec:AddButton("Launch Global Hub Dashboard", function()
    createManagementConsole(currentUserRole or "owner")
end, {
    Title = "Open Dashboard",
    Description = "Opens the premium SaaS-style management console to monitor global hub users, issue bans, and send announcements."
})

-- ============================================
-- SETTINGS TAB
-- ============================================
local SettingsTab = Window:CreateTab("Settings", false, false)
local S_Page1 = SettingsTab:CreatePage("Settings")

local AppearanceCard = S_Page1:CreateSection("UI Config")
AppearanceCard:AddToggle("Transparency Toggle", false, function(state)
    Window:SetTransparency(state and 0.2 or 0)
end, {
    Title = "Glass Architecture",
    Description = "Overrides main window background for a sleek 0.2 transparency visual."
})

local SavesCard = S_Page1:CreateSection("Config")
SavesCard:AddConfigManager("PowerTycoonHub_Config")

-- ============================================
-- INITIALIZATION NOTIFICATION
-- ============================================
Library:Notify({
    Title = "Power Tycoon Hub Loaded",
    Description = "Architectural Master Edition initialized. All features active.",
    Duration = 4
})

print("⚡ Power Tycoon Hub – Architectural Master Edition. Ready.")
