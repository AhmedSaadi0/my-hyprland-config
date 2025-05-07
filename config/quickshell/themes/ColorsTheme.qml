pragma Singleton

import Quickshell
import QtQuick

BaseTheme {
    id: colorsTheme

    property int themeRadius: 15

    property var colors: QtObject {
        property color textBackgroundColor1: "#F905FF"
        property color textBackgroundColor2: "#20D2FD"
        property color textFg: "#09070f"
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
