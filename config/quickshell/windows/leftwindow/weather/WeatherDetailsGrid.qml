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
        Layout.preferredHeight: 150 // زدنا الارتفاع لراحة العناصر
        color: colors.topbarBgColorV1.alpha(0.5)
        radius: root.cardRadius
        border.color: colors.leftMenuFgColorV1.alpha(0.05)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16 // هامش داخلي مريح للكرت بالكامل
            spacing: 10

            // العنوان
            RowLayout {
                spacing: 8
                Text { text: ""; font.family: typo.iconFont; color: colors.primary }
                Text { 
                    text: "التوقعات القادمة"
                    font.family: typo.bodyFont
                    font.pixelSize: typo.small
                    color: colors.subtleText
                }
            }

            // القائمة
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                spacing: 20 // مسافة كبيرة بين كل ساعة وأخرى
                clip: true
                model: Weather.hourlyForecast
                
                // ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }

                delegate: ColumnLayout {
                    spacing: 8 // مسافة بين الوقت والأيقونة والحرارة
                    width: 50
                    
                    Text { 
                        text: modelData.time
                        font.family: typo.bodyFont; font.pixelSize: 12
                        color: colors.subtleText
                        Layout.alignment: Qt.AlignHCenter 
                    }
                    Text { 
                        text: modelData.icon 
                        font.family: typo.iconFont; font.pixelSize: 28
                        color: colors.primary
                        Layout.alignment: Qt.AlignHCenter 
                    }
                    Text { 
                        text: modelData.temp + "°"
                        font.family: typo.bodyFont; font.pixelSize: 16; font.bold: true
                        color: colors.leftMenuFgColorV1
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
        color: colors.topbarBgColorV1.alpha(0.5)
        radius: root.cardRadius
        border.color: colors.leftMenuFgColorV1.alpha(0.05)
        border.width: 1

        ColumnLayout {
            id: dailyLayout
            anchors.fill: parent
            anchors.margins: 16 // هامش داخلي
            spacing: 16 // تباعد بين الأسطر

            // العنوان
            RowLayout {
                spacing: 8
                Text { text: ""; font.family: typo.iconFont; color: colors.primary }
                Text { 
                    text: "الأيام القادمة"
                    font.family: typo.bodyFont
                    font.pixelSize: typo.small
                    color: colors.subtleText
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
                        font.family: typo.bodyFont; font.pixelSize: 14
                        color: colors.leftMenuFgColorV1
                        Layout.preferredWidth: 90 
                    }
                    
                    // الأيقونة
                    Text { 
                        text: modelData.icon
                        font.family: typo.iconFont; font.pixelSize: 20
                        color: colors.primary
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Item { Layout.fillWidth: true } // مسافة مرنة
                    
                    // الصغرى
                    Text { 
                        text: modelData.minTemp + "°"
                        font.family: typo.bodyFont; font.pixelSize: 14
                        color: colors.subtleText 
                    }
                    
                    // البار المرئي
                    Rectangle {
                        Layout.preferredWidth: 60; Layout.preferredHeight: 4; radius: 2
                        color: colors.primary.alpha(0.15)
                        Rectangle {
                            height: parent.height; radius: 2; color: colors.primary
                            width: parent.width * 0.7; anchors.centerIn: parent
                        }
                    }
                    
                    // العظمى
                    Text { 
                        text: modelData.maxTemp + "°"
                        font.family: typo.bodyFont; font.pixelSize: 14; font.bold: true
                        color: colors.leftMenuFgColorV1 
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
        columnSpacing: 16 // زيادة المسافة بين الأعمدة
        rowSpacing: 16    // زيادة المسافة بين الصفوف

        DetailCard { title: "Feels Like"; value: Weather.feelsLike + "°"; icon: ""; iconColor: colors.error }
        DetailCard { title: "Humidity"; value: Weather.humidity + "%"; icon: ""; iconColor: colors.primary }
        DetailCard { title: "Wind"; value: Weather.windSpeed + " km/h"; subtitle: Weather.windDirection; icon: ""; iconColor: colors.secondary }
        DetailCard { title: "UV Index"; value: Weather.uvIndex; icon: ""; iconColor: colors.warning }
        DetailCard { title: "Visibility"; value: Weather.visibility + " km"; icon: ""; iconColor: colors.subtleText }
        DetailCard { title: "Pressure"; value: Weather.pressure + " hPa"; icon: ""; iconColor: colors.success }
    }

    // ==========================================
    // 4. الفلك (Astronomy)
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 110
        color: colors.secondary.alpha(0.1)
        radius: root.cardRadius
        border.color: colors.leftMenuFgColorV1.alpha(0.05)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20 // هوامش مريحة جداً
            spacing: 0
            
            AstroCard { Layout.fillWidth: true; title: "Sunrise"; time: Weather.sunrise; icon: ""; iconColor: colors.warning }
            
            // فاصل عمودي
            Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: colors.leftMenuFgColorV1.alpha(0.1); Layout.margins: 10 }
            
            AstroCard { Layout.fillWidth: true; title: "Sunset"; time: Weather.sunset; icon: ""; iconColor: colors.error }
            
            // فاصل عمودي
            Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: colors.leftMenuFgColorV1.alpha(0.1); Layout.margins: 10 }
            
            AstroCard { Layout.fillWidth: true; title: "Moon"; time: Weather.moonPhase; icon: ""; iconColor: colors.primary }
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
        implicitHeight: 110 // ارتفاع مريح
        
        color: colors.topbarBgColorV1.alpha(0.5)
        radius: root.cardRadius
        border.color: colors.leftMenuFgColorV1.alpha(0.05)
        border.width: 1

        // استخدام ColumnLayout مع هوامش داخلية لحل مشكلة الالتصاق
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14 // الهامش السحري لحل مشكلة الالتصاق
            spacing: 6
            
            // الأيقونة في الزاوية العلوية
            RowLayout {
                Layout.fillWidth: true
                Text { 
                    text: icon
                    font.pixelSize: 22
                    font.family: typo.iconFont
                    color: iconColor
                }
                Item { Layout.fillWidth: true } // دفع الأيقونة لليسار
            }
            
            // القيمة في المنتصف/الأسفل
            Text { 
                text: value
                font.pixelSize: 20
                font.bold: true
                color: colors.leftMenuFgColorV1
            }
            
            // العنوان في الأسفل
            Text { 
                text: title
                font.pixelSize: 12
                color: colors.subtleText
            }
            
            Text { 
                visible: subtitle !== ""
                text: subtitle
                font.pixelSize: 11
                color: colors.primary
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
            color: colors.leftMenuFgColorV1
            Layout.alignment: Qt.AlignHCenter 
        }
        Text { 
            text: title
            font.pixelSize: 12
            color: colors.subtleText
            Layout.alignment: Qt.AlignHCenter 
        }
    }
}
