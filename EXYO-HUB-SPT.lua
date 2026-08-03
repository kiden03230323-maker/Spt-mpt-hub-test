-- ═══════════════════════════════════════════════════════════════
--  EXO HUB v4.0 – Velocity.vip UI | Power Tycoon
--  SPT + MPT Redesigned | Settings | Updates | Key System
-- ═══════════════════════════════════════════════════════════════

local library = loadstring(game:HttpGet("https://github.com/GhostDuckyy/UI-Libraries/blob/main/Velocity.vip/source.lua?raw=true"))()

-- ── SERVICES ────────────────────────────────────────────────
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local player            = Players.LocalPlayer

-- ── FILE I/O ────────────────────────────────────────────────
local HUB_KEY     = "EXOSTAKEOVERR19$"
local KEY_FILE    = "exo_key_v4.dat"
local CONFIG_DIR  = "exo_hub"

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

-- ── STATE VARIABLES ─────────────────────────────────────────
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
local IK_TargetParts    = {}

local HitAmpEnabled     = false
local HitAmpConn        = nil
local HA_CachedTools    = {}
local HA_LastActivation = 0
local HA_Accumulator    = 0

local TG_Enabled        = false
local TG_padsByBase     = {}
local TG_registered     = {}

local KillNotifEnabled  = false
local KillLogEnabled    = false
local KillLogs          = {}
local ESPEnabled        = false
local AntiLagEnabled    = false
local espDots           = {}
local espGui            = nil

-- ── DAMAGE REMOTE DETECTION ─────────────────────────────────
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

-- ── TYCOON HELPERS ──────────────────────────────────────────
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
    end
    return 0
end

local function getCost(obj)
    local pv = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if pv and (pv:IsA("IntValue") or pv:IsA("NumberValue")) then return pv.Value end
    local attr = obj:GetAttribute("Price") or obj:GetAttribute("Cost")
    if type(attr) == "number" then return attr end
    return 0
end

local function getPriority(modelName)
    local name = modelName:lower()
    if name:find("robux") then return 999 end
    local num = tonumber(name:match("%d+")) or 0
    if name:find("gen") and not name:find("gear") then
        if num <= 1 then return 10 + num elseif num <= 3 then return 30 + num
        elseif num <= 5 then return 50 + num else return 70 + num end
    end
    if name:find("gear") or name:find("gun") then
        if num <= 2 then return 20 + num elseif num <= 5 then return 55 + num
        else return 67 + num end
    end
    if name:find("wall") or name:find("door") or name:find("ladder") then return 40 + num end
    if name:find("ultima") or name:find("effect") then return 80 end
    return 90 + num
end

local function getServerPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then table.insert(list, p.Name) end
    end
    return #list > 0 and list or {"No Players"}
end

local function getToolPart(tool)
    if tool:FindFirstChild("Handle") and tool.Handle:IsA("BasePart") then return tool.Handle end
    for _, v in ipairs(tool:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end

local function getHRP(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

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

-- ── AURA & KILL ─────────────────────────────────────────────
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
                if not damagePart then damagePart = tool:FindFirstChild("Handle") end
                if not damagePart then continue end
                local origCF = damagePart.CFrame
                for _, targetPlr in ipairs(Aura.TargetList) do
                    local tChar = targetPlr.Character
                    if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                        local root = tChar:FindFirstChild("HumanoidRootPart")
                        if root then
                            local predictedPos = root.Position + root.Velocity * latencyEstimate
                            pcall(function() damagePart.CFrame = CFrame.new(predictedPos) end)
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
                    if hum and hum.Health > 0 then pcall(function() hum.Health = 0 end) end
                end
            end
        end
    end)
end
local function stopAuraLoop()
    if auraConn then auraConn:Disconnect(); auraConn = nil end
end

-- ── TOOL FOLLOW ─────────────────────────────────────────────
local cachedToolParts = {}
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
local function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect() end
    ToolFollow.Connection = RunService.PreSimulation:Connect(function()
        if not ToolFollow.Enabled or #ToolFollow.Targets == 0 then return end
        updateToolCache()
        for _, targetPlr in ipairs(ToolFollow.Targets) do
            local tChar = targetPlr.Character
            if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                local torso = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso")
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
end)
updateToolCache()

-- ── AUTO CLAIM & BUILD ──────────────────────────────────────
local function startClaimMoney()
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
local function startAutoBuild()
    if buildConn then buildConn:Disconnect() end
    buildConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
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
            if obj:IsA("Model") then
                local cost = getCost(obj)
                if cost > 0 then
                    table.insert(buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)})
                end
            end
        end
        table.sort(buttons, function(a, b)
            if a.Priority == b.Priority then return a.Cost < b.Cost end
            return a.Priority < b.Priority
        end)
        for _, btnData in ipairs(buttons) do
            if cash >= btnData.Cost then
                for _, part in ipairs(getTouchableParts(btnData.Model)) do
                    pcall(firetouchinterest, root, part, 0)
                    pcall(firetouchinterest, root, part, 1)
                end
                lastBuyTime = tick()
                break
            end
        end
    end)
