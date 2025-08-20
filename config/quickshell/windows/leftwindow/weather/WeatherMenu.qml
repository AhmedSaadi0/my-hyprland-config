// ModernWeather.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "root:/themes"
import "root:/services"

Item {
    id: weatherRoot
    // width: 380
    // height: parent ? parent.height : 700

    // Static weather data (placeholder)
    property string cityName: Weather.areaName
    property string currentTemp: Weather.currentTemp
    property string weatherCondition: Weather.weatherDescription
    property string weatherIcon: Weather.weatherIcon
    property string highTemp: Weather.dailyForecast[0].maxTemp
    property string lowTemp: Weather.dailyForecast[0].minTemp
    property string humidity: Weather.humidity
    property string windSpeed: Weather.windSpeed
    property string windDirection: Weather.windDirection
    property string pressure: Weather.pressure
    property string feelsLike: Weather.feelsLike
    property string visibility: Weather.visibility
    property string sunrise: Weather.sunrise
    property string sunset: Weather.sunset
    property string uvIndex: Weather.uvIndex
    property string lastUpdate: Weather.lastUpdated

    // Design colors
    property color primaryColor: ThemeManager.selectedTheme.colors.primary
    property color secondaryColor: ThemeManager.selectedTheme.colors.secondary
    property color accentColor: "#F6D5F7"
    property color textColor: ThemeManager.selectedTheme.colors.subtleTextColor
    property color cardColor: ThemeManager.selectedTheme.colors.topbarColor
    property color cardTextColor: ThemeManager.selectedTheme.colors.topbarFgColor

    property var radius: ThemeManager.selectedTheme.dimensions.elementRadius

    Rectangle {
        anchors.fill: parent
        radius: weatherRoot.radius

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: primaryColor
            }
            GradientStop {
                position: 1.0
                color: secondaryColor
            }
        }

        // Background effects
        Rectangle {
            width: 300
            height: 300
            radius: 150
            color: accentColor
            opacity: 0.25
            x: -100
            y: -100
        }

        Rectangle {
            width: 200
            height: 200
            radius: 100
            color: accentColor
            opacity: 0.1
            x: parent.width - 150
            y: parent.height - 150
        }

        Flickable {
            anchors.fill: parent
            contentHeight: mainLayout.height + 40
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: mainLayout
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                spacing: 15

                // Card Header - Update Info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "Last Update: " + lastUpdate
                        font.pixelSize: 14
                        color: textColor
                        opacity: 0.8
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        id: refreshButton
                        implicitHeight: 36
                        implicitWidth: 80 // Increased width for "Refresh"
                        text: "Refresh"
                        font.pixelSize: 14
                        background: Rectangle {
                            color: "transparent"
                            border.color: textColor
                            border.width: 1
                            radius: 18
                        }
                        contentItem: Text {
                            text: refreshButton.text
                            font: refreshButton.font
                            color: textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Rotation effect on click
                            rotateAnim.start();
                            // Update logic will be added here later
                        }

                        RotationAnimation on rotation {
                            id: rotateAnim
                            from: 0
                            to: 360
                            duration: 500
                            running: false
                        }
                    }
                }

                // Main Weather Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 190 // New height
                    color: cardColor
                    radius: weatherRoot.radius
                    clip: true // Necessary to prevent the icon from going out

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 8
                        samples: 16
                        color: "#40000000"
                    }

                    // -- Background Icon --
                    Text {
                        text: weatherIcon
                        font.pixelSize: 150 // Very large size
                        color: cardTextColor
                        opacity: 0.08 // Very high transparency
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.top: parent.top
                        anchors.topMargin: -30
                    }

                    // --- Main Content Container ---
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 5

                        // --- 1. City Name and Weather Description ---
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: cityName
                                font.pixelSize: 22
                                font.bold: true
                                color: cardTextColor
                            }

                            Item {
                                Layout.fillWidth: true
                            } // Separator

                            Text {
                                text: weatherCondition
                                font.pixelSize: 16
                                color: cardTextColor
                                opacity: 0.8
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        // --- Visual Separator ---
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: cardTextColor
                            opacity: 0.2
                            Layout.topMargin: 10
                            Layout.bottomMargin: 10
                        }

                        // --- 2. Main Block (Temperatures) ---
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            // -- Current Temperature --
                            Text {
                                text: currentTemp
                                font.pixelSize: 55
                                font.bold: true
                                color: primaryColor
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item {
                                Layout.fillWidth: true
                            } // Separator

                            // -- High and Low --
                            ColumnLayout {
                                spacing: 8
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: "High: " + highTemp
                                    font.pixelSize: 16
                                    color: cardTextColor
                                }
                                Text {
                                    text: "Low: " + lowTemp
                                    font.pixelSize: 16
                                    color: cardTextColor
                                }
                            }
                        }
                    }
                }

                // Feels Like and Visibility Card
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    WeatherCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        title: "Feels Like"
                        value: feelsLike
                        icon: "🌡️"
                    }

                    WeatherCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        title: "Visibility"
                        value: visibility
                        icon: "👁️"
                    }
                }

                // Humidity and Wind Card
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    WeatherCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        title: "Humidity"
                        value: humidity
                        icon: "💧"
                    }

                    WeatherCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        title: "Wind"
                        value: windSpeed
                        subtitle: windDirection
                        icon: "💨"
                    }
                }

                // Pressure and UV Index Card
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    WeatherCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        title: "Pressure"
                        value: pressure
                        icon: "📊"
                    }

                    WeatherCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        title: "UV Index"
                        value: uvIndex
                        icon: "☀️"
                    }
                }

                // Sunrise and Sunset Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 110
                    color: cardColor

                    radius: weatherRoot.radius

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 8
                        samples: 16
                        color: "#40000000"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        SunriseSunsetCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            type: "Sunrise"
                            time: sunrise
                            icon: "🌅"
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: ThemeManager.selectedTheme.colors.subtleText.alpha(0.5)
                        }

                        SunriseSunsetCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            type: "Sunset"
                            time: sunset
                            icon: "🌇"
                        }
                    }
                }
            }
        }
    }

    // Weather Card Component
    component WeatherCard: Rectangle {
        property string title: ""
        property string value: ""
        property string subtitle: ""
        property string icon: ""

        color: cardColor
        radius: weatherRoot.radius

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 8
            samples: 16
            color: "#40000000"
        }

        Column {
            anchors.centerIn: parent
            spacing: subtitle !== "" ? 0 : 4

            Text {
                text: icon
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: title
                font.pixelSize: 14
                color: "#666"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: value
                font.pixelSize: 20
                font.bold: true
                color: cardTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                visible: subtitle !== ""
                text: subtitle
                font.pixelSize: 12
                color: "#888"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Sunrise/Sunset Card Component
    component SunriseSunsetCard: Column {
        property string type: ""
        property string time: ""
        property string icon: ""

        spacing: 6

        Text {
            text: icon
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: type
            font.pixelSize: 14
            color: "#666"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: time
            font.pixelSize: 18
            font.bold: true
            color: cardTextColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
