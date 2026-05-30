pragma Singleton

import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: deerTheme

    themeName: "DeerTheme"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("deer.jpg")
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("deer_depth.png")
    _desktopClockFont: "Xenophobia"
    _desktopClockFormat: "hh:mm AP MM/dd"
    _desktopClockPosition: Qt.point(8.015625, 8.015625)
    _desktopClockDepthEffectEnabled: true
    _desktopClockSize: Qt.size(1848.86328125, 612.8984375)
    _desktopClockSahdowEnabled: false
    _desktopClockUseThemeColor: false
    _desktopClockColor: Qt.rgba(0.05, 0.08, 0.13, 0.8)

    _primary: "#B38BFF"
    _secondary: "#E68A5C"

    _tertiary: "#8DE8FF"
    _onTertiary: "#0A1D27"

    // Error: أحمر ناعم (Salmon Pink)
    _error: "#ff8f9e"
    _onError: "#0A1D27"

    // Success: أخضر مائي ناعم (Mint Green)
    _success: "#a7e4a5"
    _onSuccess: "#0A1D27"

    // Warning: أصفر كريمي (Vanilla)
    _warning: "#fceab6"
    _onWarning: "#0A1D27"

    _onPrimary: "#120A2A"
    _onSecondary: "#1A0F0A"

    _topbarColor: "#0A1D27"
    _topbarFgColor: "#FFFFFF"
    _topbarBgColorV1: "#1E2D5A"
    _topbarBgColorV2: "#273C76"
    _topbarBgColorV3: "#273C76"
    _topbarFgColorV1: "#FFFFFF"
    _topbarFgColorV2: "#FFFFFF"
    _topbarFgColorV3: "#FFFFFF"

    // Left Menu
    _leftMenuBgColorV1: "#141E3C"
    _leftMenuBgColorV2: "#1E2D5A"
    _leftMenuBgColorV3: "#EBA58099"
    _leftMenuFgColorV1: "#FFFFFF"
    _leftMenuFgColorV2: "#FFFFFF"
    _leftMenuFgColorV3: "#18255E"

    // Subtle Text + OSD
    _subtleTextColor: "#B0B0FFB0"
    _volOsdBgColor: "#1E2D5A"
    _volOsdFgColor: "#FFFFFF"

    _plasmaColorScheme: "BlueDeer"
    _konsoleProfile: "game.profile"

    _themeIcons: "Vivid-Dark-Icons"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Kimi-dark"

    _hyprActiveBorder: "rgba(FDB4B7ff) rgba(A2E8FFff) 0deg"
}
