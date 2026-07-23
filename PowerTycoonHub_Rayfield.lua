--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║  POWER TYCOON HUB - ARCHITECTURAL INTEGRATION EDITION       ║
    ║  Native ZyronX UI + Premium Custom Overlays                 ║
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

local HUB_KEY = "EXOSTAKEOVERR19$"
local KEY_FILE = "exo_key_v2.dat"
local BAN_FILE = "exo_bans_v2.dat"
local MAINT_FILE = "exo_maint_v2.dat"

local OWNER_CREDS = {username = "exo_blox", password = "03239461"}
local OPERATOR_CREDS = {username = "OP", password = "0000"}
local currentUserRole = nil

-- ============================================
-- ZYRONX THEME PALETTE (For Custom Overlays)
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
-- FILE & STATE MANAGEMENT
-- ============================================
local function readFile(path)
    if isfile and readfile and isfile(path) then
        local s, r = pcall(readfile, path)
        if s then return r end
    end
end

local function writeFile(path, data)
    if writefile then pcall(writefile, path, data) end
end

local function readJSON(path)
    local raw = readFile(path)
    if raw then
        local s, d = pcall(HttpService.JSONDecode, HttpService, raw)
        if s then return d end
    end
    return nil
end

local function writeJSON(path, data)
    local s, e = pcall(HttpService.JSONEncode, HttpService, data)
    if s then writeFile(path, e) end
end

local function getDeviceID()
    if gethwid then return gethwid() end
    return tostring(player.UserId) .. "_HW"
end

-- ============================================
-- PREMIUM KEY SYSTEM UI (ZyronX Native Style)
-- ============================================
local function createKeySystem(onSuccess)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZyronXKey"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.3
    overlay.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 460, 0, 320)
    card.Position = UDim2.new(0.5, -230, 0.5, -160)
    card.BackgroundColor3 = THEME.Base
    card.BorderSizePixel = 0
    card.Parent = gui
    
    local corner = Instance.new("UICorner", card); corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", card); stroke.Color = THEME.Border; stroke.Thickness = 1.5
    
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

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.BackgroundColor3 = THEME.Element
    topbar.BorderSizePixel = 0
    topbar.Parent = card
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 12)
    
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

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1, -40, 0, 44)
    inputBg.Position = UDim2.new(0, 20, 0, 125)
    inputBg.BackgroundColor3 = THEME.Element
    inputBg.BorderSizePixel = 0
    inputBg.Parent = card
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", inputBg).Color = THEME.Border

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "Paste your key here..."
    input.PlaceholderColor3 = THEME.SubText
    input.Text = ""
    input.TextColor3 = THEME.Text
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.Parent = inputBg

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 44)
    btn.Position = UDim2.new(0, 20, 0, 185)
    btn.BackgroundColor3 = THEME.Accent
    btn.Text = "AUTHENTICATE & UNLOCK"
    btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 240)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = THEME.Danger
    status.Font = Enum.Font.GothamBold
    status.TextSize = 12
    status.Parent = card

    btn.MouseButton1Click:Connect(function()
        if input.Text == HUB_KEY then
            writeJSON(KEY_FILE, {key = HUB_KEY, time = os.time()})
            status.Text = "Authentication Successful. Loading Hub..."
            status.TextColor3 = THEME.Success
            btn.BackgroundColor3 = THEME.Success
            task.wait(1)
            gui:Destroy()
            if onSuccess then onSuccess() end
        else
            status.Text = "Invalid Key. Please check your key and try again."
            input.Text = ""
            TweenService:Create(card, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -220, 0.5, -160)}):Play()
            task.wait(0.1)
            TweenService:Create(card, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -230, 0.5, -160)}):Play()
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
    for _, b in ipairs(data.users) do if b.id == uid then return true, b.reason end end
    for _, b in ipairs(data.devices) do if b.id == hwid then return true, b.reason end end
    return false
end

