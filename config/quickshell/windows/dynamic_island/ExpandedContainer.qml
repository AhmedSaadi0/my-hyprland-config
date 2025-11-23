import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls

import "root:/themes"
import "root:/components"
import "./widgets"

Item {
    id: root

    property string currentTab: "weather"
    property int playersCount: 0

    signal tabChanged(string newTab)
    signal closeRequested
    signal switchPlayerRequested

    implicitHeight: mainLayout.implicitHeight + 20

    MButton {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.rightMargin: 15

        text: "✕"
        font.pixelSize: 12

        implicitWidth: 24
        implicitHeight: 24

        normalBackground: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)

        normalForeground: ThemeManager.selectedTheme.colors.onPrimary

        onClicked: root.closeRequested()

        z: 10
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.topMargin: 15
        anchors.bottomMargin: 5
        spacing: 10

        IslandSwitcher {
            Layout.alignment: Qt.AlignHCenter
            currentTab: root.currentTab
            onTabClicked: tab => root.tabChanged(tab)
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: root.currentTab === "weather" ? weatherWidget.implicitHeight : mediaWidget.implicitHeight

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                }
            }

            WeatherWidget {
                id: weatherWidget
                width: parent.width
                height: implicitHeight
                opacity: root.currentTab === "weather" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
                transform: Translate {
                    x: root.currentTab === "weather" ? 0 : -50
                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            MediaWidget {
                id: mediaWidget
                width: parent.width
                height: implicitHeight

                availablePlayersCount: root.playersCount
                // -------------------------------

                opacity: root.currentTab === "media" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                transform: Translate {
                    x: root.currentTab === "media" ? 0 : 50
                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                onSwitchPlayerClicked: root.switchPlayerRequested()
            }
        }
    }
}
