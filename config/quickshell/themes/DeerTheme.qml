pragma Singleton

import QtQuick

import "root:/config"

BaseTheme {
    id: deerTheme

    themeName: "DeerTheme"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("deer.jpg")

    _primary: "#DCB5F3"
    _secondary: "#F7B28A"

    _topbarColor: "#0A1D27"
    _plasmaColorScheme: "BlueDeer"
    _konsoleProfile: "game.profile"

    _themeIcons: "Vivid-Dark-Icons"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Kimi-dark"

    _hyprActiveBorder: "rgba(FDB4B7ff) rgba(A2E8FFff) 0deg"
}
