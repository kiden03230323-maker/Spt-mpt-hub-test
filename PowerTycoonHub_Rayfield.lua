--[[
    POWER TYCOON HUB – Rayfield UI with Key System
    Key: EXOSTAKEOVERR19$
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ============================================
-- RAYFIELD UI SETUP
-- ============================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "⚡ Power Tycoon Hub",
    LoadingTitle = "Loading Power Tycoon Hub...",
    LoadingSubtitle = "Initializing...",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "PowerTycoonHub",
        FileName = "Config"
    },
    KeySystem = true,
    KeySettings = {
        Title = "🔐 Power Tycoon Hub",
        Subtitle = "Enter the key to unlock",
        Note = "Key: EXOSTAKEOVERR19$",
        FileName = "PwrTycoonKey",
        SaveKey = false,
        Key = {"EXOSTAKEOVERR19$"}
    }
})

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
    print("Damage remote auto-detected:", DAMAGE_REMOTE:GetFullName())
else
    warn("No damage remote found – use Game Dumper to find it.")
end

-- ============================================
-- STATE
-- ============================================
local Aura = {
    Enabled = false,
    TargetList = {}
}
local InstantKill = false
local AutoTools = false
local NoCooldown = false
local Reach = false
local ReachMultiplier = 2.0
local FastRespawn = false
local AntiSpawnkill = false

local ToolFollow = {
    Enabled = false,
    Targets = {},
    Connection = nil
}

-- ============================================
-- SUPER POWER TYCOON TAB
-- ============================================
local SPTTab = Window:CreateTab("Super Power Tycoon", 4483362458)

-- Multi-Target Aura Section
local AuraSection = SPTTab:CreateSection("Multi-Target Aura")

local targetListLabel = SPTTab:CreateLabel("Targets: 0 selected")

