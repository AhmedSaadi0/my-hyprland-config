pragma Singleton

import QtQuick

import "root:/config"

BaseTheme {
    id: darkTheme

    themeName: "DraculaLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("linux.png")

    _primary: "#c197ff"       // بنفسجي ناعم
    _secondary: "#ff79c6"     // وردي نيوني
    _onPrimary: "#f8f8f2"     // خلفية فاتحة جدًا
    _onSecondary: "#f8f8f2"

    // _topbarColor: "#f8f8f2"
    // _topbarFgColor: "#44475a"
    //
    // _topbarBgColorV1: "#e2e2e2"
    // _topbarBgColorV2: "#ffb86c"
    // _topbarBgColorV3: "#6272a4"
    // _topbarFgColorV1: "#44475a"
    // _topbarFgColorV2: "#282a36"
    // _topbarFgColorV3: "#f8f8f2"
    //
    // _leftMenuBgColorV1: "#ffffff"
    // _leftMenuBgColorV2: "#e2e2e2"
    // _leftMenuBgColorV3: "#bd93f9"
    // _leftMenuFgColorV1: "#282a36"
    // _leftMenuFgColorV2: "#44475a"
    // _leftMenuFgColorV3: "#f8f8f2"
    //
    // _subtleTextColor: "#44475acc"  // alpha 0.8
    //
    // _volOsdBgColor: "#e2e2e2"
    // _volOsdFgColor: "#282a36"

    _plasmaColorScheme: "DraculaLight"
    _konsoleProfile: "DraculaLight.profile"

    _themeIcons: "Zafiro-Dracula"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Tokyonight-Dark-BL"

    _hyprActiveBorder: "rgba(ff79c6ff) rgba(8be9fdff) 0deg"
}
