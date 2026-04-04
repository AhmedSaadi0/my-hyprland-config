// windows/leftwindow/dashboard/QuickActions.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/config/ConstValues.js" as Consts

MenuCard {
    id: root

    title: qsTr("Quick Actions")
    icon: "󰒓"
    subtitle: qsTr("System radios and focus tools")

    property bool wifiAvailable: false
    property bool wifiEnabled: false

    property bool bluetoothAvailable: false
    property bool bluetoothEnabled: false

    property bool airplaneAvailable: false
    property bool airplaneEnabled: false

    property bool gameModeAvailable: false
    property bool gameModeEnabled: false

    property string pendingAction: ""
    property string errorMessage: ""
    property int innerRadiusDiv: 3

    function refreshStates() {
        if (statusProcess.running)
            return;

        statusProcess.command = ["sh", App.scripts.bash.quickActions, "status"];
        statusProcess.running = true;
    }

    function toggleAction(actionName) {
        if (actionProcess.running)
            return;

        root.pendingAction = actionName;
        root.errorMessage = "";
        actionProcess.command = ["sh", App.scripts.bash.quickActions, "toggle", actionName];
        actionProcess.running = true;
    }

    function updateStates(payload) {
        const wifi = payload.wifi || {};
        const bluetooth = payload.bluetooth || {};
        const airplane = payload.airplane || {};
        const gameMode = payload.gameMode || {};

        root.wifiAvailable = !!wifi.available;
        root.wifiEnabled = !!wifi.enabled;

        root.bluetoothAvailable = !!bluetooth.available;
        root.bluetoothEnabled = !!bluetooth.enabled;

        root.airplaneAvailable = !!airplane.available;
        root.airplaneEnabled = !!airplane.enabled;

        root.gameModeAvailable = !!gameMode.available;
        root.gameModeEnabled = !!gameMode.enabled;
    }

    ColumnLayout {
        spacing: 7

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 7
            rowSpacing: 7

            MButton {
                Layout.fillWidth: true
                text: qsTr("Wi-Fi")
                iconText: ""
                iconFirst: true
                enabled: root.wifiAvailable && !actionProcess.running && root.pendingAction !== "airplane"
                isActive: root.wifiEnabled && !root.airplaneEnabled
                activeText: qsTr("Wi-Fi On")
                topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : root.innerRadiusDiv)
                bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : root.innerRadiusDiv)
                onClicked: root.toggleAction("wifi")
            }

            MButton {
                Layout.fillWidth: true
                text: qsTr("Bluetooth")
                iconText: ""
                iconFirst: true
                enabled: root.bluetoothAvailable && !actionProcess.running && root.pendingAction !== "airplane"
                isActive: root.bluetoothEnabled && !root.airplaneEnabled
                activeText: qsTr("Bluetooth On")
                topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : root.innerRadiusDiv)
                bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : root.innerRadiusDiv)
                onClicked: root.toggleAction("bluetooth")
            }

            MButton {
                Layout.fillWidth: true
                text: qsTr("Airplane")
                iconText: ""
                iconFirst: true
                enabled: root.airplaneAvailable && !actionProcess.running
                isActive: root.airplaneEnabled
                activeText: qsTr("Airplane On")
                bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : root.innerRadiusDiv)
                topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : root.innerRadiusDiv)
                onClicked: root.toggleAction("airplane")
            }

            MButton {
                Layout.fillWidth: true
                text: qsTr("Game Mode")
                iconText: ""
                iconFirst: true
                enabled: root.gameModeAvailable && !actionProcess.running
                isActive: root.gameModeEnabled
                activeText: qsTr("Game Mode On")
                bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : root.innerRadiusDiv)
                topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : root.innerRadiusDiv)
                onClicked: root.toggleAction("gameMode")
            }
        }

        Text {
            Layout.fillWidth: true
            visible: root.errorMessage.length > 0
            text: root.errorMessage
            wrapMode: Text.Wrap
            color: ThemeManager.selectedTheme.colors.warning
            font.family: ThemeManager.selectedTheme.typography.bodyFont
            font.pixelSize: 11
        }
    }

    Component.onCompleted: refreshStates()

    Timer {
        interval: 12000
        repeat: true
        running: true
        onTriggered: root.refreshStates()
    }

    Process {
        id: statusProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.updateStates(JSON.parse(this.text));
                    root.errorMessage = "";
                } catch (error) {
                    root.errorMessage = qsTr("Unable to read quick action states.");
                    console.error("[QuickActions] Failed to parse status:", error);
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                root.errorMessage = data.trim();
                console.error("[QuickActions] Status stderr:", data);
            }
        }
    }

    Process {
        id: actionProcess

        onExited: {
            root.pendingAction = "";
            root.refreshStates();
        }

        stderr: SplitParser {
            onRead: data => {
                root.errorMessage = data.trim();
                console.error("[QuickActions] Action stderr:", data);
            }
        }
    }
}
