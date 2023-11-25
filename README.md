# This is my Hyprland config 
**Note:** This configuration is a work in progress, and I will continue to add more features as time permits.

**ملاحظة:** هذه الإعدادات لا تزال في مرحلة التطوير، وسأقوم بإضافة المزيد من الميزات بصورة مستمرة عندما يتاح لدي وقت أكثر.

### Required dependencies - برامج ضرورية
- [Hyprland](https://wiki.hyprland.org/Getting-Started/Installation/)
- [AGS](https://github.com/Aylur/ags/wiki/installation)
- Rofi
- network-manager-applet
- playerctl
- polkit-kde-agent
- ttf-font-awesome-5
- qt5ct
- Dolphin
- brightnessctl
- gammastep
- wl-clipboard
- hyprpicker

### Optional dependencies - برامج اختيارية
- strawberry
- easyeffects
- nwg-look
- blueman
- telegram-desktop
- discord
- qt5-gsettings
- kvantum
- lightly-qt
- konsole
- vs code
- firefox

## Installing - التثبيت

### For Arch Users - لمستخدمي Arch:
```bash
yay -S base-devel strawberry brightnessctl network-manager-applet telegram-desktop rofi qt5-gsettings konsole blueman ark dolphin ffmpegthumbs playerctl lightly-qt kvantum polkit-kde-agent ttf-font-awesome-5 jq gufw qt5ct tar gammastep wl-clipboard nwg-look-bin visual-studio-code-bin firefox easyeffects hyprpicker discord hyprshot-git
```


### Copy files - نسخ الملفات:

	git clone git@github.com:AhmedSaadi0/my-hyprland-config.git
	mv ~/.config/hypr/ ~/.config/hypr-old
	cp my-hyprland-config ~/.config/hypr
	cp ~/.config/hypr/config/ags ~/.config/ags


### Creating crontab for battery 40-80 rule - انشاء كرون تاب لتحسين استخدام البطارية باستخدام قاعدة الشحن 40-80 
    VISUAL=/usr/bin/nano crontab -e
    * * * * * ~/.config/hypr/scripts/battery.sh

# Screenshots - لقطات
<p align='center'>
	<img alt='screenshot 1' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/1.png'/>
</p>
<p align='center'>
	<img alt='screenshot 10' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/10.png'/>
</p>
<p align='center'>
	<img alt='screenshot 2' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/2.png'/>
</p>
<p align='center'>
	<img alt='screenshot 3' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/3.png'/>
</p>
<p align='center'>
	<img alt='screenshot 4' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/4.png'/>
</p>
<p align='center'>
	<img alt='screenshot 5' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/5.png'/>
</p>
<p align='center'>
	<img alt='screenshot 6' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/6.png'/>
</p>
<p align='center'>
	<img alt='screenshot 11' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/11.png'/>
</p>
<p align='center'>
	<img alt='screenshot 7' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/7.png'/>
</p>
<p align='center'>
	<img alt='screenshot 8' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/8.png'/>
</p>
<p align='center'>
	<img alt='screenshot 9' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/9.png'/>
</p>
<p align='center'>
	<img alt='screenshot 12' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/12.png'/>
</p>
<p align='center'>
	<img alt='screenshot 13' src='https://github.com/AhmedSaadi0/my-hyprland-config/blob/main/screenshots/13.png'/>
</p>