local function createBanScreen(reason)
    local gui = Instance.new("ScreenGui"); gui.Name = "Ban"; gui.ResetOnSpawn = false; gui.Parent = CoreGui
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(10,5,5); bg.Parent = gui
    local card = Instance.new("Frame"); card.Size = UDim2.new(0,500,0,280); card.Position = UDim2.new(0.5,-250,0.5,-140); card.BackgroundColor3 = THEME.Base; card.Parent = gui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", card).Color = THEME.Danger; Instance.new("UIStroke", card).Thickness = 2
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,0,0,60); t.Position = UDim2.new(0,0,0,40); t.BackgroundTransparency = 1; t.Text = "📴 ACCESS TERMINATED"; t.TextColor3 = THEME.Danger; t.Font = Enum.Font.GothamBlack; t.TextSize = 28; t.Parent = card
    local r = Instance.new("TextLabel"); r.Size = UDim2.new(1,-40,0,60); r.Position = UDim2.new(0,20,0,120); r.BackgroundTransparency = 1; r.Text = "Reason: " .. reason; r.TextColor3 = THEME.Text; r.Font = Enum.Font.GothamBold; r.TextSize = 16; r.TextWrapped = true; r.Parent = card
    local s = Instance.new("TextLabel"); s.Size = UDim2.new(1,-40,0,40); s.Position = UDim2.new(0,20,0,190); s.BackgroundTransparency = 1; s.Text = "You have been permanently banned from using this hub.\nDevice and Account HWID flagged."; s.TextColor3 = THEME.SubText; s.Font = Enum.Font.Gotham; s.TextSize = 13; s.TextWrapped = true; s.Parent = card
end

local function createMaintScreen()
    local gui = Instance.new("ScreenGui"); gui.Name = "Maint"; gui.ResetOnSpawn = false; gui.Parent = CoreGui
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = THEME.Base; bg.Parent = gui
    local card = Instance.new("Frame"); card.Size = UDim2.new(0,500,0,220); card.Position = UDim2.new(0.5,-250,0.5,-110); card.BackgroundColor3 = THEME.Element; card.Parent = gui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", card).Color = THEME.Warning
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,0,0,50); t.Position = UDim2.new(0,0,0,40); t.BackgroundTransparency = 1; t.Text = "🔧 HUB DOWN FOR MAINTENANCE"; t.TextColor3 = THEME.Warning; t.Font = Enum.Font.GothamBlack; t.TextSize = 22; t.Parent = card
    local s = Instance.new("TextLabel"); s.Size = UDim2.new(1,-40,0,40); s.Position = UDim2.new(0,20,0,110); s.BackgroundTransparency = 1; s.Text = "PLEASE WAIT A FEW MINUTES AND THEN REJOIN"; s.TextColor3 = THEME.SubText; s.Font = Enum.Font.GothamBold; s.TextSize = 14; s.TextWrapped = true; s.Parent = card
end

