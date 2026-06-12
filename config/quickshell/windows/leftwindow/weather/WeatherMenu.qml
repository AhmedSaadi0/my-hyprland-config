// windows/leftwindow/weather/WeatherMenu.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "root:/themes"
import "root:/services"
import "root:/components"
import "root:/utils"
import "root:/config/ConstValues.js" as C
import "../base"

BaseMenuView {
    id: weatherRoot

    menuTitle: qsTr("Weather")
    menuIcon: "󰖨"
    showPrimaryAction: false

    // --- منطق الإشعارات ---
    property var lastNotificationTimes: ({})
    function canSendNotification(notificationType) {
        const now = new Date();
        const cooldown = 4 * 60 * 60 * 1000;
        const lastTime = lastNotificationTimes[notificationType];
        if (!lastTime || (now.getTime() - lastTime.getTime() > cooldown)) {
            lastNotificationTimes[notificationType] = now;
            return true;
        }
        return false;
    }

    Connections {
        target: Weather
        function onChanceOfRainNotified(message) {
            if (canSendNotification("rain"))
                NotifManager.notify({
                    summary: "Chance of Rain",
                    body: message,
                    icon: App.assets.icons.rain
                });
        }
        function onChanceOfSnowNotified(message) {
            if (canSendNotification("snow"))
                NotifManager.notify({
                    summary: "Chance of Snow",
                    body: message,
                    icon: App.assets.icons.coldWeather
                });
        }
    }

    // --- المحتوى ---
    // NOTE: -> to make it stick use
    // headerContent: WeatherMainHeader {
    WeatherMainHeader {
        Layout.fillWidth: true
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: weatherRoot.sidePadding
        spacing: weatherRoot.sidePadding

        AISummaryCard {
            id: smartWeatherCard
            Layout.fillWidth: true
            // Layout.bottomMargin: weatherRoot.sidePadding

            title: Weather.aiTrendBadge !== "" ? Weather.aiTrendBadge : "محلل الطقس الذكي"
            summaryText: Weather.aiSummaryText !== "" ? Weather.aiSummaryText : "جاري تحليل حالة الطقس..."
            footerText: Weather.aiSmartPollingDetails !== "" ? ("⏱ " + Weather.aiSmartPollingDetails) : ""
            iconText: "✨"
            isLoading: Weather.aiSummaryText === ""

            showDataRefreshButton: false
            showAiRefreshButton: true
            onRefreshAiClicked: {
                console.log("طلب تحليل جديد من الـ AI...");
            }

            bottomContent: Flow {
                width: smartWeatherCard.width - (ThemeManager.selectedTheme.dimensions.menuWidgetsMargin * 2)
                spacing: 3
                topPadding: 4
                visible: Weather.aiTags && Weather.aiTags.length > 0

                Repeater {
                    id: tagsRepeater
                    model: Weather.aiTags
                    delegate: Rectangle {
                        height: 24
                        width: tagText.contentWidth + 16
                        color: smartWeatherCard.aiBorderColor.alpha(0.3)
                        property int groupRadius: ThemeManager.selectedTheme.dimensions.elementRadius / C.M3_BUTTON_RADIUS_DIVISOR
                        property int innerRadiusDiv: 4
                        topLeftRadius: index === 0 ? groupRadius : groupRadius / innerRadiusDiv
                        bottomLeftRadius: index === 0 ? groupRadius : groupRadius / innerRadiusDiv
                        topRightRadius: index === tagsRepeater.count - 1 ? groupRadius : groupRadius / innerRadiusDiv
                        bottomRightRadius: index === tagsRepeater.count - 1 ? groupRadius : groupRadius / innerRadiusDiv
                        border.color: smartWeatherCard.aiBorderColor.alpha(0.5)
                        border.width: 1

                        Text {
                            id: tagText
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 12
                            color: smartWeatherCard.aiTextColor
                        }
                    }
                }
            }
        }

        WeatherDetailsGrid {
            Layout.fillWidth: true
        }
    }
}
