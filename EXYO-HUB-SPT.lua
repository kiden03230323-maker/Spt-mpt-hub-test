-- ═══════════════════════════════════════════════════════════════
--  EXO HUB v6.0 – GODLY TIER | WindUI | Protected Build
--  Fixes: No KeySystem hang | Deferred scans | Full-power features
-- ═══════════════════════════════════════════════════════════════

-- ── ANTI-TAMPER INTEGRITY CHECK ─────────────────────────────
local _EXO_INTEGRITY = true
local _EXO_CHECKSUM = 0x45584F
pcall(function()
    if not game or not game:GetService then _EXO_INTEGRITY = false end
    if not Players then _EXO_INTEGRITY = false end
end)
if not _EXO_INTEGRITY then return end

-- ── LOAD WINDUI ─────────────────────────────────────────────
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/raw/main/dist/main.lua"))()

-- ── SERVICES ────────────────────────────────────────────────
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")
local player            = Players.LocalPlayer

-- ── ENCODED KEY (XOR obfuscated) ───────────────────────────
local function _exo_decode(encoded, key)
    local result = {}
    for i = 1, #encoded do
        result[i] = string.char(encoded:byte(i) ~ key:byte(((i - 1) % #key) + 1))
    end
    return table.concat(result)
end
local _EXO_KEY_ENC = string.char(69,88,79,83,84,65,75,69,79,86,69,82,82,49,57,36)
local HUB_KEY = _exo_decode(_EXO_KEY_ENC, "X")
local KEY_FILE = "exo_v6_k.dat"
local CONFIG_FILE = "exo_v6_cfg.dat"

-- ── FILE I/O ────────────────────────────────────────────────
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

-- ── STATE ───────────────────────────────────────────────────
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

-- ── PRE-ALLOCATED BUFFERS (zero GC pressure) ───────────────
local _buf_parts     = {}
local _buf_buttons   = {}
local _buf_wave      = {}
local _buf_targets   = {}

-- ── DEFERRED HEAVY SCANS (non-blocking) ────────────────────
local scansComplete = false

task.spawn(function()
    -- Damage remote detection
    for _, container in ipairs({ReplicatedStorage, workspace}) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:match("damage") or n:match("hit") or n:match("attack") or n:match("deal") then
                    DAMAGE_REMOTE = obj
                    break
                end
            end
        end
        if DAMAGE_REMOTE then break end
    end

    -- Pad registration
    local TycoonsFolder = workspace:FindFirstChild("Tycoons")
    if TycoonsFolder then
        for _, d in ipairs(TycoonsFolder:GetDescendants()) do
            if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
                and d.Parent.Parent.Name:find("GearGiver1") then
                local base = d.Parent.Parent.Parent
                if base then
                    local bn = base.Name
                    if bn == "Stone" or bn == "Magic" or bn == "Storm" or bn == "Robotic" then
                        TG_padsByBase[bn] = TG_padsByBase[bn] or {}
                        table.insert(TG_padsByBase[bn], d.Parent)
                        TG_registered[d.Parent] = bn
                    end
                end
            end
        end
    end

    scansComplete = true
end)

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
    table.clear(_buf_parts)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            table.insert(_buf_parts, desc.Parent)
        end
    end
    if #_buf_parts == 0 then
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("BasePart") then table.insert(_buf_parts, desc); break end
        end
    end
    return _buf_parts
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

-- ── GODLY AURA (Full power, zero lag via caching) ──────────
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
        table.clear(_buf_buttons)
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local cost = getCost(obj)
                if cost > 0 then
                    table.insert(_buf_buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)})
                end
            end
        end
        table.sort(_buf_buttons, function(a, b)
            if a.Priority == b.Priority then return a.Cost < b.Cost end
            return a.Priority < b.Priority
        end)
        for _, btnData in ipairs(_buf_buttons) do
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

-- ── ANTI-AURA (SAFE – ForceField based) ────────────────────
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

-- ── REACH (Original size storage) ──────────────────────────
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

-- ── INSTA-KILL MICRO-BURST (GODLY – full 60Hz) ─────────────
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

-- ── HIT AMPLIFIER (GODLY – 120Hz scan, 15ms cooldown) ──────
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

-- ── TOOL GRABBER (GODLY – wave system) ─────────────────────
local TG_TOOL_RULES = {
    {Pattern = "Energy Sword", Base = "Stone"},
    {Pattern = "Staff", Base = "Magic"},
    {Pattern = "Axe", Base = "Storm"},
    {Pattern = "Fist", Base = "Robotic"},
}

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
                WindUI:Notify({
                    Title = "KILL DETECTED - Threat " .. analysis.Threat .. "/10",
                    Content = "Killer: " .. analysis.Killer .. "\nWeapon: " .. analysis.Weapon
                        .. "\nDist: " .. analysis.Distance .. " studs"
                        .. "\nSuspected: " .. table.concat(analysis.Suspected, ", ")
                        .. "\nCounter: " .. table.concat(analysis.Counter, " | "),
                    Duration = 6,
                    Icon = "alert-triangle",
                })
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

-- ═══════════════════════════════════════════════════════════
--  BUILD WINDUI (NO KEYSYSTEM – non-blocking key gate)
-- ═══════════════════════════════════════════════════════════

local Window = WindUI:CreateWindow({
    Title = "EXO Hub",
    Icon = "swords",
    Author = "Power Tycoon | v6.0 GODLY",
    Folder = "EXOHub",
    Size = UDim2.fromOffset(650, 500),
    Transparent = false,
    Theme = "Default",
    SideBarWidth = 170,
    HasOutline = true,
    -- ★ NO KeySystem – prevents UI thread hang
})

Window:EditOpenButton({
    Enabled = true,
    Image = "swords",
    Title = "E",
    CornerRadius = UDim.new(1, 0),
    StrokeThickness = 2,
    Side = "Left",
})

-- ── TABS (NO :Show() CALL) ─────────────────────────────────
local SPT_Combat_Tab   = Window:Tab({Title = "SPT Combat", Icon = "swords"})
local SPT_Tycoon_Tab   = Window:Tab({Title = "SPT Tycoon", Icon = "building-2"})
local SPT_Misc_Tab     = Window:Tab({Title = "SPT Misc", Icon = "move"})
local MPT_Kill_Tab     = Window:Tab({Title = "MPT Kill", Icon = "skull"})
local MPT_Economy_Tab  = Window:Tab({Title = "MPT Economy", Icon = "crown"})
local Updates_Tab      = Window:Tab({Title = "Updates", Icon = "scroll-text"})
local Settings_Tab     = Window:Tab({Title = "Settings", Icon = "settings"})

-- ═══════════════════════════════════════════════════════════
--  SPT COMBAT
-- ═══════════════════════════════════════════════════════════
do
    local AuraSec = SPT_Combat_Tab:Section({Title = "Multi-Target Aura"})
    AuraSec:Toggle({Title = "Enable Aura", Default = false, Callback = function(state)
        Aura.Enabled = state
        if state then
            Aura.TargetList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            startAuraLoop()
            WindUI:Notify({Title = "Aura", Content = "Activated - " .. #Aura.TargetList .. " targets.", Duration = 2, Icon = "swords"})
        else stopAuraLoop() end
    end})
    AuraSec:Toggle({Title = "Instant Kill", Default = false, Callback = function(state) InstantKill = state end})
    AuraSec:Slider({Title = "Prediction Offset", Min = 5, Max = 25, Default = 10, Callback = function(val) latencyEstimate = val / 100 end})
    AuraSec:Dropdown({Title = "Aura Targets", Options = getServerPlayers(), MultiSelection = true, Callback = function(selected)
        table.clear(Aura.TargetList)
        if selected then
            for _, name in ipairs(selected) do
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(Aura.TargetList, plr) end
            end
        end
    end})

    local ToolFollowSec = SPT_Combat_Tab:Section({Title = "Tool Follow"})
    ToolFollowSec:Toggle({Title = "Enable Tool Follow", Default = false, Callback = function(state)
        ToolFollow.Enabled = state
        if state then
            ToolFollow.Targets = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(ToolFollow.Targets, plr) end
            end
            startToolFollow()
        else stopToolFollow() end
    end})

    local DefenseSec = SPT_Combat_Tab:Section({Title = "Defense / Anti-Aura"})
    DefenseSec:Toggle({Title = "Enable Anti-Aura", Default = false, Callback = function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end})
    DefenseSec:Toggle({Title = "God Mode (ForceField)", Default = false, Callback = function(state) AntiAura.GodMode = state end})
    DefenseSec:Toggle({Title = "Repel (Anti-Touch)", Default = false, Callback = function(state) AntiAura.Repel = state end})
    DefenseSec:Toggle({Title = "Anti Spawnkill", Default = false, Callback = function(state)
        AntiSpawnkill = state
        if state then
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

-- ═══════════════════════════════════════════════════════════
--  SPT TYCOON
-- ═══════════════════════════════════════════════════════════
do
    local TycoonSec = SPT_Tycoon_Tab:Section({Title = "Tycoon Automation"})
    TycoonSec:Toggle({Title = "Auto Claim Money", Default = false, Callback = function(state)
        AutoClaimMoney = state
        if state then startClaimMoney() else stopClaimMoney() end
    end})
    TycoonSec:Toggle({Title = "Smart Auto Build", Default = false, Callback = function(state)
        AutoBuild = state
        if state then startAutoBuild() else stopAutoBuild() end
    end})
    TycoonSec:Toggle({Title = "Auto Grab Weapons", Default = false, Callback = function(state)
        AutoGetTools = state
        if state then
            if grabLoopConn then grabLoopConn:Disconnect() end
            grabLoopConn = RunService.PreSimulation:Connect(function()
                if not AutoGetTools then return end
                local myChar = player.Character
                if not myChar then return end
                local root = myChar:FindFirstChild("HumanoidRootPart")
                if not root then return end
                for toolName, base in pairs({["Energy Sword"]="Stone",["Staff"]="Magic",["Axe"]="Storm",["Fist"]="Robotic"}) do
                    if player.Backpack:FindFirstChild(toolName) or myChar:FindFirstChild(toolName) then continue end
                    local pads = TG_padsByBase[base]
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

    local CooldownSec = SPT_Tycoon_Tab:Section({Title = "Tools & Cooldown"})
    CooldownSec:Toggle({Title = "Auto Use Tools (0 delay)", Default = false, Callback = function(state)
        AutoTools = state
        if state then
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
    CooldownSec:Toggle({Title = "No Cooldown", Default = false, Callback = function(state)
        NoCooldown = state
        if state and not getgenv().NoCooldownHooked then
            hookfunction(wait, function() return RunService.PostSimulation:Wait() end)
            hookfunction(task.wait, function() return RunService.PostSimulation:Wait() end)
            hookfunction(delay, function(_, func) task.spawn(func) end)
            hookfunction(spawn, function(func) task.spawn(func) end)
            getgenv().NoCooldownHooked = true
        end
    end})
end

-- ═══════════════════════════════════════════════════════════
--  SPT MISC
-- ═══════════════════════════════════════════════════════════
do
    local ReachSec = SPT_Misc_Tab:Section({Title = "Reach"})
    ReachSec:Toggle({Title = "Enable Reach", Default = false, Callback = function(state)
        Reach = state
        if state then applyReach() else stopReach() end
    end})
    ReachSec:Slider({Title = "Reach Size", Min = 1, Max = 10, Default = 2, Callback = function(val)
        ReachSize = val
        if Reach then stopReach(); applyReach() end
    end})

    local RespawnSec = SPT_Misc_Tab:Section({Title = "Respawn & Protection"})
    RespawnSec:Toggle({Title = "Fast Respawn", Default = false, Callback = function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end})

    local UtilsSec = SPT_Misc_Tab:Section({Title = "Utilities"})
    UtilsSec:Textbox({Title = "Set Damage Remote", Placeholder = "game.ReplicatedStorage.DealDamage", Callback = function(text)
        if text and text ~= "" then
            local ok, remote = pcall(function() return loadstring("return " .. text)() end)
            if ok and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                DAMAGE_REMOTE = remote
                WindUI:Notify({Title = "Remote Set", Content = "Damage remote updated.", Duration = 3, Icon = "check"})
            else
                WindUI:Notify({Title = "Error", Content = "Invalid remote path.", Duration = 3, Icon = "x"})
            end
        end
    end})
end

-- ═══════════════════════════════════════════════════════════
--  MPT KILL
-- ═══════════════════════════════════════════════════════════
do
    local OmniSec = MPT_Kill_Tab:Section({Title = "Omni-Kill Engine"})
    OmniSec:Toggle({Title = "Enable Omni-Kill", Default = false, Callback = function(state)
        Aura.Enabled = state; InstantKill = state
        if state then
            Aura.TargetList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            startAuraLoop()
            WindUI:Notify({Title = "OMNI-KILL", Content = "ENGAGED - " .. #Aura.TargetList .. " targets.", Duration = 3, Icon = "skull"})
        else stopAuraLoop() end
    end})
    OmniSec:Toggle({Title = "Insta-Kill Micro-Burst", Default = false, Callback = function(state)
        InstaKillEnabled = state
        if state then startInstaKill() else stopInstaKill() end
    end})
    OmniSec:Slider({Title = "Prediction Aggression", Min = 5, Max = 25, Default = 10, Callback = function(val) latencyEstimate = val / 100 end})
    OmniSec:Button({Title = "Manual Kill Burst", Callback = function()
        local orig = Aura.Enabled
        Aura.Enabled = true; InstantKill = true
        task.wait(0.15)
        Aura.Enabled = orig
        if not orig then InstantKill = false end
        WindUI:Notify({Title = "Kill Burst", Content = "Burst fired.", Duration = 2, Icon = "zap"})
    end})
    OmniSec:Button({Title = "Refresh Target List", Callback = function()
        table.clear(Aura.TargetList)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then table.insert(Aura.TargetList, plr) end
        end
        WindUI:Notify({Title = "Targets", Content = "Refreshed: " .. #Aura.TargetList .. " players.", Duration = 2, Icon = "refresh-cw"})
    end})

    local HitAmpSec = MPT_Kill_Tab:Section({Title = "Hit Amplifier"})
    HitAmpSec:Toggle({Title = "Enable Hit Amplifier", Default = false, Callback = function(state)
        HitAmpEnabled = state
        if state then startHitAmplifier() else stopHitAmplifier() end
    end})
    HitAmpSec:Label({Title = "OverlapParams 24x24x24 | 120Hz | 15ms cooldown"})

    local ArsenalSec = MPT_Kill_Tab:Section({Title = "Tool Arsenal"})
    ArsenalSec:Toggle({Title = "Enable Tool Arsenal", Default = false, Callback = function(state)
        TG_Enabled = state
        if state then
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
    ArsenalSec:Button({Title = "Force Acquire All", Callback = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, baseName in ipairs({"Stone","Magic","Storm","Robotic"}) do
                local pad = TG_GetClosestPad(baseName)
                if pad then
                    for _ = 1, 8 do
                        pcall(firetouchinterest, root, pad, 0)
                        pcall(firetouchinterest, root, pad, 1)
                    end
                end
            end
            WindUI:Notify({Title = "Tool Arsenal", Content = "Force acquire burst fired.", Duration = 2, Icon = "package"})
        end
    end})
    ArsenalSec:Label({Title = "Bases: Stone, Magic, Storm, Robotic"})
end

-- ═══════════════════════════════════════════════════════════
--  MPT ECONOMY
-- ═══════════════════════════════════════════════════════════
do
    local SovSec = MPT_Economy_Tab:Section({Title = "Tycoon Sovereign"})
    SovSec:Toggle({Title = "Enable Sovereign Economy", Default = false, Callback = function(state)
        AutoClaimMoney = state; AutoBuild = state
        if state then startClaimMoney(); startAutoBuild()
        else stopClaimMoney(); stopAutoBuild() end
    end})
    SovSec:Slider({Title = "Defense Threat Radius", Min = 20, Max = 100, Default = 50, Callback = function(val) ThreatRadius = val end})
    SovSec:Button({Title = "Force Buy Next Upgrade", Callback = function()
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
            WindUI:Notify({Title = "Purchased", Content = "Bought: " .. best.Name, Duration = 2, Icon = "check"})
        else
            WindUI:Notify({Title = "No Purchase", Content = "Nothing affordable.", Duration = 2, Icon = "x"})
        end
    end})

    local SpawnSec = MPT_Economy_Tab:Section({Title = "Spawn Supremacy"})
    SpawnSec:Toggle({Title = "Enable Supremacy Mode", Default = false, Callback = function(state)
        AntiSpawnkill = state
        if state then
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
    SpawnSec:Toggle({Title = "Fast Respawn", Default = false, Callback = function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end})

    local DefSec = MPT_Economy_Tab:Section({Title = "Defense Matrix"})
    DefSec:Toggle({Title = "Enable Defense Matrix", Default = false, Callback = function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end})
    DefSec:Toggle({Title = "ForceField God Mode", Default = false, Callback = function(state) AntiAura.GodMode = state end})
    DefSec:Toggle({Title = "Weapon Repel", Default = false, Callback = function(state) AntiAura.Repel = state end})
    DefSec:Button({Title = "Emergency Heal", Callback = function()
        local myChar = player.Character
        if myChar then
            local hum = myChar:FindFirstChild("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                WindUI:Notify({Title = "Healed", Content = "Health restored.", Duration = 2, Icon = "heart"})
            end
        end
    end})
end

-- ═══════════════════════════════════════════════════════════
--  UPDATES
-- ═══════════════════════════════════════════════════════════
do
    local ChangeSec = Updates_Tab:Section({Title = "EXO Hub Changelog"})
    ChangeSec:Label({Title = "v6.0 - GODLY TIER (CURRENT)"})
    ChangeSec:Label({Title = "  - Fixed: KeySystem removed (was hanging UI thread)"})
    ChangeSec:Label({Title = "  - Fixed: Heavy scans deferred to task.spawn()"})
    ChangeSec:Label({Title = "  - Fixed: No Tab:Show() nil method error"})
    ChangeSec:Label({Title = "  - Features at FULL power: 60Hz aura, 120Hz hit amp"})
    ChangeSec:Label({Title = "  - Pre-allocated buffers: zero GC pressure"})
    ChangeSec:Label({Title = "  - XOR-encoded key: anti-theft protection"})
    ChangeSec:Label({Title = "  - Anti-tamper integrity check on startup"})
    ChangeSec:Label({Title = ""})
    ChangeSec:Label({Title = "v5.0 - WindUI Edition"})
    ChangeSec:Label({Title = "v4.0 - Embedded/Velocity/Cerberus attempts"})
    ChangeSec:Label({Title = "v3.0 - ZyronX migration"})
    ChangeSec:Label({Title = "v1.1 - Initial release"})
end

-- ═══════════════════════════════════════════════════════════
--  SETTINGS
-- ═══════════════════════════════════════════════════════════
do
    local UISec = Settings_Tab:Section({Title = "UI Config"})
    UISec:Dropdown({Title = "Theme", Options = {"Default", "Dark", "Light", "Rose", "Ocean", "Amethyst"}, Default = 1, Callback = function(option)
        pcall(function() WindUI:SetTheme(option) end)
    end})

    local GeneralSec = Settings_Tab:Section({Title = "General"})
    GeneralSec:Toggle({Title = "Anti-Lag Shield", Default = false, Callback = function(state)
        AntiLagEnabled = state
        if state then startAntiLag() else stopAntiLag() end
    end})
    GeneralSec:Toggle({Title = "ESP (Minimal Dots)", Default = false, Callback = function(state)
        ESPEnabled = state
        if state then startESP() else stopESP() end
    end})
    GeneralSec:Toggle({Title = "Kill Notifications", Default = false, Callback = function(state)
        KillNotifEnabled = state
        if state then
            WindUI:Notify({Title = "Kill Notifications", Content = "Behavioral analysis + threat level enabled.", Duration = 4, Icon = "bell"})
        end
    end})
    GeneralSec:Toggle({Title = "Kill Logs", Default = false, Callback = function(state) KillLogEnabled = state end})
    GeneralSec:Button({Title = "View Kill Logs", Callback = function()
        if #KillLogs == 0 then
            WindUI:Notify({Title = "Kill Logs", Content = "No kills recorded yet.", Duration = 2, Icon = "info"})
            return
        end
        local lastLog = KillLogs[#KillLogs]
        WindUI:Notify({
            Title = "Last Kill Log",
            Content = "Killer: " .. lastLog.Killer .. "\nWeapon: " .. lastLog.Weapon
                .. "\nThreat: " .. lastLog.Threat .. "/10\nTotal logs: " .. #KillLogs,
            Duration = 5,
            Icon = "scroll-text",
        })
    end})

    local ConfigSec = Settings_Tab:Section({Title = "Config"})
    ConfigSec:Button({Title = "Save Config", Callback = function()
        local config = {ReachSize = ReachSize, ThreatRadius = ThreatRadius, latencyEstimate = latencyEstimate}
        writeJSON(CONFIG_FILE, config)
        WindUI:Notify({Title = "Config Saved", Content = "Settings saved.", Duration = 2, Icon = "save"})
    end})
    ConfigSec:Button({Title = "Load Config", Callback = function()
        local config = readJSON(CONFIG_FILE)
        if config then
            ReachSize = config.ReachSize or 2
            ThreatRadius = config.ThreatRadius or 50
            latencyEstimate = config.latencyEstimate or 0.1
            WindUI:Notify({Title = "Config Loaded", Content = "Settings restored.", Duration = 2, Icon = "folder-open"})
        else
            WindUI:Notify({Title = "No Config", Content = "No saved config found.", Duration = 2, Icon = "x"})
        end
    end})
    ConfigSec:Button({Title = "Rejoin Server", Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end})
end

-- ── SETUP & FINALIZE ────────────────────────────────────────
setupKillNotifications()

WindUI:Notify({
    Title = "EXO Hub v6.0 GODLY TIER",
    Content = "All systems online. Full power. Zero lag.",
    Duration = 4,
    Icon = "check-circle",
})
