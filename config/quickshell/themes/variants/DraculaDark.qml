pragma Singleton

import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: draculaDark

    themeName: "DraculaDark"
    _themeMode: "dark"

    // wallpaper
    _wallpaper: App.assets.getWallpaperPath("dracula_dark.png")

    // desktopClock
    _desktopClockEnabled: true
    _desktopClockFont: "abeatbyKai"
    _desktopClockColor: "#ffffffc8"
    _desktopClockFormat: "hh:mm AP"
    _desktopClockSize: Qt.size(547.51, 120.33)
    _desktopClockPosition: Qt.point(1328.48, 40.24)
    _desktopClockSahdowEnabled: true
    _desktopClockSahdowColor: "#d1d1d1"
    _desktopClockUseThemeColor: false
    _desktopClockUseAnimation: true

    // Clock Depth Effect
    _desktopClockDepthEffectEnabled: true
    _desktopClockDepthModel: "u2net"
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("dracula_dark_depth.png")

    _baseRadius: 12
    _elementRadius: 1
    _iconFont: "FantasqueSansM Nerd Font Propo"
    _bodyFont: "JF Flat"

    _themeIcons: "Papirus"

    // Hyprland
    _hyprBorderWidth: 2
    _hyprActiveBorder: "rgba(ff79c6ff) rgba(50FA7Bff) rgba(8be9fdff) 0deg"
    _hyprInactiveBorder: "rgba(50505088)"
    _hyprRounding: 0
    _hyprDropShadow: "no"
    _hyprGapsIn: 5
    _hyprGapsOut: "12, 15, 15, 52"
    _hyprLayout: "dwindle"
    _hyprAnimationsEnabled: true
    _hyprBezier: "linear, 0, 0, 1, 1"
    _hyprAnimWindows: "1, 1, linear, slide"
    _hyprAnimWorkspaces: "1, 1, linear, fade"
    _hyprBlurEnabled: true
    _hyprBlurSize: 2
    _hyprBlurPasses: 2
    _hyprDimInactive: true
    _hyprDimStrength: 0
    _hyprShadowRange: 30
_hyprShadowColor: "#00000000"

    _primary: "#bd93f9"       // بنفسجي
    _secondary: "#8be9fd"     // أزرق سماوي

    _onPrimary: "#282a36"     // خلفية داكنة (نص فوق اللون الأساسي)
    _onSecondary: "#282a36"   // خلفية داكنة

    _tertiary: "#50fa7b"       // أخضر
    _onTertiary: "#282a36"

    // Error: الأحمر (Dracula Red)
    _error: "#ff5555"
    _onError: "#282a36"

    // Success: الأخضر (Dracula Green)
    _success: "#50fa7b"
    _onSuccess: "#282a36"

    // Warning: البرتقالي (Dracula Orange)
    _warning: "#ffb86c"
    _onWarning: "#282a36"

    // topbar
    // _topbarColor: "#282a36"
    // _topbarFgColor: "#f8f8f2"
    //
    // _topbarBgColorV1: "#44475a"
    _topbarBgColorV2: "#531353"
    _topbarBgColorV3: "#632f4e"
    // _topbarFgColorV1: "#f8f8f2"
    _topbarFgColorV2: "#f8f8f2"
    _topbarFgColorV3: "#f8f8f2"
    //
    // // Left Menu
    // _leftMenuBgColorV1: "#282a36"
    _leftMenuBgColorV2: "#292c38" // 3f1e32
    // _leftMenuBgColorV3: "#ff79c6"
    // _leftMenuFgColorV1: "#f8f8f2"
    // _leftMenuFgColorV2: "#bd93f9"
    // _leftMenuFgColorV3: "#282a36"
    //
    // _subtleTextColor: "#f8f8f2cc"  // alpha 0.8

    // OSDs
    _volOsdBgColor: "#44475a"
    _volOsdFgColor: "#f8f8f2"

    _plasmaColorScheme: "Dracula"
    _konsoleProfile: "DraculaDark.profile"

    // _themeIcons: "Zafiro-Dracula"
    _kvantumTheme: "Tellgo"
    _gtkTheme: "Dracula"
}
