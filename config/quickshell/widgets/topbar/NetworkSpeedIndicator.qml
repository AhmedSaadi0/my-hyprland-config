import Quickshell.Io

// import QtDBus 1.0

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../themes"
import "../../utils/helpers.js" as Helper
import "../../components"

Rectangle {
    id: netspeedToolbarWidget

    property string networkInterface: "wlp0s20f3"
    property int callInterval: 500
    property int networkTimeout: 300
    property var txBytes: 0
    property var rxBytes: 0

    implicitWidth: 180 + children[0].width
    implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
    color: palette.light
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    // -------------------------
    // ------ Name & icon ------
    // -------------------------
    Rectangle {
        id: informationRow
        width: children[0].children[1].width + 45
        height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight - 4
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: palette.mid

        layer.enabled: true
        layer.effect: Shadow {
            color: palette.shadow.alpha(0.2)
            radius: 8
        }

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
                id: networkIcon
                text: "󰤮"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                color: palette.text
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: networkName
                text: "-"
                color: palette.text
            }
        }
    }

    RowLayout {
        id: netSpeed
        spacing: 10
        // width: 160

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 10
        }

        RowLayout {
            spacing: 3
            // anchors {
            //     left: parent.left
            //     verticalCenter: parent.verticalCenter
            // }
            Text {
                id: uploadSpeedText
                text: "0b/s"
                color: palette.text
            }
            Label {
                text: "↑"
                color: palette.text
                font.family: ThemeManager.selectedTheme.typography.iconFont
            }
        }

        RowLayout {
            spacing: 3
            // anchors {
            //     right: parent.right
            //     verticalCenter: parent.verticalCenter
            // }
            Text {
                id: downloadSpeedText
                text: "0b/s"
                color: palette.text
            }
            Label {
                text: "↓"
                font.family: ThemeManager.selectedTheme.typography.iconFont
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
        command: ["sh", "-c", `~/.config/quickshell/scripts/internet.sh ${networkInterface}`]

        stdinEnabled: true
        // running: true

        stdout: SplitParser {
            id: outputParser
            onRead: data => {
                var parts = data.trim().split("::");

                if (parts.length === 4) {
                    const newTxBytes = parseInt(parts[0].trim());
                    const newRxBytes = parseInt(parts[1].trim());
                    const connectedToRaw = parts[2].trim();
                    const strengthRaw = parts[3].trim();

                    const stringth = parseInt(strengthRaw, 10);

                    if (!Helper.isValidPositiveInt(newTxBytes) || !Helper.isValidPositiveInt(newRxBytes)) {
                        return;
                    }

                    const downloadSpeed = Helper.calculateSpeed(newRxBytes, rxBytes, updateTimer.interval);
                    const uploadSpeed = Helper.calculateSpeed(newTxBytes, txBytes, updateTimer.interval);

                    downloadSpeedText.text = Helper.convertToH(downloadSpeed);
                    uploadSpeedText.text = Helper.convertToH(uploadSpeed);

                    networkName.text = Helper.formatNetworkName(connectedToRaw);
                    networkIcon.text = Helper.signalStrengthToIcon(stringth);

                    rxBytes = newRxBytes;
                    txBytes = newTxBytes;
                }
            }
        }
    }
}
