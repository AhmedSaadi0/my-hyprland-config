import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"

ColumnLayout {
    id: root

    property var liveUsageModel
    property bool liveUsageLoading: false
    property int maxVisibleRows: 8

    property int innerRadiusDiv: 4
    property int groupRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    Layout.fillWidth: true
    spacing: 6

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: qsTr("Application")
            font.bold: true
        }
        Label {
            text: qsTr("Rate")
            font.bold: true
        }
        Label {
            text: qsTr("Conn")
            font.bold: true
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV2.alpha(0.15)
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6
        visible: root.liveUsageModel && root.liveUsageModel.count > 0

        Repeater {
            model: root.liveUsageModel ? Math.min(root.liveUsageModel.count, root.maxVisibleRows) : 0

            delegate: Rectangle {
                required property int index
                readonly property var rowData: root.liveUsageModel.get(index)

                Layout.fillWidth: true
                implicitHeight: 48
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2.alpha(0.35)
                border.color: ThemeManager.selectedTheme.colors.leftMenuFgColorV2.alpha(0.1)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 4

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Label {
                            Layout.fillWidth: true
                            text: rowData.display_name
                            font.bold: true
                            elide: Text.ElideRight
                        }
                        Label {
                            Layout.fillWidth: true
                            text: `RX ${rowData.rx_text} | TX ${rowData.tx_text}`
                            font.pixelSize: ThemeManager.selectedTheme.typography.small
                            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV2.alpha(0.75)
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 96
                        Layout.preferredHeight: 30
                        color: ThemeManager.selectedTheme.colors.primary.alpha(0.12)
                        border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.28)
                        border.width: 1

                        topLeftRadius: root.groupRadius
                        bottomLeftRadius: root.groupRadius
                        topRightRadius: root.groupRadius / root.innerRadiusDiv
                        bottomRightRadius: root.groupRadius / root.innerRadiusDiv

                        Label {
                            anchors.centerIn: parent
                            text: rowData.total_text
                            font.bold: true
                            color: ThemeManager.selectedTheme.colors.primary
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 30
                        color: ThemeManager.selectedTheme.colors.leftMenuBgColorV3.alpha(0.45)

                        topRightRadius: root.groupRadius
                        bottomRightRadius: root.groupRadius
                        topLeftRadius: root.groupRadius / root.innerRadiusDiv
                        bottomLeftRadius: root.groupRadius / root.innerRadiusDiv

                        Label {
                            anchors.centerIn: parent
                            text: `${rowData.connections_count}`
                            font.bold: true
                        }
                    }
                }
            }
        }
    }

    Label {
        Layout.fillWidth: true
        visible: !root.liveUsageModel || root.liveUsageModel.count === 0
        text: root.liveUsageLoading ? qsTr("Reading live app usage...") : qsTr("No active app usage found.")
        horizontalAlignment: Text.AlignHCenter
        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV2.alpha(0.75)
        wrapMode: Text.Wrap
    }
}
