pragma Singleton

import QtQuick

import "root:/config"

BaseTheme {
    id: darkTheme

    themeName: "DarkTheme"

    _wallpaper: App.assets.getWallpaperPath("dark.jpg")

    _primary: "#F59549"
    _secondary: "#02A4ED"

    _topbarColor: "#191C21"
    _plasmaColorScheme: "DarkAGS"
    _konsoleProfile: "dark.profile"

    _themeIcons: "Infinity-Dark-Icons"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Tokyonight-Dark-BL"

    _hyprActiveBorder: "rgba(ff9a4cff) rgba(0080ffff) 0deg"
}
