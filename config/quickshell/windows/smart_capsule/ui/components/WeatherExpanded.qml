import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/services"
import "root:/windows/smart_capsule/logic"

Item {
    id: root

    implicitHeight: 170

    // ============================================================
    //  STYLE CONFIGURATION
    // ============================================================
    property QtObject style: QtObject {
        id: style
        property color primary: CapsuleManager.fgColor
        property color secondary: CapsuleManager.fgColor.alpha(0.7)
        property color accent: CapsuleManager.fgColor.alpha(0.9)
        property color divider: CapsuleManager.fgColor.alpha(0.15)

        property string iconFont: ThemeManager.selectedTheme.typography.iconFont

        property int fsHuge: 42
        property int fsIcon: 44
        property int fsLarge: 12
        property int fsNormal: 11
        property int fsSmall: 10
    }

    // ============================================================
    //  DATA LOGIC & SAFETY
    // ============================================================

    // هل البيانات جاهزة؟
    property bool hasData: Weather.currentTemp !== undefined && Weather.currentTemp !== 0 && !Weather.isLoading
    property bool hasForecast: Weather.dailyForecast && Weather.dailyForecast.length > 0

    // بيانات اليوم (مع قيم افتراضية لمنع الكسور)
    property var todayForecast: hasForecast ? Weather.dailyForecast[0] : null

    // دوال مساعدة للنصوص الآمنة
    function safeText(val, fallback) {
        return (hasData && val) ? val : fallback;
    }
    function safeTemp(val) {
        return (hasData && val !== undefined) ? val + "°" : "--";
    }

    // ============================================================
    //  MAIN LAYOUT
    // ============================================================
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // --------------------------------------------------------
        // LEFT SIDE: Current Weather (Fixed Width ~230px)
        // --------------------------------------------------------
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 230
            Layout.maximumWidth: 230
            Layout.alignment: Qt.AlignVCenter
            spacing: -10

            // 1. Header: Location
            RowLayout {
                spacing: 6
                Layout.fillWidth: true

                Text {
                    text: ""
                    font.family: style.iconFont
                    font.pixelSize: 12
                    color: style.secondary
                }
                Text {
                    text: root.hasData ? Weather.areaName : "Loading..."
                    font.pixelSize: 12
                    font.bold: true
                    color: style.secondary

                    // منع النص من الخروج
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            // 2. Main Info: Icon + Temp
            RowLayout {
                Layout.topMargin: 5
                spacing: 12

                // Icon Container (Fixed Size)
                Item {
                    width: style.fsIcon
                    height: style.fsIcon
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: root.hasData ? Weather.weatherIcon : "" // أيقونة افتراضية
                        font.family: style.iconFont
                        font.pixelSize: style.fsIcon
                        color: style.primary
                    }
                }

                // Temp Column
                ColumnLayout {
                    spacing: -2

                    // Current Temp
                    Text {
                        text: safeTemp(Weather.currentTemp)
                        font.bold: true
                        font.pixelSize: style.fsHuge
                        color: style.primary
                    }

                    // High / Low Indicators
                    RowLayout {
                        spacing: 8
                        Text {
                            text: " " + (root.todayForecast ? root.todayForecast.maxTemp + "°" : "--")
                            font.family: style.iconFont
                            font.pixelSize: style.fsSmall
                            color: style.secondary
                        }
                        Text {
                            text: " " + (root.todayForecast ? root.todayForecast.minTemp + "°" : "--")
                            font.family: style.iconFont
                            font.pixelSize: style.fsSmall
                            color: style.secondary
                        }
                    }
                }
            }

            // 3. Description
            Text {
                text: root.hasData ? Weather.weatherDescription : "..."
                font.pixelSize: style.fsLarge
                font.bold: true
                color: style.accent

                Layout.fillWidth: true
                Layout.topMargin: 2

                // القص عند زيادة الطول
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            // 4. Details Row (Humidity & Feels Like)
            RowLayout {
                Layout.topMargin: 5
                spacing: 15

                // Feels Like
                RowLayout {
                    spacing: 4
                    Text {
                        text: ""
                        font.family: style.iconFont
                        font.pixelSize: 12
                        color: style.secondary
                    }
                    Text {
                        text: safeTemp(Weather.feelsLike)
                        font.pixelSize: style.fsNormal
                        color: style.secondary
                    }
                }

                // Humidity
                RowLayout {
                    spacing: 4
                    Text {
                        text: ""
                        font.family: style.iconFont
                        font.pixelSize: 12
                        color: style.secondary
                    }
                    Text {
                        text: root.hasData ? Weather.humidity + "%" : "--%"
                        font.pixelSize: style.fsNormal
                        color: style.secondary
                    }
                }
            }
        }

        // --------------------------------------------------------
        // DIVIDER
        // --------------------------------------------------------
        Rectangle {
            Layout.fillHeight: true
            Layout.topMargin: 15
            Layout.bottomMargin: 15
            width: 1
            color: style.divider
        }

        // --------------------------------------------------------
        // RIGHT SIDE: Forecast (Fixed Width ~120px)
        // --------------------------------------------------------
        RowLayout {
            Layout.preferredWidth: 120 // عرض ثابت
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 10
            spacing: 25

            Repeater {
                model: root.hasForecast ? Weather.dailyForecast.slice(0, 3) : [1, 2, 3]

                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Day
                    Text {
                        text: (root.hasForecast && modelData.dayName) ? modelData.dayName.substring(0, 3).toUpperCase() : "--"
                        font.pixelSize: 10
                        font.bold: true

                        // استخدم root.style
                        color: root.style.secondary

                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Icon
                    Text {
                        text: (root.hasForecast && modelData.icon) ? modelData.icon : ""

                        // استخدم root.style
                        font.family: root.style.iconFont

                        font.pixelSize: 22

                        // استخدم root.style
                        color: root.style.primary

                        opacity: root.hasForecast ? 1 : 0.3
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Temp Stack
                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            text: (root.hasForecast) ? modelData.maxTemp + "°" : "--"
                            font.pixelSize: 12
                            font.bold: true

                            // استخدم root.style
                            color: root.style.primary

                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: (root.hasForecast) ? modelData.minTemp + "°" : "--"
                            font.pixelSize: 10

                            // استخدم root.style
                            color: root.style.secondary

                            opacity: 0.7
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
