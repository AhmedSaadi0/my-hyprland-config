// windows/leftwindow/weather/WeatherDetailsGrid.qml

import QtQuick
import QtQuick.Layouts
import "root:/themes"
import "root:/services"
import "root:/components"

ColumnLayout {
    id: root
    spacing: 16 // مسافة بين السكاشن الرئيسية

    readonly property var theme: ThemeManager.selectedTheme
    readonly property var colors: theme.colors
    readonly property var typo: theme.typography
    readonly property int cardRadius: theme.dimensions.elementRadius

    // ==========================================
    // 1. التوقعات الساعية (Hourly Forecast)
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 150
        color: colors.surfaceContainer.alpha(0.5)
        radius: root.cardRadius
        border.color: colors.onSurface.alpha(0.05)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
            spacing: 10

            // العنوان
            RowLayout {
                spacing: 8
                Text {
                    text: "󰥔"
                    font.family: typo.iconFont
                    color: colors.primary
                }
                Text {
                    text: qsTr("Upcoming Forecast")
                    font.family: typo.bodyFont
                    font.pixelSize: typo.small
                    color: colors.onSurfaceVariant
                }
            }

            // القائمة
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
                clip: true
                model: Weather.hourlyForecast

                // ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }

                delegate: ColumnLayout {
                    spacing: 8 // مسافة بين الوقت والأيقونة والحرارة
                    width: 50

                    Text {
                        text: modelData.time
                        font.family: typo.bodyFont
                        font.pixelSize: 12
                        color: colors.onSurfaceVariant
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: modelData.icon
                        font.family: typo.iconFont
                        font.pixelSize: 28
                        color: colors.primary
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: modelData.temp + "°"
                        font.family: typo.bodyFont
                        font.pixelSize: 16
                        font.bold: true
                        color: colors.onSurface
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    // ==========================================
    // 2. توقعات الأيام (Daily Forecast)
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: dailyLayout.implicitHeight + 32 // +32 للهوامش (16 فوق و 16 تحت)
        color: colors.surfaceContainer.alpha(0.5)
        radius: root.cardRadius
        border.color: colors.onSurface.alpha(0.05)
        border.width: 1

        ColumnLayout {
            id: dailyLayout
            anchors.fill: parent
            anchors.margins: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
            spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            // العنوان
            RowLayout {
                spacing: 8
                Text {
                    text: ""
                    font.family: typo.iconFont
                    color: colors.primary
                }
                Text {
                    text: qsTr("Upcoming Days")
                    font.family: typo.bodyFont
                    font.pixelSize: typo.small
                    color: colors.onSurfaceVariant
                }
            }

            Repeater {
                model: Weather.dailyForecast
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // اسم اليوم
                    Text {
                        text: modelData.dayName
                        font.family: typo.bodyFont
                        font.pixelSize: 14
                        color: colors.onSurface
                        Layout.preferredWidth: 90
                    }

                    // الأيقونة
                    Text {
                        text: modelData.icon
                        font.family: typo.iconFont
                        font.pixelSize: 20
                        color: colors.primary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    } // مسافة مرنة

                    // الصغرى
                    Text {
                        text: modelData.minTemp + "°"
                        font.family: typo.bodyFont
                        font.pixelSize: 14
                        color: colors.onSurfaceVariant
                    }

                    // البار المرئي
                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 4
                        radius: 2
                        color: colors.primary.alpha(0.15)
                        Rectangle {
                            height: parent.height
                            radius: 2
                            color: colors.primary
                            width: parent.width * 0.7
                            anchors.centerIn: parent
                        }
                    }

                    // العظمى
                    Text {
                        text: modelData.maxTemp + "°"
                        font.family: typo.bodyFont
                        font.pixelSize: 14
                        font.bold: true
                        color: colors.onSurface
                    }
                }
            }
        }
    }

    // ==========================================
    // 3. شبكة التفاصيل (Grid Layout) - مع إصلاح الالتصاق
    // ==========================================
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        rowSpacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        DetailCard {
            title: qsTr("Feels Like")
            value: Weather.feelsLike + "°"
            icon: ""
            iconColor: colors.error
        }
        DetailCard {
            title: qsTr("Humidity")
            value: Weather.humidity + "%"
            icon: ""
            iconColor: colors.primary
        }
        DetailCard {
            title: qsTr("Wind")
            value: Weather.windSpeed + " km/h"
            subtitle: Weather.windDirection
            icon: ""
            iconColor: colors.secondary
        }
        DetailCard {
            title: qsTr("UV Index")
            value: Weather.uvIndex
            icon: "󱟾"
            iconColor: colors.secondary
        }
        DetailCard {
            title: qsTr("Visibility")
            value: Weather.visibility + " km"
            icon: "󰈈"
            iconColor: colors.onSurfaceVariant
        }
        DetailCard {
            title: qsTr("Pressure")
            value: Weather.pressure + " hPa"
            icon: ""
            iconColor: colors.tertiary
        }
    }

    // ==========================================
    // 4. الفلك (Astronomy)
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 110
        color: colors.secondary.alpha(0.1)
        radius: root.cardRadius
        border.color: colors.onSurface.alpha(0.05)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
            spacing: 0

            AstroCard {
                Layout.fillWidth: true
                title: qsTr("Sunrise")
                time: Weather.sunrise
                icon: "󰖜"
                iconColor: colors.secondary
            }

            // فاصل عمودي
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: colors.onSurface.alpha(0.1)
                Layout.margins: 10
            }

            AstroCard {
                Layout.fillWidth: true
                title: qsTr("Sunset")
                time: Weather.sunset
                icon: "󰖛"
                iconColor: colors.error
            }

            // فاصل عمودي
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: colors.onSurface.alpha(0.1)
                Layout.margins: 10
            }

            AstroCard {
                Layout.fillWidth: true
                title: qsTr("Moon")
                time: Weather.moonPhase
                icon: ""
                iconColor: colors.primary
            }
        }
    }

    // ==========================================
    // Components Definitions (Improved Padding)
    // ==========================================

    // المكون المسؤول عن كروت الشبكة
    component DetailCard: Rectangle {
        property string title
        property string value
        property string subtitle: ""
        property string icon
        property color iconColor: colors.primary
        Layout.fillWidth: true
        implicitHeight: 110
        color: colors.surfaceContainer.alpha(0.5)
        radius: root.cardRadius
        border.color: colors.onSurface.alpha(0.05)
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // ── الصف الأول: العنوان + الأيقونة ──
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: title
                    font.pixelSize: 12
                    color: colors.onSurfaceVariant
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: icon
                    font.pixelSize: 20
                    font.family: typo.iconFont
                    color: iconColor
                }
            }

            // ── القيمة ──
            Text {
                text: value
                font.pixelSize: 22
                font.bold: true
                color: colors.onSurface
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // ── الصف الأخير: العنوان الفرعي + مؤشر صغير ──
            RowLayout {
                Layout.fillWidth: true
                visible: subtitle !== ""

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: iconColor
                    opacity: 0.7
                }

                Text {
                    text: subtitle
                    font.pixelSize: 10
                    color: colors.onSurfaceVariant
                    opacity: 0.8
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            // فراغ يملأ الباقي لو ما في subtitle
            Item {
                Layout.fillHeight: true
                visible: subtitle === ""
            }
        }
    }

    component AstroCard: ColumnLayout {
        property string title
        property string time
        property string icon
        property color iconColor: colors.primary

        spacing: 6
        Text {
            text: icon
            font.pixelSize: 26
            font.family: typo.iconFont
            color: iconColor
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: time
            font.pixelSize: 16
            font.bold: true
            color: colors.onSurface
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: title
            font.pixelSize: 12
            color: colors.onSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
