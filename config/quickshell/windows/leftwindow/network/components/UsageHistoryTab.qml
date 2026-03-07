import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"

ColumnLayout {
    id: root

    property var historyUsageModel
    property bool historyUsageLoading: false
    property string historyUsageTotal: "..."
    property string historyUsagePeak: "..."
    property string historyUsageSamples: "..."
    property int maxVisibleRows: 8

    property int innerRadiusDiv: 4
    property int groupRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    Layout.fillWidth: true
    spacing: 6

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 44
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: ThemeManager.selectedTheme.colors.primary.alpha(0.12)
        border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.28)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            Label {
                text: `${qsTr("Total")}: ${root.historyUsageTotal}`
                Layout.fillWidth: true
                font.bold: true
            }
            Label {
                text: `${qsTr("Peak")}: ${root.historyUsagePeak}`
            }
            Label {
                text: `${qsTr("Samples")}: ${root.historyUsageSamples}`
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: qsTr("Application")
            font.bold: true
        }
        Label {
            text: qsTr("Total")
            font.bold: true
        }
        Label {
            text: qsTr("Peak")
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
        visible: root.historyUsageModel && root.historyUsageModel.count > 0

        Repeater {
            model: root.historyUsageModel ? Math.min(root.historyUsageModel.count, root.maxVisibleRows) : 0

            delegate: Rectangle {
                required property int index
                readonly property var rowData: root.historyUsageModel.get(index)

                Layout.fillWidth: true
                implicitHeight: 44
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2.alpha(0.35)
                border.color: ThemeManager.selectedTheme.colors.leftMenuFgColorV2.alpha(0.1)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 4

                    Label {
                        Layout.fillWidth: true
                        text: rowData.display_name
                        font.bold: true
                        elide: Text.ElideRight
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
                            color: ThemeManager.selectedTheme.colors.primary
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 84
                        Layout.preferredHeight: 30
                        color: ThemeManager.selectedTheme.colors.leftMenuBgColorV3.alpha(0.45)

                        topRightRadius: root.groupRadius
                        bottomRightRadius: root.groupRadius
                        topLeftRadius: root.groupRadius / root.innerRadiusDiv
                        bottomLeftRadius: root.groupRadius / root.innerRadiusDiv

                        Label {
                            anchors.centerIn: parent
                            text: rowData.peak_text
                        }
                    }
                }
            }
        }
    }

    Label {
        Layout.fillWidth: true
        visible: !root.historyUsageModel || root.historyUsageModel.count === 0
        text: root.historyUsageLoading ? qsTr("Reading usage history...") : qsTr("No history found yet.")
        horizontalAlignment: Text.AlignHCenter
        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV2.alpha(0.75)
        wrapMode: Text.Wrap
    }
}
