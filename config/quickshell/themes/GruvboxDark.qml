pragma Singleton
import QtQuick
import "root:/config"

BaseTheme {
    id: lightTheme
    themeName: "GruvboxDark"

    _wallpaper: App.assets.getWallpaperPath("gruvbox-dark.png")

    _primary: "#8CC37B"
    _secondary: "#fabd2f"
    _onPrimary: "#282828"
    _onSecondary: "#282828"

    _topbarColor: "#3c3836"  // bg1
    _topbarFgColor: "#ebdbb2" // fg
    _topbarBgColorV1: "#504945" // bg2
    _topbarBgColorV2: "#665c54" // bg3
    _topbarBgColorV3: "#fe8019" // orange
    _topbarFgColorV1: "#fbf1c7" // fg0
    _topbarFgColorV2: "#fbf1c7" // fg0
    _topbarFgColorV3: "#282828" // bg

    _leftMenuBgColorV1: "#282828" // bg
    _leftMenuBgColorV2: "#3c3836" // bg1
    _leftMenuBgColorV3: "#8ec07c" // aqua
    _leftMenuFgColorV1: "#ebdbb2" // fg
    _leftMenuFgColorV2: "#ebdbb2" // fg
    _leftMenuFgColorV3: "#282828" // bg

    _subtleTextColor: "#a89984cc" // gray with transparency
    _volOsdBgColor: "#504945"     // bg2
    _volOsdFgColor: "#fbf1c7"     // fg0

    _hyprActiveBorder: "rgba(8CC37Bff) rgba(fabd2fff) 0deg"

    _plasmaColorScheme: "NibrasGruvboxDark"
    _konsoleProfile: "GruvboxDark.profile"

    _themeIcons: "Gruvbox"

    _gtkTheme: "Nordic-lighter"
}
