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
    property string loadingBssid: ""
    property string liveUsageSubtitle: qsTr("Loading app usage...")
    property bool isLiveUsageLoading: false
    property string historyUsageSubtitle: qsTr("Loading history...")
    property bool isHistoryUsageLoading: false
    property string historyUsageTotal: "..."
    property string historyUsagePeak: "..."
    property string historyUsageSamples: "..."
    property bool isLeftMenuOpen: false

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
        liveUsageModel: liveUsageModel
        liveUsageSubtitle: root.liveUsageSubtitle
        liveUsageLoading: root.isLiveUsageLoading
        historyUsageModel: historyUsageModel
        historyUsageSubtitle: root.historyUsageSubtitle
        historyUsageLoading: root.isHistoryUsageLoading
        historyUsageTotal: root.historyUsageTotal
        historyUsagePeak: root.historyUsagePeak
        historyUsageSamples: root.historyUsageSamples

        onRefreshRequested: {
            root.refreshCurrentUsageTab();
        }
        onLiveUsageRefreshRequested: root.refreshCurrentUsageTab()
        onHistoryUsageRefreshRequested: root.refreshCurrentUsageTab()
        onActiveTabChanged: root.syncUsageProcesses(true)
        onExpandedChanged: root.syncUsageProcesses(true)
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
                console.info("wifiScannerProcess finished; bytes:", data ? data.length : 0);
                try {
                    root.updateWifiModel(JSON.parse(data));
                    root.loadingBssid = "";
                    console.info("wifi model updated, count:", wifiModel.count);
                } catch (e) {
                    console.error("WifiList JSON parse error:", e);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("WifiList stderr:", data)
        }
        function scan() {
            console.info("wifiScannerProcess.scan called; running:", this.running);
            this.running = true;
        }
    }

    Process {
        id: dataUsageProcess
        command: Utils.Helper.wifiDataUsageCommand({})
        stdout: StdioCollector {
            onStreamFinished: {
                console.info("dataUsageProcess finished; bytes:", data ? data.length : 0);
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
            console.info("dataUsageProcess.start called; running:", this.running);
            this.running = true;
        }
    }

    Process {
        id: dailyDataUsageProcess
        stdout: StdioCollector {
            onStreamFinished: {
                console.info("dailyDataUsageProcess finished; bytes:", data ? data.length : 0);
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
            console.info("dailyDataUsageProcess.start called");
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

    Process {
        id: liveUsageProcess
        command: Utils.Helper.wifiLiveUsageCommand({
            limit: 8
        })
        stdout: StdioCollector {
            onStreamFinished: {
                console.info("liveUsageProcess finished; bytes:", data ? data.length : 0);
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        root.updateLiveUsageModel(response.data);
                        console.info("live usage model updated, count:", liveUsageModel.count);
                        if (response.warning && liveUsageModel.count === 0)
                            root.liveUsageSubtitle = qsTr("Live rate unavailable (fallback mode)");
                    } else {
                        root.liveUsageSubtitle = qsTr("Unable to read live app usage");
                    }
                } catch (e) {
                    console.error("Live usage parse error:", e);
                    root.liveUsageSubtitle = qsTr("Unable to parse live app usage");
                }
                root.isLiveUsageLoading = false;
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.error("Live usage stderr:", data);
                root.isLiveUsageLoading = false;
            }
        }
        function start() {
            console.info("liveUsageProcess.start called; running:", this.running);
            root.isLiveUsageLoading = true;
            this.running = true;
        }
    }

    Process {
        id: historyUsageProcess
        command: Utils.Helper.wifiLiveUsageSummaryCommand({
            hours: 24,
            top: 8
        })
        stdout: StdioCollector {
            onStreamFinished: {
                console.info("historyUsageProcess finished; bytes:", data ? data.length : 0);
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        root.updateHistoryUsageModel(response);
                        console.info("history usage model updated, count:", historyUsageModel.count);
                    } else {
                        root.historyUsageSubtitle = qsTr("Unable to read usage history");
                    }
                } catch (e) {
                    console.error("History usage parse error:", e);
                    root.historyUsageSubtitle = qsTr("Unable to parse usage history");
                }
                root.isHistoryUsageLoading = false;
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.error("History usage stderr:", data);
                root.isHistoryUsageLoading = false;
            }
        }
        function start() {
            console.info("historyUsageProcess.start called; running:", this.running);
            root.isHistoryUsageLoading = true;
            this.running = true;
        }
    }

    Timer {
        id: scanTimer
        interval: 5000
        repeat: true
        running: false
        onTriggered: {
            root.safeStartWifiScan();
        }
    }

    Timer {
        id: refreshLiveData
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            if (root.shouldRunLiveUsage())
                root.refreshLiveUsage();
        }
    }

    Timer {
        id: refreshHistoryData
        interval: 30000
        repeat: true
        running: false
        onTriggered: {
            if (root.shouldRunHistoryUsage())
                root.refreshHistoryUsage();
        }
    }

    ListModel {
        id: wifiModel
    }

    ListModel {
        id: liveUsageModel
    }

    ListModel {
        id: historyUsageModel
    }

    // ─── دورة الحياة ─────────────────────────────────────────────
    Component.onCompleted: {
        console.info("WifiList created");
        root.safeStartWifiScan();
        EventBus.on(Events.LEFT_MENU_IS_OPENED, () => {
            console.info("LEFT_MENU_IS_OPENED received for WifiList");
            root.isLeftMenuOpen = true;
            root.safeStartWifiScan();
            if (scanTimer)
                scanTimer.running = true;
            root.syncUsageProcesses(true);
        }, root);
        EventBus.on(Events.LEFT_MENU_IS_CLOSED, () => {
            console.info("LEFT_MENU_IS_CLOSED received for WifiList");
            root.isLeftMenuOpen = false;
            if (scanTimer)
                scanTimer.running = false;
            if (refreshLiveData)
                refreshLiveData.running = false;
            if (refreshHistoryData)
                refreshHistoryData.running = false;
        }, root);
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

    function normalizeAndSortNetworks(networkArray) {
        if (!Array.isArray(networkArray))
            return [];

        const normalized = [];
        for (let i = 0; i < networkArray.length; i++) {
            if (networkArray[i] && networkArray[i].ssid)
                normalized.push(networkArray[i]);
        }

        normalized.sort((a, b) => a.is_saved !== b.is_saved ? b.is_saved - a.is_saved : b.signal - a.signal);
        return normalized;
    }

    function syncWifiModel(nextArray) {
        for (let i = 0; i < nextArray.length; i++) {
            const nextItem = nextArray[i];

            if (i < wifiModel.count) {
                if (wifiModel.get(i).bssid === nextItem.bssid) {
                    wifiModel.set(i, nextItem);
                    continue;
                }

                let existingIndex = -1;
                for (let j = i + 1; j < wifiModel.count; j++) {
                    if (wifiModel.get(j).bssid === nextItem.bssid) {
                        existingIndex = j;
                        break;
                    }
                }

                if (existingIndex !== -1) {
                    wifiModel.move(existingIndex, i, 1);
                    wifiModel.set(i, nextItem);
                } else {
                    wifiModel.insert(i, nextItem);
                }
            } else {
                wifiModel.append(nextItem);
            }
        }

        while (wifiModel.count > nextArray.length)
            wifiModel.remove(wifiModel.count - 1);
    }

    function findIndexByBssid(bssid) {
        for (let i = 0; i < wifiModel.count; i++) {
            if (wifiModel.get(i).bssid === bssid)
                return i;
        }
        return -1;
    }

    function updateWifiModel(networkArray) {
        const nextNetworks = root.normalizeAndSortNetworks(networkArray);
        const expandedBssid = root.expandedBssid;

        if (expandedBssid === "") {
            root.syncWifiModel(nextNetworks);
            wifiList.currentIndex = -1;
            return;
        }

        let expandedIndex = -1;
        let expandedEntry = null;
        for (let i = 0; i < wifiModel.count; i++) {
            const item = wifiModel.get(i);
            if (item.bssid === expandedBssid) {
                expandedIndex = i;
                expandedEntry = item;
                break;
            }
        }

        if (expandedEntry === null) {
            root.syncWifiModel(nextNetworks);
            const expandedIndexAfterSync = root.findIndexByBssid(expandedBssid);
            if (expandedIndexAfterSync !== -1) {
                wifiList.currentIndex = expandedIndexAfterSync;
                return;
            }
            root.expandedBssid = "";
            wifiList.currentIndex = -1;
            return;
        }

        const merged = [];
        for (let i = 0; i < nextNetworks.length; i++) {
            if (nextNetworks[i].bssid !== expandedBssid)
                merged.push(nextNetworks[i]);
        }
        const targetIndex = Math.min(expandedIndex, merged.length);
        merged.splice(targetIndex, 0, expandedEntry);

        root.syncWifiModel(merged);
        wifiList.currentIndex = targetIndex;
    }

    function sanitizeProcessName(name) {
        if (!name || name.trim() === "")
            return qsTr("Unknown");
        return name;
    }

    function refreshLiveUsage() {
        if (liveUsageProcess && !liveUsageProcess.running)
            liveUsageProcess.start();
    }

    function shouldRunUsageSection() {
        if (!dataUsage)
            return false;
        return root.isLeftMenuOpen && dataUsage.expanded;
    }

    function shouldRunDataUsage() {
        return root.shouldRunUsageSection() && dataUsage.activeTab === 0;
    }

    function shouldRunLiveUsage() {
        return root.shouldRunUsageSection() && dataUsage.activeTab === 1;
    }

    function shouldRunHistoryUsage() {
        return root.shouldRunUsageSection() && dataUsage.activeTab === 2;
    }

    function refreshCurrentUsageTab() {
        if (root.shouldRunDataUsage()) {
            if (dataUsageProcess && !dataUsageProcess.running)
                dataUsageProcess.start();
            if (dailyDataUsageProcess && !dailyDataUsageProcess.running)
                dailyDataUsageProcess.start();
            return;
        }

        if (root.shouldRunLiveUsage())
            root.refreshLiveUsage();

        if (root.shouldRunHistoryUsage())
            root.refreshHistoryUsage();
    }

    function syncUsageProcesses(runImmediate = false) {
        if (refreshLiveData)
            refreshLiveData.running = root.shouldRunLiveUsage();
        if (refreshHistoryData)
            refreshHistoryData.running = root.shouldRunHistoryUsage();

        if (runImmediate)
            root.refreshCurrentUsageTab();
    }

    function refreshHistoryUsage() {
        if (historyUsageProcess && !historyUsageProcess.running)
            historyUsageProcess.start();
    }

    function safeStartWifiScan() {
        console.info("safeStartWifiScan invoked; hasProcess=", wifiScannerProcess !== null);
        if (wifiScannerProcess && !wifiScannerProcess.running)
            wifiScannerProcess.scan();
    }

    function updateLiveUsageModel(liveRows) {
        const rows = Array.isArray(liveRows) ? liveRows : [];
        liveUsageModel.clear();

        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            const pid = Number(row.pid) || 0;
            const processName = root.sanitizeProcessName(row.name);
            const bytesRecv = Number(row.bytes_recv) || 0;
            const bytesSent = Number(row.bytes_sent) || 0;
            const bytesTotal = Number(row.bytes_total) || (bytesRecv + bytesSent);
            const rxRate = Number(row.rx_rate_bps) || 0;
            const txRate = Number(row.tx_rate_bps) || 0;
            const totalRate = Number(row.total_rate_bps) || (rxRate + txRate);
            const connectionsCount = Number(row.connections_count) || 0;

            liveUsageModel.append({
                display_name: `${processName} (${pid})`,
                rx_text: rxRate > 0 ? root.formatRate(rxRate) : root.formatBytes(bytesRecv),
                tx_text: txRate > 0 ? root.formatRate(txRate) : root.formatBytes(bytesSent),
                total_text: totalRate > 0 ? root.formatRate(totalRate) : root.formatBytes(bytesTotal),
                connections_count: connectionsCount
            });
        }

        const updatedAt = Qt.formatTime(new Date(), "hh:mm:ss");
        if (liveUsageModel.count > 0) {
            root.liveUsageSubtitle = qsTr("Updated %1 • %2 active apps").arg(updatedAt).arg(liveUsageModel.count);
        } else {
            root.liveUsageSubtitle = qsTr("Updated %1 • No active apps").arg(updatedAt);
        }
    }

    function updateHistoryUsageModel(summaryResponse) {
        const rows = Array.isArray(summaryResponse.data) ? summaryResponse.data : [];
        const totals = summaryResponse.totals || {};
        historyUsageModel.clear();

        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            const name = root.sanitizeProcessName(row.name);
            const totalBytes = Number(row.total_bytes) || 0;
            const peakRate = Number(row.peak_rate_bps) || 0;

            historyUsageModel.append({
                display_name: name,
                total_text: root.formatBytes(totalBytes),
                peak_text: root.formatRate(peakRate)
            });
        }

        root.historyUsageTotal = root.formatBytes(Number(totals.total_bytes) || 0);
        root.historyUsagePeak = root.formatRate(Number(totals.peak_rate_bps) || 0);
        root.historyUsageSamples = `${Number(totals.samples_count) || 0}`;

        const updatedAt = Qt.formatTime(new Date(), "hh:mm:ss");
        root.historyUsageSubtitle = qsTr("Last 24h • Updated %1").arg(updatedAt);
    }

    function formatRate(bytesPerSecond) {
        return `${root.formatBytes(bytesPerSecond)}/s`;
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
