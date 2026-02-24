// windows/leftwindow/network/DataUsageHeader.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"
import "root:/components"
import "../base"

HeaderCard {
    id: root

    property string subtitle: qsTr("Loading data...")
    property string receivedData: "..."
    property string sentData: "..."
    property string totalData: "..."
    property string dailyReceivedData: "..."
    property string dailySentData: "..."
    property string dailyTotalData: "..."

    signal refreshRequested()

    MenuCard {
        id: dataUsage
        Layout.fillWidth: true

        cardColor: "transparent"

        title: qsTr("Data Usage")
        subtitle: root.subtitle
        icon: "󰑓"
        iconCursorShape: Qt.PointingHandCursor

        onIconClicked: {
            rotationAnim.start();
            root.refreshRequested();
        }

        RotationAnimation on rotation {
            id: rotationAnim
            target: dataUsage.iconItem
            from: 0
            to: 360
            duration: 500
            easing.type: Easing.InOutCubic
        }

        GridLayout {
            Layout.fillWidth: true

            columns: 3
            columnSpacing: 10
            rowSpacing: 8

            Item {
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Today")
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("This Month")
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 14
                Label {
                    text: "󰁅"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                }
                Label {
                    text: qsTr("Received")
                    font.bold: true
                }
            }
            Label {
                text: root.dailyReceivedData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Label {
                text: root.receivedData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 14
                Label {
                    text: "󰁝"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                }
                Label {
                    text: qsTr("Sent")
                    font.bold: true
                }
            }
            Label {
                text: root.dailySentData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Label {
                text: root.sentData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 6
                Label {
                    text: "󰯙"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                }
                Label {
                    text: qsTr("Total")
                    font.bold: true
                }
            }
            Label {
                text: root.dailyTotalData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Label {
                text: root.totalData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }
}
