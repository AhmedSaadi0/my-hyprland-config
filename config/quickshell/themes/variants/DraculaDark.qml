pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: draculaDark

    themeName: "DraculaDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("dracula_dark.png")

    _desktopClockEnabled: true
    _desktopClockFont: "abeatbyKai"
    _desktopClockColor: "#ffffffc8"
    _desktopClockFormat: "hh:mm AP"
    _desktopClockSize: Qt.size(547.51, 120.33)
    _desktopClockPosition: Qt.point(1328.48, 40.24)
    _desktopClockShadowEnabled: true
    _desktopClockShadowColor: "#d1d1d1"
    _desktopClockUseThemeColor: false
    _desktopClockUseAnimation: true

    _desktopClockDepthEffectEnabled: true
    _desktopClockDepthModel: "u2net"
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("dracula_dark_depth.png")

    _baseRadius: 1
    _elementRadius: 1
    _iconFont: "FantasqueSansM Nerd Font Propo"
    _bodyFont: "JF Flat"

    _themeIcons: "Papirus"

    _hyprBorderWidth: 2
    _hyprRounding: 0
    _hyprDropShadow: "no"
    _hyprGapsIn: 5
    _hyprGapsOut: "12, 15, 15, 52"
    _hyprLayout: "dwindle"
    _hyprAnimationsEnabled: true
    _hyprBezier: "linear, 0, 0, 1, 1"
    _hyprAnimWindows: "1, 1, linear, slide"
    _hyprAnimWorkspaces: "1, 1, linear, fade"
    _hyprBlurEnabled: true
    _hyprBlurSize: 2
    _hyprBlurPasses: 2
    _hyprDimInactive: true
    _hyprDimStrength: 0
    _hyprShadowRange: 30
    _hyprShadowColor: "#00000000"

    _primary: "#bd93f9"           // Purple
    _secondary: "#8be9fd"         // Cyan
    _onPrimary: "#191a21"         // Standard Dracula dark bg
    _onSecondary: "#191a21"
    _tertiary: "#50fa7b"          // Green
    _onTertiary: "#191a21"
    _error: "#ff5555"             // Red
    _onError: "#191a21"

    _surface: "#282A36"                      // Background
    _onSurface: "#F8F8F2"                    // Foreground
    _surfaceDim: "#21222C"                   // Darker bg
    _surfaceBright: "#343746"                // Selection / Current Line
    _surfaceContainerLowest: "#191A21"
    _surfaceContainerLow: "#21222C"
    _surfaceContainer: "#282A36"
    _surfaceContainerHigh: "#343746"
    _surfaceContainerHighest: "#44475A"
    _surfaceVariant: "#343746"
    _onSurfaceVariant: "#BFBFBF"

    // مواءمة الألوان وفق تدرجات دراكولا الحقيقية (بأبعاد متباينة بدلاً من اللون الموحد 44475A)
    _primaryContainer: "#35294a"             // Dark Purple selection-like
    _onPrimaryContainer: "#bd93f9"
    _secondaryContainer: "#1e353b"           // Dark Cyan selection-like
    _onSecondaryContainer: "#8be9fd"
    _tertiaryContainer: "#1c3b24"            // Dark Green selection-like
    _onTertiaryContainer: "#50fa7b"
    _errorContainer: "#3d1c1c"               // Dark Red selection-like
    _onErrorContainer: "#ff5555"

    _outline: "#6272A4"                      // Dracula Comment Color (ممتازة للحدود الافتراضية)
    _outlineVariant: "#44475A"               // Dracula Selection Color
    _inverseSurface: "#F8F8F2"
    _onInverseSurface: "#282A36"
    _inversePrimary: "#BD93F9"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "Dracula"
    _konsoleProfile: "DraculaDark.profile"

    _kvantumTheme: "Tellgo"
    _gtkTheme: "Dracula"
}
