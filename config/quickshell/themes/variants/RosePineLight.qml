pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: rosePineLight

    themeName: "RosePineLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("rosepine-light.png")

    _primary: "#d7827e"             // Rose (Dawn)
    _onPrimary: "#faf4ed"           // Base Dawn
    _secondary: "#907aa9"           // Iris
    _onSecondary: "#faf4ed"
    _tertiary: "#56949f"            // Foam
    _onTertiary: "#faf4ed"
    _error: "#b4637a"               // Love
    _onError: "#faf4ed"

    _surface: "#faf4ed"                        // Base Dawn
    _onSurface: "#575279"                      // Text Dawn
    _surfaceDim: "#f2e9e1"                     // Overlay
    _surfaceBright: "#fffaf3"                  // Surface
    _surfaceContainerLowest: "#ffffff"
    _surfaceContainerLow: "#fffaf3"            // Surface
    _surfaceContainer: "#faf4ed"               // Base
    _surfaceContainerHigh: "#f2e9e1"           // Overlay
    _surfaceContainerHighest: "#e8ddd3"
    _surfaceVariant: "#f2e9e1"
    _onSurfaceVariant: "#797593"               // Subtle

    _primaryContainer: "#f0d9d7"               // Light Rose container
    _onPrimaryContainer: "#8a3a32"
    _secondaryContainer: "#e6dced"             // Light Iris container
    _onSecondaryContainer: "#5a3a6a"
    _tertiaryContainer: "#d8e8ea"              // Light Foam container
    _onTertiaryContainer: "#2a5a62"
    _errorContainer: "#edd8dc"                 // Light Love container
    _onErrorContainer: "#b4637a"

    _outline: "#9893a5"                        // Muted
    _outlineVariant: "#f2e9e1"                 // Overlay
    _inverseSurface: "#575279"
    _onInverseSurface: "#faf4ed"
    _inversePrimary: "#d7827e"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasRosePineLight"
    _konsoleProfile: "RosePineLight.profile"

    _themeIcons: "Tela-light"
    _gtkTheme: "Breeze"
    _kvantumTheme: "KvArc"
}
