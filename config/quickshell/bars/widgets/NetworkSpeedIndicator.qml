import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/utils/helpers.js" as Helper

Rectangle {
    id: netspeedToolbarWidget

    property string networkInterface: App.networkMonitor
    property int callInterval: App.networkInterval
    property var txBytes: 0
    property var rxBytes: 0

    implicitWidth: 190 + children[0].width
    implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
    color: ThemeManager.selectedTheme.colors.topbarBgColorV3
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    // -------------------------
    // ------ Name & icon ------
    // -------------------------
    Rectangle {
        id: informationRow

        width: children[0].children[1].width + 45
        height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight - 4
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: ThemeManager.selectedTheme.colors.topbarColor
        layer.enabled: true

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
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }

            Text {
                id: networkName
                text: "-"
                font.bold: true
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
            }
        }

        layer.effect: Shadow {
            color: palette.shadow.alpha(0.2)
            radius: 8
        }
    }

    RowLayout {
        // width: 160

        id: netSpeed

        spacing: 10

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
                color: ThemeManager.selectedTheme.colors.topbarFgColorV3
            }

            Label {
                text: "↑"
                color: ThemeManager.selectedTheme.colors.topbarFgColorV3
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
                color: ThemeManager.selectedTheme.colors.topbarFgColorV3
            }

            Label {
                text: "↓"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                color: ThemeManager.selectedTheme.colors.topbarFgColorV3
            }
        }
    }

    Timer {
        id: updateTimer

        interval: callInterval
        repeat: true
        running: true
        onTriggered: {
            networkMonitoringProcess.running = true;
        }
    }

    Process {
        // running: true

        id: networkMonitoringProcess

        // command: ["sh", "-c", `~/.config/quickshell/scripts/internet.sh ${networkInterface}`]
        command: App.scripts.bash.internetCommand
        stdinEnabled: true

        stderr: SplitParser {
            onRead: data => {
                console.error(data);
            }
        }

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
                    if (!Helper.isValidPositiveInt(newTxBytes) || !Helper.isValidPositiveInt(newRxBytes))
                        return;

                    const downloadSpeed = Helper.calculateSpeed(newRxBytes, rxBytes, updateTimer.interval);
                    const uploadSpeed = Helper.calculateSpeed(newTxBytes, txBytes, updateTimer.interval);
                    downloadSpeedText.text = Helper.convertToH(downloadSpeed);
                    uploadSpeedText.text = Helper.convertToH(uploadSpeed);
                    networkName.text = Helper.formatNetworkName(connectedToRaw) ? Helper.formatNetworkName(connectedToRaw) : qsTr("No Network");
                    networkIcon.text = Helper.signalStrengthToIcon(stringth);
                    rxBytes = newRxBytes;
                    txBytes = newTxBytes;
                }
            }
        }
    }
}
