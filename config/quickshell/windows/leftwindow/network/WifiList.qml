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
        property bool closeLeftbar: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(data);
                    if (response.status === "success") {
                        console.log("Wifi Action Success:", response.message);
                        listView.currentIndex = -1;
                        root.expandedBssid = "";

                        if (wifiActionProcess.closeLeftbar) {
                            EventBus.emit(Events.CLOSE_LEFTBAR);
                        }

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

        function startAction(fullCommand, closeLeftbar = false) {
            root.loadingBssid = root.expandedBssid;
            this.closeLeftbar = closeLeftbar;
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

    // Process for monthly data usage
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

    // Process for daily data usage
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
                    } else {
                        console.error("Daily Data Usage Error:", response.message);
                    }
                } catch (e) {
                    console.error("Daily Data Usage JSON Parse Error:", e);
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                console.error("Daily Data Usage Stderr:", data);
            }
        }

        function start() {
            const today = new Date();
            const tomorrow = new Date();
            tomorrow.setDate(today.getDate() + 1);

            const startDate = today.toISOString().slice(0, 10);
            const endDate = tomorrow.toISOString().slice(0, 10);

            this.command = Utils.Helper.wifiDataUsageCommand({
                startDate: startDate,
                endDate: endDate
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
                if (networkArray[i].ssid) {
                    wifiModel.append(networkArray[i]);
                }
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
        EventBus.on(Events.LEFT_MENU_IS_OPENED, function () {
            wifiScannerProcess.scan();
            scanTimer.running = true;
            scanTimer.repeat = true;
            dataUsageProcess.start();
            dailyDataUsageProcess.start();
        });

        EventBus.on(Events.LEFT_MENU_IS_CLOSED, function () {
            scanTimer.running = false;
            scanTimer.repeat = false;
        });
    }

    // ***** START: ADAPTIVE DATA USAGE CARD *****
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
        property string dailyReceivedData: "..."
        property string dailySentData: "..."
        property string dailyTotalData: "..."

        onIconClicked: {
            rotationAnim.start();
            dataUsageProcess.start();
            dailyDataUsageProcess.start();
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

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 10
            rowSpacing: 8

            // --- HEADERS ---
            Item {
                Layout.fillWidth: true
            } // Empty cell for alignment
            Label {
                text: qsTr("Today")
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("This Month")
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            // --- RECEIVED ROW ---
            RowLayout {
                spacing: 14
                Label {
                    text: "󰁅" // nf-md-arrow_down
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    text: qsTr("Received")
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Label {
                text: dataUsage.dailyReceivedData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Label {
                text: dataUsage.receivedData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            // --- SENT ROW ---
            RowLayout {
                spacing: 14
                Label {
                    text: "󰁝" // nf-md-arrow_up
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    text: qsTr("Sent")
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Label {
                text: dataUsage.dailySentData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Label {
                text: dataUsage.sentData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            // --- TOTAL ROW ---
            RowLayout {
                spacing: 6
                Label {
                    text: "󰯙" // nf-md-swap_vertical
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    text: qsTr("Total")
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Label {
                text: dataUsage.dailyTotalData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Label {
                text: dataUsage.totalData
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }
    // ***** END: ADAPTIVE DATA USAGE CARD *****

    ColumnLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: 10
        spacing: 0

        MButton {
            id: hiddenToggleBtn
            Layout.fillWidth: true

            text: qsTr("Connect to Hidden Network") + "  󰤨"

            normalBackground: hiddenNetworkContainer.isOpen ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.leftMenuBgColorV2
            normalForeground: hiddenNetworkContainer.isOpen ? ThemeManager.selectedTheme.colors.onPrimary : ThemeManager.selectedTheme.colors.leftMenuFgColorV1

            onClicked: {
                hiddenNetworkContainer.isOpen = !hiddenNetworkContainer.isOpen;
            }
        }

        Item {
            id: hiddenNetworkContainer
            Layout.fillWidth: true
            Layout.topMargin: isOpen ? 10 : 0

            property bool isOpen: false

            implicitHeight: isOpen ? contentRect.implicitHeight : 0

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on Layout.topMargin {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            clip: true

            opacity: isOpen ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }

            Rectangle {
                id: contentRect
                width: parent.width
                implicitHeight: hiddenFormLayout.implicitHeight + 24

                color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2.alpha(0.5)
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.2)
                border.width: 1

                ColumnLayout {
                    id: hiddenFormLayout
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 12
                    spacing: 12

                    EditableField {
                        id: hiddenSsidField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Network Name (SSID)")
                        font.pixelSize: 14

                        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                        placeholderTextColor: ThemeManager.selectedTheme.colors.subtleText

                        background: Rectangle {
                            color: ThemeManager.selectedTheme.colors.leftMenuBgColorV3.alpha(0.5)
                            radius: ThemeManager.selectedTheme.dimensions.elementRadius
                            border.color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.1)
                            border.width: 1
                        }
                    }

                    EditableField {
                        id: hiddenPasswordField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Password (Optional)")
                        echoMode: TextInput.Password
                        font.pixelSize: 14

                        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                        placeholderTextColor: ThemeManager.selectedTheme.colors.subtleText

                        background: Rectangle {
                            color: ThemeManager.selectedTheme.colors.leftMenuBgColorV3.alpha(0.5)
                            radius: ThemeManager.selectedTheme.dimensions.elementRadius
                            border.color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.1)
                            border.width: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MButton {
                            Layout.fillWidth: true
                            text: qsTr("Connect")

                            normalBackground: ThemeManager.selectedTheme.colors.primary.darker(1.1)
                            normalForeground: ThemeManager.selectedTheme.colors.onPrimary

                            enabled: hiddenSsidField.text.length > 0

                            onClicked: {
                                root.connectToHiddenWifi(hiddenSsidField.text, hiddenPasswordField.text);
                                hiddenSsidField.text = "";
                                hiddenPasswordField.text = "";
                                hiddenNetworkContainer.isOpen = false;
                            }
                        }
                    }
                }
            }
        }
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
        wifiActionProcess.startAction(command, true);
    }

    function connectToHiddenWifi(ssid, password) {
        const command = Utils.Helper.connectWifiCommand({
            ssid: ssid,
            command: "connect",
            password: password
            // hidden: true
        });
        wifiActionProcess.startAction(command, true);
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
