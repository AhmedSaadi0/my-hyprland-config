pragma Singleton

import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: deerTheme

    themeName: "DeerTheme"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("deer.jpg")

    _primary: "#DCB5F3"
    _secondary: "#F7B28A"

    _tertiary: "#A2E8FF"
    _onTertiary: "#0A1D27"

    // Error: أحمر ناعم (Salmon Pink)
    _error: "#ff8f9e"
    _onError: "#0A1D27"

    // Success: أخضر مائي ناعم (Mint Green)
    _success: "#a7e4a5"
    _onSuccess: "#0A1D27"

    // Warning: أصفر كريمي (Vanilla)
    _warning: "#fceab6"
    _onWarning: "#0A1D27"

    _topbarColor: "#0A1D27"
    _plasmaColorScheme: "BlueDeer"
    _konsoleProfile: "game.profile"

    _themeIcons: "Vivid-Dark-Icons"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Kimi-dark"

    _hyprActiveBorder: "rgba(FDB4B7ff) rgba(A2E8FFff) 0deg"
}
