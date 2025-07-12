pragma Singleton

import QtQuick

BaseTheme {
    id: root
    themeName: "M3Dark"

    _enableDynamicColoring: true
    _enableDynamicWallpapers: true
    _dynamicWallpapersPath: "/home/ahmed/wallpapers/dark"

    _themeMode: "dark"
    _baseRadius: 18
    _hyprBorderWidth: 3

    _wallpaper: "dark.png"

    // _primary: "#DCB5F3"
    // _secondary: "#F7B28A"

    _plasmaColorScheme: "MaterialYouDark"
    _konsoleProfile: "MaterialYouAlt.profile"

    _themeIcons: "Vivid-Dark-Icons"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Breeze-Dark"

    _hyprActiveBorder: "rgba(678382ff) rgba(9d6c73ff) 0deg"
}
