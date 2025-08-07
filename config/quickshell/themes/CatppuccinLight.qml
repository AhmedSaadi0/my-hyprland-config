pragma Singleton

import QtQuick

import "root:/config"

BaseTheme {
    id: darkTheme

    themeName: "CatppuccinLight"

    _wallpaper: App.assets.getWallpaperPath("Cat.jpg")

    _primary: "#209fb5" // Blue
    _secondary: "#ea76cb" // Pink

    _onPrimary: "#eff1f5"
    _onSecondary: "#eff1f5"
    _topbarColor: "#e6e9ef" // Mantle
    _topbarFgColor: "#4c4f69" // Text

    // خلفيات متدرجة وفاتحة ولكنها مختلفة
    _topbarBgColorV1: "#ccd0da" // Surface0
    _topbarBgColorV2: "#bcc0cc" // Surface1
    _topbarBgColorV3: "#acb0be" // Surface2

    _topbarFgColorV1: "#4c4f69" // Text
    _topbarFgColorV2: "#4c4f69" // Text
    _topbarFgColorV3: "#4c4f69" // Text

    _leftMenuBgColorV1: "#eff1f5" // Base
    _leftMenuBgColorV2: "#e6e9ef" // Mantle
    // خلفية العنصر النشط أغمق قليلاً من البقية للتمييز
    _leftMenuBgColorV3: "#bcc0cc" // Surface1

    _leftMenuFgColorV1: "#7287fd" // Lavender (لون النص للعنصر النشط)
    _leftMenuFgColorV2: "#4c4f69" // Text
    _leftMenuFgColorV3: "#eff1f5" // Base (لون النص فوق الخلفية النشطة)

    _subtleTextColor: "#6c6f85cc"
    _volOsdBgColor: "#ccd0da" // Surface0
    _volOsdFgColor: "#4c4f69" // Text

    _plasmaColorScheme: "NibrasCatppuccinLight"
    _konsoleProfile: "CatppuccinLight.profile"

    _themeIcons: "Catppuccin-Latte"
    // _kvantumTheme: "Tellgo"
    _gtkTheme: "Catppuccin-Latte-Standard-Blue-Light"

    _hyprActiveBorder: "rgba(30, 102, 245, 1) rgba(234, 118, 203, 1) 0deg" // Blue and Pink
}
