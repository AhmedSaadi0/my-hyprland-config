import Quickshell
import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
// import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import "../themes"
import "./topbar"
import "./topbar/monitors"

PanelWindow {
    id: topBar
    reloadableId: "persistedStates"

    height: ColorsTheme.values.barHeight

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
        height: ColorsTheme.values.barWidgetsHeight
        width: clockText.width + 20
        anchors.centerIn: parent
        radius: ColorsTheme.values.radius
        color: palette.window

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: ColorsTheme.colors.textBackgroundColor1
            }
            GradientStop {
                position: 1.0
                color: ColorsTheme.colors.textBackgroundColor2
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
            color: ColorsTheme.colors.textFg
        }
    }

    Workspaces {
        id: workspaces
        height: ColorsTheme.values.barWidgetsHeight
        // width: children[0].width
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 2
        }
    }

    RowLayout {
        height: ColorsTheme.values.barHeight
        spacing: 10

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            margins: 2
        }

        NetworkSpeedIndicator {
            id: internetIndicator
        }

        Item {
            clip: true
            height: ColorsTheme.values.barWidgetsHeight + 10
            width: 140

            Rectangle {
                id: progressBackground
                width: 120
                height: ColorsTheme.values.barWidgetsHeight
                radius: ColorsTheme.values.radius
                color: Kirigami.Theme.alternateBackgroundColor
                // color: palette.light
                // color: palette.mid
                anchors {
                    centerIn: parent
                }

                layer.enabled: true // Required for effects to render

                layer.effect: DropShadow {
                    color: palette.shadow.alpha(0.2)
                    radius: 8
                    spread: 0
                    samples: 9
                    verticalOffset: 0 // Matches CSS vertical offset (1px)
                    // horizontalOffset: 4 // Matches CSS horizontal offset (1px)
                    // sourceRect: parent.parent.sourceRect // Optional: control shadow bounds
                }
            }

            RowLayout {
                // anchors.fill: parent
                // width: 120
                spacing: 1
                anchors {
                    fill: progressBackground
                    horizontalCenter: progressBackground.horizontalCenter
                    verticalCenter: progressBackground.verticalCenter
                }
                Item {
                    width: 4
                } // Space
                Cpu {}
                Ram {}
                Battery {}
                Tempreture {}
            }
        }
    }
}
