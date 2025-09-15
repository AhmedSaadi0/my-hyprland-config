import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

import "root:/themes"
import "./WifiItem.qml"
import "root:/config/EventNames.js" as Events
import "root:/config"
import "root:/utils" as Utils

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0

    property string expandedBssid: ""
    property bool isAnyItemExpanded: expandedBssid !== ""
    property string loadingBssid: ""
    property bool forceScan: false

    Process {
        id: wifiActionProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        console.log("Wifi Action Success:", response.message);
                        listView.currentIndex = -1;
                        root.expandedBssid = "";

                        root.forceScan = true;
                        wifiScannerProcess.scan();
                    } else {
                        console.error("Wifi Action Error:", response.message);
                        root.loadingBssid = "";
                    }
                } catch (e) {
                    console.error("Wifi Action JSON Parse Error:", e);
                    root.loadingBssid = "";
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                console.error("Wifi Action Stderr:", data);
                root.loadingBssid = "";
            }
        }

        function startAction(fullCommand) {
            root.loadingBssid = root.expandedBssid;
            this.command = fullCommand;
            this.running = true;
        }
    }

    Process {
        id: wifiScannerProcess
        command: Utils.Helper.listWifiCommand()
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    if (root.forceScan || !root.isAnyItemExpanded) {
                        const newNetworkData = JSON.parse(data);
                        root.updateWifiModel(newNetworkData);
                        root.forceScan = false;
                        root.loadingBssid = "";
                    }
                } catch (e) {
                    console.error("WifiList: فشل في تحليل مخرجات JSON:", e);
                    console.error("البيانات المستلمة:", data);
                }
            }
        }

        stderr: SplitParser {
            onRead: data => console.error("WifiList: خطأ من سكربت الشبكة:", data)
        }

        function scan() {
            this.running = true;
        }
    }

    Timer {
        id: scanTimer
        interval: 5000
        repeat: true
        running: !root.isAnyItemExpanded
        onTriggered: {
            if (!wifiScannerProcess.running) {
                wifiScannerProcess.scan();
            }
        }
    }

    ListModel {
        id: wifiModel
    }

    function updateWifiModel(networkArray) {
        if (Array.isArray(networkArray)) {
            networkArray.sort((a, b) => {
                if (a.is_saved !== b.is_saved) {
                    return b.is_saved - a.is_saved;
                }
                return b.signal - a.signal;
            });
        }

        wifiModel.clear();

        if (Array.isArray(networkArray)) {
            for (let i = 0; i < networkArray.length; i++) {
                wifiModel.append(networkArray[i]);
            }
        }

        if (root.expandedBssid !== "") {
            for (let i = 0; i < wifiModel.count; i++) {
                if (wifiModel.get(i).bssid === root.expandedBssid) {
                    listView.currentIndex = i;
                    return;
                }
            }
            root.expandedBssid = "";
            listView.currentIndex = -1;
        }
    }

    Component.onCompleted: {
        EventBus.on(Events.OPEN_LEFTBAR, function () {
            wifiScannerProcess.scan();
            scanTimer.running = true;
            scanTimer.repeat = true;
        });

        EventBus.on(Events.CLOSE_LEFTBAR, function () {
            scanTimer.running = false;
            scanTimer.repeat = false;
        });
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ListView {
            id: listView
            anchors.fill: parent
            model: wifiModel
            clip: true
            spacing: ThemeManager.selectedTheme.dimensions.spacingMedium
            currentIndex: -1

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            add: Transition {
                ParallelAnimation {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to: 1.0
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                    PropertyAnimation {
                        property: "scale"
                        from: 0.85
                        to: 1.0
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }
            }

            remove: Transition {
                ParallelAnimation {
                    PropertyAnimation {
                        property: "opacity"
                        to: 0
                        duration: 200
                        easing.type: Easing.InQuad
                    }
                    PropertyAnimation {
                        property: "scale"
                        to: 0.85
                        duration: 200
                        easing.type: Easing.InCubic
                    }
                }
            }
            delegate: WifiItem {
                width: listView.width
                Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.baseMargins / 2

                ssid: model.ssid
                bssid: model.bssid
                signal: model.signal
                security: model.security
                in_use: model.in_use
                is_saved: model.is_saved

                // expanded: listView.currentIndex === index
                // isLoading: root.loadingBssid === model.bssid

                expanded: root.expandedBssid === model.bssid
                isLoading: root.loadingBssid === model.bssid

                onItemToggled: {
                    if (root.loadingBssid === model.bssid)
                        return;

                    listView.currentIndex = (listView.currentIndex === index ? -1 : index);
                    root.expandedBssid = (listView.currentIndex !== -1) ? model.bssid : "";
                }

                onConnectClicked: (ssid, password) => {
                    connectToWifi(ssid, password);
                }
                onDisconnectClicked: ssid => {
                    disconnectFromWifi(ssid);
                }
                onForgetClicked: ssid => {
                    forgetWifi(ssid);
                }
            }

            Label {
                anchors.centerIn: parent
                visible: listView.model.count === 0
                text: "جاري البحث عن الشبكات..."
                color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.7)
            }
        }
    }

    function connectToWifi(ssid, password) {
        const command = Utils.Helper.connectWifiCommand({
            ssid: ssid,
            command: "connect",
            password: password
        });
        wifiActionProcess.startAction(command);
    }

    function disconnectFromWifi(ssid) {
        const command = Utils.Helper.connectWifiCommand({
            ssid: ssid,
            command: "disconnect"
        });
        wifiActionProcess.startAction(command);
    }

    function forgetWifi(ssid) {
        const command = Utils.Helper.connectWifiCommand({
            ssid: ssid,
            command: "delete"
        });
        wifiActionProcess.startAction(command);
    }
}
