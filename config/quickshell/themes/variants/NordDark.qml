pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: nordDark
    themeName: "NordDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("nord-dark.gif")
    _desktopClockFont: "Daydream"
    _desktopClockFormat: "hh:mm AP"
    _desktopClockPosition: Qt.point(346, 121)
    _desktopClockDepthEffectEnabled: false
    _desktopClockSize: Qt.size(818, 266)
    _desktopClockShadowEnabled: false
    _desktopClockUseThemeColor: false
    _desktopClockColor: Qt.rgba(0.22, 0.18, 0.47, 0.6)

    _primary: "#81A1C1"           // Nord9 (أزرق نورد القياسي)
    _onPrimary: "#2E3440"         // Nord0
    _secondary: "#A3BE8C"         // Nord14 (الأخضر النوردي)
    _onSecondary: "#2E3440"
    _tertiary: "#B48EAD"          // Nord15 (الأرجواني النوردي)
    _onTertiary: "#2E3440"
    _error: "#BF616A"             // Nord11 (الأحمر النوردي)
    _onError: "#ECEFF4"           // Nord6

    _surface: "#2E3440"                      // Nord0
    _onSurface: "#ECEFF4"                    // Nord6
    _surfaceDim: "#242933"                   // درجة مخصصة أغمق قليلاً من Nord0
    _surfaceBright: "#3B4252"                // Nord1
    _surfaceContainerLowest: "#20242c"
    _surfaceContainerLow: "#2E3440"
    _surfaceContainer: "#343A47"             // Nord0_medium
    _surfaceContainerHigh: "#3B4252"         // Nord1
    _surfaceContainerHighest: "#434C5E"      // Nord2
    _surfaceVariant: "#3B4252"
    _onSurfaceVariant: "#D8DEE9"             // Nord4

    // استبدال اللون الموحد 434C5E لزيادة التباين البصري الداكن والعمق
    _primaryContainer: "#3b495e"             // Dark Frost Blue
    _onPrimaryContainer: "#88C0D0"
    _secondaryContainer: "#3d4c3f"           // Dark Aurora Green
    _onSecondaryContainer: "#A3BE8C"
    _tertiaryContainer: "#463d4c"            // Dark Aurora Purple
    _onTertiaryContainer: "#B48EAD"
    _errorContainer: "#4c3b3d"               // Dark Aurora Red
    _onErrorContainer: "#BF616A"

    _outline: "#4C566A"                      // Nord3 (الحدود الافتراضية للسمة)
    _outlineVariant: "#434C5E"               // Nord2
    _inverseSurface: "#ECEFF4"
    _onInverseSurface: "#2E3440"
    _inversePrimary: "#88C0D0"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasNordDark"
    _konsoleProfile: "NordDark.profile"

    _themeIcons: "Zafiro-Nord-Black-Blue"
    _gtkTheme: "Nordic-darker-standard-buttons"
}
