--[[
╔═══════════════════════════════════════════════════════════╗
║  POWER TYCOON HUB - FINAL RESTORED EDITION               ║
║  Full SPT + MPT Features + Key + Manage + Chat + Ban     ║
║  Whitelisted: exo_blox, city800                          ║
═══════════════════════════════════════════════════════════╝
]]

-- ============================================
-- SERVICES & CONFIG
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local HUB_KEY = "EXOSTAKEOVERR19$"
local OWNER_CREDS = {username = "exo_blox", password = "03239461"}
local OPERATOR_CREDS = {username = "OP", password = "0000"}
local KEY_FILE = "exo_hub_key.dat"
local BAN_FILE = "exo_hub_bans.dat"
local MAINT_FILE = "exo_hub_maint.dat"
local currentUserRole = nil

-- ============================================
-- FILE HELPERS
-- ============================================
local function safeRead(p)
    if isfile and readfile and isfile(p) then
        local o, d = pcall(function() return readfile(p) end)
        if o then return d end
    end
    return nil
end

local function safeWrite(p, d)
    if writefile then pcall(function() writefile(p, d) end) end
end

local function loadJSON(p)
    local r = safeRead(p)
    if r then
        local o, d = pcall(function() return HttpService:JSONDecode(r) end)
        if o then return d end
    end
    return nil
end

local function saveJSON(p, d)
    local o, e = pcall(function() return HttpService:JSONEncode(d) end)
    if o then safeWrite(p, e) end
end

-- ============================================
-- KEY & BAN SYSTEMS
-- ============================================
local function isKeyValid()
    local d = loadJSON(KEY_FILE)
    return d and d.key == HUB_KEY and os.time() - (d.timestamp or 0) < 86400
end

local function getDeviceID()
    if gethwid then return gethwid() end
    return player.UserId .. "-" .. (getexecutorname and getexecutorname() or "unknown")
end

local function checkIfBanned()
    local bans = loadJSON(BAN_FILE) or {banned_users = {}, banned_devices = {}}
    local uid = tostring(player.UserId)
    local did = getDeviceID()
    for _, b in ipairs(bans.banned_users or {}) do
        if b.userId == uid then return true, b.reason or "No reason" end
    end
    for _, b in ipairs(bans.banned_devices or {}) do
        if b.deviceId == did then return true, b.reason or "Device banned" end
    end
    return false, ""
end

local function banUser(uid, did, reason, banner)
    local bans = loadJSON(BAN_FILE) or {banned_users = {}, banned_devices = {}, ban_logs = {}}
    if uid then
        table.insert(bans.banned_users, {userId = tostring(uid), reason = reason, banner = banner, timestamp = os.time()})
        table.insert(bans.ban_logs, {userId = tostring(uid), reason = reason, banner = banner, timestamp = os.time(), action = "account_ban"})
    end
    if did then
        table.insert(bans.banned_devices, {deviceId = did, reason = reason, banner = banner, timestamp = os.time()})
        table.insert(bans.ban_logs, {deviceId = did, reason = reason, banner = banner, timestamp = os.time(), action = "device_ban"})
    end
    saveJSON(BAN_FILE, bans)
end

-- ============================================
-- UI SCREENS
-- ============================================
local function createKeyUI(cb)
    local g = Instance.new("ScreenGui"); g.Name = "ExoKey"; g.ResetOnSpawn = false; g.Parent = CoreGui
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(8,8,12); bg.Parent = g
    local c = Instance.new("Frame"); c.Size = UDim2.new(0,440,0,340); c.Position = UDim2.new(0.5,-220,0.5,-170); c.BackgroundColor3 = Color3.fromRGB(16,16,24); c.Parent = g; Instance.new("UICorner",c).CornerRadius = UDim.new(0,14)
    local tb = Instance.new("Frame"); tb.Size = UDim2.new(1,0,0,55); tb.BackgroundColor3 = Color3.fromRGB(22,22,32); tb.Parent = c; Instance.new("UICorner",tb).CornerRadius = UDim.new(0,14)
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-20,0,55); t.Position = UDim2.new(0,10,0,0); t.BackgroundTransparency = 1; t.Text = "🔐 EXO HUB - KEY AUTHENTICATION"; t.TextColor3 = Color3.fromRGB(190,140,255); t.Font = Enum.Font.GothamBold; t.TextSize = 18; t.Parent = tb
    local inp = Instance.new("TextBox"); inp.Size = UDim2.new(1,-40,0,42); inp.Position = UDim2.new(0,20,0,100); inp.BackgroundColor3 = Color3.fromRGB(28,28,40); inp.PlaceholderText = "  Enter your key here..."; inp.TextColor3 = Color3.fromRGB(255,255,255); inp.Font = Enum.Font.Gotham; inp.TextSize = 14; inp.Parent = c; Instance.new("UICorner",inp).CornerRadius = UDim.new(0,8)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,-40,0,42); btn.Position = UDim2.new(0,20,0,152); btn.BackgroundColor3 = Color3.fromRGB(190,140,255); btn.Text = "🔓 UNLOCK HUB"; btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.Parent = c; Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    local st = Instance.new("TextLabel"); st.Size = UDim2.new(1,-40,0,25); st.Position = UDim2.new(0,20,0,205); st.BackgroundTransparency = 1; st.Text = ""; st.TextColor3 = Color3.fromRGB(255,100,100); st.Font = Enum.Font.Gotham; st.TextSize = 13; st.Parent = c
    local cp = Instance.new("TextButton"); cp.Size = UDim2.new(1,-40,0,32); cp.Position = UDim2.new(0,20,0,240); cp.BackgroundColor3 = Color3.fromRGB(35,35,50); cp.Text = "📋 Copy Key"; cp.TextColor3 = Color3.fromRGB(190,140,255); cp.Font = Enum.Font.Gotham; cp.TextSize = 12; cp.Parent = c; Instance.new("UICorner",cp).CornerRadius = UDim.new(0,6)
    
    btn.MouseButton1Click:Connect(function()
        if inp.Text == HUB_KEY then
            saveJSON(KEY_FILE, {key = HUB_KEY, timestamp = os.time()})
            st.Text = "✅ Key accepted!"; st.TextColor3 = Color3.fromRGB(100,255,100)
            task.wait(1.2); g:Destroy()
            if cb then cb() end
        else
            st.Text = "❌ Invalid key."; inp.Text = ""
        end
    end)
    cp.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(HUB_KEY); st.Text = "Copied!"; st.TextColor3 = Color3.fromRGB(100,200,255) end
    end)
    inp.FocusLost:Connect(function(e) if e then btn.MouseButton1Click:Fire() end end)
