pragma Singleton

import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: draculaDark

    themeName: "DraculaDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("linux.png")

    _primary: "#ff79c6"       // وردي نيون
    _secondary: "#8be9fd"     // أزرق سماوي

    _onPrimary: "#282a36"     // خلفية داكنة (نص فوق اللون الأساسي)
    _onSecondary: "#282a36"   // خلفية داكنة

    _tertiary: "#bd93f9"
    _onTertiary: "#282a36"

    // Error: الأحمر (Dracula Red)
    _error: "#ff5555"
    _onError: "#282a36"

    // Success: الأخضر (Dracula Green)
    _success: "#50fa7b"
    _onSuccess: "#282a36"

    // Warning: البرتقالي (Dracula Orange)
    _warning: "#ffb86c"
    _onWarning: "#282a36"

    // topbar
    // _topbarColor: "#282a36"
    // _topbarFgColor: "#f8f8f2"
    //
    // _topbarBgColorV1: "#44475a"
    _topbarBgColorV2: "#531353"
    _topbarBgColorV3: "#632f4e"
    // _topbarFgColorV1: "#f8f8f2"
    _topbarFgColorV2: "#f8f8f2"
    _topbarFgColorV3: "#f8f8f2"
    //
    // // Left Menu
    // _leftMenuBgColorV1: "#282a36"
    _leftMenuBgColorV2: "#292c38" // 3f1e32
    // _leftMenuBgColorV3: "#ff79c6"
    // _leftMenuFgColorV1: "#f8f8f2"
    // _leftMenuFgColorV2: "#bd93f9"
    // _leftMenuFgColorV3: "#282a36"
    //
    // _subtleTextColor: "#f8f8f2cc"  // alpha 0.8

    // OSDs
    _volOsdBgColor: "#44475a"
    _volOsdFgColor: "#f8f8f2"

    _plasmaColorScheme: "Dracula"
    _konsoleProfile: "DraculaDark.profile"

    _themeIcons: "Zafiro-Dracula"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Dracula"

    _hyprActiveBorder: "rgba(ff79c6ff) rgba(8be9fdff) 0deg"
}
