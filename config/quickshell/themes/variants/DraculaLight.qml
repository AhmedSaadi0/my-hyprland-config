pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: draculaLight

    themeName: "DraculaLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("linux.png")

    _primary: "#bd93f9"           // Purple (تصحيح درجة البنفسجي لتلائم دراكولا الرسمي)
    _onPrimary: "#f8f8f2"
    _secondary: "#ff79c6"         // Pink
    _onSecondary: "#f8f8f2"
    _tertiary: "#8be9fd"          // Cyan
    _onTertiary: "#282a36"
    _error: "#ff5555"
    _onError: "#f8f8f2"

    _surface: "#F8F8F2"
    _onSurface: "#44475A"
    _surfaceDim: "#E6E6E0"
    _surfaceBright: "#FFFFFF"
    _surfaceContainerLowest: "#FFFFFF"
    _surfaceContainerLow: "#F2F2EC"
    _surfaceContainer: "#E6E6E0"
    _surfaceContainerHigh: "#D9D9D3"
    _surfaceContainerHighest: "#CCCCc6"
    _surfaceVariant: "#E6E6E0"
    _onSurfaceVariant: "#6272A4"

    // تحسين حاويات النسخة المضيئة لإعطاء عمق أنيق
    _primaryContainer: "#e8daff"             // Light Purple Container
    _onPrimaryContainer: "#7247b5"
    _secondaryContainer: "#ffe5f4"           // Light Pink Container
    _onSecondaryContainer: "#b3337e"
    _tertiaryContainer: "#e0fbff"            // Light Cyan Container
    _onTertiaryContainer: "#007a8c"
    _errorContainer: "#ffe5e5"               // Light Red Container
    _onErrorContainer: "#ff5555"

    _outline: "#999999"
    _outlineVariant: "#CCCCc6"
    _inverseSurface: "#44475A"
    _onInverseSurface: "#F8F8F2"
    _inversePrimary: "#BD93F9"
    _shadow: "#121212"
    _scrim: "#000000"

    _baseRadius: 1
    _elementRadius: 1

    _shapeNone: 0
    _shapeExtraSmall: 1
    _shapeSmall: 1
    _shapeMedium: 1
    _shapeLarge: 1
    _shapeExtraLarge: 1
    _shapeFull: 1

    _iconButtonRadius: 1
    _statCardRadius: 1

    _plasmaColorScheme: "DraculaLight"
    _konsoleProfile: "DraculaLight.profile"

    _themeIcons: "Colloid-Purple-Dracula-Dark"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Tokyonight-Dark-BL"
}
