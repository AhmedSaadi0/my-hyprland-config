// windows/leftwindow/weather/WeatherMainHeader.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "root:/themes"
import "root:/services"
import "root:/components"
import "root:/windows/leftwindow/base"

HeaderCard {
    id: root
    implicitHeight: mainCol.implicitHeight + 40
    implicitWidth: mainCol.implicitWidth + 40

    readonly property var theme: ThemeManager.selectedTheme
    readonly property var colors: theme.colors
    readonly property var typo: theme.typography

    actionIcon: "󰑓"
    onActionClicked: {
        Weather.getWeatherData();
        rotationAnim.start();
    }

    RotationAnimation {
        id: rotationAnim
        target: root.actionButton.iconItem
        property: "rotation"
        from: 0
        to: 360
        duration: 1000
    }

    // 2. المحتوى الرئيسي
    ColumnLayout {
        id: mainCol
        Layout.fillWidth: true
        Layout.margins: 20
        spacing: 12

        // --- أ: الموقع وتوقيت التحديث ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: Weather.areaName
                font.family: typo.bodyFont
                font.pixelSize: 24
                font.weight: Font.Bold
                color: colors.leftMenuFgColorV1
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 6
                Text {
                    text: Weather.countryName
                    font.family: typo.bodyFont
                    font.pixelSize: 13
                    color: colors.subtleText
                }

                // نقطة فاصلة
                Rectangle {
                    width: 4
                    height: 4
                    radius: 2
                    color: colors.subtleText.alpha(0.5)
                }

                Text {
                    text: Weather.lastUpdated
                    font.family: typo.bodyFont
                    font.pixelSize: 12
                    color: colors.subtleText.alpha(0.8)
                }
            }
        }

        Item {
            Layout.preferredHeight: 5
        } // مسافة

        // --- ب: القسم الرئيسي (الأيقونة + الحرارة) ---
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 15

            // 1. الأيقونة الكبيرة العائمة
            Item {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 0
                        to: -5
                        duration: 2500
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        from: -5
                        to: 0
                        duration: 2500
                        easing.type: Easing.InOutSine
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Weather.weatherIcon
                    font.family: typo.iconFont
                    font.pixelSize: 72
                    color: colors.primary
                }

                // ظل ملون خلف الأيقونة ليعطي عمقاً
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    // shadowColor: palette.shadow
                    shadowColor: theme.colors.baseShadowColor.alpha(0.6)
                    shadowBlur: 1.0
                    shadowOpacity: 0.4
                    shadowVerticalOffset: 5
                }
            }

            // 2. الحرارة والوصف
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -4

                Text {
                    text: Weather.currentTemp + "°"
                    font.family: typo.bodyFont
                    font.pixelSize: 58
                    font.weight: Font.DemiBold
                    color: colors.leftMenuFgColorV1
                }

                Text {
                    text: Weather.weatherDescription
                    font.family: typo.bodyFont
                    font.pixelSize: 16
                    color: colors.leftMenuFgColorV2
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                // الحرارة المحسوسة
                Text {
                    text: qsTr("Feels like ") + Weather.feelsLike + "°"
                    font.family: typo.bodyFont
                    font.pixelSize: 13
                    color: colors.subtleText
                }
            }
        }

        Item {
            Layout.preferredHeight: 10
        } // مسافة

        // --- ج: شبكة التفاصيل (Info Grid) ---
        // تعرض الرطوبة، الرياح، UV، والشروق
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 8
            rowSpacing: 0

            // العناصر
            StatBox {
                icon: ""
                value: Weather.humidity + "%"
                label: qsTr("Humidity")
                iconColor: colors.primary
            }
            StatBox {
                icon: ""
                value: Weather.windSpeed + " km"
                label: qsTr("Wind")
                iconColor: colors.subtleText
            }
            StatBox {
                icon: ""
                value: String(Weather.uvIndex)
                label: qsTr("UV Index")
                iconColor: colors.warning
            }
            StatBox {
                icon: ""
                value: Weather.sunrise
                label: qsTr("Sunrise")
                iconColor: colors.warning
            }
        }

        Item {
            Layout.preferredHeight: 5
        } // مسافة

        // خط فاصل خفيف
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: colors.leftMenuFgColorV1.alpha(0.08)
        }

        // --- د: العظمى والصغرى (Max/Min) ---
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 5
            spacing: 15

            // Max Temp Pill
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 32
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                color: colors.error.alpha(0.1)
                border.color: colors.error.alpha(0.2)
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: ""
                        font.family: typo.iconFont
                        color: colors.error
                        font.pixelSize: 14
                    }
                    Text {
                        text: (Weather.dailyForecast[0]?.maxTemp || "--") + "° Max"
                        font.family: typo.bodyFont
                        color: colors.error
                        font.bold: true
                        font.pixelSize: 13
                    }
                }
            }

            // Min Temp Pill
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 32
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                // لون الخلفية: لون الثيم الأساسي شفاف (Primary)
                color: colors.primary.alpha(0.1)
                border.color: colors.primary.alpha(0.2)
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: ""
                        font.family: typo.iconFont
                        color: colors.primary
                        font.pixelSize: 14
                    }
                    Text {
                        text: (Weather.dailyForecast[0]?.minTemp || "--") + "° Min"
                        font.family: typo.bodyFont
                        color: colors.primary
                        font.bold: true
                        font.pixelSize: 13
                    }
                }
            }
        }
    }

    // مكون داخلي لتكرار العناصر بنفس التصميم
    component StatBox: ColumnLayout {
        property string icon
        property string value
        property string label
        property color iconColor: colors.subtleText // افتراضي

        spacing: 4

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 40
            height: 40
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            // خلفية شفافة جداً بلون الثيم
            color: colors.leftMenuFgColorV1.alpha(0.05)

            Text {
                anchors.centerIn: parent
                text: icon
                font.family: typo.iconFont
                font.pixelSize: 18
                color: iconColor
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: value
            font.family: typo.bodyFont
            font.pixelSize: 13
            font.bold: true
            color: colors.leftMenuFgColorV1
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: label
            font.family: typo.bodyFont
            font.pixelSize: 11
            color: colors.subtleText
        }
    }
}
