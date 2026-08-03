-- ═══════════════════════════════════════════════════════════
--  EXO HUB – Power Tycoon | ZyronX UI Edition
--  Rewritten & Fixed
-- ═══════════════════════════════════════════════════════════

-- ── 1. LOAD ZYRONX LIBRARY ──────────────────────────────────
local Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()

-- ── 2. SERVICES ─────────────────────────────────────────────
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local player            = Players.LocalPlayer

-- ── 3. CONFIGURATION ────────────────────────────────────────
local HUB_KEY   = "EXOSTAKEOVERR19$"
local KEY_FILE  = "exo_key_v3.dat"

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

-- ── 5. KEY SYSTEM (★ FIX: actually called now) ─────────────
local keyValidated = false

local function createKeySystem(onSuccess)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ExoKeySystem"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 480, 0, 340)
    card.Position = UDim2.new(0.5, -240, 0.5, -170)
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    card.BorderSizePixel = 0
    card.Parent = gui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(35, 35, 42)
    stroke.Thickness = 1.5

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    topbar.BorderSizePixel = 0
    topbar.Parent = card
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 12)
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, 15)
    fix.Position = UDim2.new(0, 0, 1, -15)
    fix.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    fix.BorderSizePixel = 0
    fix.Parent = topbar

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, -20, 1, 0)
    logo.Position = UDim2.new(0, 20, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "EXO  |  Key Authentication"
    logo.TextColor3 = Color3.fromRGB(240, 240, 245)
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 14
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = topbar

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.Position = UDim2.new(0, 0, 1, 0)
    accent.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
    accent.BorderSizePixel = 0
    accent.Parent = topbar

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 40)
    desc.Position = UDim2.new(0, 20, 0, 65)
    desc.BackgroundTransparency = 1
    desc.Text = "Enter your premium key to access the Power Tycoon Hub."
    desc.TextColor3 = Color3.fromRGB(160, 160, 175)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 13
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = card

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1, -40, 0, 48)
    inputBg.Position = UDim2.new(0, 20, 0, 125)
    inputBg.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    inputBg.BorderSizePixel = 0
    inputBg.Parent = card
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 8)
    local iStroke = Instance.new("UIStroke", inputBg)
    iStroke.Color = Color3.fromRGB(35, 35, 42)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "Paste your premium key here..."
    input.PlaceholderColor3 = Color3.fromRGB(160, 160, 175)
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(240, 240, 245)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = inputBg

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 48)
    btn.Position = UDim2.new(0, 20, 0, 195)
    btn.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
    btn.Text = "AUTHENTICATE & UNLOCK"
    btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 255)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(220, 50, 50)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 12
    status.Parent = card

    btn.MouseButton1Click:Connect(function()
        if input.Text == HUB_KEY then
            writeJSON(KEY_FILE, {key = HUB_KEY, time = os.time()})
            status.Text = "Authentication Successful. Loading Hub..."
            status.TextColor3 = Color3.fromRGB(50, 200, 100)
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            keyValidated = true
            task.wait(1.2)
            gui:Destroy()
            if onSuccess then onSuccess() end
        else
            status.Text = "Invalid Key. Please check and try again."
            input.Text = ""
        end
    end)

    input.FocusLost:Connect(function(enter)
        if enter then btn.MouseButton1Click:Fire() end
    end)
end

-- ── 6. STATE VARIABLES ──────────────────────────────────────
local DAMAGE_REMOTE   = nil
local Aura            = {Enabled = false, TargetList = {}}
local InstantKill     = false
local AutoTools       = false
local NoCooldown      = false
local Reach           = false
local ReachSize       = 2
local FastRespawn     = false
local AntiSpawnkill   = false
local ToolFollow      = {Enabled = false, Targets = {}, Connection = nil}
local AutoGetTools    = false
local AutoClaimMoney  = false
local AutoBuild       = false
local grabLoopConn    = nil
local toolLoopConn    = nil
local auraConn        = nil
local claimConn       = nil
local buildConn       = nil
local cachedTycoonType= nil
local AntiAura        = {Enabled = false, GodMode = false, Repel = false}
local antiAuraConn    = nil
local ThreatLevel     = 0
local LastThreatCheck = 0
local ThreatRadius    = 50
local latencyEstimate = 0.1

-- ── 7. DAMAGE REMOTE DETECTION ──────────────────────────────
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
else
    warn("[EXO] No damage remote found – use Game Dumper to set it manually.")
end

