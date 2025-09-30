## System Applications

### Required apps

- Hyprland
- Quickshell
- playerctl
- polkit-kde-agent
- [FantasqueSansM Nerd Font](https://www.nerdfonts.com/font-downloads)
- brightnessctl
- gammastep
- sysstat
- bc
- sassc
- swww
- power-profiles-daemon
- lm_sensors
- [KDE Material You Colors](https://github.com/luisbocanegra/kde-material-you-colors)
- vnstat

### Optional apps

- hyprshot
- dolphin
- konsole
- hyprpicker
- systemsettings
- fish
- copyq
- easyeffects
- blueman
- telegram-desktop
- discord

## Python packages

- rembg
- pillow
- psutil

```bash
pip install rembg[gpu] pillow psutil
```

## Files

### Project

- ~/.config/hypr/
- ~/.config/quickshell/
- ~/.config/easyeffects
- ~/.config/fish/config.fish
- ~/.nibrasshell.json

```bash
# نسخ الملفات
cp -r nibrasshell ~/.config/hypr
cp -r ~/.config/hypr/config/quickshell ~/.config/quickshell
cp ~/.config/hypr/config/config.fish ~/.config/fish/config.fish
cp -r ~/.config/hypr/config/easyeffects ~/.config/easyeffects

sudo chmod +x ~/.config/hypr/scripts/*
sudo chmod +x ~/.config/quickshell/scripts/*

# نسخ ملفات الثيمات
mkdir ~/.local/share/color-schemes/
mkdir ~/.local/share/konsole/
mkdir ~/.config/Kvantum/

cp -r ~/.config/hypr/config/plasma-colors/* ~/.local/share/color-schemes/
cp -r ~/.config/hypr/config/kvantum-themes/* ~/.config/Kvantum/
cp -r ~/.config/hypr/config/konsole/* ~/.local/share/konsole/

# الخطوط
cp -r ~/.config/hypr/config/.fonts/* ~/.fonts
```

- Extract all icons in `~/.config/hypr/config/icons/` to icons folder -> `~/.local/share/icons`
- Extract all themes in `~/.config/hypr/config/gtk-themes/` to themes folder

### Project config file

`~/.nibrasshell.json`

```bash
nvim ~/.nibrasshell.json
```

- must contain correct setup

EX:

```json
{
  "username": "احمد الصعدي",
  "profilePicture": "/home/ahmed/wallpapers/profile.png",
  "networkMonitor": "wlp0s20f3",
  "networkTimeout": 300,
  "networkInterval": 1000,
  "darkM3WallpaperPath": "/home/ahmed/wallpapers/dark",
  "lightM3WallpaperPath": "/home/ahmed/wallpapers/light",
  "weatherLocation": "sanaa",
  "city": "sanaa",
  "country": "yemen",
  "usePrayerTimes": true,
  "changePlasmaColor": true,
  "scripts": {
    "dynamicM3Py": null,
    "get_wallpapers": null,
    "createThumbnail": null,
    "gtk_theme": null,
    "systemInfo": null,
    "deviceLocal": null,
    "cpu": null,
    "ram": null,
    "deviceTemp": null,
    "hardwareInfo": null,
    "cpuUsage": null,
    "ramUsage": null,
    "cpuCores": null,
    "devicesTemp2": null,
    "playerctl": null
  }
}
```
