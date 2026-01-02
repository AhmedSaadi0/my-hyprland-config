pragma Singleton

import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: colorsTheme

    themeName: "ColorsTheme"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("colors.png")

    _primary: "#22C1EB"
    _secondary: "#FD02FF"

    _tertiary: "#FAD000"
    _onTertiary: "#19002e"

    // Error: أحمر ساطع
    _error: "#ff3333"
    _onError: "#ffffff" // الأبيض هنا أفضل لأن الأحمر عادة أغمق قليلاً من الأصفر

    // Success: أخضر نيون (Electric Green)
    _success: "#00E676"
    _onSuccess: "#19002e"

    // Warning: برتقالي ساطع
    _warning: "#FF9100"
    _onWarning: "#19002e"

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
