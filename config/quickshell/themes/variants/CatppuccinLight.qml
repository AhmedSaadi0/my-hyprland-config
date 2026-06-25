pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: catppuccinLightTheme

    themeName: "CatppuccinLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("catppuccin_light.jpeg")

    _desktopClockEnabled: true
    _desktopClockFont: "Overhead BRK"
    _desktopClockColor: "#281F34"
    _desktopClockFormat: "hh:mm AP - MM/dd"
    _desktopClockSize: Qt.size(638.23, 225.73)
    _desktopClockPosition: Qt.point(638.09, 552.60)
    _desktopClockShadowEnabled: false
    _desktopClockShadowColor: "#00000044"
    _desktopClockUseThemeColor: false
    _desktopClockUseAnimation: true

    _desktopClockDepthEffectEnabled: true
    _desktopClockDepthModel: "u2net"
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("catppuccin_light_depth.png")

    _baseRadius: 12
    _elementRadius: 15
    _iconFont: "FantasqueSansM Nerd Font Propo"
    _bodyFont: "JF Flat"

    _themeIcons: "Colloid-Purple-Dracula-Dark"

    _hyprBorderWidth: 2
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

    _primary: "#209fb5"           // Teal
    _onPrimary: "#EFF1F5"         // Base
    _secondary: "#ea76cb"         // Pink
    _onSecondary: "#EFF1F5"
    _tertiary: "#40a02b"          // Green (تم تغييرها لـ Latte Green الحقيقية لزيادة التناسق)
    _onTertiary: "#EFF1F5"
    _error: "#d20f39"             // Red
    _onError: "#EFF1F5"

    _surface: "#EFF1F5"                      // Base
    _onSurface: "#4C4F69"                    // Text
    _surfaceDim: "#DCE0E8"                   // Crust
    _surfaceBright: "#EFF1F5"                // Base
    _surfaceContainerLowest: "#FFFFFF"
    _surfaceContainerLow: "#F2F3F7"          // Mantle
    _surfaceContainer: "#EFF1F5"             // Base
    _surfaceContainerHigh: "#E6E9EF"         // Mantle
    _surfaceContainerHighest: "#CCD0DA"      // Surface0
    _surfaceVariant: "#E6E9EF"
    _onSurfaceVariant: "#6C7086"             // Subtext0

    _primaryContainer: "#d2f1f5"             // Light Teal Container
    _onPrimaryContainer: "#1e6c7a"
    _secondaryContainer: "#fddfe9"           // Light Pink Container
    _onSecondaryContainer: "#9e3d82"
    _tertiaryContainer: "#e2efdf"            // Light Green Container
    _onTertiaryContainer: "#2d701e"
    _errorContainer: "#f8d7da"               // Light Red Container
    _onErrorContainer: "#d20f39"

    _outline: "#9CA0B0"                      // Surface2
    _outlineVariant: "#CCD0DA"               // Surface0
    _inverseSurface: "#4C4F69"
    _onInverseSurface: "#EFF1F5"
    _inversePrimary: "#209FB5"
    _shadow: "#222222"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasCatppuccinLight"
    _konsoleProfile: "CatppuccinLight.profile"

    _gtkTheme: "Catppuccin-Latte-Standard-Blue-Light"
}