end
local function stopAutoBuild()
    if buildConn then buildConn:Disconnect(); buildConn = nil end
end

-- ── ANTI-AURA (SAFE) ───────────────────────────────────────
local function startAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect() end
    antiAuraConn = RunService.Heartbeat:Connect(function()
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
            if hum.Health < hum.MaxHealth * 0.5 then hum.Health = hum.MaxHealth end
        else
            if antiAuraFF and antiAuraFF.Parent then antiAuraFF:Destroy(); antiAuraFF = nil end
        end
        if AntiAura.Repel then
            for _, otherPlr in ipairs(Players:GetPlayers()) do
                if otherPlr ~= player and otherPlr.Character then
                    for _, tool in ipairs(otherPlr.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                local dist = (handle.Position - root.Position).Magnitude
                                if dist < 10 then
                                    local dir = (root.Position - handle.Position).Unit
                                    pcall(function() handle.AssemblyLinearVelocity = dir * 60 end)
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

-- ── REACH ───────────────────────────────────────────────────
local reachOriginalSizes = {}
local reachHL = {}
local function applyReach()
    local myChar = player.Character
    if not myChar then return end
    for _, t in ipairs(myChar:GetChildren()) do
        if t:IsA("Tool") then
            local part = getToolPart(t)
            if part then
                if not reachOriginalSizes[part] then reachOriginalSizes[part] = part.Size end
                part.Size = reachOriginalSizes[part] * ReachSize
                part.Massless = true
                if not reachHL[part] then
                    local hl = Instance.new("Highlight", part)
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                    reachHL[part] = hl
                end
            end
        end
    end
end
local function stopReach()
    for part, hl in pairs(reachHL) do if hl and hl.Parent == part then hl:Destroy() end end
    table.clear(reachHL)
    for part, origSize in pairs(reachOriginalSizes) do
        if part and part.Parent then part.Size = origSize end
    end
    table.clear(reachOriginalSizes)
end

-- ── FAST RESPAWN ────────────────────────────────────────────
local function startFastRespawn()
    local Guide = ReplicatedStorage:FindFirstChild("Guide")
    local last = 0
    local function respawn()
        if tick() - last < 0.05 then return end
        last = tick()
        pcall(function()
            if Guide then Guide:FireServer() else player:LoadCharacter() end
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

-- ── INSTA-KILL MICRO-BURST ─────────────────────────────────
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
        if part and part:IsA("BasePart") then table.insert(IK_TargetParts, part) end
    end
    if #IK_TargetParts == 0 then return end
    for _, toolData in ipairs(IK_ToolsCache) do
        local tool = toolData.Tool
        local fight = toolData.FightEvent
        local touch = toolData.TouchPart
        if tool and tool.Parent then
            if fight then
                pcall(function() for _ = 1, burstCount do fight:FireServer() end end)
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
        if target then IK_MicroBurst(target, 5) end
    end)
end
local function stopInstaKill()
    if InstaKillConn then InstaKillConn:Disconnect(); InstaKillConn = nil end
end

-- ── HIT AMPLIFIER ───────────────────────────────────────────
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
                if hum and hum.Health > 0 and model ~= char then hasTarget = true; break end
            end
        end
        if hasTarget then
            HA_LastActivation = now
            for _, data in ipairs(HA_CachedTools) do
                if data.FightEvent then
                    pcall(function() for _ = 1, 3 do data.FightEvent:FireServer() end end)
                else
                    pcall(data.Tool.Activate, data.Tool)
                end
            end
        end
    end)
end
local function stopHitAmplifier()
    if HitAmpConn then HitAmpConn:Disconnect(); HitAmpConn = nil end
end

-- ── TOOL GRABBER ────────────────────────────────────────────
local TG_TOOL_RULES = {
    {Pattern = "Energy Sword", Base = "Stone"},
    {Pattern = "Staff", Base = "Magic"},
    {Pattern = "Axe", Base = "Storm"},
    {Pattern = "Fist", Base = "Robotic"},
}
local TG_ALLOWED = {Stone=true, Magic=true, Storm=true, Robotic=true}
local TG_EXCLUDED = {Insanity=true, Giant=true, Dark=true, Spike=true, Web=true, Strong=true}

local function TG_ScanTycoons()
    local Tycoons = workspace:FindFirstChild("Tycoons")
    if not Tycoons then return end
    for _, obj in ipairs(Tycoons:GetDescendants()) do
        if obj:IsA("BasePart") and obj:FindFirstChildOfClass("TouchTransmitter") then
            local giver = obj.Parent
            while giver and giver ~= workspace do
                if giver.Name == "GearGiver1" then break end
                giver = giver.Parent
            end
            if giver and giver.Name == "GearGiver1" then
                local base = giver.Parent
                if base and TG_ALLOWED[base.Name] and not TG_EXCLUDED[base.Name] then
                    if not TG_registered[obj] then
                        TG_registered[obj] = base.Name
                        TG_padsByBase[base.Name] = TG_padsByBase[base.Name] or {}
                        table.insert(TG_padsByBase[base.Name], obj)
                    end
                end
            end
        end
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

-- ── KILL NOTIFICATIONS ──────────────────────────────────────
local function analyzeKill(killer, weaponName, distance)
    local suspected = {}
    local counter = {}
    local threat = 1
    if distance > 30 then
        table.insert(suspected, "Reach/Aura")
        table.insert(counter, "Anti-Aura + Repel")
        threat = threat + 3
    end
    if distance < 5 then
        table.insert(suspected, "Close combat")
        table.insert(counter, "Repel")
        threat = threat + 1
    end
    if weaponName == "Unknown" then
        table.insert(suspected, "Remote spam")
        table.insert(counter, "God Mode")
        threat = threat + 3
    end
    threat = math.clamp(threat, 1, 10)
    if threat >= 10 then table.insert(counter, "ENABLE ANTI-SPAWNKILL NOW") end
    return {Killer=killer, Weapon=weaponName, Distance=math.floor(distance),
            Suspected=suspected, Counter=counter, Threat=threat, Time=os.date("%H:%M:%S")}
end

local function setupKillNotifications()
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            if not KillNotifEnabled then return end
            local creator = hum:FindFirstChild("creator")
            local killerName, weaponName, distance = "Unknown", "Unknown", 0
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
                        if tool:IsA("Tool") then weaponName = tool.Name; break end
                    end
                end
            end
            local analysis = analyzeKill(killerName, weaponName, distance)
            if KillNotifEnabled then
                library.notify("KILL: " .. analysis.Killer .. " | " .. analysis.Weapon .. " | Threat: " .. analysis.Threat .. "/10")
            end
            if KillLogEnabled then
                table.insert(KillLogs, analysis)
                if #KillLogs > 50 then table.remove(KillLogs, 1) end
            end
        end)
    end)
