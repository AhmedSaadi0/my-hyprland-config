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
- sysstat
- bc
- kitty
- sassc
- systemsettings
- ttf-font-awesome-5

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
yay -S base-devel strawberry brightnessctl network-manager-applet telegram-desktop rofi qt5-gsettings konsole blueman ark dolphin ffmpegthumbs playerctl lightly-qt kvantum polkit-kde-agent ttf-font-awesome-5 jq gufw qt5ct tar gammastep wl-clipboard nwg-look-bin visual-studio-code-bin firefox easyeffects hyprpicker discord hyprshot-git bc sysstat kitty sassc systemsettings ttf-font-awesome-
```


### Setting up files - اعداد الملفات:

	git clone git@github.com:AhmedSaadi0/my-hyprland-config.git
	mv ~/.config/hypr/ ~/.config/hypr-old
	cp -r my-hyprland-config ~/.config/hypr
	cp -r ~/.config/hypr/configs/ags ~/.config/ags
	cp ~/.config/ags/modules/theme/plasma-colors/* ~/.local/share/color-schemes/
	cp ~/.config/hypr/configs/qt5ct.conf ~/.config/qt5ct/
	mkdir ~/.fonts
	cp -r ~/.config/hypr/configs/.fonts/* ~/.fonts
	sudo cp /etc/environment /etc/environmentOLD
	sudo chmod +x ~/.config/hypr/scripts/*
	sudo chmod +x ~/.config/ags/scripts/*
	echo 'QT_QPA_PLATFORMTHEME=qt5ct' | sudo tee -a /etc/environment
	mkdir ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/BeautySolar.tar.gz -C ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/Gradient-Dark-Icons.tar.gz -C ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/Infinity-Dark-Icons.tar.gz -C ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/Magma.tar.gz -C ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/NeonIcons.tar.gz -C ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/NeonIcons.tar.gz -C ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/kora-grey-light-panel.tar.gz -C ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/la-capitaine-icon-theme.tar.gz -C ~/.local/share/icons
	tar xvf ~/.config/hypr/configs/icons/oomox-aesthetic-dark.tar.gz -C ~/.local/share/icons

### You can change system fonts if you want to 'JF Flat' to have the same font I had
### بامكانك تغير خط الجهاز الى 'JF Flat' اذا اردت ان تحصل على نفس الخط الذي لدي


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
