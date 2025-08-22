pragma Singleton

import QtQuick

import "root:/config"

BaseTheme {
    id: darkTheme

    themeName: "CatppuccinDark"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("CatppuccinDark.png")

    _primary: "#89B4FA" // Blue
    _secondary: "#F38BA8" // Pink

    _onPrimary: "#1e1e2e"
    _onSecondary: "#1e1e2e"
    _topbarColor: "#1E1E2E" // Mantle
    _topbarFgColor: "#cdd6f4" // Text

    // خلفيات متدرجة وداكنة ولكنها مختلفة
    _topbarBgColorV1: "#181825" // Surface0
    _topbarBgColorV2: "#323F57" // Surface1
    _topbarBgColorV3: "#5c4b73" // Surface2

    _topbarFgColorV1: "#cdd6f4" // Text
    _topbarFgColorV2: "#cdd6f4" // Text
    _topbarFgColorV3: "#cdd6f4" // Text

    _leftMenuBgColorV1: "#1e1e2e" // Base
    _leftMenuBgColorV2: "#181825" // Mantle
    // خلفية العنصر النشط أغمق قليلاً من البقية للتمييز
    _leftMenuBgColorV3: "#45475a" // Surface1

    _leftMenuFgColorV1: "#b4befe" // Lavender (لون النص للعنصر النشط)
    _leftMenuFgColorV2: "#cdd6f4" // Text
    _leftMenuFgColorV3: "#1e1e2e" // Base (لون النص فوق الخلفية النشطة)

    _subtleTextColor: "#a6adc8cc"
    _volOsdBgColor: "#313244" // Surface0
    _volOsdFgColor: "#cdd6f4" // Text

    _plasmaColorScheme: "NibrasCatppuccinDark"
    _konsoleProfile: "CatppuccinDark.profile"

    _themeIcons: "Catppuccin-Latte"
    // _kvantumTheme: "Tellgo"
    _gtkTheme: "Catppuccin-Mocha-Standard-Blue-Dark"

    _hyprActiveBorder: "rgba(89b4faff) rgba(f5c2e7ff) 0deg"
}
