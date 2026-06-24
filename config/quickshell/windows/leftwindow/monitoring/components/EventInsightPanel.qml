// windows/leftwindow/monitoring/components/EventInsightPanel.qml

import QtQuick
import QtQuick.Layouts
import "root:/themes"

Rectangle {
    id: root

    property bool isLoading: false
    property string rootCause: ""
    property string processName: ""
    property string processBehavior: ""
    property string thermalRisk: ""
    property string thermalDetails: ""

    readonly property var theme: ThemeManager.selectedTheme

    radius: theme.dimensions.elementRadius
    color: Qt.rgba(theme.colors.surfaceContainerHigh.r, theme.colors.surfaceContainerHigh.g, theme.colors.surfaceContainerHigh.b, 0.75)
    border.color: Qt.rgba(theme.colors.onSurfaceVariant.r, theme.colors.onSurfaceVariant.g, theme.colors.onSurfaceVariant.b, 0.22)
    border.width: 1
    clip: true

    implicitHeight: contentLayout.implicitHeight + 20

    function riskColor() {
        if (thermalRisk === "high")
            return theme.colors.error;
        if (thermalRisk === "medium")
            return theme.colors.secondary;
        return theme.colors.tertiary;
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Root Cause
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 3
                Layout.fillHeight: true
                radius: 2
                color: theme.colors.secondary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text {
                        text: ""
                        font.family: theme.typography.iconFont
                        font.pixelSize: 14
                        color: theme.colors.secondary
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Root Cause")
                        font.family: theme.typography.bodyFont
                        font.pixelSize: theme.typography.small + 1
                        font.bold: true
                        color: theme.colors.secondary
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: isLoading ? "..." : rootCause
                    wrapMode: Text.WordWrap
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small + 1
                    color: theme.colors.onSurfaceVariant
                    lineHeight: 1.25
                    textFormat: Text.PlainText
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(theme.colors.onSurfaceVariant.r, theme.colors.onSurfaceVariant.g, theme.colors.onSurfaceVariant.b, 0.12)
        }

        // Process
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 3
                Layout.fillHeight: true
                radius: 2
                color: theme.colors.tertiary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text {
                        text: ""
                        font.family: theme.typography.iconFont
                        font.pixelSize: 14
                        color: theme.colors.tertiary
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Process")
                        font.family: theme.typography.bodyFont
                        font.pixelSize: theme.typography.small + 1
                        font.bold: true
                        color: theme.colors.secondary
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: isLoading ? "..." : processName
                    wrapMode: Text.WordWrap
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small + 1
                    font.bold: true
                    color: theme.colors.onSurfaceVariant
                    textFormat: Text.PlainText
                }

                Text {
                    visible: processBehavior !== ""
                    Layout.fillWidth: true
                    text: isLoading ? "" : processBehavior
                    wrapMode: Text.WordWrap
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.onSurfaceVariant
                    opacity: 0.85
                    lineHeight: 1.2
                    textFormat: Text.PlainText
                }
            }
        }

        Rectangle {
            visible: thermalRisk !== ""
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(theme.colors.onSurfaceVariant.r, theme.colors.onSurfaceVariant.g, theme.colors.onSurfaceVariant.b, 0.12)
        }

        // Thermal Impact
        RowLayout {
            visible: thermalRisk !== ""
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 3
                Layout.fillHeight: true
                radius: 2
                color: riskColor()
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: ""
                        font.family: theme.typography.iconFont
                        font.pixelSize: 14
                        color: riskColor()
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Thermal Impact")
                        font.family: theme.typography.bodyFont
                        font.pixelSize: theme.typography.small + 1
                        font.bold: true
                        color: theme.colors.secondary
                    }

                    Rectangle {
                        height: 18
                        radius: theme.dimensions.shapeSmall
                        color: Qt.rgba(riskColor().r, riskColor().g, riskColor().b, 0.2)
                        border.color: riskColor()
                        border.width: 1
                        Layout.preferredWidth: thermalRisk.length > 6 ? 76 : 60
                        Text {
                            anchors.centerIn: parent
                            text: thermalRisk.toUpperCase()
                            font.pixelSize: 9
                            font.bold: true
                            color: riskColor()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: isLoading ? "" : thermalDetails
                    wrapMode: Text.WordWrap
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small + 1
                    color: theme.colors.onSurfaceVariant
                    lineHeight: 1.25
                    textFormat: Text.PlainText
                }
            }
        }
    }
}
