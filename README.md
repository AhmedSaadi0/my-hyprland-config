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

## التثبيت

### الطريقة التلقائية (موصى به)

بعد استنساخ المستودع، قم بتشغيل السكربت التالي الذي سيهتم بكل شيء، بما في ذلك إنشاء ملف الإعدادات `.nibrasshell.json`:

```bash
python install.py
```

<details>
<summary><strong>التثبيت اليدوي (اضغط للفتح)</strong></summary>

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
sudo dnf install lsp-plugins calf rubberband zam-plugins breeze-gtk-gtk4 breeze-gtk-gtk3 kde-connect ffmpegthumbs bluedevil kde-gtk-config kde-settings-pulseaudio kdebugsettings kdenetwork-filesharing kdeplasma-addons plasma-nm plasma-systemmonitor plasma-vault sddm-breeze xwaylandvideobridge NetworkManager-l2tp NetworkManager-libreswan kde-settings-sddm kde-connect-libs imsettings imsettings-libs sddm network-manager-applet playerctl brightnessctl gammastep sysstat sassc plasma-systemsettings acpi fish gnome-bluetooth lm_sensors easyeffects blueman telegram-desktop kvantum konsole pulseaudio-utils polkit-qt polkit-kde gstreamer1-libav strawberry dnf-plugins-core gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld ffmpeg gstreamer1-plugins-base-devel vnstat nethogs retroarch inkscape gimp g4music android-tools plasma-integration-qt5 plasma-integration vlc-plugin-gstreamer vlc mpv kget kteatime gwenview unzip p7zip p7zip-plugins unrar copyq jq lsp-plugins lmms lsp-plugins-clap lsp-plugins-jack lsp-plugins-ladspa lv2-calf-plugins lv2-calf-plugins-gui lsp-plugins-lv2 lsp-plugins-vst lsp-plugins-vst3 lsp-plugins-jack lsp-plugins-gstreamer lsp-plugins lsp-plugins-clap gh python3.13

# تفعيل مستودع هيبر لاند
sudo dnf copr enable solopasha/hyprland
sudo dnf install hyprland hyprshot hyprpicker wl-clipboard swww


# تفعيل مستودع كويك شل
sudo dnf copr enable errornointernet/quickshell
sudo dnf install quickshell

# تفعيل مستودع material-you-colors
sudo dnf copr enable luisbocanegra/kde-material-you-colors
sudo dnf install kde-material-you-colors

# تثبيت plasma-desktop - غير الزامي
sudo dnf install plasma-desktop ark kate dolphin
```

**ملاحطة:** إذا كنت تستخدم نظام تشغيل آخر غير أرش او فيدورا فسوف تحتاج إلى تثبيت جميع البرامج الضرورية. قد تختلف الخطوات بناءً على نوع توزيعتك.

#### مثلا:

- بالنسبة للتوزيعات القائمة على **دبيان/أوبونتو**، يمكنك تثبيت البرامج باستخدام `apt install` او البحث عن طريق `apt search hyprland`.
- بالنسبة لبرامج ادارة الحزم الاخرى، قم بالبحث عن كل برنامج وتثبيته عبر مدير حزم نظامك.

### متطلبات تاثير العمق للساعة في سطح المكتب

- نحتاج مكتبه `rembg` و `pillow` لانشاء الصور ذات تاثير العمق

```bash
pip install rembg[gpu] pillow psutil
```

### الان يمكنك استخدام سكربت التثبيت واختيار رقم 2

```bash
python install.py
Choose your language / اختر لغتك / Vyberte jazyk:
1. English
2. العربية
3. Česky
> 2

