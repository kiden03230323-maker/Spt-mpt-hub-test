--[[
POWER TYCOON HUB – Ultimate ZyronX UI Version (SPT + FULL MPT Feature Parity)
Every feature from the reference hub natively rewritten for maximum stability and performance.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ============================================
-- DAMAGE REMOTE DETECTION
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
end

-- ============================================
-- GLOBAL STATE
-- ============================================
local Aura = { Enabled = false, TargetList = {} }
local InstantKill = false
local AutoTools = false
local NoCooldown = false
local Reach = false
local ReachVA = false
local Hitbox = false
local FastRespawn = false
local AntiSpawnkill = false
local ToolFollow = { Enabled = false, Targets = {}, Connection = nil }
local AutoGetTools = false
local grabLoopConn, toolLoopConn, auraConn, reachConn = nil, nil, nil, nil

local AutoClaimMoney = false
local AutoBuild = false
local claimConn, buildConn = nil, nil
local cachedTycoonType = nil

-- MPT Specific States
local Loopbring = { Enabled = false, Target = nil, Connection = nil }
local FreezeTarget = { Enabled = false, Target = nil, Connection = nil }
local HitAmplifier = false
local BigTools = false
local NoAnimation = false
local LocalInvisible = false
local ChatSpammer = { Enabled = false, Message = "MPT Hub is OP!", Connection = nil }
local LagServerActive = false

-- ============================================
-- TARGET MANAGER GUI (Custom Sub-Menu)
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
    frame.Parent = targetGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    title.Text = buttonText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    
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
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)
    
    local function refresh()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") and c ~= refreshBtn then c:Destroy() end
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
                Instance.new("UICorner", plrBtn).CornerRadius = UDim.new(0, 8)
                
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
    Players.PlayerAdded:Connect(function() if frame.Visible then refresh() end end)
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

createTargetManager("Manage Aura Targets", Aura.TargetList, "Aura")
createTargetManager("Manage Follow Targets", ToolFollow.Targets, "Follow")

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
        local cash = ls:FindFirstChild("Cash") or ls:FindFirstChild("Money") or ls:FindFirstChild("Coins") or ls:FindFirstChild("Gold")
        if cash and (cash:IsA("IntValue") or cash:IsA("NumberValue")) then return cash.Value end
        for _, stat in ipairs(ls:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then return stat.Value end
        end
    end
    return 0
end

local function getCost(obj)
    local priceVal = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if priceVal and (priceVal:IsA("IntValue") or priceVal:IsA("NumberValue")) then return priceVal.Value end
    local attr = obj:GetAttribute("Price") or obj:GetAttribute("Cost")
    if type(attr) == "number" then return attr end
    for _, child in ipairs(obj:GetDescendants()) do
        if (child:IsA("IntValue") or child:IsA("NumberValue")) and (child.Name:lower():find("price") or child.Name:lower():find("cost")) then
            return child.Value
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
-- COMBAT & TOOL LOGIC
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
        if not Aura.Enabled and not InstantKill and not HitAmplifier then return end
        local myChar = player.Character; if not myChar then return end
        
        if Aura.Enabled or HitAmplifier then
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
                                if DAMAGE_REMOTE and HitAmplifier then
                                    for i=1, 5 do pcall(function() DAMAGE_REMOTE:FireServer(tChar, damagePart) end) end
                                elseif DAMAGE_REMOTE then
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

local cachedToolParts, cachedTorso = {}, {}
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
-- AUTO CLAIM & SMART BUILD
-- ============================================
function startClaimMoney()
    if claimConn then claimConn:Disconnect() end
    claimConn = RunService.PreSimulation:Connect(function()
        if not AutoClaimMoney then return end
        local myChar = player.Character; if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart"); if not root then return end
        local tycoonType = getPlayerTycoonType(); if not tycoonType then return end
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
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        
        local cash = getPlayerCash()
        local buttons = {}
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("button") or obj.Name:lower():find("btn")) then
                local cost = getCost(obj)
                if cost > 0 then table.insert(buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)}) end
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
function stopAutoBuild() if buildConn then buildConn:Disconnect(); buildConn = nil end end

