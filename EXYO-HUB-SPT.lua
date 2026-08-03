-- ═══════════════════════════════════════════════════════════════
--  EXO HUB v3.0 – Power Tycoon | Cerberus UI | Full Rewrite
--  All bugs fixed | MPT redesigned | Settings complete | Key system works
-- ═══════════════════════════════════════════════════════════════

-- ── 1. LOAD CERBERUS LIBRARY ────────────────────────────────
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/cerberus.lua"))()

-- ── 2. SERVICES ─────────────────────────────────────────────
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local StarterGui        = game:GetService("StarterGui")
local player            = Players.LocalPlayer

-- ── 3. CONFIGURATION ────────────────────────────────────────
local HUB_KEY  = "EXOSTAKEOVERR19$"
local KEY_FILE = "exo_key_v3.dat"
local CONFIG_FILE = "exo_config_v3.dat"

-- ── 4. FILE I/O ─────────────────────────────────────────────
local function readFile(path)
    if isfile and readfile and isfile(path) then
        local ok, r = pcall(readfile, path)
        if ok then return r end
    end
    return nil
end
local function writeFile(path, data)
    if writefile then pcall(writefile, path, data) end
end
local function readJSON(path)
    local raw = readFile(path)
    if raw then
        local ok, d = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok then return d end
    end
    return nil
end
local function writeJSON(path, data)
    local ok, e = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then writeFile(path, e) end
end

-- ── 5. CUSTOM NOTIFICATION SYSTEM ──────────────────────────
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "EXO_Notifications"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.Parent = CoreGui

local function notify(title, description, duration, notifType)
    duration = duration or 3
    notifType = notifType or "Info"

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 80)
    frame.Position = UDim2.new(1, 10, 1, -90)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.BorderSizePixel = 0
    frame.Parent = notifGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = notifType == "Error" and Color3.fromRGB(220,50,50)
        or notifType == "Success" and Color3.fromRGB(50,200,100)
        or notifType == "Warning" and Color3.fromRGB(230,180,40)
        or Color3.fromRGB(190,140,255)
    accent.BorderSizePixel = 0
    accent.Parent = frame
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -16, 0, 24)
    titleLabel.Position = UDim2.new(0, 12, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -16, 0, 40)
    descLabel.Position = UDim2.new(0, 12, 0, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -350, 1, -90)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, 1, -90)
        }):Play()
        task.delay(0.35, function()
            if frame and frame.Parent then frame:Destroy() end
        end)
    end)
end

-- ── 6. KEY SYSTEM ───────────────────────────────────────────
local function createKeySystem(onSuccess)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ExoKeySystem"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.4
    overlay.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0,480,0,340)
    card.Position = UDim2.new(0.5,-240,0.5,-170)
    card.BackgroundColor3 = Color3.fromRGB(15,15,18)
    card.BorderSizePixel = 0
    card.Parent = gui
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke",card)
    stroke.Color = Color3.fromRGB(35,35,42)
    stroke.Thickness = 1.5

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1,0,0,45)
    topbar.BackgroundColor3 = Color3.fromRGB(22,22,26)
    topbar.BorderSizePixel = 0
    topbar.Parent = card
    Instance.new("UICorner",topbar).CornerRadius = UDim.new(0,12)
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1,0,0,15)
    fix.Position = UDim2.new(0,0,1,-15)
    fix.BackgroundColor3 = Color3.fromRGB(22,22,26)
    fix.BorderSizePixel = 0
    fix.Parent = topbar

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1,-20,1,0)
    logo.Position = UDim2.new(0,20,0,0)
    logo.BackgroundTransparency = 1
    logo.Text = "EXO  |  Key Authentication"
    logo.TextColor3 = Color3.fromRGB(240,240,245)
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 14
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = topbar

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1,0,0,2)
    accentLine.Position = UDim2.new(0,0,1,0)
    accentLine.BackgroundColor3 = Color3.fromRGB(190,140,255)
    accentLine.BorderSizePixel = 0
    accentLine.Parent = topbar

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1,-40,0,40)
    desc.Position = UDim2.new(0,20,0,65)
    desc.BackgroundTransparency = 1
    desc.Text = "Enter your premium key to access the Power Tycoon Hub."
    desc.TextColor3 = Color3.fromRGB(160,160,175)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 13
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = card

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1,-40,0,48)
    inputBg.Position = UDim2.new(0,20,0,125)
    inputBg.BackgroundColor3 = Color3.fromRGB(22,22,26)
    inputBg.BorderSizePixel = 0
    inputBg.Parent = card
    Instance.new("UICorner",inputBg).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke",inputBg).Color = Color3.fromRGB(35,35,42)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1,-20,1,0)
    input.Position = UDim2.new(0,10,0,0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "Paste your premium key here..."
    input.PlaceholderColor3 = Color3.fromRGB(160,160,175)
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(240,240,245)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = inputBg

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-40,0,48)
    btn.Position = UDim2.new(0,20,0,195)
    btn.BackgroundColor3 = Color3.fromRGB(190,140,255)
    btn.Text = "AUTHENTICATE & UNLOCK"
    btn.TextColor3 = Color3.fromRGB(20,20,20)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = card
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,-40,0,20)
    status.Position = UDim2.new(0,20,0,255)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(220,50,50)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 12
    status.Parent = card

    btn.MouseButton1Click:Connect(function()
        if input.Text == HUB_KEY then
            writeJSON(KEY_FILE, {key = HUB_KEY, time = os.time()})
            status.Text = "Authentication Successful. Loading Hub..."
            status.TextColor3 = Color3.fromRGB(50,200,100)
            btn.BackgroundColor3 = Color3.fromRGB(50,200,100)
            task.wait(1.2)
            gui:Destroy()
            if onSuccess then onSuccess() end
        else
            status.Text = "Invalid Key. Please check and try again."
            input.Text = ""
            TweenService:Create(card, TweenInfo.new(0.1), {Position = UDim2.new(0.5,-230,0.5,-170)}):Play()
            task.wait(0.1)
            TweenService:Create(card, TweenInfo.new(0.1), {Position = UDim2.new(0.5,-240,0.5,-170)}):Play()
        end
    end)
    input.FocusLost:Connect(function(enter)
        if enter then btn.MouseButton1Click:Fire() end
    end)
end

-- ── 7. STATE VARIABLES ──────────────────────────────────────
local DAMAGE_REMOTE    = nil
local Aura             = {Enabled = false, TargetList = {}}
local InstantKill      = false
local AutoTools        = false
local NoCooldown       = false
local Reach            = false
local ReachSize        = 2
local FastRespawn      = false
local AntiSpawnkill    = false
local ToolFollow       = {Enabled = false, Targets = {}, Connection = nil}
local AutoGetTools     = false
local AutoClaimMoney   = false
local AutoBuild        = false
local grabLoopConn     = nil
local toolLoopConn     = nil
local auraConn         = nil
local claimConn        = nil
local buildConn        = nil
local cachedTycoonType = nil
local AntiAura         = {Enabled = false, GodMode = false, Repel = false}
local antiAuraConn     = nil
local antiAuraFF       = nil
local ThreatLevel      = 0
local LastThreatCheck  = 0
local ThreatRadius     = 50
local latencyEstimate  = 0.1

local InstaKillEnabled  = false
local InstaKillConn     = nil
local IK_ToolsCache     = {}
local IK_LastActivation = 0
local IK_BurstActive    = false
local IK_TargetParts    = {}

local HitAmpEnabled     = false
local HitAmpConn        = nil
local HA_CachedTools    = {}
local HA_LastActivation = 0
local HA_Accumulator    = 0

