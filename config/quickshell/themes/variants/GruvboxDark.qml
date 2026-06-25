pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: gruvboxDark
    themeName: "GruvboxDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("gruvbox-dark.png")

    _primary: "#8CC37B"           // Gruvbox Green
    _onPrimary: "#282828"
    _secondary: "#fabd2f"         // Gruvbox Yellow
    _onSecondary: "#282828"
    _tertiary: "#83a598"          // Gruvbox Blue
    _onTertiary: "#282828"
    _error: "#fb4934"             // Gruvbox Red
    _onError: "#282828"

    _surface: "#282828"                      // bg0
    _onSurface: "#EBDBB2"                    // fg0
    _surfaceDim: "#1D2021"                   // bg0_h
    _surfaceBright: "#3C3836"                // bg1
    _surfaceContainerLowest: "#1D2021"
    _surfaceContainerLow: "#222426"
    _surfaceContainer: "#2C2F31"
    _surfaceContainerHigh: "#3C3836"
    _surfaceContainerHighest: "#504945"      // bg2
    _surfaceVariant: "#3C3836"
    _onSurfaceVariant: "#D5C4A1"             // fg2

    // تصحيح الألوان الموحدة 504945 في الحاويات وجعلها متطابقة مع تدرجات Gruvbox
    _primaryContainer: "#3a3e25"             // Dark Green Highlight
    _onPrimaryContainer: "#8cc37b"
    _secondaryContainer: "#453512"           // Dark Yellow Highlight
    _onSecondaryContainer: "#fabd2f"
    _tertiaryContainer: "#1c2d30"            // Dark Blue Highlight
    _onTertiaryContainer: "#83a598"
    _errorContainer: "#401614"               // Dark Red Highlight
    _onErrorContainer: "#fb4934"

    _outline: "#665C54"                      // bg3
    _outlineVariant: "#504945"               // bg2
    _inverseSurface: "#EBDBB2"
    _onInverseSurface: "#282828"
    _inversePrimary: "#8CC37B"
    _shadow: "#121212"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasGruvboxDark"
    _konsoleProfile: "GruvboxDark.profile"

    _themeIcons: "Gruvbox"
    _gtkTheme: "Gruvbox-Dark-Soft"
}
