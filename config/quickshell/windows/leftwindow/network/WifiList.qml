// windows/leftwindow/network/WifiList.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"
import "root:/utils" as Utils
import "root:/components"
import "../base"

BaseMenuView {
    id: root

    menuTitle: qsTr("Network")
    menuIcon: "󰖩"
    showPrimaryAction: false

    // ─── خصائص الواجهة ───────────────────────────────────────────
    property string expandedBssid: ""
    property bool isAnyItemExpanded: expandedBssid !== ""
    property string loadingBssid: ""
    property bool forceScan: false

    // ─── DataUsage كهيدر يتمرر مع المحتوى ────────────────────────
    DataUsageHeader {
        id: dataUsage
        Layout.fillWidth: true

        subtitle: qsTr("Loading data...")
        receivedData: "..."
        sentData: "..."
        totalData: "..."
        dailyReceivedData: "..."
        dailySentData: "..."
        dailyTotalData: "..."

        onRefreshRequested: {
            dataUsageProcess.start();
            dailyDataUsageProcess.start();
            wifiScannerProcess.scan();
        }
    }

    // ─── المحتوى ─────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        spacing: 0

        HiddenNetworkSection {
            Layout.fillWidth: true
            onConnectRequested: (ssid, password) => root.connectToHiddenWifi(ssid, password)
        }
    }

    // قائمة الشبكات
    WifiNetworksList {
        id: wifiList
        Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        model: wifiModel
        expandedBssid: root.expandedBssid
        loadingBssid: root.loadingBssid

        onExpandedBssidSelected: bssid => root.expandedBssid = bssid
        onConnectClicked: (ssid, password) => root.connectToWifi(ssid, password)
        onDisconnectClicked: ssid => root.disconnectFromWifi(ssid)
        onForgetClicked: ssid => root.forgetWifi(ssid)
    }

    // ─── Processes ───────────────────────────────────────────────
    Process {
        id: wifiActionProcess
        property bool closeLeftbar: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        wifiList.currentIndex = -1;
                        root.expandedBssid = "";
                        if (wifiActionProcess.closeLeftbar)
                            EventBus.emit(Events.CLOSE_LEFTBAR);
                        root.forceScan = true;
                        wifiScannerProcess.scan();
                    } else {
                        root.loadingBssid = "";
                    }
                } catch (e) {
                    root.loadingBssid = "";
                }
            }
        }
        stderr: SplitParser {
            onRead: data => root.loadingBssid = ""
        }

        function startAction(fullCommand, closeLeftbar = false) {
            root.loadingBssid = root.expandedBssid;
            this.closeLeftbar = closeLeftbar;
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
                        root.updateWifiModel(JSON.parse(data));
                        root.forceScan = false;
                        root.loadingBssid = "";
                    }
                } catch (e) {
                    console.error("WifiList JSON parse error:", e);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("WifiList stderr:", data)
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
                        dataUsage.subtitle = `Monthly: ${response.period.start} to ${response.period.end}`;
                        dataUsage.receivedData = root.formatBytes(response.usage_bytes.received);
                        dataUsage.sentData = root.formatBytes(response.usage_bytes.sent);
                        dataUsage.totalData = root.formatBytes(response.usage_bytes.total);
                    }
                } catch (e) {
                    console.error("Data Usage parse error:", e);
                }
            }
        }
        function start() {
            this.running = true;
        }
    }

    Process {
        id: dailyDataUsageProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        dataUsage.dailyReceivedData = root.formatBytes(response.usage_bytes.received);
                        dataUsage.dailySentData = root.formatBytes(response.usage_bytes.sent);
                        dataUsage.dailyTotalData = root.formatBytes(response.usage_bytes.total);
                    }
                } catch (e) {
                    console.error("Daily Data Usage parse error:", e);
                }
            }
        }
        function start() {
            const today = new Date();
            const tomorrow = new Date();
            tomorrow.setDate(today.getDate() + 1);
            this.command = Utils.Helper.wifiDataUsageCommand({
                startDate: today.toISOString().slice(0, 10),
                endDate: tomorrow.toISOString().slice(0, 10)
            });
            this.running = true;
        }
    }

    Timer {
        id: scanTimer
        interval: 5000
        repeat: true
        running: !root.isAnyItemExpanded
        onTriggered: {
            if (!wifiScannerProcess.running)
                wifiScannerProcess.scan();
        }
    }

    ListModel {
        id: wifiModel
    }

    // ─── دورة الحياة ─────────────────────────────────────────────
    Component.onCompleted: {
        EventBus.on(Events.LEFT_MENU_IS_OPENED, () => {
            wifiScannerProcess.scan();
            scanTimer.running = true;
            scanTimer.repeat = true;
            dataUsageProcess.start();
            dailyDataUsageProcess.start();
        });
        EventBus.on(Events.LEFT_MENU_IS_CLOSED, () => {
            scanTimer.running = false;
            scanTimer.repeat = false;
        });
    }

    // ─── دوال مساعدة ─────────────────────────────────────────────
    function formatBytes(bytes, decimals = 2) {
        if (!+bytes)
            return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return `${parseFloat((bytes / Math.pow(k, i)).toFixed(decimals < 0 ? 0 : decimals))} ${sizes[i]}`;
    }

    function updateWifiModel(networkArray) {
        if (Array.isArray(networkArray)) {
            networkArray.sort((a, b) => a.is_saved !== b.is_saved ? b.is_saved - a.is_saved : b.signal - a.signal);
        }
        wifiModel.clear();
        if (Array.isArray(networkArray)) {
            for (let i = 0; i < networkArray.length; i++) {
                if (networkArray[i].ssid)
                    wifiModel.append(networkArray[i]);
            }
        }
        if (root.expandedBssid !== "") {
            for (let i = 0; i < wifiModel.count; i++) {
                if (wifiModel.get(i).bssid === root.expandedBssid) {
                    wifiList.currentIndex = i;
                    return;
                }
            }
            root.expandedBssid = "";
            wifiList.currentIndex = -1;
        }
    }

    function connectToWifi(ssid, password) {
        wifiActionProcess.startAction(Utils.Helper.connectWifiCommand({
            ssid,
            command: "connect",
            password
        }), true);
    }
    function connectToHiddenWifi(ssid, password) {
        wifiActionProcess.startAction(Utils.Helper.connectWifiCommand({
            ssid,
            command: "connect",
            password
        }), true);
    }
    function disconnectFromWifi(ssid) {
        wifiActionProcess.startAction(Utils.Helper.connectWifiCommand({
            ssid,
            command: "disconnect"
        }));
    }
    function forgetWifi(ssid) {
        wifiActionProcess.startAction(Utils.Helper.connectWifiCommand({
            ssid,
            command: "delete"
        }));
    }
}
