# My Hyprland Config

**Join our [Discord Server](https://discord.gg/EUcGgRGhrs) for discussions and support!**

[![Discord](https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/EUcGgRGhrs)

<details>
<summary>العربية</summary>

**ملاحظة:** هذه الإعدادات لا تزال في مرحلة التطوير، وسأقوم بإضافة المزيد من الميزات بصورة مستمرة عندما يتاح لدي وقت أكثر.

### ملاحظة

يُفضل استخدام هذا الإعداد مع تطبيقات KDE للحصول على أفضل تجربة. إذا اخترت استخدام تطبيقات أخرى، فلا بأس بذلك، ولكن ستحتاج إلى ضبط الإعدادات يدوياً إذا لم يكن لديها ثيم مشابه لبقية التطبيقات.

> 💡 **مهم:** للحصول على الوظائف الكاملة للشبكة، يرجى استخدام **[الفورك الخاص بي](https://github.com/AhmedSaadi0/ags)** من (AGS)، حيث أن النسخة الأصلية لا تحتوي على هذه التحسينات.

### برامج ضرورية

- [Hyprland](https://wiki.hyprland.org/Getting-Started/Installation/)
- [AGS](https://github.com/Aylur/ags/wiki/installation)
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
- [Gradience](https://github.com/GradienceTeam/Gradience?tab=readme-ov-file) for gtk4 Material you themes

### برامج اختيارية

- strawberry
- easyeffects
- nwg-look
- blueman
- telegram-desktop
- discord
- kvantum
- firefox
- qt5ct
- qt6ct
- kitty

## التثبيت

### تثبيت البرامج لمستخدمي Arch:

```bash
# تثبيت البرامج المطلوبة
yay -S base-devel brightnessctl network-manager-applet konsole blueman ark dolphin ffmpegthumbs playerctl kvantum polkit-kde-agent jq gufw tar gammastep wl-clipboard easyeffects hyprpicker hyprshot-git bc sysstat kitty sassc systemsettings acpi fish kde-material-you-colors plasma5support plasma5-integration plasma-framework5 aylurs-gtk-shell-git ttf-jetbrains-mono-nerd ttf-fantasque-nerd powerdevil gnome-bluetooth-3.0 power-profiles-daemon libjpeg6-turbo swww python-regex copyq

# تثبيت البرامج الاختيارية
yay -S orchis-theme-git discord firefox visual-studio-code-bin nwg-look-bin qt5ct telegram-desktop strawberry
```

### مستخدمي Fedora 40

```bash
# تثبيت البرامج المطلوبه وبرامج اخرى مثل دعم الصوتيات
sudo dnf install ffmpeg --allowerasing
sudo dnf install network-manager-applet playerctl brightnessctl gammastep sysstat sassc plasma-systemsettings acpi fish gnome-bluetooth power-profiles-daemon lm_sensors easyeffects blueman telegram-desktop kvantum konsole pulseaudio-utils polkit-gnome polkit-qt polkit-kde gstreamer1-libav strawberry dnf-plugins-core gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld ffmpeg gstreamer1-plugins-base-devel vnstat retroarch inkscape gimp g4music android-tools plasma-integration-qt5 plasma-integration vlc-plugin-gstreamer vlc mpv kget kteatime gwenview unzip p7zip p7zip-plugins unrar copyq jq

# تفعيل مستودع هيبر لاند
sudo dnf copr enable solopasha/hyprland
sudo dnf install aylurs-gtk-shell hyprland hyprshot hyprpicker wl-clipboard

# تفعيل مستودع gradience
sudo dnf copr enable lyessaadi/gradience
sudo dnf install gradience

# تفعيل مستودع material-you-colors
sudo dnf copr enable luisbocanegra/kde-material-you-colors
sudo dnf install kde-material-you-colors

# تثبيت plasma-desktop
sudo dnf install plasma-desktop
```

**ملاحطة:** إذا كنت تستخدم نظام تشغيل آخر غير أرش او فيدورا فسوف تحتاج إلى تثبيت جميع البرامج الضرورية. قد تختلف الخطوات بناءً على نوع توزيعتك.

#### مثلا:

- بالنسبة للتوزيعات القائمة على **دبيان/أوبونتو**، يمكنك تثبيت البرامج باستخدام `apt install` او البحث عن طريق `apt search hyprland`.
- بالنسبة لبرامج ادارة الحزم الاخرى، قم بالبحث عن كل برنامج وتثبيته عبر مدير حزم نظامك.

### اعداد الملفات:

    git clone https://github.com/AhmedSaadi0/my-hyprland-config.git

    # عمل نسخة احتياطية لملفاتك الاصلية
    mv ~/.config/hypr/ ~/.config/hypr-old
    mv ~/.config/ags/ ~/.config/ags-old
    mv ~/.config/wofi/ ~/.config/wofi-old
    mv ~/.config/easyeffects ~/.config/easyeffects-old
    mv ~/.config/fish/config.fish ~/.config/fish/config.back.fish

    # نسخ الملفات
    cp -r my-hyprland-config ~/.config/hypr
    cp -r ~/.config/hypr/config/ags ~/.config/ags
    cp -r ~/.config/hypr/config/wofi ~/.config/wofi
    cp ~/.config/hypr/config/config.fish ~/.config/fish/config.fish

    # اعداد الصلاحيات للملفات التنفيذية
    sudo chmod +x ~/.config/hypr/scripts/*
    sudo chmod +x ~/.config/ags/scripts/*

    # اعداد بيئة النظام
    # غير ضرورية لانه يتم استخدام nvidia.conf
    # استخدمها اذا كنت تعتقد انك تحتاجها فعلا
    sudo cp /etc/environment /etc/environmentOLD
    echo 'QT_QPA_PLATFORMTHEME=kde' | sudo tee -a /etc/environment

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
    tar xvf ~/.config/hypr/config/icons/kora-grey-light-panel.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Magma.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/NeonIcons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/la-capitaine-icon-theme.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/oomox-aesthetic-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Vivid-Dark-Icons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Windows11-red-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Zafiro-Nord-Dark-Black.tar.gz -C ~/.local/share/icons

    mkdir ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Cabinet-Light-Orange.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Kimi-dark.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Nordic-darker-standard-buttons.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Orchis-Green-Dark-Compact.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Shades-of-purple.tar.xz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Tokyonight-Dark-BL.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Dracula.tar.gz -C ~/.themes
    mkdir ~/.local/share/themes
    unzip ~/.config/hypr/config/gtk-themes/adw-gtk3.zip -d ~/.local/share/themes

### بامكانك تغير خط الجهاز الى 'JF Flat' اذا اردت ان تحصل على نفس الخط الذي لدي

### انشاء كرون تاب لتحسين استخدام البطارية باستخدام قاعدة الشحن 40-80

    VISUAL=/usr/bin/nano crontab -e
    * * * * * ~/.config/hypr/scripts/battery.sh

#### تغيير مسار ملف صوت اشعارات البطارية في الملف `hypr/scripts/battery.sh`

    home_path="/home/ahmed"

### تغيير الاعدادات

- انشء ملف باسم `.ahmed-config.json` في مجلد الهوم

```bash
nvim .ahmed-config.json
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

<details>

<summary>English</summary>

**Note:** This configuration is a work in progress, and I will continue to add more features as time permits.

### Note

It is recommended to use this setup with KDE applications for the best experience. If you choose to use other applications, that is fine, but you will need to theme them manually if they do not have a theme similar to the rest of the applications.

> 💡 **Important:** For full network functionality, please compile **[my fork](https://github.com/AhmedSaadi0/ags)** of (AGS), as the original version does not include these enhancements.

### Required dependencies:

- [Hyprland](https://wiki.hyprland.org/Getting-Started/Installation/)
- [AGS](https://github.com/Aylur/ags/wiki/installation)
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
- [KDE Material You Colors](https://github.com/luisbocanegra/kde-material-you-colors)
- [Gradience](https://github.com/GradienceTeam/Gradience?tab=readme-ov-file) for gtk4 Material you themes
- copyq

### Optional dependencies:

- strawberry
- easyeffects
- nwg-look
- blueman
- telegram-desktop
- discord
- kvantum
- firefox
- qt5ct
- qt6ct
- kitty

## Installing:

### Arch Users:

```bash
# Install required applications
yay -S base-devel brightnessctl network-manager-applet konsole blueman ark dolphin ffmpegthumbs playerctl kvantum polkit-kde-agent jq gufw tar gammastep wl-clipboard easyeffects hyprpicker hyprshot-git bc sysstat kitty sassc systemsettings acpi fish kde-material-you-colors plasma5support plasma5-integration plasma-framework5 aylurs-gtk-shell-git ttf-jetbrains-mono-nerd ttf-fantasque-nerd powerdevil gnome-bluetooth-3.0 power-profiles-daemon libjpeg6-turbo swww python-regex copyq

# Install optional applications
yay -S orchis-theme-git discord firefox visual-studio-code-bin nwg-look-bin qt5ct telegram-desktop strawberry
```

### Fedora 40 users

```bash
# Install needed apps with other supporing apps like media support
sudo dnf install ffmpeg --allowerasing
sudo dnf install network-manager-applet playerctl brightnessctl gammastep sysstat sassc plasma-systemsettings acpi fish gnome-bluetooth power-profiles-daemon lm_sensors easyeffects blueman telegram-desktop kvantum konsole pulseaudio-utils polkit-gnome polkit-qt polkit-kde gstreamer1-libav strawberry dnf-plugins-core gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld ffmpeg gstreamer1-plugins-base-devel vnstat retroarch inkscape gimp g4music android-tools plasma-integration-qt5 plasma-integration vlc-plugin-gstreamer vlc mpv kget kteatime gwenview unzip p7zip p7zip-plugins unrar copyq jq

# Enable Hyprland repository
sudo dnf copr enable solopasha/hyprland
sudo dnf install aylurs-gtk-shell hyprland hyprshot hyprpicker wl-clipboard

# Enable gradience repository
sudo dnf copr enable lyessaadi/gradience
sudo dnf install gradience

# Enable kde-material-you-colors repository
sudo dnf copr enable luisbocanegra/kde-material-you-colors
sudo dnf install kde-material-you-colors

# Install plasma-desktop for its apps
sudo dnf install plasma-desktop
```

**Note:** If you use an operating system other than Arch or Fedora, you will need to install all required dependencies. The specific steps may vary depending on your distro.

#### Example:

- For **Debian/Ubuntu-based** systems, you can install dependencies using `apt install` or search using `apt search hyprland`.
- For other package managers, search for each dependency and install using your system's package manager.

### Setting up files:

    git clone https://github.com/AhmedSaadi0/my-hyprland-config.git

    # backup your files
    mv ~/.config/hypr/ ~/.config/hypr-old
    mv ~/.config/ags/ ~/.config/ags-old
    mv ~/.config/wofi/ ~/.config/wofi-old
    mv ~/.config/easyeffects ~/.config/easyeffects-old
    cp ~/.config/fish/config.fish ~/.config/fish/config.back.fish

    # copy files
    cp -r my-hyprland-config ~/.config/hypr
    cp -r ~/.config/hypr/config/ags ~/.config/ags
    cp -r ~/.config/hypr/config/wofi ~/.config/wofi
    cp ~/.config/hypr/config/config.fish ~/.config/fish/config.fish

    # set permissions for scripts
    sudo chmod +x ~/.config/hypr/scripts/*
    sudo chmod +x ~/.config/ags/scripts/*

    # setup environment
    # Not needed anymore becuase we are using nvidia.conf
    # only use it if you think you realy need it
    sudo cp /etc/environment /etc/environmentOLD
    echo 'QT_QPA_PLATFORMTHEME=kde' | sudo tee -a /etc/environment

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
    tar xvf ~/.config/hypr/config/icons/kora-grey-light-panel.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Magma.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/NeonIcons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/la-capitaine-icon-theme.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/oomox-aesthetic-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Vivid-Dark-Icons.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Windows11-red-dark.tar.gz -C ~/.local/share/icons
    tar xvf ~/.config/hypr/config/icons/Zafiro-Nord-Dark-Black.tar.gz -C ~/.local/share/icons

    mkdir ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Cabinet-Light-Orange.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Kimi-dark.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Nordic-darker-standard-buttons.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Orchis-Green-Dark-Compact.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Shades-of-purple.tar.xz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Tokyonight-Dark-BL.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/Dracula.tar.gz -C ~/.themes
    tar xvf ~/.config/hypr/config/gtk-themes/adw-gtk3.tar.gz -C ~/.themes
    mkdir ~/.local/share/themes
    unzip ~/.config/hypr/config/gtk-themes/adw-gtk3.zip -d ~/.local/share/themes

### You can change system fonts if you want to 'JF Flat' to have the same font I had

### Creating crontab for battery 40-80 rule:

    VISUAL=/usr/bin/nano crontab -e
    * * * * * ~/.config/hypr/scripts/battery.sh

#### Change home path for battery script in `hypr/scripts/battery.sh`

    home_path="/home/ahmed"

### Change the settings

- Create a file with the name `.ahmed-config.json` in your home directory.

```bash
nvim .ahmed-config.json
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

# Screenshots - لقطات

| Category | Screenshots                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Dark     | <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/dark_1.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/dark_2.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/dark_3.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/dark_4.png" width="200" />                                                                                                                                                                                                                                             |
| Light    | <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/light_1.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/light_2.png" width="200"/> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/light_3.png" width="200" />                                                                                                                                                                                                                                                                                                                                                        |
| Neutral  | <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/neutral_1.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/neutral_2.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/neutral_3.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/neutral_4.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/neutral_5.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/neutral_6.png" width="200" /> |
| Menu     | <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/dashboard.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/notifications.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/weather.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/monitors.png" width="200" /> <img src="https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/network.png" width="200" />                                                                                                                  |

### Material 3

#### Dark

<p align='center'>
	<img alt='M3 Dark screenshot' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/dark_m.png'/>
</p>

#### Light

<p align='center'>
	<img alt='M3 Light screenshot' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/light_m.png'/>
</p>

<hr />

### Credits

<a href="https://www.flaticon.com/free-icons/high-voltage" title="high voltage icons">High voltage icons created by Muhammad Atif - Flaticon</a>

<a href="https://www.pling.com/p/2037657/" title="BeautySolar">BeautySolar Icons</a>

<a href="https://www.pling.com/p/2090548/" title="Shades of purple Kvantum">Shades of purple Kvantum</a>

<a href="https://www.pling.com/p/2074105/" title="Shades of purple GTK">Shades of purple GTK</a>

<a href="https://www.pling.com/p/2110189/" title="Vivid-Dark-Icons">Vivid-Dark-Icons</a>

<a href="https://www.pling.com/p/1326889/" title="Kimi">Kimi GTK Theme</a>

<a href="https://www.pling.com/p/1956870/" title="Zafiro-Nord-Dark-Black">Zafiro-Nord-Dark-Black Icons</a>

<a href="https://www.pling.com/p/1248852/" title="Cabinet">Cabinet GTK Theme</a>

<a href="https://www.pling.com/p/1256209/" title="Kora">Kora Icons</a>

<a href="https://www.pling.com/p/1148695/" title="La Capitaine">La Capitaine Icons</a>

<a href="https://www.pling.com/p/1681315/" title="TokyoNight">TokyoNight GTK Theme</a>

<a href="https://www.pling.com/p/1436570/" title="Infinity-Dark-Icons">Infinity-Dark-Icons</a>

<a href="https://www.pling.com/p/1687249/" title="Dracula">Dracula GTK Theme</a>

<a href="https://www.pling.com/p/2078427/" title="Gradient-Dark-Icons">Gradient-Dark-Icons</a>

<a href="https://www.pling.com/p/1877058/" title="Rowaita icons">Rowaita icons</a>

<a href="https://www.pling.com/p/1891521/" title="Jasper-gtk-theme">Jasper-gtk-theme</a>

<a href="https://www.pling.com/p/1658156/" title="Victory-gtk-theme">Victory-gtk-theme</a>

<a href="https://store.kde.org/p/2106379" title="Windows11 icon theme">Windows11 icon theme</a>