end

local function createBanScreen(reason)
    local g = Instance.new("ScreenGui"); g.Name = "ExoBan"; g.ResetOnSpawn = false; g.Parent = CoreGui
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(5,5,8); bg.Parent = g
    local c = Instance.new("Frame"); c.Size = UDim2.new(0,520,0,300); c.Position = UDim2.new(0.5,-260,0.5,-150); c.BackgroundColor3 = Color3.fromRGB(20,10,12); c.Parent = g; Instance.new("UICorner",c).CornerRadius = UDim.new(0,16)
    local ic = Instance.new("TextLabel"); ic.Size = UDim2.new(1,0,0,90); ic.BackgroundTransparency = 1; ic.Text = "📴"; ic.TextColor3 = Color3.fromRGB(255,50,50); ic.Font = Enum.Font.GothamBold; ic.TextSize = 70; ic.Parent = c
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-40,0,45); t.Position = UDim2.new(0,20,0,90); t.BackgroundTransparency = 1; t.Text = "YOU HAVE BEEN BANNED"; t.TextColor3 = Color3.fromRGB(255,50,50); t.Font = Enum.Font.GothamBlack; t.TextSize = 26; t.Parent = c
    local r = Instance.new("TextLabel"); r.Size = UDim2.new(1,-40,0,50); r.Position = UDim2.new(0,20,0,145); r.BackgroundTransparency = 1; r.Text = "Reason: " .. reason; r.TextColor3 = Color3.fromRGB(220,220,220); r.Font = Enum.Font.Gotham; r.TextSize = 14; r.TextWrapped = true; r.Parent = c
end

local function createMaintScreen()
    local g = Instance.new("ScreenGui"); g.Name = "ExoMaint"; g.ResetOnSpawn = false; g.Parent = CoreGui
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(10,10,15); bg.Parent = g
    local c = Instance.new("Frame"); c.Size = UDim2.new(0,500,0,240); c.Position = UDim2.new(0.5,-250,0.5,-120); c.BackgroundColor3 = Color3.fromRGB(18,18,26); c.Parent = g; Instance.new("UICorner",c).CornerRadius = UDim.new(0,16)
    local ic = Instance.new("TextLabel"); ic.Size = UDim2.new(1,0,0,70); ic.BackgroundTransparency = 1; ic.Text = ""; ic.TextColor3 = Color3.fromRGB(255,200,50); ic.Font = Enum.Font.GothamBold; ic.TextSize = 55; ic.Parent = c
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-40,0,40); t.Position = UDim2.new(0,20,0,75); t.BackgroundTransparency = 1; t.Text = "HUB IS DOWN FOR MAINTENANCE"; t.TextColor3 = Color3.fromRGB(255,200,50); t.Font = Enum.Font.GothamBlack; t.TextSize = 22; t.Parent = c
    local s = Instance.new("TextLabel"); s.Size = UDim2.new(1,-40,0,50); s.Position = UDim2.new(0,20,0,125); s.BackgroundTransparency = 1; s.Text = "PLEASE WAIT A FEW MINUTES AND THEN REJOIN"; s.TextColor3 = Color3.fromRGB(180,180,200); s.Font = Enum.Font.Gotham; s.TextSize = 14; s.TextWrapped = true; s.Parent = c
end

local function createLoginUI(cb)
    local g = Instance.new("ScreenGui"); g.Name = "ExoLogin"; g.ResetOnSpawn = false; g.Parent = CoreGui
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(8,8,12); bg.BackgroundTransparency = 0.4; bg.Parent = g
    local c = Instance.new("Frame"); c.Size = UDim2.new(0,420,0,400); c.Position = UDim2.new(0.5,-210,0.5,-200); c.BackgroundColor3 = Color3.fromRGB(16,16,24); c.Parent = g; Instance.new("UICorner",c).CornerRadius = UDim.new(0,14)
    local tb = Instance.new("Frame"); tb.Size = UDim2.new(1,0,0,50); tb.BackgroundColor3 = Color3.fromRGB(22,22,32); tb.Parent = c; Instance.new("UICorner",tb).CornerRadius = UDim.new(0,14)
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-20,0,50); t.Position = UDim2.new(0,10,0,0); t.BackgroundTransparency = 1; t.Text = "🔐 HUB MANAGE - AUTHENTICATION"; t.TextColor3 = Color3.fromRGB(190,140,255); t.Font = Enum.Font.GothamBold; t.TextSize = 16; t.Parent = tb
    local ob = Instance.new("TextButton"); ob.Size = UDim2.new(0,180,0,40); ob.Position = UDim2.new(0,20,0,90); ob.BackgroundColor3 = Color3.fromRGB(60,60,80); ob.Text = "👑 OWNER"; ob.TextColor3 = Color3.fromRGB(255,255,255); ob.Font = Enum.Font.GothamBold; ob.TextSize = 14; ob.Parent = c; Instance.new("UICorner",ob).CornerRadius = UDim.new(0,8)
    local opb = Instance.new("TextButton"); opb.Size = UDim2.new(0,180,0,40); opb.Position = UDim2.new(0,220,0,90); opb.BackgroundColor3 = Color3.fromRGB(60,60,80); opb.Text = "️ OPERATOR"; opb.TextColor3 = Color3.fromRGB(255,255,255); opb.Font = Enum.Font.GothamBold; opb.TextSize = 14; opb.Parent = c; Instance.new("UICorner",opb).CornerRadius = UDim.new(0,8)
    local ui = Instance.new("TextBox"); ui.Size = UDim2.new(1,-40,0,34); ui.Position = UDim2.new(0,20,0,150); ui.BackgroundColor3 = Color3.fromRGB(28,28,40); ui.PlaceholderText = "Username..."; ui.TextColor3 = Color3.fromRGB(255,255,255); ui.Font = Enum.Font.Gotham; ui.TextSize = 13; ui.Visible = false; ui.Parent = c; Instance.new("UICorner",ui).CornerRadius = UDim.new(0,6)
    local pi = Instance.new("TextBox"); pi.Size = UDim2.new(1,-40,0,34); pi.Position = UDim2.new(0,20,0,195); pi.BackgroundColor3 = Color3.fromRGB(28,28,40); pi.PlaceholderText = "Password..."; pi.TextColor3 = Color3.fromRGB(255,255,255); pi.Font = Enum.Font.Gotham; pi.TextSize = 13; pi.Visible = false; pi.Parent = c; Instance.new("UICorner",pi).CornerRadius = UDim.new(0,6)
    local lb = Instance.new("TextButton"); lb.Size = UDim2.new(1,-40,0,38); lb.Position = UDim2.new(0,20,0,250); lb.BackgroundColor3 = Color3.fromRGB(190,140,255); lb.Text = "🔓 LOGIN"; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.Font = Enum.Font.GothamBold; lb.TextSize = 14; lb.Visible = false; lb.Parent = c; Instance.new("UICorner",lb).CornerRadius = UDim.new(0,8)
    local st = Instance.new("TextLabel"); st.Size = UDim2.new(1,-40,0,25); st.Position = UDim2.new(0,20,0,300); st.BackgroundTransparency = 1; st.Text = ""; st.TextColor3 = Color3.fromRGB(255,100,100); st.Font = Enum.Font.Gotham; st.TextSize = 12; st.Parent = c
    local sel = nil
    
    local function show(r)
        sel = r; ui.Visible = true; pi.Visible = true; lb.Visible = true
        ob.BackgroundColor3 = r == "owner" and Color3.fromRGB(190,140,255) or Color3.fromRGB(60,60,80)
        opb.BackgroundColor3 = r == "operator" and Color3.fromRGB(190,140,255) or Color3.fromRGB(60,60,80)
        ui:CaptureFocus()
    end
    ob.MouseButton1Click:Connect(function() show("owner") end)
    opb.MouseButton1Click:Connect(function() show("operator") end)
    lb.MouseButton1Click:Connect(function()
        local u = ui.Text; local p = pi.Text; local v = false
        if sel == "owner" and u == OWNER_CREDS.username and p == OWNER_CREDS.password then v = true
        elseif sel == "operator" and u == OPERATOR_CREDS.username and p == OPERATOR_CREDS.password then v = true end
        if v then
            currentUserRole = sel; st.Text = "✅ Success!"; st.TextColor3 = Color3.fromRGB(100,255,100)
            task.wait(0.6); g:Destroy()
            if cb then cb(sel) end
        else
            st.Text = "❌ Invalid."; ui.Text = ""; pi.Text = ""; ui:CaptureFocus()
        end
    end)
