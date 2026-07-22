--[[
POWER TYCOON HUB – with Owner Controls & Lockdown System
Made for city800 and whitelisted users.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ============================================
-- 1. LOCKDOWN & PAID ACCESS SYSTEM
-- ============================================
local WhitelistedUsers = {
    "city800",      -- OWNER
    "Username1",    -- Add your paid users here
    "Username2",
    "Username3"
}

local IsWhitelisted = false
local IsOwner = (player.Name == "city800")

for _, user in ipairs(WhitelistedUsers) do
    if user == player.Name then
        IsWhitelisted = true
        break
    end
end

if not IsWhitelisted then
    warn("Access Denied: You are not authorized to use this hub.")
    -- Optional: Kick the player entirely: player:Kick("Not whitelisted for this hub.")
    return -- Stops the script from loading the UI
end

-- ============================================
-- 2. REMOTE HUB CONTROL SYSTEM (Client-to-Client via Server)
-- ============================================
local HubRemote = ReplicatedStorage:FindFirstChild("HubControlRemote")
if not HubRemote then
    HubRemote = Instance.new("RemoteEvent")
    HubRemote.Name = "HubControlRemote"
    HubRemote.Parent = ReplicatedStorage
end

-- Listen for owner commands (Kick Hub, Banish)
HubRemote.OnClientEvent:Connect(function(command, targetName, senderName)
    -- Verify the command is genuinely from the owner
    if senderName == "city800" and targetName == player.Name then
        if command == "KickHub" then
            _G.HubKicked = true
            if CoreGui:FindFirstChild("PowerHub") then
                CoreGui.PowerHub:Destroy()
            end
            warn("You have been kicked from the hub by the Owner.")
        elseif command == "Banish" then
            player:Kick("You have been banished from the game by the Hub Owner.")
        end
    end
end)

-- ============================================
-- 3. DAMAGE REMOTE DETECTION (PLACEHOLDER)
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
-- 4. STATE
-- ============================================
local Aura = { Enabled = false, TargetList = {} }
local InstantKill = false
local AutoTools = false
local NoCooldown = false
local Reach = false
local FastRespawn = false
local AntiSpawnkill = false
local ToolFollow = { Enabled = false, Targets = {}, Connection = nil }

-- ============================================
-- 5. CUSTOM UI
-- ============================================
local hubGui = Instance.new("ScreenGui")
hubGui.Name = "PowerHub"
hubGui.ResetOnSpawn = false
hubGui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 480)
main.Position = UDim2.new(0.5, -260, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = hubGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
title.Text = "⚡ Power Tycoon Hub" .. (IsOwner and " 👑" or "")
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(1, 0, 0, 32)
tabHolder.Position = UDim2.new(0, 0, 0, 40)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = main

local sptTab = Instance.new("TextButton")
sptTab.Size = UDim2.new(0.5, -2, 1, 0)
sptTab.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
sptTab.Text = "Super Power Tycoon"
sptTab.TextColor3 = Color3.fromRGB(255, 255, 255)
sptTab.Font = Enum.Font.GothamBold
sptTab.TextSize = 14
sptTab.Parent = tabHolder
Instance.new("UICorner", sptTab).CornerRadius = UDim.new(0, 8)

local mptTab = Instance.new("TextButton")
mptTab.Size = UDim2.new(0.5, -2, 1, 0)
mptTab.Position = UDim2.new(0.5, 0, 0, 0)
mptTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
mptTab.Text = "Mega Power Tycoon"
mptTab.TextColor3 = Color3.fromRGB(200, 200, 200)
mptTab.Font = Enum.Font.GothamBold
mptTab.TextSize = 14
mptTab.Parent = tabHolder
Instance.new("UICorner", mptTab).CornerRadius = UDim.new(0, 8)

local sptContent = Instance.new("Frame")
sptContent.Size = UDim2.new(1, 0, 1, -80)
sptContent.Position = UDim2.new(0, 0, 0, 75)
sptContent.BackgroundTransparency = 1
sptContent.Visible = true
sptContent.Parent = main

local mptContent = Instance.new("Frame")
mptContent.Size = UDim2.new(1, 0, 1, -80)
mptContent.Position = UDim2.new(0, 0, 0, 75)
mptContent.BackgroundTransparency = 1
mptContent.Visible = false
mptContent.Parent = main

sptTab.MouseButton1Click:Connect(function()
    sptTab.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    mptTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sptContent.Visible = true
    mptContent.Visible = false
end)

mptTab.MouseButton1Click:Connect(function()
    mptTab.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    sptTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sptContent.Visible = false
    mptContent.Visible = true
end)

local sptScroll = Instance.new("ScrollingFrame")
sptScroll.Size = UDim2.new(1, -4, 1, 0)
sptScroll.Position = UDim2.new(0, 2, 0, 0)
sptScroll.BackgroundTransparency = 1
sptScroll.ScrollBarThickness = 6
sptScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sptScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sptScroll.ScrollingDirection = Enum.ScrollingDirection.Y
sptScroll.Parent = sptContent

local sptList = Instance.new("UIListLayout", sptScroll)
sptList.SortOrder = Enum.SortOrder.LayoutOrder
sptList.Padding = UDim.new(0, 8)

-- UI helper functions
local function addSectionHeader(text)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1, -20, 0, 28)
    h.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    h.Parent = sptScroll
    h.LayoutOrder = #sptScroll:GetChildren()
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 6)
    
    local t = Instance.new("TextLabel", h)
    t.Size = UDim2.new(1, -10, 1, 0)
    t.Position = UDim2.new(0, 5, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = Color3.fromRGB(150, 200, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
end

local function addToggle(text, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 30)
    f.BackgroundTransparency = 1
    f.Parent = sptScroll
    f.LayoutOrder = #sptScroll:GetChildren()
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 70, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    b.Text = "OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -80, 1, 0)
    l.Position = UDim2.new(0, 80, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local toggled = false
    b.MouseButton1Click:Connect(function()
        toggled = not toggled
        b.Text = toggled and "ON" or "OFF"
        b.BackgroundColor3 = toggled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(70, 70, 90)
        callback(toggled)
    end)
end

local function addButton(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = sptScroll
    b.LayoutOrder = #sptScroll:GetChildren()
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function createTargetManager(buttonText, targetList)
    local btn = addButton(buttonText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    frame.Visible = false
    frame.Parent = sptScroll
    frame.LayoutOrder = btn.LayoutOrder + 1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, -8, 0, 22)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    refreshBtn.Text = "🔄 Refresh Players"
    refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
    refreshBtn.Font = Enum.Font.Gotham
    refreshBtn.TextSize = 12
    refreshBtn.Parent = frame
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)
    
    local function refresh()
        for _, c in ipairs(frame:GetChildren()) do
            if c:IsA("TextButton") and c ~= refreshBtn then c:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local plrBtn = Instance.new("TextButton")
                plrBtn.Size = UDim2.new(1, -8, 0, 26)
                plrBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                plrBtn.Text = plr.Name
                plrBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
                plrBtn.Font = Enum.Font.Gotham
                plrBtn.TextSize = 13
                plrBtn.Parent = frame
                Instance.new("UICorner", plrBtn).CornerRadius = UDim.new(0, 8)
                if table.find(targetList, plr) then plrBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 80) end
                
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
        frame.Size = UDim2.new(1, -20, 0, (#frame:GetChildren() - 1) * 30 + 30)
    end
    
    refreshBtn.MouseButton1Click:Connect(refresh)
    btn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        if frame.Visible then refresh() end
    end)
    
    Players.PlayerAdded:Connect(function() if frame.Visible then refresh() end end)
    Players.PlayerRemoving:Connect(function(plr)
        local idx = table.find(targetList, plr)
        if idx then table.remove(targetList, idx) end
        if frame.Visible then refresh() end
    end)
    return refresh
end

-- ============================================
-- 6. OWNER CONTROLS (Exclusive to city800)
-- ============================================
if IsOwner then
    addSectionHeader("👑 Owner Controls")
    
    local ownerFrame = Instance.new("Frame")
    ownerFrame.Size = UDim2.new(1, -20, 0, 0)
    ownerFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    ownerFrame.Parent = sptScroll
    ownerFrame.LayoutOrder = #sptScroll:GetChildren()
    Instance.new("UICorner", ownerFrame).CornerRadius = UDim.new(0, 8)
    
    local ownerLayout = Instance.new("UIListLayout", ownerFrame)
    ownerLayout.Padding = UDim.new(0, 4)
    ownerLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local refreshOwnerBtn = Instance.new("TextButton")
    refreshOwnerBtn.Size = UDim2.new(1, -8, 0, 26)
    refreshOwnerBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    refreshOwnerBtn.Text = "🔄 Refresh Player List"
    refreshOwnerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshOwnerBtn.Font = Enum.Font.GothamBold
    refreshOwnerBtn.TextSize = 13
    refreshOwnerBtn.Parent = ownerFrame
    Instance.new("UICorner", refreshOwnerBtn).CornerRadius = UDim.new(0, 6)

    local function refreshOwnerList()
        -- Clear existing player rows (keep refresh button)
        for _, child in ipairs(ownerFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name == "PlayerRow" then
                child:Destroy()
            end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local row = Instance.new("Frame")
                row.Name = "PlayerRow"
                row.Size = UDim2.new(1, -8, 0, 30)
                row.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                row.Parent = ownerFrame
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.35, 0, 1, 0)
                nameLabel.Position = UDim2.new(0, 5, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = plr.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 13
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Parent = row

                -- Join Button
                local joinBtn = Instance.new("TextButton")
                joinBtn.Size = UDim2.new(0.18, 0, 0.8, 0)
                joinBtn.Position = UDim2.new(0.37, 0, 0.1, 0)
                joinBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
                joinBtn.Text = "Join"
                joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                joinBtn.Font = Enum.Font.GothamBold
                joinBtn.TextSize = 12
                joinBtn.Parent = row
                Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)
                joinBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
                    end)
                end)

                -- Kick Hub Button
                local kickBtn = Instance.new("TextButton")
                kickBtn.Size = UDim2.new(0.22, 0, 0.8, 0)
                kickBtn.Position = UDim2.new(0.57, 0, 0.1, 0)
                kickBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 40)
                kickBtn.Text = "Kick Hub"
                kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                kickBtn.Font = Enum.Font.GothamBold
                kickBtn.TextSize = 12
                kickBtn.Parent = row
                Instance.new("UICorner", kickBtn).CornerRadius = UDim.new(0, 4)
                kickBtn.MouseButton1Click:Connect(function()
                    HubRemote:FireServer("KickHub", plr.Name, player.Name)
                end)

                -- Banish Button
                local banishBtn = Instance.new("TextButton")
                banishBtn.Size = UDim2.new(0.22, 0, 0.8, 0)
                banishBtn.Position = UDim2.new(0.80, 0, 0.1, 0)
                banishBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
                banishBtn.Text = "Banish"
                banishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                banishBtn.Font = Enum.Font.GothamBold
                banishBtn.TextSize = 12
                banishBtn.Parent = row
                Instance.new("UICorner", banishBtn).CornerRadius = UDim.new(0, 4)
                banishBtn.MouseButton1Click:Connect(function()
                    HubRemote:FireServer("Banish", plr.Name, player.Name)
                end)

                -- Update frame size dynamically
                ownerFrame.Size = UDim2.new(1, -20, 0, (#ownerFrame:GetChildren()) * 34 + 10)
            end
        end
    end

    refreshOwnerBtn.MouseButton1Click:Connect(refreshOwnerList)
    refreshOwnerList() -- Initial load

    Players.PlayerAdded:Connect(refreshOwnerList)
    Players.PlayerRemoving:Connect(refreshOwnerList)
end

-- ============================================
-- 7. MULTI‑TARGET AURA
-- ============================================
addSectionHeader("Multi‑Target Aura")
createTargetManager("Manage Targets", Aura.TargetList)

addToggle("Enable Aura", function(state)
    Aura.Enabled = state
    if state then startAuraLoop() else stopAuraLoop() end
end)

addToggle("Instant Kill", function(state) InstantKill = state end)

local auraConn
function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.PreSimulation:Connect(function()
        if _G.HubKicked or not Aura.Enabled then return end
        local myChar = player.Character
        if not myChar then return end
        
        for _, tool in ipairs(myChar:GetChildren()) do
            if tool:IsA("Tool") then
                local damagePart
                for _, obj in ipairs(tool:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then 
                        damagePart = obj.Parent
                        break 
                    end
                end
                if not damagePart then damagePart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart") end
                if not damagePart then continue end
                
                local origCF = damagePart.CFrame
                for _, targetPlr in ipairs(Aura.TargetList) do
                    local tChar = targetPlr.Character
                    if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                        local root = tChar:FindFirstChild("HumanoidRootPart")
                        if root then
                            pcall(function() 
                                damagePart.CFrame = root.CFrame * CFrame.new(0, 2, 0)
                                damagePart:SetNetworkOwner(player) 
                            end)
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
        
        -- Brute-force Instant Kill (current fallback)
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
-- 8. TOOL FOLLOW (ORIGINAL, CRASH-FREE)
-- ============================================
addSectionHeader("Tool Follow (Original)")
createTargetManager("Manage Follow Targets", ToolFollow.Targets)

addToggle("Enable Tool Follow", function(state)
    ToolFollow.Enabled = state
    if state then startToolFollow() else stopToolFollow() end
end)

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

function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
    ToolFollow.Connection = RunService.Heartbeat:Connect(function()
        if _G.HubKicked or not ToolFollow.Enabled then return end
        if #ToolFollow.Targets == 0 then return end
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

-- Respawn handling
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
-- 9. AUTO GET TOOLS (ORIGINAL 0-DELAY)
-- ============================================
addSectionHeader("Auto Get Tools (0 delay)")
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

local Tycoons = workspace:WaitForChild("Tycoons")
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

local grabLoopConn
local AutoGetTools = false

addToggle("Auto Grab Weapons", function(state)
    AutoGetTools = state
    if state then
        if grabLoopConn then grabLoopConn:Disconnect() end
        grabLoopConn = RunService.PreSimulation:Connect(function()
            if _G.HubKicked or not AutoGetTools then return end
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
end)

-- ============================================
-- 10. OTHER FEATURES
-- ============================================
addSectionHeader("Tools & Cooldown")
local toolLoopConn

addToggle("Auto Use Tools (0 delay)", function(state)
    AutoTools = state
    if state then
        toolLoopConn = RunService.RenderStepped:Connect(function()
            if _G.HubKicked or not AutoTools then return end
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

addToggle("No Cooldown (arms stick)", function(state)
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
                if _G.HubKicked then break end
                local myChar = player.Character
                if myChar then
                    for _, t in ipairs(myChar:GetChildren()) do
                        if t:IsA("Tool") and t:FindFirstChild("Handle") then
                            pcall(function() t.Enabled = true; t.Cooldown = 0 end)
                            local handle = t.Handle
                            if handle:IsA("BasePart") then 
                                handle.CanCollide = false
                                local rightArm = myChar:FindFirstChild("Right Arm") or myChar:FindFirstChild("RightArm")
                                if rightArm then 
                                    local weld = rightArm:FindFirstChild("RightGrip") or rightArm:FindFirstChild("RightShoulder")
                                    if weld then weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(90), 0, 0) end
                                end
                            end
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
        end)
    end
end)

addSectionHeader("Reach")
addToggle("Reach (hitbox + outline)", function(state)
    Reach = state
    if state then
        local reachHL = {}
        local function apply()
            local myChar = player.Character
            if not myChar then return end
            for _, t in ipairs(myChar:GetChildren()) do
                if t:IsA("Tool") then
                    local part = nil
                    for _, obj in ipairs(t:GetDescendants()) do 
                        if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then 
                            part = obj.Parent
                            break 
                        end 
                    end
                    if not part then part = t:FindFirstChildWhichIsA("BasePart") end
                    if part and not reachHL[part] then 
                        part.Size = part.Size * 2
                        part.Massless = true
                        local hl = Instance.new("Highlight", part)
                        hl.FillTransparency = 1
                        hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                        hl.OutlineTransparency = 0
                        reachHL[part] = hl 
                    end
                end
            end
        end
        apply()
        player.CharacterAdded:Connect(apply)
        task.spawn(function() 
            while Reach do 
                if _G.HubKicked then break end
                apply()
                task.wait(0.5) 
            end 
        end)
    end
end)

addSectionHeader("Respawn & Protection")
addToggle("Fast Respawn", function(state)
    FastRespawn = state
    if state then
        local Guide = ReplicatedStorage:FindFirstChild("Guide")
        local last = 0
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
end)

addToggle("Anti Spawnkill (invincible 3s)", function(state)
    AntiSpawnkill = state
    if state then
        player.CharacterAdded:Connect(function(c)
            local hum = c:WaitForChild("Humanoid")
            hum.MaxHealth = 9e9
            hum.Health = 9e9
            local dmgConn = hum.TakeDamage:Connect(function() return 0 end)
            local ff = Instance.new("ForceField", c)
            ff.Visible = false
            task.delay(3, function() 
                if hum and hum.Parent then 
                    hum.MaxHealth = 100
                    hum.Health = 100 
                end
                if dmgConn then dmgConn:Disconnect() end
                if ff then ff:Destroy() end 
            end)
        end)
    end
end)

addSectionHeader("Utilities")
addButton("Open Game Dumper", function()
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
    
    local dTitle = Instance.new("TextLabel", frame)
    dTitle.Size = UDim2.new(1, 0, 0, 35)
    dTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    dTitle.Text = "🔍 FULL GAME SCANNER"
    dTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    dTitle.Font = Enum.Font.GothamBold
    dTitle.TextSize = 18
    
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -10, 1, -80)
    scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 8
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local list = Instance.new("UIListLayout", scroll)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 2)
    
    local copyBtn = Instance.new("TextButton", frame)
    copyBtn.Size = UDim2.new(0, 120, 0, 30)
    copyBtn.Position = UDim2.new(0.5, -160, 1, -40)
    copyBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    copyBtn.Text = "📋 Copy Log"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 14
    
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Position = UDim2.new(0.5, 30, 1, -40)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "✖ Close"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.MouseButton1Click:Connect(function() dGui:Destroy() end)
    
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
    
    copyBtn.MouseButton1Click:Connect(function() 
        pcall(function() setclipboard(table.concat(logLines, "\n")) end)
        addLog("✅ Copied to clipboard!", Color3.fromRGB(100, 255, 100)) 
    end)
    
    addLog("🔎 SCANNING ALL GAME OBJECTS...", Color3.fromRGB(255, 200, 50))
    
    local function scan(container, depth)
        for _, child in ipairs(container:GetChildren()) do
            local indent = string.rep("   ", depth)
            local icon = "📄"
            if child:IsA("Folder") then 
                icon = "📁"
                addLog(indent .. icon .. "  " .. child.Name .. " (Folder)", Color3.fromRGB(255, 200, 100))
                scan(child, depth + 1)
            elseif child:IsA("Tool") then 
                icon = "🔧"
                addLog(indent .. icon .. "  " .. child.Name .. " (Tool)", Color3.fromRGB(100, 255, 100))
            elseif child:IsA("Model") then 
                icon = "🧩"
                addLog(indent .. icon .. "  " .. child.Name .. " (Model)", Color3.fromRGB(200, 200, 255))
            elseif child:IsA("RemoteEvent") then 
                icon = "📡"
                addLog(indent .. icon .. "  " .. child.Name .. " (RemoteEvent)", Color3.fromRGB(255, 150, 255))
            elseif child:IsA("RemoteFunction") then 
                icon = "📡"
                addLog(indent .. icon .. "  " .. child.Name .. " (RemoteFunction)", Color3.fromRGB(255, 150, 255))
            elseif child:IsA("BindableEvent") or child:IsA("BindableFunction") then 
                icon = "🔗"
                addLog(indent .. icon .. "  " .. child.Name .. " (" .. child.ClassName .. ")", Color3.fromRGB(200, 200, 255))
            end
        end
    end
    
    addLog("━━━ WORKSPACE ━━━", Color3.fromRGB(100, 200, 255))
    scan(workspace, 0)
    addLog("━━━ REPLICATEDSTORAGE ━━━", Color3.fromRGB(100, 200, 255))
    scan(ReplicatedStorage, 0)
    addLog("━━━ REPLICATEDFIRST ━━━", Color3.fromRGB(100, 200, 255))
    scan(game:GetService("ReplicatedFirst"), 0)
    addLog("━━━ LIGHTING ━━━", Color3.fromRGB(100, 200, 255))
    scan(game:GetService("Lighting"), 0)
    addLog("━━━ PLAYER BACKPACK ━━━", Color3.fromRGB(100, 200, 255))
    if player:FindFirstChild("Backpack") then scan(player.Backpack, 0) end
    addLog("━━━ PLAYER CHARACTER ━━━", Color3.fromRGB(100, 200, 255))
    if player.Character then scan(player.Character, 0) end
    addLog("✅ SCAN COMPLETE! Use the Copy button to save all data.", Color3.fromRGB(100, 255, 100))
end)

addButton("Set Damage Remote", function()
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 100)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderText = "Full path e.g. game.ReplicatedStorage.DealDamage"
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.Parent = main
    input:CaptureFocus()
    
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1, -20, 0, 30)
    submitBtn.Position = UDim2.new(0, 10, 0, 140)
    submitBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    submitBtn.Text = "Set Remote"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 14
    submitBtn.Parent = main
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 6)
    
    submitBtn.MouseButton1Click:Connect(function()
        local path = input.Text
        if path and path ~= "" then
            local success, remote = pcall(function() return loadstring("return " .. path)() end)
            if success and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                DAMAGE_REMOTE = remote
                print("Damage remote set to: ", DAMAGE_REMOTE:GetFullName())
            else
                warn("Invalid remote path.")
            end
        end
        input:Destroy()
        submitBtn:Destroy()
    end)
end)

-- MPT placeholder
local mptLabel = Instance.new("TextLabel")
mptLabel.Size = UDim2.new(1, -20, 0, 30)
mptLabel.Position = UDim2.new(0, 10, 0, 10)
mptLabel.BackgroundTransparency = 1
mptLabel.Text = "🚧 Mega Power Tycoon features coming soon"
mptLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
mptLabel.Font = Enum.Font.GothamBold
mptLabel.TextSize = 16
mptLabel.Parent = mptContent

print("⚡ Power Tycoon Hub – Loaded successfully. Owner controls active for city800.")
