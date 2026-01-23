import QtQuick.Layouts
import QtQuick

import "root:/components/monitors"
import "root:/themes"
import "root:/services"
import "root:/components"

RowLayout {
    spacing: 8

    // 1. تنسيق النص الرقمي
    component ValueLabel: Text {
        color: ThemeManager.selectedTheme.colors.primary
        font.family: ThemeManager.selectedTheme.typography.fontFamily
        font.pixelSize: 12
        font.bold: true
        Layout.alignment: Qt.AlignVCenter
    }

    // 2. شكل الفاصل العمودي
    component VerticalDivider: Rectangle {
        width: 1
        height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight / 1.9
        color: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 2
        Layout.rightMargin: 2
    }

    // --- 1. Temperature ---
    Row {
        spacing: 5
        Layout.alignment: Qt.AlignVCenter
        Tempreture {
            id: tempMonitor
            iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        }
        ValueLabel {
            // إضافة Math.round هنا لإزالة الفواصل
            text: Math.round(tempMonitor.value * 100) + "°C"
            color: tempMonitor.fgNormal
        }
    }

    VerticalDivider {
        Layout.alignment: Qt.AlignVCenter
    }

    // --- 2. Battery ---
    Row {
        spacing: 5
        Layout.alignment: Qt.AlignVCenter
        Battery {
            id: batteryMonitor
            glowIcon: false
            iconColor: ThemeManager.selectedTheme.colors.primary
            iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
            backgroundColor: ThemeManager.selectedTheme.colors.primary.alpha(0.2)
            foregroundColor: ThemeManager.selectedTheme.colors.primary
        }
        ValueLabel {
            text: Math.round(batteryMonitor.value * 100) + "%"
        }
    }

    VerticalDivider {
        Layout.alignment: Qt.AlignVCenter
    }

    // --- 3. RAM ---
    Row {
        spacing: 5
        Layout.alignment: Qt.AlignVCenter
        Ram {
            id: ramMonitor
            iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        }
        ValueLabel {
            text: Math.round(ramMonitor.value * 100) + "%"
            color: ramMonitor.fgNormal
        }
    }

    VerticalDivider {
        Layout.alignment: Qt.AlignVCenter
    }

    // --- 4. CPU ---
    Row {
        spacing: 5
        Layout.alignment: Qt.AlignVCenter
        Cpu {
            id: cpuMonitor
            iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        }
        ValueLabel {
            text: Math.round(cpuMonitor.value * 100) + "%"
            color: cpuMonitor.fgNormal
        }
    }
}
