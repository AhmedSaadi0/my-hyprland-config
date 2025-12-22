pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: tokyoNightDark
    themeName: "TokyoNightDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("tokyonight-dark.png")

    _primary: "#7aa2f7"
    _secondary: "#bb9af7"

    _onPrimary: "#1a1b26"
    _onSecondary: "#1a1b26"

    _tertiary: "#7dcfff"
    _onTertiary: "#1a1b26"

    // Error: أحمر (Red)
    _error: "#f7768e"
    _onError: "#1a1b26"

    // Success: أخضر (Green)
    _success: "#9ece6a"
    _onSuccess: "#1a1b26"

    // Warning: برتقالي (Orange)
    _warning: "#e0af68"
    _onWarning: "#1a1b26"

    _topbarColor: "#1a1b26"        // base
    _topbarFgColor: "#c0caf5"      // text
    _topbarBgColorV1: "#24283b"    // darker
    _topbarBgColorV2: "#414868"    // grayish
    _topbarBgColorV3: "#f7768e"    // red-accent
    _topbarFgColorV1: "#c0caf5"    // text
    _topbarFgColorV2: "#c0caf5"    // text
    _topbarFgColorV3: "#1a1b26"    // base

    _leftMenuBgColorV1: "#1a1b26"  // base
    _leftMenuBgColorV2: "#24283b"  // darker
    _leftMenuBgColorV3: "#7dcfff"  // cyan
    _leftMenuFgColorV1: "#c0caf5"  // text
    _leftMenuFgColorV2: "#c0caf5"  // text
    _leftMenuFgColorV3: "#1a1b26"  // base

    _subtleTextColor: "#9aa5cecc"  // subtle
    _volOsdBgColor: "#24283b"      // darker
    _volOsdFgColor: "#c0caf5"      // text

    _hyprActiveBorder: "rgba(7aa2f7ff) rgba(bb9af7ff) 0deg"

    _plasmaColorScheme: "NibrasTokyoNightDark"
    _konsoleProfile: "NibrasTokyoNightDark.profile"

    _themeIcons: "Tela-dark"
    _gtkTheme: "Tokyonight-Dark"
}
