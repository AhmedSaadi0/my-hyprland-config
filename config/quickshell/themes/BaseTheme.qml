// themes/BaseTheme.qml

import QtQuick
import Quickshell
import org.kde.kirigami as Kirigami

PersistentProperties {
    id: root

    // --- SOURCE PROPERTIES (for overriding in custom themes) ---
    // These are the actual values. Custom themes will override these.
    // The underscore is a convention to indicate these are the 'backing' properties.

    // Colors
    property color _textBackgroundColor1: Kirigami.Theme.negativeTextColor
    property color _textBackgroundColor2: Kirigami.Theme.highlightColor
    property color _textFg: Kirigami.Theme.backgroundColor
    property color _topbarColor: Kirigami.Theme.backgroundColor

    // Dimensions
    property int _baseRadius: 12
    property int _barHeight: 30
    property int _barWidgetsHeight: 22
    property int _menuHeight: 900
    property int _menuWidth: 380
    property int _menuWidgetsMargin: 15
    property int _elementRadius: root._baseRadius // Reference the source property

    // Typography
    property string _iconFont: "FantasqueSansM Nerd Font Propo"
    property string _bodyFont: "Sans Serif"
    property int _baseFontSize: 12
    property int _mediumFontSize: 14
    property int _smallFontSize: 12

    // Hyprland
    property int _hyprBorderWidth: 2
    property string _hyprActiveBorder: 'rgba(FDBBC4ff) rgba(ff00ffff) 0deg'
    property string _hyprInactiveBorder: 'rgba(59595900) 0deg'
    property int _hyprRounding: root._baseRadius
    property string _hyprDropShadow: 'no'

    // --- PUBLIC GROUPED API (for using the theme) ---
    // These structured objects are for clean access (e.g., theme.colors.xyz).
    // They are readonly to prevent accidental replacement.

    property string themeName: "Base Theme"

    readonly property var colors: QtObject {
        property alias textBackgroundColor1: root._textBackgroundColor1
        property alias textBackgroundColor2: root._textBackgroundColor2
        property alias textFg: root._textFg
        property alias topbarColor: root._topbarColor
    }

    readonly property var dimensions: QtObject {
        property alias baseRadius: root._baseRadius
        property alias barHeight: root._barHeight
        property alias barWidgetsHeight: root._barWidgetsHeight
        property alias menuHeight: root._menuHeight
        property alias menuWidth: root._menuWidth
        property alias menuWidgetsMargin: root._menuWidgetsMargin
        property alias elementRadius: root._elementRadius
    }

    readonly property var typography: QtObject {
        property alias iconFont: root._iconFont
        property alias bodyFont: root._bodyFont
        property alias baseFontSize: root._baseFontSize
        property alias medium: root._mediumFontSize
        property alias small: root._smallFontSize
    }

    // Note: You can skip this pattern for SystemSettings and Hyprland if you
    // prefer to replace the whole object, but for consistency, it's better this way.
    readonly property var hyprConfiguration: QtObject {
        property alias border_width: root._hyprBorderWidth
        property alias active_border: root._hyprActiveBorder
        property alias inactive_border: root._hyprInactiveBorder
        property alias rounding: root._hyprRounding
        property alias drop_shadow: root._hyprDropShadow
    }

    // System settings often don't need overriding this granularly, so
    // keeping it as a single 'var' property might be fine if you always
    // define the whole block. But for completeness, here it is aliased:
    // ...
}