=============================================
سكربت تثبيت NibrasShell
=============================================
1. تثبيت المتطلبات
2. تثبيت الواجهة
3. تحديث QuickShell
4. حذف الواجهة
5. إنشاء/تعديل ملف الإعدادات
6. خروج
اختر أحد الخيارات: 2
```

### في حال لم يعمل السكربت الان اكمل مع التثبيت اليدوي

#### استخرج جميع الثيمات في المجلد `config/gtk-themes/` الى `~/.themes`

### اعداد الملفات:

    git clone https://github.com/AhmedSaadi0/NibrasShell.git

    # عمل نسخة احتياطية لملفاتك الاصلية
    mv ~/.config/hypr/ ~/.config/hypr-old
    mv ~/.config/quickshell/ ~/.config/quickshell-old
    mv ~/.config/wofi/ ~/.config/wofi-old
    mv ~/.config/easyeffects ~/.config/easyeffects-old
    mv ~/.config/fish/config.fish ~/.config/fish/config.back.fish

    # نسخ الملفات
    cp -r nibrasshell ~/.config/hypr
    cp -r ~/.config/hypr/config/quickshell ~/.config/quickshell
    cp -r ~/.config/hypr/config/wofi ~/.config/wofi
    cp ~/.config/hypr/config/config.fish ~/.config/fish/config.fish

    # اعداد الصلاحيات للملفات التنفيذية
    sudo chmod +x ~/.config/hypr/scripts/*
    sudo chmod +x ~/.config/quickshell/scripts/*

    # نسخ اعدادت easyeffects
    cp -r ~/.config/hypr/config/easyeffects ~/.config/easyeffects

    # نسخ ملفات الثيمات
    mkdir ~/.local/share/color-schemes/
    mkdir ~/.local/share/konsole/
    mkdir ~/.config/Kvantum/
    mkdir ~/.config/qt5ct/
    mkdir ~/.config/qt6ct/

    cp -r ~/.config/hypr/config/plasma-colors/* ~/.local/share/color-schemes/
    cp -r ~/.config/hypr/config/kvantum-themes/* ~/.config/Kvantum/
    cp -r ~/.config/hypr/config/konsole/* ~/.local/share/konsole/
    cp ~/.config/hypr/config/qt5ct.conf ~/.config/qt5ct/
    cp ~/.config/hypr/config/qt6ct.conf ~/.config/qt6ct/

    mkdir ~/.fonts
    cp -r ~/.config/hypr/config/.fonts/* ~/.fonts

    mkdir ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/BeautySolar.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Delight-brown-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Gradient-Dark-Icons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Infinity-Dark-Icons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/la-capitaine-icon-theme.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Magma.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/oomox-aesthetic-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Vivid-Dark-Icons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Windows11-red-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Zafiro-Nord-Dark-Black.tar.gz -C ~/.local/share/icons

### بامكانك تغير خط الجهاز الى 'JF Flat' اذا اردت ان تحصل على نفس الخط الذي لدي

### تغيير الاعدادات

- انشء ملف باسم `.nibrasshell.json` في مجلد الهوم

```bash
nvim .nibrasshell.json
```

- قم باضافة الاعدادات حسب جهازك ومنطقتك

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

## Installing

### Automatic Method (Recommended)

After cloning the repository, run the installation script. It will handle everything, including the creation of the `.nibrasshell.json` config file:

```bash
python install.py
```

<details>
<summary><strong>Manual Installation (Click to expand)</strong></summary>

### Required dependencies:

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

### Optional dependencies:

- strawberry
- easyeffects
- blueman
- telegram-desktop
- discord
- kvantum
- firefox

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
sudo dnf install lsp-plugins calf rubberband zam-plugins breeze-gtk-gtk4 breeze-gtk-gtk3 kde-connect ffmpegthumbs bluedevil kde-gtk-config kde-settings-pulseaudio kdebugsettings kdenetwork-filesharing kdeplasma-addons plasma-nm plasma-systemmonitor plasma-vault sddm-breeze xwaylandvideobridge NetworkManager-l2tp NetworkManager-libreswan kde-settings-sddm kde-connect-libs imsettings imsettings-libs sddm network-manager-applet playerctl brightnessctl gammastep sysstat sassc plasma-systemsettings acpi fish gnome-bluetooth lm_sensors easyeffects blueman telegram-desktop kvantum konsole pulseaudio-utils polkit-qt polkit-kde gstreamer1-libav strawberry dnf-plugins-core gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld ffmpeg gstreamer1-plugins-base-devel vnstat nethogs retroarch inkscape gimp g4music android-tools plasma-integration-qt5 plasma-integration vlc-plugin-gstreamer vlc mpv kget kteatime gwenview unzip p7zip p7zip-plugins unrar copyq jq lsp-plugins lmms lsp-plugins-clap lsp-plugins-jack lsp-plugins-ladspa lv2-calf-plugins lv2-calf-plugins-gui lsp-plugins-lv2 lsp-plugins-vst lsp-plugins-vst3 lsp-plugins-jack lsp-plugins-gstreamer lsp-plugins lsp-plugins-clap gh python3.13

# Enable Hyprland repository
sudo dnf copr enable solopasha/hyprland
sudo dnf install hyprland hyprshot hyprpicker wl-clipboard swww

# Enable Quickshell repository
sudo dnf copr enable errornointernet/quickshell
sudo dnf install quickshell

# material-you-colors
sudo dnf copr enable luisbocanegra/kde-material-you-colors
sudo dnf install kde-material-you-colors

# Install plasma-desktop for its apps - Optional
sudo dnf install plasma-desktop ark kate dolphin
```

