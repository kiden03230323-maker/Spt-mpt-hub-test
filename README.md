# ⚡ Power Tycoon Hub – Architectural Integration Edition

A sophisticated **Roblox Power Tycoon exploit hub** with **Native ZyronX UI**, premium custom overlays, and enterprise-grade security architecture.

**Owner:** exo_blox | **Co-Owner:** city800

---

## 🎨 UI Architecture

This hub uses **Native ZyronX UI Library** (not Rayfield) with:
- ✨ Modern dark theme with purple accents
- 🎯 Premium custom overlay system
- 🔐 Whitelisted administrative console
- 📱 Responsive design & smooth animations
- 🛡️ Enterprise-grade security layer

---

## 🔐 Key System

**Key:** `EXOSTAKEOVERR19$` (24-hour expiration)

- 🔒 **Hardware ID Tracking** - Device-based bans
- ⏱️ **Time-Limited Keys** - Auto-expire every 24 hours
- 📝 **User/Device Ban System** - Dual-layer bans
- 🔧 **Maintenance Mode** - Admin shutdown capability

---

## 📋 Features

### 🎯 Multi-Target Aura (Super Power Tycoon)
- **Enable Aura** - Toggle damage aura on/off
- **Instant Kill** - One-hit brute-force eliminations
- **Auto Target Detection** - Works with any tool
- **Damage Remote Auto-Detection** - Finds damage systems automatically

### 🛠️ Tool Follow System
- **Enable Tool Follow** - Stick tools to targets continuously
- **Auto-detection** - Finds tool parts & hit boxes automatically
- **Smooth Tracking** - Heartbeat-based positioning
- **Touch Interest Firing** - Native Roblox damage triggering

### ⚙️ Auto Grab Weapons (0 Delay)
- **Auto Grab Weapons** - Automatically collects tycoon tools
- **Supported Bases:**
  - Stone
  - Magic
  - Storm
  - Robotic
- **Exclusions:** Insanity, Giant, Dark, Spike, Web, Strong
- **Priority System** - Intelligent tool acquisition

### 💪 Tools & Cooldown Management
- **Auto Use Tools (0 delay)** - Continuous rapid activation
- **No Cooldown** - Removes wait/task.wait delays via function hooking
- **RenderStepped Loop** - Ultra-fast tool cycling
- **Backpack Auto-Equip** - Tools automatically moved to character

### 🎯 Reach Enhancement
- **Reach (hitbox + outline)** - Expand tool hitboxes
- **Visual Indicator** - Blue outline on expanded parts
- **2x Size Multiplier** - Doubled weapon reach
- **Massless Tools** - Improved collision detection

### 💰 Tycoon Automation (Super Power Tycoon)
- **Auto Claim Money** - Continuous cash register interaction
- **Smart Auto Build** - Priority-based upgrade purchasing
  - Buys gears first (priority 1)
  - Then walls (priority 2)
  - Then generators (priority 3)
  - Then doors (priority 4)
- **Cost Detection** - Reads Price/Cost/Value objects
- **Cash Verification** - Only buys when affordable

### 🎮 Mega Power Tycoon Tab
- **Kill Aura** - Multi-target damage system
- **Fast Kill** - Instant elimination mode
- **Get Base** - Quick teleport to nearest tycoon door

---

## 🔐 Administrative Console (Whitelisted)

**Hub Manage Tab** - Restricted Access

### Authentication
```
Owner: exo_blox / Password: 03239461
Operator: OP / Password: 0000
```

### Owner-Only Actions
- 🚫 **Ban User (Account + HWID)** - Permanent dual-layer ban
- 🔧 **Shutdown Hub** - Activate maintenance mode (1 hour auto-reset)
- 👥 **Join Selected User** - Teleport to player
- ⚠️ **Issue Official Warning** - Send warning to players

### Real-Time Features
- Live player list with avatars
- Click to select target player
- Auto-refresh every 3 seconds

---

## 📦 Installation

