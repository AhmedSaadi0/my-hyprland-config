// windows/leftwindow/network/WifiList.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"
import "root:/components"
import "root:/services"
import "../base"

BaseMenuView {
    id: root

    menuTitle: qsTr("Network")
    menuIcon: "󰖩"
    showPrimaryAction: false

    property string expandedBssid: ""
    property string loadingBssid: ""
    property bool isLeftMenuOpen: false

    DataUsageHeader {
        id: dataUsage
        Layout.fillWidth: true

        subtitle: NetworkService.usageSubtitle
        receivedData: NetworkService.receivedData
        sentData: NetworkService.sentData
        totalData: NetworkService.totalData
        dailyReceivedData: NetworkService.dailyReceivedData
        dailySentData: NetworkService.dailySentData
        dailyTotalData: NetworkService.dailyTotalData

        liveUsageModel: NetworkService.liveUsageModel
        liveUsageSubtitle: NetworkService.liveUsageSubtitle
        liveUsageLoading: NetworkService.liveUsageLoading

        historyUsageModel: NetworkService.historyUsageModel
        historyUsageSubtitle: NetworkService.historyUsageSubtitle
        historyUsageLoading: NetworkService.historyUsageLoading
        historyUsageTotal: NetworkService.historyUsageTotal
        historyUsagePeak: NetworkService.historyUsagePeak
        historyUsageSamples: NetworkService.historyUsageSamples

        onRefreshRequested: NetworkService.refreshCurrentUsageTab()
        onLiveUsageRefreshRequested: NetworkService.refreshCurrentUsageTab()
        onHistoryUsageRefreshRequested: NetworkService.refreshCurrentUsageTab()
        onActiveTabChanged: NetworkService.setUsageState(dataUsage.expanded, dataUsage.activeTab)
        onExpandedChanged: NetworkService.setUsageState(dataUsage.expanded, dataUsage.activeTab)
    }

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

    Connections {
        target: NetworkService

        function onWifiNetworksUpdated(networks) {
            root.updateWifiModel(networks);
        }

        function onWifiActionFinished(success, closeLeftbar, message) {
            if (success) {
                wifiList.currentIndex = -1;
                root.expandedBssid = "";

                if (closeLeftbar)
                    EventBus.emit(Events.CLOSE_LEFTBAR);
            } else if (message && message.length > 0) {
                console.error("[WifiList] Wifi action failed:", message);
            }

            root.loadingBssid = "";
        }
    }

    ListModel {
        id: wifiModel
    }

    Component.onCompleted: {
        root.safeStartWifiScan();
        NetworkService.setUsageState(dataUsage.expanded, dataUsage.activeTab);

        EventBus.on(Events.LEFT_MENU_IS_OPENED, () => {
            root.isLeftMenuOpen = true;
            root.safeStartWifiScan();
            NetworkService.setMenuOpen(true);
            NetworkService.setUsageState(dataUsage.expanded, dataUsage.activeTab);
        }, root);

        EventBus.on(Events.LEFT_MENU_IS_CLOSED, () => {
            root.isLeftMenuOpen = false;
            NetworkService.setMenuOpen(false);
        }, root);
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

    function safeStartWifiScan() {
        NetworkService.scanWifi();
    }

    function connectToWifi(ssid, password) {
        root.loadingBssid = root.expandedBssid;
        NetworkService.connectToWifi(ssid, password, true);
    }

    function connectToHiddenWifi(ssid, password) {
        root.loadingBssid = root.expandedBssid;
        NetworkService.connectToHiddenWifi(ssid, password, true);
    }

    function disconnectFromWifi(ssid) {
        root.loadingBssid = root.expandedBssid;
        NetworkService.disconnectWifi(ssid);
    }

    function forgetWifi(ssid) {
        root.loadingBssid = root.expandedBssid;
        NetworkService.forgetWifi(ssid);
    }
}