-- ============================================
-- PREMIUM MANAGEMENT CONSOLE (ZyronX Style)
-- ============================================
local function createManagementConsole(role)
    local gui = Instance.new("ScreenGui"); gui.Name = "Console"; gui.ResetOnSpawn = false; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = CoreGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 800, 0, 550)
    main.Position = UDim2.new(0.5, -400, 0.5, -275)
    main.BackgroundColor3 = THEME.Base
    main.Active = true; main.Draggable = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", main).Color = THEME.Border; Instance.new("UIStroke", main).Thickness = 1.5
    
    local topbar = Instance.new("Frame"); topbar.Size = UDim2.new(1,0,0,45); topbar.BackgroundColor3 = THEME.Element; topbar.BorderSizePixel = 0; topbar.Parent = main
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 12)
    local topbarFix = Instance.new("Frame"); topbarFix.Size = UDim2.new(1,0,0,15); topbarFix.Position = UDim2.new(0,0,1,-15); topbarFix.BackgroundColor3 = THEME.Element; topbarFix.BorderSizePixel = 0; topbarFix.Parent = topbar
    local accent = Instance.new("Frame"); accent.Size = UDim2.new(1,0,0,2); accent.Position = UDim2.new(0,0,1,0); accent.BackgroundColor3 = THEME.Accent; accent.BorderSizePixel = 0; accent.Parent = topbar
    
    local title = Instance.new("TextLabel"); title.Size = UDim2.new(1,-100,1,0); title.Position = UDim2.new(0,20,0,0); title.BackgroundTransparency = 1; title.Text = "Management Console  |  Role: " .. string.upper(role); title.TextColor3 = THEME.Text; title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = topbar
    
    local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0,80,0,30); closeBtn.Position = UDim2.new(1,-90,0,7); closeBtn.BackgroundColor3 = THEME.Danger; closeBtn.Text = "✖ Close"; closeBtn.TextColor3 = THEME.Text; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 12; closeBtn.BorderSizePixel = 0; closeBtn.Parent = topbar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Left Panel: Player List
    local leftPanel = Instance.new("Frame"); leftPanel.Size = UDim2.new(0, 300, 1, -65); leftPanel.Position = UDim2.new(0, 10, 0, 55); leftPanel.BackgroundColor3 = THEME.Element; leftPanel.BorderSizePixel = 0; leftPanel.Parent = main
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 8)
    
    local listHeader = Instance.new("TextLabel"); listHeader.Size = UDim2.new(1,-20,0,30); listHeader.Position = UDim2.new(0,10,0,5); listHeader.BackgroundTransparency = 1; listHeader.Text = "Active Hub Users"; listHeader.TextColor3 = THEME.Accent; listHeader.Font = Enum.Font.GothamBold; listHeader.TextSize = 13; listHeader.TextXAlignment = Enum.TextXAlignment.Left; listHeader.Parent = leftPanel
    
    local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1,-10,1,-45); scroll.Position = UDim2.new(0,5,0,40); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 4; scroll.ScrollBarImageColor3 = THEME.Accent; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = leftPanel
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 6); layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Right Panel: Actions
    local rightPanel = Instance.new("Frame"); rightPanel.Size = UDim2.new(1, -330, 1, -65); rightPanel.Position = UDim2.new(0, 320, 0, 55); rightPanel.BackgroundColor3 = THEME.Element; rightPanel.BorderSizePixel = 0; rightPanel.Parent = main
    Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 8)
    
    local actHeader = Instance.new("TextLabel"); actHeader.Size = UDim2.new(1,-20,0,30); actHeader.Position = UDim2.new(0,10,0,5); actHeader.BackgroundTransparency = 1; actHeader.Text = "Administrative Actions"; actHeader.TextColor3 = THEME.Accent; actHeader.Font = Enum.Font.GothamBold; actHeader.TextSize = 13; actHeader.TextXAlignment = Enum.TextXAlignment.Left; actHeader.Parent = rightPanel
    
    local selectedPlayer = nil
    
    local function createActionBtn(text, color, yPos, callback)
        local b = Instance.new("TextButton"); b.Size = UDim2.new(1,-20,0,40); b.Position = UDim2.new(0,10,0,yPos); b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = THEME.Text; b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.BorderSizePixel = 0; b.Parent = rightPanel
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function() if selectedPlayer then callback(selectedPlayer) end end)
        return b
    end

    local joinBtn = createActionBtn("👥 Join Selected User", Color3.fromRGB(40, 100, 200), 45, function(p)
        if p.Character and player.Character then
            local r1 = p.Character:FindFirstChild("HumanoidRootPart")
            local r2 = player.Character:FindFirstChild("HumanoidRootPart")
            if r1 and r2 then r2.CFrame = r1.CFrame + Vector3.new(0,0,5) end
        end
    end)

    local warnBtn = createActionBtn("⚠️ Issue Official Warning", THEME.Warning, 95, function(p)
        -- Simulate sending warning to user's screen
        print("Warning sent to " .. p.Name)
    end)

    if role == "owner" then
        local banBtn = createActionBtn("🚫 Ban User (Account + HWID)", THEME.Danger, 145, function(p)
            local data = readJSON(BAN_FILE) or {users = {}, devices = {}}
            table.insert(data.users, {id = tostring(p.UserId), reason = "Banned by Owner", time = os.time()})
            -- In a real scenario, we'd get their HWID, but we simulate it here
            table.insert(data.devices, {id = tostring(p.UserId) .. "_HW", reason = "Banned by Owner", time = os.time()})
            writeJSON(BAN_FILE, data)
            p:Kick("You have been banned from the Power Tycoon Hub.")
        end)
        
        local shutdownBtn = createActionBtn("🔧 Shutdown Hub (Maintenance)", Color3.fromRGB(150, 80, 20), 195, function()
            writeJSON(MAINT_FILE, {active = true, time = os.time()})
            print("Hub shutdown initiated.")
        end)
    end

    local function refreshList()
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        for _, p in ipairs(Players:GetPlayers()) do
            local card = Instance.new("Frame"); card.Size = UDim2.new(1,-10,0,55); card.BackgroundColor3 = THEME.Base; card.BorderSizePixel = 0; card.Parent = scroll; card.LayoutOrder = #scroll:GetChildren()
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", card).Color = THEME.Border
            
            local av = Instance.new("ImageLabel"); av.Size = UDim2.new(0,40,0,40); av.Position = UDim2.new(0,8,0.5,-20); av.BackgroundColor3 = THEME.Element; av.Parent = card
            Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
            pcall(function() av.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            
            local name = Instance.new("TextLabel"); name.Size = UDim2.new(1,-60,0,20); name.Position = UDim2.new(0,55,0,8); name.BackgroundTransparency = 1; name.Text = p.DisplayName; name.TextColor3 = THEME.Text; name.Font = Enum.Font.GothamBold; name.TextSize = 13; name.TextXAlignment = Enum.TextXAlignment.Left; name.Parent = card
            local user = Instance.new("TextLabel"); user.Size = UDim2.new(1,-60,0,15); user.Position = UDim2.new(0,55,0,28); user.BackgroundTransparency = 1; user.Text = "@" .. p.Name; user.TextColor3 = THEME.SubText; user.Font = Enum.Font.Gotham; user.TextSize = 11; user.TextXAlignment = Enum.TextXAlignment.Left; user.Parent = card
            
            card.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    selectedPlayer = p
                    for _, c2 in ipairs(scroll:GetChildren()) do if c2:IsA("Frame") then c2.BackgroundColor3 = THEME.Base end end
                    card.BackgroundColor3 = THEME.AccentDark
                end
            end)
        end
    end
    
    refreshList()
    task.spawn(function() while gui.Parent do task.wait(3); refreshList() end end)