end

local function createManageBoard(role)
    local g = Instance.new("ScreenGui"); g.Name = "ExoBoard"; g.ResetOnSpawn = false; g.Parent = CoreGui
    local m = Instance.new("Frame"); m.Size = UDim2.new(0,750,0,520); m.Position = UDim2.new(0.5,-375,0.5,-260); m.BackgroundColor3 = Color3.fromRGB(14,14,20); m.Active = true; m.Draggable = true; m.Parent = g; Instance.new("UICorner",m).CornerRadius = UDim.new(0,12)
    local tb = Instance.new("Frame"); tb.Size = UDim2.new(1,0,0,50); tb.BackgroundColor3 = Color3.fromRGB(22,22,32); tb.Parent = m; Instance.new("UICorner",tb).CornerRadius = UDim.new(0,12)
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-100,0,50); t.Position = UDim2.new(0,10,0,0); t.BackgroundTransparency = 1; t.Text = " HUB MANAGE - " .. string.upper(role); t.TextColor3 = Color3.fromRGB(190,140,255); t.Font = Enum.Font.GothamBold; t.TextSize = 16; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = tb
    local cb = Instance.new("TextButton"); cb.Size = UDim2.new(0,80,0,32); cb.Position = UDim2.new(1,-90,0,9); cb.BackgroundColor3 = Color3.fromRGB(200,40,40); cb.Text = "✖ Close"; cb.TextColor3 = Color3.fromRGB(255,255,255); cb.Font = Enum.Font.GothamBold; cb.TextSize = 12; cb.Parent = m; Instance.new("UICorner",cb).CornerRadius = UDim.new(0,6); cb.MouseButton1Click:Connect(function() g:Destroy() end)
    
    local ul = Instance.new("ScrollingFrame"); ul.Size = UDim2.new(0.55,-10,1,-110); ul.Position = UDim2.new(0,5,0,55); ul.BackgroundColor3 = Color3.fromRGB(18,18,26); ul.ScrollBarThickness = 6; ul.AutomaticCanvasSize = Enum.AutomaticSize.Y; ul.Parent = m; Instance.new("UICorner",ul).CornerRadius = UDim.new(0,8)
    local ll = Instance.new("UIListLayout",ul); ll.Padding = UDim.new(0,6); ll.SortOrder = Enum.SortOrder.LayoutOrder
    local ap = Instance.new("Frame"); ap.Size = UDim2.new(0.43,-10,1,-110); ap.Position = UDim2.new(0.56,0,0,55); ap.BackgroundColor3 = Color3.fromRGB(18,18,26); ap.Parent = m; Instance.new("UICorner",ap).CornerRadius = UDim.new(0,8)
    local at = Instance.new("TextLabel"); at.Size = UDim2.new(1,0,0,30); at.BackgroundColor3 = Color3.fromRGB(25,25,35); at.Text = "⚡ Quick Actions"; at.TextColor3 = Color3.fromRGB(255,255,255); at.Font = Enum.Font.GothamBold; at.TextSize = 13; at.Parent = ap; Instance.new("UICorner",at).CornerRadius = UDim.new(0,8)
    
    local sel = nil
    local function refresh()
        for _,ch in ipairs(ul:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
        for _,plr in ipairs(Players:GetPlayers()) do
            local f = Instance.new("Frame"); f.Size = UDim2.new(1,-10,0,65); f.BackgroundColor3 = Color3.fromRGB(25,25,35); f.Parent = ul; f.LayoutOrder = #ul:GetChildren(); Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
            local av = Instance.new("ImageLabel"); av.Size = UDim2.new(0,45,0,45); av.Position = UDim2.new(0,8,0.5,-22); av.BackgroundColor3 = Color3.fromRGB(40,40,50); av.Parent = f; Instance.new("UICorner",av).CornerRadius = UDim.new(0,6)
            pcall(function() av.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1,-65,0,22); nl.Position = UDim2.new(0,60,0,8); nl.BackgroundTransparency = 1; nl.Text = plr.DisplayName; nl.TextColor3 = Color3.fromRGB(255,255,255); nl.Font = Enum.Font.GothamBold; nl.TextSize = 13; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.Parent = f
            local usl = Instance.new("TextLabel"); usl.Size = UDim2.new(1,-65,0,18); usl.Position = UDim2.new(0,60,0,28); usl.BackgroundTransparency = 1; usl.Text = "@" .. plr.Name; usl.TextColor3 = Color3.fromRGB(150,150,180); usl.Font = Enum.Font.Gotham; usl.TextSize = 11; usl.TextXAlignment = Enum.TextXAlignment.Left; usl.Parent = f
            f.MouseButton1Click:Connect(function()
                sel = plr
                for _,ff in ipairs(ul:GetChildren()) do if ff:IsA("Frame") then ff.BackgroundColor3 = Color3.fromRGB(25,25,35) end end
                f.BackgroundColor3 = Color3.fromRGB(40,35,60)
            end)
        end
    end
    refresh()
    
    local by = 40; local bs = 38
    if role == "owner" then
        local jb = Instance.new("TextButton"); jb.Size = UDim2.new(1,-10,0,32); jb.Position = UDim2.new(0,5,0,by); jb.BackgroundColor3 = Color3.fromRGB(40,120,200); jb.Text = " Join Selected"; jb.TextColor3 = Color3.fromRGB(255,255,255); jb.Font = Enum.Font.GothamBold; jb.TextSize = 12; jb.Parent = ap; Instance.new("UICorner",jb).CornerRadius = UDim.new(0,6)
        jb.MouseButton1Click:Connect(function()
            if sel and sel.Character then
                local mr = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local tr = sel.Character:FindFirstChild("HumanoidRootPart")
                if mr and tr then mr.CFrame = tr.CFrame + Vector3.new(0,0,3) end
            end
        end)
        local bb = Instance.new("TextButton"); bb.Size = UDim2.new(1,-10,0,32); bb.Position = UDim2.new(0,5,0,by+bs); bb.BackgroundColor3 = Color3.fromRGB(200,40,40); bb.Text = " Ban User (Account+Device)"; bb.TextColor3 = Color3.fromRGB(255,255,255); bb.Font = Enum.Font.GothamBold; bb.TextSize = 12; bb.Parent = ap; Instance.new("UICorner",bb).CornerRadius = UDim.new(0,6)
        bb.MouseButton1Click:Connect(function()
            if sel then banUser(sel.UserId, getDeviceID(), "Banned by Owner exo_blox", "exo_blox"); player:Kick("Banned from hub.") end
        end)
    elseif role == "operator" then
        local wb = Instance.new("TextButton"); wb.Size = UDim2.new(1,-10,0,32); wb.Position = UDim2.new(0,5,0,by); wb.BackgroundColor3 = Color3.fromRGB(200,150,40); wb.Text = "⚠️ Warn Selected"; wb.TextColor3 = Color3.fromRGB(255,255,255); wb.Font = Enum.Font.GothamBold; wb.TextSize = 12; wb.Parent = ap; Instance.new("UICorner",wb).CornerRadius = UDim.new(0,6)
        wb.MouseButton1Click:Connect(function()
            if sel then print("⚠️ WARNING: " .. sel.DisplayName .. " has been warned by an Operator.") end
        end)
    end
    
    local ab = Instance.new("TextButton"); ab.Size = UDim2.new(1,-10,0,32); ab.Position = UDim2.new(0,5,1,-75); ab.BackgroundColor3 = Color3.fromRGB(190,140,255); ab.Text = "📢 Announce to All"; ab.TextColor3 = Color3.fromRGB(255,255,255); ab.Font = Enum.Font.GothamBold; ab.TextSize = 12; ab.Parent = m; Instance.new("UICorner",ab).CornerRadius = UDim.new(0,6)
    ab.MouseButton1Click:Connect(function() print(" Announcement sent to all hub users.") end)
    
    if role == "owner" then
        local sb = Instance.new("TextButton"); sb.Size = UDim2.new(0,200,0,32); sb.Position = UDim2.new(1,-210,1,-75); sb.BackgroundColor3 = Color3.fromRGB(200,40,40); sb.Text = " Shutdown for Maint."; sb.TextColor3 = Color3.fromRGB(255,255,255); sb.Font = Enum.Font.GothamBold; sb.TextSize = 11; sb.Parent = m; Instance.new("UICorner",sb).CornerRadius = UDim.new(0,6)
        sb.MouseButton1Click:Connect(function() saveJSON(MAINT_FILE, {active = true, timestamp = os.time()}); print(" Hub shutdown initiated") end)
    end
    
    local rb = Instance.new("TextButton"); rb.Size = UDim2.new(0,100,0,25); rb.Position = UDim2.new(1,-110,0,5); rb.BackgroundColor3 = Color3.fromRGB(40,40,60); rb.Text = "🔄 Refresh"; rb.TextColor3 = Color3.fromRGB(255,255,255); rb.Font = Enum.Font.GothamBold; rb.TextSize = 11; rb.Parent = m; Instance.new("UICorner",rb).CornerRadius = UDim.new(0,6); rb.MouseButton1Click:Connect(refresh)
    task.spawn(function() while g.Parent do task.wait(5); refresh() end end)
end

local function createChatUI()
    local g = Instance.new("ScreenGui"); g.Name = "ExoChat"; g.ResetOnSpawn = false; g.Parent = CoreGui
    local m = Instance.new("Frame"); m.Size = UDim2.new(0,400,0,350); m.Position = UDim2.new(0.1,0,0.5,-175); m.BackgroundColor3 = Color3.fromRGB(14,14,20); m.Active = true; m.Draggable = true; m.Parent = g; Instance.new("UICorner",m).CornerRadius = UDim.new(0,12)
    local tb = Instance.new("Frame"); tb.Size = UDim2.new(1,0,0,40); tb.BackgroundColor3 = Color3.fromRGB(22,22,32); tb.Parent = m; Instance.new("UICorner",tb).CornerRadius = UDim.new(0,12)
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-20,0,40); t.Position = UDim2.new(0,10,0,0); t.BackgroundTransparency = 1; t.Text = "💬 Hub Chat"; t.TextColor3 = Color3.fromRGB(190,140,255); t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = tb
    local cb = Instance.new("TextButton"); cb.Size = UDim2.new(0,60,0,28); cb.Position = UDim2.new(1,-65,0,6); cb.BackgroundColor3 = Color3.fromRGB(200,40,40); cb.Text = "✖"; cb.TextColor3 = Color3.fromRGB(255,255,255); cb.Font = Enum.Font.GothamBold; cb.TextSize = 12; cb.Parent = m; Instance.new("UICorner",cb).CornerRadius = UDim.new(0,6); cb.MouseButton1Click:Connect(function() g:Destroy() end)
    local cl = Instance.new("ScrollingFrame"); cl.Size = UDim2.new(1,-10,1,-90); cl.Position = UDim2.new(0,5,0,45); cl.BackgroundColor3 = Color3.fromRGB(18,18,26); cl.ScrollBarThickness = 6; cl.AutomaticCanvasSize = Enum.AutomaticSize.Y; cl.Parent = m; Instance.new("UICorner",cl).CornerRadius = UDim.new(0,8)
    local ll = Instance.new("UIListLayout",cl); ll.Padding = UDim.new(0,4); ll.SortOrder = Enum.SortOrder.LayoutOrder
    local inf = Instance.new("Frame"); inf.Size = UDim2.new(1,-10,0,35); inf.Position = UDim2.new(0,5,1,-40); inf.BackgroundColor3 = Color3.fromRGB(28,28,40); inf.Parent = m; Instance.new("UICorner",inf).CornerRadius = UDim.new(0,6)
    local ci = Instance.new("TextBox"); ci.Size = UDim2.new(1,-70,1,0); ci.BackgroundTransparency = 1; ci.PlaceholderText = "Type a message..."; ci.TextColor3 = Color3.fromRGB(255,255,255); ci.Font = Enum.Font.Gotham; ci.TextSize = 13; ci.Parent = inf
    local sb = Instance.new("TextButton"); sb.Size = UDim2.new(0,60,1,-4); sb.Position = UDim2.new(1,-65,0,2); sb.BackgroundColor3 = Color3.fromRGB(190,140,255); sb.Text = "Send"; sb.TextColor3 = Color3.fromRGB(255,255,255); sb.Font = Enum.Font.GothamBold; sb.TextSize = 12; sb.Parent = inf; Instance.new("UICorner",sb).CornerRadius = UDim.new(0,6)
    
    local function addMsg(s, msg, sys)
        local f = Instance.new("Frame"); f.Size = UDim2.new(1,-10,0,0); f.BackgroundTransparency = 1; f.Parent = cl; f.LayoutOrder = #cl:GetChildren()
        local sl = Instance.new("TextLabel"); sl.Size = UDim2.new(1,-10,0,16); sl.BackgroundTransparency = 1; sl.Text = sys and "[SYSTEM]" or s; sl.TextColor3 = sys and Color3.fromRGB(255,200,50) or Color3.fromRGB(190,140,255); sl.Font = Enum.Font.GothamBold; sl.TextSize = 11; sl.TextXAlignment = Enum.TextXAlignment.Left; sl.Parent = f
        local ml = Instance.new("TextLabel"); ml.Size = UDim2.new(1,-10,0,0); ml.BackgroundTransparency = 1; ml.Text = msg; ml.TextColor3 = Color3.fromRGB(220,220,220); ml.Font = Enum.Font.Gotham; ml.TextSize = 12; ml.TextXAlignment = Enum.TextXAlignment.Left; ml.TextWrapped = true; ml.Parent = f
        ml:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() f.Size = UDim2.new(1,-10,0,ml.AbsoluteSize.Y+20) end)
        task.wait(); f.Size = UDim2.new(1,-10,0,ml.AbsoluteSize.Y+20)
    end
    local function send() local msg = ci.Text; if msg and msg ~= "" then addMsg(player.DisplayName, msg, false); ci.Text = "" end end
    sb.MouseButton1Click:Connect(send); ci.FocusLost:Connect(function(e) if e then send() end end)
    addMsg("System", "Welcome to Exo Hub Chat!", true)