local TG_Enabled        = false
local TG_padsByBase     = {}
local TG_registered     = {}

local KillNotifEnabled = false
local KillLogEnabled   = false
local KillLogs         = {}
local ESPEnabled       = false
local AntiLagEnabled   = false
local espDots          = {}
local espGui           = nil

local CurrentTheme = {
    Accent = Color3.fromRGB(190,140,255)
}

-- ── 8. DAMAGE REMOTE DETECTION ──────────────────────────────
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
if #dmgRemotes > 0 then DAMAGE_REMOTE = dmgRemotes[1] end

-- ── 9. TYCOON HELPERS ───────────────────────────────────────
local function getPlayerTycoonType()
    if cachedTycoonType and workspace:FindFirstChild("Tycoons")
        and workspace.Tycoons:FindFirstChild(cachedTycoonType) then
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
            if (n:find("tycoon") or n:find("type") or n:find("base") or n:find("theme"))
                and type(attrVal) == "string" then
                cachedTycoonType = attrVal
                return cachedTycoonType
            end
        end
    end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local closest, minDist = nil, math.huge
        local tf = workspace:FindFirstChild("Tycoons")
        if tf then
            for _, t in ipairs(tf:GetChildren()) do
                if t:IsA("Folder") then
                    local door = t:FindFirstChild("Door", true)
                    if door then
                        local dp = door:FindFirstChildWhichIsA("BasePart")
                        if dp then
                            local d = (dp.Position - root.Position).Magnitude
                            if d < minDist then minDist = d; closest = t.Name end
                        end
                    end
                end
            end
        end
        cachedTycoonType = closest
        return closest
    end
    return nil
end
player.CharacterAdded:Connect(function() cachedTycoonType = nil end)

local function getTouchableParts(model)
    local parts = {}
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            table.insert(parts, desc.Parent)
        end
    end
    if #parts == 0 then
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("BasePart") then table.insert(parts, desc); break end
        end
    end
    return parts
end

local function getPlayerCash()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        for _, name in ipairs({"Cash","Money","Coins","Gold"}) do
            local v = ls:FindFirstChild(name)
            if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then return v.Value end
        end
        for _, stat in ipairs(ls:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then return stat.Value end
        end
    end
    return 0
end

local function getCost(obj)
    local pv = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if pv and (pv:IsA("IntValue") or pv:IsA("NumberValue")) then return pv.Value end
    local attr = obj:GetAttribute("Price") or obj:GetAttribute("Cost")
    if type(attr) == "number" then return attr end
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            local n = child.Name:lower()
            if n:find("price") or n:find("cost") then return child.Value end
        end
    end
    return 0
end

local function getPriority(modelName)
    local name = modelName:lower()
    if name:find("robux") then return 999 end
    local num = tonumber(name:match("%d+")) or 0
    if name:find("gen") and not name:find("gear") then
        if num == 0 then return 10 elseif num == 1 then return 11
        elseif num == 2 then return 30 elseif num == 3 then return 31
        elseif num == 4 then return 50 elseif num == 5 then return 60
        else return 70 + num end
    end
    if name:find("gear") or name:find("gun") then
        if num <= 1 then return 20 elseif num == 2 then return 21
        elseif num == 3 then return 55 elseif num == 4 then return 65
        elseif num == 5 then return 66 else return 67 + num end
    end
    if name:find("wall") or name:find("door") or name:find("ladder") or name:find("upstairs") then
        return 40 + num
    end
    if name:find("ultima") or name:find("effect") then return 80 end
    return 90 + num
end

local function getServerPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then table.insert(list, p.Name) end
    end
    return #list > 0 and list or {"No Players Available"}
end

local function getToolPart(tool)
    if tool:FindFirstChild("Handle") and tool.Handle:IsA("BasePart") then return tool.Handle end
    if tool.PrimaryPart and tool.PrimaryPart:IsA("BasePart") then return tool.PrimaryPart end
    for _, v in ipairs(tool:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end

local function getHRP(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

-- ── 10. THREAT DETECTION ────────────────────────────────────
local function updateThreatLevel()
    if tick() - LastThreatCheck < 0.5 then return end
    LastThreatCheck = tick()
    ThreatLevel = 0
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if (plr.Character.HumanoidRootPart.Position - myPos).Magnitude < ThreatRadius then
                ThreatLevel = ThreatLevel + 1
            end
        end
    end
end

-- ── 11. AURA & KILL ─────────────────────────────────────────
local function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not Aura.Enabled then return end
        local myChar = player.Character
        if not myChar then return end
        for _, tool in ipairs(myChar:GetChildren()) do
            if tool:IsA("Tool") then
                local damagePart
                for _, obj in ipairs(tool:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then
                        damagePart = obj.Parent; break
                    end
                end
                if not damagePart then
                    damagePart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                end
                if not damagePart then continue end
                local origCF = damagePart.CFrame
                for _, targetPlr in ipairs(Aura.TargetList) do
                    local tChar = targetPlr.Character
                    if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                        local root = tChar:FindFirstChild("HumanoidRootPart")
                        if root then
                            local predictedPos = root.Position + root.Velocity * latencyEstimate
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = {myChar, tChar}
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            local rayResult = workspace:Raycast(
                                damagePart.Position,
                                (predictedPos - damagePart.Position).Unit * 50,
                                rayParams
                            )
                            if rayResult and rayResult.Instance and rayResult.Instance.Parent == root.Parent then
                                pcall(function() damagePart.CFrame = CFrame.new(rayResult.Position) end)
                            else
                                pcall(function() damagePart.CFrame = CFrame.new(predictedPos) end)
                            end
                            if DAMAGE_REMOTE then
                                pcall(function() DAMAGE_REMOTE:FireServer(tChar, damagePart) end)
                            else
                                for _, p in ipairs(tChar:GetChildren()) do
                                    if p:IsA("BasePart") then
                                        pcall(firetouchinterest, damagePart, p, 0)
                                        pcall(firetouchinterest, damagePart, p, 1)
                                    end
                                end
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
local function stopAuraLoop()
    if auraConn then auraConn:Disconnect(); auraConn = nil end
end

-- ── 12. TOOL FOLLOW ─────────────────────────────────────────
local cachedToolParts = {}
local cachedTorso = {}
local function updateToolCache()
    table.clear(cachedToolParts)
    local char = player.Character
    if not char then return end
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
local function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect() end
    ToolFollow.Connection = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not ToolFollow.Enabled or #ToolFollow.Targets == 0 then return end
        local myChar = player.Character
        if not myChar then return end
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
                        end
                    end
                end
            end
        end
    end)
end
local function stopToolFollow()
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
end)
updateToolCache()

-- ── 13. AUTO CLAIM & BUILD ──────────────────────────────────
local function startClaimMoney()
    if claimConn then claimConn:Disconnect() end
    claimConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
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
            for _, part in ipairs(getTouchableParts(cashRegister)) do
                pcall(firetouchinterest, root, part, 0)
                pcall(firetouchinterest, root, part, 1)
            end
        end
    end)
end
local function stopClaimMoney()
    if claimConn then claimConn:Disconnect(); claimConn = nil end
end

local lastBuyTime = 0
local lastCashCheck = 0
local cashPerSecond = 0
local previousCash = 0
local function startAutoBuild()
    if buildConn then buildConn:Disconnect() end
    buildConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not AutoBuild then return end
        if tick() - lastBuyTime < 0.5 then return end
        local currentTime = tick()
        if currentTime - lastCashCheck > 1 then
            local currentCash = getPlayerCash()
            cashPerSecond = (currentCash - previousCash) / math.max(currentTime - lastCashCheck, 0.01)
            previousCash = currentCash
            lastCashCheck = currentTime
        end
        local buyDelay = cashPerSecond < 100 and 0.2 or 0.05
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
            if obj:IsA("Model") then
                local ln = obj.Name:lower()
                if ln:find("button") or ln:find("btn") or ln:find("gen") or ln:find("wall")
                    or ln:find("door") or ln:find("ladder") or ln:find("upstairs")
                    or ln:find("gear") or ln:find("ultima") then
                    local cost = getCost(obj)
                    if cost > 0 then
                        table.insert(buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)})
                    end
                end
            end
        end
        table.sort(buttons, function(a, b)
            if a.Priority == b.Priority then return a.Cost < b.Cost end
            return a.Priority < b.Priority
        end)
        if ThreatLevel > 0 then
            for _, btnData in ipairs(buttons) do
                local mn = btnData.Model.Name:lower()
                if (mn:find("wall") or mn:find("door") or mn:find("ladder")) and cash >= btnData.Cost then
                    for _, part in ipairs(getTouchableParts(btnData.Model)) do
                        pcall(firetouchinterest, root, part, 0)
                        pcall(firetouchinterest, root, part, 1)
                    end
                    lastBuyTime = tick()
                    task.wait(buyDelay)
                    break
                end
            end
        else
            for _, btnData in ipairs(buttons) do
                if cash >= btnData.Cost then
                    for _, part in ipairs(getTouchableParts(btnData.Model)) do
                        pcall(firetouchinterest, root, part, 0)
                        pcall(firetouchinterest, root, part, 1)
                    end
                    lastBuyTime = tick()
                    task.wait(buyDelay)
                    break
                end
            end
        end
    end)
