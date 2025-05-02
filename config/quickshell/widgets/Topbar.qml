import Quickshell
import QtQuick
// import QtQuick.Effects
// import Qt5Compat.GraphicalEffects

import "../themes"

PanelWindow {
    id: topBar
    reloadableId: "persistedStates"
    height: 30

    ColorsTheme {
        id: colorsTheme
    }

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: palette.window
        z: -1
    }

    Rectangle {
        id: clockBackground
        anchors.centerIn: parent
        radius: 15
        width: clockText.width + 20
        height: 22
        color: palette.window

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: colorsTheme.textBackgroundColor1
            }
            GradientStop {
                position: 1.0
                color: colorsTheme.textBackgroundColor2
            }
        }

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }

        Text {
            id: clockText
            text: clock.date.toLocaleString(Qt.locale(), "hh:mm:ss AP - dddd, dd MMMM yyyy")
            anchors.centerIn: parent
            color: colorsTheme.textFg
        }
    }

    // DropShadow {
    //     anchors.fill: clockBackground
    //     horizontalOffset: 3
    //     verticalOffset: 3
    //     radius: 8.0
    //     // samples: 17
    //     color: "#10000000"
    //     source: clockBackground
    // }

    Workspaces {
        id: workspaces
        width: children[0].width
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 2
        }
        height: parent.height - 8
    }

    MouseArea {
        anchors.fill: parent
        onClicked:
        // if (ThemeManager.currentThemeName === "dark") {
        //     ThemeManager.setTheme("light");
        // } else {
        //     ThemeManager.setTheme("dark");
        // }
        {}
    }
}