**Note:** If you use an operating system other than Arch or Fedora, you will need to install all required dependencies. The specific steps may vary depending on your distro.

#### Example:

- For **Debian/Ubuntu-based** systems, you can install dependencies using `apt install` or search using `apt search hyprland`.
- For other package managers, search for each dependency and install using your system's package manager.

### Depth effect requirements

- we need `rembg` and `pillow` to create the needed images to apply depth effect

```bash
pip install rembg[gpu] pillow psutil
```

### Now you can use the install script option 2

```bash
$ python install.py
Choose your language / اختر لغتك / Vyberte jazyk:
1. English
2. العربية
3. Česky
> 1

=============================================
NibrasShell Installation Script
=============================================
1. Install Dependencies
2. Install NibrasShell
3. Update QuickShell
4. Uninstall NibrasShell
5. Create/Edit User Config
6. Exit
Choose an option: 2
```

### in case the install script still did not work you can continue

#### Extract all themes in `config/gtk-themes/` to `~/.themes`

### Setting up files:

    git clone https://github.com/AhmedSaadi0/NibrasShell.git

    # backup your files
    mv ~/.config/hypr/ ~/.config/hypr-old
    mv ~/.config/quickshell/ ~/.config/quickshell-old
    mv ~/.config/wofi/ ~/.config/wofi-old
    mv ~/.config/easyeffects ~/.config/easyeffects-old
    cp ~/.config/fish/config.fish ~/.config/fish/config.back.fish

    # copy files
    cp -r nibrasshell ~/.config/hypr
    cp -r ~/.config/hypr/config/quickshell ~/.config/quickshell
    cp -r ~/.config/hypr/config/wofi ~/.config/wofi
    cp ~/.config/hypr/config/config.fish ~/.config/fish/config.fish

    # set permissions for scripts
    sudo chmod +x ~/.config/hypr/scripts/*
    sudo chmod +x ~/.config/quickshell/scripts/*

    # Copy easyeffects settings
    cp -r ~/.config/hypr/config/easyeffects ~/.config/easyeffects

    # copy theme files
    mkdir ~/.local/share/color-schemes/
    mkdir ~/.local/share/konsole/
    mkdir ~/.config/Kvantum/
    mkdir ~/.config/qt5ct/
    mkdir ~/.config/qt6ct/

    cp -r ~/.config/hypr/config/plasma-colors/* ~/.local/share/color-schemes/
    cp -r ~/.config/hypr/config/kvantum-themes/* ~/.config/Kvantum/
    cp -r ~/.config/hypr/config/konsole/* ~/.local/share/konsole/
    cp ~/.config/hypr/config/qt5ct.conf ~/.config/qt5ct/
    cp ~/.config/hypr/config/qt6ct.conf ~/.config/qt6ct/

    mkdir ~/.fonts
    cp -r ~/.config/hypr/config/.fonts/* ~/.fonts

    mkdir ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/BeautySolar.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Delight-brown-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Gradient-Dark-Icons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Infinity-Dark-Icons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/la-capitaine-icon-theme.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Magma.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/oomox-aesthetic-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Vivid-Dark-Icons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Windows11-red-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Zafiro-Nord-Dark-Black.tar.gz -C ~/.local/share/icons

### You can change system fonts if you want to 'JF Flat' to have the same font I had

### Change the settings

- Create a file with the name `.nibrasshell.json` in your home directory.

```bash
nvim .nibrasshell.json
```

- Add these settings

```json
{
  "username": "Ahmed Alsaadi",
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
