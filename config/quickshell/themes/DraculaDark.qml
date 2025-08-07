pragma Singleton

import QtQuick

import "root:/config"

BaseTheme {
    id: darkTheme

    themeName: "DraculaDark"

    _wallpaper: App.assets.getWallpaperPath("linux.png")

    _primary: "#ff79c6"       // وردي نيون
    _secondary: "#8be9fd"     // أزرق سماوي
    _onPrimary: "#282a36"     // خلفية داكنة (نص فوق اللون الأساسي)
    _onSecondary: "#282a36"   // خلفية داكنة

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
    // _leftMenuBgColorV2: "#44475a"
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
    _konsoleProfile: "dark.profile"

    _themeIcons: "Zafiro-Dracula"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Tokyonight-Dark-BL"

    _hyprActiveBorder: "rgba(ff79c6ff) rgba(8be9fdff) 0deg"
}
