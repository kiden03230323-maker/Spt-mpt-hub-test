--[[
POWER TYCOON HUB – Zonix UI Edition (Native PlayerList Integration)
All original game logic preserved 1:1.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ============================================
-- DAMAGE REMOTE DETECTION (PLACEHOLDER)
-- ============================================
local DAMAGE_REMOTE = nil
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
-- STATE
-- ============================================
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
-- TYCOON DETECTION & TOUCH HELPERS
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
-- LOGIC FUNCTIONS (Original Script)
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
-- FIXED: SMART AUTO CLAIM MONEY & AUTO BUILD
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
-- ZONIX UI INITIALIZATION
-- ============================================
local Zonix = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zontrz/zonix-ui/refs/heads/main/main.lua"))()

local Window = Zonix:Window({
    Name = "Power Tycoon Hub",
    Icon = "⚡",
    MinimizeMode = "collapse"
})

-- ============================================
-- SUPER POWER TYCOON TAB
-- ============================================
local SPT_Tab = Window:Tab({Name = "Super Power Tycoon", Icon = "🎮"})

-- Target Management using Zonix Native PlayerList
SPT_Tab:Section("🎯 Target Management")
local PlayerListObj = SPT_Tab:PlayerList({
    MinHeight = 150,
    MaxHeight = 250,
    Flag = "server_players"
})

local AuraLabel = SPT_Tab:Label("Aura Targets: None")
local ToolLabel = SPT_Tab:Label("Tool Follow Targets: None")

local function updateLabels()
    local auraNames = {}
    for _, p in ipairs(Aura.TargetList) do table.insert(auraNames, p.DisplayName) end
    AuraLabel:Set("Aura Targets: " .. (#auraNames > 0 and table.concat(auraNames, ", ") or "None"))
    
    local toolNames = {}
    for _, p in ipairs(ToolFollow.Targets) do table.insert(toolNames, p.DisplayName) end
    ToolLabel:Set("Tool Follow Targets: " .. (#toolNames > 0 and table.concat(toolNames, ", ") or "None"))
end

SPT_Tab:Button({
    Name = "➕ Add Selected to Aura Targets",
    Callback = function()
        local selected = PlayerListObj:GetSelected()
        if selected and not table.find(Aura.TargetList, selected) then
            table.insert(Aura.TargetList, selected)
            updateLabels()
            Zonix:Notify({Title = "Target Added", Content = selected.DisplayName .. " added to Aura.", Duration = 2, Type = "Success"})
        end
    end
})

SPT_Tab:Button({
    Name = "➕ Add Selected to Tool Follow",
    Callback = function()
        local selected = PlayerListObj:GetSelected()
        if selected and not table.find(ToolFollow.Targets, selected) then
            table.insert(ToolFollow.Targets, selected)
            updateLabels()
            Zonix:Notify({Title = "Target Added", Content = selected.DisplayName .. " added to Tool Follow.", Duration = 2, Type = "Success"})
        end
    end
})

SPT_Tab:Button({
    Name = "❌ Clear All Targets",
    Callback = function()
        table.clear(Aura.TargetList)
        table.clear(ToolFollow.Targets)
        updateLabels()
        Zonix:Notify({Title = "Targets Cleared", Content = "All target lists wiped.", Duration = 2, Type = "Warning"})
    end
})

-- Combat Section
SPT_Tab:Section("⚔️ Combat")
SPT_Tab:Toggle({
    Name = "Enable Aura",
    Default = false,
    Flag = "aura_toggle",
    Callback = function(state)
        Aura.Enabled = state
        if state then startAuraLoop() else stopAuraLoop() end
    end
})

SPT_Tab:Toggle({
    Name = "Instant Kill",
    Default = false,
    Flag = "instakill_toggle",
    Callback = function(state) InstantKill = state end
})

SPT_Tab:Toggle({
    Name = "Enable Tool Follow",
    Default = false,
    Flag = "toolfollow_toggle",
    Callback = function(state)
        ToolFollow.Enabled = state
        if state then startToolFollow() else stopToolFollow() end
    end
})

-- Tycoon Section
SPT_Tab:Section("🏭 Tycoon Automation")
SPT_Tab:Toggle({
    Name = "Auto Claim Money",
    Default = false,
    Flag = "autoclaim_toggle",
    Callback = function(state)
        AutoClaimMoney = state
        if state then startClaimMoney() else stopClaimMoney() end
    end
})

SPT_Tab:Toggle({
    Name = "Smart Auto Build",
    Default = false,
    Flag = "autobuild_toggle",
    Callback = function(state)
        AutoBuild = state
        if state then startAutoBuild() else stopAutoBuild() end
    end
})

SPT_Tab:Toggle({
    Name = "Auto Grab Weapons",
    Default = false,
    Flag = "autoget_toggle",
    Callback = function(state)
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
    end
})

-- Tools & Cooldown Section
SPT_Tab:Section("🔧 Tools & Cooldown")
SPT_Tab:Toggle({
    Name = "Auto Use Tools (0 delay)",
    Default = false,
    Flag = "autouse_toggle",
    Callback = function(state)
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
    end
})

SPT_Tab:Toggle({
    Name = "No Cooldown (arms stick)",
    Default = false,
    Flag = "nocd_toggle",
    Callback = function(state)
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
    end
})

-- Movement & Visuals Section
SPT_Tab:Section("🏃 Movement & Visuals")
SPT_Tab:Toggle({
    Name = "Reach (hitbox + outline)",
    Default = false,
    Flag = "reach_toggle",
    Callback = function(state)
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
    end
})

-- Respawn & Protection Section
SPT_Tab:Section("🛡️ Respawn & Protection")
SPT_Tab:Toggle({
    Name = "Fast Respawn",
    Default = false,
    Flag = "fastrespawn_toggle",
    Callback = function(state)
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
    end
})

SPT_Tab:Toggle({
    Name = "Anti Spawnkill (invincible 3s)",
    Default = false,
    Flag = "antispawn_toggle",
    Callback = function(state)
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
    end
})

-- Utilities Section
SPT_Tab:Section("🛠️ Utilities")
SPT_Tab:Button({
    Name = "Open Game Dumper",
    Callback = function()
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
    end
})

SPT_Tab:Textbox({
    Name = "Damage Remote Path",
    Default = "game.ReplicatedStorage.DealDamage",
    Placeholder = "Full path to remote...",
    Flag = "dmg_remote_path",
    Callback = function(text)
        if text and text ~= "" then
            local success, remote = pcall(function() return loadstring("return " .. text)() end)
            if success and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                DAMAGE_REMOTE = remote
                print("Damage remote set to: ", DAMAGE_REMOTE:GetFullName())
                Zonix:Notify({Title = "Remote Set", Content = "Damage remote updated successfully.", Duration = 3, Type = "Success"})
            else
                warn("Invalid remote path.")
                Zonix:Notify({Title = "Error", Content = "Invalid remote path.", Duration = 3, Type = "Error"})
            end
        end
    end
})

-- ============================================
-- MEGA POWER TYCOON TAB
-- ============================================
local MPT_Tab = Window:Tab({Name = "Mega Power Tycoon", Icon = "🚧"})
MPT_Tab:Section("Status")
MPT_Tab:Paragraph("MPT Features", "Mega Power Tycoon features are currently in development. Check back soon for updates!")
MPT_Tab:Button({
    Name = "Placeholder",
    Callback = function()
        Zonix:Notify({Title = "MPT", Content = "Mega Power Tycoon features coming soon!", Duration = 3, Type = "Info"})
    end
})

-- ============================================
-- SETTINGS TAB
-- ============================================
local SettingsTab = Window:Tab({Name = "Settings", Icon = "⚙️"})

SettingsTab:Section("🎨 UI Customization")
SettingsTab:Dropdown({
    Name = "Theme",
    Options = {"Dark", "Light", "Midnight"},
    Default = "Dark",
    Flag = "theme_dropdown",
    Callback = function(theme)
        Zonix:UpdateTheme(theme)
    end
})

SettingsTab:Toggle({
    Name = "Rainbow Mode",
    Default = false,
    Flag = "rainbow_toggle",
    Callback = function(state)
        Zonix.Settings.RainbowMode = state
    end
})

SettingsTab:Section("💾 Configuration")
SettingsTab:Button({
    Name = "Save Config",
    Callback = function() Zonix:SaveConfig("power_tycoon") end
})

SettingsTab:Button({
    Name = "Load Config",
    Callback = function() Zonix:LoadConfig("power_tycoon") end
})

-- ============================================
-- INITIALIZATION NOTIFICATION
-- ============================================
Zonix:Notify({
    Title = "Power Tycoon Hub Loaded",
    Content = "Zonix UI Edition initialized successfully. Native PlayerList active.",
    Duration = 4,
    Type = "Success"
})

print("⚡ Power Tycoon Hub – Zonix UI Edition. Auto-Cash/Build & Native Target Selection Active.")
