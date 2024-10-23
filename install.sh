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
# sudo cp /etc/environment /etc/environmentOLD
# echo 'QT_QPA_PLATFORMTHEME=kde' | sudo tee -a /etc/environment

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
# mkdir ~/.local/share/themes
# unzip ~/.config/hypr/config/gtk-themes/adw-gtk3.zip -d ~/.local/share/themes
