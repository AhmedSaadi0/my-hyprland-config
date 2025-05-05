import Quickshell.Io

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// import QtQuick.Layouts

import "../themes"
import "../utils/helpers.js" as Helper

Rectangle {
    id: netspeedToolbarWidget

    width: 190 + children[0].width
    height: parent.height - 6
    color: palette.light

    radius: ColorsTheme.values.radius

    property string networkInterface: "wlp0s20f3"
    property int callInterval: 500
    property int networkTimeout: 300
    property int txBytes: 0
    property int rxBytes: 0
    property int oldTxBytes: 0
    property int oldRxBytes: 0

    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        margins: 10
    }

    Rectangle {
        id: informationRow
        width: children[0].children[1].width + 45
        height: 20
        radius: ColorsTheme.values.radius
        color: palette.mid

        anchors {
            left: parent.left
            margins: 2
            verticalCenter: parent.verticalCenter
        }

        RowLayout {
            spacing: 10

            anchors {
                left: parent.left
                margins: 8
                verticalCenter: parent.verticalCenter
            }

            Text {
                id: icon
                text: "󰤨"
                font.family: ColorsTheme.values.iconFont
                color: palette.text
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: networkName
                text: "Ahmed"
                color: palette.text
            }
        }
    }

    Rectangle {
        id: netSpeed
        width: 160
        height: 20
        color: "transparent"
        // spacing: 10

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 13
        }

        RowLayout {
            spacing: 5
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            Text {
                id: uoloadSpeedText
                text: "0b/s"
                color: palette.text
            }
            Label {
                text: "↑"
                color: palette.text
                font.family: ColorsTheme.values.iconFont
            }
        }

        RowLayout {
            spacing: 5
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            Text {
                id: downloadSpeedText
                text: "0b/s"
                color: palette.text
            }
            Label {
                text: "↓"
                font.family: ColorsTheme.values.iconFont
                color: palette.text
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            networkMonitoringProcess.running = true;
        }
    }

    Process {
        id: networkMonitoringProcess
        command: ["/bin/sh", "-c", "echo \"$(cat /sys/class/net/" + networkInterface + "/statistics/tx_bytes)::$(cat /sys/class/net/" + networkInterface + "/statistics/rx_bytes)\""]
        stdinEnabled: true

        stdout: SplitParser {
            id: outputParser

            onRead: data => {
                var parts = data.trim().split("::"); // Use trim() in case of trailing whitespace
                if (parts.length === 2) {
                    txBytes = parseInt(parts[0].trim());
                    rxBytes = parseInt(parts[1].trim());

                    const downloadSpeed = (rxBytes - oldRxBytes) / (networkTimeout / callInterval);
                    const uploadSpeed = (txBytes - oldTxBytes) / (networkTimeout / callInterval);

                    downloadSpeedText.text = Helper.convertToH(downloadSpeed);
                    uoloadSpeedText.text = Helper.convertToH(uploadSpeed);

                    oldRxBytes = rxBytes;
                    oldTxBytes = txBytes;
                }
            }
        }
    }
}
