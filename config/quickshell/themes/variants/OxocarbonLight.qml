pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: oxocarbonLight

    themeName: "OxocarbonLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("oxocarbon-light.png")

    _primary: "#0f62fe"             // IBM Blue 60
    _onPrimary: "#f2f4f8"           // Light bg
    _secondary: "#8a3ffc"           // IBM Purple 60
    _onSecondary: "#f2f4f8"
    _tertiary: "#007d79"            // Teal 60
    _onTertiary: "#f2f4f8"
    _error: "#da1e28"               // Red 60
    _onError: "#f2f4f8"

    _surface: "#f2f4f8"                        // Light bg
    _onSurface: "#161616"                      // Dark fg
    _surfaceDim: "#dde1e6"                     // Gray 10
    _surfaceBright: "#ffffff"
    _surfaceContainerLowest: "#ffffff"
    _surfaceContainerLow: "#f8fafb"
    _surfaceContainer: "#f2f4f8"
    _surfaceContainerHigh: "#dde1e6"
    _surfaceContainerHighest: "#c1c7cd"        // Gray 20
    _surfaceVariant: "#dde1e6"
    _onSurfaceVariant: "#525252"               // Gray 70

    _primaryContainer: "#d0e2ff"               // Light Blue container
    _onPrimaryContainer: "#002a4d"
    _secondaryContainer: "#e8daff"             // Light Purple container
    _onSecondaryContainer: "#2a0a5e"
    _tertiaryContainer: "#c1f0f0"              // Light Teal container
    _onTertiaryContainer: "#003e3e"
    _errorContainer: "#ffd6d9"                 // Light Red container
    _onErrorContainer: "#5a0a0e"

    _outline: "#8d8d8d"                        // Gray 50
    _outlineVariant: "#dde1e6"
    _inverseSurface: "#161616"
    _onInverseSurface: "#f2f4f8"
    _inversePrimary: "#0f62fe"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasOxocarbonLight"
    _konsoleProfile: "OxocarbonLight.profile"

    _themeIcons: "Tela-light"
    _gtkTheme: "Breeze"
    _kvantumTheme: "KvArc"
}
