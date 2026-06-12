pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: catppuccindarkTheme

    themeName: "CatppuccinDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("CatppuccinDark.png")

    _primary: "#89B4FA"           // Blue
    _onPrimary: "#11111B"         // Crust
    _secondary: "#F38BA8"         // Pink
    _onSecondary: "#11111B"
    _tertiary: "#cba6f7"          // Mauve
    _onTertiary: "#11111B"
    _error: "#f38ba8"             // Red
    _onError: "#11111B"

    _surface: "#1E1E2E"                      // Base
    _onSurface: "#CDD6F4"                    // Text
    _surfaceDim: "#181825"                   // Mantle
    _surfaceBright: "#313244"                // Surface0
    _surfaceContainerLowest: "#11111B"       // Crust
    _surfaceContainerLow: "#151522"          // Mantle-Base Intermediate
    _surfaceContainer: "#1E1E2E"             // Base
    _surfaceContainerHigh: "#252538"         // Base-Surface0 Intermediate
    _surfaceContainerHighest: "#313244"      // Surface0
    _surfaceVariant: "#313244"
    _onSurfaceVariant: "#BAC2DE"             // Subtext1

    // ضبط حاويات التحديد وخلفيات الأزرار بتدرج ناعم ومتناسق
    _primaryContainer: "#25304B"             // Dark Sapphire/Blue container
    _onPrimaryContainer: "#89B4FA"
    _secondaryContainer: "#452435"           // Dark Pink container
    _onSecondaryContainer: "#F38BA8"
    _tertiaryContainer: "#3a254e"            // Dark Mauve container
    _onTertiaryContainer: "#cba6f7"
    _errorContainer: "#45242c"               // Dark Red container
    _onErrorContainer: "#f38ba8"

    _outline: "#585B70"                      // Surface2 (الحدود الافتراضية للسمة)
    _outlineVariant: "#45475A"               // Surface1 (حدود فرعية أقل وضوحاً)
    _inverseSurface: "#CDD6F4"
    _onInverseSurface: "#1E1E2E"
    _inversePrimary: "#89B4FA"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasCatppuccinDark"
    _konsoleProfile: "CatppuccinDark.profile"

    _themeIcons: "Vivid-Dark-Icons"
    _gtkTheme: "Catppuccin-Mocha-Standard-Blue-Dark"
}