end
local function stopAutoBuild()
    if buildConn then buildConn:Disconnect(); buildConn = nil end
end

-- ── 14. ANTI-AURA (SAFE) ───────────────────────────────────
local function startAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect() end
    antiAuraConn = RunService.Heartbeat:Connect(function()
        updateThreatLevel()
        if not AntiAura.Enabled then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        local hum = myChar:FindFirstChild("Humanoid")
        if not root or not hum then return end
        if AntiAura.GodMode then
            if not antiAuraFF or not antiAuraFF.Parent then
                antiAuraFF = Instance.new("ForceField")
                antiAuraFF.Visible = false
                antiAuraFF.Parent = myChar
            end
            if hum.Health < hum.MaxHealth * 0.5 then
                hum.Health = hum.MaxHealth
            end
        else
            if antiAuraFF and antiAuraFF.Parent then
                antiAuraFF:Destroy()
                antiAuraFF = nil
            end
        end
        if AntiAura.Repel then
            for _, otherPlr in ipairs(Players:GetPlayers()) do
                if otherPlr ~= player and otherPlr.Character then
                    for _, tool in ipairs(otherPlr.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                            if handle then
                                local dist = (handle.Position - root.Position).Magnitude
                                if dist < 10 then
                                    local dir = (root.Position - handle.Position).Unit
                                    pcall(function()
                                        handle.AssemblyLinearVelocity = dir * 60
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
local function stopAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect(); antiAuraConn = nil end
    if antiAuraFF and antiAuraFF.Parent then antiAuraFF:Destroy(); antiAuraFF = nil end
end

-- ── 15. REACH (FIXED) ──────────────────────────────────────
local reachOriginalSizes = {}
local reachHL = {}
local function applyReach()
    local myChar = player.Character
    if not myChar then return end
    for _, t in ipairs(myChar:GetChildren()) do
        if t:IsA("Tool") then
            local part = nil
            for _, obj in ipairs(t:GetDescendants()) do
                if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then
                    part = obj.Parent; break
                end
            end
            if not part then part = t:FindFirstChildWhichIsA("BasePart") end
            if part then
                if not reachOriginalSizes[part] then
                    reachOriginalSizes[part] = part.Size
                end
                part.Size = reachOriginalSizes[part] * ReachSize
                part.Massless = true
                if not reachHL[part] then
                    local hl = Instance.new("Highlight", part)
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(0,150,255)
                    hl.OutlineTransparency = 0
                    reachHL[part] = hl
                end
            end
        end
    end
end
local function startReach() applyReach() end
local function stopReach()
    for part, hl in pairs(reachHL) do
        if hl and hl.Parent == part then hl:Destroy() end
    end
    table.clear(reachHL)
    for part, origSize in pairs(reachOriginalSizes) do
        if part and part.Parent then part.Size = origSize end
    end
    table.clear(reachOriginalSizes)
end

-- ── 16. FAST RESPAWN ────────────────────────────────────────
local function startFastRespawn()
    local Guide = ReplicatedStorage:FindFirstChild("Guide")
    local last = 0
    local function respawn()
        if tick() - last < 0.05 then return end
        last = tick()
        pcall(function()
            if Guide then Guide:FireServer()
            else player:LoadCharacter() end
        end)
    end
    local function hook(c)
        local hum = c:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function(hp) if hp <= 0 then respawn() end end)
        hum.Died:Connect(respawn)
    end
    if player.Character then hook(player.Character) end
    player.CharacterAdded:Connect(hook)
end

-- ── 17. MPT: INSTA-KILL MICRO-BURST ────────────────────────
local function IK_RefreshTools()
    table.clear(IK_ToolsCache)
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local fightEvent = tool:FindFirstChild("FightEvent", true)
            local touchPart = tool:FindFirstChildWhichIsA("TouchTransmitter", true)
            if fightEvent and fightEvent:IsA("RemoteEvent") then
                table.insert(IK_ToolsCache, {Tool = tool, FightEvent = fightEvent, TouchPart = touchPart and touchPart.Parent or nil})
            elseif touchPart then
                table.insert(IK_ToolsCache, {Tool = tool, FightEvent = nil, TouchPart = touchPart.Parent})
            end
        end
    end
end

local function IK_GetTarget()
    local myChar = player.Character
    local myRoot = myChar and getHRP(myChar)
    if not myRoot then return nil end
    local bestChar, bestDist = nil, 28
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char then
                local root = getHRP(char)
                if root then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        if dist < bestDist then bestDist = dist; bestChar = char end
                    end
                end
            end
        end
    end
    return bestChar
end

local function IK_MicroBurst(targetChar, burstCount)
    if not targetChar or not player.Character then return end
    table.clear(IK_TargetParts)
    for _, name in ipairs({"HumanoidRootPart","UpperTorso","Torso","Head"}) do
        local part = targetChar:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            table.insert(IK_TargetParts, part)
        end
    end
    if #IK_TargetParts == 0 then return end
    for _, toolData in ipairs(IK_ToolsCache) do
        local tool = toolData.Tool
        local fight = toolData.FightEvent
        local touch = toolData.TouchPart
        if tool and tool.Parent then
            if fight then
                pcall(function()
                    for _ = 1, burstCount do fight:FireServer() end
                end)
            else
                pcall(tool.Activate, tool)
            end
            if touch then
                for _, part in ipairs(IK_TargetParts) do
                    if part and part.Parent then
                        pcall(firetouchinterest, touch, part, 0)
                        pcall(firetouchinterest, touch, part, 1)
                    end
                end
            end
        end
    end
end

local function startInstaKill()
    if InstaKillConn then InstaKillConn:Disconnect() end
    IK_RefreshTools()
    InstaKillConn = RunService.PreSimulation:Connect(function()
        if not InstaKillEnabled then return end
        local now = os.clock()
        if now - IK_LastActivation < 1/60 then return end
        IK_LastActivation = now
        IK_RefreshTools()
        if #IK_ToolsCache == 0 then return end
        local target = IK_GetTarget()
        if target then
            IK_MicroBurst(target, 5)
        end
    end)
end
local function stopInstaKill()
    if InstaKillConn then InstaKillConn:Disconnect(); InstaKillConn = nil end
end

-- ── 18. MPT: HIT AMPLIFIER ─────────────────────────────────
local HA_OverlapParams = OverlapParams.new()
HA_OverlapParams.FilterType = Enum.RaycastFilterType.Exclude

local function HA_RefreshTools()
    table.clear(HA_CachedTools)
    local char = player.Character
    if not char then return end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local fight = t:FindFirstChild("FightEvent", true)
            if fight and fight:IsA("RemoteEvent") then
                table.insert(HA_CachedTools, {Tool = t, FightEvent = fight})
            else
                local touch = t:FindFirstChildWhichIsA("TouchTransmitter", true)
                if touch then
                    table.insert(HA_CachedTools, {Tool = t})
                end
            end
        end
    end
end

local function HA_PulseTools()
    for _, data in ipairs(HA_CachedTools) do
        local tool = data.Tool
        local fight = data.FightEvent
        if tool and tool.Parent then
            if fight then
                pcall(function()
                    for _ = 1, 3 do fight:FireServer() end
                end)
            else
                pcall(tool.Activate, tool)
            end
        end
    end
end

local function startHitAmplifier()
    if HitAmpConn then HitAmpConn:Disconnect() end
    HA_RefreshTools()
    HitAmpConn = RunService.PreSimulation:Connect(function(dt)
        if not HitAmpEnabled then return end
        HA_Accumulator = HA_Accumulator + dt
        if HA_Accumulator < 1/120 then return end
        HA_Accumulator = 0
        local char = player.Character
        if not char then return end
        local hrp = getHRP(char)
        if not hrp then return end
        local now = os.clock()
        if now - HA_LastActivation < 0.015 then return end
        HA_OverlapParams.FilterDescendantsInstances = {char}
        local parts = workspace:GetPartBoundsInBox(CFrame.new(hrp.Position), Vector3.new(24,24,24), HA_OverlapParams)
        local hasTarget = false
        for _, part in ipairs(parts) do
            local model = part:FindFirstChildOfClass("Model") or (part.Parent and part.Parent:FindFirstChildOfClass("Model"))
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and model ~= char then
                    hasTarget = true
                    break
                end
            end
        end
        if not hasTarget then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then
                    local targetChar = plr.Character
                    if targetChar then
                        local targetHRP = getHRP(targetChar)
                        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                        if targetHRP and targetHum and targetHum.Health > 0 then
                            if (hrp.Position - targetHRP.Position).Magnitude <= 20 then
                                hasTarget = true
                                break
                            end
                        end
                    end
                end
            end
        end
        if hasTarget then
            HA_LastActivation = now
            HA_PulseTools()
        end
    end)
end
local function stopHitAmplifier()
    if HitAmpConn then HitAmpConn:Disconnect(); HitAmpConn = nil end
end

-- ── 19. MPT: TOOL GRABBER WAVE SYSTEM ──────────────────────
local TG_TOOL_RULES = {
    {Pattern = "Energy Sword", Base = "Stone"},
    {Pattern = "Staff",        Base = "Magic"},
    {Pattern = "Axe",          Base = "Storm"},
    {Pattern = "Fist",         Base = "Robotic"},
}
local TG_ALLOWED_BASES  = {Stone=true, Magic=true, Storm=true, Robotic=true}
local TG_EXCLUDED_BASES = {Insanity=true, Giant=true, Dark=true, Spike=true, Web=true, Strong=true}

local function TG_RegisterPad(pad)
    if not pad or not pad:IsA("BasePart") then return end
    if not pad:FindFirstChildOfClass("TouchTransmitter") then return end
    local giver = pad.Parent
    while giver and giver ~= workspace do
        if giver.Name == "GearGiver1" then break end
        giver = giver.Parent
    end
    if not giver or giver.Name ~= "GearGiver1" then return end
    local base = giver.Parent
    if not base or TG_EXCLUDED_BASES[base.Name] or not TG_ALLOWED_BASES[base.Name] then return end
    if TG_registered[pad] == base.Name then return end
    TG_registered[pad] = base.Name
    TG_padsByBase[base.Name] = TG_padsByBase[base.Name] or {}
    table.insert(TG_padsByBase[base.Name], pad)
end

local function TG_ScanTycoons()
    local Tycoons = workspace:FindFirstChild("Tycoons")
    if not Tycoons then return end
    for _, obj in ipairs(Tycoons:GetDescendants()) do
        if obj:IsA("BasePart") then TG_RegisterPad(obj) end
    end
end

local function TG_HasTool(pattern)
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find(pattern:lower(), 1, true) then return true end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find(pattern:lower(), 1, true) then return true end
        end
    end
    return false
end

local function TG_GetClosestPad(baseName)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pads = TG_padsByBase[baseName]
    if not pads or #pads == 0 then return nil end
    local closest, bestDist = nil, 10000
    for _, pad in ipairs(pads) do
        if pad and pad.Parent then
            local d = (pad.Position - root.Position).Magnitude
            if d < bestDist then bestDist = d; closest = pad end
        end
    end
    return closest
end

local function TG_BuildWave()
    local wave = {}
    local seenPads = {}
    for _, rule in ipairs(TG_TOOL_RULES) do
        if not TG_HasTool(rule.Pattern) then
            local pad = TG_GetClosestPad(rule.Base)
            if pad and not seenPads[pad] then
                seenPads[pad] = true
                table.insert(wave, {Pad = pad, Base = rule.Base})
            end
        end
    end
    return wave
end

local function TG_AcquirePass(root, wave, burstCount)
    if not root or not root.Parent then return end
    for _, entry in ipairs(wave) do
        if entry.Pad and entry.Pad.Parent then
            pcall(function()
                for _ = 1, burstCount do
                    firetouchinterest(root, entry.Pad, 0)
                    firetouchinterest(root, entry.Pad, 1)
                end
            end)
        end
    end
end

-- ── 20. KILL NOTIFICATION SYSTEM ───────────────────────────
local function analyzeKill(killer, weaponName, distance)
    local suspectedFeatures = {}
    local counterAdvice = {}
    local threatLevel = 1

    if distance > 30 then
        table.insert(suspectedFeatures, "Reach/Aura (long range kill)")
        table.insert(counterAdvice, "Enable Anti-Aura + Repel")
        threatLevel = threatLevel + 3
    end
    if distance < 5 then
        table.insert(suspectedFeatures, "Close-range combat / Tool Follow")
        table.insert(counterAdvice, "Enable Tool Follow or Repel")
        threatLevel = threatLevel + 1
    end
    if weaponName == "None" or weaponName == "" then
        table.insert(suspectedFeatures, "Remote spam (FightEvent / No tool)")
        table.insert(counterAdvice, "Enable God Mode (ForceField)")
        threatLevel = threatLevel + 3
    end
    if distance > 15 and distance <= 30 then
        table.insert(suspectedFeatures, "Possible Hit Amplifier / Overlap scanning")
        table.insert(counterAdvice, "Enable Anti-Aura + Fast Respawn")
        threatLevel = threatLevel + 2
    end

    threatLevel = math.clamp(threatLevel, 1, 10)

    if threatLevel >= 10 then
        table.insert(counterAdvice, "CRITICAL: Enable Anti-Spawnkill Shield NOW")
    end
    if threatLevel >= 7 then
        table.insert(counterAdvice, "Consider enabling full Defense Matrix")
    end

    return {
        Killer = killer,
        Weapon = weaponName,
        Distance = math.floor(distance),
        Suspected = suspectedFeatures,
        Counter = counterAdvice,
        Threat = threatLevel,
        Time = os.date("%H:%M:%S")
    }
end

local function setupKillNotifications()
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            if not KillNotifEnabled then return end
            local creator = hum:FindFirstChild("creator")
            local killerName = "Unknown"
            local weaponName = "Unknown"
            local distance = 0

            if creator and creator.Value then
                killerName = creator.Value.Name
                local killerChar = creator.Value.Character
                if killerChar then
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    local theirRoot = killerChar:FindFirstChild("HumanoidRootPart")
                    if myRoot and theirRoot then
                        distance = (myRoot.Position - theirRoot.Position).Magnitude
                    end
                    for _, tool in ipairs(killerChar:GetChildren()) do
                        if tool:IsA("Tool") then
                            weaponName = tool.Name
                            break
                        end
                    end
                end
            end

            local analysis = analyzeKill(killerName, weaponName, distance)

            if KillNotifEnabled then
                local descLines = {
                    "Killer: " .. analysis.Killer,
                    "Weapon: " .. analysis.Weapon,
                    "Distance: " .. analysis.Distance .. " studs",
                    "Suspected: " .. table.concat(analysis.Suspected, ", "),
                    "Counter: " .. table.concat(analysis.Counter, " | "),
                    "Threat: " .. analysis.Threat .. "/10",
                }
                if analysis.Threat >= 10 then
                    table.insert(descLines, "ENABLE ANTI-SPAWNKILL SHIELD NOW")
                end
                notify("KILL DETECTED", table.concat(descLines, "\n"), 6, "Error")
            end

            if KillLogEnabled then
                table.insert(KillLogs, analysis)
                if #KillLogs > 50 then table.remove(KillLogs, 1) end
            end
        end)
    end)
