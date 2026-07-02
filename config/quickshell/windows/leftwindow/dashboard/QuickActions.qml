import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Io

import "root:/components"
import "root:/themes"

MenuCard {
    id: root

    title: qsTr("Quick Actions")
    icon: ""
    cardColor: ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.7)
    textColor: ThemeManager.selectedTheme.colors.onSecondaryContainer

    function _findWifiDevice() {
        return Networking.devices.values.find(d => d.type === DeviceType.Wifi) || null;
    }

    property var wifiDevice: null
    property bool wifiAvailable: wifiDevice !== null
    property bool wifiEnabled: Networking.wifiEnabled

    property bool bluetoothAvailable: Bluetooth.defaultAdapter !== null
    property bool bluetoothEnabled: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false

    property bool airplaneAvailable: wifiAvailable || bluetoothAvailable
    property bool airplaneEnabled: airplaneAvailable && (!wifiAvailable || !wifiEnabled) && (!bluetoothAvailable || !bluetoothEnabled)

    function toggleAction(actionName) {
        switch (actionName) {
        case "wifi":
            Networking.wifiEnabled = !Networking.wifiEnabled;
            break;
        case "bluetooth":
            if (Bluetooth.defaultAdapter)
                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
            break;
        case "airplane":
            if (root.airplaneEnabled) {
                if (root.wifiAvailable)
                    Networking.wifiEnabled = true;
                if (root.bluetoothAvailable && Bluetooth.defaultAdapter)
                    Bluetooth.defaultAdapter.enabled = true;
            } else {
                if (root.wifiAvailable)
                    Networking.wifiEnabled = false;
                if (root.bluetoothAvailable && Bluetooth.defaultAdapter)
                    Bluetooth.defaultAdapter.enabled = false;
            }
            break;
        }
    }

    RowLayout {
        spacing: 7
        Layout.fillWidth: true

        MButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 25
            text: "Wi-Fi"
            iconText: root.wifiEnabled ? "" : "󰖪"
            iconFirst: true
            iconSize: 16
            enabled: root.wifiAvailable
            isActive: root.wifiEnabled && !root.airplaneEnabled
            onClicked: root.toggleAction("wifi")

            normalBackground: root.textColor.alpha(0.1)
            normalForeground: root.textColor
            hoveredBackground: root.cardColor.alpha(0.2)
            downForeground: root.textColor
        }

        MButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 25
            text: "Bluetooth"
            iconText: root.bluetoothEnabled ? "󰂯" : "󰂲"
            iconFirst: true
            iconSize: 16
            enabled: root.bluetoothAvailable
            isActive: root.bluetoothEnabled && !root.airplaneEnabled
            onClicked: root.toggleAction("bluetooth")
            normalBackground: root.textColor.alpha(0.1)
            normalForeground: root.textColor
            hoveredBackground: root.cardColor.alpha(0.2)
            downForeground: root.textColor
        }

        MButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 25
            text: "Airplane"
            iconText: "󰀝"
            iconSize: 16
            iconFirst: true
            enabled: root.airplaneAvailable
            isActive: root.airplaneEnabled
            onClicked: root.toggleAction("airplane")
            normalBackground: root.textColor.alpha(0.1)
            normalForeground: root.textColor
            hoveredBackground: root.cardColor.alpha(0.2)
            downForeground: root.textColor
        }
    }

    Connections {
        target: Networking.devices
        function onValuesChanged() {
            root.wifiDevice = root._findWifiDevice();
        }
    }

    Component.onCompleted: {
        root.wifiDevice = root._findWifiDevice();
    }
}
