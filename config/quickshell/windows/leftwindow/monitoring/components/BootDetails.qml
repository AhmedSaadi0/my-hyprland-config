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
            return bootRoot.theme.colors.success;
        if (s.startsWith("#"))
            return s;
        if (s === "red")
            return bootRoot.theme.colors.error;
        if (s === "orange" || s === "yellow")
            return bootRoot.theme.colors.warning;
        if (s === "green")
            return bootRoot.theme.colors.success;
        return bootRoot.theme.colors.info || bootRoot.theme.colors.primary;
    }

    readonly property color statusBgColor: Qt.rgba(themeStatusColor.r, themeStatusColor.g, themeStatusColor.b, bootRoot.theme.systemSettings.themeMode == "dark" ? 0.18 : 0.12)
    readonly property color statusBorderColor: Qt.rgba(themeStatusColor.r, themeStatusColor.g, themeStatusColor.b, bootRoot.theme.systemSettings.themeMode == "dark" ? 0.35 : 0.25)
    readonly property color statusTitleColor: bootRoot.theme.systemSettings.themeMode == "dark" ? themeStatusColor.lighter(1.25) : themeStatusColor.darker(1.6)
    readonly property color statusTextColor: bootRoot.theme.colors.leftMenuFgColorV1
    readonly property color statusMutedColor: Qt.rgba(statusTitleColor.r, statusTitleColor.g, statusTitleColor.b, 0.85)

    Rectangle {
        anchors.fill: parent
        color: bootRoot.theme.systemSettings.themeMode == "dark" ? bootRoot.theme.colors.leftMenuBgColorV2.lighter(1.3) : bootRoot.theme.colors.leftMenuBgColorV2.darker(1.1)
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
            radius: 8

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

        // --- Logs List ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: SystemService.bootLogsModel
                delegate: Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: logRow.implicitHeight + 10
                    color: logMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.03) : "transparent"
                    radius: 4

                    RowLayout {
                        id: logRow
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignTop
                            Layout.topMargin: 2
                            text: ""
                            font.family: bootRoot.theme.typography.iconFont
                            color: bootRoot.statusMutedColor
                        }

                        Text {
                            id: logContent
                            Layout.fillWidth: true
                            text: `<b>${modelData.process}:</b> ${modelData.message}`
                            color: bootRoot.theme.colors.leftMenuFgColorV2
                            font.family: "Monospace"
                            font.pixelSize: bootRoot.theme.typography.small - 2
                            wrapMode: Text.WordWrap
                        }

                        // زر النسخ
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: copyMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
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
                                    var txt = modelData.process + ": " + modelData.message;
                                    console.info("txt -> " + txt);
                                    App.dispatchCommand("Copy Log", ["wl-copy", `'${txt}'`]);
                                    copyIcon.text = "";
                                    resetTimer.start();
                                }
                            }
                            Timer {
                                id: resetTimer
                                interval: 1500
                                onTriggered: copyIcon.text = ""
                            }
                        }
                    }
                    MouseArea {
                        id: logMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }
    }
}
