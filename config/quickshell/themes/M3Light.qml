pragma Singleton

import QtQuick

BaseTheme {
    id: root
    themeName: "M3Light"

    _enableDynamicColoring: true
    _enableDynamicWallpapers: true
    _dynamicWallpapersPath: "/home/ahmed/wallpapers/light"

    _themeMode: "light"
    _baseRadius: 14
    _hyprBorderWidth: 3

    _wallpaper: "light.png"

    // _primary: "#DCB5F3"
    // _secondary: "#F7B28A"

    _plasmaColorScheme: "MaterialYouLight"
    _konsoleProfile: "MaterialYouAlt.profile"

    _themeIcons: "Tela-light"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Breeze-Light"

    _hyprActiveBorder: "rgba(678382ff) rgba(9d6c73ff) 0deg"
}