-- ============================================
-- MPT SPECIFIC FEATURES (NATIVE & OPTIMIZED)
-- ============================================
function startLoopbring()
    if Loopbring.Connection then Loopbring.Connection:Disconnect() end
    Loopbring.Connection = RunService.Heartbeat:Connect(function()
        if not Loopbring.Enabled or not Loopbring.Target then return end
        local myChar = player.Character; if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
        local tChar = Loopbring.Target.Character
        if tChar then
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            if tRoot then
                tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, 2)
            end
        end
    end)
end
function stopLoopbring() if Loopbring.Connection then Loopbring.Connection:Disconnect(); Loopbring.Connection = nil end end

function startFreezeTarget()
    if FreezeTarget.Connection then FreezeTarget.Connection:Disconnect() end
    FreezeTarget.Connection = RunService.Heartbeat:Connect(function()
        if not FreezeTarget.Enabled or not FreezeTarget.Target then return end
        local tChar = FreezeTarget.Target.Character
        if tChar then
            local hum = tChar:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end
            local root = tChar:FindFirstChild("HumanoidRootPart")
            if root then root.Anchored = true end
        end
    end)
end
function stopFreezeTarget() 
    if FreezeTarget.Connection then FreezeTarget.Connection:Disconnect(); FreezeTarget.Connection = nil end
    if FreezeTarget.Target and FreezeTarget.Target.Character then
        local hum = FreezeTarget.Target.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        local root = FreezeTarget.Target.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
    end
end

function applyBigTools()
    local myChar = player.Character; if not myChar then return end
    for _, tool in ipairs(myChar:GetChildren()) do
        if tool:IsA("Tool") then
            for _, part in ipairs(tool:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * 3
                    part.Massless = true
                end
            end
        end
    end
end

function applyNoAnimation()
    local myChar = player.Character; if not myChar then return end
    local animate = myChar:FindFirstChild("Animate")
    if animate then animate:Destroy() end
    local animator = myChar:FindFirstChildWhichIsA("Animator")
    if animator then animator:Destroy() end
end

function applyLocalInvisible()
    local myChar = player.Character; if not myChar then return end
    for _, desc in ipairs(myChar:GetDescendants()) do
        if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
            desc.Transparency = 1
        end
        if desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") then
            desc.Enabled = false
        end
    end
end

function startChatSpammer()
    if ChatSpammer.Connection then ChatSpammer.Connection:Disconnect() end
    ChatSpammer.Connection = RunService.Heartbeat:Connect(function()
        if not ChatSpammer.Enabled then return end
        task.wait(0.5)
        local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
            pcall(function() chatEvent.SayMessageRequest:FireServer(ChatSpammer.Message, "All") end)
        end
    end)
end
function stopChatSpammer() if ChatSpammer.Connection then ChatSpammer.Connection:Disconnect(); ChatSpammer.Connection = nil end end

function triggerLocalLag()
    LagServerActive = not LagServerActive
    if LagServerActive then
        local lagFolder = Instance.new("Folder", workspace)
        lagFolder.Name = "LagTestFolder"
        for i = 1, 500 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(1,1,1)
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 1
            part.Parent = lagFolder
        end
        task.delay(3, function()
            if lagFolder then lagFolder:Destroy() end
            LagServerActive = false
        end)
    end
end

-- ============================================
-- ZYRONX UI INITIALIZATION
-- ============================================
local Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()

local Window = Library:CreateWindow({
    Title = "Power Tycoon Hub",
    Subtitle = "SPT & MPT Ultimate",
    SubtitleColor = Color3.fromRGB(100, 200, 255),
    Logo = "rbxassetid://82367817676382",
    LogoSize = 32,
    SphereText = true,
    SphereWords = "PT",
    SphereImage = "rbxassetid://82367817676382",
    SphereIconSize = 38
})

-- ============================================
-- SUPER POWER TYCOON TAB (SPT)
-- ============================================
local SPT_Tab = Window:CreateTab("Super Power Tycoon", true, false)

local SPT_Combat = SPT_Tab:CreatePage("Combat")
local AuraSection = SPT_Combat:CreateSection("Multi-Target Aura")
AuraSection:AddButton("Manage Aura Targets", function() toggleTargetFrame("Aura") end, {Title="Manage Targets", Description="Open target selection."})
AuraSection:AddToggle("Enable Aura", false, function(state) Aura.Enabled = state; if state then startAuraLoop() else stopAuraLoop() end end, {Title="Enable Aura", Description="Starts multi-target aura."})
AuraSection:AddToggle("Instant Kill", false, function(state) InstantKill = state end, {Title="Instant Kill", Description="Brute-force kills targets."})

local ToolFollowSection = SPT_Combat:CreateSection("Tool Follow")
ToolFollowSection:AddButton("Manage Follow Targets", function() toggleTargetFrame("Follow") end, {Title="Manage Targets", Description="Open target selection."})
ToolFollowSection:AddToggle("Enable Tool Follow", false, function(state) ToolFollow.Enabled = state; if state then startToolFollow() else stopToolFollow() end end, {Title="Enable Tool Follow", Description="Forces tools to follow targets."})

local SPT_Tycoon = SPT_Tab:CreatePage("Tycoon")
local TycoonCoreSection = SPT_Tycoon:CreateSection("Tycoon Automation")
TycoonCoreSection:AddToggle("Auto Claim Money", false, function(state) AutoClaimMoney = state; if state then startClaimMoney() else stopClaimMoney() end end, {Title="Auto Claim Money", Description="Remotely touches Cash Register."})
TycoonCoreSection:AddToggle("Smart Auto Build", false, function(state) AutoBuild = state; if state then startAutoBuild() else stopAutoBuild() end end, {Title="Smart Auto Build", Description="Buys: Gear → Walls → Gen → Doors."})

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
                    for i = 1, 8 do pcall(firetouchinterest, root, closest, 0); pcall(firetouchinterest, root, closest, 1) end
                end
            end
        end)
    else
        if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end
    end
