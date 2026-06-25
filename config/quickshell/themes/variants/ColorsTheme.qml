pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: colorsTheme

    themeName: "ColorsTheme"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("colors.png")
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("colors_depth.png")
    _desktopClockFont: "Xenophobia"
    _desktopClockFormat: "hh mm AP - MM/dd"
    _desktopClockPosition: Qt.point(7, 11)
    _desktopClockDepthEffectEnabled: true
    _desktopClockSize: Qt.size(1860, 600)
    _desktopClockShadowEnabled: false
    _desktopClockUseThemeColor: false
    _desktopClockColor: "#22c1eb"

    _primary: "#22C1EB"
    _onPrimary: "#1E1240"

    _secondary: "#FD02FF"
    _onSecondary: "#EFF0F1"

    _tertiary: "#FAD000"
    _onTertiary: "#19002e"

    _error: "#ff3333"
    _onError: "#ffffff"

    _surface: "#3A2961"
    _onSurface: "#EFF0F1"
    _surfaceDim: "#2D1F4D"
    _surfaceBright: "#4F3784"
    _surfaceContainerLowest: "#1E1240"
    _surfaceContainerLow: "#2D1F4D"
    _surfaceContainer: "#3E2D68"
    _surfaceContainerHigh: "#4F3784"
    _surfaceContainerHighest: "#7150A1"
    _surfaceVariant: "#4F3784"
    _onSurfaceVariant: "#D0C5E8"

    // حاويات الألوان تم جعلها بظلال نيون غامقة تندمج بشكل مثالي مع خلفية Shades of Purple الداكنة
    _primaryContainer: "#143d4f"             // Dark Neon Blue
    _onPrimaryContainer: "#22C1EB"
    _secondaryContainer: "#4d154d"           // Dark Neon Magenta
    _onSecondaryContainer: "#FD02FF"
    _tertiaryContainer: "#3d3300"            // Dark Neon Gold
    _onTertiaryContainer: "#FAD000"
    _errorContainer: "#471414"
    _onErrorContainer: "#ff3333"

    _outline: "#8A6FBF"
    _outlineVariant: "#4F3784"
    _inverseSurface: "#EFF0F1"
    _onInverseSurface: "#3A2961"
    _inversePrimary: "#22C1EB"
    _shadow: "#121212"
    _scrim: "#000000"

    _plasmaColorScheme: "AColors"
    _themeIcons: "Vivid-Dark-Icons"
    _kvantumTheme: "Shades-of-purple"
    _gtkTheme: "Shades-of-purple"
    _konsoleProfile: "pinky.profile"

    _baseRadius: 12

    _hyprBorderWidth: 3
    _hyprRounding: _baseRadius
    _hyprDropShadow: "no"
}
