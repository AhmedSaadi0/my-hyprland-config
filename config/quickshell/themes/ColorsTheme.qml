pragma Singleton

import QtQuick
import org.kde.kirigami as Kirigami

BaseTheme {
    id: colorsTheme

    property int themeRadius: 15

    property var colors: QtObject {
        property color textBackgroundColor1: Kirigami.Theme.negativeTextColor
        property color textBackgroundColor2: Kirigami.Theme.highlightColor
        property color textFg: Kirigami.Theme.backgroundColor
    }

    // property var dimensions: QtObject {
    //     property int barHeight: 33
    //     property int barWidgetsHeight: 23
    //     property int radius: colorsTheme.themeRadius
    // }

    property var hyprConfiguration: QtObject {
        property int border_width: 2
        property string active_border: 'rgba(FDBBC4ff) rgba(ff00ffff) 0deg'
        property string inactive_border: 'rgba(59595900) 0deg'
        property string drop_shadow: 'no'
    }
}
