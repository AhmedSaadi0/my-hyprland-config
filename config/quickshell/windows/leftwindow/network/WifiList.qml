import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

import "root:/themes"
import "./WifiItem.qml"
import "root:/config/EventNames.js" as Events
import "root:/config"
import "root:/utils" as Utils
import "root:/components"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0

    property string expandedBssid: ""
    property bool isAnyItemExpanded: expandedBssid !== ""
    property string loadingBssid: ""
    property bool forceScan: false

    // Process to handle connect/disconnect/forget actions
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

    // Process to scan for available Wi-Fi networks
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

    Process {
        id: dataUsageProcess
        command: Utils.Helper.wifiDataUsageCommand({})

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        dataUsage.subtitle = `Start: ${response.period.start} - End: ${response.period.end}`;
                        dataUsage.receivedData = root.formatBytes(response.usage_bytes.received);
                        dataUsage.sentData = root.formatBytes(response.usage_bytes.sent);
                        dataUsage.totalData = root.formatBytes(response.usage_bytes.total);
                    } else {
                        console.error("Data Usage Error:", response.message);
                        dataUsage.subtitle = "Failed to load data";
                    }
                } catch (e) {
                    console.error("Data Usage JSON Parse Error:", e);
                    dataUsage.subtitle = "Error parsing data";
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                console.error("Data Usage Stderr:", data);
                dataUsage.subtitle = "Error executing command";
            }
        }

        function start() {
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

    function formatBytes(bytes, decimals = 2) {
        if (!+bytes)
            return '0 Bytes';

        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB'];

        const i = Math.floor(Math.log(bytes) / Math.log(k));

        return `${parseFloat((bytes / Math.pow(k, i)).toFixed(dm))} ${sizes[i]}`;
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
        dataUsageProcess.start(); // Fetch data usage on startup

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

    MenuCard {
        id: dataUsage

        Layout.fillWidth: true
        Layout.bottomMargin: 10

        cardColor: ThemeManager.selectedTheme.colors.primary.alpha(0.4)

        cardLeftPadding: 8
        cardRightPadding: 8

        title: "Data Usage"
        subtitle: "Loading data..."
        icon: "󰑓" // nf-md-sync
        iconCursorShape: Qt.PointingHandCursor

        property string receivedData: "..."
        property string sentData: "..."
        property string totalData: "..."

        onIconClicked: {
            rotationAnim.start();
            dataUsageProcess.start();
            wifiScannerProcess.scan();
        }

        RotationAnimation on rotation {
            id: rotationAnim
            target: dataUsage.iconItem
            from: 0
            to: 360
            duration: 500
            easing.type: Easing.InOutCubic
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 60

            Layout.leftMargin: 10
            Layout.rightMargin: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Label {
                    text: "󰁅" // nf-md-arrow_down
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 26
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: qsTr("Received")
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: dataUsage.receivedData
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Sent Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Label {
                    text: "󰁝" // nf-md-arrow_up
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 26
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: qsTr("Sent")
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: dataUsage.sentData
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Total Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Label {
                    text: "󰯙" // nf-md-swap_vertical
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 26
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: qsTr("Total")
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: dataUsage.totalData
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
    // ***** END: UPDATED DATA USAGE CARD *****

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
                text: qsTr("Searching for networks ...")
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