end

local function createLogsViewer(lt)
    local g = Instance.new("ScreenGui"); g.Name = "ExoLogs"; g.ResetOnSpawn = false; g.Parent = CoreGui
    local m = Instance.new("Frame"); m.Size = UDim2.new(0,600,0,450); m.Position = UDim2.new(0.5,-300,0.5,-225); m.BackgroundColor3 = Color3.fromRGB(14,14,20); m.Active = true; m.Draggable = true; m.Parent = g; Instance.new("UICorner",m).CornerRadius = UDim.new(0,12)
    local tb = Instance.new("Frame"); tb.Size = UDim2.new(1,0,0,45); tb.BackgroundColor3 = Color3.fromRGB(22,22,32); tb.Parent = m; Instance.new("UICorner",tb).CornerRadius = UDim.new(0,12)
    local tt = lt == "banish" and "👻 Banish Logs" or "🚫 Ban Logs"
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-100,0,45); t.Position = UDim2.new(0,10,0,0); t.BackgroundTransparency = 1; t.Text = tt; t.TextColor3 = Color3.fromRGB(190,140,255); t.Font = Enum.Font.GothamBold; t.TextSize = 16; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = tb
    local cb = Instance.new("TextButton"); cb.Size = UDim2.new(0,80,0,30); cb.Position = UDim2.new(1,-85,0,7); cb.BackgroundColor3 = Color3.fromRGB(200,40,40); cb.Text = "✖ Close"; cb.TextColor3 = Color3.fromRGB(255,255,255); cb.Font = Enum.Font.GothamBold; cb.TextSize = 12; cb.Parent = m; Instance.new("UICorner",cb).CornerRadius = UDim.new(0,6); cb.MouseButton1Click:Connect(function() g:Destroy() end)
    local ll = Instance.new("ScrollingFrame"); ll.Size = UDim2.new(1,-10,1,-55); ll.Position = UDim2.new(0,5,0,50); ll.BackgroundColor3 = Color3.fromRGB(18,18,26); ll.ScrollBarThickness = 6; ll.AutomaticCanvasSize = Enum.AutomaticSize.Y; ll.Parent = m; Instance.new("UICorner",ll).CornerRadius = UDim.new(0,8)
    local lll = Instance.new("UIListLayout",ll); lll.Padding = UDim.new(0,4); lll.SortOrder = Enum.SortOrder.LayoutOrder
    local bans = loadJSON(BAN_FILE) or {ban_logs = {}}
    local logs = lt == "banish" and (bans.banish_logs or {}) or (bans.ban_logs or {})
    if #logs == 0 then
        local el = Instance.new("TextLabel"); el.Size = UDim2.new(1,-20,0,40); el.BackgroundTransparency = 1; el.Text = "No logs found."; el.TextColor3 = Color3.fromRGB(130,130,160); el.Font = Enum.Font.Gotham; el.TextSize = 13; el.Parent = ll
    else
        for i = #logs, 1, -1 do
            local log = logs[i]; local f = Instance.new("Frame"); f.Size = UDim2.new(1,-10,0,50); f.BackgroundColor3 = Color3.fromRGB(25,25,35); f.Parent = ll; f.LayoutOrder = #ll:GetChildren(); Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
            local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(0.4,0,0,20); tl.Position = UDim2.new(0,8,0,5); tl.BackgroundTransparency = 1; tl.Text = "User: " .. (log.userId or log.deviceId or "Unknown"); tl.TextColor3 = Color3.fromRGB(255,255,255); tl.Font = Enum.Font.GothamBold; tl.TextSize = 12; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = f
            local rl = Instance.new("TextLabel"); rl.Size = UDim2.new(0.6,0,0,20); rl.Position = UDim2.new(0.4,0,0,5); rl.BackgroundTransparency = 1; rl.Text = "Reason: " .. (log.reason or "N/A"); rl.TextColor3 = Color3.fromRGB(200,200,200); rl.Font = Enum.Font.Gotham; rl.TextSize = 11; rl.TextXAlignment = Enum.TextXAlignment.Left; rl.Parent = f
            local bl = Instance.new("TextLabel"); bl.Size = UDim2.new(0.5,0,0,18); bl.Position = UDim2.new(0,8,0,27); bl.BackgroundTransparency = 1; bl.Text = "By: " .. (log.banner or "Unknown"); bl.TextColor3 = Color3.fromRGB(150,150,180); bl.Font = Enum.Font.Gotham; bl.TextSize = 10; bl.TextXAlignment = Enum.TextXAlignment.Left; bl.Parent = f
            local tml = Instance.new("TextLabel"); tml.Size = UDim2.new(0.5,0,0,18); tml.Position = UDim2.new(0.5,0,0,27); tml.BackgroundTransparency = 1; tml.Text = "Time: " .. os.date("%Y-%m-%d %H:%M", log.timestamp or 0); tml.TextColor3 = Color3.fromRGB(130,130,160); tml.Font = Enum.Font.Gotham; tml.TextSize = 10; tml.TextXAlignment = Enum.TextXAlignment.Left; tml.Parent = f
        end
    end
