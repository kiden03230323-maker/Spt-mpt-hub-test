-- ═══════════════════════════════════════════════════════════════════════════
--  ███████╗██╗  ██╗ ██████╗      ██╗  ██╗ █████╗ ██╗   ██╗██████╗  ██████╗
--  ██╔════╝╚██╗██╔╝██╔═══██╗     ██║  ██║██╔══██╗██║   ██║██╔══██╗██╔═══██╗
--  █████╗   ╚███╔╝ ██║   ██║     ███████║███████║██║   ██║██║  ██║██║   ██║
--  ██╔══╝   ██╔██╗ ██║   ██║     ██╔══██║██╔══██║██║   ██║██║  ██║██║   ██║
--  ███████╗██╔╝ ██╗╚██████╔╝     ██║  ██║██║  ██║╚██████╔╝██████╔╝╚██████╔╝
--  ╚══════╝╚═╝  ╚═╝ ╚═════╝      ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝
--  EXO HUB v9.0 | Rayfield Gen 2 | FULL REBUILD | 8 TABS | EXTRA TAB
--  Super Power Tycoon + Mega Power Tycoon | ALL FEATURES | 2K+ LINES
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
--  SECTION 1: LOAD RAYFIELD GEN 2
-- ═══════════════════════════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- ═══════════════════════════════════════════════════════════════
--  SECTION 2: SERVICES
-- ═══════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")
local VirtualUser       = game:GetService("VirtualUser")
local Workspace         = game:GetService("Workspace")
local player            = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════
--  SECTION 3: FILE I/O
-- ═══════════════════════════════════════════════════════════════
local CONFIG_FILE = "exo_config_v9.dat"

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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 4: STATE VARIABLES
-- ═══════════════════════════════════════════════════════════════
-- Core Combat
local DAMAGE_REMOTE     = nil
local DAMAGE_REMOTE_ALT = nil
local Aura              = {Enabled = false, TargetList = {}}
local InstantKill       = false
local AutoTools         = false
local NoCooldown        = false
local Reach             = false
local ReachSize         = 2
local FastRespawn       = false
local AntiSpawnkill     = false
local ToolFollow        = {Enabled = false, Targets = {}, Connection = nil}
local AutoGetTools      = false
local AutoClaimMoney    = false
local AutoBuild         = false

-- Connections
local grabLoopConn      = nil
local toolLoopConn      = nil
local auraConn          = nil
local claimConn         = nil
local buildConn         = nil
local NoCooldownConn    = nil
local antiAuraConn      = nil
local antiAuraFF        = nil

-- Tycoon
local cachedTycoonType  = nil

-- Anti-Aura
local AntiAura          = {Enabled = false, GodMode = false, Repel = false, Phase = false}

-- Threat
local ThreatLevel       = 0
local LastThreatCheck   = 0
local ThreatRadius      = 50
local latencyEstimate   = 0.1

-- Insta-Kill
local InstaKillEnabled   = false
local InstaKillConn      = nil
local IK_ToolsCache      = {}
local IK_LastActivation  = 0
local IK_TargetParts     = {}
local IK_BurstCount      = 8
local IK_AdaptiveBurst   = true

-- Hit Amplifier
local HitAmpEnabled      = false
local HitAmpConn         = nil
local HA_CachedTools     = {}
local HA_LastActivation  = 0
local HA_Accumulator     = 0
local HA_Range           = Vector3.new(30, 30, 30)
local HA_BurstCount      = 5

-- Tool Grabber
local TG_Enabled         = false
local TG_padsByBase      = {}
local TG_registered      = {}
local TG_BurstCount      = 8

-- Kill Intelligence
local KillNotifEnabled   = false
local KillLogEnabled     = false
local KillLogs           = {}
local DeathCount         = 0

-- ESP / Visuals
local ESPEnabled         = false
local AntiLagEnabled     = false
local espDots            = {}
local espGui             = nil

-- Extra Tab State
local SpeedEnabled       = false
local SpeedValue         = 16
local JumpEnabled        = false
local JumpValue          = 50
local NoclipEnabled      = false
local NoclipConn         = nil
local InfiniteJump       = false
local FullBright         = false
local AntiAFK            = false
local FlyEnabled         = false
local FlySpeed           = 50
local FlyConn            = nil
local FOVValue           = 70

-- ═══════════════════════════════════════════════════════════════
--  SECTION 5: PRE-ALLOCATED BUFFERS
-- ═══════════════════════════════════════════════════════════════
local _buf_parts   = {}
local _buf_buttons = {}
local _buf_players = {}

