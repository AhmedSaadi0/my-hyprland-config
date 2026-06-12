// windows/leftwindow/network/DataUsageHeader.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"
import "root:/components"
import "../base"
import "./components"
import "root:/config/ConstValues.js" as Consts

HeaderCard {
    id: root

    property string subtitle: qsTr("Loading data...")
    property string receivedData: "..."
    property string sentData: "..."
    property string totalData: "..."
    property string dailyReceivedData: "..."
    property string dailySentData: "..."
    property string dailyTotalData: "..."

    property var liveUsageModel
    property string liveUsageSubtitle: qsTr("Loading app usage...")
    property bool liveUsageLoading: false

    property var historyUsageModel
    property string historyUsageSubtitle: qsTr("Loading history...")
    property bool historyUsageLoading: false
    property string historyUsageTotal: "..."
    property string historyUsagePeak: "..."
    property string historyUsageSamples: "..."

    property int activeTab: 0 // 0:Data, 1:Live, 2:History
    property bool expanded: true
    property int maxVisibleLiveRows: 8
    property int maxVisibleHistoryRows: 8
    property int contentViewportHeight: 290
    property real expandedProgress: expanded ? 1.0 : 0.0
    property int innerRadiusDiv: 4
    property int groupRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    signal refreshRequested
    signal liveUsageRefreshRequested
    signal historyUsageRefreshRequested

    function currentSubtitle() {
        if (root.activeTab === 1)
            return root.liveUsageSubtitle;
        if (root.activeTab === 2)
            return root.historyUsageSubtitle;
        return root.subtitle;
    }

    Behavior on expandedProgress {
        NumberAnimation {
            duration: 320
            easing.type: Easing.InOutCubic
        }
    }

    onExpandedChanged: expandedProgress = expanded ? 1.0 : 0.0

    MenuCard {
        id: usageCard
        Layout.fillWidth: true
        cardColor: "transparent"
        heightAnimationDuration: 0

        title: qsTr("Network Insights")
        subtitle: root.currentSubtitle()
        icon: "󰑐"
        iconCursorShape: Qt.PointingHandCursor

        onIconClicked: {
            spinAnim.start();
            if (root.activeTab === 0)
                root.refreshRequested();
            else if (root.activeTab === 1)
                root.liveUsageRefreshRequested();
            else
                root.historyUsageRefreshRequested();
        }

        RotationAnimation on rotation {
            id: spinAnim
            target: usageCard.iconItem
            from: 0
            to: 360
            duration: 500
            easing.type: Easing.InOutCubic
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 4

            Repeater {
                model: [
                    {
                        title: qsTr("Data"),
                        idx: 0
                    },
                    {
                        title: qsTr("Live"),
                        idx: 1
                    },
                    {
                        title: qsTr("History"),
                        idx: 2
                    }
                ]

                delegate: MButton {
                    required property var modelData

                    Layout.fillWidth: true
                    text: modelData.title
                    isActive: root.activeTab === modelData.idx
                    normalBackground: ThemeManager.selectedTheme.colors.surfaceContainerHigh
                    activeBackground: ThemeManager.selectedTheme.colors.primary
                    normalForeground: ThemeManager.selectedTheme.colors.onSurface
                    activeForeground: ThemeManager.selectedTheme.colors.onPrimary
                    onClicked: root.activeTab = modelData.idx

                    topLeftRadius: modelData.idx === 0 ? root.groupRadius : root.groupRadius / root.innerRadiusDiv
                    bottomLeftRadius: modelData.idx === 0 ? root.groupRadius : root.groupRadius / root.innerRadiusDiv
                    topRightRadius: root.groupRadius / root.innerRadiusDiv
                    bottomRightRadius: root.groupRadius / root.innerRadiusDiv
                }
            }

            MButton {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 25
                text: root.expanded ? "󰅂" : "󰅀"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                textHorizontalAlignment: Text.AlignHCenter
                normalBackground: ThemeManager.selectedTheme.colors.surfaceContainerHigh
                normalForeground: ThemeManager.selectedTheme.colors.onSurface
                onClicked: root.expanded = !root.expanded

                topLeftRadius: root.groupRadius / root.innerRadiusDiv
                bottomLeftRadius: root.groupRadius / root.innerRadiusDiv
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            implicitHeight: Math.round(root.contentViewportHeight * root.expandedProgress)
            Layout.preferredHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
            clip: true

            Flickable {
                id: contentFlick
                anchors.fill: parent
                clip: true
                visible: true
                enabled: root.expandedProgress > 0.0
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                contentWidth: width
                contentHeight: scrollContent.implicitHeight

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }

                WheelHandler {
                    target: contentFlick
                    onWheel: function (event) {
                        if (!contentFlick.interactive) {
                            event.accepted = false;
                            return;
                        }

                        const delta = event.pixelDelta.y !== 0 ? event.pixelDelta.y : (event.angleDelta.y / 8);
                        const maxY = Math.max(0, contentFlick.contentHeight - contentFlick.height);
                        const nextY = Math.max(0, Math.min(maxY, contentFlick.contentY - delta));

                        if (nextY !== contentFlick.contentY) {
                            contentFlick.contentY = nextY;
                            event.accepted = true;
                            return;
                        }

                        event.accepted = false;
                    }
                }

                ColumnLayout {
                    id: scrollContent
                    width: contentFlick.width
                    spacing: 8

                    UsageDataTab {
                        Layout.fillWidth: true
                        visible: root.activeTab === 0
                        receivedData: root.receivedData
                        sentData: root.sentData
                        totalData: root.totalData
                        dailyReceivedData: root.dailyReceivedData
                        dailySentData: root.dailySentData
                        dailyTotalData: root.dailyTotalData
                    }

                    UsageLiveTab {
                        Layout.fillWidth: true
                        visible: root.activeTab === 1
                        liveUsageModel: root.liveUsageModel
                        liveUsageLoading: root.liveUsageLoading
                        maxVisibleRows: root.maxVisibleLiveRows
                    }

                    UsageHistoryTab {
                        Layout.fillWidth: true
                        visible: root.activeTab === 2
                        historyUsageModel: root.historyUsageModel
                        historyUsageLoading: root.historyUsageLoading
                        historyUsageTotal: root.historyUsageTotal
                        historyUsagePeak: root.historyUsagePeak
                        historyUsageSamples: root.historyUsageSamples
                        maxVisibleRows: root.maxVisibleHistoryRows
                    }
                }
            }
        }
    }
}
