// ModernWeather.qml
import QtQuick
// import QtQuick.Controls
// import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import Quickshell.Io

import "root:/themes"
import "root:/services"
import "root:/components"
import "root:/utils"
import "root:/config"

ColumnLayout {
    id: weatherRoot

    spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
    height: 300

    // width: 380
    // height: parent ? parent.height : 700

    // Static weather data (placeholder)
    property string cityName: Weather.areaName
    property string currentTemp: Weather.currentTemp
    property string weatherCondition: Weather.weatherDescription
    property string weatherIcon: Weather.weatherIcon
    property string highTemp: Weather.dailyForecast[0] !== undefined ? Weather.dailyForecast[0].maxTemp : 0
    property string lowTemp: Weather.dailyForecast[0] !== undefined ? Weather.dailyForecast[0].minTemp : 0
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

    property string accentColor: ThemeManager.selectedTheme.colors.primary
    property string textColor: ThemeManager.selectedTheme.colors.subtleTextColor !== undefined ? ThemeManager.selectedTheme.colors.subtleTextColor : null

    property string mainCardColor: ThemeManager.selectedTheme.colors.primary.alpha(0.4)
    property string mainCardTextColor: ThemeManager.selectedTheme.colors.topbarFgColorV1

    property string cardColor: ThemeManager.selectedTheme.colors.topbarBgColorV1
    property string cardTextColor: ThemeManager.selectedTheme.colors.topbarFgColorV1

    property var radius: ThemeManager.selectedTheme.dimensions.elementRadius
    property var iconFont: ThemeManager.selectedTheme.typography.iconFont

    property var lastNotificationTimes: ({})

    function canSendNotification(notificationType) {
        const now = new Date();
        const twoHoursInMillis = 4 * 60 * 60 * 1000;

        const lastTime = lastNotificationTimes[notificationType];

        if (!lastTime || (now.getTime() - lastTime.getTime() > twoHoursInMillis)) {
            lastNotificationTimes[notificationType] = now;
            console.log("Sending notification for:", notificationType);
            return true;
        }

        console.log("Skipping notification for:", notificationType, ". Not enough time has passed.");
        return false;
    }

    Connections {
        target: Weather

        function onChanceOfRainNotified(message) {
            if (!canSendNotification("rain"))
                return;

            NotifManager.notify({
                summary: "Chance of rain",
                body: message,
                icon: App.assets.icons.rain,
                tone: App.assets.audio.coldWeather
            });
        }

        function onChanceOfSnowNotified(message) {
            if (!canSendNotification("snow"))
                return;

            NotifManager.notify({
                summary: "Chance of snow",
                body: message,
                icon: App.assets.icons.coldWeather,
                tone: App.assets.audio.coldWeather
            });
        }

        function onChanceOfFrostNotified(message) {
            if (!canSendNotification("frost"))
                return;

            NotifManager.notify({
                summary: "Chance of frost",
                body: message,
                icon: App.assets.icons.coldWeather,
                tone: App.assets.audio.coldWeather
            });
        }

        function onChanceOfFogNotified(message) {
            if (!canSendNotification("fog"))
                return;

            NotifManager.notify({
                summary: "Chance of fog",
                body: message,
                icon: App.assets.icons.fog,
                tone: App.assets.audio.coldWeather
            });
        }

        function onChanceOfThunderNotified(message) {
            if (!canSendNotification("thunder"))
                return;

            NotifManager.notify({
                summary: "Chance of thunder",
                body: message,
                icon: App.assets.icons.thunder,
                tone: App.assets.audio.coldWeather
            });
        }

        function onChanceOfWindyNotified(message) {
            if (!canSendNotification("wind"))
                return;

            NotifManager.notify({
                summary: "Chance of wind",
                body: message,
                icon: App.assets.icons.wind,
                tone: App.assets.audio.coldWeather
            });
        }

        function onWeatherUpdated() {
        // ...
        }

        function onFetchFailed(error) {
        // ...
        }
    }

    MenuCard {
        id: weatherHeaderCard

        Layout.fillWidth: true
        Layout.preferredHeight: 210

        // cardColor: ThemeManager.selectedTheme.colors.leftMenuBgColorV3
        // textColor: ThemeManager.selectedTheme.colors.leftMenufgColorV3
        cardColor: mainCardColor

        cardLeftPadding: 8
        cardRightPadding: 8

        title: cityName
        subtitle: "Last Update: " + lastUpdate
        icon: "󰑓"
        iconCursorShape: Qt.PointingHandCursor

        onIconClicked: {
            console.info("Icon has been clicked! Calling the refresh function now.");
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
            easing.type: Easing.InOutCubic
        }

        // --- Main Content Container ---
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                id: backgroundWeatherIcon
                text: weatherIcon
                font.pixelSize: 140
                color: mainCardTextColor
                opacity: 0.08
                font.family: iconFont

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            RowLayout {
                anchors.fill: parent

                Text {
                    text: currentTemp
                    color: accentColor
                    font.pixelSize: 65
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 10
                }

                Item {
                    Layout.fillWidth: true
                } // Separator

                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 10

                    Text {
                        Layout.fillWidth: true
                        text: "High: " + highTemp
                        font.pixelSize: 16
                        color: mainCardTextColor
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Low: " + lowTemp
                        font.pixelSize: 16
                        color: mainCardTextColor
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: weatherCondition
                        font.pixelSize: 16
                        color: mainCardTextColor
                        opacity: 0.8
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }

    // Sunrise and Sunset Card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 110
        color: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)

        radius: weatherRoot.radius

        // layer.enabled: true
        // layer.effect: DropShadow {
        //     transparentBorder: true
        //     radius: 8
        //     samples: 16
        //     color: "#40000000"
        // }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

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

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        WeatherCard {
            id: feelsLikeCard
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            title: "Feels Like"
            value: feelsLike
            icon: "🌡️"

            // --- التأثير اللوني المعتمد على الحرارة ---
            // property color tempColor: weatherRoot.getColorForTemperature(feelsLike)
            //
            // // طبقة علوية للتأثير اللوني
            // Rectangle {
            //     id: colorOverlay
            //     anchors.fill: parent
            //     radius: parent.radius
            //     gradient: Gradient {
            //         GradientStop {
            //             position: 0.0
            //             // تعديل الشفافية هنا مباشرة
            //             color: {
            //                 let c = feelsLikeCard.tempColor;
            //                 c.a = 0.2;
            //                 return c;
            //             }
            //         }
            //         GradientStop {
            //             position: 1.0
            //             color: "transparent"
            //         }
            //     }
            //     opacity: 0
            // }
            //
            // // مؤقت لتشغيل التأثير كل فترة
            // Timer {
            //     id: tempColorTimer
            //     interval: 6300
            //     repeat: true
            //     running: true
            //     onTriggered: {
            //         // تشغيل حركة الظهور والاختفاء
            //         colorEffectAnimation.start();
            //     }
            // }
            //
            // // حركة ظهور واختفاء التأثير
            // SequentialAnimation {
            //     id: colorEffectAnimation
            //     running: false // لا تعمل إلا عند استدعائها
            //
            //     // 1. ظهور التأثير
            //     NumberAnimation {
            //         target: colorOverlay
            //         property: "opacity"
            //         to: 1.0
            //         duration: 700
            //         easing.type: Easing.InQuad
            //     }
            //     // 2. انتظار لثانية واحدة
            //     PauseAnimation {
            //         duration: 1000
            //     }
            //     // 3. اختفاء التأثير
            //     NumberAnimation {
            //         target: colorOverlay
            //         property: "opacity"
            //         to: 0.0
            //         duration: 700
            //         easing.type: Easing.OutQuad
            //     }
            // }
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
        spacing: 12

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
        spacing: 12

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

    // Weather Card Component
    component WeatherCard: Rectangle {
        property string title: ""
        property string value: ""
        property string subtitle: ""
        property string icon: ""

        color: cardColor
        radius: weatherRoot.radius

        border.width: 1
        border.color: "transparent"

        // layer.enabled: true
        // layer.effect: DropShadow {
        //     transparentBorder: true
        //     radius: 8
        //     samples: 16
        //     color: "#40000000"
        // }

        Column {
            anchors.centerIn: parent
            spacing: subtitle !== "" ? 0 : 4

            Text {
                text: icon
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 20
                font.family: ThemeManager.selectedTheme.typography.iconFont
            }

            Text {
                text: title
                font.pixelSize: 14
                color: cardTextColor
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
                color: weatherRoot.textColor
                anchors.horizontalCenter: {
                    parent.horizontalCenter;
                }
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
            font.family: ThemeManager.selectedTheme.typography.iconFont
        }

        Text {
            text: type
            font.pixelSize: 14
            color: weatherRoot.textColor
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

    function getColorForTemperature(tempStr) {
        const temp = parseFloat(tempStr);

        // نصيحة للبرمجة: استخدم console.log للتحقق من القيم أثناء التطوير
        // console.log("FeelsLike Input:", tempStr, "Parsed Temp:", temp);

        // اللون الافتراضي في حالة عدم وجود قيمة صالحة
        if (isNaN(temp)) {
            return Qt.rgba(0.5, 0.5, 0.5, 1); // لون رمادي محايد كقيمة افتراضية
        }

        const coldColor = Qt.rgba(0.3, 0.6, 1.0, 1);    // أزرق
        const neutralColor = Qt.rgba(0.9, 0.9, 0.9, 1); // أبيض مائل للرمادي
        const warmColor = Qt.rgba(1.0, 0.5, 0.2, 1);    // برتقالي
        const hotColor = Qt.rgba(1.0, 0.2, 0.2, 1);     // أحمر

        if (temp <= 10) {
            return coldColor;
        } else if (temp > 10 && temp <= 20) {
            return Qt.color(coldColor.r + (neutralColor.r - coldColor.r) * ((temp - 10) / 10), coldColor.g + (neutralColor.g - coldColor.g) * ((temp - 10) / 10), coldColor.b + (neutralColor.b - coldColor.b) * ((temp - 10) / 10));
        } else if (temp > 20 && temp < 30) {
            return Qt.color(neutralColor.r + (warmColor.r - neutralColor.r) * ((temp - 20) / 10), neutralColor.g + (warmColor.g - neutralColor.g) * ((temp - 20) / 10), neutralColor.b + (warmColor.b - neutralColor.b) * ((temp - 20) / 10));
        } else {
            // temp >= 30
            const factor = Math.min((temp - 30) / 10, 1.0);
            return Qt.color(warmColor.r + (hotColor.r - warmColor.r) * factor, warmColor.g + (hotColor.g - warmColor.g) * factor, warmColor.b + (hotColor.b - warmColor.b) * factor);
        }
    }
}