local targetRefresh
targetRefresh = function()
    local targetPlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(targetPlayers, plr.Name)
        end
    end
    
    local selectedTargets = {}
    for _, plr in ipairs(Aura.TargetList) do
        table.insert(selectedTargets, plr.Name)
    end
    
    SPTTab:CreateDropdown({
        Name = "Select Targets",
        Options = targetPlayers,
        CurrentOption = selectedTargets,
        MultipleOptions = true,
        Flag = "TargetDropdown",
        Callback = function(options)
            Aura.TargetList = {}
            for _, name in ipairs(options) do
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(Aura.TargetList, plr) end
            end
            targetListLabel:Set("Targets: " .. tostring(#Aura.TargetList) .. " selected")
        end
    })
end

local function createTargetRefreshButton()
    SPTTab:CreateButton({
        Name = "🔄 Refresh Players",
        Callback = targetRefresh
    })
end

createTargetRefreshButton()
targetRefresh()

local auraToggle = SPTTab:CreateToggle({
    Name = "Enable Aura",
    CurrentValue = false,
    Flag = "AuraToggle",
    Callback = function(state)
        Aura.Enabled = state
        if state then startAuraLoop() else stopAuraLoop() end
    end
})

SPTTab:CreateToggle({
    Name = "Instant Kill (Proper Delete)",
    CurrentValue = false,
    Flag = "InstantKillToggle",
    Callback = function(state)
        InstantKill = state
    end
})

-- Tool Follow Section
local ToolFollowSection = SPTTab:CreateSection("Tool Follow")

local function createToolFollowTargets()
    local followPlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(followPlayers, plr.Name)
        end
    end
    
    local selectedFollowTargets = {}
    for _, plr in ipairs(ToolFollow.Targets) do
        table.insert(selectedFollowTargets, plr.Name)
    end
    
    SPTTab:CreateDropdown({
        Name = "Select Follow Targets",
        Options = followPlayers,
        CurrentOption = selectedFollowTargets,
        MultipleOptions = true,
        Flag = "FollowTargetDropdown",
        Callback = function(options)
            ToolFollow.Targets = {}
            for _, name in ipairs(options) do
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(ToolFollow.Targets, plr) end
            end
        end
    })
end

local followRefreshBtn = SPTTab:CreateButton({
    Name = "🔄 Refresh Follow Targets",
    Callback = function()
        createToolFollowTargets()
    end
})

createToolFollowTargets()

SPTTab:CreateToggle({
    Name = "Enable Tool Follow",
    CurrentValue = false,
    Flag = "ToolFollowToggle",
    Callback = function(state)
        ToolFollow.Enabled = state
        if state then startToolFollow() else stopToolFollow() end
    end
})

-- Auto Get Tools Section
local AutoToolsSection = SPTTab:CreateSection("Auto Get Tools")

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
SPTTab:CreateToggle({
    Name = "Auto Grab Weapons",
    CurrentValue = false,
    Flag = "AutoGrabToggle",
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
local ToolsSection = SPTTab:CreateSection("Tools & Cooldown")

local toolLoopConn
SPTTab:CreateToggle({
    Name = "Auto Use Tools (0 delay)",
    CurrentValue = false,
    Flag = "AutoUseToolsToggle",
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

SPTTab:CreateToggle({
    Name = "No Cooldown (arms stick)",
    CurrentValue = false,
    Flag = "NoCooldownToggle",
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
                                    if rightArm then local weld = rightArm:FindFirstChild("RightGrip") or rightArm:FindFirstChild("RightShoulder")
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

-- Reach Section with Slider
local ReachSection = SPTTab:CreateSection("Reach")

local reachTrackedParts = {}

local function applyReach()
    local myChar = player.Character; if not myChar then return end
    for _, t in ipairs(myChar:GetChildren()) do
        if t:IsA("Tool") then
            local part = nil
            for _, obj in ipairs(t:GetDescendants()) do if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then part = obj.Parent; break end end
            if not part then part = t:FindFirstChildWhichIsA("BasePart") end
            if part then
                if not reachTrackedParts[part] then
                    -- Store original size
                    reachTrackedParts[part] = {origSize = part.Size}
                    part.Massless = true
                    local hl = Instance.new("Highlight",part)
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(0,150,255)
                    hl.OutlineTransparency = 0
                end
                -- Apply current multiplier
                local tracked = reachTrackedParts[part]
                part.Size = tracked.origSize * ReachMultiplier
            end
        end
    end
end

SPTTab:CreateToggle({
    Name = "Enable Reach",
    CurrentValue = false,
    Flag = "ReachToggle",
    Callback = function(state)
        Reach = state
        if state then
            applyReach()
            player.CharacterAdded:Connect(function()
                reachTrackedParts = {}
                applyReach()
            end)
            task.spawn(function() while Reach do applyReach(); task.wait(0.1) end end)
        end
    end
})

SPTTab:CreateSlider({
    Name = "Reach Size Multiplier",
    Min = 1,
    Max = 10,
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = 2,
    Flag = "ReachSlider",
    Callback = function(value)
        ReachMultiplier = value
        if Reach then
            applyReach()
        end
    end
})

-- Respawn & Protection Section
local RespawnSection = SPTTab:CreateSection("Respawn & Protection")

SPTTab:CreateToggle({
    Name = "Fast Respawn",
    CurrentValue = false,
    Flag = "FastRespawnToggle",
    Callback = function(state)
        FastRespawn = state
        if state then
            local Guide = ReplicatedStorage:FindFirstChild("Guide"); local last = 0
            local function respawn()
                if tick() - last < 0.05 then return end
                last = tick()
                pcall(function() if Guide then Guide:FireServer() else player:LoadCharacter() end end)
            end
            local function hook(c) local hum = c:WaitForChild("Humanoid"); hum.HealthChanged:Connect(function(hp) if hp <= 0 then respawn() end end); hum.Died:Connect(respawn) end
            if player.Character then hook(player.Character) end
            player.CharacterAdded:Connect(hook)
        end
    end
})

SPTTab:CreateToggle({
    Name = "Anti Spawnkill (invincible 3s)",
    CurrentValue = false,
    Flag = "AntiSpawnkillToggle",
    Callback = function(state)
        AntiSpawnkill = state
        if state then
            player.CharacterAdded:Connect(function(c)
                local hum = c:WaitForChild("Humanoid"); hum.MaxHealth = 9e9; hum.Health = 9e9
                local dmgConn = hum.TakeDamage:Connect(function() return 0 end)
                local ff = Instance.new("ForceField",c); ff.Visible = false
                task.delay(3, function() if hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end; if dmgConn then dmgConn:Disconnect() end; if ff then ff:Destroy() end end)
            end)
        end
    end
})

-- Utilities Section
local UtilSection = SPTTab:CreateSection("Utilities")

SPTTab:CreateButton({
    Name = "🔍 Open Game Dumper",
    Callback = function()
        if CoreGui:FindFirstChild("DumperGUI") then return end
        local dGui = Instance.new("ScreenGui",CoreGui); dGui.Name = "DumperGUI"; dGui.ResetOnSpawn = false
        local frame = Instance.new("Frame",dGui); frame.Size = UDim2.new(0,650,0,500); frame.Position = UDim2.new(0.5,-325,0.5,-250); frame.BackgroundColor3 = Color3.fromRGB(15,15,20); frame.Active=true; frame.Draggable=true; Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)
        local title = Instance.new("TextLabel",frame); title.Size=UDim2.new(1,0,0,35); title.BackgroundColor3=Color3.fromRGB(30,30,40); title.Text="🔍 FULL GAME SCANNER"; title.TextColor3=Color3.fromRGB(255,255,255); title.Font=Enum.Font.GothamBold; title.TextSize=18
        local scroll = Instance.new("ScrollingFrame",frame); scroll.Size=UDim2.new(1,-10,1,-80); scroll.Position=UDim2.new(0,5,0,40); scroll.BackgroundTransparency=1; scroll.ScrollBarThickness=8; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
        local list = Instance.new("UIListLayout",scroll); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Padding=UDim.new(0,2)
        local copyBtn = Instance.new("TextButton",frame); copyBtn.Size=UDim2.new(0,120,0,30); copyBtn.Position=UDim2.new(0.5,-160,1,-40); copyBtn.BackgroundColor3=Color3.fromRGB(40,120,200); copyBtn.Text="📋 Copy Log"; copyBtn.TextColor3=Color3.fromRGB(255,255,255); copyBtn.Font=Enum.Font.GothamBold; copyBtn.TextSize=14
        local closeBtn = Instance.new("TextButton",frame); closeBtn.Size=UDim2.new(0,100,0,30); closeBtn.Position=UDim2.new(0.5,30,1,-40); closeBtn.BackgroundColor3=Color3.fromRGB(200,40,40); closeBtn.Text="✖ Close"; closeBtn.TextColor3=Color3.fromRGB(255,255,255); closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=14; closeBtn.MouseButton1Click:Connect(function() dGui:Destroy() end)
        local logLines={}
        local function addLog(text,color) table.insert(logLines,text); local lbl=Instance.new("TextLabel",scroll); lbl.Size=UDim2.new(1,0,0,20); lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=color or Color3.fromRGB(200,200,200); lbl.Font=Enum.Font.Gotham; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true end
        copyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(table.concat(logLines,"\n")) end); addLog("✅ Copied to clipboard!",Color3.fromRGB(100,255,100)) end)
        addLog("🔎 SCANNING ALL GAME OBJECTS...",Color3.fromRGB(255,200,50))
        local function scan(container,depth)
            for _,child in ipairs(container:GetChildren()) do
                local indent=string.rep("  ",depth); local icon="📄"
                if child:IsA("Folder") then icon="📁"; addLog(indent..icon.." "..child.Name.." (Folder)",Color3.fromRGB(255,200,100)); scan(child,depth+1)
                elseif child:IsA("Tool") then icon="🔧"; addLog(indent..icon.." "..child.Name.." (Tool)",Color3.fromRGB(100,255,100))
                elseif child:IsA("Model") then icon="🧩"; addLog(indent..icon.." "..child.Name.." (Model)",Color3.fromRGB(200,200,255))
                elseif child:IsA("RemoteEvent") then icon="📡"; addLog(indent..icon.." "..child.Name.." (RemoteEvent)",Color3.fromRGB(255,150,255))
                elseif child:IsA("RemoteFunction") then icon="📡"; addLog(indent..icon.." "..child.Name.." (RemoteFunction)",Color3.fromRGB(255,150,255))
                elseif child:IsA("BindableEvent") or child:IsA("BindableFunction") then icon="🔗"; addLog(indent..icon.." "..child.Name.." ("..child.ClassName..")",Color3.fromRGB(200,200,255))
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

SPTTab:CreateButton({
    Name = "⚙️ Set Damage Remote",
    Callback = function()
        Rayfield:Notify({
            Title = "Set Damage Remote",
            Content = "Paste the full path in your script executor",
            Duration = 3,
            Image = 4483362458,
        })
    end
})

-- ============================================
-- MEGA POWER TYCOON TAB (Placeholder)
-- ============================================
local MPTTab = Window:CreateTab("Mega Power Tycoon", 4483362458)

MPTTab:CreateLabel("🚧 Mega Power Tycoon features coming soon")

-- ============================================
-- AURA LOOP FUNCTIONS
-- ============================================
local auraConn
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
                        -- Proper deletion method
                        pcall(function()
                            hum.Health = 0
                            task.wait(0.1)
                            if tChar:FindFirstChild("Humanoid") then
                                hum:Destroy()
                            end
                        end)
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
-- TOOL FOLLOW FUNCTIONS
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
-- FINAL NOTIFICATION
-- ============================================
Rayfield:Notify({
    Title = "⚡ Power Tycoon Hub Loaded",
    Content = "All features ready! Key system active.",
    Duration = 4,
    Image = 4483362458,
})

print("⚡ Power Tycoon Hub with Rayfield UI – Ready to use!")