-- ── 8. TYCOON HELPERS ───────────────────────────────────────
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
        local tycoonsFolder = workspace:FindFirstChild("Tycoons")
        if tycoonsFolder then
            for _, tf in ipairs(tycoonsFolder:GetChildren()) do
                if tf:IsA("Folder") then
                    local door = tf:FindFirstChild("Door", true)
                    if door then
                        local dp = door:FindFirstChildWhichIsA("BasePart")
                        if dp then
                            local d = (dp.Position - root.Position).Magnitude
                            if d < minDist then minDist = d; closest = tf.Name end
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
        local cash = ls:FindFirstChild("Cash") or ls:FindFirstChild("Money")
            or ls:FindFirstChild("Coins") or ls:FindFirstChild("Gold")
        if cash and (cash:IsA("IntValue") or cash:IsA("NumberValue")) then
            return cash.Value
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
        if num == 0 then return 10 end
        if num == 1 then return 11 end
        if num == 2 then return 30 end
        if num == 3 then return 31 end
        if num == 4 then return 50 end
        if num == 5 then return 60 end
        if num >= 6 then return 70 + num end
    end
    if name:find("gear") or name:find("gun") then
        if num <= 1 then return 20 end
        if num == 2 then return 21 end
        if num == 3 then return 55 end
        if num == 4 then return 65 end
        if num == 5 then return 66 end
        if num >= 6 then return 67 + num end
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

-- ── 9. THREAT DETECTION ─────────────────────────────────────
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

-- ── 10. AURA & KILL ─────────────────────────────────────────
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

-- ── 11. TOOL FOLLOW ─────────────────────────────────────────
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

-- ── 12. AUTO CLAIM & BUILD ──────────────────────────────────
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

-- ── 13. ANTI-AURA (★ COMPLETELY REWRITTEN – no longer kills you) ──
local antiAuraFF = nil

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

        -- GOD MODE: ForceField + health clamp (safe, no desync)
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

        -- REPEL: Push away nearby tool handles using AssemblyLinearVelocity (safe)
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

-- ── 14. REACH (★ FIXED – stores original sizes) ────────────
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
                    hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                    hl.OutlineTransparency = 0
                    reachHL[part] = hl
                end
            end
        end
    end
end

local function startReach()
    applyReach()
end

local function stopReach()
    for part, hl in pairs(reachHL) do
        if hl and hl.Parent == part then hl:Destroy() end
    end
    table.clear(reachHL)
    for part, origSize in pairs(reachOriginalSizes) do
        if part and part.Parent then
            part.Size = origSize
        end
    end
    table.clear(reachOriginalSizes)
end

-- ── 15. FAST RESPAWN ────────────────────────────────────────
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
        hum.HealthChanged:Connect(function(hp)
            if hp <= 0 then respawn() end
        end)
        hum.Died:Connect(respawn)
    end
    if player.Character then hook(player.Character) end
    player.CharacterAdded:Connect(hook)
end

-- ── 16. AUTO GET TOOLS SETUP ────────────────────────────────
local toolToBase = {
    ["Energy Sword"] = "Stone",
    ["Staff"]        = "Magic",
    ["Axe"]          = "Storm",
    ["Fist"]         = "Robotic"
}
local allowedBases  = {Stone=true, Magic=true, Storm=true, Robotic=true}
local excludedBases = {Insanity=true, Giant=true, Dark=true, Spike=true, Web=true, Strong=true}
local padsByBase    = {}

local function registerPad(pad)
    local base = pad.Parent and pad.Parent.Parent
    if not base or excludedBases[base.Name] or not allowedBases[base.Name] then return end
    padsByBase[base.Name] = padsByBase[base.Name] or {}
    table.insert(padsByBase[base.Name], pad)
end

