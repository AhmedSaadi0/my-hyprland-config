// ModernWeather.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "root:/themes"
import "root:/services"
import "root:/components"
import "root:/utils"
import "root:/config"
import "root:/utils/helpers.js" as Helper

// --- Root element is now a Flickable to allow scrolling ---
Flickable {
    id: weatherRoot

    // Flickable Properties
    flickableDirection: Flickable.VerticalFlick
    contentHeight: contentColumn.height // Set content height to the layout's height
    clip: true // Ensure content doesn't spill out

    // The main content is placed inside this ColumnLayout
    ColumnLayout {
        id: contentColumn
        width: weatherRoot.width // Bind the layout width to the Flickable's width
        spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        // ========================================================================
        // 1. Smart Properties & Logic
        // ========================================================================

        property bool isAiDataAvailable: Weather.aiSmartIcon !== "" && Weather.aiBgColor !== ""

        // --- Dynamic Properties ---
        property string displayIcon: Weather.weatherIcon
        property string displayTitle: Weather.weatherDescription
        property string displayTemp: Weather.currentTemp
        property string displayFeelsLike: Weather.feelsLike
        property string displayHumidity: Weather.humidity
        property color displayCardColor: mainCardColor

        // --- Static Properties ---
        property string accentColor: ThemeManager.selectedTheme.colors.primary
        property string textColor: ThemeManager.selectedTheme.colors.subtleText
        property color mainCardColor: ThemeManager.selectedTheme.colors.primary.alpha(0.4)
        property string mainCardTextColor: ThemeManager.selectedTheme.colors.topbarFgColorV1
        property color cardColor: ThemeManager.selectedTheme.colors.topbarBgColorV1
        property string cardTextColor: ThemeManager.selectedTheme.colors.topbarFgColorV1
        property var radius: ThemeManager.selectedTheme.dimensions.elementRadius
        property var iconFont: ThemeManager.selectedTheme.typography.iconFont
        property var lastNotificationTimes: ({})

        // ========================================================================
        // 2. Connections & Notifications
        // ========================================================================

        // Helper function to prevent spamming notifications
        function canSendNotification(notificationType) {
            const now = new Date();
            // Cooldown period: 4 hours in milliseconds
            const cooldown = 4 * 60 * 60 * 1000;
            const lastTime = lastNotificationTimes[notificationType];

            if (!lastTime || (now.getTime() - lastTime.getTime() > cooldown)) {
                lastNotificationTimes[notificationType] = now;
                console.log("Notification allowed for:", notificationType);
                return true;
            }
            console.log("Skipping notification for:", notificationType, "(cooldown)");
            return false;
        }

        Connections {
            target: Weather

            function onChanceOfRainNotified(message) {
                if (!contentColumn.canSendNotification("rain"))
                    return;
                NotifManager.notify({
                    summary: "Chance of Rain",
                    body: message,
                    icon: App.assets.icons.rain,
                    tone: App.assets.audio.rain
                });
            }

            function onChanceOfSnowNotified(message) {
                if (!contentColumn.canSendNotification("snow"))
                    return;
                NotifManager.notify({
                    summary: "Chance of Snow",
                    body: message,
                    icon: App.assets.icons.coldWeather,
                    tone: App.assets.audio.coldWeather
                });
            }

            function onChanceOfFrostNotified(message) {
                if (!contentColumn.canSendNotification("frost"))
                    return;
                NotifManager.notify({
                    summary: "Chance of Frost",
                    body: message,
                    icon: App.assets.icons.coldWeather,
                    tone: App.assets.audio.coldWeather
                });
            }

            function onChanceOfFogNotified(message) {
                if (!contentColumn.canSendNotification("fog"))
                    return;
                NotifManager.notify({
                    summary: "Chance of Fog",
                    body: message,
                    icon: App.assets.icons.fog,
                    tone: App.assets.audio.coldWeather
                });
            }

            function onChanceOfThunderNotified(message) {
                if (!contentColumn.canSendNotification("thunder"))
                    return;
                NotifManager.notify({
                    summary: "Chance of Thunder",
                    body: message,
                    icon: App.assets.icons.thunder,
                    tone: App.assets.audio.coldWeather
                });
            }

            function onChanceOfWindyNotified(message) {
                if (!contentColumn.canSendNotification("wind"))
                    return;
                NotifManager.notify({
                    summary: "Chance of Strong Wind",
                    body: message,
                    icon: App.assets.icons.wind,
                    tone: App.assets.audio.coldWeather
                });
            }
        }

        // ========================================================================
        // 3. UI Components
        // ========================================================================

        // --- Main Weather Card ---
        MenuCard {
            id: weatherHeaderCard
            Layout.fillWidth: true
            Layout.preferredHeight: 210
            cardColor: contentColumn.displayCardColor
            cardLeftPadding: 8
            cardRightPadding: 8
            title: Weather.areaName
            subtitle: "Last Update: " + Weather.lastUpdated
            icon: "󰑓"
            iconCursorShape: Qt.PointingHandCursor

            onIconClicked: {
                Weather.getWeatherData();
                rotationAnim.start();
            }

            RotationAnimation {
                id: rotationAnim
                target: weatherHeaderCard.iconItem
                property: "rotation"
                from: 0
                to: 360
                duration: 1000
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    id: backgroundWeatherIcon
                    text: contentColumn.displayIcon
                    font.pixelSize: 140
                    color: contentColumn.mainCardTextColor
                    opacity: 0.08
                    font.family: contentColumn.iconFont
                    anchors.centerIn: parent
                }

                RowLayout {
                    anchors.fill: parent

                    Text {
                        text: contentColumn.displayTemp + "°"
                        color: contentColumn.accentColor
                        font.pixelSize: 65
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 10
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 10
                        Text {
                            text: `High: ${Weather.dailyForecast[0]?.maxTemp || 0}°`
                            font.pixelSize: 16
                            color: contentColumn.mainCardTextColor
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            text: `Low: ${Weather.dailyForecast[0]?.minTemp || 0}°`
                            font.pixelSize: 16
                            color: contentColumn.mainCardTextColor
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            text: contentColumn.displayTitle
                            font.pixelSize: 16
                            color: contentColumn.mainCardTextColor
                            opacity: 0.8
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }

        // --- AI Smart Summary Card ---
        MenuCard {
            id: smartWeatherDetailsCard
            Layout.fillWidth: true
            visible: contentColumn.isAiDataAvailable && Weather.aiSummaryText
            cardColor: Weather.aiBgColor1
            textColor: Helper.getAccurteTextColor(Weather.aiBgColor1)
            icon: "󱙺"
            title: Weather.aiTrendBadge

            // gradient: Gradient {
            //     orientation: Gradient.Horizontal
            //     GradientStop {
            //         position: 0.0
            //         color: Weather.aiBgColor1
            //     }
            //     GradientStop {
            //         position: 1.0
            //         color: Weather.aiBgColor2
            //     }
            // }

            Text {
                Layout.fillWidth: true
                text: Weather.aiSummaryText
                wrapMode: Text.WordWrap
                font.pixelSize: 14
                color: Helper.getAccurteTextColor(Weather.aiBgColor1)
            }

            Flow {
                Layout.fillWidth: true
                spacing: 6
                topPadding: 8
                visible: Weather.aiTags.length > 0
                Repeater {
                    model: Weather.aiTags
                    delegate: Rectangle {
                        height: 24
                        width: tagText.contentWidth + 16
                        color: Weather.aiBgColor1.lighter(1.25)
                        radius: 6
                        Text {
                            id: tagText
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 12
                            color: Helper.getAccurteTextColor(Weather.aiBgColor1)
                        }
                    }
                }
            }
        }

        // --- Details Cards ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            color: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)
            radius: contentColumn.radius
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12
                SunriseSunsetCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    type: "Sunrise"
                    time: Weather.sunrise
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
                    time: Weather.sunset
                    icon: "🌇"
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            WeatherCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                title: "Feels Like"
                value: contentColumn.displayFeelsLike + "°"
                icon: "🌡️"
            }
            WeatherCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                title: "Visibility"
                value: Weather.visibility + " km"
                icon: "👁️"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            WeatherCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                title: "Humidity"
                value: contentColumn.displayHumidity
                icon: "💧"
            }
            WeatherCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                title: "Wind"
                value: Weather.windSpeed + " km/h"
                subtitle: Weather.windDirection
                icon: "💨"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            WeatherCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                title: "Pressure"
                value: Weather.pressure + " hPa"
                icon: "📊"
            }
            WeatherCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                title: "UV Index"
                value: Weather.uvIndex
                icon: "☀️"
            }
        }
    } // End of contentColumn

    // ========================================================================
    // 4. Component Definitions
    // ========================================================================
    component WeatherCard: Rectangle {
        property string title
        property string value
        property string subtitle
        property string icon
        color: contentColumn.cardColor
        radius: contentColumn.radius
        Column {
            anchors.centerIn: parent
            spacing: subtitle !== "" ? 0 : 4
            Text {
                text: icon
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 20
                font.family: contentColumn.iconFont
            }
            Text {
                text: title
                font.pixelSize: 14
                color: contentColumn.cardTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: value
                font.pixelSize: 20
                font.bold: true
                color: contentColumn.cardTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                visible: subtitle !== ""
                text: subtitle
                font.pixelSize: 12
                color: contentColumn.textColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    component SunriseSunsetCard: Column {
        property string type
        property string time
        property string icon
        spacing: 6
        Text {
            text: icon
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: contentColumn.iconFont
        }
        Text {
            text: type
            font.pixelSize: 14
            color: contentColumn.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: time
            font.pixelSize: 18
            font.bold: true
            color: contentColumn.cardTextColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
