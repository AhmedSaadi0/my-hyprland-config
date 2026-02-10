// windows/leftwindow/monitoring/EventDelegate.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "root:/themes"

Item {
    id: delegateRoot
    width: parent ? parent.width : 400
    // الارتفاع الكلي للعنصر يتبع ارتفاع الكرت
    height: contentContainer.height

    property string eventId
    property string eventType
    property string eventValue
    property string eventSeverity
    property string eventTime
    property string aiText
    property string aiModelName: "System AI"
    property bool isLoading: false
    property bool isExpanded: false

    signal expandRequested

    readonly property var theme: ThemeManager.selectedTheme
    property bool isCritical: eventSeverity === "CRITICAL"
    property color stateColor: {
        if (eventSeverity === "CRITICAL")
            return theme.colors.error;
        if (eventSeverity === "WARNING")
            return theme.colors.warning;
        return theme.colors.success;
    }

    // --- Timeline Line ---
    Rectangle {
        id: timelineLine
        width: 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: 28
        color: Qt.rgba(theme.colors.subtleText.r, theme.colors.subtleText.g, theme.colors.subtleText.b, 0.2)
        z: 1
    }

    // --- Timeline Dot ---
    Rectangle {
        id: timelineDot
        width: 14
        height: 14
        radius: theme.dimensions.elementRadius
        x: 22
        y: 22
        z: 5
        color: theme.colors.leftMenuBgColorV2
        border.width: 2
        border.color: stateColor
        layer.enabled: isCritical
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: stateColor
            shadowBlur: 0.5
            shadowOpacity: 0.6
        }
    }

    // --- Main Card Content ---
    Rectangle {
        id: contentContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 48
        anchors.rightMargin: 12

        // الحساب الدقيق للارتفاع: الارتفاع الضمني للمحتوى + الهوامش
        height: mainLayout.implicitHeight + 20

        // أنيميشن الارتفاع (يجعل الكرت ينزلق بسلاسة)
        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        color: isExpanded ? theme.colors.leftMenuBgColorV1 : Qt.rgba(theme.colors.leftMenuBgColorV1.r, theme.colors.leftMenuBgColorV1.g, theme.colors.leftMenuBgColorV1.b, 0.4)
        radius: theme.dimensions.elementRadius
        border.color: isExpanded ? theme.colors.primary : Qt.rgba(theme.colors.subtleText.r, theme.colors.subtleText.g, theme.colors.subtleText.b, 0.2)
        border.width: 1
        clip: true

        ColumnLayout {
            id: mainLayout
            // نستخدم anchors لربط العرض فقط، والارتفاع يُترك للـ implicitHeight
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            anchors.leftMargin: 14
            spacing: 0

            // 1. Header Row
            RowLayout {
                id: headerRow
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                spacing: 12

                // Icon Box
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: theme.dimensions.elementRadius
                    color: theme.colors.leftMenuBgColorV2
                    border.width: 1
                    border.color: Qt.rgba(theme.colors.subtleText.r, theme.colors.subtleText.g, theme.colors.subtleText.b, 0.1)
                    Text {
                        anchors.centerIn: parent
                        text: (eventType === "CPU") ? "" : (eventType === "RAM") ? "" : (eventType === "TEMP") ? "" : ""
                        font.family: theme.typography.iconFont
                        font.pixelSize: 16
                        color: stateColor
                    }
                }

                // Text Info (هذا الجزء يملأ المنتصف)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    RowLayout {
                        spacing: 8
                        Text {
                            text: eventType + " Spike"
                            color: theme.colors.secondary
                            font.family: theme.typography.bodyFont
                            font.pixelSize: theme.typography.small
                            font.bold: true
                        }
                        Rectangle {
                            visible: isCritical
                            width: 32
                            height: 14
                            radius: 2
                            color: Qt.rgba(theme.colors.error.r, theme.colors.error.g, theme.colors.error.b, 0.2)
                            Text {
                                anchors.centerIn: parent
                                text: "CRIT"
                                color: theme.colors.error
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                    }
                    Text {
                        text: "Value: <font color='" + theme.colors.secondary + "'>" + eventValue + "</font>"
                        color: theme.colors.subtleText
                        font.family: theme.typography.bodyFont
                        font.pixelSize: theme.typography.small - 1
                        textFormat: Text.StyledText
                    }
                }

                // Time and Expand Icon (مجبورين جهة اليمين)
                ColumnLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    spacing: 4

                    // To fill space
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        Layout.alignment: Qt.AlignRight
                        text: eventTime
                        color: theme.colors.subtleText
                        font.family: "Monospace"
                        font.pixelSize: theme.typography.small - 2
                    }
                    Text {
                        id: expandIcon
                        Layout.alignment: Qt.AlignRight
                        text: ""
                        font.family: theme.typography.iconFont
                        font.pixelSize: 14
                        color: isExpanded ? theme.colors.primary : theme.colors.subtleText
                        rotation: isExpanded ? 180 : 0
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 250
                            }
                        }
                    }
                }
            }

            // 2. AI Analysis Section (القسم القابل للتمدد)
            ColumnLayout {
                id: aiSection
                Layout.fillWidth: true

                // التحكم في الظهور: إذا لم يكن مفتوحاً، الارتفاع 0 والشفافية 0
                visible: opacity > 0
                opacity: isExpanded ? 1 : 0

                // منع العنصر من أخذ مساحة عند الإغلاق
                Layout.preferredHeight: isExpanded ? -1 : 0

                // أنيميشن الشفافية
                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                    }
                }

                Item {
                    Layout.preferredHeight: 12
                } // فاصل (Top Margin)

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Qt.rgba(theme.colors.subtleText.r, theme.colors.subtleText.g, theme.colors.subtleText.b, 0.1)
                }

                Item {
                    Layout.preferredHeight: 12
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Layout.alignment: Qt.AlignTop

                    Text {
                        text: ""
                        font.family: theme.typography.iconFont
                        color: theme.colors.tertiary
                        Layout.alignment: Qt.AlignTop
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "ANALYSIS REPORT"
                                font.pixelSize: 9
                                font.bold: true
                                color: theme.colors.tertiary
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            Text {
                                text: aiModelName
                                font.pixelSize: 8
                                color: theme.colors.subtleText
                            }
                        }

                        Text {
                            id: aiDescription
                            Layout.fillWidth: true
                            text: isLoading ? "Analyzing... Please wait." : aiText
                            wrapMode: Text.WordWrap
                            font.family: theme.typography.bodyFont
                            font.pixelSize: theme.typography.small - 1
                            color: Qt.lighter(theme.colors.subtleText, 1.4)
                            lineHeight: 1.2
                        }

                        Rectangle {
                            Layout.topMargin: 4
                            width: 85
                            height: 22
                            radius: theme.dimensions.elementRadius
                            color: Qt.rgba(theme.colors.tertiary.r, theme.colors.tertiary.g, theme.colors.tertiary.b, 0.1)
                            border.color: Qt.rgba(theme.colors.tertiary.r, theme.colors.tertiary.g, theme.colors.tertiary.b, 0.2)
                            Text {
                                anchors.centerIn: parent
                                text: isLoading ? "Analyzing" : "View Details"
                                font.pixelSize: 9
                                color: theme.colors.tertiary
                            }
                        }
                    }
                }
                // هامش سفلي للتأكد من عدم قص المحتوى
                Item {
                    Layout.preferredHeight: 8
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: delegateRoot.expandRequested()
        }
    }
}