end

-- ============================================
-- GAME LOGIC (100% INTACT & RESTORED)
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
local grabLoopConn, toolLoopConn, auraConn = nil, nil, nil
local AutoClaimMoney = false
local AutoBuild = false
local claimConn, buildConn = nil, nil
local cachedTycoonType = nil

local function findDamageRemotes()
    local remotes = {}
    for _, container in ipairs({ReplicatedStorage, workspace}) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:match("damage") or n:match("hit") or n:match("attack") or n:match("deal") then table.insert(remotes, obj) end
            end
        end
    end
    return remotes
end
local dmgRemotes = findDamageRemotes()
if #dmgRemotes > 0 then DAMAGE_REMOTE = dmgRemotes[1] end

local function getPlayerTycoonType()
    if cachedTycoonType and workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(cachedTycoonType) then return cachedTycoonType end
    local plot = workspace:FindFirstChild(player.Name)
    if plot then
        for _, child in ipairs(plot:GetChildren()) do
            if child:IsA("StringValue") and (child.Name:lower():find("tycoon") or child.Name:lower():find("type")) then cachedTycoonType = child.Value; return cachedTycoonType end
        end
    end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local closestTycoon, minDist = nil, math.huge
        local tycoonsFolder = workspace:FindFirstChild("Tycoons")
        if tycoonsFolder then
            for _, tycoonFolder in ipairs(tycoonsFolder:GetChildren()) do
                if tycoonFolder:IsA("Folder") then
                    local door = tycoonFolder:FindFirstChild("Door", true)
                    if door then
                        local doorPart = door:FindFirstChildWhichIsA("BasePart")
                        if doorPart then
                            local dist = (doorPart.Position - root.Position).Magnitude
                            if dist < minDist then minDist = dist; closestTycoon = tycoonFolder.Name end
                        end
                    end
                end
            end
        end
        cachedTycoonType = closestTycoon; return closestTycoon
    end
    return nil