end, {Title="Auto Grab Weapons", Description="Grabs weapons from tycoon pads."})

local CooldownSection = SPT_Tycoon:CreateSection("Tools & Cooldown")
CooldownSection:AddToggle("Auto Use Tools", false, function(state)
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
end, {Title="Auto Use Tools", Description="Continuously activates all tools."})

CooldownSection:AddToggle("No Cooldown", false, function(state)
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
end, {Title="No Cooldown", Description="Removes tool cooldowns."})

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
end, {Title="Reach", Description="Expands tool hitboxes."})

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
end, {Title="Fast Respawn", Description="Instantly respawns upon death."})

RespawnSection:AddToggle("Anti Spawnkill", false, function(state)
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
end, {Title="Anti Spawnkill", Description="3 seconds of invincibility on spawn."})

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
    copyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(table.concat(logLines, "\n")) end); addLog("✅ Copied!",Color3.fromRGB(100,255,100)) end)
    addLog("🔎 SCANNING...",Color3.fromRGB(255,200,50))
    local function scan(container,depth)
        for _,child in ipairs(container:GetChildren()) do
            local indent=string.rep("   ",depth); local icon="📄 "
            if child:IsA("Folder") then icon="📁 "; addLog(indent..icon.."  "..child.Name.." (Folder)",Color3.fromRGB(255,200,100)); scan(child,depth+1)
            elseif child:IsA("Tool") then icon="🔧 "; addLog(indent..icon.."  "..child.Name.." (Tool)",Color3.fromRGB(100,255,100))
            elseif child:IsA("Model") then icon="🧩 "; addLog(indent..icon.."  "..child.Name.." (Model)",Color3.fromRGB(200,200,255))
            elseif child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then icon="📡 "; addLog(indent..icon.."  "..child.Name.." ("..child.ClassName..")",Color3.fromRGB(255,150,255))
            end
        end
    end
    scan(workspace,0); scan(ReplicatedStorage,0)
    addLog("✅ SCAN COMPLETE!",Color3.fromRGB(100,255,100))
end, {Title="Open Game Dumper", Description="Scans and logs remotes/objects."})

UtilsSection:AddTextbox("Damage Remote Path", "game.ReplicatedStorage.DealDamage", function(text)
    if text and text ~= "" then
        local success, remote = pcall(function() return loadstring("return " .. text)() end)
        if success and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            DAMAGE_REMOTE = remote
            Library:Notify({Title = "Remote Set", Description = "Damage remote updated.", Duration = 3})
        end
    end
end, {Title="Set Damage Remote", Description="Enter full path to damage remote."})


-- ============================================
-- MEGA POWER TYCOON TAB (FULL FEATURE PARITY)
-- ============================================
local MPT_Tab = Window:CreateTab("Mega Power Tycoon", false, false)

