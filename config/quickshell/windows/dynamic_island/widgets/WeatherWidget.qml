import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls

import "root:/themes"

import "root:/services"

Item {
    id: root

    implicitHeight: 180

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.45
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            RowLayout {
                spacing: 10

                Text {
                    text: Weather.weatherIcon
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 40
                    color: ThemeManager.selectedTheme.colors.onPrimary
                }

                Text {

                    text: Weather.currentTemp + "°"
                    font.bold: true
                    font.pixelSize: 38
                    color: ThemeManager.selectedTheme.colors.onPrimary
                }
            }

            Text {
                text: Weather.weatherDescription
                font.pixelSize: 14
                font.bold: true
                color: ThemeManager.selectedTheme.colors.onPrimary
                opacity: 0.9
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: Weather.areaName
                font.pixelSize: 12
                color: ThemeManager.selectedTheme.colors.onPrimary
                opacity: 0.7
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            width: 1
            color: ThemeManager.selectedTheme.colors.onPrimary
            opacity: 0.2
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Repeater {

                model: Weather.dailyForecast ? Weather.dailyForecast.slice(0, 3) : []

                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {

                        text: modelData.dayName ? modelData.dayName.substring(0, 3).toUpperCase() : ""
                        font.pixelSize: 11
                        font.bold: true
                        color: ThemeManager.selectedTheme.colors.onPrimary
                        opacity: 0.6
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: modelData.icon
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 20
                        color: ThemeManager.selectedTheme.colors.onPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: modelData.maxTemp + "°"
                        font.pixelSize: 13
                        font.bold: true
                        color: ThemeManager.selectedTheme.colors.onPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        visible: Weather.isLoading && (!Weather.currentTemp || Weather.currentTemp === 0)

        Text {
            anchors.centerIn: parent
            text: "Loading..."
            color: ThemeManager.selectedTheme.colors.onPrimary
        }
    }
}
