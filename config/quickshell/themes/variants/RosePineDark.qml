pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: rosePineDark

    themeName: "RosePineDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("rosepine-dark.png")

    _primary: "#ebbcba"             // Rose
    _onPrimary: "#191724"           // Base
    _secondary: "#c4a7e7"            // Iris
    _onSecondary: "#191724"
    _tertiary: "#9ccfd8"             // Foam
    _onTertiary: "#191724"
    _error: "#eb6f92"               // Love
    _onError: "#191724"

    _surface: "#191724"                        // Base
    _onSurface: "#e0def4"                      // Text
    _surfaceDim: "#12111d"                     // Darker than base
    _surfaceBright: "#26233a"                  // Overlay
    _surfaceContainerLowest: "#0f0e1a"
    _surfaceContainerLow: "#12111d"
    _surfaceContainer: "#191724"               // Base
    _surfaceContainerHigh: "#1f1d2e"           // Surface
    _surfaceContainerHighest: "#26233a"        // Overlay
    _surfaceVariant: "#26233a"
    _onSurfaceVariant: "#908caa"               // Subtle

    _primaryContainer: "#332733"               // Dark Rose container
    _onPrimaryContainer: "#ebbcba"
    _secondaryContainer: "#2b2542"             // Dark Iris container
    _onSecondaryContainer: "#c4a7e7"
    _tertiaryContainer: "#1e2f3a"              // Dark Foam container
    _onTertiaryContainer: "#9ccfd8"
    _errorContainer: "#3d1e2e"                 // Dark Love container
    _onErrorContainer: "#eb6f92"

    _outline: "#6e6a86"                        // Muted
    _outlineVariant: "#26233a"                 // Overlay
    _inverseSurface: "#e0def4"
    _onInverseSurface: "#191724"
    _inversePrimary: "#ebbcba"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasRosePineDark"
    _konsoleProfile: "RosePineDark.profile"

    _themeIcons: "Tela-dark"
    _gtkTheme: "Breeze-Dark"
    _kvantumTheme: "KvArcDark"
}
