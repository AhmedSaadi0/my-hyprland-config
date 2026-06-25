pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: gruvboxLight
    themeName: "GruvboxLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("gruvbox-light.png")
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("gruvbox-light-depth.png")
    _desktopClockFont: "Xenophobia"
    _desktopClockFormat: "hh mm AP - MM/dd"
    _desktopClockPosition: Qt.point(31.29, 45.73)
    _desktopClockDepthEffectEnabled: true
    _desktopClockSize: Qt.size(1829.6484375, 453.57421875)
    _desktopClockShadowEnabled: false
    _desktopClockUseThemeColor: false
    _desktopClockColor: Qt.rgba(0.80, 0.75, 0.69, 0.8)

    _primary: "#6B9E6B"
    _onPrimary: "#fbf1c7"
    _secondary: "#d79921"
    _onSecondary: "#fbf1c7"
    _tertiary: "#458588"
    _onTertiary: "#fbf1c7"
    _error: "#cc241d"
    _onError: "#fbf1c7"

    _surface: "#FBF1C7"                      // bg0_light
    _onSurface: "#3C3836"                    // fg0_light
    _surfaceDim: "#EBDBB2"                   // bg1_light
    _surfaceBright: "#FBF1C7"
    _surfaceContainerLowest: "#FFFFFF"
    _surfaceContainerLow: "#F2EBCD"
    _surfaceContainer: "#EBDBB2"
    _surfaceContainerHigh: "#D5C4A1"
    _surfaceContainerHighest: "#BDAE93"
    _surfaceVariant: "#EBDBB2"
    _onSurfaceVariant: "#7C6F64"

    // تحسين ألوان الحاويات والبطاقات للنسخة المضيئة لمنع مظهر السطح المسطح العادي
    _primaryContainer: "#e5edd5"             // Light Green Tint
    _onPrimaryContainer: "#427b58"
    _secondaryContainer: "#f5e6c4"           // Light Yellow/Gold Tint
    _onSecondaryContainer: "#b57614"
    _tertiaryContainer: "#dcf0f1"            // Light Blue/Cyan Tint
    _onTertiaryContainer: "#076678"
    _errorContainer: "#f9dedc"               // Light Red Tint
    _onErrorContainer: "#cc241d"

    _outline: "#928374"
    _outlineVariant: "#D5C4A1"
    _inverseSurface: "#3C3836"
    _onInverseSurface: "#FBF1C7"
    _inversePrimary: "#6B9E6B"
    _shadow: "#353535"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasGruvboxLight"
    _konsoleProfile: "GruvboxLight.profile"

    _themeIcons: "Gruvbox"
    _gtkTheme: "Gruvbox-Light-Soft"
}
