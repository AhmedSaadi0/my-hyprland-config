pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: deerTheme

    themeName: "DeerTheme"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("deer.jpg")
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("deer_depth.png")
    _desktopClockFont: "Xenophobia"
    _desktopClockFormat: "hh:mm AP MM/dd"
    _desktopClockPosition: Qt.point(8.015625, 8.015625)
    _desktopClockDepthEffectEnabled: true
    _desktopClockSize: Qt.size(1848.86328125, 612.8984375)
    _desktopClockShadowEnabled: false
    _desktopClockUseThemeColor: false
    _desktopClockColor: Qt.rgba(0.05, 0.08, 0.13, 0.8)

    _primary: "#B38BFF"
    _onPrimary: "#120A2A"
    _secondary: "#E68A5C"
    _onSecondary: "#1A0F0A"
    _tertiary: "#8DE8FF"
    _onTertiary: "#0A1D27"
    _error: "#ff8f9e"
    _onError: "#0A1D27"

    _surface: "#0A1D27"
    _onSurface: "#FFFFFF"
    _surfaceDim: "#061520"
    _surfaceBright: "#142A3C"
    _surfaceContainerLowest: "#050F17"
    _surfaceContainerLow: "#0C2030"
    _surfaceContainer: "#0E2435"
    _surfaceContainerHigh: "#142A3C"
    _surfaceContainerHighest: "#1E3A5A"
    _surfaceVariant: "#142A3C"
    _onSurfaceVariant: "#B0C4DE"

    // تدرجات الألوان للحاويات من أجل إبراز المظهر الداكن الغني باللون الكحلي/البنفسجي
    _primaryContainer: "#2e1b4d"             // Subtle Dark Purple container
    _onPrimaryContainer: "#B38BFF"
    _secondaryContainer: "#3d1a0a"           // Subtle Dark Orange container
    _onSecondaryContainer: "#E68A5C"
    _tertiaryContainer: "#0e2a36"            // Subtle Dark Cyan container
    _onTertiaryContainer: "#8DE8FF"
    _errorContainer: "#3a151b"
    _onErrorContainer: "#ff8f9e"

    _outline: "#3A5A7A"
    _outlineVariant: "#1E3A5A"
    _inverseSurface: "#FFFFFF"
    _onInverseSurface: "#0A1D27"
    _inversePrimary: "#B38BFF"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "BlueDeer"
    _konsoleProfile: "game.profile"

    _themeIcons: "Vivid-Dark-Icons"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Kimi-dark"
}