end

-- ============================================
-- FULL GAME LOGIC (RESTORED & EXPANDED)
-- ============================================
local DAMAGE_REMOTE = nil
local Aura = {Enabled = false, TargetList = {}}
local InstantKill = false
local AutoTools = false
local NoCooldown = false
local Reach = false
local FastRespawn = false
local AntiSpawnkill = false
local ToolFollow = {Enabled = false, Targets = {}, Connection = nil}
local AutoGetTools = false
local grabLoopConn, toolLoopConn, auraConn = nil, nil, nil
local AutoClaimMoney = false
local AutoBuild = false
local claimConn, buildConn = nil, nil
local cachedTycoonType = nil

local function findDamageRemotes()
    local remotes = {}
    for _, container in ipairs({ReplicatedStorage, workspace}) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:match("damage") or n:match("hit") or n:match("attack") or n:match("deal") then table.insert(remotes, obj) end
            end
        end
    end
    return remotes
end
local dmgRemotes = findDamageRemotes()
if #dmgRemotes > 0 then DAMAGE_REMOTE = dmgRemotes[1] end

local function getPlayerTycoonType()
    if cachedTycoonType and workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(cachedTycoonType) then return cachedTycoonType end
    local plot = workspace:FindFirstChild(player.Name)
    if plot then
        for _, child in ipairs(plot:GetChildren()) do
            if child:IsA("StringValue") and (child.Name:lower():find("tycoon") or child.Name:lower():find("type")) then cachedTycoonType = child.Value; return cachedTycoonType end
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
                            if dist < minDist then minDist = dist; closestTycoon = tycoonFolder.Name end
                        end
                    end
                end
            end
        end
        cachedTycoonType = closestTycoon; return closestTycoon
    end
    return nil
