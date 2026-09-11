pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: solarizedDark

    themeName: "SolarizedDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("solarized-dark.png")

    _primary: "#268bd2"             // Blue
    _onPrimary: "#002b36"           // base03
    _secondary: "#2aa198"           // Cyan
    _onSecondary: "#002b36"
    _tertiary: "#6c71c4"            // Violet
    _onTertiary: "#002b36"
    _error: "#dc322f"               // Red
    _onError: "#fdf6e3"             // base3

    _surface: "#002b36"                        // base03
    _onSurface: "#839496"                      // base0
    _surfaceDim: "#001e26"                     // darker than base03
    _surfaceBright: "#073642"                  // base02
    _surfaceContainerLowest: "#00141c"
    _surfaceContainerLow: "#001e26"
    _surfaceContainer: "#002b36"               // base03
    _surfaceContainerHigh: "#073642"           // base02
    _surfaceContainerHighest: "#0a4a5a"        // lighter highlight
    _surfaceVariant: "#073642"
    _onSurfaceVariant: "#93a1a1"               // base1

    _primaryContainer: "#0e2f45"               // Dark Blue container
    _onPrimaryContainer: "#268bd2"
    _secondaryContainer: "#0d332f"             // Dark Cyan container
    _onSecondaryContainer: "#2aa198"
    _tertiaryContainer: "#1e2342"              // Dark Violet container
    _onTertiaryContainer: "#6c71c4"
    _errorContainer: "#3d1a1a"                 // Dark Red container
    _onErrorContainer: "#dc322f"

    _outline: "#586e75"                        // base01
    _outlineVariant: "#073642"                 // base02
    _inverseSurface: "#eee8d5"                 // base2
    _onInverseSurface: "#002b36"
    _inversePrimary: "#268bd2"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasSolarizedDark"
    _konsoleProfile: "SolarizedDark.profile"

    _themeIcons: "Papirus-Dark"
    _gtkTheme: "Breeze-Dark"
    _kvantumTheme: "KvArcDark"
}