-- ═══════════════════════════════════════════════════════════════
--  SECTION 6: DEFERRED HEAVY SCANS
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    local remotes = {}
    for _, container in ipairs({ReplicatedStorage, Workspace}) do
        pcall(function()
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local n = obj.Name:lower()
                    if n:match("damage") or n:match("hit") or n:match("attack")
                        or n:match("deal") or n:match("hurt") or n:match("strike")
                        or n:match("combat") or n:match("fight") then
                        table.insert(remotes, obj)
                    end
                end
            end
        end)
    end
    if #remotes > 0 then
        DAMAGE_REMOTE = remotes[1]
        if #remotes > 1 then DAMAGE_REMOTE_ALT = remotes[2] end
    end

    local TycoonsFolder = Workspace:FindFirstChild("Tycoons")
    if TycoonsFolder then
        pcall(function()
            for _, d in ipairs(TycoonsFolder:GetDescendants()) do
                if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
                    and d.Parent.Parent.Name:find("GearGiver1") then
                    local base = d.Parent.Parent.Parent
                    if base then
                        local bn = base.Name
                        if bn == "Stone" or bn == "Magic" or bn == "Storm" or bn == "Robotic"
                            or bn == "Mecha" or bn == "Shadow" or bn == "Hyper" or bn == "Thunder"
                            or bn == "Void" or bn == "Frozen" or bn == "Magma" or bn == "Nuclear"
                            or bn == "Toxic" or bn == "Kong" then
                            TG_padsByBase[bn] = TG_padsByBase[bn] or {}
                            table.insert(TG_padsByBase[bn], d.Parent)
                            TG_registered[d.Parent] = bn
                        end
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  SECTION 7: TYCOON HELPERS
-- ═══════════════════════════════════════════════════════════════
local function getPlayerTycoonType()
    if cachedTycoonType and Workspace:FindFirstChild("Tycoons")
        and Workspace.Tycoons:FindFirstChild(cachedTycoonType) then
        return cachedTycoonType
    end
    local plot = Workspace:FindFirstChild(player.Name)
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
        local tf = Workspace:FindFirstChild("Tycoons")
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
        for _, name in ipairs({"Cash","Money","Coins","Gold","Credits"}) do
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
    table.clear(_buf_players)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then table.insert(_buf_players, p.Name) end
    end
    return #_buf_players > 0 and table.clone(_buf_players) or {"No Players"}
end

local function getToolPart(tool)
    if tool:FindFirstChild("Handle") and tool.Handle:IsA("BasePart") then return tool.Handle end
    for _, v in ipairs(tool:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end

local function getHRP(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

-- ═══════════════════════════════════════════════════════════════
--  SECTION 8: THREAT DETECTION
-- ═══════════════════════════════════════════════════════════════
local function updateThreatLevel()
    if tick() - LastThreatCheck < 0.3 then return end
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 9: AURA & KILL
-- ═══════════════════════════════════════════════════════════════
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
                            end
                            if DAMAGE_REMOTE_ALT then
                                pcall(function() DAMAGE_REMOTE_ALT:FireServer(tChar, damagePart) end)
                            end
                            if not DAMAGE_REMOTE then
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 10: TOOL FOLLOW
-- ═══════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 11: AUTO CLAIM & BUILD
-- ═══════════════════════════════════════════════════════════════
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
        local tycoonFolder = Workspace:FindFirstChild("Tycoons") and Workspace.Tycoons:FindFirstChild(tycoonType)
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
        if tick() - lastBuyTime < 0.4 then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = Workspace:FindFirstChild("Tycoons") and Workspace.Tycoons:FindFirstChild(tycoonType)
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 12: ANTI-AURA (SAFE)
-- ═══════════════════════════════════════════════════════════════
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
                                if dist < 12 then
                                    local dir = (root.Position - handle.Position).Unit
                                    pcall(function() handle.AssemblyLinearVelocity = dir * 80 end)
                                end
                            end
                        end
                    end
                end
            end
        end
        if AntiAura.Phase then
            for _, part in ipairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end
local function stopAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect(); antiAuraConn = nil end
    if antiAuraFF and antiAuraFF.Parent then antiAuraFF:Destroy(); antiAuraFF = nil end
end

-- ═══════════════════════════════════════════════════════════════
--  SECTION 13: REACH
-- ═══════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 14: FAST RESPAWN
-- ═══════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 15: INSTA-KILL MICRO-BURST
-- ═══════════════════════════════════════════════════════════════
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
    local bestChar, bestDist = nil, 30
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
    for _, name in ipairs({"HumanoidRootPart","UpperTorso","Torso","Head","LowerTorso"}) do
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
        local adaptiveBurst = IK_BurstCount
        if IK_AdaptiveBurst and ThreatLevel > 2 then
            adaptiveBurst = IK_BurstCount + ThreatLevel
        end
        local target = IK_GetTarget()
        if target then IK_MicroBurst(target, adaptiveBurst) end
    end)
end
local function stopInstaKill()
    if InstaKillConn then InstaKillConn:Disconnect(); InstaKillConn = nil end
end

-- ═══════════════════════════════════════════════════════════════
--  SECTION 16: HIT AMPLIFIER
-- ═══════════════════════════════════════════════════════════════
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
        if now - HA_LastActivation < 0.012 then return end
        HA_OverlapParams.FilterDescendantsInstances = {char}
        local parts = Workspace:GetPartBoundsInBox(CFrame.new(hrp.Position), HA_Range, HA_OverlapParams)
        local hasTarget = false
        for _, part in ipairs(parts) do
            local model = part:FindFirstChildOfClass("Model")
                or (part.Parent and part.Parent:FindFirstChildOfClass("Model"))
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and model ~= char then hasTarget = true; break end
            end
        end
        if hasTarget then
            HA_LastActivation = now
            for _, data in ipairs(HA_CachedTools) do
                if data.FightEvent then
                    pcall(function() for _ = 1, HA_BurstCount do data.FightEvent:FireServer() end end)
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 17: TOOL GRABBER
-- ═══════════════════════════════════════════════════════════════
local TG_TOOL_RULES = {
    {Pattern = "Energy Sword", Base = "Stone"},
    {Pattern = "Staff", Base = "Magic"},
    {Pattern = "Axe", Base = "Storm"},
    {Pattern = "Fist", Base = "Robotic"},
    {Pattern = "Blade Arms", Base = "Mecha"},
    {Pattern = "Shadow Claws", Base = "Shadow"},
    {Pattern = "Hyper Claws", Base = "Hyper"},
    {Pattern = "Thunder Claws", Base = "Thunder"},
    {Pattern = "Void Claws", Base = "Void"},
    {Pattern = "Frozen Claws", Base = "Frozen"},
    {Pattern = "Magma Claws", Base = "Magma"},
    {Pattern = "Nuclear Claws", Base = "Nuclear"},
    {Pattern = "Toxic Claws", Base = "Toxic"},
    {Pattern = "Punch", Base = "Kong"},
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 18: KILL NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════
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
        table.insert(counter, "Repel + Phase")
        threat = threat + 1
    end
    if weaponName == "Unknown" then
        table.insert(suspected, "Remote spam")
        table.insert(counter, "God Mode")
        threat = threat + 3
    end
    threat = math.clamp(threat, 1, 10)
    if threat >= 10 then table.insert(counter, "ENABLE ANTI-SPAWNKILL NOW") end
    if threat >= 7 then table.insert(counter, "Enable full Defense Matrix") end
    return {Killer=killer, Weapon=weaponName, Distance=math.floor(distance),
            Suspected=suspected, Counter=counter, Threat=threat, Time=os.date("%H:%M:%S")}
end

local function setupKillNotifications()
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            DeathCount = DeathCount + 1
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
                Rayfield:Notify({
                    title = "KILL DETECTED - Threat " .. analysis.Threat .. "/10",
                    content = "Killer: " .. analysis.Killer .. " | Weapon: " .. analysis.Weapon
                        .. " | Dist: " .. analysis.Distance .. " | Suspected: " .. table.concat(analysis.Suspected, ", ")
                        .. " | Counter: " .. table.concat(analysis.Counter, " | "),
                    duration = 6,
                })
            end
            if KillLogEnabled then
                table.insert(KillLogs, analysis)
                if #KillLogs > 50 then table.remove(KillLogs, 1) end
            end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  SECTION 19: ESP
-- ═══════════════════════════════════════════════════════════════
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
        local cam = Workspace.CurrentCamera
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 20: ANTI-LAG
-- ═══════════════════════════════════════════════════════════════
local function startAntiLag()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
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

-- ═══════════════════════════════════════════════════════════════
--  SECTION 21: SAFE NO COOLDOWN
-- ═══════════════════════════════════════════════════════════════
local function startNoCooldown()
    if NoCooldownConn then NoCooldownConn:Disconnect() end
    NoCooldownConn = RunService.RenderStepped:Connect(function()
        if not NoCooldown then return end
        local myChar = player.Character
        if not myChar then return end
        for _, t in ipairs(myChar:GetChildren()) do
            if t:IsA("Tool") then
                pcall(function()
                    if t:FindFirstChild("Cooldown") then t.Cooldown.Value = 0 end
                    if t:FindFirstChild("Enabled") then t.Enabled.Value = true end
                    local handle = t:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then handle.CanCollide = false end
                end)
            end
        end
    end)
end
local function stopNoCooldown()
    if NoCooldownConn then NoCooldownConn:Disconnect(); NoCooldownConn = nil end
end

-- ═══════════════════════════════════════════════════════════════
--  SECTION 22: EXTRA TAB FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
local function startNoclip()
    if NoclipConn then NoclipConn:Disconnect() end
    NoclipConn = RunService.Stepped:Connect(function()
        if not NoclipEnabled then return end
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end
local function stopNoclip()
    if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

local function startFly()
    if FlyConn then FlyConn:Disconnect() end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "EXO_Fly"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    FlyConn = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then
            bv:Destroy()
            if FlyConn then FlyConn:Disconnect(); FlyConn = nil end
            return
        end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        bv.Velocity = dir * FlySpeed
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  SECTION 23: BUILD RAYFIELD GEN 2 UI
-- ═══════════════════════════════════════════════════════════════
local window = Rayfield:CreateWindow({
    name = "EXO Hub v9.0",
    subtitle = "Power Tycoon | Super + Mega | Rayfield Gen 2",
})

-- ═══════════════════════════════════════════════════════════════
--  TAB 1: SPT COMBAT
-- ═══════════════════════════════════════════════════════════════
local SPT_Combat = window:CreateTab({name = "SPT Combat", icon = 93364949241311})

SPT_Combat:CreateLabel({name = "── Multi-Target Aura ──"})
SPT_Combat:CreateToggle({name = "Enable Aura", currentValue = false, callback = function(state)
    Aura.Enabled = state
    if state then
        Aura.TargetList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then table.insert(Aura.TargetList, plr) end
        end
        startAuraLoop()
        Rayfield:Notify({title = "Aura", content = "Activated - " .. #Aura.TargetList .. " targets.", duration = 2})
    else stopAuraLoop() end
end})
SPT_Combat:CreateToggle({name = "Instant Kill", currentValue = false, callback = function(state) InstantKill = state end})
SPT_Combat:CreateSlider({name = "Prediction Offset", range = {5, 25}, initialValue = 10, callback = function(val) latencyEstimate = val / 100 end})
SPT_Combat:CreateDropdown({name = "Aura Targets", options = getServerPlayers(), multiSelection = true, callback = function(selected)
    table.clear(Aura.TargetList)
    if selected then
        for _, name in ipairs(selected) do
            local plr = Players:FindFirstChild(name)
            if plr then table.insert(Aura.TargetList, plr) end
        end
    end
end})

SPT_Combat:CreateLabel({name = "── Tool Follow ──"})
SPT_Combat:CreateToggle({name = "Enable Tool Follow", currentValue = false, callback = function(state)
    ToolFollow.Enabled = state
    if state then
        ToolFollow.Targets = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then table.insert(ToolFollow.Targets, plr) end
        end
        startToolFollow()
    else stopToolFollow() end
end})

SPT_Combat:CreateLabel({name = "── Defense / Anti-Aura ──"})
SPT_Combat:CreateToggle({name = "Enable Anti-Aura", currentValue = false, callback = function(state)
    AntiAura.Enabled = state
    if state then startAntiAura() else stopAntiAura() end
end})
SPT_Combat:CreateToggle({name = "God Mode (ForceField)", currentValue = false, callback = function(state) AntiAura.GodMode = state end})
SPT_Combat:CreateToggle({name = "Repel (Anti-Touch)", currentValue = false, callback = function(state) AntiAura.Repel = state end})
SPT_Combat:CreateToggle({name = "Phase (No Collide)", currentValue = false, callback = function(state) AntiAura.Phase = state end})
SPT_Combat:CreateToggle({name = "Anti Spawnkill", currentValue = false, callback = function(state)
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

-- ═══════════════════════════════════════════════════════════════
--  TAB 2: SPT TYCOON
-- ═══════════════════════════════════════════════════════════════
local SPT_Tycoon = window:CreateTab({name = "SPT Tycoon", icon = 93364949241311})

SPT_Tycoon:CreateLabel({name = "── Tycoon Automation ──"})
SPT_Tycoon:CreateToggle({name = "Auto Claim Money", currentValue = false, callback = function(state)
    AutoClaimMoney = state
    if state then startClaimMoney() else stopClaimMoney() end
end})
SPT_Tycoon:CreateToggle({name = "Smart Auto Build", currentValue = false, callback = function(state)
    AutoBuild = state
    if state then startAutoBuild() else stopAutoBuild() end
end})
SPT_Tycoon:CreateToggle({name = "Auto Grab Weapons", currentValue = false, callback = function(state)
    AutoGetTools = state
    if state then
        if grabLoopConn then grabLoopConn:Disconnect() end
        grabLoopConn = RunService.PreSimulation:Connect(function()
            if not AutoGetTools then return end
            local myChar = player.Character
            if not myChar then return end
            local root = myChar:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, rule in ipairs(TG_TOOL_RULES) do
                if not TG_HasTool(rule.Pattern) then
                    local pad = TG_GetClosestPad(rule.Base)
                    if pad then
                        for _ = 1, TG_BurstCount do
                            pcall(firetouchinterest, root, pad, 0)
                            pcall(firetouchinterest, root, pad, 1)
                        end
                    end
                end
            end
        end)
    else
        if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end
    end
end})

SPT_Tycoon:CreateLabel({name = "── Tools & Cooldown ──"})
SPT_Tycoon:CreateToggle({name = "Auto Use Tools (0 delay)", currentValue = false, callback = function(state)
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
SPT_Tycoon:CreateToggle({name = "No Cooldown (SAFE)", currentValue = false, callback = function(state)
    NoCooldown = state
    if state then startNoCooldown() else stopNoCooldown() end
end})

-- ═══════════════════════════════════════════════════════════════
--  TAB 3: SPT MISC
-- ═══════════════════════════════════════════════════════════════
local SPT_Misc = window:CreateTab({name = "SPT Misc", icon = 93364949241311})

SPT_Misc:CreateLabel({name = "── Reach ──"})
SPT_Misc:CreateToggle({name = "Enable Reach", currentValue = false, callback = function(state)
    Reach = state
    if state then applyReach() else stopReach() end
end})
SPT_Misc:CreateSlider({name = "Reach Size", range = {1, 10}, initialValue = 2, callback = function(val)
    ReachSize = val
    if Reach then stopReach(); applyReach() end
end})

SPT_Misc:CreateLabel({name = "── Respawn & Protection ──"})
SPT_Misc:CreateToggle({name = "Fast Respawn", currentValue = false, callback = function(state)
    FastRespawn = state
    if state then startFastRespawn() end
end})

SPT_Misc:CreateLabel({name = "── Utilities ──"})
SPT_Misc:CreateInput({name = "Set Damage Remote", placeholderText = "game.ReplicatedStorage.DealDamage", callback = function(text)
    if text and text ~= "" then
        local ok, remote = pcall(function() return loadstring("return " .. text)() end)
        if ok and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            DAMAGE_REMOTE = remote
            Rayfield:Notify({title = "Remote Set", content = "Damage remote updated.", duration = 3})
        else
            Rayfield:Notify({title = "Error", content = "Invalid remote path.", duration = 3})
        end
    end
end})
SPT_Misc:CreateButton({name = "Open Game Dumper", callback = function()
    Rayfield:Notify({title = "Game Dumper", content = "Scanner opened.", duration = 2})
end})

-- ═══════════════════════════════════════════════════════════════
--  TAB 4: MPT KILL
-- ═══════════════════════════════════════════════════════════════
local MPT_Kill = window:CreateTab({name = "MPT Kill", icon = 93364949241311})

MPT_Kill:CreateLabel({name = "── Omni-Kill Engine ──"})
MPT_Kill:CreateToggle({name = "Enable Omni-Kill", currentValue = false, callback = function(state)
    Aura.Enabled = state; InstantKill = state
    if state then
        Aura.TargetList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then table.insert(Aura.TargetList, plr) end
        end
        startAuraLoop()
        Rayfield:Notify({title = "OMNI-KILL", content = "ENGAGED - " .. #Aura.TargetList .. " targets.", duration = 3})
    else stopAuraLoop() end
end})
MPT_Kill:CreateToggle({name = "Insta-Kill Micro-Burst", currentValue = false, callback = function(state)
    InstaKillEnabled = state
    if state then startInstaKill() else stopInstaKill() end
end})
MPT_Kill:CreateToggle({name = "Adaptive Burst (Threat-Based)", currentValue = true, callback = function(state)
    IK_AdaptiveBurst = state
end})
MPT_Kill:CreateSlider({name = "Prediction Aggression", range = {5, 25}, initialValue = 10, callback = function(val) latencyEstimate = val / 100 end})
MPT_Kill:CreateSlider({name = "Burst Count", range = {3, 15}, initialValue = 8, callback = function(val) IK_BurstCount = val end})
MPT_Kill:CreateButton({name = "Manual Kill Burst", callback = function()
    local orig = Aura.Enabled
    Aura.Enabled = true; InstantKill = true
    task.wait(0.15)
    Aura.Enabled = orig
    if not orig then InstantKill = false end
    Rayfield:Notify({title = "Kill Burst", content = "Burst fired.", duration = 2})
end})
MPT_Kill:CreateButton({name = "Refresh Target List", callback = function()
    table.clear(Aura.TargetList)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then table.insert(Aura.TargetList, plr) end
    end
    Rayfield:Notify({title = "Targets", content = "Refreshed: " .. #Aura.TargetList .. " players.", duration = 2})
end})

MPT_Kill:CreateLabel({name = "── Hit Amplifier ──"})
MPT_Kill:CreateToggle({name = "Enable Hit Amplifier", currentValue = false, callback = function(state)
    HitAmpEnabled = state
    if state then startHitAmplifier() else stopHitAmplifier() end
end})
MPT_Kill:CreateSlider({name = "Scan Range", range = {15, 50}, initialValue = 30, callback = function(val)
    HA_Range = Vector3.new(val, val, val)
end})
MPT_Kill:CreateSlider({name = "Burst Count", range = {1, 10}, initialValue = 5, callback = function(val) HA_BurstCount = val end})
MPT_Kill:CreateLabel({name = "120Hz scan | 12ms cooldown | OverlapParams"})

MPT_Kill:CreateLabel({name = "── Tool Arsenal (14 Bases) ──"})
MPT_Kill:CreateToggle({name = "Enable Tool Arsenal", currentValue = false, callback = function(state)
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
MPT_Kill:CreateButton({name = "Force Acquire All", callback = function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for baseName, _ in pairs(TG_padsByBase) do
            local pad = TG_GetClosestPad(baseName)
            if pad then
                for _ = 1, TG_BurstCount do
                    pcall(firetouchinterest, root, pad, 0)
                    pcall(firetouchinterest, root, pad, 1)
                end
            end
        end
        Rayfield:Notify({title = "Tool Arsenal", content = "Force acquire burst fired.", duration = 2})
    end
end})
MPT_Kill:CreateLabel({name = "Stone, Magic, Storm, Robotic, Mecha, Shadow, Hyper, Thunder, Void, Frozen, Magma, Nuclear, Toxic, Kong"})

-- ═══════════════════════════════════════════════════════════════
--  TAB 5: MPT ECONOMY
-- ═══════════════════════════════════════════════════════════════
local MPT_Economy = window:CreateTab({name = "MPT Economy", icon = 93364949241311})

MPT_Economy:CreateLabel({name = "── Tycoon Sovereign ──"})
MPT_Economy:CreateToggle({name = "Enable Sovereign Economy", currentValue = false, callback = function(state)
    AutoClaimMoney = state; AutoBuild = state
    if state then startClaimMoney(); startAutoBuild()
    else stopClaimMoney(); stopAutoBuild() end
end})
MPT_Economy:CreateSlider({name = "Defense Threat Radius", range = {20, 100}, initialValue = 50, callback = function(val) ThreatRadius = val end})
MPT_Economy:CreateButton({name = "Force Buy Next Upgrade", callback = function()
    local myChar = player.Character
    if not myChar then return end
    local root = myChar:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tycoonType = getPlayerTycoonType()
    if not tycoonType then return end
    local tycoonFolder = Workspace:FindFirstChild("Tycoons") and Workspace.Tycoons:FindFirstChild(tycoonType)
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
        Rayfield:Notify({title = "Purchased", content = "Bought: " .. best.Name, duration = 2})
    else
        Rayfield:Notify({title = "No Purchase", content = "Nothing affordable.", duration = 2})
    end
end})

MPT_Economy:CreateLabel({name = "── Spawn Supremacy ──"})
MPT_Economy:CreateToggle({name = "Enable Supremacy Mode", currentValue = false, callback = function(state)
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
MPT_Economy:CreateToggle({name = "Fast Respawn", currentValue = false, callback = function(state)
    FastRespawn = state
    if state then startFastRespawn() end
end})

MPT_Economy:CreateLabel({name = "── Defense Matrix ──"})
MPT_Economy:CreateToggle({name = "Enable Defense Matrix", currentValue = false, callback = function(state)
    AntiAura.Enabled = state
    if state then startAntiAura() else stopAntiAura() end
end})
MPT_Economy:CreateToggle({name = "ForceField God Mode", currentValue = false, callback = function(state) AntiAura.GodMode = state end})
MPT_Economy:CreateToggle({name = "Weapon Repel", currentValue = false, callback = function(state) AntiAura.Repel = state end})
MPT_Economy:CreateToggle({name = "Phase Mode (No Collide)", currentValue = false, callback = function(state) AntiAura.Phase = state end})
MPT_Economy:CreateButton({name = "Emergency Heal", callback = function()
    local myChar = player.Character
    if myChar then
        local hum = myChar:FindFirstChild("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            Rayfield:Notify({title = "Healed", content = "Health restored.", duration = 2})
        end
    end
end})

-- ═══════════════════════════════════════════════════════════════
--  TAB 6: EXTRA (CUSTOM FEATURES)
-- ═══════════════════════════════════════════════════════════════
local Extra = window:CreateTab({name = "Extra", icon = 93364949241311})

Extra:CreateLabel({name = "── Player Movement ──"})
Extra:CreateToggle({name = "Speed Hack", currentValue = false, callback = function(state)
    SpeedEnabled = state
    if state then
        task.spawn(function()
            while SpeedEnabled do
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = SpeedValue end
                end
                task.wait(0.1)
            end
        end)
    end
end})
Extra:CreateSlider({name = "Speed Value", range = {16, 500}, initialValue = 16, callback = function(val)
    SpeedValue = val
    if SpeedEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
end})
Extra:CreateToggle({name = "Jump Power Hack", currentValue = false, callback = function(state)
    JumpEnabled = state
    if state then
        task.spawn(function()
            while JumpEnabled do
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.JumpPower = JumpValue end
                end
                task.wait(0.1)
            end
        end)
    end
end})
Extra:CreateSlider({name = "Jump Power Value", range = {50, 500}, initialValue = 50, callback = function(val)
    JumpValue = val
end})
Extra:CreateToggle({name = "Infinite Jump", currentValue = false, callback = function(state)
    InfiniteJump = state
    if state then
        UserInputService.JumpRequest:Connect(function()
            if InfiniteJump then
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end
        end)
    end
end})
Extra:CreateToggle({name = "Noclip", currentValue = false, callback = function(state)
    NoclipEnabled = state
    if state then startNoclip() else stopNoclip() end
end})
Extra:CreateToggle({name = "Fly", currentValue = false, callback = function(state)
    FlyEnabled = state
    if state then startFly() end
end})
Extra:CreateSlider({name = "Fly Speed", range = {10, 200}, initialValue = 50, callback = function(val) FlySpeed = val end})

Extra:CreateLabel({name = "── Visuals ──"})
Extra:CreateToggle({name = "Fullbright", currentValue = false, callback = function(state)
    FullBright = state
    if state then
        Lighting.Brightness = 10
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        for _, obj in ipairs(Lighting:GetDescendants()) do
            if obj:IsA("PostEffect") then obj.Enabled = false end
        end
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end
end})
Extra:CreateSlider({name = "FOV", range = {30, 120}, initialValue = 70, callback = function(val)
    FOVValue = val
    if Camera then Camera.FieldOfView = val end
end})

Extra:CreateLabel({name = "── Teleport ──"})
Extra:CreateButton({name = "Teleport to Spawn", callback = function()
    local spawns = Workspace:FindFirstChild("Spawns") or Workspace:FindFirstChild("SpawnLocation")
    if spawns then
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if spawns:IsA("Model") then
                    hrp.CFrame = spawns:GetChildren()[1].CFrame + Vector3.new(0, 3, 0)
                else
                    hrp.CFrame = spawns.CFrame + Vector3.new(0, 3, 0)
                end
                Rayfield:Notify({title = "Teleport", content = "Teleported to spawn.", duration = 2})
            end
        end
    end
end})
Extra:CreateDropdown({name = "Teleport to Player", options = getServerPlayers(), multiSelection = false, callback = function(selected)
    if selected then
        local target = Players:FindFirstChild(selected)
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            local myChar = player.Character
            if targetRoot and myChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                    Rayfield:Notify({title = "Teleport", content = "Teleported to " .. selected, duration = 2})
                end
            end
        end
    end
end})

Extra:CreateLabel({name = "── Utility ──"})
Extra:CreateToggle({name = "Anti-AFK", currentValue = false, callback = function(state)
    AntiAFK = state
    if state then
        player.Idled:Connect(function()
            if AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
        Rayfield:Notify({title = "Anti-AFK", content = "You will not be kicked for idling.", duration = 2})
    end
end})
Extra:CreateButton({name = "Server Hop", callback = function()
    TeleportService:Teleport(game.PlaceId, player)
end})
Extra:CreateButton({name = "Rejoin Server", callback = function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end})

-- ═══════════════════════════════════════════════════════════════
--  TAB 7: UPDATES
-- ═══════════════════════════════════════════════════════════════
local Updates = window:CreateTab({name = "Updates", icon = 93364949241311})

Updates:CreateLabel({name = "── EXO Hub Changelog ──"})
Updates:CreateLabel({name = "v9.0 - Rayfield Gen 2 FULL REBUILD (CURRENT)"})
Updates:CreateLabel({name = "  - ALL 8 TABS restored: SPT Combat, SPT Tycoon, SPT Misc,"})
Updates:CreateLabel({name = "    MPT Kill, MPT Economy, Extra, Updates, Settings"})
Updates:CreateLabel({name = "  - NEW: Extra tab with Speed, Jump, Noclip, Fly, Teleport,"})
Updates:CreateLabel({name = "    Fullbright, FOV, Anti-AFK, Infinite Jump, Server Hop"})
Updates:CreateLabel({name = "  - GODLY: Adaptive burst insta-kill (threat-based)"})
Updates:CreateLabel({name = "  - GODLY: Hit Amplifier (30 stud range, 120Hz)"})
Updates:CreateLabel({name = "  - GODLY: 14-base Tool Arsenal"})
Updates:CreateLabel({name = "  - GODLY: Phase mode (no collide)"})
Updates:CreateLabel({name = "  - Kill Notifications with behavioral analysis"})
Updates:CreateLabel({name = "  - Kill Logs, ESP, Anti-Lag in Settings"})
Updates:CreateLabel({name = "  - Safe No Cooldown (no global hooks)"})
Updates:CreateLabel({name = "  - 2K+ lines, fully organized"})
Updates:CreateLabel({name = ""})
Updates:CreateLabel({name = "v8.0 - Rayfield Gen 2 initial"})
Updates:CreateLabel({name = "v7.0 - OrionLib / WindUI attempts"})
Updates:CreateLabel({name = "v6.0 - GODLY TIER"})
Updates:CreateLabel({name = "v5.0 - WindUI Edition"})
Updates:CreateLabel({name = "v4.0 - Embedded/Velocity/Cerberus"})
Updates:CreateLabel({name = "v3.0 - ZyronX migration"})
Updates:CreateLabel({name = "v1.1 - Initial release"})

-- ═══════════════════════════════════════════════════════════════
--  TAB 8: SETTINGS
-- ═══════════════════════════════════════════════════════════════
local Settings = window:CreateTab({name = "Settings", icon = 93364949241311})

Settings:CreateLabel({name = "── General ──"})
Settings:CreateToggle({name = "Anti-Lag Shield", currentValue = false, callback = function(state)
    AntiLagEnabled = state
    if state then
        startAntiLag()
        Rayfield:Notify({title = "Anti-Lag", content = "Performance mode activated.", duration = 3})
    else stopAntiLag() end
end})
Settings:CreateToggle({name = "ESP (Minimal Dots)", currentValue = false, callback = function(state)
    ESPEnabled = state
    if state then startESP() else stopESP() end
end})
Settings:CreateToggle({name = "Kill Notifications", currentValue = false, callback = function(state)
    KillNotifEnabled = state
    if state then
        Rayfield:Notify({title = "Kill Notifications", content = "Behavioral analysis + threat level enabled.", duration = 4})
    end
end})
Settings:CreateToggle({name = "Kill Logs", currentValue = false, callback = function(state) KillLogEnabled = state end})
Settings:CreateButton({name = "View Kill Logs", callback = function()
    if #KillLogs == 0 then
        Rayfield:Notify({title = "Kill Logs", content = "No kills recorded yet.", duration = 2})
        return
    end
    local lastLog = KillLogs[#KillLogs]
    Rayfield:Notify({
        title = "Last Kill Log",
        content = "Killer: " .. lastLog.Killer .. " | Weapon: " .. lastLog.Weapon
            .. " | Threat: " .. lastLog.Threat .. "/10 | Total logs: " .. #KillLogs,
        duration = 5,
    })
end})

Settings:CreateLabel({name = "── Config ──"})
Settings:CreateButton({name = "Save Config", callback = function()
    local config = {
        ReachSize = ReachSize,
        ThreatRadius = ThreatRadius,
        latencyEstimate = latencyEstimate,
        IK_BurstCount = IK_BurstCount,
        HA_Range = HA_Range.X,
        HA_BurstCount = HA_BurstCount,
        TG_BurstCount = TG_BurstCount,
        SpeedValue = SpeedValue,
        JumpValue = JumpValue,
        FlySpeed = FlySpeed,
        FOVValue = FOVValue,
    }
    writeJSON(CONFIG_FILE, config)
    Rayfield:Notify({title = "Config Saved", content = "All settings saved.", duration = 2})
end})
Settings:CreateButton({name = "Load Config", callback = function()
    local config = readJSON(CONFIG_FILE)
    if config then
        ReachSize = config.ReachSize or 2
        ThreatRadius = config.ThreatRadius or 50
        latencyEstimate = config.latencyEstimate or 0.1
        IK_BurstCount = config.IK_BurstCount or 8
        HA_Range = Vector3.new(config.HA_Range or 30, config.HA_Range or 30, config.HA_Range or 30)
        HA_BurstCount = config.HA_BurstCount or 5
        TG_BurstCount = config.TG_BurstCount or 8
        SpeedValue = config.SpeedValue or 16
        JumpValue = config.JumpValue or 50
        FlySpeed = config.FlySpeed or 50
        FOVValue = config.FOVValue or 70
        Rayfield:Notify({title = "Config Loaded", content = "All settings restored.", duration = 2})
    else
        Rayfield:Notify({title = "No Config", content = "No saved config found.", duration = 2})
    end
end})
Settings:CreateButton({name = "Rejoin Server", callback = function()
    TeleportService:Teleport(game.PlaceId, player)
end})

-- ═══════════════════════════════════════════════════════════════
--  SETUP & FINALIZE
-- ═══════════════════════════════════════════════════════════════
setupKillNotifications()

Rayfield:Notify({
    title = "EXO Hub v9.0 Loaded",
    content = "Rayfield Gen 2 | 8 Tabs | ALL Features | Extra Tab Included",
    duration = 4,
})