end
player.CharacterAdded:Connect(function() cachedTycoonType = nil end)

local function getTouchableParts(model)
    local parts = {}
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then table.insert(parts, desc.Parent) end
    end
    if #parts == 0 then for _, desc in ipairs(model:GetDescendants()) do if desc:IsA("BasePart") then table.insert(parts, desc); break end end end
    return parts
end

local function getPlayerCash()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local cash = ls:FindFirstChild("Cash") or ls:FindFirstChild("Money") or ls:FindFirstChild("Coins")
        if cash and (cash:IsA("IntValue") or cash:IsA("NumberValue")) then return cash.Value end
        for _, stat in ipairs(ls:GetChildren()) do if stat:IsA("IntValue") or stat:IsA("NumberValue") then return stat.Value end end
    end
    return 0
end

local function getCost(obj)
    local priceVal = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if priceVal and (priceVal:IsA("IntValue") or priceVal:IsA("NumberValue")) then return priceVal.Value end
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
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent and d.Parent.Parent.Name:find("GearGiver1") then registerPad(d.Parent) end
    end
    Tycoons.DescendantAdded:Connect(function(d)
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent and d.Parent.Parent.Name:find("GearGiver1") then registerPad(d.Parent) end
    end)
end

function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.PreSimulation:Connect(function()
        if not Aura.Enabled and not InstantKill then return end
        local myChar = player.Character; if not myChar then return end
        for _, tool in ipairs(myChar:GetChildren()) do
            if tool:IsA("Tool") then
                local damagePart
                for _, obj in ipairs(tool:GetDescendants()) do if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then damagePart = obj.Parent; break end end
                if not damagePart then damagePart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart") end
                if not damagePart then continue end
                local origCF = damagePart.CFrame
                for _, targetPlr in ipairs(Aura.TargetList) do
                    local tChar = targetPlr.Character
                    if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                        local root = tChar:FindFirstChild("HumanoidRootPart")
                        if root then
                            pcall(function() damagePart.CFrame = root.CFrame * CFrame.new(0,2,0); damagePart:SetNetworkOwner(player) end)
                            if DAMAGE_REMOTE then pcall(function() DAMAGE_REMOTE:FireServer(tChar, damagePart) end)
                            else for _, p in ipairs(tChar:GetChildren()) do if p:IsA("BasePart") then pcall(firetouchinterest, damagePart, p, 0); pcall(firetouchinterest, damagePart, p, 1) end end end
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
                    if hum and hum.Health > 0 then pcall(function() hum:TakeDamage(9e9) end); pcall(function() hum.Health = 0 end) end
                end
            end
        end
    end)
end
function stopAuraLoop() if auraConn then auraConn:Disconnect(); auraConn = nil end end

local function getToolPart(tool)
    if tool:FindFirstChild("Handle") and tool.Handle:IsA("BasePart") then return tool.Handle end
    if tool.PrimaryPart and tool.PrimaryPart:IsA("BasePart") then return tool.PrimaryPart end
    for _, v in ipairs(tool:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end
local cachedToolParts, cachedTorso = {}, {}
local function updateToolCache()
    table.clear(cachedToolParts)
    local char = player.Character; if not char then return end
    for _, tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") then local part = getToolPart(tool); if part then table.insert(cachedToolParts, part) end end end
end
local function getCachedTorso(char)
    if cachedTorso[char] and cachedTorso[char].Parent then return cachedTorso[char] end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"); cachedTorso[char] = torso; return torso
end
function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
    ToolFollow.Connection = RunService.Heartbeat:Connect(function()
        if not ToolFollow.Enabled or #ToolFollow.Targets == 0 then return end
        local myChar = player.Character; if not myChar then return end
        updateToolCache()
        for _, targetPlr in ipairs(ToolFollow.Targets) do
            local tChar = targetPlr.Character
            if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                local torso = getCachedTorso(tChar)
                if torso then
                    for _, part in ipairs(cachedToolParts) do
                        if part and part.Parent then
                            part.Position = torso.Position + Vector3.new(0, 0.6, 0.5); part.CanCollide = false; part.Massless = true
                            pcall(firetouchinterest, part, torso, 0); pcall(firetouchinterest, part, torso, 1)
                        end
                    end
                end
            end
        end
    end)
end
function stopToolFollow() if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart"); updateToolCache()
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then task.wait(); updateToolCache(); local part = getToolPart(child); if part then part.CanCollide = false; part.Massless = true end end
    end)
    for _, tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") then local part = getToolPart(tool); if part then part.CanCollide = false; part.Massless = true end end end