end

-- ── ESP ─────────────────────────────────────────────────────
local function startESP()
    if espGui then return end
    espGui = Instance.new("ScreenGui")
    espGui.Name = "EXO_ESP"
    espGui.ResetOnSpawn = false
    pcall(function() espGui.Parent = CoreGui end)
    if not espGui.Parent then espGui.Parent = player:WaitForChild("PlayerGui") end
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
        if espDots[plr] then espDots[plr]:Destroy(); espDots[plr] = nil end
    end)
    RunService.RenderStepped:Connect(function()
        if not ESPEnabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        for plr, dot in pairs(espDots) do
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = cam:WorldToViewportPoint(char.HumanoidRootPart.Position)
                dot.Position = UDim2.new(0, pos.X - 4, 0, pos.Y - 4)
                dot.Visible = onScreen
            else
                dot.Visible = false
            end
        end
    end)
end
local function stopESP()
    if espGui then espGui:Destroy(); espGui = nil end
    table.clear(espDots)
end

-- ── ANTI-LAG ────────────────────────────────────────────────
local function startAntiLag()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then obj.Enabled = false end
        end
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = false end
        end
    end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end
local function stopAntiLag()
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = true end
        end
    end)
end

-- ── AUTO GRAB TOOLS (SPT) ──────────────────────────────────
local toolToBase = {["Energy Sword"]="Stone",["Staff"]="Magic",["Axe"]="Storm",["Fist"]="Robotic"}
local padsByBase = {}
local TycoonsFolder = workspace:FindFirstChild("Tycoons")
if TycoonsFolder then
    for _, d in ipairs(TycoonsFolder:GetDescendants()) do
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
            and d.Parent.Parent.Name:find("GearGiver1") then
            local base = d.Parent.Parent.Parent
            if base then
                padsByBase[base.Name] = padsByBase[base.Name] or {}
                table.insert(padsByBase[base.Name], d.Parent)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
