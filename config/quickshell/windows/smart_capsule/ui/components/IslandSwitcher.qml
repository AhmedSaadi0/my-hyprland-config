import QtQuick
import QtQuick.Layouts
import "root:/themes"

Item {
    id: root

    property string currentTab: "weather"
    property color fgColor: ThemeManager.selectedTheme.colors.onPrimary

    signal tabClicked(string tab)

    implicitWidth: 122
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)

        Rectangle {
            id: indicator
            width: (parent.width - 4) / 2
            height: parent.height - 4
            y: 2
            x: root.currentTab === "weather" ? 2 : ((parent.width / 2) - 2) + 2

            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.2)

            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            MouseArea {
                anchors.fill: parent
                onClicked: root.tabClicked("weather")
                cursorShape: Qt.PointingHandCursor
            }
            Text {
                anchors.centerIn: parent
                text: "☁"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 16
                color: root.fgColor
                opacity: root.currentTab === "weather" ? 1.0 : 0.5
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            MouseArea {
                anchors.fill: parent
                onClicked: root.tabClicked("media")
                cursorShape: Qt.PointingHandCursor
            }
            Text {
                anchors.centerIn: parent
                text: "󰝚"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 16
                color: root.fgColor
                opacity: root.currentTab === "media" ? 1.0 : 0.5
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }
    }
}
