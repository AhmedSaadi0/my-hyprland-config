pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "root:/config"
import "root:/utils" as Utils

Singleton {
    id: root

    property string wifiInterface: App.networkMonitor
    property bool isMenuOpen: false
    property bool usageExpanded: true
    property int usageActiveTab: 0 // 0:data, 1:live, 2:history

    property int liveLimit: 8
    property int historyTop: 8
    property int historyHours: 24

    property var wifiNetworks: []

    property string usageSubtitle: qsTr("Loading data...")
    property string receivedData: "..."
    property string sentData: "..."
    property string totalData: "..."
    property string dailyReceivedData: "..."
    property string dailySentData: "..."
    property string dailyTotalData: "..."

    property string liveUsageSubtitle: qsTr("Loading app usage...")
    property bool liveUsageLoading: false

    property string historyUsageSubtitle: qsTr("Loading history...")
    property bool historyUsageLoading: false
    property string historyUsageTotal: "..."
    property string historyUsagePeak: "..."
    property string historyUsageSamples: "..."

    readonly property alias liveUsageModel: liveUsageListModel
    readonly property alias historyUsageModel: historyUsageListModel

    signal wifiNetworksUpdated(var networks)
    signal wifiActionFinished(bool success, bool closeLeftbar, string message)

    ListModel {
        id: liveUsageListModel
    }

    ListModel {
        id: historyUsageListModel
    }

    function setMenuOpen(opened) {
        root.isMenuOpen = opened;
        root.syncTimers(true);
    }

    function setUsageState(expanded, activeTab) {
        root.usageExpanded = expanded;
        root.usageActiveTab = activeTab;
        root.syncTimers(true);
    }

    function syncTimers(runImmediate = false) {
        wifiScanTimer.running = root.isMenuOpen;
        liveSamplingTimer.running = root.shouldCollectLiveSamples();
        historyRefreshTimer.running = root.shouldCollectHistory();

        if (!runImmediate || !root.isMenuOpen)
            return;

        root.scanWifi();
        root.refreshCurrentUsageTab();

        // Collect live samples in background so history keeps moving even outside Live tab.
        if (root.shouldCollectLiveSamples())
            root.refreshLiveUsage();

        if (root.shouldCollectHistory())
            root.refreshHistoryUsage();
    }

    function shouldRunUsageSection() {
        return root.isMenuOpen && root.usageExpanded;
    }

    function shouldCollectLiveSamples() {
        return root.shouldRunUsageSection();
    }

    function shouldCollectHistory() {
        return root.shouldRunUsageSection();
    }

    function refreshCurrentUsageTab() {
        if (!root.isMenuOpen)
            return;

        if (root.usageActiveTab === 0) {
            root.refreshDataUsage();
            return;
        }

        if (root.usageActiveTab === 1) {
            root.refreshLiveUsage();
            return;
        }

        root.refreshHistoryUsage();
    }

    function scanWifi() {
        if (wifiScannerProcess.running)
            return;

        wifiScannerProcess.command = Utils.Helper.listWifiCommand(root.wifiInterface);
        wifiScannerProcess.running = true;
    }

    function connectToWifi(ssid, password, closeLeftbar = true) {
        root.runWifiAction(Utils.Helper.connectWifiCommand({
            ssid,
            command: "connect",
            password,
            wifiInterface: root.wifiInterface
        }), closeLeftbar);
    }

    function connectToHiddenWifi(ssid, password, closeLeftbar = true) {
        root.connectToWifi(ssid, password, closeLeftbar);
    }

    function disconnectWifi(ssid) {
        root.runWifiAction(Utils.Helper.connectWifiCommand({
            ssid,
            command: "disconnect",
            wifiInterface: root.wifiInterface
        }), false);
    }

    function forgetWifi(ssid) {
        root.runWifiAction(Utils.Helper.connectWifiCommand({
            ssid,
            command: "delete",
            wifiInterface: root.wifiInterface
        }), false);
    }

    function runWifiAction(fullCommand, closeLeftbar) {
        if (wifiActionProcess.running)
            return;

        wifiActionProcess.closeLeftbar = closeLeftbar;
        wifiActionProcess.command = fullCommand;
        wifiActionProcess.running = true;
    }

    function refreshDataUsage() {
        if (!dataUsageProcess.running) {
            dataUsageProcess.command = Utils.Helper.wifiDataUsageCommand({
                wifiInterface: root.wifiInterface
            });
            dataUsageProcess.running = true;
        }

        if (!dailyDataUsageProcess.running) {
            const todayIso = root.localIsoDate(new Date());
            dailyDataUsageProcess.command = Utils.Helper.wifiDataUsageCommand({
                wifiInterface: root.wifiInterface,
                startDate: todayIso,
                endDate: todayIso
            });
            dailyDataUsageProcess.running = true;
        }
    }

    function refreshLiveUsage() {
        if (liveUsageProcess.running)
            return;

        root.liveUsageLoading = true;
        liveUsageProcess.command = Utils.Helper.wifiLiveUsageCommand({
            limit: root.liveLimit,
            wifiInterface: root.wifiInterface
        });
        liveUsageProcess.running = true;
    }

    function refreshHistoryUsage() {
        if (historyUsageProcess.running)
            return;

        root.historyUsageLoading = true;
        historyUsageProcess.command = Utils.Helper.wifiLiveUsageSummaryCommand({
            hours: root.historyHours,
            top: root.historyTop,
            wifiInterface: root.wifiInterface
        });
        historyUsageProcess.running = true;
    }

    function localIsoDate(dateObj) {
        const y = dateObj.getFullYear();
        const m = (dateObj.getMonth() + 1).toString().padStart(2, "0");
        const d = dateObj.getDate().toString().padStart(2, "0");
        return `${y}-${m}-${d}`;
    }

    function formatBytes(bytes, decimals = 2) {
        if (!+bytes)
            return "0 Bytes";

        const k = 1024;
        const sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB"];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return `${parseFloat((bytes / Math.pow(k, i)).toFixed(decimals < 0 ? 0 : decimals))} ${sizes[i]}`;
    }

    function formatRate(bytesPerSecond) {
        return `${root.formatBytes(bytesPerSecond)}/s`;
    }

    function sanitizeProcessName(name) {
        if (!name || name.trim() === "")
            return qsTr("Unknown");
        return name;
    }

    function updateLiveUsageModel(liveRows) {
        const rows = Array.isArray(liveRows) ? liveRows : [];
        liveUsageListModel.clear();

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

            liveUsageListModel.append({
                display_name: `${processName} (${pid})`,
                rx_text: rxRate > 0 ? root.formatRate(rxRate) : root.formatBytes(bytesRecv),
                tx_text: txRate > 0 ? root.formatRate(txRate) : root.formatBytes(bytesSent),
                total_text: totalRate > 0 ? root.formatRate(totalRate) : root.formatBytes(bytesTotal),
                connections_count: connectionsCount
            });
        }

        const updatedAt = Qt.formatTime(new Date(), "hh:mm:ss");
        if (liveUsageListModel.count > 0) {
            root.liveUsageSubtitle = qsTr("Updated %1 • %2 active apps").arg(updatedAt).arg(liveUsageListModel.count);
            return;
        }

        root.liveUsageSubtitle = qsTr("Updated %1 • No active apps").arg(updatedAt);
    }

    function updateHistoryUsageModel(summaryResponse) {
        const rows = Array.isArray(summaryResponse.data) ? summaryResponse.data : [];
        const totals = summaryResponse.totals || {};
        historyUsageListModel.clear();

        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            const name = root.sanitizeProcessName(row.name);
            const totalBytes = Number(row.total_bytes) || 0;
            const peakRate = Number(row.peak_rate_bps) || 0;

            historyUsageListModel.append({
                display_name: name,
                total_text: root.formatBytes(totalBytes),
                peak_text: root.formatRate(peakRate)
            });
        }

        root.historyUsageTotal = root.formatBytes(Number(totals.total_bytes) || 0);
        root.historyUsagePeak = root.formatRate(Number(totals.peak_rate_bps) || 0);
        root.historyUsageSamples = `${Number(totals.samples_count) || 0}`;

        const updatedAt = Qt.formatTime(new Date(), "hh:mm:ss");
        const rangeHours = Number(summaryResponse.range_hours) || root.historyHours;
        root.historyUsageSubtitle = qsTr("Last %1h • Updated %2").arg(rangeHours).arg(updatedAt);
    }

    Process {
        id: wifiScannerProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(data);
                    root.wifiNetworks = Array.isArray(parsed) ? parsed : [];
                    root.wifiNetworksUpdated(root.wifiNetworks);
                } catch (e) {
                    console.error("[NetworkService] Wifi scan parse error:", e);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("[NetworkService] Wifi scan stderr:", data)
        }
    }

    Process {
        id: wifiActionProcess
        property bool closeLeftbar: false

        stdout: StdioCollector {
            onStreamFinished: {
                let isSuccess = false;
                let message = "";

                try {
                    const response = JSON.parse(data);
                    isSuccess = response.status === "success";
                    message = response.message || "";
                } catch (e) {
                    message = `${e}`;
                }

                root.wifiActionFinished(isSuccess, wifiActionProcess.closeLeftbar, message);

                if (isSuccess)
                    root.scanWifi();
            }
        }
        stderr: SplitParser {
            onRead: data => root.wifiActionFinished(false, wifiActionProcess.closeLeftbar, data)
        }
    }

    Process {
        id: dataUsageProcess
        command: Utils.Helper.wifiDataUsageCommand({
            wifiInterface: root.wifiInterface
        })
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status !== "success")
                        return;

                    root.usageSubtitle = `Monthly: ${response.period.start} to ${response.period.end}`;
                    root.receivedData = root.formatBytes(response.usage_bytes.received);
                    root.sentData = root.formatBytes(response.usage_bytes.sent);
                    root.totalData = root.formatBytes(response.usage_bytes.total);
                } catch (e) {
                    console.error("[NetworkService] Monthly usage parse error:", e);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("[NetworkService] Monthly usage stderr:", data)
        }
    }

    Process {
        id: dailyDataUsageProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status !== "success")
                        return;

                    root.dailyReceivedData = root.formatBytes(response.usage_bytes.received);
                    root.dailySentData = root.formatBytes(response.usage_bytes.sent);
                    root.dailyTotalData = root.formatBytes(response.usage_bytes.total);
                } catch (e) {
                    console.error("[NetworkService] Daily usage parse error:", e);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("[NetworkService] Daily usage stderr:", data)
        }
    }

    Process {
        id: liveUsageProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        root.updateLiveUsageModel(response.data);
                        if (response.warning && liveUsageListModel.count === 0)
                            root.liveUsageSubtitle = qsTr("Live rate unavailable (fallback mode)");
                    } else {
                        root.liveUsageSubtitle = qsTr("Unable to read live app usage");
                    }
                } catch (e) {
                    console.error("[NetworkService] Live usage parse error:", e);
                    root.liveUsageSubtitle = qsTr("Unable to parse live app usage");
                }

                root.liveUsageLoading = false;
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.error("[NetworkService] Live usage stderr:", data);
                root.liveUsageLoading = false;
            }
        }
    }

    Process {
        id: historyUsageProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        root.updateHistoryUsageModel(response);
                    } else {
                        root.historyUsageSubtitle = qsTr("Unable to read usage history");
                    }
                } catch (e) {
                    console.error("[NetworkService] History usage parse error:", e);
                    root.historyUsageSubtitle = qsTr("Unable to parse usage history");
                }

                root.historyUsageLoading = false;
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.error("[NetworkService] History usage stderr:", data);
                root.historyUsageLoading = false;
            }
        }
    }

    Timer {
        id: wifiScanTimer
        interval: 5000
        repeat: true
        running: false
        onTriggered: root.scanWifi()
    }

    Timer {
        id: liveSamplingTimer
        interval: 2000
        repeat: true
        running: false
        onTriggered: root.refreshLiveUsage()
    }

    Timer {
        id: historyRefreshTimer
        interval: 30000
        repeat: true
        running: false
        onTriggered: root.refreshHistoryUsage()
    }
}
