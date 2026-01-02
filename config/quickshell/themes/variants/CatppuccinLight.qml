pragma Singleton

import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: catppuccinLightTheme

    themeName: "CatppuccinLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("Cat.jpg")

    // --- الألوان الأساسية ---
    _primary: "#209fb5" // Blue
    _onPrimary: "#eff1f5"

    _secondary: "#ea76cb" // Pink
    _onSecondary: "#eff1f5"

    _tertiary: "#739d6f" // Mauve
    _onTertiary: "#eff1f5"

    _error: "#f38ba8"
    _onError: "#eff1f5"

    _success: "#739d6f"
    _onSuccess: "#eff1f5"

    _warning: "#c5b28a"
    _onWarning: "#eff1f5"

    _topbarColor: "#e6e9ef" // Mantle
    _topbarFgColor: "#4c4f69" // Text

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

    // _themeIcons: "Catppuccin-Latte"
    _themeIcons: "Vivid-Dark-Icons"
    // _kvantumTheme: "Tellgo"
    _gtkTheme: "Catppuccin-Latte-Standard-Blue-Light"

    _hyprActiveBorder: "rgba(219FB5ff) rgba(E976CBff) 0deg" // Blue and Pink
    _hyprInactiveBorder: "rgba(E6E9EFaa) 0deg"
}
