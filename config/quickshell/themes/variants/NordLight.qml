pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: lightTheme
    themeName: "NordLight"
    _themeMode: "light"

    _wallpaper: App.assets.getWallpaperPath("nord-light.gif")

    _desktopClockFont: "Daydream"
    _desktopClockFormat: "hh:mm AP"
    _desktopClockPosition: Qt.point(675, 435)
    _desktopClockDepthEffectEnabled: false
    _desktopClockSize: Qt.size(470, 188)
    _desktopClockShadowEnabled: false
    _desktopClockUseThemeColor: false
    _desktopClockColor: Qt.rgba(0.36, 0.37, 0.50, 0.6)

    _primary: "#5E81AC"           // Nord10 (أزرق نورد الغامق والواضح)
    _onPrimary: "#ECEFF4"         // Nord6
    _secondary: "#88C0D0"         // Nord8 (Frost Ice Blue)
    _onSecondary: "#2E3440"       // Nord0
    _tertiary: "#A3BE8C"          // Nord14
    _onTertiary: "#2E3440"
    _error: "#BF616A"             // Nord11
    _onError: "#ECEFF4"

    _surface: "#ECEFF4"                      // Nord6
    _onSurface: "#2E3440"                    // Nord0
    _surfaceDim: "#D8DEE9"                   // Nord4
    _surfaceBright: "#ECEFF4"
    _surfaceContainerLowest: "#FFFFFF"
    _surfaceContainerLow: "#E8ECF2"
    _surfaceContainer: "#E1E5EB"
    _surfaceContainerHigh: "#D8DEE9"
    _surfaceContainerHighest: "#C8CED8"
    _surfaceVariant: "#D8DEE9"
    _onSurfaceVariant: "#4C566A"             // Nord3

    // تحسين الحاويات لتنسجم مع بياض خلفيات نورد الناصعة بظلال خفيفة
    _primaryContainer: "#e5edf5"             // Light Frost Blue
    _onPrimaryContainer: "#5E81AC"
    _secondaryContainer: "#eaf4f7"           // Light Ice Blue
    _onSecondaryContainer: "#88C0D0"
    _tertiaryContainer: "#eef5e9"            // Light Green Tint
    _onTertiaryContainer: "#A3BE8C"
    _errorContainer: "#f5e9ea"               // Light Red Tint
    _onErrorContainer: "#BF616A"

    _outline: "#7B88A1"
    _outlineVariant: "#D8DEE9"
    _inverseSurface: "#2E3440"
    _onInverseSurface: "#ECEFF4"
    _inversePrimary: "#5E81AC"
    _shadow: "#121212"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasNordLight"
    _konsoleProfile: "NordLight.profile"

    _themeIcons: "Zafiro-Nord-Light-Blue"
    _gtkTheme: "Nordic-lighter"
}
