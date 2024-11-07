#!/bin/bash

# Get the logged-in username and home directory path
username=$(whoami)
home_dir="$HOME"

# Function to prompt for user inputs with defaults and create .ahmed-config.json in the home directory
create_config() {
    # Prompt for each value with default values
    read -p "Enter your username [default: $username]: " input
    username="${input:-$username}"

    read -p "Enter the path to your profile picture [default: $home_dir/wallpapers/profile.png]: " input
    profilePicture="${input:-$home_dir/wallpapers/profile.png}"

    read -p "Enter your network monitor (e.g., wlp0s20f3) [default: wlp0s20f3]: " input
    networkMonitor="${input:-wlp0s20f3}"

    read -p "Enter network timeout in seconds [default: 300]: " input
    networkTimeout="${input:-300}"

    read -p "Enter network interval in milliseconds [default: 1000]: " input
    networkInterval="${input:-1000}"

    read -p "Enter the path to your dark M3 wallpapers [default: $home_dir/wallpapers/dark]: " input
    darkM3WallpaperPath="${input:-$home_dir/wallpapers/dark}"

    read -p "Enter the path to your light M3 wallpapers [default: $home_dir/wallpapers/light]: " input
    lightM3WallpaperPath="${input:-$home_dir/wallpapers/light}"

    read -p "Enter your weather location [default: sanaa]: " input
    weatherLocation="${input:-sanaa}"

    read -p "Enter your city [default: sanaa]: " input
    city="${input:-sanaa}"

    read -p "Enter your country [default: yemen]: " input
    country="${input:-yemen}"

    read -p "Use prayer times? (true/false) [default: true]: " input
    usePrayerTimes="${input:-true}"

    read -p "Change Plasma color? (true/false) [default: true]: " input
    changePlasmaColor="${input:-true}"

    # Create JSON file
    cat <<EOF >~/.ahmed-config-test.json
{
  "username": "$username",
  "profilePicture": "$profilePicture",
  "networkMonitor": "$networkMonitor",
  "networkTimeout": $networkTimeout,
  "networkInterval": $networkInterval,
  "darkM3WallpaperPath": "$darkM3WallpaperPath",
  "lightM3WallpaperPath": "$lightM3WallpaperPath",
  "weatherLocation": "$weatherLocation",
  "city": "$city",
  "country": "$country",
  "usePrayerTimes": $usePrayerTimes,
  "changePlasmaColor": $changePlasmaColor,
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
EOF
}

# Check if the system is Fedora
if grep -q "Fedora" /etc/os-release; then
    echo "Fedora detected. Installing required packages and enabling repositories..."

    # Enable rpmfusion repository
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Install required packages
    sudo dnf install -y ffmpeg --allowerasing
    sudo dnf install -y network-manager-applet playerctl brightnessctl gammastep sysstat sassc plasma-systemsettings acpi fish gnome-bluetooth power-profiles-daemon lm_sensors easyeffects blueman telegram-desktop kvantum konsole pulseaudio-utils polkit-gnome polkit-qt polkit-kde gstreamer1-libav strawberry dnf-plugins-core gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld ffmpeg gstreamer1-plugins-base-devel vnstat retroarch inkscape gimp g4music android-tools plasma-integration-qt5 plasma-integration vlc-plugin-gstreamer vlc mpv kget kteatime gwenview unzip p7zip p7zip-plugins unrar copyq jq swww

    # Enable Hyprland repository and install packages
    sudo dnf copr enable solopasha/hyprland -y
    sudo dnf install -y aylurs-gtk-shell hyprland hyprshot hyprpicker wl-clipboard

    # Enable Gradience repository and install Gradience
    sudo dnf copr enable lyessaadi/gradience -y
    sudo dnf install -y gradience

    # Enable material-you-colors repository and install KDE Material You Colors
    sudo dnf copr enable luisbocanegra/kde-material-you-colors -y
    sudo dnf install -y kde-material-you-colors

    # Install Plasma Desktop and additional KDE applications
    sudo dnf install -y plasma-desktop ark kate dolphin
elif grep -q "Arch" /etc/os-release; then
    echo "Arch Linux detected. Installing required packages with yay..."

    # Install required applications on Arch Linux
    yay -S --noconfirm base-devel brightnessctl network-manager-applet konsole blueman ark dolphin ffmpegthumbs playerctl kvantum polkit-kde-agent jq gufw tar gammastep wl-clipboard easyeffects hyprpicker hyprshot-git bc sysstat kitty sassc systemsettings acpi fish kde-material-you-colors plasma5support plasma5-integration plasma-framework5 aylurs-gtk-shell-git ttf-jetbrains-mono-nerd ttf-fantasque-nerd powerdevil gnome-bluetooth-3.0 power-profiles-daemon libjpeg6-turbo swww python-regex copyq

    # Install optional applications on Arch Linux
    yay -S --noconfirm orchis-theme-git discord firefox visual-studio-code-bin nwg-look-bin qt5ct telegram-desktop strawberry
else
    echo "Operating system not recognized. Skipping OS-specific installations."
    echo "Please refer to the Git repository for a list of required applications and install them manually."
fi

# Call the function to create the config file
create_config

mv ~/.config/hypr/ ~/.config/hypr-old
mv ~/.config/ags/ ~/.config/ags-old
mv ~/.config/wofi/ ~/.config/wofi-old
mv ~/.config/easyeffects ~/.config/easyeffects-old
cp ~/.config/fish/config.fish ~/.config/fish/config.back.fish

# Copy files
cp -r my-hyprland-config ~/.config/hypr
cp -r ~/.config/hypr/config/ags ~/.config/ags
cp -r ~/.config/hypr/config/wofi ~/.config/wofi
cp ~/.config/hypr/config/config.fish ~/.config/fish/config.fish

# Set permissions for scripts
sudo chmod +x ~/.config/hypr/scripts/*
sudo chmod +x ~/.config/ags/scripts/*

# Copy easyeffects settings
cp -r ~/.config/hypr/config/easyeffects ~/.config/easyeffects

# Copy theme files
mkdir -p ~/.local/share/color-schemes/
mkdir -p ~/.local/share/konsole/
mkdir -p ~/.config/Kvantum/
mkdir -p ~/.config/qt5ct/
mkdir -p ~/.config/qt6ct/

cp -r ~/.config/hypr/config/plasma-colors/* ~/.local/share/color-schemes/
cp -r ~/.config/hypr/config/kvantum-themes/* ~/.config/Kvantum/
cp -r ~/.config/hypr/config/konsole/* ~/.local/share/konsole/
cp ~/.config/hypr/config/qt5ct.conf ~/.config/qt5ct/
cp ~/.config/hypr/config/qt6ct.conf ~/.config/qt6ct/

mkdir -p ~/.fonts
cp -r ~/.config/hypr/config/.fonts/* ~/.fonts

mkdir -p ~/.local/share/icons
for icon in BeautySolar Delight-brown-dark Gradient-Dark-Icons Infinity-Dark-Icons kora-grey-light-panel Magma NeonIcons la-capitaine-icon-theme oomox-aesthetic-dark Vivid-Dark-Icons Windows11-red-dark Zafiro-Nord-Dark-Black; do
    tar xvf ~/.config/hypr/config/icons/$icon.tar.gz -C ~/.local/share/icons
done

mkdir -p ~/.themes
for theme in Cabinet-Light-Orange Kimi-dark Nordic-darker-standard-buttons Orchis-Green-Dark-Compact Shades-of-purple Tokyonight-Dark-BL Dracula; do
    tar xvf ~/.config/hypr/config/gtk-themes/$theme.tar.gz -C ~/.themes
done