end

-- ── 21. KILL LOG VIEWER ─────────────────────────────────────
local function openKillLogViewer()
    if CoreGui:FindFirstChild("EXO_KillLogViewer") then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "EXO_KillLogViewer"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 550, 0, 450)
    frame.Position = UDim2.new(0.5, -275, 0.5, -225)
    frame.BackgroundColor3 = Color3.fromRGB(15,15,18)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(190,140,255)
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,35)
    title.BackgroundColor3 = Color3.fromRGB(22,22,26)
    title.Text = "KILL LOG VIEWER"
    title.TextColor3 = Color3.fromRGB(240,240,245)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,-10,1,-80)
    scroll.Position = UDim2.new(0,5,0,40)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.BorderSizePixel = 0
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    if #KillLogs == 0 then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,0,30)
        lbl.BackgroundTransparency = 1
        lbl.Text = "No kills recorded yet."
        lbl.TextColor3 = Color3.fromRGB(160,160,175)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.Parent = scroll
    else
        for i, log in ipairs(KillLogs) do
            local entry = Instance.new("TextLabel")
            entry.Size = UDim2.new(1,-4,0,0)
            entry.AutomaticSize = Enum.AutomaticSize.Y
            entry.BackgroundColor3 = Color3.fromRGB(22,22,26)
            entry.BackgroundTransparency = 0.3
            entry.TextWrapped = true
            entry.TextXAlignment = Enum.TextXAlignment.Left
            entry.TextYAlignment = Enum.TextYAlignment.Top
            entry.Font = Enum.Font.Gotham
            entry.TextSize = 12
            entry.TextColor3 = Color3.fromRGB(240,240,245)
            entry.Text = string.format(
                "[%s] #%d | Killer: %s | Weapon: %s | Dist: %d | Threat: %d/10\nSuspected: %s\nCounter: %s",
                log.Time, i, log.Killer, log.Weapon, log.Distance, log.Threat,
                table.concat(log.Suspected, ", "),
                table.concat(log.Counter, " | ")
            )
            entry.LayoutOrder = i
            entry.Parent = scroll
            Instance.new("UICorner", entry).CornerRadius = UDim.new(0,6)
            local pad = Instance.new("UIPadding", entry)
            pad.PaddingTop = UDim.new(0,4)
            pad.PaddingBottom = UDim.new(0,4)
            pad.PaddingLeft = UDim.new(0,6)
            pad.PaddingRight = UDim.new(0,6)
        end
    end

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,100,0,30)
    closeBtn.Position = UDim2.new(0.5,-50,1,-38)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220,50,50)
    closeBtn.Text = "Close"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
