import Quickshell.Hyprland
import Quickshell
import QtQuick

import "../themes"

PanelWindow {

    ColorsTheme {
        id: colorsTheme
    }

    reloadableId: "persistedStates"

    anchors {
        top: true
        left: true
        right: true
    }

    height: 30 // يمكن أن تكون هذه أيضًا خاصية من خصائص الثيم

    Rectangle {
        anchors.fill: parent
        color: palette.window // palette متاح
        z: -1
    }

    Rectangle {
        id: clockBackground // الـ ids الداخلية لا بأس بها
        anchors.centerIn: parent
        radius: 15
        width: clockText.width + 20
        height: 22

        // الربط بـ ThemeManager (سيكون متاحًا في النطاق الذي يتم فيه تحميل هذا المكون)
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
            text: clock.date.toLocaleString(Qt.locale(), "(hh:mm:ss) dddd, dd MMMM")
            anchors.centerIn: parent
            color: colorsTheme.textFg
        }
    }

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
