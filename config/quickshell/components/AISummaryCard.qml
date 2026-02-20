// components/AISummaryCard.qml

import QtQuick
import QtQuick.Layouts
import "root:/themes"
import "root:/components"

Item {
    id: root

    // ==========================================
    // الخصائص العامة
    // ==========================================
    property string title: "ملخص الذكاء الاصطناعي"
    property string summaryText: ""
    property string footerText: ""
    property string iconText: "✨"
    property bool isLoading: false

    // ==========================================
    // خصائص الأزرار (أيقونات قابلة للتخصيص مع مسميات Data و AI)
    // ==========================================
    property bool showDataRefreshButton: true
    property string dataIcon: "󰑓" // أيقونة زر البيانات (افتراضياً: تحديث)

    property bool showAiRefreshButton: true
    property string aiIcon: "󰚩" // أيقونة زر الذكاء الاصطناعي (افتراضياً: روبوت)

    signal refreshDataClicked
    signal refreshAiClicked

    // ==========================================
    // المحتوى المخصص (العلوي والسفلي)
    // ==========================================
    default property alias topContent: topContainer.data
    property alias bottomContent: bottomContainer.data

    implicitHeight: mainCard.height
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutQuart
        }
    }

    // ==========================================
    // الألوان والسمات (عصرية وأنيقة)
    // ==========================================
    readonly property var theme: ThemeManager.selectedTheme
    readonly property var dim: theme.dimensions
    readonly property bool isDark: theme.systemSettings.themeMode === "dark"

    readonly property color aiBgTop: isDark ? "#27272A" : "#FFFFFF"
    readonly property color aiBgBottom: isDark ? "#18181B" : "#F8FAFC"
    readonly property color aiBorderColor: isDark ? "#3F3F46" : "#E2E8F0"
    readonly property color aiAccentColor: isDark ? "#A5B4FC" : "#6366F1"
    readonly property color aiTextColor: isDark ? "#F8FAFC" : "#0F172A"
    readonly property color aiSubTextColor: isDark ? "#A1A1AA" : "#64748B"
    readonly property color aiHeaderBg: isDark ? "#1E1B4B" : "#EEF2FF"
    readonly property color aiButtonBg: isDark ? "#27272A" : "#F1F5F9"
    readonly property color aiButtonHover: isDark ? "#3F3F46" : "#E2E8F0"
    readonly property color aiDivider: isDark ? "#3F3F46" : "#E2E8F0"

    Rectangle {
        id: mainCard
        width: parent.width
        height: contentLayout.implicitHeight + (dim.menuWidgetsMargin * 2)
        radius: dim.elementRadius + 4

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: root.aiBgTop
            }
            GradientStop {
                position: 1.0
                color: root.aiBgBottom
            }
        }

        border.color: Qt.rgba(root.aiBorderColor.r, root.aiBorderColor.g, root.aiBorderColor.b, 0.6)
        border.width: 1

        layer.enabled: true
        layer.effect: Shadow {
            alpha: isDark ? 0.4 : 0.08
            radius: 16
        }

        // تأثير إضاءة علوي خفيف
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 40
            radius: mainCard.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: root.aiAccentColor
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
            opacity: isDark ? 0.08 : 0.04
        }

        ColumnLayout {
            id: contentLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: dim.menuWidgetsMargin + 4
            spacing: 12

            // 1. المحتوى العلوي المخصص
            Item {
                id: topContainer
                Layout.fillWidth: true
                implicitHeight: childrenRect.height
                visible: children.length > 0
            }

            // فاصل
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.aiDivider
                opacity: 0.5
                visible: topContainer.visible && (root.title !== "" || root.summaryText !== "")
            }

            // 2. هيدر البطاقة مع الأزرار
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: root.title !== ""

                Rectangle {
                    id: headerChip
                    radius: height / 2
                    color: root.aiHeaderBg
                    border.color: root.aiBorderColor
                    border.width: 1
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: headerRow.implicitWidth + 24

                    RowLayout {
                        id: headerRow
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: root.iconText
                            font.pixelSize: 16
                            color: root.aiAccentColor
                            font.family: theme.typography.iconFont
                            RotationAnimation on rotation {
                                loops: Animation.Infinite
                                from: 0
                                to: 360
                                duration: 1500
                                running: root.isLoading
                            }
                        }

                        Text {
                            text: root.title
                            font.family: theme.typography.bodyFont
                            font.pixelSize: theme.typography.small
                            font.weight: Font.DemiBold
                            color: root.aiAccentColor
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                } // مسافة

                // زر الـ Data
                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: dataMouseArea.containsMouse ? root.aiButtonHover : root.aiButtonBg
                    visible: root.showDataRefreshButton
                    scale: dataMouseArea.pressed ? 0.92 : 1.0
                    border.color: root.aiBorderColor
                    border.width: 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutQuad
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.dataIcon
                        font.pixelSize: 14
                        font.family: theme.typography.iconFont
                        color: root.aiSubTextColor
                    }
                    MouseArea {
                        id: dataMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.refreshDataClicked()
                    }
                }

                // زر الـ AI
                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: aiMouseArea.containsMouse ? root.aiButtonHover : root.aiButtonBg
                    visible: root.showAiRefreshButton
                    scale: aiMouseArea.pressed ? 0.92 : 1.0
                    border.color: root.aiBorderColor
                    border.width: 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutQuad
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.aiIcon
                        font.pixelSize: 15
                        font.family: theme.typography.iconFont
                        color: root.aiAccentColor
                    }
                    MouseArea {
                        id: aiMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.refreshAiClicked()
                    }
                }
            }

            // 3. نص الملخص
            Text {
                visible: root.summaryText !== ""
                text: root.summaryText
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: root.aiTextColor
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                lineHeight: 1.6
                opacity: root.isLoading ? 0.4 : 1.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // 4. نص التذييل (Footer)
            Text {
                visible: root.footerText !== ""
                text: root.footerText
                font.family: theme.typography.bodyFont
                font.pixelSize: 11
                color: root.aiSubTextColor
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                Layout.topMargin: 4
            }

            // 5. المحتوى السفلي المخصص
            Item {
                id: bottomContainer
                Layout.fillWidth: true
                implicitHeight: childrenRect.height
                visible: children.length > 0
                Layout.topMargin: children.length > 0 ? 4 : 0
            }
        }
    }
}
