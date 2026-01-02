pragma Singleton

import org.kde.kirigami as Kirigami
import QtQuick

import "root:/themes"

BaseTheme {
    id: root
    themeName: "M3Light"

    _enableDynamicColoring: true
    _enableDynamicWallpapers: true
    _dynamicWallpapersPath: "/home/ahmed/wallpapers/light"

    _themeMode: "light"

    _baseRadius: 14
    _hyprBorderWidth: 3

    _wallpaper: "light.png"

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

    _plasmaColorScheme: "MaterialYouLight"
    _konsoleProfile: "MaterialYouAlt.profile"

    _themeIcons: "Tela-light"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Breeze-Light"

    _hyprActiveBorder: "rgba(678382ff) rgba(9d6c73ff) 0deg"
}
