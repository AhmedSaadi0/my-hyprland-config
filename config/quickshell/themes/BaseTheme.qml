// themes/BaseTheme.qmlbasethe

import QtQuick
import Quickshell
import org.kde.kirigami as Kirigami

PersistentProperties {
    id: root

    // --- SOURCE PROPERTIES (for overriding in custom themes) ---
    // These are the actual values. Custom themes will override these.
    // The underscore is a convention to indicate these are the 'backing' properties.

    // --------------------
    // ------ Colors ------
    // --------------------
    property color _primary: Kirigami.Theme.negativeTextColor
    property color _secondary: Kirigami.Theme.highlightColor
    property color _onPrimary: Kirigami.Theme.backgroundColor
    property color _onSecondary: Kirigami.Theme.backgroundColor

    // topbar
    property color _topbarColor: Kirigami.Theme.backgroundColor

    property color _topbarBgColorV1: Kirigami.Theme.backgroundColor.lighter(1.5)
    property color _topbarBgColorV2: Kirigami.Theme.negativeBackgroundColor
    property color _topbarBgColorV3: Kirigami.Theme.neutralBackgroundColor
    property color _topbarFgColorV1: Kirigami.Theme.textColor
    property color _topbarFgColorV2: Kirigami.Theme.textColor
    property color _topbarFgColorV3: Kirigami.Theme.textColor

    // Left Menu
    property color _leftMenuBgColorV1: Kirigami.Theme.backgroundColor
    property color _leftMenuBgColorV2: Kirigami.Theme.negativeBackgroundColor
    property color _leftMenuBgColorV3: Kirigami.Theme.highlightColor
    property color _leftMenuFgColorV1: Kirigami.Theme.textColor
    property color _leftMenuFgColorV2: Kirigami.Theme.neutralTextColor
    property color _leftMenuFgColorV3: Kirigami.Theme.highlightedTextColor

    property color _subtleTextColor: Kirigami.Theme.textColor.alpha(0.8)

    // OSDs
    property color _volOsdBgColor: Kirigami.Theme.backgroundColor.lighter(1.5)
    property color _volOsdFgColor: Kirigami.Theme.textColor
    // --------------------
    // ---- Dimensions ----
    // --------------------
    property int _baseRadius: 12
    property int _barHeight: 30
    property int _barWidgetsHeight: 22
    property int _menuHeight: 900
    property int _menuWidth: 380
    property int _menuWidgetsMargin: 15
    property int _elementRadius: root._baseRadius // Reference the source property

    property int _spacingSmall: 4
    property int _spacingMedium: 6
    property int _spacingLarge: 8

    // --------------------
    // ---- Typography ----
    // --------------------
    property string _iconFont: "FantasqueSansM Nerd Font Propo"
    property string _bodyFont: "Sans Serif"
    property int _baseFontSize: 12
    property int _heading1Size: 22
    property int _heading2Size: 20
    property int _heading3Size: 18
    property int _heading4Size: 16
    property int _mediumFontSize: 14
    property int _smallFontSize: 12

    // ------------------------
    // -- System Integration --
    // ------------------------
    property string _wallpaper: "colors.png"
    property string _qtThemeStyle: "Fusion"
    property string _kvantumTheme: "KvGnome"
    property string _gtk3Theme: "Breeze"
    property string _themeIcons: "breeze-dark"
    property string _themeMode: "dark"

    // --------------------
    // ----- Hyprland -----
    // --------------------
    property int _hyprBorderWidth: 2
    property string _hyprActiveBorder: 'rgba(FDBBC4ff) rgba(ff00ffff) 0deg'
    property string _hyprInactiveBorder: 'rgba(59595900) 0deg'
    property int _hyprRounding: root._baseRadius
    property string _hyprDropShadow: 'no'

    // ======================================================================
    // --- PUBLIC GROUPED API (for using the theme) ---
    // These structured objects are for clean access (e.g., theme.colors.xyz).
    // They are readonly to prevent accidental replacement.
    // ======================================================================

    property string themeName: "Base Theme"

    // --- Color Palette ---
    readonly property var colors: QtObject {
        // General
        property alias primary: root._primary
        property alias secondary: root._secondary
        property alias onPrimary: root._onPrimary
        property alias onSecondary: root._onSecondary

        // Top Bar
        property alias topbarColor: root._topbarColor

        property alias topbarBgColorV1: root._topbarBgColorV1
        property alias topbarBgColorV2: root._topbarBgColorV2
        property alias topbarBgColorV3: root._topbarBgColorV3
        property alias topbarFgColorV1: root._topbarFgColorV1
        property alias topbarFgColorV2: root._topbarFgColorV2
        property alias topbarFgColorV3: root._topbarFgColorV3

        // Left Menu
        property alias leftMenuBgColorV1: root._leftMenuBgColorV1
        property alias leftMenuBgColorV2: root._leftMenuBgColorV2
        property alias leftMenuBgColorV3: root._leftMenuBgColorV3
        property alias leftMenuFgColorV1: root._leftMenuFgColorV1
        property alias leftMenuFgColorV2: root._leftMenuFgColorV2
        property alias leftMenuFgColorV3: root._leftMenuFgColorV3

        property alias volOsdBgColor: root._volOsdBgColor
        property alias volOsdFgColor: root._volOsdFgColor

        property alias subtleText: root._subtleTextColor
    }

    // --- Dimensions and Spacing ---
    readonly property var dimensions: QtObject {
        property alias baseRadius: root._baseRadius
        property alias barHeight: root._barHeight
        property alias barWidgetsHeight: root._barWidgetsHeight
        property alias menuHeight: root._menuHeight
        property alias menuWidth: root._menuWidth
        property alias menuWidgetsMargin: root._menuWidgetsMargin
        property alias elementRadius: root._elementRadius

        property alias spacingSmall: root._spacingSmall
        property alias spacingMedium: root._spacingMedium
        property alias spacingLarge: root._spacingLarge
    }

    // --- Typography ---
    readonly property var typography: QtObject {
        property alias iconFont: root._iconFont
        property alias bodyFont: root._bodyFont
        property alias heading1Size: root._heading1Size
        property alias heading2Size: root._heading2Size
        property alias heading3Size: root._heading3Size
        property alias heading4Size: root._heading4Size
        property alias baseFontSize: root._baseFontSize
        property alias medium: root._mediumFontSize
        property alias small: root._smallFontSize

        property alias spacingSmall: root._spacingSmall
        property alias spacingMedium: root._spacingMedium
        property alias spacingLarge: root._spacingLarge
    }

    // --- System Integration Settings ---
    readonly property var systemSettings: QtObject {
        property alias wallpaper: root._wallpaper
        property alias qtThemeStyle: root._qtThemeStyle
        property alias kvantumTheme: root._kvantumTheme
        property alias gtk3Theme: root._gtk3Theme
        property alias themeIcons: root._themeIcons
        property alias themeMode: root._themeMode
    }

    // --- Hyprland Configuration ---
    readonly property var hyprConfiguration: QtObject {
        property alias border_width: root._hyprBorderWidth
        property alias active_border: root._hyprActiveBorder
        property alias inactive_border: root._hyprInactiveBorder
        property alias rounding: root._hyprRounding
        property alias drop_shadow: root._hyprDropShadow
    }
}
