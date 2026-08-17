// windows/leftwindow/monitoring/components/EventAnalysis.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

ColumnLayout {
    id: root

    property bool isExpanded: false
    property bool isLoading: false
    property string aiTitle: ""
    property int aiConfidence: 0
    property string aiNarrative: ""
    property string aiRootCause: ""
    property string aiProcessName: ""
    property string aiProcessBehavior: ""
    property string aiThermalRisk: ""
    property string aiThermalDetails: ""
    property var actionsModel: []

    readonly property var theme: ThemeManager.selectedTheme

    // ألوان مقروءة: تُعمَّق في الوضع الفاتح
    readonly property color accentTertiary: theme.systemSettings.themeMode == "dark" ? theme.colors.tertiary : theme.colors.tertiary.darker(1.6)
    readonly property color accentSecondary: theme.systemSettings.themeMode == "dark" ? theme.colors.secondary : theme.colors.secondary.darker(1.6)
    readonly property color narrativeColor: theme.systemSettings.themeMode == "dark" ? Qt.lighter(theme.colors.onSurfaceVariant, 1.4) : theme.colors.onSurfaceVariant.darker(1.2)
    readonly property color actionTextColor: theme.systemSettings.themeMode == "dark" ? Qt.lighter(theme.colors.onSurfaceVariant, 1.3) : theme.colors.onSurfaceVariant.darker(1.1)

    Layout.fillWidth: true
    visible: opacity > 0
    opacity: isExpanded ? 1 : 0
    Layout.preferredHeight: isExpanded ? -1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 300
        }
    }

    Item {
        Layout.preferredHeight: 12
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Qt.rgba(theme.colors.onSurfaceVariant.r, theme.colors.onSurfaceVariant.g, theme.colors.onSurfaceVariant.b, 0.12)
    }

    Item {
        Layout.preferredHeight: 12
    }

    // --- العنوان والثقة ---
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: ""
            font.family: theme.typography.iconFont
            color: root.accentTertiary
            font.pixelSize: 16
        }

        Text {
            text: isLoading ? qsTr("Analyzing...") : aiTitle
            font.pixelSize: theme.typography.small + 2
            font.bold: true
            color: root.accentSecondary
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Rectangle {
            visible: !isLoading && aiConfidence > 0
            width: 64
            height: 10
            radius: theme.dimensions.shapeSmall
            color: Qt.rgba(theme.colors.primary.r, theme.colors.primary.g, theme.colors.primary.b, 0.18)
            border.color: theme.colors.primary
            border.width: 1

            Rectangle {
                width: (aiConfidence / 100) * parent.width
                height: parent.height
                radius: theme.dimensions.shapeSmall
                color: theme.colors.primary
            }

            Text {
                anchors.centerIn: parent
                text: aiConfidence + "%"
                font.pixelSize: 9
                font.bold: true
                color: theme.colors.primary
                z: 1
            }
        }
    }

    Item {
        Layout.preferredHeight: 10
    }

    // --- السرد التحليلي ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: qsTr("Forensic Analysis")
            font.pixelSize: theme.typography.small - 1
            font.bold: true
            color: theme.colors.onSurfaceVariant
            opacity: 0.7
        }

        Text {
            Layout.fillWidth: true
            text: isLoading ? qsTr("Gathering data from system logs...") : aiNarrative
            wrapMode: Text.WordWrap
            font.family: theme.typography.bodyFont
            font.pixelSize: theme.typography.small + 1
            color: root.narrativeColor
            lineHeight: 1.3
            textFormat: Text.PlainText
        }
    }

    Item {
        Layout.preferredHeight: 12
    }

    // --- السبب الجذري + العملية + التأثير الحراري (لوحة موحدة) ---
    EventInsightPanel {
        Layout.fillWidth: true
        isLoading: root.isLoading
        rootCause: root.aiRootCause
        processName: root.aiProcessName
        processBehavior: root.aiProcessBehavior
        thermalRisk: root.aiThermalRisk
        thermalDetails: root.aiThermalDetails
    }

    Item {
        Layout.preferredHeight: 12
    }

    // --- الإجراءات المقترحة ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: qsTr("Recommended Actions")
            font.pixelSize: theme.typography.small - 1
            font.bold: true
            color: root.accentTertiary
        }

        Repeater {
            model: isLoading ? [] : actionsModel

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 18
                    height: 18
                    radius: theme.dimensions.shapeSmall
                    color: Qt.rgba(root.accentTertiary.r, root.accentTertiary.g, root.accentTertiary.b, 0.18)
                    border.color: root.accentTertiary
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        font.pixelSize: 11
                        color: root.accentTertiary
                        font.bold: true
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: modelData
                    wrapMode: Text.WordWrap
                    font.pixelSize: theme.typography.small + 1
                    color: root.actionTextColor
                    textFormat: Text.PlainText
                }
            }
        }

        Text {
            visible: isLoading || actionsModel.length === 0
            text: isLoading ? qsTr("Generating recommendations...") : qsTr("No specific actions required.")
            font.pixelSize: theme.typography.small
            color: theme.colors.onSurfaceVariant
            opacity: 0.7
        }
    }

    Item {
        Layout.preferredHeight: 8
    }
}
