// windows/leftwindow/weather/WeatherMenu.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "root:/themes"
import "root:/services"
import "root:/components"
import "root:/utils"

Flickable {
    id: weatherRoot

    readonly property int sidePadding: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    flickableDirection: Flickable.VerticalFlick
    contentHeight: pageLayout.implicitHeight
    clip: true

    // --- منطق الإشعارات ---
    property var lastNotificationTimes: ({})
    function canSendNotification(notificationType) {
        const now = new Date();
        const cooldown = 4 * 60 * 60 * 1000;
        const lastTime = lastNotificationTimes;

        if (!lastTime || (now.getTime() - lastTime.getTime() > cooldown)) {
            lastNotificationTimes = now;
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

    // --- تخطيط الصفحة ---
    ColumnLayout {
        id: pageLayout
        width: weatherRoot.width
        spacing: 0 // صفر لالتصاق الهيدر بالـ TopAppBar

        // 1. الشريط العلوي
        TopAppBar {
            Layout.fillWidth: true
            title: qsTr("Weather")
            icon: "󰖨"
            scrollY: weatherRoot.contentY
            primaryActionVisible: false
        }

        // 2. معلومات الطقس العامة (الكرت الجديد)
        WeatherMainHeader {
            Layout.fillWidth: true
        }

        // 3. باقي المحتوى (بهوامش جانبية)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: weatherRoot.sidePadding
            spacing: ThemeManager.selectedTheme.dimensions.spacingMedium

            property bool isAiDataAvailable: Weather.aiSummaryText !== ""

            // --- كرت الذكاء الاصطناعي ---
            AISummaryCard {
                id: smartWeatherCard
                Layout.fillWidth: true
                visible: true

                title: Weather.aiTrendBadge !== "" ? Weather.aiTrendBadge : "محلل الطقس الذكي"
                summaryText: Weather.aiSummaryText !== "" ? Weather.aiSummaryText : "جاري تحليل حالة الطقس..."
                footerText: Weather.aiSmartPollingDetails !== "" ? ("⏱ " + Weather.aiSmartPollingDetails) : ""
                iconText: "✨"
                isLoading: Weather.aiSummaryText === ""

                // إظهار زر إعادة تحليل الذكاء الاصطناعي فقط (التحديث العادي في الهيدر العام)
                showDataRefreshButton: false
                showAiRefreshButton: true
                onRefreshAiClicked: {
                    console.log("طلب تحليل جديد من الـ AI...");
                    // Weather.requestAiAnalysis();
                }

                // الكلمات الدلالية
                bottomContent: Flow {
                    width: smartWeatherCard.width - (ThemeManager.selectedTheme.dimensions.menuWidgetsMargin * 2)
                    spacing: 6
                    topPadding: 4
                    visible: Weather.aiTags && Weather.aiTags.length > 0

                    Repeater {
                        model: Weather.aiTags
                        delegate: Rectangle {
                            height: 24
                            width: tagText.contentWidth + 16
                            color: smartWeatherCard.aiBorderColor.alpha(0.3)
                            radius: 6
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

            // --- تفاصيل الطقس (الشبكة) ---
            WeatherDetailsGrid {
                Layout.fillWidth: true
            }
        }
    }
}
