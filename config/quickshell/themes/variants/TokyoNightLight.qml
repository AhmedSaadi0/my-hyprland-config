pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: lightTheme
    themeName: "TokyoNightLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("tokyonight-light.png")

    _primary: "#2e7de9"           // Light Blue
    _onPrimary: "#e9e9ec"         // Light Base
    _secondary: "#7847bd"         // Light Purple
    _onSecondary: "#e9e9ec"
    _tertiary: "#007197"           // Light Cyan
    _onTertiary: "#e9e9ec"
    _error: "#f52a65"             // Light Red
    _onError: "#e9e9ec"

    _surface: "#E9E9EC"                      // bg
    _onSurface: "#3760BF"                    // fg
    _surfaceDim: "#D5D6DB"                   // bg_dark
    _surfaceBright: "#E9E9EC"
    _surfaceContainerLowest: "#FFFFFF"
    _surfaceContainerLow: "#E6E6E9"
    _surfaceContainer: "#DEDEE1"
    _surfaceContainerHigh: "#D5D6DB"
    _surfaceContainerHighest: "#BCC0CC"
    _surfaceVariant: "#D5D6DB"
    _onSurfaceVariant: "#6172B0"             // fg_gutter

    // استبدال اللون الموحد D5D6DB بتدرجات تحديد لطيفة وباهتة تلائم طوكيو نايت المضيء
    _primaryContainer: "#cfe0f9"             // Light Blue Selection
    _onPrimaryContainer: "#2e7de9"
    _secondaryContainer: "#e5dbf5"           // Light Purple Selection
    _onSecondaryContainer: "#7847bd"
    _tertiaryContainer: "#d6eef5"            // Light Cyan Selection
    _onTertiaryContainer: "#007197"
    _errorContainer: "#fddde6"               // Light Red Selection
    _onErrorContainer: "#f52a65"

    _outline: "#8990B3"
    _outlineVariant: "#D5D6DB"
    _inverseSurface: "#3760BF"
    _onInverseSurface: "#E9E9EC"
    _inversePrimary: "#2E7DE9"
    _shadow: "#565278"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasTokyoNightLight"
    _konsoleProfile: "NibrasTokyoNightLight.profile"

    _themeIcons: "Tela-light"
    _gtkTheme: "Tokyonight-Light"
}
