--[[
POWER TYCOON HUB – ZyronX UI Version
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

-- Respawn handling for Tool Follow
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
-- ZYRONX UI INITIALIZATION
-- ============================================
local Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()

local Window = Library:CreateWindow({
    Title = "Power Tycoon Hub",
    Subtitle = "SPT & MPT",
    SubtitleColor = Color3.fromRGB(100, 200, 255),
    Logo = "rbxassetid://82367817676382",
    LogoSize = 32,
    SphereText = true,
    SphereWords = "PT",
    SphereImage = "rbxassetid://82367817676382",
    SphereIconSize = 38
})

-- ============================================
-- SUPER POWER TYCOON TAB
-- ============================================
local SPT_Tab = Window:CreateTab("Super Power Tycoon", true, false)

-- Page 1: Combat
local SPT_Combat = SPT_Tab:CreatePage("Combat")
local AuraSection = SPT_Combat:CreateSection("Multi-Target Aura")
AuraSection:AddButton("Manage Aura Targets", function() toggleTargetFrame("Aura") end, {Title="Manage Targets", Description="Open the target selection menu for Aura."})
AuraSection:AddToggle("Enable Aura", false, function(state)
    Aura.Enabled = state
    if state then startAuraLoop() else stopAuraLoop() end
end, {Title="Enable Aura", Description="Starts the multi-target aura loop."})
AuraSection:AddToggle("Instant Kill", false, function(state) InstantKill = state end, {Title="Instant Kill", Description="Attempts to brute-force kill targets."})

local ToolFollowSection = SPT_Combat:CreateSection("Tool Follow")
ToolFollowSection:AddButton("Manage Follow Targets", function() toggleTargetFrame("Follow") end, {Title="Manage Targets", Description="Open the target selection menu for Tool Follow."})
ToolFollowSection:AddToggle("Enable Tool Follow", false, function(state)
    ToolFollow.Enabled = state
    if state then startToolFollow() else stopToolFollow() end
end, {Title="Enable Tool Follow", Description="Forces your tools to follow and hit targets."})

-- Page 2: Tycoon
local SPT_Tycoon = SPT_Tab:CreatePage("Tycoon")
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
end, {Title="Auto Grab Weapons", Description="Automatically grabs weapons from tycoon pads."})

local CooldownSection = SPT_Tycoon:CreateSection("Tools & Cooldown")
CooldownSection:AddToggle("Auto Use Tools (0 delay)", false, function(state)
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
end, {Title="Auto Use Tools", Description="Continuously activates all tools in inventory."})

CooldownSection:AddToggle("No Cooldown (arms stick)", false, function(state)
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
end, {Title="No Cooldown", Description="Removes tool cooldowns and modifies arm welds."})

-- Page 3: Movement & Visuals
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
end, {Title="Reach", Description="Expands tool hitboxes and adds an outline."})

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
end, {Title="Fast Respawn", Description="Instantly respawns you upon death."})

RespawnSection:AddToggle("Anti Spawnkill (invincible 3s)", false, function(state)
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
end, {Title="Anti Spawnkill", Description="Grants 3 seconds of invincibility on spawn."})

-- Page 4: Utilities
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
end, {Title="Open Game Dumper", Description="Scans the game and logs remotes/objects."})

UtilsSection:AddTextbox("Damage Remote Path", "game.ReplicatedStorage.DealDamage", function(text)
    if text and text ~= "" then
        local success, remote = pcall(function() return loadstring("return " .. text)() end)
        if success and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            DAMAGE_REMOTE = remote
            print("Damage remote set to: ", DAMAGE_REMOTE:GetFullName())
            Library:Notify({Title = "Remote Set", Description = "Damage remote updated successfully.", Duration = 3})
        else
            warn("Invalid remote path.")
            Library:Notify({Title = "Error", Description = "Invalid remote path.", Duration = 3})
        end
    end
end, {Title="Set Damage Remote", Description="Enter the full path to the damage remote."})

-- ============================================
-- MEGA POWER TYCOON TAB
-- ============================================
local MPT_Tab = Window:CreateTab("Mega Power Tycoon", false, false)
local MPT_Page = MPT_Tab:CreatePage("Coming Soon")
local MPT_Section = MPT_Page:CreateSection("Status")
MPT_Section:AddButton("Placeholder", function() 
    Library:Notify({Title = "MPT", Description = "Mega Power Tycoon features coming soon!", Duration = 3})
end, {Title="MPT Status", Description="Mega Power Tycoon features are currently in development."})

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
    Description = "Successfully initialized with ZyronX UI!",
    Duration = 4
})

print("⚡ Power Tycoon Hub – ZyronX UI Version. Ready for dumper logs to fix Instant Kill.")
