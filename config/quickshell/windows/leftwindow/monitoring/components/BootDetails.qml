// windows/leftwindow/monitoring/components/BootDetails.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/services"
import "root:/config"

Item {
    id: bootRoot
    property var theme
    property bool isOpen: false

    Layout.fillWidth: true
    Layout.preferredHeight: isOpen ? mainLayout.implicitHeight + 30 : 0
    clip: true

    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: 350
            easing.type: Easing.InOutQuint
        }
    }

    // الألوان بناءً على حالة الـ AI
    readonly property color themeStatusColor: {
        var s = SystemService.bootStatusColor; // سيتحسس QML أي تغيير هنا
        if (!s || s === "")
            return bootRoot.theme.colors.tertiary;
        if (s.startsWith("#"))
            return s;
        if (s === "red")
            return bootRoot.theme.colors.error;
        if (s === "orange" || s === "yellow")
            return bootRoot.theme.colors.secondary;
        if (s === "green")
            return bootRoot.theme.colors.tertiary;
        return bootRoot.theme.colors.info || bootRoot.theme.colors.primary;
    }

    readonly property color statusBgColor: Qt.rgba(themeStatusColor.r, themeStatusColor.g, themeStatusColor.b, bootRoot.theme.systemSettings.themeMode == "dark" ? 0.18 : 0.12)
    readonly property color statusBorderColor: Qt.rgba(themeStatusColor.r, themeStatusColor.g, themeStatusColor.b, bootRoot.theme.systemSettings.themeMode == "dark" ? 0.35 : 0.25)
    readonly property color statusTitleColor: bootRoot.theme.systemSettings.themeMode == "dark" ? themeStatusColor.lighter(1.25) : themeStatusColor.darker(1.6)
    readonly property color statusTextColor: bootRoot.theme.colors.onSurface
    readonly property color statusMutedColor: Qt.rgba(statusTitleColor.r, statusTitleColor.g, statusTitleColor.b, 0.85)

    Rectangle {
        anchors.fill: parent
        color: bootRoot.theme.systemSettings.themeMode == "dark" ? bootRoot.theme.colors.surfaceContainerHigh.lighter(1.3) : bootRoot.theme.colors.surfaceContainerHigh.darker(1.1)
    }

    ColumnLayout {
        id: mainLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 15

        opacity: bootRoot.height > 20 ? 1 : 0
        visible: opacity > 0

        // --- Box Summary ---
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: summaryRow.implicitHeight + 20
            color: bootRoot.statusBgColor
            border.color: bootRoot.statusBorderColor
            radius: bootRoot.theme.dimensions.shapeSmall

            RowLayout {
                id: summaryRow
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12
                Text {
                    text: SystemService.bootStatusIcon || ""
                    font.family: bootRoot.theme.typography.iconFont
                    font.pixelSize: 22
                    color: bootRoot.statusTitleColor
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: SystemService.bootStatusTitle || "Analyzing..."
                        color: bootRoot.statusTitleColor
                        font.bold: true
                        font.pixelSize: bootRoot.theme.typography.small
                    }
                    Text {
                        Layout.fillWidth: true
                        text: SystemService.aiBootSummary || "Waiting for system logs analysis..."
                        color: bootRoot.statusTextColor
                        font.pixelSize: bootRoot.theme.typography.small - 1
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // --- Expandable Log Cards ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: SystemService.bootLogsModel
                delegate: Item {
                    id: logDelegate
                    property bool isExpanded: false

                    Layout.fillWidth: true
                    implicitHeight: collapsedRow.implicitHeight + (isExpanded ? expandedBox.implicitHeight + 12 : 0) + 12
                    clip: true

                    Behavior on implicitHeight {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }

                    // Card background
                    Rectangle {
                        anchors.fill: parent
                        radius: bootRoot.theme.dimensions.shapeExtraSmall
                        color: {
                            if (isExpanded && bootRoot.themeStatusColor) {
                                var c = bootRoot.themeStatusColor;
                                return Qt.rgba(c.r, c.g, c.b, bootRoot.theme.systemSettings.themeMode == "dark" ? 0.15 : 0.08);
                            }
                            return logHover.containsMouse
                                ? bootRoot.theme.colors.onSurface.alpha(0.04)
                                : "transparent";
                        }
                        border.color: isExpanded ? Qt.rgba(bootRoot.themeStatusColor.r, bootRoot.themeStatusColor.g, bootRoot.themeStatusColor.b, 0.25) : "transparent"
                        border.width: isExpanded ? 1 : 0

                        Behavior on color {
                            ColorAnimation { duration: 250 }
                        }
                    }

                    ColumnLayout {
                        id: logCardLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 6
                        spacing: 6

                        // --- Collapsed Row (always visible) ---
                        RowLayout {
                            id: collapsedRow
                            Layout.fillWidth: true
                            spacing: 8

                            // Expand/collapse arrow icon
                            Text {
                                Layout.alignment: Qt.AlignTop
                                Layout.topMargin: 2
                                text: logDelegate.isExpanded ? "" : ""
                                font.family: bootRoot.theme.typography.iconFont
                                font.pixelSize: 12
                                color: bootRoot.statusMutedColor

                                Behavior on text {
                                    SequentialAnimation {
                                        PropertyAction {} // force initial
                                    }
                                }
                            }

                            // Summary text
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    id: processName
                                    Layout.fillWidth: true
                                    text: `<b>${modelData.process}</b>`
                                    color: bootRoot.theme.colors.onSurfaceVariant
                                    font.family: "Monospace"
                                    font.pixelSize: bootRoot.theme.typography.small - 2
                                    elide: Text.ElideRight
                                }
                                Text {
                                    id: shortMessage
                                    Layout.fillWidth: true
                                    text: modelData.message || ""
                                    color: bootRoot.theme.colors.onSurfaceVariant
                                    font.pixelSize: bootRoot.theme.typography.small - 3
                                    font.family: "Monospace"
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: logDelegate.isExpanded ? 100 : 2
                                    elide: Text.ElideRight
                                    opacity: logDelegate.isExpanded ? 0.6 : 1.0
                                }
                            }

                            // Smart copy button
                            Rectangle {
                                width: 26
                                height: 26
                                radius: bootRoot.theme.dimensions.shapeMedium
                                color: copyMouse.containsMouse ? bootRoot.theme.colors.onSurface.alpha(0.1) : "transparent"
                                Layout.alignment: Qt.AlignTop

                                Text {
                                    id: copyIcon
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: bootRoot.theme.typography.iconFont
                                    color: bootRoot.statusMutedColor
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: copyMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var txt;
                                        if (logDelegate.isExpanded && modelData.raw_details) {
                                            txt = modelData.raw_details;
                                        } else {
                                            txt = modelData.process + ": " + (modelData.message || "");
                                        }
                                        App.dispatchCommand("Copy Log", ["wl-copy", `'${txt}'`]);
                                        copyIcon.text = "";
                                        copyResetTimer.start();
                                    }
                                }
                                Timer {
                                    id: copyResetTimer
                                    interval: 1500
                                    onTriggered: copyIcon.text = ""
                                }
                            }
                        }

                        // --- Expanded Raw Details Box (animated) ---
                        Rectangle {
                            id: expandedBox
                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            implicitHeight: rawLogText.implicitHeight + 14
                            radius: bootRoot.theme.dimensions.shapeExtraSmall
                            visible: logDelegate.isExpanded
                            opacity: logDelegate.isExpanded ? 1 : 0
                            color: bootRoot.theme.colors.surface.alpha(bootRoot.theme.systemSettings.themeMode == "dark" ? 0.35 : 0.06)

                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }

                            TextEdit {
                                id: rawLogText
                                anchors.fill: parent
                                anchors.margins: 7
                                text: modelData.raw_details || modelData.time + " " + modelData.process + ": " + (modelData.message || "")
                                color: bootRoot.theme.colors.onSurfaceVariant
                                font.family: "Monospace"
                                font.pixelSize: bootRoot.theme.typography.small - 2
                                wrapMode: TextEdit.Wrap
                                selectByMouse: true
                                readOnly: true
                                selectionColor: bootRoot.themeStatusColor
                                selectedTextColor: bootRoot.theme.colors.onPrimary
                            }
                        }
                    }

                    // Click to expand/collapse
                    MouseArea {
                        id: logHover
                        z: -1
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton
                        onClicked: logDelegate.isExpanded = !logDelegate.isExpanded
                    }
                }
            }
        }
    }
}