-- MPT Page 1: Combat
local MPT_Combat = MPT_Tab:CreatePage("Combat")
local MPT_CombatSec = MPT_Combat:CreateSection("Aggressive Combat")
MPT_CombatSec:AddButton("Manage Aura Targets", function() toggleTargetFrame("Aura") end, {Title="Manage Targets", Description="Select players for MPT Combat features."})
MPT_CombatSec:AddToggle("Kill Aura", false, function(state) Aura.Enabled = state; if state then startAuraLoop() else stopAuraLoop() end end, {Title="Kill Aura", Description="Automatically hits targets around you."})
MPT_CombatSec:AddToggle("Fast Kill", false, function(state) InstantKill = state end, {Title="Fast Kill", Description="Brute-force sets target health to 0."})
MPT_CombatSec:AddToggle("Hit Amplifier", false, function(state) HitAmplifier = state end, {Title="Hit Amplifier", Description="Spams damage remotes for massive damage."})

-- MPT Page 2: Movement & Control
local MPT_Movement = MPT_Tab:CreatePage("Movement & Control")
local MPT_ControlSec = MPT_Movement:CreateSection("Target Control")

local function getPlayerNames()
    local names = {"None"}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(names, p.Name) end end
    return names
end

MPT_ControlSec:AddDropdown("Loopbring Target", getPlayerNames, "None", function(selected)
    if selected == "None" then Loopbring.Target = nil else Loopbring.Target = Players:FindFirstChild(selected) end
end, {Title="Loopbring Target", Description="Choose a player to constantly teleport to you."})

MPT_ControlSec:AddToggle("Loopbring", false, function(state) 
    Loopbring.Enabled = state
    if state then startLoopbring() else stopLoopbring() end 
end, {Title="Loopbring", Description="Constantly teleports the target to you."})

MPT_ControlSec:AddDropdown("Freeze Target", getPlayerNames, "None", function(selected)
    if selected == "None" then FreezeTarget.Target = nil else FreezeTarget.Target = Players:FindFirstChild(selected) end
end, {Title="Freeze Target", Description="Choose a player to freeze."})

MPT_ControlSec:AddToggle("No Movement (Freeze)", false, function(state) 
    FreezeTarget.Enabled = state
    if state then startFreezeTarget() else stopFreezeTarget() end 
end, {Title="No Movement", Description="Anchors target and sets speed to 0."})


-- MPT Page 3: Tools & Visuals
local MPT_Tools = MPT_Tab:CreatePage("Tools & Visuals")
local MPT_ToolSec = MPT_Tools:CreateSection("Tool Manipulation")

MPT_ToolSec:AddToggle("Get Tools", false, function(state)
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
                    for i = 1, 8 do pcall(firetouchinterest, root, closest, 0); pcall(firetouchinterest, root, closest, 1) end
                end
            end
        end)
    else
        if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end
    end
end, {Title="Get Tools", Description="Automatically grabs weapons from tycoon pads."})

MPT_ToolSec:AddToggle("Use Tools", false, function(state)
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
end, {Title="Use Tools", Description="Continuously activates all tools."})

MPT_ToolSec:AddToggle("Cooldown (No Cooldown)", false, function(state)
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
end, {Title="Cooldown", Description="Removes tool cooldowns."})

MPT_ToolSec:AddToggle("Reach", false, function(state)
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
end, {Title="Reach", Description="Expands tool hitboxes and adds an outline."})