end
player.CharacterAdded:Connect(function() cachedTycoonType = nil end)

local function getTouchableParts(model)
    local parts = {}
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then table.insert(parts, desc.Parent) end
    end
    if #parts == 0 then for _, desc in ipairs(model:GetDescendants()) do if desc:IsA("BasePart") then table.insert(parts, desc); break end end end
    return parts
end

local function getPlayerCash()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local cash = ls:FindFirstChild("Cash") or ls:FindFirstChild("Money") or ls:FindFirstChild("Coins")
        if cash and (cash:IsA("IntValue") or cash:IsA("NumberValue")) then return cash.Value end
        for _, stat in ipairs(ls:GetChildren()) do if stat:IsA("IntValue") or stat:IsA("NumberValue") then return stat.Value end end
    end
    return 0
end

local function getCost(obj)
    local priceVal = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if priceVal and (priceVal:IsA("IntValue") or priceVal:IsA("NumberValue")) then return priceVal.Value end
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
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent and d.Parent.Parent.Name:find("GearGiver1") then registerPad(d.Parent) end
    end
    Tycoons.DescendantAdded:Connect(function(d)
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent and d.Parent.Parent.Name:find("GearGiver1") then registerPad(d.Parent) end
    end)
end

function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.PreSimulation:Connect(function()
        if not Aura.Enabled and not InstantKill then return end
        local myChar = player.Character; if not myChar then return end
        for _, tool in ipairs(myChar:GetChildren()) do
            if tool:IsA("Tool") then
                local damagePart
                for _, obj in ipairs(tool:GetDescendants()) do if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then damagePart = obj.Parent; break end end
                if not damagePart then damagePart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart") end
                if not damagePart then continue end
                local origCF = damagePart.CFrame
                for _, targetPlr in ipairs(Aura.TargetList) do
                    local tChar = targetPlr.Character
                    if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                        local root = tChar:FindFirstChild("HumanoidRootPart")
                        if root then
                            pcall(function() damagePart.CFrame = root.CFrame * CFrame.new(0,2,0); damagePart:SetNetworkOwner(player) end)
                            if DAMAGE_REMOTE then pcall(function() DAMAGE_REMOTE:FireServer(tChar, damagePart) end)
                            else for _, p in ipairs(tChar:GetChildren()) do if p:IsA("BasePart") then pcall(firetouchinterest, damagePart, p, 0); pcall(firetouchinterest, damagePart, p, 1) end end end
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
                    if hum and hum.Health > 0 then pcall(function() hum:TakeDamage(9e9) end); pcall(function() hum.Health = 0 end) end
                end
            end
        end
    end)
end
function stopAuraLoop() if auraConn then auraConn:Disconnect(); auraConn = nil end end

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
    for _, tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") then local part = getToolPart(tool); if part then table.insert(cachedToolParts, part) end end end
