pragma Singleton

import QtQuick

BaseTheme {
    id: colorsTheme

    themeName: "HarmonyTheme"

    _wallpaper: "ign_wanderlust.jpg"

    _primary: "#BE626B"
    _secondary: "#6AA6A5"

    _plasmaColorScheme: "Nordic"
    _themeIcons: "Windows11-red-dark"
    _kvantumTheme: "Sweet-Mars"
    _gtkTheme: "Nordic-darker-standard-buttons"
    _konsoleProfile: "harmony.profile"

    _baseRadius: 12

    _hyprBorderWidth: 3
    _hyprActiveBorder: "rgba(BF616Bff) rgba(BF616Bff) 0deg"
    _hyprInactiveBorder: "rgba(2E3440ff) 0deg"
    _hyprRounding: _baseRadius
    _hyprDropShadow: "no"
}
