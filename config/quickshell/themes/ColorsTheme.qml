pragma Singleton

import QtQuick

BaseTheme {
    id: colorsTheme

    themeName: "ColorsTheme"

    _wallpaper: "colors.png"

    _primary: "#22C1EB"
    _secondary: "#FD02FF"

    _plasmaColorScheme: "AColors"
    _themeIcons: "Vivid-Dark-Icons"
    _kvantumTheme: "Shades-of-purple"
    _gtkTheme: "Shades-of-purple"
    _konsoleProfile: "pinky.profile"

    _baseRadius: 12

    _hyprBorderWidth: 3
    _hyprActiveBorder: "rgba(EB08FBff) rgba(16D7BAff) 0deg"
    _hyprInactiveBorder: "rgba(59595900) 0deg"
    _hyprRounding: _baseRadius
    _hyprDropShadow: "no"
}