end

-- ── 22. ESP (MINIMAL DOTS) ─────────────────────────────────
local function startESP()
    if espGui then return end
    espGui = Instance.new("ScreenGui")
    espGui.Name = "EXO_ESP"
    espGui.ResetOnSpawn = false
    espGui.Parent = CoreGui

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            dot.BorderSizePixel = 0
            dot.Parent = espGui
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            espDots[plr] = dot
        end
    end

    Players.PlayerAdded:Connect(function(plr)
        if plr ~= player then
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            dot.BorderSizePixel = 0
            dot.Parent = espGui
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            espDots[plr] = dot
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if espDots[plr] then
            espDots[plr]:Destroy()
            espDots[plr] = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not ESPEnabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        for plr, dot in pairs(espDots) do
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = cam:WorldToViewportPoint(char.HumanoidRootPart.Position)
                if onScreen then
                    dot.Position = UDim2.new(0, pos.X - 4, 0, pos.Y - 4)
                    dot.Visible = true
                else
                    dot.Visible = false
                end
            else
                dot.Visible = false
            end
        end
    end)
end

local function stopESP()
    if espGui then
        espGui:Destroy()
        espGui = nil
    end
    table.clear(espDots)
end

-- ── 23. ANTI-LAG SHIELD ─────────────────────────────────────
local function startAntiLag()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end)
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
    end)
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            end
        end
    end)
end

local function stopAntiLag()
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = true
            end
        end
    end)
end

-- ── 24. AUTO GET TOOLS (SPT) ───────────────────────────────
local toolToBase = {
    ["Energy Sword"] = "Stone",
    ["Staff"] = "Magic",
    ["Axe"] = "Storm",
    ["Fist"] = "Robotic"
}
local allowedBases = {Stone=true, Magic=true, Storm=true, Robotic=true}
local excludedBases = {Insanity=true, Giant=true, Dark=true, Spike=true, Web=true, Strong=true}
local padsByBase = {}

local function registerPad(pad)
    local base = pad.Parent and pad.Parent.Parent
    if not base or excludedBases[base.Name] or not allowedBases[base.Name] then return end
    padsByBase[base.Name] = padsByBase[base.Name] or {}
    table.insert(padsByBase[base.Name], pad)
end