--  BUILD THE HUB UI (VELOCITY)
-- ═══════════════════════════════════════════════════════════
local function buildHub()

    local ui = {}
    ui.window = library.init_window("EXO Hub", {
        size = Vector2.new(650, 500),
        name = "EXO Hub | Power Tycoon v4.0",
        drag_tween = true
    })

    ui.pages = {}
    ui.pages.spt_combat   = ui.window.create_page(ui.window, {name = "SPT Combat"})
    ui.pages.spt_tycoon   = ui.window.create_page(ui.window, {name = "SPT Tycoon"})
    ui.pages.spt_misc     = ui.window.create_page(ui.window, {name = "SPT Misc"})
    ui.pages.mpt_kill     = ui.window.create_page(ui.window, {name = "MPT Kill"})
    ui.pages.mpt_economy  = ui.window.create_page(ui.window, {name = "MPT Economy"})
    ui.pages.updates      = ui.window.create_page(ui.window, {name = "Updates"})
    ui.pages.settings     = ui.window.create_page(ui.window, {name = "Settings"})

    ui.pages.spt_combat:set_default()

    -- ═══════════════════════════════════════════════════════
    --  SPT COMBAT PAGE
    -- ═══════════════════════════════════════════════════════
    do
        local aura_section = ui.pages.spt_combat:new_section({name = "multi-target aura", side = "left", size = 220})

        aura_section:new_toggle({name = "enable aura", risky = true, flag = "spt_aura_enabled", callback = function()
            Aura.Enabled = library.flags.spt_aura_enabled
            if Aura.Enabled then
                Aura.TargetList = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then table.insert(Aura.TargetList, plr) end
                end
                startAuraLoop()
                library.notify("Aura activated - targeting " .. #Aura.TargetList .. " players")
            else
                stopAuraLoop()
            end
        end})

        aura_section:new_toggle({name = "instant kill", risky = true, flag = "spt_instant_kill", callback = function()
            InstantKill = library.flags.spt_instant_kill
        end})

        aura_section:new_slider({name = "prediction offset", min = 5, max = 25, default = 10, flag = "spt_prediction", callback = function()
            latencyEstimate = library.flags.spt_prediction / 100
        end})

        aura_section:new_dropdown({name = "aura targets", options = getServerPlayers(), flag = "spt_aura_targets", callback = function()
            -- Dropdown selection handled via flags
        end})

        local toolfollow_section = ui.pages.spt_combat:new_section({name = "tool follow", side = "right", size = 180})

        toolfollow_section:new_toggle({name = "enable tool follow", risky = true, flag = "spt_toolfollow_enabled", callback = function()
            ToolFollow.Enabled = library.flags.spt_toolfollow_enabled
            if ToolFollow.Enabled then
                ToolFollow.Targets = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then table.insert(ToolFollow.Targets, plr) end
                end
                startToolFollow()
            else
                stopToolFollow()
            end
        end})

        local defense_section = ui.pages.spt_combat:new_section({name = "defense / anti-aura", side = "right", size = 200})

        defense_section:new_toggle({name = "enable anti-aura", risky = false, flag = "spt_antiaura_enabled", callback = function()
            AntiAura.Enabled = library.flags.spt_antiaura_enabled
            if AntiAura.Enabled then startAntiAura() else stopAntiAura() end
        end})

        defense_section:new_toggle({name = "god mode (forcefield)", risky = false, flag = "spt_godmode", callback = function()
            AntiAura.GodMode = library.flags.spt_godmode
        end})

        defense_section:new_toggle({name = "repel (anti-touch)", risky = false, flag = "spt_repel", callback = function()
            AntiAura.Repel = library.flags.spt_repel
        end})

        defense_section:new_toggle({name = "anti spawnkill", risky = false, flag = "spt_antispawnkill", callback = function()
            AntiSpawnkill = library.flags.spt_antispawnkill
            if AntiSpawnkill then
                player.CharacterAdded:Connect(function(c)
                    local hum = c:WaitForChild("Humanoid")
                    hum.MaxHealth = 9e9; hum.Health = 9e9
                    local ff = Instance.new("ForceField", c); ff.Visible = false
                    task.delay(3, function()
                        if hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end
                        if ff then ff:Destroy() end
                    end)
                end)
            end
        end})
    end

    -- ═══════════════════════════════════════════════════════
    --  SPT TYCOON PAGE
    -- ═══════════════════════════════════════════════════════
    do
        local tycoon_section = ui.pages.spt_tycoon:new_section({name = "tycoon automation", side = "left", size = 180})

        tycoon_section:new_toggle({name = "auto claim money", risky = false, flag = "spt_autoclaim", callback = function()
            AutoClaimMoney = library.flags.spt_autoclaim
            if AutoClaimMoney then startClaimMoney() else stopClaimMoney() end
        end})

        tycoon_section:new_toggle({name = "smart auto build", risky = false, flag = "spt_autobuild", callback = function()
            AutoBuild = library.flags.spt_autobuild
            if AutoBuild then startAutoBuild() else stopAutoBuild() end
        end})

        tycoon_section:new_toggle({name = "auto grab weapons", risky = false, flag = "spt_autograb", callback = function()
            AutoGetTools = library.flags.spt_autograb
            if AutoGetTools then
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
        end})

        local cooldown_section = ui.pages.spt_tycoon:new_section({name = "tools & cooldown", side = "right", size = 180})

        cooldown_section:new_toggle({name = "auto use tools (0 delay)", risky = true, flag = "spt_autotools", callback = function()
            AutoTools = library.flags.spt_autotools
            if AutoTools then
                toolLoopConn = RunService.RenderStepped:Connect(function()
                    if not AutoTools then return end
                    local myChar = player.Character
                    if not myChar then return end
                    for _, t in ipairs(myChar:GetChildren()) do
                        if t:IsA("Tool") then pcall(function() t:Activate() end) end
                    end
                    for _, t in ipairs(player.Backpack:GetChildren()) do
                        if t:IsA("Tool") then t.Parent = myChar; pcall(function() t:Activate() end) end
                    end
                end)
            else
                if toolLoopConn then toolLoopConn:Disconnect(); toolLoopConn = nil end
            end
        end})

        cooldown_section:new_toggle({name = "no cooldown", risky = true, flag = "spt_nocooldown", callback = function()
            NoCooldown = library.flags.spt_nocooldown
            if NoCooldown and not getgenv().NoCooldownHooked then
                hookfunction(wait, function() return RunService.PostSimulation:Wait() end)
                hookfunction(task.wait, function() return RunService.PostSimulation:Wait() end)
                hookfunction(delay, function(_, func) task.spawn(func) end)
                hookfunction(spawn, function(func) task.spawn(func) end)
                getgenv().NoCooldownHooked = true
            end
        end})
    end

    -- ═══════════════════════════════════════════════════════
    --  SPT MISC PAGE
    -- ═══════════════════════════════════════════════════════
    do
        local reach_section = ui.pages.spt_misc:new_section({name = "reach", side = "left", size = 160})

        reach_section:new_toggle({name = "enable reach", risky = true, flag = "spt_reach_enabled", callback = function()
            Reach = library.flags.spt_reach_enabled
            if Reach then applyReach() else stopReach() end
        end})

        reach_section:new_slider({name = "reach size", min = 1, max = 10, default = 2, flag = "spt_reach_size", callback = function()
            ReachSize = library.flags.spt_reach_size
            if Reach then stopReach(); applyReach() end
        end})

        local respawn_section = ui.pages.spt_misc:new_section({name = "respawn & protection", side = "left", size = 120})

        respawn_section:new_toggle({name = "fast respawn", risky = false, flag = "spt_fastrespawn", callback = function()
            FastRespawn = library.flags.spt_fastrespawn
            if FastRespawn then startFastRespawn() end
        end})

        local utils_section = ui.pages.spt_misc:new_section({name = "utilities", side = "right", size = 160})

        utils_section:new_textbox({placeholder = "damage remote path", flag = "spt_remote_path"})

        utils_section:new_button({name = "set damage remote", confirm = false, callback = function()
            local text = library.flags.spt_remote_path
            if text and text ~= "" then
                local ok, remote = pcall(function() return loadstring("return " .. text)() end)
                if ok and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                    DAMAGE_REMOTE = remote
                    library.notify("Damage remote set successfully")
                else
                    library.notify("Invalid remote path")
                end
            end
        end})

        utils_section:new_button({name = "open game dumper", confirm = false, callback = function()
            library.notify("Game Dumper opened - check CoreGui")
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
            titleLbl.Text = "GAME SCANNER"
            titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
            titleLbl.Font = Enum.Font.GothamBold
            titleLbl.TextSize = 18
            local scroll = Instance.new("ScrollingFrame", frame)
            scroll.Size = UDim2.new(1,-10,1,-80)
            scroll.Position = UDim2.new(0,5,0,40)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 8
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            local listLayout = Instance.new("UIListLayout", scroll)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0,2)
            local function addLog(text, color)
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
            local function scan(container, depth)
                for _, child in ipairs(container:GetChildren()) do
                    local indent = string.rep("  ", depth)
                    local icon = ""
                    if child:IsA("Folder") then icon = "[Folder] "
                    elseif child:IsA("Tool") then icon = "[Tool] "
                    elseif child:IsA("Model") then icon = "[Model] "
                    elseif child:IsA("RemoteEvent") then icon = "[Remote] "
                    end
                    if icon ~= "" then
                        addLog(indent .. icon .. child.Name, Color3.fromRGB(200,200,255))
                        if child:IsA("Folder") then scan(child, depth + 1) end
                    end
                end
            end
            addLog("--- WORKSPACE ---", Color3.fromRGB(100,200,255)); scan(workspace, 0)
            addLog("--- REPLICATEDSTORAGE ---", Color3.fromRGB(100,200,255)); scan(ReplicatedStorage, 0)
            addLog("SCAN COMPLETE", Color3.fromRGB(100,255,255))
        end})
    end

    -- ═══════════════════════════════════════════════════════
    --  MPT KILL PAGE
    -- ═══════════════════════════════════════════════════════
    do
        local omni_section = ui.pages.mpt_kill:new_section({name = "omni-kill engine", side = "left", size = 240})

        omni_section:new_toggle({name = "enable omni-kill", risky = true, flag = "mpt_omnikill", callback = function()
            Aura.Enabled = library.flags.mpt_omnikill
            InstantKill = library.flags.mpt_omnikill
            if Aura.Enabled then
                Aura.TargetList = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then table.insert(Aura.TargetList, plr) end
                end
                startAuraLoop()
                library.notify("OMNI-KILL ENGAGED - " .. #Aura.TargetList .. " targets")
            else
                stopAuraLoop()
            end
        end})

        omni_section:new_toggle({name = "insta-kill micro-burst", risky = true, flag = "mpt_instakill", callback = function()
            InstaKillEnabled = library.flags.mpt_instakill
            if InstaKillEnabled then startInstaKill() else stopInstaKill() end
        end})

        omni_section:new_slider({name = "prediction aggression", min = 5, max = 25, default = 10, flag = "mpt_prediction", callback = function()
            latencyEstimate = library.flags.mpt_prediction / 100
        end})

        omni_section:new_button({name = "manual kill burst", confirm = false, callback = function()
            local orig = Aura.Enabled
            Aura.Enabled = true; InstantKill = true
            task.wait(0.15)
            Aura.Enabled = orig
            if not orig then InstantKill = false end
            library.notify("Kill burst fired")
        end})

        omni_section:new_button({name = "refresh target list", confirm = false, callback = function()
            table.clear(Aura.TargetList)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            library.notify("Targets refreshed: " .. #Aura.TargetList .. " players")
        end})

        local hitamp_section = ui.pages.mpt_kill:new_section({name = "hit amplifier", side = "right", size = 160})

        hitamp_section:new_toggle({name = "enable hit amplifier", risky = true, flag = "mpt_hitamp", callback = function()
            HitAmpEnabled = library.flags.mpt_hitamp
            if HitAmpEnabled then startHitAmplifier() else stopHitAmplifier() end
        end})

        local arsenal_section = ui.pages.mpt_kill:new_section({name = "tool arsenal", side = "right", size = 180})

        arsenal_section:new_toggle({name = "enable tool arsenal", risky = false, flag = "mpt_toolarsenal", callback = function()
            TG_Enabled = library.flags.mpt_toolarsenal
            if TG_Enabled then
                TG_ScanTycoons()
                if not getgenv().EXO_TG_Loop then
                    getgenv().EXO_TG_Loop = true
                    task.spawn(function()
                        while getgenv().EXO_TG_Loop do
                            if TG_Enabled then
                                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    for _, rule in ipairs(TG_TOOL_RULES) do
                                        if not TG_HasTool(rule.Pattern) then
                                            local pad = TG_GetClosestPad(rule.Base)
                                            if pad then
                                                for _ = 1, 5 do
                                                    pcall(firetouchinterest, root, pad, 0)
                                                    pcall(firetouchinterest, root, pad, 1)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            task.wait(0.1)
                        end
                    end)
                end
            else
                getgenv().EXO_TG_Loop = false
            end
        end})

        arsenal_section:new_button({name = "force acquire all", confirm = false, callback = function()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                TG_ScanTycoons()
                for _, baseName in ipairs({"Stone","Magic","Storm","Robotic"}) do
                    local pad = TG_GetClosestPad(baseName)
                    if pad then
                        for _ = 1, 8 do
                            pcall(firetouchinterest, root, pad, 0)
                            pcall(firetouchinterest, root, pad, 1)
                        end
                    end
                end
                library.notify("Force acquire burst fired")
            end
        end})
    end

    -- ═══════════════════════════════════════════════════════
    --  MPT ECONOMY PAGE
    -- ═══════════════════════════════════════════════════════
    do
        local sov_section = ui.pages.mpt_economy:new_section({name = "tycoon sovereign", side = "left", size = 200})

        sov_section:new_toggle({name = "enable sovereign economy", risky = false, flag = "mpt_sovereign", callback = function()
            AutoClaimMoney = library.flags.mpt_sovereign
            AutoBuild = library.flags.mpt_sovereign
            if AutoClaimMoney then startClaimMoney(); startAutoBuild()
            else stopClaimMoney(); stopAutoBuild() end
        end})

        sov_section:new_slider({name = "defense threat radius", min = 20, max = 100, default = 50, flag = "mpt_threatradius", callback = function()
            ThreatRadius = library.flags.mpt_threatradius
        end})

        sov_section:new_button({name = "force buy next upgrade", confirm = false, callback = function()
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
                    if cost > 0 and cost <= cash and pri < bestPri then best = obj; bestPri = pri end
                end
            end
            if best then
                for _, part in ipairs(getTouchableParts(best)) do
                    pcall(firetouchinterest, root, part, 0)
                    pcall(firetouchinterest, root, part, 1)
                end
                library.notify("Purchased: " .. best.Name)
            else
                library.notify("Nothing affordable")
            end
        end})

        local spawn_section = ui.pages.mpt_economy:new_section({name = "spawn supremacy", side = "right", size = 160})

        spawn_section:new_toggle({name = "enable supremacy mode", risky = false, flag = "mpt_supremacy", callback = function()
            AntiSpawnkill = library.flags.mpt_supremacy
            if AntiSpawnkill then
                player.CharacterAdded:Connect(function(c)
                    local hum = c:WaitForChild("Humanoid")
                    hum.MaxHealth = 9e9; hum.Health = 9e9
                    local ff = Instance.new("ForceField", c); ff.Visible = false
                    task.delay(3, function()
                        if hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end
                        if ff then ff:Destroy() end
                    end)
                end)
            end
        end})

        spawn_section:new_toggle({name = "fast respawn", risky = false, flag = "mpt_fastrespawn", callback = function()
            FastRespawn = library.flags.mpt_fastrespawn
            if FastRespawn then startFastRespawn() end
        end})

        local def_section = ui.pages.mpt_economy:new_section({name = "defense matrix", side = "right", size = 200})

        def_section:new_toggle({name = "enable defense matrix", risky = false, flag = "mpt_defense", callback = function()
            AntiAura.Enabled = library.flags.mpt_defense
            if AntiAura.Enabled then startAntiAura() else stopAntiAura() end
        end})

        def_section:new_toggle({name = "forcefield god mode", risky = false, flag = "mpt_godmode", callback = function()
            AntiAura.GodMode = library.flags.mpt_godmode
        end})

        def_section:new_toggle({name = "weapon repel", risky = false, flag = "mpt_repel", callback = function()
            AntiAura.Repel = library.flags.mpt_repel
        end})

        def_section:new_button({name = "emergency heal", confirm = false, callback = function()
            local myChar = player.Character
            if myChar then
                local hum = myChar:FindFirstChild("Humanoid")
                if hum then
                    hum.Health = hum.MaxHealth
                    library.notify("Health restored")
                end
            end
        end})
    end

    -- ═══════════════════════════════════════════════════════
    --  UPDATES PAGE
    -- ═══════════════════════════════════════════════════════
    do
        local changelog_section = ui.pages.updates:new_section({name = "exo hub changelog", side = "left", size = 400})

        changelog_section:new_button({name = "v4.0 - velocity ui edition", confirm = false, callback = function()
            library.notify("v4.0: Velocity UI, all features working, key system fixed")
        end})
        changelog_section:new_button({name = "v3.0 - embedded ui attempt", confirm = false, callback = function()
            library.notify("v3.0: Embedded UI engine, mobile compatible")
        end})
        changelog_section:new_button({name = "v2.0 - zyronx migration", confirm = false, callback = function()
            library.notify("v2.0: ZyronX UI (capped), syntax fixes")
        end})
        changelog_section:new_button({name = "v1.1 - initial release", confirm = false, callback = function()
            library.notify("v1.1: FluentPro, basic features")
        end})
    end

    -- ═══════════════════════════════════════════════════════
    --  SETTINGS PAGE
    -- ═══════════════════════════════════════════════════════
    do
        local ui_section = ui.pages.settings:new_section({name = "ui config", side = "left", size = 200})

        ui_section:new_colorpicker({name = "menu accent", default = Color3.fromRGB(190, 140, 255), flag = "ui_accent", callback = function()
            library:ChangeThemeOption("Accent", library.flags.ui_accent)
        end})

        ui_section:new_keybind({name = "open / close", default = Enum.KeyCode.End, mode = "Toggle", flag = "ui_toggle_key", callback = function()
            library:SetOpen(library.flags.ui_toggle_key)
        end})

        local general_section = ui.pages.settings:new_section({name = "general", side = "left", size = 250})

        general_section:new_toggle({name = "anti-lag shield", risky = false, flag = "settings_antilag", callback = function()
            AntiLagEnabled = library.flags.settings_antilag
            if AntiLagEnabled then startAntiLag() else stopAntiLag() end
        end})

        general_section:new_toggle({name = "esp (minimal dots)", risky = false, flag = "settings_esp", callback = function()
            ESPEnabled = library.flags.settings_esp
            if ESPEnabled then startESP() else stopESP() end
        end})

        general_section:new_toggle({name = "kill notifications", risky = false, flag = "settings_killnotif", callback = function()
            KillNotifEnabled = library.flags.settings_killnotif
        end})

        general_section:new_toggle({name = "kill logs", risky = false, flag = "settings_killlog", callback = function()
            KillLogEnabled = library.flags.settings_killlog
        end})

        local config_section = ui.pages.settings:new_section({name = "configuration", side = "right", size = 200})

        config_section:new_button({name = "save config", confirm = false, callback = function()
            local config = ui.window:get_config()
            writeJSON(CONFIG_DIR .. "_config.dat", {config = tostring(config)})
            library.notify("Config saved")
        end})

        config_section:new_button({name = "load config", confirm = false, callback = function()
            local data = readJSON(CONFIG_DIR .. "_config.dat")
            if data and data.config then
                library.notify("Config loaded")
            else
                library.notify("No config found")
            end
        end})

        config_section:new_button({name = "rejoin server", confirm = true, callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end})
    end

    -- SETUP KILL NOTIFICATIONS
    setupKillNotifications()

    -- OPEN UI
    library:SetOpen(true)
    library.notify("EXO Hub v4.0 loaded - Velocity UI Edition")
end

-- ── KEY SYSTEM ──────────────────────────────────────────────
local function createKeySystem(onSuccess)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ExoKeySystem"
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.4
    overlay.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0,420,0,300)
    card.Position = UDim2.new(0.5,-210,0.5,-150)
    card.BackgroundColor3 = Color3.fromRGB(15,15,18)
    card.BorderSizePixel = 0
    card.Parent = gui
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,12)
    Instance.new("UIStroke",card).Color = Color3.fromRGB(190,140,255)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-20,0,40)
    title.Position = UDim2.new(0,10,0,10)
    title.BackgroundTransparency = 1
    title.Text = "EXO | Key Authentication"
    title.TextColor3 = Color3.fromRGB(240,240,245)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1,-40,0,30)
    desc.Position = UDim2.new(0,20,0,55)
    desc.BackgroundTransparency = 1
    desc.Text = "Enter your premium key to access the hub."
    desc.TextColor3 = Color3.fromRGB(160,160,175)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 13
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = card

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1,-40,0,44)
    inputBg.Position = UDim2.new(0,20,0,100)
    inputBg.BackgroundColor3 = Color3.fromRGB(22,22,26)
    inputBg.BorderSizePixel = 0
    inputBg.Parent = card
    Instance.new("UICorner",inputBg).CornerRadius = UDim.new(0,8)

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
    btn.Size = UDim2.new(1,-40,0,44)
    btn.Position = UDim2.new(0,20,0,160)
    btn.BackgroundColor3 = Color3.fromRGB(190,140,255)
    btn.Text = "AUTHENTICATE"
    btn.TextColor3 = Color3.fromRGB(20,20,20)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = card
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,-40,0,20)
    status.Position = UDim2.new(0,20,0,215)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(220,50,50)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 12
    status.Parent = card

    btn.MouseButton1Click:Connect(function()
        if input.Text == HUB_KEY then
            writeJSON(KEY_FILE, {key = HUB_KEY, time = os.time()})
            status.Text = "Success. Loading Hub..."
            status.TextColor3 = Color3.fromRGB(50,200,100)
            btn.BackgroundColor3 = Color3.fromRGB(50,200,100)
            task.wait(1)
            gui:Destroy()
            if onSuccess then onSuccess() end
        else
            status.Text = "Invalid Key."
            input.Text = ""
        end
    end)
    input.FocusLost:Connect(function(enter)
        if enter then btn.MouseButton1Click:Fire() end
    end)
end

-- ── ENTRY POINT ─────────────────────────────────────────────
local savedKey = readJSON(KEY_FILE)
if savedKey and savedKey.key == HUB_KEY then
    buildHub()
else
    createKeySystem(function()
        buildHub()
    end)
end
