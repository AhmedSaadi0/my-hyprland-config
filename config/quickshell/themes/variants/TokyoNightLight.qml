pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: lightTheme
    themeName: "TokyoNightLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("tokyonight-light.png")

    _primary: "#2e7de9"
    _secondary: "#7847bd"

    _onPrimary: "#e9e9ec"
    _onSecondary: "#e9e9ec"

    _tertiary: "#007197"
    _onTertiary: "#e9e9ec"

    // Error: أحمر (Red)
    _error: "#f52a65"
    _onError: "#e9e9ec"

    // Success: أخضر (Green)
    _success: "#589b13"
    _onSuccess: "#e9e9ec"

    // Warning: برتقالي/بني (Orange)
    _warning: "#b36600"
    _onWarning: "#e9e9ec"

    _topbarColor: "#e9e9ec"        // base
    _topbarFgColor: "#3760bf"      // text
    _topbarBgColorV1: "#d5d6db"    // light gray
    _topbarBgColorV2: "#bcc0cc"    // gray
    _topbarBgColorV3: "#f52a65"    // red-accent
    _topbarFgColorV1: "#3760bf"    // text
    _topbarFgColorV2: "#3760bf"    // text
    _topbarFgColorV3: "#e9e9ec"    // base

    _leftMenuBgColorV1: "#e9e9ec"  // base
    _leftMenuBgColorV2: "#d5d6db"  // light gray
    _leftMenuBgColorV3: "#007197"  // cyan
    _leftMenuFgColorV1: "#3760bf"  // text
    _leftMenuFgColorV2: "#3760bf"  // text
    _leftMenuFgColorV3: "#e9e9ec"  // base

    _subtleTextColor: "#6172bacc"  // subtle
    _volOsdBgColor: "#d5d6db"      // light gray
    _volOsdFgColor: "#3760bf"      // text

    _hyprActiveBorder: "rgba(2e7de9ff) rgba(7847bdff) 0deg"

    _plasmaColorScheme: "NibrasTokyoNightLight"
    _konsoleProfile: "NibrasTokyoNightLight.profile"

    _themeIcons: "Tela-light"
    // _kvantumTheme: "Tellgo"
    _gtkTheme: "Tokyonight-Light"
}
