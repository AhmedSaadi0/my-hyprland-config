pragma Singleton
import QtQuick
import "root:/config"

BaseTheme {
    id: lightTheme
    themeName: "GruvboxLight"

    _wallpaper: App.assets.getWallpaperPath("gruvbox-light.png")

    _primary: "#6B9E6B"
    _secondary: "#d79921"
    _onPrimary: "#fbf1c7"
    _onSecondary: "#fbf1c7"

    _topbarColor: "#ebdbb2"  // light1
    _topbarFgColor: "#3c3836" // fg
    _topbarBgColorV1: "#d5c4a1" // light2
    _topbarBgColorV2: "#bdae93" // light3
    _topbarBgColorV3: "#d65d0e" // orange
    _topbarFgColorV1: "#282828" // fg0
    _topbarFgColorV2: "#282828" // fg0
    _topbarFgColorV3: "#fbf1c7" // light0

    _leftMenuBgColorV1: "#fbf1c7" // light0
    _leftMenuBgColorV2: "#ebdbb2" // light1
    _leftMenuBgColorV3: "#689d6a" // aqua
    _leftMenuFgColorV1: "#3c3836" // fg
    _leftMenuFgColorV2: "#3c3836" // fg
    _leftMenuFgColorV3: "#fbf1c7" // light0

    _subtleTextColor: "#7c6f64cc" // gray with transparency
    _volOsdBgColor: "#d5c4a1"     // light2
    _volOsdFgColor: "#282828"     // fg0

    _hyprActiveBorder: "rgba(6B9E6Bff) rgba(d79921ff) 0deg"

    _plasmaColorScheme: "NibrasGruvboxLight"
    _konsoleProfile: "GruvboxLight.profile"

    _themeIcons: "Gruvbox"

    _gtkTheme: "Nordic-lighter"
}