MPT_ToolSec:AddToggle("ReachVA", false, function(state)
    ReachVA = state
    if state then
        reachConn = RunService.Heartbeat:Connect(function()
            if not ReachVA then return end
            local myChar = player.Character; if not myChar then return end
            for _, t in ipairs(myChar:GetChildren()) do
                if t:IsA("Tool") then
                    local part = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
                    if part and Aura.TargetList[1] and Aura.TargetList[1].Character then
                        local targetRoot = Aura.TargetList[1].Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            part.CFrame = targetRoot.CFrame * CFrame.new(0, 1, 0)
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        if reachConn then reachConn:Disconnect(); reachConn = nil end
    end
end, {Title="ReachVA", Description="Aggressively teleports tools to the first selected aura target."})

MPT_ToolSec:AddToggle("Hitbox", false, function(state)
    Hitbox = state
    if state then
        local myChar = player.Character; if not myChar then return end
        for _, t in ipairs(myChar:GetChildren()) do
            if t:IsA("Tool") then
                for _, part in ipairs(t:GetDescendants()) do
                    if part:IsA("BasePart") then part.Size = part.Size * 2.5; part.Massless = true end
                end
            end
        end
    end
end, {Title="Hitbox", Description="Permanently scales up tool hitboxes by 2.5x."})

MPT_ToolSec:AddToggle("Fly Tools / Float Tools", false, function(state) 
    ToolFollow.Enabled = state
    if state then startToolFollow() else stopToolFollow() end 
end, {Title="Fly / Float Tools", Description="Forces tools to float and hit targets."})

MPT_ToolSec:AddToggle("Big Tools", false, function(state) 
    BigTools = state
    if state then applyBigTools() end
end, {Title="Big Tools", Description="Scales up all tool hitboxes by 3x."})

MPT_ToolSec:AddToggle("No Animation", false, function(state) 
    NoAnimation = state
    if state then applyNoAnimation() end
end, {Title="No Animation", Description="Destroys the Animate script for glitchy movement."})

MPT_ToolSec:AddToggle("Invisible", false, function(state) 
    LocalInvisible = state
    if state then applyLocalInvisible() end
end, {Title="Invisible", Description="Makes your character transparent locally."})


-- MPT Page 4: Utilities & Spam
local MPT_Utils = MPT_Tab:CreatePage("Utilities & Spam")
local MPT_UtilSec = MPT_Utils:CreateSection("Player Utilities")

MPT_UtilSec:AddToggle("Fast Respawn", false, function(state)
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
end, {Title="Fast Respawn", Description="Instantly respawns upon death."})

MPT_UtilSec:AddToggle("Anti Spawn", false, function(state)
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
end, {Title="Anti Spawn", Description="3 seconds of invincibility on spawn."})

MPT_UtilSec:AddButton("Get Base", function()
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
    if closestDoor then
        myRoot.CFrame = closestDoor.CFrame + Vector3.new(0, 5, 0)
        Library:Notify({Title = "Teleported", Description = "Moved to nearest tycoon door.", Duration = 3})
    end
end, {Title="Get Base", Description="Instantly teleports you to the nearest tycoon door."})

local MPT_SpamSec = MPT_Utils:CreateSection("Spam & Misc")
MPT_SpamSec:AddTextbox("Chat Message", "MPT Hub is OP!", function(text) ChatSpammer.Message = text end, {Title="Chat Spammer Message", Description="Set the message to spam."})

MPT_SpamSec:AddToggle("Ultra Spammer", false, function(state) 
    ChatSpammer.Enabled = state
    if state then startChatSpammer() else stopChatSpammer() end 
end, {Title="Ultra Spammer", Description="Spams the set message in chat."})

MPT_SpamSec:AddButton("Lag Server (Local Test)", function()
    triggerLocalLag()
    Library:Notify({Title = "Lag Triggered", Description = "Spawned 500 local parts to test client FPS drop. (Safe)", Duration = 3})
end, {Title="Lag Server", Description="Spawns local parts to simulate lag safely without risking a ban."})

MPT_SpamSec:AddTextbox("Command", "print('Hello')", function(text)
    local success, err = pcall(function() loadstring(text)() end)
    if not success then
        Library:Notify({Title = "Command Error", Description = tostring(err), Duration = 3})
    end
end, {Title="Command Bar (Infinite Yield Alt)", Description="Execute custom Lua code directly. Safer and won't break like external links."})


-- ============================================
-- SETTINGS TAB
-- ============================================
local SettingsTab = Window:CreateTab("Settings", false, false)
local S_Page1 = SettingsTab:CreatePage("Settings")
local AppearanceCard = S_Page1:CreateSection("UI Config")
AppearanceCard:AddToggle("Transparency Toggle", false, function(state)
    Window:SetTransparency(state and 0.2 or 0)
end, {Title="Glass Architecture", Description="Overrides main window background for a sleek 0.2 transparency visual."})

local SavesCard = S_Page1:CreateSection("Config")
SavesCard:AddConfigManager("PowerTycoonHub_Config")

-- ============================================
-- INITIALIZATION NOTIFICATION
-- ============================================
Library:Notify({
    Title = "Power Tycoon Hub Loaded",
    Description = "ALL friend's hub features natively integrated and optimized!",
    Duration = 4
})

print("⚡ Power Tycoon Hub – Ultimate ZyronX UI Version. Full feature parity achieved.")
