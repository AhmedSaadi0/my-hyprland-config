# 🚀 Development Roadmap

## 💊 Smart Capsule & AI (Priority)

_Focus on the unique features of the capsule._

- **Visuals & Customization**
  - [ ] **🎨 Smart Capsule Color Customization**: Add specific settings to control capsule background, border, and text colors independently of the main theme.
  - [ ] **Fuzzy Clock**: Add a fuzzy clock logic to organize the day (e.g., "Work Time", "Rest"), connected to AI.

- **AI Logic**
  - [ ] **System Reactions**: Trigger AI reactions when RAM is full or CPU is high (using AI to explain the issue humorously).
  - [ ] **Clipboard AI**: AI summarizer for copied text.
  - [ ] **Connect Fuzzy Clock**: Link the fuzzy clock states with AI responses.

---

## 🎨 UI & Theming

_Visual improvements and customization options._

- **Core UI**
  - [x] **Improve Themes**: restructure `ThemeManager.qml` to separate the concerne
  - [ ] **Game Mode**: Toggle to enable high performance.
  - [ ] **GIF Wallpapers**: Support `.gif` files as wallpapers.
  - [ ] **Bar Customization**: Controls for Bar Shadows & Left Bar Width.
  - [ ] **Depth Effect**:
    - [ ] Auto-generation of depth effect.
    - [ ] Support depth effect for _each_ wallpaper in dynamic folders.
    - [ ] Cava (Visualizer) integration with Depth Effect.

- **Themes**
  - [ ] **Dynamic Coloring Control**: Configure Material 3 `scheme_variant` via settings.
  - [ ] **New Themes**: Solarized, Rosé Pine, Oxocarbon.
  - [x] **Extended Colors**: Expand color schema to 6 colors.
  - [ ] **Halt Dynamic Wallpapers**: Option to pause automatic wallpaper cycling.

---

## 🧰 Productivity & Widgets

_Tools and applets._

- **Menus & Popups**
  - [x] **Clipboard Manager**: UI for clipboard history.
  - [ ] **Todo List**: Built-in simple task manager.
  - [ ] **Notes**: Quick note-taking widget.
  - [ ] **Favorite Apps**: Quick launch section.
  - [ ] **AI Bots**: Menu for different AI assistants.
  - [ ] **Menu Logic**: Option to control opening style (Reserve space vs. Floating).

- **Service Widgets**
  - [ ] **Prayer Times**: Notification & Widget + Hijri Date.
  - [ ] **Music Lyrics**: Live sync lyrics display.

---

## ⚙️ System & Devices

_Hardware control and system indicators._

- **Connectivity & Hardware**
  - [ ] **Bluetooth Manager**: Full UI for Bluetooth devices.
  - [ ] **Display Settings**: Monitor selection and resolution control.
  - [ ] **VPN Indicator**: Status icon for VPN.
  - [ ] **Quick Toggles**: Wi-Fi, Airplane Mode, Gammastep buttons.
  - [ ] **Keyboard Layout**: Indicator for current language.
  - [ ] **Power**: Battery & Power Profiles integration.

---

## 🛠️ Code Refactoring

_Internal code improvements._

- [ ] **EventBus**: Remove `LeftMenuStatus` and replace with `EventBus`.
- [ ] **Structure**: Move non-general components (e.g., `SettingSwitch`) to their correct specific directories.

---

# ✅ Completed (Archive)

<details>
<summary>Click to view completed tasks</summary>

**Smart Capsule & AI**

- [x] Dynamic Island Support
- [x] AI Weather Analysts & Alerts
- [x] AI Audiophile (Media Critic)
- [x] Animated Robot Eye
- [x] Battery & Status Info
- [x] Expanded cards details

**UI & UX**

- [x] System Tray & Launcher
- [x] Edge Corners & Shadows
- [x] Notification Center & History (Fixed Race Conditions)
- [x] OSD (Volume, Brightness, Battery)
- [x] Cheatsheet Menu

**Theming**

- [x] Material 3 Dynamic Coloring
- [x] Automatic Wallpaper Changer & Folders
- [x] GTK4 Theme Support
- [x] Major Themes (Dracula, Tokyo Night, etc.)
- [x] Settings Window (Wallpapers, Colors, Fonts, Hyprland)

**System**

- [x] Network Manager UI
- [x] Audio Devices Control
- [x] Weather Service (Backend)
- [x] Config File Control (`.nibrasshell.json`)
</details>
