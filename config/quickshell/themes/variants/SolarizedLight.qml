pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: solarizedLight

    themeName: "SolarizedLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("solarized-light.png")

    _primary: "#268bd2"             // Blue
    _onPrimary: "#fdf6e3"           // base3
    _secondary: "#859900"           // Green
    _onSecondary: "#fdf6e3"
    _tertiary: "#d33682"            // Magenta
    _onTertiary: "#fdf6e3"
    _error: "#dc322f"               // Red
    _onError: "#fdf6e3"

    _surface: "#fdf6e3"                        // base3
    _onSurface: "#657b83"                      // base00
    _surfaceDim: "#eee8d5"                     // base2
    _surfaceBright: "#fdf6e3"
    _surfaceContainerLowest: "#ffffff"
    _surfaceContainerLow: "#fef9ec"
    _surfaceContainer: "#fdf6e3"               // base3
    _surfaceContainerHigh: "#eee8d5"           // base2
    _surfaceContainerHighest: "#d3cbb7"
    _surfaceVariant: "#eee8d5"
    _onSurfaceVariant: "#586e75"               // base01

    _primaryContainer: "#d1e6f5"               // Light Blue container
    _onPrimaryContainer: "#1a6090"
    _secondaryContainer: "#e0e9c8"             // Light Green container
    _onSecondaryContainer: "#5a6b00"
    _tertiaryContainer: "#f0d6e3"              // Light Magenta container
    _onTertiaryContainer: "#8a2a5a"
    _errorContainer: "#f5d6d6"                 // Light Red container
    _onErrorContainer: "#a31e1e"

    _outline: "#93a1a1"                        // base1
    _outlineVariant: "#eee8d5"                 // base2
    _inverseSurface: "#002b36"                 // base03
    _onInverseSurface: "#fdf6e3"
    _inversePrimary: "#268bd2"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasSolarizedLight"
    _konsoleProfile: "SolarizedLight.profile"

    _themeIcons: "Papirus-Light"
    _gtkTheme: "Breeze"
    _kvantumTheme: "KvArc"
}
