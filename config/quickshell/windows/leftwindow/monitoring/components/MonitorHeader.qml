import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import "root:/themes"
import "root:/components"

Item {
    id: headerRoot

    // --- Properties ---
    property var theme
    property string title: "AI System Analysis"
    property string statusText: "AI AGENT ACTIVE"
    property bool isDetailsOpen: false

    // تحديد إذا كان النظام في وضع الداكن
    readonly property bool isDarkMode: theme.systemSettings.themeMode === "dark"

    // ألوان ذكاء اصطناعي ديناميكية
    readonly property color aiColorStart: isDarkMode ? "#8E2DE2" : "#6A11CB" // بنفسجي تقني
    readonly property color aiColorEnd: isDarkMode ? "#4A00E0" : "#2575FC"   // أزرق عميق

    // --- Signals ---
    signal toggleDetailsClicked

    Layout.fillWidth: true
    Layout.preferredHeight: 64 // زيادة الطول قليلاً ليعطي فخامة أكثر

    // خلفية الهيدر
    Rectangle {
        anchors.fill: parent
        color: headerRoot.theme.colors.leftMenuBgColorV3
        opacity: isDarkMode ? 0.8 : 0.9

        radius: headerRoot.theme.dimensions.elementRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: headerRoot.theme.colors.leftMenuBgColorV3
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: headerRoot.theme.dimensions.spacingLarge * 1.5
        anchors.rightMargin: headerRoot.theme.dimensions.spacingLarge * 1.5
        spacing: headerRoot.theme.dimensions.spacingMedium

        // 1. AI Icon Container
        Rectangle {
            id: aiIconBox
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 10 // تصميم عصري أكثر دائرية

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: headerRoot.aiColorStart
                }
                GradientStop {
                    position: 1.0
                    color: headerRoot.aiColorEnd
                }
            }

            // تأثير توهج (Glow) للأيقونة لتبدو كالذكاء الاصطناعي
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: headerRoot.aiColorStart
                shadowBlur: 0.6
                shadowOpacity: isDarkMode ? 0.5 : 0.3
            }

            Text {
                anchors.centerIn: parent
                // أيقونة ذكاء اصطناعي (Brain/Circuit/Magic) من Nerd Fonts
                // يمكنك تجربة "󱚣" أو "󰧑" أو "󰭹"
                text: "󱚣"
                font.family: headerRoot.theme.typography.iconFont
                font.pixelSize: 22
                color: "#FFFFFF"
            }
        }

        // 2. Title & Status Section
        ColumnLayout {
            spacing: 2
            Text {
                text: headerRoot.title
                color: headerRoot.theme.colors.leftMenuFgColorV3
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            RowLayout {
                spacing: 6
                // نقطة الحالة النابضة (اختياري: يمكن إضافة Animation هنا)
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: headerRoot.theme.colors.success
                }
                Text {
                    text: headerRoot.statusText
                    color: headerRoot.theme.colors.leftMenuFgColorV3.alpha(0.8)
                    font.pixelSize: 11
                    font.letterSpacing: 1.1
                    font.weight: Font.DemiBold
                    // opacity: 0.8
                }
            }
        }

        // 3. Dynamic Spacer (هذا الجزء يضمن دفع الزر لليمين)
        Item {
            Layout.fillWidth: true
        }

        // 4. Terminal Toggle Button (الطرف الأيمن)
        MButton {
            id: terminalButton
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38

            text: ""
            cursorShape: Qt.PointingHandCursor
            font.family: ThemeManager.selectedTheme.typography.iconFont
            isActive: headerRoot.isDetailsOpen

            // // تخصي0 ديناميكي للألوان
            // normalBackground: "transparent"
            // hoveredBackground: Qt.rgba(headerRoot.theme.colors.subtleText.r, headerRoot.theme.colors.subtleText.g, headerRoot.theme.colors.subtleText.b, 0.1)
            // activeBackground: headerRoot.aiColorStart
            // activeForeground: "#FFFFFF"
            // normalForeground: headerRoot.theme.colors.subtleText

            // radius: 8

            onClicked: headerRoot.toggleDetailsClicked()

            // Tooltip (اختياري لتحسين تجربة المستخدم)
            ToolTip.visible: hovered
            ToolTip.text: "Open Terminal Logs"
            ToolTip.delay: 500
        }
    }
}
