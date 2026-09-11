pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: oxocarbonDark

    themeName: "OxocarbonDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("oxocarbon-dark.png")

    _primary: "#33b1ff"             // Blue
    _onPrimary: "#161616"           // Background
    _secondary: "#be95ff"           // Purple
    _onSecondary: "#161616"
    _tertiary: "#3ddbd9"            // Cyan
    _onTertiary: "#161616"
    _error: "#ee5396"               // Red/Pink
    _onError: "#161616"

    _surface: "#161616"                        // Background
    _onSurface: "#dde1e6"                      // Foreground
    _surfaceDim: "#0f0f0f"                     // Darker bg
    _surfaceBright: "#262626"                  // bg2
    _surfaceContainerLowest: "#0a0a0a"
    _surfaceContainerLow: "#111111"
    _surfaceContainer: "#161616"               // Background
    _surfaceContainerHigh: "#262626"           // bg2
    _surfaceContainerHighest: "#393939"        // bg3
    _surfaceVariant: "#262626"
    _onSurfaceVariant: "#a8a8a8"

    _primaryContainer: "#1a2a3a"               // Dark Blue container
    _onPrimaryContainer: "#33b1ff"
    _secondaryContainer: "#2a1f3a"             // Dark Purple container
    _onSecondaryContainer: "#be95ff"
    _tertiaryContainer: "#0f2e2e"              // Dark Cyan container
    _onTertiaryContainer: "#3ddbd9"
    _errorContainer: "#3a1a2a"                 // Dark Red container
    _onErrorContainer: "#ee5396"

    _outline: "#525252"                        // bg4
    _outlineVariant: "#393939"                 // bg3
    _inverseSurface: "#f2f4f8"
    _onInverseSurface: "#161616"
    _inversePrimary: "#33b1ff"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasOxocarbonDark"
    _konsoleProfile: "OxocarbonDark.profile"

    _themeIcons: "Tela-dark"
    _gtkTheme: "Breeze-Dark"
    _kvantumTheme: "KvArcDark"
}
