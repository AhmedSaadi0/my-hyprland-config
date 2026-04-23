pragma Singleton

import QtQuick
import org.kde.kirigami as Kirigami

import "root:/themes"
import "root:/config"

BaseTheme {
    id: root
    themeName: "M3Dark"

    _enableDynamicColoring: true
    _enableDynamicWallpapers: false
    // _dynamicWallpapersPath: "/home/ahmed/wallpapers/dark"
    _wallpaper: App.assets.getWallpaperPath("m3_dark.png")
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("m3_dark_depth.png")
    _desktopClockFont: "Unrealised"
    _desktopClockFormat: "hh:mm AP - MM/dd"
    _desktopClockPosition: Qt.point(3.0234375, 8.60546875)
    _desktopClockDepthEffectEnabled: true
    _desktopClockSize: Qt.size(1859.52734375, 498.1171875)
    _desktopClockSahdowEnabled: false
    _desktopClockUseThemeColor: false
    _desktopClockColor: Qt.rgba(0.79, 0.97, 0.77, 0.8)

    _themeMode: "dark"
    _baseRadius: 14
    _hyprBorderWidth: 3
    // _dynamicWallpapersInterval: 1000 * 10

    // _wallpaper: "dark.png"

    _primary: Kirigami.Theme.highlightColor
    _onPrimary: Kirigami.Theme.highlightedTextColor

    _secondary: Kirigami.Theme.linkColor
    _onSecondary: Kirigami.Theme.highlightedTextColor

    _tertiary: Kirigami.Theme.buttonBackgroundColor
    _onTertiary: Kirigami.Theme.buttonTextColor

    _error: Kirigami.Theme.negativeTextColor
    _onError: Kirigami.Theme.highlightedTextColor

    _success: Kirigami.Theme.positiveTextColor
    _onSuccess: Kirigami.Theme.highlightedTextColor

    _warning: Kirigami.Theme.neutralTextColor
    _onWarning: Kirigami.Theme.highlightedTextColor

    // _primary: "#DCB5F3"
    // _secondary: "#F7B28A"

    _plasmaColorScheme: "MaterialYouDark"
    _konsoleProfile: "MaterialYouAlt.profile"

    _themeIcons: "Tela-dark"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Breeze-Dark"

    _hyprActiveBorder: "rgba(678382ff) rgba(9d6c73ff) 0deg"
}
