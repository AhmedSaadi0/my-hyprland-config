## 🎨 الواجهة (UI & UX)

- **Core UI**
  - [x] System Tray (Systray)
  - [x] Application Launcher
  - [x] Improve bars positioning and shadows
  - [x] Improve edge corners
  - [x] Cheatsheet menu
  - [x] Start AI Integration
  - [ ] Game mode
  - [ ] Bars Shadow Control
  - [ ] Left Bar Width Control
  - [ ] Remove `LeftMenuStatus` and Use `EventBus`

- **Menus**
  - [x] Left Menu Navigation
  - [x] Left Menu Animations
  - [ ] Clipboard Manager
  - [ ] Todo List
  - [ ] AI Bots
  - [ ] Notes
  - [ ] Favorite Apps

- **Setting Window**
  - [x] Create a setting Window
  - [x] Wallpapers Settings
  - [x] Colors Settings
  - [x] Layout & Fonts Settings
  - [x] Desktop Clock Settings
  - [x] Hyprland Settings
  - [x] Integration Settings
  - [ ] Control `.nibrasshell.json`

- **Widgets**
  - [x] Clock Widget
  - [x] Depth Effect
  - [x] Support Depth Effect for Dynamic Wallpapers
  - [x] Weather Widget
  - [x] Music Widget
  - [ ] Depth effect for each wallpaper in dynamic wallpapers
  - [ ] Auto Depth Effect generation + clock adaptation
  - [ ] Cava With Depth Effect when music in on

---

## 🔔 الإشعارات & OSD (Notifications & OSD)

- [x] Notifications
- [x] Improve notification osd to not block content on right side
- [x] Notifications History Center
  - [x] Action buttons
  - [x] Race Condition Fix
  - [x] Dismissal Sync
  - [x] Responsive Timer
  - [x] Sound with Notifications
  - [x] DND
- [x] Sound OSD
- [x] Brightness OSD
- [x] Battery Status OSD
- [x] Volume & Brightness Animations

---

## 🧰 إدارة النظام (System & Devices)

- **Network**
  - [x] Network Manager Interface/Scripts
  - [x] Network Manager UI
  - [x] Network Usage Card
  - [ ] VPN Status Indicator
  - [ ] Quick Wi-Fi / Airplane Toggle
  - [ ] Monitor Selection

- **Devices**
  - [x] Audio Devices Control
  - [ ] Audio Devices Animations
  - [ ] Screen / Display Settings
  - [ ] Bluetooth Manager UI
  - [ ] Battery & Power Profiles Integration

---

## 🌤️ الخدمات (Services)

- **Weather**
  - [x] Weather Service (Backend)
  - [x] Severe Weather Alerts

- **Prayer Time**
  - [ ] Prayer Time Notifications & Widget
  - [ ] Hijri Date Display

- **Music**
  - [x] Dynamic Island Support - (Smart cap)
  - [x] Cava Visualization
  - [x] Media Controls Widget
  - [ ] Lyrics Display (Live sync)

- **AI**
  - [ ] AI API Support
  - [ ] Quick AI Assistant (Prompt overlay)
  - [ ] Clipboard AI Summarizer

---

## 🎨 الثيمات والتخصيص (Themes & Personalization)

- [x] Theme Service
- [x] Automatic Wallpaper Changer
- [x] Material 3 (M3) Dynamic Coloring
- [x] Dynamic Wallpaper Folders
- [x] Feature Control Window
- [x] Config File
- [x] Custom Full Themes
- [x] Reset Theme Fix + Colors Reset
- [x] Add more controls (radius, hyprland settings)
- [x] Dracula, Gruvbox, Catppuccin, Tokyo Night Themes
- [x] GTK4 Theme Support
- [ ] Halt Dynamic Wallpapers option
- [ ] Configure Dynamic Coloring
  - [ ] Control Material 3 `scheme_variant` from settings
- [ ] Solarized, Rosé Pine, Oxocarbon Themes
- [ ] Extend Color Schema (6 colors)

---

## 🧠 تحسينات وتجربة المستخدم (Productivity & UX)

- [x] Improve Menu Cards
- [x] Improve Animations (Menu, Notifications, Navigation)
- [ ] Improve Menus Navigation
- [ ] Keyboard Layout Switch Indicator
- [ ] Control the way menu is opened (reserve space or like floating)
- [ ] Toggle Buttons for (Wi-Fi, Bluetooth, Gammastep, Gaming Mode ... etc)

---

## 🛠️ تحسين الكود (Code Improvements)

- [x] Create Component for Theme Settings Text & Label
- [x] Wallpaper Settings: TextField update before save
- [ ] Move Non General Components to Correct Location: ex-> SettingSwitch to windows/settings/widgets

---

## Smart Cap

- [x] Improve weather info (color be same as weather condition, add gif that represents current weather)
- [x] Animated eye that looks like a robot
- [x] AI Weather Alerts And Analysts
- [x] AI Audiophile and Media Critic
- [x] Add const values to statuses (media, weather, info, clock)
- [x] Add Battery info
- [ ] Add fuzzy clock to organize the day, connected to ai if available
- [ ] Sends more data (last played 2,3 songs, time of the day, volume percentage, output device name ... etc) to ai when media is opened to make the judge more funny
- [ ] New Reaction when memory is full or cpu is high, use ai to tell the user whats wrong