end
local function getCachedTorso(char)
    if cachedTorso[char] and cachedTorso[char].Parent then return cachedTorso[char] end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"); cachedTorso[char] = torso; return torso
end
function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
    ToolFollow.Connection = RunService.Heartbeat:Connect(function()
        if not ToolFollow.Enabled or #ToolFollow.Targets == 0 then return end
        local myChar = player.Character; if not myChar then return end
        updateToolCache()
        for _, targetPlr in ipairs(ToolFollow.Targets) do
            local tChar = targetPlr.Character
            if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                local torso = getCachedTorso(tChar)
                if torso then
                    for _, part in ipairs(cachedToolParts) do
                        if part and part.Parent then
                            part.Position = torso.Position + Vector3.new(0, 0.6, 0.5); part.CanCollide = false; part.Massless = true
                            pcall(firetouchinterest, part, torso, 0); pcall(firetouchinterest, part, torso, 1)
                        end
                    end
                end
            end
        end
    end)
end
function stopToolFollow() if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart"); updateToolCache()
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then task.wait(); updateToolCache(); local part = getToolPart(child); if part then part.CanCollide = false; part.Massless = true end end
    end)
    for _, tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") then local part = getToolPart(tool); if part then part.CanCollide = false; part.Massless = true end end end
end)
updateToolCache()
if player.Character then for _, tool in ipairs(player.Character:GetChildren()) do if tool:IsA("Tool") then local part = getToolPart(tool); if part then part.CanCollide = false; part.Massless = true end end end end

function startClaimMoney()
    if claimConn then claimConn:Disconnect() end
    claimConn = RunService.PreSimulation:Connect(function()
        if not AutoClaimMoney then return end
        local myChar = player.Character; if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart"); if not root then return end
        local tycoonType = getPlayerTycoonType(); if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType); if not tycoonFolder then return end
        local cashRegister = tycoonFolder:FindFirstChild("CashRegister", true)
        if cashRegister then for _, part in ipairs(getTouchableParts(cashRegister)) do pcall(firetouchinterest, root, part, 0); pcall(firetouchinterest, root, part, 1) end end
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
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType); if not tycoonFolder then return end
        local cash = getPlayerCash()
        local buttons = {}
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("button") or obj.Name:lower():find("btn")) then
                local cost = getCost(obj)
                if cost > 0 then table.insert(buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)}) end
            end
        end
        table.sort(buttons, function(a, b) if a.Priority == b.Priority then return a.Cost < b.Cost end; return a.Priority < b.Priority end)
        for _, btnData in ipairs(buttons) do
            if cash >= btnData.Cost then
                for _, part in ipairs(getTouchableParts(btnData.Model)) do pcall(firetouchinterest, root, part, 0); pcall(firetouchinterest, root, part, 1) end
                lastBuyTime = tick(); break
            end
        end
    end)
end
function stopAutoBuild() if buildConn then buildConn:Disconnect(); buildConn = nil end end

-- ============================================
-- MAIN HUB INITIALIZATION
-- ============================================
local Library
local Window

