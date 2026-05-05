pragma Singleton

import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: catppuccinLightTheme

    themeName: "CatppuccinLight"
    _themeMode: "light"

    // wallpaper
    _wallpaper: App.assets.getWallpaperPath("catppuccin_light.jpeg")

    // desktopClock
    _desktopClockEnabled: true
    _desktopClockFont: "Overhead BRK"
    _desktopClockColor: "#281F34"
    _desktopClockFormat: "hh:mm AP - MM/dd"
    _desktopClockSize: Qt.size(638.23, 225.73)
    _desktopClockPosition: Qt.point(638.09, 552.60)
    _desktopClockSahdowEnabled: false
    _desktopClockSahdowColor: "#00000044"
    _desktopClockUseThemeColor: false
    _desktopClockUseAnimation: true

    // Clock Depth Effect
    _desktopClockDepthEffectEnabled: true
    _desktopClockDepthModel: "u2net"
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("catppuccin_light_depth.png")

    _baseRadius: 12
    _elementRadius: 15
    _iconFont: "FantasqueSansM Nerd Font Propo"
    _bodyFont: "JF Flat"

    _themeIcons: "Colloid-Purple-Dracula-Dark"

    // Hyprland
    _hyprBorderWidth: 2
    _hyprActiveBorder: "rgba(219FB5ff) rgba(E976CBff) 0deg"
    _hyprInactiveBorder: "rgba(E6E9EFaa) 0deg"
    _hyprRounding: 12
    _hyprDropShadow: "yes"
    _hyprGapsIn: 5
    _hyprGapsOut: "12, 15, 15, 52"
    _hyprLayout: "dwindle"
    _hyprAnimationsEnabled: true
    _hyprBezier: "decel, 0.05, 0.7, 0.1, 1"
    _hyprAnimWindows: "1, 5, decel, slidefade 18%"
    _hyprAnimWorkspaces: "1, 3, md_standard, slidefade 8%"
    _hyprBlurEnabled: true
    _hyprBlurSize: 4
    _hyprBlurPasses: 2
    _hyprDimInactive: false
    _hyprDimStrength: 0
    _hyprShadowRange: 28
    _hyprShadowColor: "#ffffff"

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

    // _kvantumTheme: "Tellgo"
    _gtkTheme: "Catppuccin-Latte-Standard-Blue-Light"
}