end)
updateToolCache()
if player.Character then for _, tool in ipairs(player.Character:GetChildren()) do if tool:IsA("Tool") then local part = getToolPart(tool); if part then part.CanCollide = false; part.Massless = true end end end end

function startClaimMoney()
    if claimConn then claimConn:Disconnect() end
    claimConn = RunService.PreSimulation:Connect(function()
        if not AutoClaimMoney then return end
        local myChar = player.Character; if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart"); if not root then return end
        local tycoonType = getPlayerTycoonType(); if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType); if not tycoonFolder then return end
        local cashRegister = tycoonFolder:FindFirstChild("CashRegister", true)
        if cashRegister then for _, part in ipairs(getTouchableParts(cashRegister)) do pcall(firetouchinterest, root, part, 0); pcall(firetouchinterest, root, part, 1) end end
    end)
end
function stopClaimMoney() if claimConn then claimConn:Disconnect(); claimConn = nil end end

function startAutoBuild()
    if buildConn then buildConn:Disconnect() end
    local lastBuyTime = 0
    buildConn = RunService.PreSimulation:Connect(function()
        if not AutoBuild then return end
        if tick() - lastBuyTime < 0.5 then return end
        local myChar = player.Character; if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart"); if not root then return end
        local tycoonType = getPlayerTycoonType(); if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType); if not tycoonFolder then return end
        local cash = getPlayerCash()
        local buttons = {}
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("button") or obj.Name:lower():find("btn")) then
                local cost = getCost(obj)
                if cost > 0 then table.insert(buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)}) end
            end
        end
        table.sort(buttons, function(a, b) if a.Priority == b.Priority then return a.Cost < b.Cost end; return a.Priority < b.Priority end)
        for _, btnData in ipairs(buttons) do
            if cash >= btnData.Cost then
                for _, part in ipairs(getTouchableParts(btnData.Model)) do pcall(firetouchinterest, root, part, 0); pcall(firetouchinterest, root, part, 1) end
                lastBuyTime = tick(); break
            end
        end
    end)
end
function stopAutoBuild() if buildConn then buildConn:Disconnect(); buildConn = nil end end