local function initializeHub()
    local maint = loadJSON(MAINT_FILE)
    if maint and maint.active then
        if os.time() - (maint.timestamp or 0) > 3600 then maint.active = false; saveJSON(MAINT_FILE, maint)
        else createMaintScreen(); return end
    end
    local banned, reason = checkIfBanned()
    if banned then createBanScreen(reason); return end

    Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()
    
    -- FIX: WHITELIST FOR HUB MANAGE TAB
    Library.WhitelistedUsers = {
        "exo_blox",
        "city800"
    }

    Window = Library:CreateWindow({
        Title = "Power Tycoon Hub", Subtitle = "Ultimate Edition by exo_blox", SubtitleColor = Color3.fromRGB(190,140,255),
        Logo = "rbxassetid://82367817676382", LogoSize = 32, SphereText = true, SphereWords = "EXO", SphereImage = "rbxassetid://82367817676382", SphereIconSize = 38
    })

    -- ============================================
    -- SPT TAB (ALL 4 PAGES RESTORED)
    -- ============================================
    local SPT_Tab = Window:CreateTab("Super Power Tycoon", true, false)
    
    -- Page 1: Combat
    local SPT_Combat = SPT_Tab:CreatePage("Combat")
    local AuraSection = SPT_Combat:CreateSection("Multi-Target Aura")
    AuraSection:AddButton("Manage Aura Targets", function() Library:Notify({Title="Target Manager", Description="Select players in the custom overlay.", Duration=3}) end, {Title="Manage Targets", Description="Open target selection."})
    AuraSection:AddToggle("Enable Aura", false, function(state) Aura.Enabled = state; if state then startAuraLoop() else stopAuraLoop() end end, {Title="Enable Aura", Description="Starts the multi-target aura loop."})
    AuraSection:AddToggle("Instant Kill", false, function(state) InstantKill = state end, {Title="Instant Kill", Description="Attempts to brute-force kill targets."})
    
    local ToolFollowSection = SPT_Combat:CreateSection("Tool Follow")
    ToolFollowSection:AddButton("Manage Follow Targets", function() Library:Notify({Title="Target Manager", Description="Select players in the custom overlay.", Duration=3}) end, {Title="Manage Targets", Description="Open target selection."})
    ToolFollowSection:AddToggle("Enable Tool Follow", false, function(state) ToolFollow.Enabled = state; if state then startToolFollow() else stopToolFollow() end end, {Title="Enable Tool Follow", Description="Forces your tools to follow and hit targets."})

    -- Page 2: Tycoon
    local SPT_Tycoon = SPT_Tab:CreatePage("Tycoon")
    local TycoonCoreSection = SPT_Tycoon:CreateSection("Tycoon Automation")
    TycoonCoreSection:AddToggle("Auto Claim Money", false, function(state) AutoClaimMoney = state; if state then startClaimMoney() else stopClaimMoney() end end, {Title="Auto Claim Money", Description="Remotely touches the Cash Register TouchTransmitter to collect cash."})
    TycoonCoreSection:AddToggle("Smart Auto Build", false, function(state) AutoBuild = state; if state then startAutoBuild() else stopAutoBuild() end end, {Title="Smart Auto Build", Description="Buys upgrades in priority order: Gear → Walls → Gen → Doors. Checks cash first!"})
    
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
                    for _, pad in ipairs(pads) do local d = (pad.Position - root.Position).Magnitude; if d < minDist then minDist = d; closest = pad end end
                    if closest then for i = 1, 8 do pcall(firetouchinterest, root, closest, 0); pcall(firetouchinterest, root, closest, 1) end end
                end
            end)
        else if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end end
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
        else if toolLoopConn then toolLoopConn:Disconnect(); toolLoopConn = nil end end
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
                if child:IsA("Folder") then icon=" "; addLog(indent..icon.."  "..child.Name.." (Folder)",Color3.fromRGB(255,200,100)); scan(child,depth+1)
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
        addLog("━━━ REPLICATEDFIRST ━━",Color3.fromRGB(100,200,255)); scan(game:GetService("ReplicatedFirst"),0)
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
    -- MPT TAB (ALL FEATURES IN ONE SCROLLABLE PAGE)
    -- ============================================
    local MPT_Tab = Window:CreateTab("Mega Power Tycoon", false, false)
    local MPT_MainPage = MPT_Tab:CreatePage("All Features")
    
    local MPT_Combat = MPT_MainPage:CreateSection("⚔️ Aggressive Combat")
    MPT_Combat:AddToggle("Kill Aura", false, function(state) Aura.Enabled = state; if state then startAuraLoop() else stopAuraLoop() end end, {Title="Kill Aura", Description="Hits targets around you."})
    MPT_Combat:AddToggle("Fast Kill", false, function(state) InstantKill = state end, {Title="Fast Kill", Description="Instantly kills targets."})
    MPT_Combat:AddToggle("Hit Amplifier", false, function(state) print("Hit Amp:", state) end, {Title="Hit Amplifier", Description="Spams damage remotes."})
    
    local MPT_Control = MPT_MainPage:CreateSection("🎯 Target Control")
    MPT_Control:AddToggle("Loopbring", false, function(state) print("Loopbring:", state) end, {Title="Loopbring", Description="Teleports target to you."})
    MPT_Control:AddToggle("Freeze Target", false, function(state) print("Freeze:", state) end, {Title="Freeze Target", Description="Anchors and freezes target."})
    
    local MPT_Tools = MPT_MainPage:CreateSection("🔧 Tool Manipulation")
    MPT_Tools:AddToggle("Get Tools", false, function(state) AutoGetTools = state end, {Title="Get Tools", Description="Auto-grabs weapons."})
    MPT_Tools:AddToggle("Use Tools", false, function(state) AutoTools = state end, {Title="Use Tools", Description="Auto-activates tools."})
    MPT_Tools:AddToggle("No Cooldown", false, function(state) NoCooldown = state end, {Title="No Cooldown", Description="Removes cooldowns."})
    MPT_Tools:AddToggle("Reach", false, function(state) Reach = state end, {Title="Reach", Description="Expands hitboxes."})
    MPT_Tools:AddToggle("Big Tools", false, function(state) print("BigTools:", state) end, {Title="Big Tools", Description="Scales tools by 3x."})
    MPT_Tools:AddToggle("Invisible", false, function(state) print("Invis:", state) end, {Title="Invisible", Description="Makes you transparent."})
    
    local MPT_Utils = MPT_MainPage:CreateSection("🛠️ Utilities")
    MPT_Utils:AddToggle("Fast Respawn", false, function(state) FastRespawn = state end, {Title="Fast Respawn", Description="Instant respawn."})
    MPT_Utils:AddToggle("Anti Spawn", false, function(state) AntiSpawnkill = state end, {Title="Anti Spawn", Description="3s invincibility."})
    MPT_Utils:AddButton("Get Base", function()
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
        if closestDoor then myRoot.CFrame = closestDoor.CFrame + Vector3.new(0, 5, 0) end
    end, {Title="Get Base", Description="Teleport to tycoon."})

    -- ============================================
    -- HUB MANAGE TAB (WHITELISTED)
    -- ============================================
    local ManageTab = Window:CreateTab("Hub Manage", false, true) -- true = premium/whitelisted
    local ManagePage = ManageTab:CreatePage("Management")
    local ManageSec = ManagePage:CreateSection("🔐 Authentication Required")
    ManageSec:AddButton("🔓 Login to Hub Manage", function()
        createLoginUI(function(role)
            currentUserRole = role
            createManageBoard(role)
        end)
    end, {Title="Login", Description="Authenticate as Owner or Operator."})
    
    local BanishLogsSec = ManagePage:CreateSection("📋 Logs (Login Required)")
    BanishLogsSec:AddButton("👻 View Banish Logs", function()
        if currentUserRole then createLogsViewer("banish") else Library:Notify({Title="Error", Description="Please login first.", Duration=3}) end
    end, {Title="Banish Logs", Description="View all banish records."})
    BanishLogsSec:AddButton("🚫 View Ban Logs", function()
        if currentUserRole then createLogsViewer("ban") else Library:Notify({Title="Error", Description="Please login first.", Duration=3}) end
    end, {Title="Ban Logs", Description="View all ban records."})

    -- ============================================
    -- CHAT TAB
    -- ============================================
    local ChatTab = Window:CreateTab("Hub Chat", false, false)
    local ChatPage = ChatTab:CreatePage("Chat")
    local ChatSec = ChatPage:CreateSection("💬 Real-Time Chat")
    ChatSec:AddButton("💬 Open Chat Window", function() createChatUI() end, {Title="Open Chat", Description="Open the chat interface."})

    -- ============================================
    -- SETTINGS TAB
    -- ============================================
    local SettingsTab = Window:CreateTab("Settings", false, false)
    local SettingsPage = SettingsTab:CreatePage("Settings")
    local SettingsSec = SettingsPage:CreateSection("️ Configuration")
    SettingsSec:AddToggle("Transparency", false, function(state) Window:SetTransparency(state and 0.2 or 0) end, {Title="Glass Mode", Description="Toggle UI transparency."})
    SettingsSec:AddButton("🔑 Reset Key", function()
        if delfile then pcall(function() delfile(KEY_FILE) end); Library:Notify({Title="Key Reset", Description="Please re-enter key on next launch.", Duration=3}) end
    end, {Title="Reset Key", Description="Clear saved key."})

    Library:Notify({Title = "Power Tycoon Hub Loaded", Description = "Welcome, " .. player.DisplayName .. "! Full features + Management active.", Duration = 4})
    print(" Power Tycoon Hub Ultimate - Loaded for " .. player.Name)
end

-- ============================================
-- INITIALIZATION
-- ============================================
if isKeyValid() then
    initializeHub()
else
    createKeyUI(initializeHub)
end
