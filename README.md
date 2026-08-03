# ⚡ EXO Hub v3.0 — Power Tycoon

> **The most advanced Power Tycoon exploit hub for Roblox.** Built on the Cerberus UI Library with a fully redesigned MPT engine, intelligent kill analysis, and a complete defense matrix.

---

## 📋 Table of Contents

- [About](#-about)
- [Supported Games](#-supported-games)
- [Loadstring](#-loadstring)
- [Key System](#-key-system)
- [Features](#-features)
  - [Super Power Tycoon (SPT)](#super-power-tycoon-spt)
  - [Mega Power Tycoon (MPT)](#mega-power-tycoon-mpt)
  - [Settings & Utilities](#settings--utilities)
- [UI Themes](#-ui-themes)
- [Changelog](#-changelog)
- [Requirements](#-requirements)
- [Disclaimer](#-disclaimer)

---

## 🔥 About

EXO Hub is a **full-rewrite**, feature-rich script hub designed specifically for the Power Tycoon franchise on Roblox. Version 3.0 introduces a completely new architecture with predictive combat, overlap-scanned hit amplification, wave-based tool acquisition, and a behavioral kill-analysis notification system.

**UI Library:** [Cerberus](https://github.com/Jxereas/UI-Libraries) by Jxereas

---

## 🎮 Supported Games

| Game | Status |
|------|--------|
| **Super Power Tycoon** | ✅ Full Support |
| **Mega Power Tycoon** | ✅ Full Support |

---

## 🚀 Loadstring

loadstring(game:HttpGet("https://raw.githubusercontent.com/kiden03230323-maker/Spt-mpt-hub-test/refs/heads/main/EXYO-HUB-SPT.lua"))()

> 

---

## 🔑 Key System

The hub is gated by a premium key authentication system.

| Field | Value |
|-------|-------|
| **Key** | `EXOSTAKEOVERR19$` |
| **Storage** | Saved locally to `exo_key_v3.dat` after first authentication |

- On first run, a sleek authentication card appears.
- Enter the key and click **AUTHENTICATE & UNLOCK**.
- The key is cached locally so you won't need to re-enter it.

---

## ✨ Features

### Super Power Tycoon (SPT)

#### ⚔️ Multi-Target Aura
- Select individual targets from a dropdown or target all players
- **Predictive hit registration** with adjustable latency offset
- **Instant Kill** toggle (sets humanoid health to 0)
- Raycast-validated hit confirmation
- Falls back to `firetouchinterest` if no damage remote is found

#### 🎯 Tool Follow
- Tools hover near selected players' torsos in real-time
- Cached tool parts for performance
- Auto-updates on character respawn and new tool equip

#### 🛡️ Defense / Anti-Aura
- **God Mode** — Invisible ForceField + auto-heal below 50% HP
- **Repel** — Pushes enemy weapon handles away when within 10 studs
- **Anti-Spawnkill** — 9 billion HP + ForceField for 3 seconds on spawn

#### 🏗️ Tycoon Automation
- **Auto Claim Money** — Fires touch interest on your CashRegister
- **Smart Auto Build** — Priority-sorted purchasing (Generators → Walls → Gears → Upgrades)
- Threat-aware building: prioritizes defensive structures when enemies are nearby

#### 🔧 Auto Get Tools
- Automatically grabs weapons from tycoon gear givers
- Supports **Stone**, **Magic**, **Storm**, and **Robotic** bases
- Excludes Insanity, Giant, Dark, Spike, Web, and Strong bases

#### ⏱️ Tools & Cooldown
- **Auto Use Tools** — Activates all tools at 0 delay (including backpack)
- **No Cooldown** — Hooks `wait`, `task.wait`, `delay`, and `spawn`

#### 📏 Reach
- Multiplies tool hitbox size (slider: 1x–10x)
- Stores original sizes for clean reset
- Blue highlight outline on modified parts

#### 🔄 Respawn & Protection
- **Fast Respawn** — Instant respawn on death via `Guide` remote or `LoadCharacter`

#### 🛠️ Utilities
- **Full Game Scanner** — Opens a draggable dumper GUI that scans Workspace and ReplicatedStorage
- **Custom Damage Remote** — Set your own remote path via text input

---

### Mega Power Tycoon (MPT)

#### 💀 Omni-Kill Engine
- Master toggle: enables Aura + Instant Kill + auto-targets all players
- **Insta-Kill Micro-Burst** — 5-burst FightEvent spam at 60Hz on the nearest target
- **Prediction Aggression** slider
- **Manual Kill Burst** button for on-demand elimination
- **Refresh Target List** button

#### 💥 Hit Amplifier
- **OverlapParams** 24×24×24 box scan around your character
- Runs at **120Hz** with a **15ms** cooldown
- Automatically fires FightEvent remotes or activates tools when targets are detected
- Dual detection: spatial overlap + player distance fallback (20 studs)

#### 🗡️ Tool Arsenal
- **Wave-based** tool acquisition system
- Scans tycoons for gear giver pads
- Acquires: Energy Sword, Staff, Axe, Fist
- **Force Acquire All** button for instant 8-burst grab

#### 👑 Tycoon Sovereign
- **Sovereign Economy** — Combines Auto Claim + Auto Build in one toggle
- **Defense Threat Radius** slider (20–100 studs)
- **Force Buy Next Upgrade** — Purchases the highest-priority affordable item

#### 🏁 Spawn Supremacy
- **Supremacy Mode** — 9B HP + invisible ForceField on spawn (3s duration)
- **Fast Respawn** toggle

#### 🛡️ Defense Matrix
- Full Anti-Aura suite (ForceField God Mode + Weapon Repel)
- **Emergency Heal** button — Instantly restores health to max

---

### Settings & Utilities

| Feature | Description |
|---------|-------------|
| 🎨 **UI Themes** | Purple, Green, Red, Blue, Gold + custom color wheel |
| 💾 **Config Save/Load** | Saves reach, threat radius, latency, theme, and toggles to `exo_config_v3.dat` |
| 📉 **Anti-Lag Shield** | Disables particles, beams, trails, post-effects, textures, and drops render quality |
| 👁️ **ESP (Minimal Dots)** | Red dot overlay on all player positions via `WorldToViewportPoint` |
| ☠️ **Kill Notifications** | Behavioral analysis on death: killer, weapon, distance, suspected features, counter-advice, threat level (1–10) |
| 📜 **Kill Logs** | Scrollable log viewer storing up to 50 kill events with full analysis |

---

## 🎨 UI Themes

| Theme | Accent Color |
|-------|-------------|
| 💜 Purple (Default) | `RGB(190, 140, 255)` |
| 💚 Green | `RGB(50, 200, 100)` |
| ❤️ Red | `RGB(220, 50, 50)` |
| 💙 Blue | `RGB(50, 120, 220)` |
| 💛 Gold | `RGB(230, 180, 40)` |
| 🎨 Custom | Use the color wheel in Settings |

---

## 📝 Changelog

### v3.0 — Current Release
- ✅ Full rewrite on **Cerberus UI Library**
- ✅ Key system now properly gates the hub
- ✅ MPT completely redesigned with 6 sections
- ✅ Insta-Kill Micro-Burst engine
- ✅ Hit Amplifier with OverlapParams scanning
- ✅ Tool Arsenal wave-based acquisition
- ✅ Safe Anti-Aura (ForceField, no broken hooks)
- ✅ Reach slider with original size storage
- ✅ Kill Notifications with behavioral analysis
- ✅ Kill Log viewer with scrollable history
- ✅ Config save/load system
- ✅ Anti-Lag Shield & ESP

### v2.0
- Migrated to ZyronX UI (deprecated)
- All syntax/string bugs fixed

### v1.2
- MPT Tab redesigned
- Enhanced Aura with predictive hit registration

### v1.1
- Improved Tool Follow, Reach, Respawn
- Added Updates Tab

---

## ⚙️ Requirements

| Requirement | Details |
|-------------|---------|
| **Executor** | Any Level 7+ executor (Synapse X, Script-Ware, Fluxus, etc.) |
| **Supported Functions** | `loadstring`, `game:HttpGet`, `isfile`, `readfile`, `writefile`, `firetouchinterest` |
| **Game** | Super Power Tycoon or Mega Power Tycoon |

---

## ⚠️ Disclaimer

> This project is for **educational and research purposes only**. The use of exploit scripts in Roblox games violates the [Roblox Terms of Service](https://en.help.roblox.com/hc/en-us/articles/115004647846). The author is not responsible for any bans, account terminations, or other consequences resulting from the use of this script. Use at your own risk.

---

<div align="center">

**⚡ EXO Hub v3.0 — Cerberus Edition ⚡**

*All systems online. SPT + MPT + Settings + Updates.*

</div>
