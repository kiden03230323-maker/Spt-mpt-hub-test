# ⚡ Power Tycoon Hub – Rayfield UI Edition

A sophisticated **Roblox Power Tycoon exploit hub** with a sleek **Rayfield UI** and secure key system.

## 🔐 Key System
**Key:** `EXOSTAKEOVERR19$`

---

## 📋 Features

### 🎯 Multi-Target Aura
- **Manage Targets** - Select multiple players to target
- **Enable Aura** - Toggle damage aura on/off
- **Instant Kill** - One-hit eliminations
- **🔄 Refresh Players** - Update player list in real-time

### 🛠️ Tool Follow
- **Select Follow Targets** - Choose which players to follow
- **Enable Tool Follow** - Stick tools to targets
- **Auto-detection** - Finds tool parts automatically

### ⚙️ Auto Get Tools (0 Delay)
- **Auto Grab Weapons** - Automatically collects weapons
- **Supported Bases:**
  - Stone
  - Magic
  - Storm
  - Robotic
- **Exclusions:** Insanity, Giant, Dark, Spike, Web, Strong

### 💪 Tools & Cooldown
- **Auto Use Tools (0 delay)** - Rapid tool activation
- **No Cooldown (arms stick)** - Remove cooldown delays
- Hooked wait/task.wait functions for maximum speed

### 🎯 Reach
- **Reach (hitbox + outline)** - Expand hitboxes
- **Visual Indicator** - Blue outline on reach parts
- **2x Size Multiplier** - Doubled weapon hitbox

### 🛡️ Respawn & Protection
- **Fast Respawn** - Instant respawn on death
- **Anti Spawnkill (3s invincible)** - Spawn protection

### 🔧 Utilities
- **🔍 Open Game Dumper** - Full game object scanner
- **⚙️ Set Damage Remote** - Custom damage remote configuration
- **Copy Logs** - Export dumper results

---

## 📦 Installation

### Method 1: Direct Executor
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kiden03230323-maker/spt-mpt-hub-test/main/PowerTycoonHub_Rayfield.lua"))()
```

### Method 2: Manual Copy
1. Copy the script from `PowerTycoonHub_Rayfield.lua`
2. Paste into your Roblox exploit executor
3. Run and enter key: `EXOSTAKEOVERR19$`

---

## 🎮 How to Use

### Getting Started
1. **Execute the script** in your Roblox executor
2. **Enter the key:** `EXOSTAKEOVERR19$`
3. **The hub opens** with full UI

### Multi-Target Aura Setup
1. Go to **Super Power Tycoon** tab
2. Click **🔄 Refresh Players** to see all players
3. Select targets from the dropdown
4. Toggle **Enable Aura** to activate
5. Optional: Enable **Instant Kill** for one-shot eliminations

### Tool Follow
1. Click **🔄 Refresh Follow Targets**
2. Select targets from dropdown
3. Toggle **Enable Tool Follow**
4. Your tools will stick to targets

### Auto Grab Weapons
1. Toggle **Auto Grab Weapons**
2. Walk to tycoon areas
3. Tools automatically grabbed and equipped

### Reach Expansion
1. Toggle **Reach (hitbox + outline)**
2. Weapon hitbox increases 2x
3. Blue outline shows reach expansion

### Fast Respawn
1. Toggle **Fast Respawn**
2. Die to respawn instantly
3. Works with Guide remote

### Anti Spawnkill
1. Toggle **Anti Spawnkill (invincible 3s)**
2. Get 3 seconds of invincibility on spawn
3. Infinite health during protection

---

## 🔍 Game Dumper

Click **🔍 Open Game Dumper** to scan:
- ✅ Workspace
- ✅ ReplicatedStorage
- ✅ ReplicatedFirst
- ✅ Lighting
- ✅ Player Backpack
- ✅ Player Character

**Icons:**
- 📁 Folders
- 🔧 Tools
- 🧩 Models
- 📡 RemoteEvent / RemoteFunction
- 🔗 BindableEvent / BindableFunction

**Copy results** to clipboard with 📋 button.

---

## ⚙️ Configuration

### Damage Remote Detection
- **Auto-detects** damage remotes by name matching:
  - "damage"
  - "hit"
  - "attack"
  - "deal"

### Custom Damage Remote
1. Use Game Dumper to find the remote
2. Click **⚙️ Set Damage Remote**
3. Enter full path (e.g., `game.ReplicatedStorage.DealDamage`)

---

## 🚀 Performance Tips

- **Disable unused features** to improve FPS
- **Auto Use Tools** uses RenderStepped (fast updates)
- **No Cooldown** hooks wait functions
- **Tool Follow** updates on Heartbeat

---

## 📊 Technical Details

### Services Used
- `Players` - Player management
- `RunService` - Loop connections
- `ReplicatedStorage` - Remote detection
- `CoreGui` - UI rendering

### Connection Types
- `PreSimulation` - Damage/aura loop
- `RenderStepped` - Tool activation
- `Heartbeat` - Tool follow
- `TouchTransmitter` - Hitbox detection

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

**Key:** `EXOSTAKEOVERR19$`