### Method 1: Direct Executor (Recommended)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kiden03230323-maker/Spt-mpt-hub-test/main/PowerTycoonHub_Rayfield.lua"))()
```

### Method 2: Manual Copy
1. Copy entire script from `PowerTycoonHub_Rayfield.lua`
2. Paste into your Roblox exploit executor
3. Run and enter key: `EXOSTAKEOVERR19$`

---

## 🎮 How to Use

### Getting Started
1. **Execute the script** in your Roblox executor
2. **Enter the key:** `EXOSTAKEOVERR19$`
3. **Hub UI opens** with three main tabs

### Multi-Target Aura Setup
1. Go to **Super Power Tycoon** → **Combat**
2. Toggle **Enable Aura** to activate damage aura
3. Optional: Enable **Instant Kill** for one-shot eliminations
4. Aura targets all nearby players automatically

### Tool Follow
1. Go to **Super Power Tycoon** → **Combat**
2. Enable **Tool Follow** to make tools stick to targets
3. Works with any equipped weapon in inventory

### Auto Grab Weapons
1. Go to **Super Power Tycoon** → **Tycoon** → **Auto Get Tools**
2. Toggle **Auto Grab Weapons**
3. Walk to any tycoon area
4. Tools automatically grab from pads (Stone, Magic, Storm, Robotic)

### Tool Activation & Cooldown
1. Go to **Super Power Tycoon** → **Tycoon** → **Tools & Cooldown**
2. **Auto Use Tools** - Continuously activates all tools
3. **No Cooldown** - Removes wait delays for faster attacks

### Reach Expansion
1. Go to **Super Power Tycoon** → **Movement & Visuals**
2. Toggle **Reach (hitbox + outline)**
3. Weapon hitbox increases 2x
4. Blue outline shows expanded reach

### Auto Build Tycoon
1. Go to **Super Power Tycoon** → **Tycoon**
2. Toggle **Smart Auto Build**
3. Automatically purchases upgrades in priority order
4. Buys only when you have enough cash

### Auto Claim Money
1. Go to **Super Power Tycoon** → **Tycoon**
2. Toggle **Auto Claim Money**
3. Continuously collects from cash register

### Mega Power Tycoon Tab
1. Go to **Mega Power Tycoon** → **All Features**
2. Quick access to Kill Aura and Fast Kill
3. **Get Base** button teleports to nearest tycoon

### Administrative Console
1. Go to **Hub Manage** → **Console**
2. Click **Launch Console**
3. Enter credentials (Owner or Operator)
4. Access player management tools
5. Ban, warn, or join players in real-time

---

## 🔧 Configuration

### Damage Remote Detection
The hub **auto-detects** damage remotes by scanning for:
- "damage"
- "hit"
- "attack"
- "deal"

### Tycoon Detection
- Auto-detects player's tycoon type
- Finds nearest tycoon by door proximity
- Caches type for performance
- Resets on character respawn

### Tool Base System
```lua
Energy Sword → Stone
Staff → Magic
Axe → Storm
Fist → Robotic
```

---

## 🚀 Performance Tips

- **Disable unused features** to maximize FPS
- **Auto Use Tools** uses RenderStepped (fastest updates)
- **No Cooldown** hooks wait/task.wait functions
- **Tool Follow** updates on Heartbeat (60 FPS)
- **Aura** runs on PreSimulation (physics-safe)
- **Auto Build** includes 0.5s throttle to prevent spam

---

## 📊 Technical Details

### Services Used
- `Players` - Player management
- `RunService` - Loop connections (PreSimulation, RenderStepped, Heartbeat)
- `ReplicatedStorage` - Remote detection
- `CoreGui` - UI rendering
- `HttpService` - JSON key/ban file handling
- `TweenService` - UI animations
- `UserInputService` - Input handling

### Loop Architecture
- **PreSimulation** - Damage/aura/claim/build loops (physics-safe)
- **RenderStepped** - Auto tool activation (high-frequency)
- **Heartbeat** - Tool follow tracking (smooth motion)
- **TouchTransmitter** - Hit box detection

### Security Features
- ✅ **Hardware ID Tracking** - `gethwid()` integration
- ✅ **Time-Locked Keys** - 24-hour expiration
- ✅ **Dual-Layer Bans** - User ID + HWID
- ✅ **File Persistence** - JSON-based data storage
- ✅ **Whitelisted Admin** - Username/password authentication
- ✅ **Maintenance Mode** - Admin shutdown capability

---

## 🎨 UI Theme Colors

```lua
Base       = RGB(15, 15, 18)          -- Dark background
Element    = RGB(22, 22, 26)          -- Card/panel background
Accent     = RGB(190, 140, 255)       -- Purple accent
AccentDark = RGB(140, 90, 200)        -- Dark purple
Border     = RGB(35, 35, 42)          -- UI borders
Text       = RGB(240, 240, 245)       -- Primary text
SubText    = RGB(160, 160, 175)       -- Secondary text
Danger     = RGB(220, 50, 50)         -- Red alerts
Success    = RGB(50, 200, 100)        -- Green success
Warning    = RGB(230, 180, 40)        -- Orange warnings
```

---

## ⚠️ Disclaimer

This script is for **educational purposes only**. Use at your own risk. The author is not responsible for:
- Account bans
- Data loss
- Game restrictions
- Any other consequences

**Use responsibly!**

---

## 🤝 Contributing

Found a bug? Have a feature request?
- Open an issue
- Submit improvements
- Suggest optimizations

---

## 📄 License

This project is provided as-is. No warranty or support guaranteed.

---

**Made with ⚡ for Power Tycoon**

**Architectural Integration Edition | ZyronX UI**

**Key:** `EXOSTAKEOVERR19$` (24-hour expiration)
