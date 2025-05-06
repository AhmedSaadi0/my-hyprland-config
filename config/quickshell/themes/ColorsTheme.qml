pragma Singleton

import Quickshell // Keep your imports
import QtQuick

PersistentProperties {

    property var colors: QtObject {
        property color textBackgroundColor1: "#F905FF"
        property color textBackgroundColor2: "#20D2FD"
        property color textFg: "#09070f"
    }

    property var values: QtObject {
        property int barHeight: 33
        property int barWidgetsHeight: 25
        property int radius: 15
        property string iconFont: "FantasqueSansM Nerd Font Propo"
    }
}
