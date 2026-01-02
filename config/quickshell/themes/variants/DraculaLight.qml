pragma Singleton

import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: draculaLight

    themeName: "DraculaLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("linux.png")

    _primary: "#c197ff"       // بنفسجي ناعم
    _secondary: "#ff79c6"     // وردي نيوني

    _onPrimary: "#f8f8f2"     // خلفية فاتحة جدًا
    _onSecondary: "#f8f8f2"

    _tertiary: "#8be9fd"
    _onTertiary: "#282a36"    // نص داكن لأن السماوي فاتح جداً

    // Error: أحمر (Dracula Red)
    _error: "#ff5555"
    _onError: "#f8f8f2"       // الأحمر داكن بما يكفي للنص الأبيض

    // Success: أخضر (Dracula Green)
    _success: "#50fa7b"
    _onSuccess: "#282a36"     // الأخضر ساطع جداً، النص الداكن أفضل

    // Warning: برتقالي (Dracula Orange)
    _warning: "#ffb86c"
    _onWarning: "#282a36"     // نص داكن للوضوح

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
