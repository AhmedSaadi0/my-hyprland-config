// themes/BaseTheme.qml

import QtQuick
import Quickshell
import org.kde.kirigami as Kirigami

PersistentProperties {
    id: root

    property string themeName: "BaseTheme"

    // --- SOURCE PROPERTIES (for overriding in custom themes) ---
    // These are the actual values. Custom themes will override these.
    // The underscore is a convention to indicate these are the 'backing' properties.
    property real _alpha: 1

    // --------------------
    // ------ Colors ------
    // --------------------
    property color _primary: Kirigami.Theme.highlightColor
    property color _secondary: Kirigami.Theme.negativeTextColor
    property color _onPrimary: Kirigami.Theme.highlightedTextColor
    property color _onSecondary: Kirigami.Theme.textColor

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
    property int _barBottomMargin: 10
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
    property string _bodyFont: "JF Flat"
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
    property string _wallpaper: "gruvb_solarsys.png"
    property string _qtThemeStyle: "Breeze"
    property string _kvantumTheme: "KvGnome"
    property string _gtkTheme: "Breeze"
    property string _themeIcons: "breeze-dark"
    property string _themeMode: "dark"
    property string _plasmaColorScheme: "MaterialYouDark"
    property string _konsoleProfile: "MaterialYouAlt.profile"

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

    // --- Color Palette ---

    readonly property var colors: QtObject {
        // General
        property color primary: Qt.rgba(root._primary.r, root._primary.g, root._primary.b, root._alpha)
        property color secondary: Qt.rgba(root._secondary.r, root._secondary.g, root._secondary.b, root._alpha)
        property color onPrimary: Qt.rgba(root._onPrimary.r, root._onPrimary.g, root._onPrimary.b, root._alpha)
        // property color onPrimary: {
        //     color = Helper.getAccurteTextColor(root._primary);
        //     console.info(color);
        //     return color;
        // }
        property color onSecondary: Qt.rgba(root._onSecondary.r, root._onSecondary.g, root._onSecondary.b, root._alpha)

        // Top Bar
        property color topbarColor: Qt.rgba(root._topbarColor.r, root._topbarColor.g, root._topbarColor.b, root._alpha)

        property color topbarBgColorV1: Qt.rgba(root._topbarBgColorV1.r, root._topbarBgColorV1.g, root._topbarBgColorV1.b, root._alpha)
        property color topbarBgColorV2: Qt.rgba(root._topbarBgColorV2.r, root._topbarBgColorV2.g, root._topbarBgColorV2.b, root._alpha)
        property color topbarBgColorV3: Qt.rgba(root._topbarBgColorV3.r, root._topbarBgColorV3.g, root._topbarBgColorV3.b, root._alpha)

        property color topbarFgColorV1: Qt.rgba(root._topbarFgColorV1.r, root._topbarFgColorV1.g, root._topbarFgColorV1.b, 1)
        property color topbarFgColorV2: Qt.rgba(root._topbarFgColorV2.r, root._topbarFgColorV2.g, root._topbarFgColorV2.b, 1)
        property color topbarFgColorV3: Qt.rgba(root._topbarFgColorV3.r, root._topbarFgColorV3.g, root._topbarFgColorV3.b, 1)

        // Left Menu
        property color leftMenuBgColorV1: Qt.rgba(root._leftMenuBgColorV1.r, root._leftMenuBgColorV1.g, root._leftMenuBgColorV1.b, root._alpha)
        property color leftMenuBgColorV2: Qt.rgba(root._leftMenuBgColorV2.r, root._leftMenuBgColorV2.g, root._leftMenuBgColorV2.b, root._alpha)
        property color leftMenuBgColorV3: Qt.rgba(root._leftMenuBgColorV3.r, root._leftMenuBgColorV3.g, root._leftMenuBgColorV3.b, root._alpha)

        property color leftMenuFgColorV1: Qt.rgba(root._leftMenuFgColorV1.r, root._leftMenuFgColorV1.g, root._leftMenuFgColorV1.b, 1)
        property color leftMenuFgColorV2: Qt.rgba(root._leftMenuFgColorV2.r, root._leftMenuFgColorV2.g, root._leftMenuFgColorV2.b, 1)
        property color leftMenuFgColorV3: Qt.rgba(root._leftMenuFgColorV3.r, root._leftMenuFgColorV3.g, root._leftMenuFgColorV3.b, 1)

        property color volOsdBgColor: Qt.rgba(root._volOsdBgColor.r, root._volOsdBgColor.g, root._volOsdBgColor.b, root._alpha)
        property color volOsdFgColor: Qt.rgba(root._volOsdFgColor.r, root._volOsdFgColor.g, root._volOsdFgColor.b, 1)

        property color subtleText: Qt.rgba(root._subtleTextColor.r, root._subtleTextColor.g, root._subtleTextColor.b, root._alpha)
    }

    // --- Dimensions and Spacing ---
    readonly property var dimensions: QtObject {
        property alias baseRadius: root._baseRadius
        property alias barHeight: root._barHeight
        property alias barBottomMargin: root._barBottomMargin
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
        property alias gtkTheme: root._gtkTheme
        property alias themeIcons: root._themeIcons
        property alias themeMode: root._themeMode
        property alias plasmaColorScheme: root._plasmaColorScheme
        property alias konsoleProfile: root._konsoleProfile
        property alias fontName: root._bodyFont
    }

    // --- Hyprland Configuration ---
    readonly property var hyprlandConfiguration: QtObject {
        property alias borderWidth: root._hyprBorderWidth
        property alias activeBorder: root._hyprActiveBorder
        property alias inactiveBorder: root._hyprInactiveBorder
        property alias rounding: root._hyprRounding
        property alias dropShadow: root._hyprDropShadow
    }
}
