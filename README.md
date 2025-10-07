# NibrasShell – Hyprland + Quickshell

**Join our [Discord Server](https://discord.gg/EUcGgRGhrs) for discussions and support!**

[![Discord](https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/EUcGgRGhrs)

## This branch will use [quickshell](https://quickshell.outfoxxed.me/)

If you want to use ags_v1 change the branch to [main](https://github.com/AhmedSaadi0/nibrasshell/blob/main)

<details>
<summary>العربية</summary>

**ملاحظة:** هذه الإعدادات لا تزال في [مرحلة التطوير](https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/config/quickshell/todo.md)، وسأقوم بإضافة المزيد من الميزات بصورة مستمرة عندما يتاح لدي وقت أكثر.

### ملاحظة

يُفضل استخدام هذا الإعداد مع تطبيقات KDE للحصول على أفضل تجربة. إذا اخترت استخدام تطبيقات أخرى، فلا بأس بذلك، ولكن ستحتاج إلى ضبط الإعدادات يدوياً إذا لم يكن لديها ثيم مشابه لبقية التطبيقات.

### برامج ضرورية

- [Hyprland](https://wiki.hyprland.org/Getting-Started/Installation/)
- [Quickshell](https://quickshell.outfoxxed.me/docs/guide/install-setup/)
- network-manager-applet
- playerctl
- polkit-kde-agent or polkit-gnome
- [FantasqueSansM Nerd Font](https://www.nerdfonts.com/font-downloads)
- dolphin
- konsole
- brightnessctl
- gammastep
- wl-clipboard
- hyprpicker
- sysstat
- bc
- sassc
- swww
- systemsettings
- acpi
- fish
- gnome-bluetooth-3.0
- power-profiles-daemon
- lm_sensors
- copyq
- [KDE Material You Colors](https://github.com/luisbocanegra/kde-material-you-colors)
- vnstat
- nethogs

### برامج اختيارية

- strawberry
- easyeffects
- blueman
- telegram-desktop
- discord
- kvantum
- firefox

## التثبيت

### الطريقة التلقائية (موصى به)

بعد استنساخ المستودع، قم بتشغيل السكربت التالي الذي سيهتم بكل شيء، بما في ذلك إنشاء ملف الإعدادات `.nibrasshell.json`:

```bash
python install.py
```

<details>
<summary><strong>التثبيت اليدوي (اضغط للفتح)</strong></summary>

### تثبيت البرامج لمستخدمي Arch:

```bash
# تثبيت البرامج المطلوبة
yay -S base-devel brightnessctl network-manager-applet konsole blueman ark dolphin ffmpegthumbs playerctl kvantum polkit-kde-agent jq gufw tar gammastep wl-clipboard easyeffects hyprpicker hyprshot-git bc sysstat kitty sassc systemsettings acpi fish kde-material-you-colors plasma5support plasma5-integration plasma-framework5 ttf-jetbrains-mono-nerd ttf-fantasque-nerd powerdevil power-profiles-daemon libjpeg6-turbo swww python-regex copyq swww quickshell
# تثبيت البرامج الاختيارية
yay -S orchis-theme-git discord firefox visual-studio-code-bin nwg-look-bin qt5ct telegram-desktop strawberry
```

### مستخدمي Fedora

```bash
# Enable rpmfusion repository
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# تثبيت البرامج المطلوبه وبرامج اخرى مثل دعم الصوتيات
sudo dnf install ffmpeg --allowerasing
sudo dnf groupinstall "Sound and Video" --allowerasing
# تفعيل مستودع هيبر لاند
sudo dnf copr enable solopasha/hyprland
sudo dnf install hyprland hyprshot hyprpicker wl-clipboard swww
# تفعيل مستودع كويك شل
sudo dnf copr enable errornointernet/quickshell
sudo dnf install quickshell
# تفعيل مستودع material-you-colors
sudo dnf copr enable luisbocanegra/kde-material-you-colors
sudo dnf install kde-material-you-colors
```

### متطلبات تاثير العمق للساعة في سطح المكتب

- نحتاج مكتبه `rembg` و `pillow` لانشاء الصور ذات تاثير العمق

```bash
pip install rembg[gpu] pillow psutil
```

### اعداد الملفات:

    git clone https://github.com/AhmedSaadi0/NibrasShell.git

    # نسخ الملفات, نسخ احتياطي والى اخره

### تغيير الاعدادات

- **ملاحظة:** هذه الخطوة تتم تلقائياً عند استخدام `install.py`.
- انشء ملف باسم `.nibrasshell.json` في مجلد الهوم وقم بإضافة الإعدادات حسب جهازك ومنطقتك.

```json
{
  "username": "احمد الصعدي",
  "profilePicture": "/home/ahmed/wallpapers/profile.png",
  "networkMonitor": "wlp0s20f3",
  "darkM3WallpaperPath": "/home/ahmed/wallpapers/dark",
  "lightM3WallpaperPath": "/home/ahmed/wallpapers/light",
  "weatherLocation": "sanaa"
}
```

</details>

## اختصارات لوحة المفاتيح

| الاختصار    | الوظيفة                                           |
| :---------- | :------------------------------------------------ |
| `Super + /` | فتح قائمة الـ Cheatsheet وستجد فيها كل الاختصارات |

</details>

<details>

<summary>English</summary>

**Note:** This configuration is a [work in progress](https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/config/quickshell/todo.md), and I will continue to add more features as time permits.

### Note

It is recommended to use this setup with KDE applications for the best experience. If you choose to use other applications, that is fine, but you will need to theme them manually if they do not have a theme similar to the rest of the applications.

### Required dependencies:

- [Hyprland](https://wiki.hyprland.org/Getting-Started/Installation/)
- [Quickshell](https://quickshell.outfoxxed.me/docs/guide/install-setup/)
- And more listed in the manual installation...

### Optional dependencies:

- strawberry
- easyeffects
- blueman
- telegram-desktop
- discord
- kvantum
- firefox

## Installing

### Automatic Method (Recommended)

After cloning the repository, run the installation script. It will handle everything, including the creation of the `.nibrasshell.json` config file:

```bash
python install.py
```

<details>
<summary><strong>Manual Installation (Click to expand)</strong></summary>

### Arch Users:

```bash
# Install required applications
yay -S base-devel brightnessctl network-manager-applet konsole blueman ark dolphin ffmpegthumbs playerctl kvantum polkit-kde-agent jq gufw tar gammastep wl-clipboard easyeffects hyprpicker hyprshot-git bc sysstat kitty sassc systemsettings acpi fish kde-material-you-colors plasma5support plasma5-integration plasma-framework5 ttf-jetbrains-mono-nerd ttf-fantasque-nerd powerdevil power-profiles-daemon libjpeg6-turbo swww python-regex copyq swww quickshell
# Install optional applications
yay -S orchis-theme-git discord firefox visual-studio-code-bin nwg-look-bin qt5ct telegram-desktop strawberry
```

### Fedora

```bash
# Enable rpmfusion repository
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# Install needed apps with other supporting apps like media support
sudo dnf install ffmpeg --allowerasing
sudo dnf groupinstall "Sound and Video" --allowerasing
# Enable Hyprland repository
sudo dnf copr enable solopasha/hyprland
sudo dnf install hyprland hyprshot hyprpicker wl-clipboard swww
# Enable Quickshell repository
sudo dnf copr enable errornointernet/quickshell
sudo dnf install quickshell
# material-you-colors
sudo dnf copr enable luisbocanegra/kde-material-you-colors
sudo dnf install kde-material-you-colors
```

### Depth effect requirements

- we need `rembg` and `pillow` to create the needed images to apply depth effect

```bash
pip install rembg[gpu] pillow psutil
```

### Setting up files:

    git clone https://github.com/AhmedSaadi0/NibrasShell.git
    # Copy files, backup, etc.

### Change the settings

- **Note:** This step is handled automatically when using `install.py`.
- Create a file named `.nibrasshell.json` in your home directory and add your personalized settings.

```json
{
  "username": "Ahmed Alsaadi",
  "profilePicture": "/home/ahmed/wallpapers/profile.png",
  "networkMonitor": "wlp0s20f3",
  "darkM3WallpaperPath": "/home/ahmed/wallpapers/dark",
  "lightM3WallpaperPath": "/home/ahmed/wallpapers/light",
  "weatherLocation": "sanaa"
}
```

</details>

## Keybindings

| Keybinding  | Action                                                          |
| :---------- | :-------------------------------------------------------------- |
| `Super + /` | Open Cheatsheet menu and there you will see all the keybindings |

</details>

# Screenshots - لقطات شاشة

|                                                          M3 Light                                                          |                                                         M3 Dark                                                          |
| :------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------: |
| <img alt='M3 Light screenshot' src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/m3-light.png'/> | <img alt='M3 Dark screenshot' src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/m3-dark.png'/> |

|                                                  Nord Light                                                   |                                                  Nord Dark                                                   |
| :-----------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------: |
| <img alt='Nord' src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/nord-light.png'/> | <img alt='Nord' src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/nord-dark.png'/> |

|                                                    Gruvbox Light                                                    |                                                    Gruvbox Dark                                                    |
| :-----------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| <img alt='Gruvbox' src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/gruvbox-light.png'/> | <img alt='Gruvbox' src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/gruvbox-dark.png'/> |

|                                                        Catppuccin Dark                                                        |                                                   TokyoNight Dark                                                   |
| :---------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------: |
| <img alt='Catppuccin-dark' src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/Catppuccin-dark.png'/> | <img alt='TokyoNight' src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/tokyonight.png'/> |

### Settings - الإعدادات

[Watch a video](https://youtu.be/w7taDzj4_Y8)

<p align='center'>
	<img src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/settings1.png' width="48%"/>
	<img src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/settings2.png' width="48%"/>
	<img src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/settings3.png' width="48%"/>
	<img src='https://github.com/AhmedSaadi0/nibrasshell/blob/quickshell/screenshots/settings4.png' width="48%"/>
</p>

---

# Credits - الحقوق

### Icons and GTK Themes

- [Gruvbox icon theme](https://www.pling.com/p/1327720/)
- [Vivid-Dark-Icons](https://www.pling.com/p/2110189/)
- [Tela-icon-theme](https://www.pling.com/p/1279924/)
- [Zafiro Nord Icons](https://www.pling.com/p/1937741/)
- [Dracula GTK Theme](https://www.pling.com/p/1687249/)
- [TokyoNight GTK Theme](https://www.pling.com/p/1681315/)
- [Shades of purple GTK/Kvantum](https://www.pling.com/p/2074105/)

### PNG Icons from Flaticon

- Foggy icons by [Freepik](https://www.flaticon.com/free-icons/foggy)
- High voltage icons by [Muhammad Atif](https://www.flaticon.com/free-icons/high-voltage)
- Wind and Rain icons by [Freepik](https://www.flaticon.com/free-icons/wind)
- Notification icons by [Freepik](https://www.flaticon.com/free-icons/notification)