-- ============================================
-- MAIN HUB INITIALIZATION
-- ============================================
local function initializeHub()
    local maint = readJSON(MAINT_FILE)
    if maint and maint.active then
        if os.time() - (maint.time or 0) > 3600 then maint.active = false; writeJSON(MAINT_FILE, maint)
        else createMaintScreen(); return end
    end
    
    local banned, reason = checkBan()
    if banned then createBanScreen(reason); return end

    local Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()
    
    -- NATIVE ZYRONX WHITELIST FOR HUB MANAGE TAB
    Library.WhitelistedUsers = {"exo_blox", "city800"}

    local Window = Library:CreateWindow({
        Title = "Power Tycoon Hub", Subtitle = "Architectural Edition", SubtitleColor = THEME.Accent,
        Logo = "rbxassetid://82367817676382", LogoSize = 32, SphereText = true, SphereWords = "EXO", SphereImage = "rbxassetid://82367817676382", SphereIconSize = 38
    })

    -- SPT TAB
    local SPT_Tab = Window:CreateTab("Super Power Tycoon", true, false)
    local SPT_Combat = SPT_Tab:CreatePage("Combat")
    local AuraSec = SPT_Combat:CreateSection("Multi-Target Aura")
    AuraSec:AddToggle("Enable Aura", false, function(state) Aura.Enabled = state; if state then startAuraLoop() else stopAuraLoop() end end, {Title="Enable Aura", Description="Starts multi-target aura."})
    AuraSec:AddToggle("Instant Kill", false, function(state) InstantKill = state end, {Title="Instant Kill", Description="Brute-force kills targets."})
    
    local ToolSec = SPT_Combat:CreateSection("Tool Follow")
    ToolSec:AddToggle("Enable Tool Follow", false, function(state) ToolFollow.Enabled = state; if state then startToolFollow() else stopToolFollow() end end, {Title="Enable Tool Follow", Description="Forces tools to follow targets."})

    local SPT_Tycoon = SPT_Tab:CreatePage("Tycoon")
    local TycoonSec = SPT_Tycoon:CreateSection("Tycoon Automation")
    TycoonSec:AddToggle("Auto Claim Money", false, function(state) AutoClaimMoney = state; if state then startClaimMoney() else stopClaimMoney() end end, {Title="Auto Claim Money", Description="Collects cash automatically."})
    TycoonSec:AddToggle("Smart Auto Build", false, function(state) AutoBuild = state; if state then startAutoBuild() else stopAutoBuild() end end, {Title="Smart Auto Build", Description="Buys upgrades in priority order."})
    
    local AutoToolsSec = SPT_Tycoon:CreateSection("Auto Get Tools")
    AutoToolsSec:AddToggle("Auto Grab Weapons", false, function(state)
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
                    for _, pad in ipairs(pads) do local d = (pad.Position - root.Position).Magnitude; if d < minDist then minDist = d; closest = pad end end
                    if closest then for i = 1, 8 do pcall(firetouchinterest, root, closest, 0); pcall(firetouchinterest, root, closest, 1) end end
                end
            end)
        else if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end end
    end, {Title="Auto Grab Weapons", Description="Grabs weapons from tycoon pads."})

    local CD_Sec = SPT_Tycoon:CreateSection("Tools & Cooldown")
    CD_Sec:AddToggle("Auto Use Tools", false, function(state)
        AutoTools = state
        if state then
            toolLoopConn = RunService.RenderStepped:Connect(function()
                if not AutoTools then return end
                local myChar = player.Character; if not myChar or not myChar:FindFirstChild("Humanoid") or myChar.Humanoid.Health <= 0 then return end
                for _, t in ipairs(myChar:GetChildren()) do if t:IsA("Tool") then pcall(function() t:Activate() end) end end
                for _, t in ipairs(player.Backpack:GetChildren()) do if t:IsA("Tool") then t.Parent = myChar; pcall(function() t:Activate() end) end end
            end)
        else if toolLoopConn then toolLoopConn:Disconnect(); toolLoopConn = nil end end
    end, {Title="Auto Use Tools", Description="Continuously activates all tools."})
    
    CD_Sec:AddToggle("No Cooldown", false, function(state)
        NoCooldown = state
        if state then
            if not getgenv().NoCooldownHooked then
                hookfunction(wait, function() return RunService.PostSimulation:Wait() end)
                hookfunction(task.wait, function() return RunService.PostSimulation:Wait() end)
                getgenv().NoCooldownHooked = true
            end
        end
    end, {Title="No Cooldown", Description="Removes tool cooldowns."})

    local SPT_Misc = SPT_Tab:CreatePage("Movement & Visuals")
    local ReachSec = SPT_Misc:CreateSection("Reach")
    ReachSec:AddToggle("Reach (hitbox + outline)", false, function(state)
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
    end, {Title="Reach", Description="Expands tool hitboxes."})

    -- MPT TAB
    local MPT_Tab = Window:CreateTab("Mega Power Tycoon", false, false)
    local MPT_Page = MPT_Tab:CreatePage("All Features")
    local MPT_Sec = MPT_Page:CreateSection("Combat & Tools")
    MPT_Sec:AddToggle("Kill Aura", false, function(state) Aura.Enabled = state; if state then startAuraLoop() else stopAuraLoop() end end, {Title="Kill Aura", Description="Hits targets around you."})
    MPT_Sec:AddToggle("Fast Kill", false, function(state) InstantKill = state end, {Title="Fast Kill", Description="Instantly kills targets."})
    MPT_Sec:AddButton("Get Base", function()
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

    -- HUB MANAGE TAB (NATIVE ZYRONX PREMIUM TAB)
    local ManageTab = Window:CreateTab("Hub Manage", false, true) -- true makes it whitelisted natively
    local ManagePage = ManageTab:CreatePage("Console")
    local AuthSec = ManagePage:CreateSection("Authentication")
    
    AuthSec:AddButton("Open Management Console", function()
        -- Custom Login Prompt
        local loginGui = Instance.new("ScreenGui"); loginGui.Name = "Login"; loginGui.ResetOnSpawn = false; loginGui.Parent = CoreGui
        local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(0,0,0); bg.BackgroundTransparency = 0.5; bg.Parent = loginGui
        local card = Instance.new("Frame"); card.Size = UDim2.new(0,400,0,300); card.Position = UDim2.new(0.5,-200,0.5,-150); card.BackgroundColor3 = THEME.Base; card.Parent = loginGui
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", card).Color = THEME.Accent
        
        local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,0,0,40); t.Position = UDim2.new(0,0,0,20); t.BackgroundTransparency = 1; t.Text = "Role Authentication"; t.TextColor3 = THEME.Accent; t.Font = Enum.Font.GothamBlack; t.TextSize = 18; t.Parent = card
        
        local uIn = Instance.new("TextBox"); uIn.Size = UDim2.new(1,-40,0,35); uIn.Position = UDim2.new(0,20,0,80); uIn.BackgroundColor3 = THEME.Element; uIn.PlaceholderText = "Username"; uIn.TextColor3 = THEME.Text; uIn.Font = Enum.Font.Gotham; uIn.TextSize = 14; uIn.Parent = card
        Instance.new("UICorner", uIn).CornerRadius = UDim.new(0, 6)
        
        local pIn = Instance.new("TextBox"); pIn.Size = UDim2.new(1,-40,0,35); pIn.Position = UDim2.new(0,20,0,125); pIn.BackgroundColor3 = THEME.Element; pIn.PlaceholderText = "Password"; pIn.TextColor3 = THEME.Text; pIn.Font = Enum.Font.Gotham; pIn.TextSize = 14; pIn.Parent = card
        Instance.new("UICorner", pIn).CornerRadius = UDim.new(0, 6)
        
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,-40,0,40); btn.Position = UDim2.new(0,20,0,180); btn.BackgroundColor3 = THEME.Accent; btn.Text = "LOGIN"; btn.TextColor3 = THEME.Base; btn.Font = Enum.Font.GothamBlack; btn.TextSize = 14; btn.Parent = card
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local st = Instance.new("TextLabel"); st.Size = UDim2.new(1,-40,0,20); st.Position = UDim2.new(0,20,0,230); st.BackgroundTransparency = 1; st.Text = ""; st.TextColor3 = THEME.Danger; st.Font = Enum.Font.GothamBold; st.TextSize = 12; st.Parent = card
        
        btn.MouseButton1Click:Connect(function()
            local u, p = uIn.Text, pIn.Text
            if u == OWNER_CREDS.username and p == OWNER_CREDS.password then
                loginGui:Destroy(); createManagementConsole("owner")
            elseif u == OPERATOR_CREDS.username and p == OPERATOR_CREDS.password then
                loginGui:Destroy(); createManagementConsole("operator")
            else
                st.Text = "Invalid Credentials."
            end
        end)
    end, {Title="Launch Console", Description="Opens the administrative overlay."})

    Library:Notify({Title = "Power Tycoon Hub", Description = "Architectural Integration Complete.", Duration = 4})
end

-- ============================================
-- BOOTSTRAP
-- ============================================
local keyData = readJSON(KEY_FILE)
if keyData and keyData.key == HUB_KEY and os.time() - (keyData.time or 0) < 86400 then
    initializeHub()
else
    createKeySystem(initializeHub)
end