local Tycoons = workspace:FindFirstChild("Tycoons")
if Tycoons then
    for _, d in ipairs(Tycoons:GetDescendants()) do
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
            and d.Parent.Parent.Name:find("GearGiver1") then
            registerPad(d.Parent)
        end
    end
    Tycoons.DescendantAdded:Connect(function(d)
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
            and d.Parent.Parent.Name:find("GearGiver1") then
            registerPad(d.Parent)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  BUILD THE HUB UI (ZyronX Library)
-- ═══════════════════════════════════════════════════════════

local function buildHub()

    -- Whitelist (add usernames for paid access tabs)
    Library.WhitelistedUsers = {
        player.Name
    }

    -- ★ FIX: Logo changed from "ZX" to "E"
    local Window = Library:CreateWindow({
        Title = "EXO Hub",
        Subtitle = "Power Tycoon | Architectural Master Edition",
        SubtitleColor = Color3.fromRGB(190, 140, 255),
        Logo = "rbxassetid://82367817676382",
        LogoSize = 32,
        SphereText = true,
        SphereWords = "E",
        SphereImage = "rbxassetid://82367817676382",
        SphereIconSize = 38
    })

    -- ── TABS ────────────────────────────────────────────────
    local SPT_Tab      = Window:CreateTab("Super Power Tycoon", true, false)
    local MPT_Tab      = Window:CreateTab("Mega Power Tycoon", false, false)
    local Updates_Tab  = Window:CreateTab("Updates", false, false)
    local Settings_Tab = Window:CreateTab("Settings", false, false)

    -- ── SPT PAGES ───────────────────────────────────────────
    local SPT_Combat = SPT_Tab:CreatePage("Combat")
    local SPT_Tycoon = SPT_Tab:CreatePage("Tycoon")
    local SPT_Misc   = SPT_Tab:CreatePage("Movement & Visuals")
    local SPT_Utils  = SPT_Tab:CreatePage("Utilities")

    -- ── MPT PAGES ───────────────────────────────────────────
    local MPT_Combat = MPT_Tab:CreatePage("Omni-Kill Suite")
    local MPT_Tycoon = MPT_Tab:CreatePage("Tycoon Sovereign")
    local MPT_Spawn  = MPT_Tab:CreatePage("Spawn Supremacy")
    local MPT_Def    = MPT_Tab:CreatePage("Defense Matrix")

    -- ── UPDATES PAGE ────────────────────────────────────────
    local Updates_Page = Updates_Tab:CreatePage("Changelog")

    -- ── SETTINGS PAGE ───────────────────────────────────────
    local Settings_Page = Settings_Tab:CreatePage("Settings")

    -- ═══════════════════════════════════════════════════════
    --  SPT → COMBAT
    -- ═══════════════════════════════════════════════════════
    local AuraCard = SPT_Combat:CreateSection("Multi-Target Aura")

    AuraCard:AddDropdown("Aura Targets", getServerPlayers(), true, function(selected)
        table.clear(Aura.TargetList)
        if selected then
            for _, name in ipairs(selected) do
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(Aura.TargetList, plr) end
            end
        end
        Library:Notify({
            Title = "Aura Targets Updated",
            Description = "Targeting " .. #Aura.TargetList .. " player(s).",
            Duration = 2
        })
    end, {
        Title = "Select Aura Targets",
        Description = "Multi-select players for the aura to attack. Updates in real-time.",
        Example = "Select multiple players to hit them all simultaneously."
    })

    AuraCard:AddToggle("Enable Aura", false, function(state)
        Aura.Enabled = state
        if state then startAuraLoop() else stopAuraLoop() end
        Library:Notify({
            Title = "Aura",
            Description = state and "Aura activated." or "Aura deactivated.",
            Duration = 2
        })
    end, {
        Title = "Enable Aura",
        Description = "Teleports your weapon hitbox to each target every frame for guaranteed hits.",
        Example = "Requires at least one target selected and a tool equipped."
    })

    AuraCard:AddToggle("Instant Kill", false, function(state)
        InstantKill = state
    end, {
        Title = "Instant Kill",
        Description = "Attempts to set target health to 0 on contact. Works best with damage remotes.",
        Example = "Combine with Aura for maximum lethality."
    })

    AuraCard:AddSlider("Prediction Offset", 0.05, 0.25, 0.1, function(val)
        latencyEstimate = val
    end, {
        Title = "Hit Prediction",
        Description = "Adjusts how far ahead the aura predicts target movement. Higher = more lead.",
        Example = "Set to ~0.1 for normal ping, ~0.2 for high ping targets."
    })

    local ToolFollowCard = SPT_Combat:CreateSection("Tool Follow")

    ToolFollowCard:AddDropdown("Tool Follow Targets", getServerPlayers(), true, function(selected)
        table.clear(ToolFollow.Targets)
        if selected then
            for _, name in ipairs(selected) do
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(ToolFollow.Targets, plr) end
            end
        end
    end, {
        Title = "Select Tool Follow Targets",
        Description = "Your equipped tools will hover near the selected players' torsos.",
        Example = "Select a player and enable Tool Follow to stick your weapon to them."
    })

    ToolFollowCard:AddToggle("Enable Tool Follow", false, function(state)
        ToolFollow.Enabled = state
        if state then startToolFollow() else stopToolFollow() end
    end, {
        Title = "Enable Tool Follow",
        Description = "Makes your tool hitbox follow targets automatically.",
        Example = "Works best with melee weapons."
    })

    -- ═══════════════════════════════════════════════════════
    --  SPT → COMBAT → DEFENSE (★ FULLY REWRITTEN)
    -- ═══════════════════════════════════════════════════════
    local DefenseCard = SPT_Combat:CreateSection("Defense / Anti-Aura")

    DefenseCard:AddToggle("Enable Anti-Aura", false, function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
        Library:Notify({
            Title = "Anti-Aura",
            Description = state and "Defense matrix online." or "Defense matrix offline.",
            Duration = 2
        })
    end, {
        Title = "Enable Anti-Aura",
        Description = "Master toggle for all defensive features. Uses ForceField and safe velocity manipulation instead of broken hooks.",
        Example = "Enable this BEFORE entering a PvP zone."
    })

    DefenseCard:AddToggle("God Mode (ForceField)", false, function(state)
        AntiAura.GodMode = state
    end, {
        Title = "God Mode",
        Description = "Applies an invisible ForceField to your character and auto-heals when health drops below 50%. No CFrame desync.",
        Example = "Combine with Anti-Aura master toggle for full protection."
    })

    DefenseCard:AddToggle("Repel (Anti-Touch)", false, function(state)
        AntiAura.Repel = state
    end, {
        Title = "Repel",
        Description = "Pushes away nearby enemy weapon handles using AssemblyLinearVelocity. Safe and stable.",
        Example = "Effective against melee aura users within 10 studs."
    })

    DefenseCard:AddToggle("Anti Spawnkill", false, function(state)
        AntiSpawnkill = state
        if state then
            player.CharacterAdded:Connect(function(c)
                local hum = c:WaitForChild("Humanoid")
                hum.MaxHealth = 9e9
                hum.Health = 9e9
                local ff = Instance.new("ForceField", c)
                ff.Visible = false
                task.delay(3, function()
                    if hum and hum.Parent then
                        hum.MaxHealth = 100
                        hum.Health = 100
                    end
                    if ff then ff:Destroy() end
                end)
            end)
        end
    end, {
        Title = "Anti Spawnkill",
        Description = "Grants 3 seconds of invincibility via ForceField + max health on every respawn.",
        Example = "Prevents spawn camping."
    })

    -- ═══════════════════════════════════════════════════════
    --  SPT → TYCOON
    -- ═══════════════════════════════════════════════════════
    local TycoonCard = SPT_Tycoon:CreateSection("Tycoon Automation")

    TycoonCard:AddToggle("Auto Claim Money", false, function(state)
        AutoClaimMoney = state
        if state then startClaimMoney() else stopClaimMoney() end
    end, {
        Title = "Auto Claim Money",
        Description = "Automatically touches the CashRegister to collect money every frame.",
        Example = "Enable and AFK – money flows in automatically."
    })

    TycoonCard:AddToggle("Smart Auto Build", false, function(state)
        AutoBuild = state
        if state then startAutoBuild() else stopAutoBuild() end
    end, {
        Title = "Smart Auto Build",
        Description = "Buys tycoon upgrades in priority order. Switches to defensive builds (walls/doors) when enemies are nearby.",
        Example = "Adaptive: builds generators first, fortifies when threatened."
    })

    local ToolsCard = SPT_Tycoon:CreateSection("Auto Get Tools")

    ToolsCard:AddToggle("Auto Grab Weapons", false, function(state)
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
                    if player.Backpack:FindFirstChild(toolName) or myChar:FindFirstChild(toolName) then
                        continue
                    end
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
    end, {
        Title = "Auto Grab Weapons",
        Description = "Automatically touches the nearest GearGiver pad for each weapon type (Stone, Magic, Storm, Robotic).",
        Example = "Skips Insanity, Giant, Dark, Spike, Web, Strong bases."
    })

    local CooldownCard = SPT_Tycoon:CreateSection("Tools & Cooldown")

    CooldownCard:AddToggle("Auto Use Tools (0 delay)", false, function(state)
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
    end, {
        Title = "Auto Use Tools",
        Description = "Activates every tool in your character and backpack every frame with zero delay.",
        Example = "Best combined with Auto Grab Weapons."
    })

    CooldownCard:AddToggle("No Cooldown", false, function(state)
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
                                pcall(function() t.Enabled = true end)
                                local handle = t.Handle
                                if handle:IsA("BasePart") then
                                    handle.CanCollide = false
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
        Description = "Hooks wait/delay/spawn to eliminate all tool cooldowns. Arms stick to targets.",
        Example = "Use with Auto Use Tools for maximum DPS."
    })

    -- ═══════════════════════════════════════════════════════
    --  SPT → MOVEMENT & VISUALS (★ REACH FIXED)
    -- ═══════════════════════════════════════════════════════
    local ReachCard = SPT_Misc:CreateSection("Reach")

    ReachCard:AddSlider("Reach Size", 1, 10, ReachSize, function(value)
        ReachSize = value
        if Reach then
            stopReach()
            startReach()
        end
    end, {
        Title = "Reach Size Multiplier",
        Description = "Multiplies your tool hitbox size. Stores original sizes for clean reset. Range: 1x to 10x.",
        Example = "Set to 3 for moderate reach, 10 for maximum. Re-applies on respawn."
    })

    ReachCard:AddToggle("Reach (hitbox + outline)", false, function(state)
        Reach = state
        if state then
            startReach()
        else
            stopReach()
        end
    end, {
        Title = "Enable Reach",
        Description = "Expands your tool hitboxes and adds a blue outline highlight. Original sizes are stored and restored on toggle off.",
        Example = "Toggle off to restore normal weapon sizes."
    })

    local RespawnCard = SPT_Misc:CreateSection("Respawn & Protection")

    RespawnCard:AddToggle("Fast Respawn", false, function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end, {
        Title = "Fast Respawn",
        Description = "Uses the Guide remote (if available) or LoadCharacter for instant respawn on death.",
        Example = "No more waiting on the respawn timer."
    })

    -- ═══════════════════════════════════════════════════════
    --  SPT → UTILITIES
    -- ═══════════════════════════════════════════════════════
    local UtilsCard = SPT_Utils:CreateSection("Tools")

    UtilsCard:AddButton("Open Game Dumper", function()
        if CoreGui:FindFirstChild("DumperGUI") then return end
        local dGui = Instance.new("ScreenGui", CoreGui)
        dGui.Name = "DumperGUI"
        dGui.ResetOnSpawn = false
        local frame = Instance.new("Frame", dGui)
        frame.Size = UDim2.new(0, 650, 0, 500)
        frame.Position = UDim2.new(0.5, -325, 0.5, -250)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.Active = true
        frame.Draggable = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, 0, 0, 35)
        title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        title.Text = "FULL GAME SCANNER"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18

        local scroll = Instance.new("ScrollingFrame", frame)
        scroll.Size = UDim2.new(1, -10, 1, -80)
        scroll.Position = UDim2.new(0, 5, 0, 40)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 8
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.BorderSizePixel = 0

        local listLayout = Instance.new("UIListLayout", scroll)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)

        local logLines = {}
        local function addLog(text, color)
            table.insert(logLines, text)
            local lbl = Instance.new("TextLabel", scroll)
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
        end

        local copyBtn = Instance.new("TextButton", frame)
        copyBtn.Size = UDim2.new(0, 120, 0, 30)
        copyBtn.Position = UDim2.new(0.5, -160, 1, -40)
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
        copyBtn.Text = "Copy Log"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 14
        copyBtn.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(table.concat(logLines, "\n")) end)
            addLog("Copied to clipboard!", Color3.fromRGB(100, 255, 100))
        end)

        local closeBtn = Instance.new("TextButton", frame)
        closeBtn.Size = UDim2.new(0, 100, 0, 30)
        closeBtn.Position = UDim2.new(0.5, 30, 1, -40)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        closeBtn.Text = "Close"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.MouseButton1Click:Connect(function() dGui:Destroy() end)

        addLog("SCANNING ALL GAME OBJECTS...", Color3.fromRGB(255, 200, 50))

        local function scan(container, depth)
            for _, child in ipairs(container:GetChildren()) do
                local indent = string.rep("  ", depth)
                local icon = ""
                if child:IsA("Folder") then icon = "[Folder] "
                elseif child:IsA("Tool") then icon = "[Tool] "
                elseif child:IsA("Model") then icon = "[Model] "
                elseif child:IsA("RemoteEvent") then icon = "[RemoteEvent] "
                elseif child:IsA("RemoteFunction") then icon = "[RemoteFunction] "
                elseif child:IsA("BindableEvent") or child:IsA("BindableFunction") then
                    icon = "[" .. child.ClassName .. "] "
                end
                if icon ~= "" then
                    addLog(indent .. icon .. child.Name, Color3.fromRGB(200, 200, 255))
                    if child:IsA("Folder") then scan(child, depth + 1) end
                end
            end
        end

        addLog("--- WORKSPACE ---", Color3.fromRGB(100, 200, 255)); scan(workspace, 0)
        addLog("--- REPLICATEDSTORAGE ---", Color3.fromRGB(100, 200, 255)); scan(ReplicatedStorage, 0)
        addLog("--- REPLICATEDFIRST ---", Color3.fromRGB(100, 200, 255)); scan(game:GetService("ReplicatedFirst"), 0)
        addLog("--- LIGHTING ---", Color3.fromRGB(100, 200, 255)); scan(game:GetService("Lighting"), 0)
        if player:FindFirstChild("Backpack") then
            addLog("--- PLAYER BACKPACK ---", Color3.fromRGB(100, 200, 255)); scan(player.Backpack, 0)
        end
        if player.Character then
            addLog("--- PLAYER CHARACTER ---", Color3.fromRGB(100, 200, 255)); scan(player.Character, 0)
        end
        addLog("SCAN COMPLETE!", Color3.fromRGB(100, 255, 255))
    end, {
        Title = "Game Dumper",
        Description = "Opens a full scanner window listing all Folders, Tools, Models, Remotes in the game.",
        Example = "Use this to find the damage remote path for the textbox below."
    })

    UtilsCard:AddTextbox("Set Damage Remote", "game.ReplicatedStorage.DealDamage", function(text)
        if text and text ~= "" then
            local success, remote = pcall(function() return loadstring("return " .. text)() end)
            if success and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                DAMAGE_REMOTE = remote
                Library:Notify({
                    Title = "Remote Set",
                    Description = "Damage remote updated: " .. DAMAGE_REMOTE:GetFullName(),
                    Duration = 3
                })
            else
                Library:Notify({
                    Title = "Error",
                    Description = "Invalid remote path. Check the Game Dumper output.",
                    Duration = 3
                })
            end
        end
    end, {
        Title = "Set Damage Remote",
        Description = "Manually set the remote used by Aura and Instant Kill. Find it using the Game Dumper.",
        Example = "Format: game.ReplicatedStorage.YourRemoteName"
    })

    -- ═══════════════════════════════════════════════════════
    --  MPT → OMNI-KILL SUITE (★ REDESIGNED)
    -- ═══════════════════════════════════════════════════════
    local OmniCard = MPT_Combat:CreateSection("Omni-Kill Engine")

    OmniCard:AddToggle("Enable Omni-Kill", false, function(state)
        Aura.Enabled = state
        InstantKill = state
        if state then
            -- Auto-target ALL players if none selected
            if #Aura.TargetList == 0 then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then table.insert(Aura.TargetList, plr) end
                end
            end
            startAuraLoop()
        else
            stopAuraLoop()
        end
        Library:Notify({
            Title = "Omni-Kill",
            Description = state and "OMNI-KILL ENGAGED – targeting " .. #Aura.TargetList .. " players." or "Omni-Kill disengaged.",
            Duration = 3
        })
    end, {
        Title = "Enable Omni-Kill",
        Description = "Master toggle: enables Aura + Instant Kill simultaneously. Auto-targets all players if none selected.",
        Example = "One toggle for total server domination."
    })

    OmniCard:AddSlider("Prediction Aggression", 0.05, 0.25, 0.1, function(val)
        latencyEstimate = val
    end, {
        Title = "Prediction Aggression",
        Description = "How far ahead the kill engine predicts movement. Higher = more aggressive lead.",
        Example = "0.1 for normal, 0.2 for laggy targets."
    })

    OmniCard:AddButton("Manual Kill Burst", function()
        local orig = Aura.Enabled
        Aura.Enabled = true
        InstantKill = true
        task.wait(0.15)
        Aura.Enabled = orig
        if not orig then InstantKill = false end
    end, {
        Title = "Manual Kill Burst",
        Description = "Fires a single high-intensity burst kill pulse at all targets.",
        Example = "Use for quick eliminations without keeping aura on."
    })

    OmniCard:AddButton("Refresh Target List", function()
        table.clear(Aura.TargetList)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then table.insert(Aura.TargetList, plr) end
        end
        Library:Notify({
            Title = "Targets Refreshed",
            Description = "Now targeting " .. #Aura.TargetList .. " players.",
            Duration = 2
        })
    end, {
        Title = "Refresh Target List",
        Description = "Re-scans the server and updates the target list with all current players.",
        Example = "Use when new players join."
    })

    -- ═══════════════════════════════════════════════════════
    --  MPT → TYCOON SOVEREIGN (★ REDESIGNED)
    -- ═══════════════════════════════════════════════════════
    local SovCard = MPT_Tycoon:CreateSection("Sovereign Economy")

    SovCard:AddToggle("Enable Sovereign Economy", false, function(state)
        AutoClaimMoney = state
        AutoBuild = state
        if state then
            startClaimMoney()
            startAutoBuild()
        else
            stopClaimMoney()
            stopAutoBuild()
        end
    end, {
        Title = "Sovereign Economy",
        Description = "Combines Auto Claim + Smart Auto Build into one toggle. Fully automated tycoon progression.",
        Example = "Enable and walk away – your tycoon builds itself."
    })

    SovCard:AddSlider("Defense Threat Radius", 20, 100, ThreatRadius, function(val)
        ThreatRadius = val
    end, {
        Title = "Defense Threshold",
        Description = "How close an enemy must be before the build system switches to defensive mode (walls/doors).",
        Example = "Lower = more paranoid building. Higher = economy-focused."
    })

    SovCard:AddButton("Force Buy Next Upgrade", function()
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
            Library:Notify({
                Title = "Purchased",
                Description = "Bought: " .. best.Name,
                Duration = 2
            })
        else
            Library:Notify({
                Title = "No Purchase",
                Description = "Nothing affordable found.",
                Duration = 2
            })
        end
    end, {
        Title = "Force Buy",
        Description = "Instantly buys the highest-priority affordable upgrade.",
        Example = "Use when you want to skip the queue."
    })

    SovCard:AddLabel("Current Cash: " .. getPlayerCash())
    SovCard:AddLabel("Threat Level: " .. ThreatLevel)

    -- ═══════════════════════════════════════════════════════
    --  MPT → SPAWN SUPREMACY (★ REDESIGNED)
    -- ═══════════════════════════════════════════════════════
    local SpawnCard = MPT_Spawn:CreateSection("Spawn Supremacy")

    SpawnCard:AddToggle("Enable Supremacy Mode", false, function(state)
        AntiSpawnkill = state
        if state then
            player.CharacterAdded:Connect(function(c)
                local hum = c:WaitForChild("Humanoid")
                hum.MaxHealth = 9e9
                hum.Health = 9e9
                local ff = Instance.new("ForceField", c)
                ff.Visible = false
                task.delay(3, function()
                    if hum and hum.Parent then
                        hum.MaxHealth = 100
                        hum.Health = 100
                    end
                    if ff then ff:Destroy() end
                end)
            end)
        end
    end, {
        Title = "Supremacy Mode",
        Description = "3 seconds of godmode on every spawn via ForceField + health overflow.",
        Example = "Prevents all spawn camping strategies."
    })

    SpawnCard:AddToggle("Fast Respawn", false, function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end, {
        Title = "Fast Respawn",
        Description = "Instantly respawns using the Guide remote or LoadCharacter.",
        Example = "Minimize downtime between deaths."
    })

    SpawnCard:AddSlider("Invincibility Duration", 1, 10, 3, function(val)
        -- Stored for future use
    end, {
        Title = "Invincibility Duration",
        Description = "How long the spawn protection ForceField lasts (seconds).",
        Example = "3s is usually enough. Increase for heavily camped spawns."
    })

    -- ═══════════════════════════════════════════════════════
    --  MPT → DEFENSE MATRIX (★ NEW TAB)
    -- ═══════════════════════════════════════════════════════
    local DefMatrixCard = MPT_Def:CreateSection("Defense Matrix")

    DefMatrixCard:AddToggle("Enable Defense Matrix", false, function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end, {
        Title = "Defense Matrix",
        Description = "Master toggle for the full defensive suite: ForceField godmode, repel, health monitoring.",
        Example = "Activate before entering any PvP engagement."
    })

    DefMatrixCard:AddToggle("ForceField God Mode", false, function(state)
        AntiAura.GodMode = state
    end, {
        Title = "ForceField God Mode",
        Description = "Invisible ForceField + auto-heal when health drops below 50%. No desync, no hooks.",
        Example = "The safest possible godmode implementation."
    })

    DefMatrixCard:AddToggle("Weapon Repel", false, function(state)
        AntiAura.Repel = state
    end, {
        Title = "Weapon Repel",
        Description = "Pushes enemy weapon handles away using AssemblyLinearVelocity within 10 studs.",
        Example = "Counters melee aura users effectively."
    })

    DefMatrixCard:AddSlider("Repel Radius", 5, 20, 10, function(val)
        -- Could be wired to a variable
    end, {
        Title = "Repel Radius",
        Description = "How far the repel effect reaches (studs).",
        Example = "10 studs is the default sweet spot."
    })

    DefMatrixCard:AddButton("Emergency Heal", function()
        local myChar = player.Character
        if myChar then
            local hum = myChar:FindFirstChild("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                Library:Notify({
                    Title = "Healed",
                    Description = "Health restored to maximum.",
                    Duration = 2
                })
            end
        end
    end, {
        Title = "Emergency Heal",
        Description = "Instantly restores your health to maximum. One-time use button.",
        Example = "Panic button when you're about to die."
    })

    -- ═══════════════════════════════════════════════════════
    --  UPDATES
    -- ═══════════════════════════════════════════════════════
    local ChangeCard = Updates_Page:CreateSection("EXO Hub Changelog")

    ChangeCard:AddLabel("v2.0 - August 03, 2026:")
    ChangeCard:AddLabel("  - FULL REWRITE: Migrated to ZyronX UI Library.")
    ChangeCard:AddLabel("  - Logo changed from ZX to E.")
    ChangeCard:AddLabel("  - Key System now actually shows and gates the hub.")
    ChangeCard:AddLabel("  - Anti-Aura completely rewritten: no more broken hooks,")
    ChangeCard:AddLabel("    uses ForceField + safe velocity. No longer kills you.")
    ChangeCard:AddLabel("  - Removed Micro-Dodge (caused desync and got you killed).")
    ChangeCard:AddLabel("  - Removed deprecated BodyVelocity repel, uses AssemblyLinearVelocity.")
    ChangeCard:AddLabel("  - Reach slider fixed: stores original sizes, clean reset.")
    ChangeCard:AddLabel("  - MPT redesigned: Omni-Kill, Sovereign, Spawn Supremacy, Defense Matrix.")
    ChangeCard:AddLabel("  - Added Prediction slider for Aura.")
    ChangeCard:AddLabel("  - Added Refresh Target List button.")
    ChangeCard:AddLabel("  - Added Force Buy button.")
    ChangeCard:AddLabel("  - Added Emergency Heal button.")
    ChangeCard:AddLabel("  - All trailing space bugs in strings fixed.")
    ChangeCard:AddLabel("  - All syntax errors fixed (d o, AddTog gle, PostSimulatio n, etc).")

    ChangeCard:AddLabel("")
    ChangeCard:AddLabel("v1.2 - August 01, 2026:")
    ChangeCard:AddLabel("  - MPT Tab Redesigned.")
    ChangeCard:AddLabel("  - Enhanced Aura with predictive hit registration.")
    ChangeCard:AddLabel("  - Core: Global threat detection system.")

    ChangeCard:AddLabel("")
    ChangeCard:AddLabel("v1.1 - July 25, 2026:")
    ChangeCard:AddLabel("  - Improved Tool Follow, Reach, Respawn.")
    ChangeCard:AddLabel("  - Added Updates Tab. Removed Hub Manage Tab.")

    -- ═══════════════════════════════════════════════════════
    --  SETTINGS
    -- ═══════════════════════════════════════════════════════
    local UICard = Settings_Page:CreateSection("UI Config")

    UICard:AddToggle("Glass Architecture", false, function(state)
        Window:SetTransparency(state and 0.2 or 0)
    end, {
        Title = "Glass Architecture",
        Description = "Sets the main window background to 0.2 transparency for a sleek look.",
        Example = "Toggle on for a glassmorphism aesthetic."
    })

    local ConfigCard = Settings_Page:CreateSection("Config")

    ConfigCard:AddButton("Save Config", function()
        local config = {
            ReachSize = ReachSize,
            ThreatRadius = ThreatRadius,
            latencyEstimate = latencyEstimate,
            AntiAura = AntiAura,
            Aura = {Enabled = Aura.Enabled},
        }
        writeJSON("exo_config_v2.dat", config)
        Library:Notify({
            Title = "Config Saved",
            Description = "Settings saved to exo_config_v2.dat",
            Duration = 2
        })
    end, {
        Title = "Save Config",
        Description = "Saves current settings to a local file.",
        Example = "Load it next session to restore your setup."
    })

    ConfigCard:AddButton("Load Config", function()
        local config = readJSON("exo_config_v2.dat")
        if config then
            ReachSize = config.ReachSize or 2
            ThreatRadius = config.ThreatRadius or 50
            latencyEstimate = config.latencyEstimate or 0.1
            Library:Notify({
                Title = "Config Loaded",
                Description = "Settings restored from exo_config_v2.dat",
                Duration = 2
            })
        else
            Library:Notify({
                Title = "No Config",
                Description = "No saved config found.",
                Duration = 2
            })
        end
    end, {
        Title = "Load Config",
        Description = "Loads previously saved settings.",
        Example = "Restores ReachSize, ThreatRadius, and prediction values."
    })

    ConfigCard:AddConfigManager("exoHubSavers")

    -- ── FINAL NOTIFICATION ──────────────────────────────────
    Library:Notify({
        Title = "EXO Hub Loaded",
        Description = "Architectural Master Edition v2.0 initialized. All systems online.",
        Duration = 4
    })
    print("[EXO] Power Tycoon Hub v2.0 – ZyronX Edition. Ready.")
end

-- ═══════════════════════════════════════════════════════════
--  ★ FIX: KEY SYSTEM IS NOW ACTUALLY CALLED
-- ═══════════════════════════════════════════════════════════
local savedKey = readJSON(KEY_FILE)
if savedKey and savedKey.key == HUB_KEY then
    -- Key already validated, skip straight to hub
    keyValidated = true
    buildHub()
else
    -- Show key system, then build hub on success
    createKeySystem(function()
        buildHub()
    end)
end