local TycoonsFolder = workspace:FindFirstChild("Tycoons")
if TycoonsFolder then
    for _, d in ipairs(TycoonsFolder:GetDescendants()) do
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
            and d.Parent.Parent.Name:find("GearGiver1") then
            registerPad(d.Parent)
        end
    end
    TycoonsFolder.DescendantAdded:Connect(function(d)
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
            and d.Parent.Parent.Name:find("GearGiver1") then
            registerPad(d.Parent)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  BUILD THE HUB UI (CERBERUS)
-- ═══════════════════════════════════════════════════════════
local function buildHub()

    local window = Library.new("EXO Hub", true, 700, 550, "RightControl")
    window:LockScreenBoundaries(true)

    -- ── TABS ────────────────────────────────────────────────
    local SPT_Tab      = window:Tab("Super Power Tycoon")
    local MPT_Tab      = window:Tab("Mega Power Tycoon")
    local Updates_Tab  = window:Tab("Updates")
    local Settings_Tab = window:Tab("Settings")

    -- ═══════════════════════════════════════════════════════
    --  SPT TAB
    -- ═══════════════════════════════════════════════════════

    -- COMBAT: AURA
    local AuraSec = SPT_Tab:Section("Multi-Target Aura")
    AuraSec:Label("Select targets from dropdown, enable aura to attack them.", 12, Color3.fromRGB(160,160,175))

    local auraDropdown = AuraSec:Dropdown("Aura Targets")
    for _, name in ipairs(getServerPlayers()) do
        auraDropdown:Toggle(name)
    end

    AuraSec:Toggle("Enable Aura", function(state)
        Aura.Enabled = state
        if state then
            Aura.TargetList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            startAuraLoop()
        else
            stopAuraLoop()
        end
        notify("Aura", state and "Aura activated." or "Aura deactivated.", 2)
    end)

    AuraSec:Toggle("Instant Kill", function(state)
        InstantKill = state
    end)

    AuraSec:Slider("Prediction Offset", function(val)
        latencyEstimate = val / 100
    end, 25, 5)

    -- COMBAT: TOOL FOLLOW
    local ToolFollowSec = SPT_Tab:Section("Tool Follow")
    ToolFollowSec:Label("Tools hover near selected players' torsos.", 12, Color3.fromRGB(160,160,175))

    local tfDropdown = ToolFollowSec:Dropdown("Tool Follow Targets")
    for _, name in ipairs(getServerPlayers()) do
        tfDropdown:Toggle(name)
    end

    ToolFollowSec:Toggle("Enable Tool Follow", function(state)
        ToolFollow.Enabled = state
        if state then
            ToolFollow.Targets = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(ToolFollow.Targets, plr) end
            end
            startToolFollow()
        else
            stopToolFollow()
        end
    end)

    -- COMBAT: DEFENSE
    local DefenseSec = SPT_Tab:Section("Defense / Anti-Aura")
    DefenseSec:Label("Safe ForceField-based protection. No broken hooks.", 12, Color3.fromRGB(160,160,175))

    DefenseSec:Toggle("Enable Anti-Aura", function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
        notify("Anti-Aura", state and "Defense matrix online." or "Defense matrix offline.", 2)
    end)

    DefenseSec:Toggle("God Mode (ForceField)", function(state)
        AntiAura.GodMode = state
    end)

    DefenseSec:Toggle("Repel (Anti-Touch)", function(state)
        AntiAura.Repel = state
    end)

    DefenseSec:Toggle("Anti Spawnkill", function(state)
        AntiSpawnkill = state
        if state then
            player.CharacterAdded:Connect(function(c)
                local hum = c:WaitForChild("Humanoid")
                hum.MaxHealth = 9e9
                hum.Health = 9e9
                local ff = Instance.new("ForceField", c)
                ff.Visible = false
                task.delay(3, function()
                    if hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end
                    if ff then ff:Destroy() end
                end)
            end)
        end
    end)

    -- TYCOON AUTOMATION
    local TycoonSec = SPT_Tab:Section("Tycoon Automation")

    TycoonSec:Toggle("Auto Claim Money", function(state)
        AutoClaimMoney = state
        if state then startClaimMoney() else stopClaimMoney() end
    end)

    TycoonSec:Toggle("Smart Auto Build", function(state)
        AutoBuild = state
        if state then startAutoBuild() else stopAutoBuild() end
    end)

    -- AUTO GET TOOLS
    local ToolsSec = SPT_Tab:Section("Auto Get Tools")

    ToolsSec:Toggle("Auto Grab Weapons", function(state)
        AutoGetTools = state
        if state then
            if grabLoopConn then grabLoopConn:Disconnect() end
            grabLoopConn = RunService.PreSimulation:Connect(function()
                if not AutoGetTools then return end
                local myChar = player.Character
                if not myChar then return end
                local root = myChar:FindFirstChild("HumanoidRootPart")
                if not root then return end
                for toolName, base in pairs(toolToBase) do
                    if player.Backpack:FindFirstChild(toolName) or myChar:FindFirstChild(toolName) then continue end
                    local pads = padsByBase[base]
                    if not pads then continue end
                    local closest, minDist = nil, 1000
                    for _, pad in ipairs(pads) do
                        local d = (pad.Position - root.Position).Magnitude
                        if d < minDist then minDist = d; closest = pad end
                    end
                    if closest then
                        for _ = 1, 8 do
                            pcall(firetouchinterest, root, closest, 0)
                            pcall(firetouchinterest, root, closest, 1)
                        end
                    end
                end
            end)
        else
            if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end
        end
    end)

    -- TOOLS & COOLDOWN
    local CooldownSec = SPT_Tab:Section("Tools & Cooldown")

    CooldownSec:Toggle("Auto Use Tools (0 delay)", function(state)
        AutoTools = state
        if state then
            toolLoopConn = RunService.RenderStepped:Connect(function()
                if not AutoTools then return end
                local myChar = player.Character
                if not myChar or not myChar:FindFirstChild("Humanoid") or myChar.Humanoid.Health <= 0 then return end
                for _, t in ipairs(myChar:GetChildren()) do
                    if t:IsA("Tool") then pcall(function() t:Activate() end) end
                end
                for _, t in ipairs(player.Backpack:GetChildren()) do
                    if t:IsA("Tool") then
                        t.Parent = myChar
                        pcall(function() t:Activate() end)
                    end
                end
            end)
        else
            if toolLoopConn then toolLoopConn:Disconnect(); toolLoopConn = nil end
        end
    end)

    CooldownSec:Toggle("No Cooldown", function(state)
        NoCooldown = state
        if state then
            if not getgenv().NoCooldownHooked then
                hookfunction(wait, function() return RunService.PostSimulation:Wait() end)
                hookfunction(task.wait, function() return RunService.PostSimulation:Wait() end)
                hookfunction(delay, function(_, func) task.spawn(func) end)
                hookfunction(spawn, function(func) task.spawn(func) end)
                getgenv().NoCooldownHooked = true
            end
        end
    end)

    -- REACH
    local ReachSec = SPT_Tab:Section("Reach")
    ReachSec:Label("Multiplies tool hitbox. Stores originals for clean reset.", 12, Color3.fromRGB(160,160,175))

    ReachSec:Slider("Reach Size", function(val)
        ReachSize = val
        if Reach then stopReach(); startReach() end
    end, 10, 1)

    ReachSec:Toggle("Enable Reach", function(state)
        Reach = state
        if state then startReach() else stopReach() end
    end)

    -- RESPAWN
    local RespawnSec = SPT_Tab:Section("Respawn & Protection")

    RespawnSec:Toggle("Fast Respawn", function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end)

    -- UTILITIES
    local UtilsSec = SPT_Tab:Section("Utilities")

    UtilsSec:Button("Open Game Dumper", function()
        notify("Game Dumper", "Scanner opened. Check CoreGui for DumperGUI.", 3)
        if CoreGui:FindFirstChild("DumperGUI") then return end
        local dGui = Instance.new("ScreenGui", CoreGui)
        dGui.Name = "DumperGUI"
        dGui.ResetOnSpawn = false
        local frame = Instance.new("Frame", dGui)
        frame.Size = UDim2.new(0,650,0,500)
        frame.Position = UDim2.new(0.5,-325,0.5,-250)
        frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
        frame.Active = true
        frame.Draggable = true
        Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)
        local titleLbl = Instance.new("TextLabel", frame)
        titleLbl.Size = UDim2.new(1,0,0,35)
        titleLbl.BackgroundColor3 = Color3.fromRGB(30,30,40)
        titleLbl.Text = "FULL GAME SCANNER"
        titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 18
        local scroll = Instance.new("ScrollingFrame", frame)
        scroll.Size = UDim2.new(1,-10,1,-80)
        scroll.Position = UDim2.new(0,5,0,40)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 8
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.BorderSizePixel = 0
        local listLayout = Instance.new("UIListLayout", scroll)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0,2)
        local logLines = {}
        local function addLog(text, color)
            table.insert(logLines, text)
            local lbl = Instance.new("TextLabel", scroll)
            lbl.Size = UDim2.new(1,0,0,20)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = color or Color3.fromRGB(200,200,200)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
        end
        local closeBtn = Instance.new("TextButton", frame)
        closeBtn.Size = UDim2.new(0,100,0,30)
        closeBtn.Position = UDim2.new(0.5,-50,1,-38)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
        closeBtn.Text = "Close"
        closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.MouseButton1Click:Connect(function() dGui:Destroy() end)
        addLog("SCANNING...", Color3.fromRGB(255,200,50))
        local function scan(container, depth)
            for _, child in ipairs(container:GetChildren()) do
                local indent = string.rep("  ", depth)
                local icon = ""
                if child:IsA("Folder") then icon = "[Folder] "
                elseif child:IsA("Tool") then icon = "[Tool] "
                elseif child:IsA("Model") then icon = "[Model] "
                elseif child:IsA("RemoteEvent") then icon = "[RemoteEvent] "
                elseif child:IsA("RemoteFunction") then icon = "[RemoteFunction] "
                end
                if icon ~= "" then
                    addLog(indent .. icon .. child.Name, Color3.fromRGB(200,200,255))
                    if child:IsA("Folder") then scan(child, depth + 1) end
                end
            end
        end
        addLog("--- WORKSPACE ---", Color3.fromRGB(100,200,255)); scan(workspace, 0)
        addLog("--- REPLICATEDSTORAGE ---", Color3.fromRGB(100,200,255)); scan(ReplicatedStorage, 0)
        addLog("SCAN COMPLETE!", Color3.fromRGB(100,255,255))
    end)

    UtilsSec:TextBox("Set Damage Remote", function(text)
        if text and text ~= "" then
            local success, remote = pcall(function() return loadstring("return " .. text)() end)
            if success and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                DAMAGE_REMOTE = remote
                notify("Remote Set", "Damage remote updated.", 3, "Success")
            else
                notify("Error", "Invalid remote path.", 3, "Error")
            end
        end
    end)

    -- ═══════════════════════════════════════════════════════
    --  MPT TAB (REDESIGNED)
    -- ═══════════════════════════════════════════════════════

    -- OMNI-KILL ENGINE
    local OmniSec = MPT_Tab:Section("Omni-Kill Engine")
    OmniSec:Label("Master toggle: Aura + Instant Kill + Auto-target all.", 12, Color3.fromRGB(160,160,175))

    OmniSec:Toggle("Enable Omni-Kill", function(state)
        Aura.Enabled = state
        InstantKill = state
        if state then
            Aura.TargetList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            startAuraLoop()
            notify("Omni-Kill", "ENGAGED - targeting " .. #Aura.TargetList .. " players.", 3, "Warning")
        else
            stopAuraLoop()
            notify("Omni-Kill", "Disengaged.", 2)
        end
    end)

    OmniSec:Toggle("Insta-Kill Micro-Burst", function(state)
        InstaKillEnabled = state
        if state then startInstaKill() else stopInstaKill() end
    end)

    OmniSec:Slider("Prediction Aggression", function(val)
        latencyEstimate = val / 100
    end, 25, 5)

    OmniSec:Button("Manual Kill Burst", function()
        local orig = Aura.Enabled
        Aura.Enabled = true
        InstantKill = true
        task.wait(0.15)
        Aura.Enabled = orig
        if not orig then InstantKill = false end
        notify("Kill Burst", "Burst fired.", 2)
    end)

    OmniSec:Button("Refresh Target List", function()
        table.clear(Aura.TargetList)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then table.insert(Aura.TargetList, plr) end
        end
        notify("Targets Refreshed", "Now targeting " .. #Aura.TargetList .. " players.", 2)
    end)

    -- HIT AMPLIFIER
    local HitAmpSec = MPT_Tab:Section("Hit Amplifier")
    HitAmpSec:Label("OverlapParams 24x24x24 box scan. 120Hz. 15ms cooldown.", 12, Color3.fromRGB(160,160,175))

    HitAmpSec:Toggle("Enable Hit Amplifier", function(state)
        HitAmpEnabled = state
        if state then startHitAmplifier() else stopHitAmplifier() end
    end)

    -- TOOL ARSENAL
    local ArsenalSec = MPT_Tab:Section("Tool Arsenal")
    ArsenalSec:Label("Wave-based tool acquisition. Bases: Stone, Magic, Storm, Robotic.", 12, Color3.fromRGB(160,160,175))

    ArsenalSec:Toggle("Enable Tool Arsenal", function(state)
        TG_Enabled = state
        if state then
            TG_ScanTycoons()
            if not getgenv().EXO_TG_Loop then
                getgenv().EXO_TG_Loop = true
                task.spawn(function()
                    while getgenv().EXO_TG_Loop do
                        if TG_Enabled then
                            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local wave = TG_BuildWave()
                                TG_AcquirePass(root, wave, 5)
                            end
                        end
                        task.wait(0.1)
                    end
                end)
            end
        else
            getgenv().EXO_TG_Loop = false
        end
    end)

    ArsenalSec:Button("Force Acquire All", function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            TG_ScanTycoons()
            local wave = {}
            for _, baseName in ipairs({"Stone","Magic","Storm","Robotic"}) do
                local pad = TG_GetClosestPad(baseName)
                if pad then table.insert(wave, {Pad = pad, Base = baseName}) end
            end
            TG_AcquirePass(root, wave, 8)
            notify("Tool Arsenal", "Force acquire burst fired.", 2)
        end
    end)

    -- TYCOON SOVEREIGN
    local SovSec = MPT_Tab:Section("Tycoon Sovereign")

    SovSec:Toggle("Enable Sovereign Economy", function(state)
        AutoClaimMoney = state
        AutoBuild = state
        if state then startClaimMoney(); startAutoBuild()
        else stopClaimMoney(); stopAutoBuild() end
    end)

    SovSec:Slider("Defense Threat Radius", function(val)
        ThreatRadius = val
    end, 100, 20)

    SovSec:Button("Force Buy Next Upgrade", function()
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        local cash = getPlayerCash()
        local best, bestPri = nil, 9999
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local cost = getCost(obj)
                local pri = getPriority(obj.Name)
                if cost > 0 and cost <= cash and pri < bestPri then
                    best = obj; bestPri = pri
                end
            end
        end
        if best then
            for _, part in ipairs(getTouchableParts(best)) do
                pcall(firetouchinterest, root, part, 0)
                pcall(firetouchinterest, root, part, 1)
            end
            notify("Purchased", "Bought: " .. best.Name, 2, "Success")
        else
            notify("No Purchase", "Nothing affordable.", 2)
        end
    end)

    -- SPAWN SUPREMACY
    local SpawnSec = MPT_Tab:Section("Spawn Supremacy")

    SpawnSec:Toggle("Enable Supremacy Mode", function(state)
        AntiSpawnkill = state
        if state then
            player.CharacterAdded:Connect(function(c)
                local hum = c:WaitForChild("Humanoid")
                hum.MaxHealth = 9e9
                hum.Health = 9e9
                local ff = Instance.new("ForceField", c)
                ff.Visible = false
                task.delay(3, function()
                    if hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end
                    if ff then ff:Destroy() end
                end)
            end)
        end
    end)

    SpawnSec:Toggle("Fast Respawn", function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end)

    -- DEFENSE MATRIX
    local DefSec = MPT_Tab:Section("Defense Matrix")

    DefSec:Toggle("Enable Defense Matrix", function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end)

    DefSec:Toggle("ForceField God Mode", function(state)
        AntiAura.GodMode = state
    end)

    DefSec:Toggle("Weapon Repel", function(state)
        AntiAura.Repel = state
    end)

    DefSec:Button("Emergency Heal", function()
        local myChar = player.Character
        if myChar then
            local hum = myChar:FindFirstChild("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                notify("Healed", "Health restored.", 2, "Success")
            end
        end
    end)

    -- ═══════════════════════════════════════════════════════
    --  UPDATES TAB
    -- ═══════════════════════════════════════════════════════
    local ChangeSec = Updates_Tab:Section("EXO Hub Changelog")

    ChangeSec:Title("v3.0 - August 03, 2026")
    ChangeSec:Label("  FULL REWRITE on Cerberus UI Library", 13)
    ChangeSec:Label("  Key System now actually shows and gates the hub", 13)
    ChangeSec:Label("  MPT completely redesigned: 6 sections", 13)
    ChangeSec:Label("  Added Insta-Kill Micro-Burst (from TFL)", 13)
    ChangeSec:Label("  Added Hit Amplifier overlap scanning (from TFL)", 13)
    ChangeSec:Label("  Added Tool Arsenal wave system (from TFL)", 13)
    ChangeSec:Label("  Anti-Aura rewritten: safe ForceField, no broken hooks", 13)
    ChangeSec:Label("  Reach slider fixed with original size storage", 13)
    ChangeSec:Label("  Settings: UI themes, configs, anti-lag, ESP, kill notifs", 13)
    ChangeSec:Label("  Kill Notifications: behavioral analysis + threat level", 13)
    ChangeSec:Label("  Kill Logs: scrollable viewer with full history", 13)

    ChangeSec:Title("v2.0 - August 03, 2026")
    ChangeSec:Label("  Migrated to ZyronX UI (deprecated)", 13)
    ChangeSec:Label("  All syntax/string bugs fixed", 13)

    ChangeSec:Title("v1.2 - August 01, 2026")
    ChangeSec:Label("  MPT Tab Redesigned", 13)
    ChangeSec:Label("  Enhanced Aura with predictive hit registration", 13)

    ChangeSec:Title("v1.1 - July 25, 2026")
    ChangeSec:Label("  Improved Tool Follow, Reach, Respawn", 13)
    ChangeSec:Label("  Added Updates Tab", 13)

    -- ═══════════════════════════════════════════════════════
    --  SETTINGS TAB
    -- ═══════════════════════════════════════════════════════

    -- UI CONFIG
    local UICard = Settings_Tab:Section("UI Config")
    UICard:Label("Customize hub appearance.", 12, Color3.fromRGB(160,160,175))

    UICard:ColorWheel("Accent Color", function(color)
        CurrentTheme.Accent = color
    end)

    UICard:Button("Theme: Purple", function()
        CurrentTheme.Accent = Color3.fromRGB(190,140,255)
        notify("Theme", "Purple accent applied.", 2)
    end)
    UICard:Button("Theme: Green", function()
        CurrentTheme.Accent = Color3.fromRGB(50,200,100)
        notify("Theme", "Green accent applied.", 2)
    end)
    UICard:Button("Theme: Red", function()
        CurrentTheme.Accent = Color3.fromRGB(220,50,50)
        notify("Theme", "Red accent applied.", 2)
    end)
    UICard:Button("Theme: Blue", function()
        CurrentTheme.Accent = Color3.fromRGB(50,120,220)
        notify("Theme", "Blue accent applied.", 2)
    end)
    UICard:Button("Theme: Gold", function()
        CurrentTheme.Accent = Color3.fromRGB(230,180,40)
        notify("Theme", "Gold accent applied.", 2)
    end)

    -- CONFIG SAVE/LOAD
    local ConfigCard = Settings_Tab:Section("Config")

    ConfigCard:Button("Save Config", function()
        local config = {
            ReachSize = ReachSize,
            ThreatRadius = ThreatRadius,
            latencyEstimate = latencyEstimate,
            Theme = {
                R = CurrentTheme.Accent.R,
                G = CurrentTheme.Accent.G,
                B = CurrentTheme.Accent.B,
            },
            Toggles = {
                AntiAura = AntiAura.Enabled,
                GodMode = AntiAura.GodMode,
                Repel = AntiAura.Repel,
                ESP = ESPEnabled,
                AntiLag = AntiLagEnabled,
                KillNotif = KillNotifEnabled,
                KillLog = KillLogEnabled,
            }
        }
        writeJSON(CONFIG_FILE, config)
        notify("Config Saved", "Settings saved to " .. CONFIG_FILE, 2, "Success")
    end)

    ConfigCard:Button("Load Config", function()
        local config = readJSON(CONFIG_FILE)
        if config then
            ReachSize = config.ReachSize or 2
            ThreatRadius = config.ThreatRadius or 50
            latencyEstimate = config.latencyEstimate or 0.1
            if config.Theme then
                CurrentTheme.Accent = Color3.new(config.Theme.R, config.Theme.G, config.Theme.B)
            end
            notify("Config Loaded", "Settings restored.", 2, "Success")
        else
            notify("No Config", "No saved config found.", 2, "Error")
        end
    end)

    -- GENERAL
    local GeneralCard = Settings_Tab:Section("General")

    GeneralCard:Toggle("Anti-Lag Shield", function(state)
        AntiLagEnabled = state
        if state then
            startAntiLag()
            notify("Anti-Lag", "Performance mode activated.", 3, "Success")
        else
            stopAntiLag()
            notify("Anti-Lag", "Performance mode deactivated.", 2)
        end
    end)

    GeneralCard:Toggle("ESP (Minimal Dots)", function(state)
        ESPEnabled = state
        if state then
            startESP()
            notify("ESP", "Player dots enabled.", 2)
        else
            stopESP()
            notify("ESP", "ESP disabled.", 2)
        end
    end)

    GeneralCard:Toggle("Kill Notifications", function(state)
        KillNotifEnabled = state
        if state then
            notify("Kill Notifications", "You will be notified when killed.\nIncludes behavioral analysis + threat level.", 4)
        end
    end)

    GeneralCard:Toggle("Kill Logs", function(state)
        KillLogEnabled = state
        if state then
            notify("Kill Logs", "All kill events will be logged.", 2)
        end
    end)

    GeneralCard:Button("Open Kill Log Viewer", function()
        openKillLogViewer()
    end)

    -- SETUP KILL NOTIFICATIONS
    setupKillNotifications()

    -- FINAL
    notify("EXO Hub v3.0 Loaded", "Cerberus Edition. All systems online.\nSPT + MPT + Settings + Updates", 4, "Success")
    print("[EXO] Power Tycoon Hub v3.0 - Cerberus Edition. Ready.")
end

-- ═══════════════════════════════════════════════════════════
--  KEY SYSTEM GATE (ACTUALLY CALLED)
-- ═══════════════════════════════════════════════════════════
local savedKey = readJSON(KEY_FILE)
if savedKey and savedKey.key == HUB_KEY then
    buildHub()
else
    createKeySystem(function()
        buildHub()
    end)
end
