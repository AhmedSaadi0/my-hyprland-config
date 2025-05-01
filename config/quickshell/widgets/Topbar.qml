// File: panels/topbar.qml

import Quickshell
import Quickshell.Io
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
        width: 190
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

        Text {
            id: clock // الـ ids الداخلية لا بأس بها
            anchors.centerIn: parent
            color: colorsTheme.textFg

            Process {
                command: ["date", "+(%I:%M) %A, %d %B"]
                running: true
                stdout: SplitParser {
                    onRead: data => clock.text = data
                }
            }
        }
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
