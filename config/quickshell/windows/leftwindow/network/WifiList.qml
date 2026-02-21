// windows/leftwindow/network/WifiList.qml

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
    MenuCard {
        id: dataUsage
        Layout.fillWidth: true

        Layout.topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        cardColor: ThemeManager.selectedTheme.colors.primary.alpha(0.4)
        cardLeftPadding: 8
        cardRightPadding: 8

        title: "Data Usage"
        subtitle: "Loading data..."
        icon: "󰑓"
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

            Item {
                Layout.fillWidth: true
            }
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

            RowLayout {
                spacing: 14
                Label {
                    text: "󰁅"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                }
                Label {
                    text: qsTr("Received")
                    font.bold: true
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

            RowLayout {
                spacing: 14
                Label {
                    text: "󰁝"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                }
                Label {
                    text: qsTr("Sent")
                    font.bold: true
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

            RowLayout {
                spacing: 6
                Label {
                    text: "󰯙"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 22
                }
                Label {
                    text: qsTr("Total")
                    font.bold: true
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

    // ─── المحتوى ─────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        spacing: 0

        // زر الشبكة المخفية
        MButton {
            id: hiddenToggleBtn
            Layout.fillWidth: true
            text: qsTr("Connect to Hidden Network") + "  󰤨"
            normalBackground: hiddenNetworkContainer.isOpen ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.leftMenuBgColorV2
            normalForeground: hiddenNetworkContainer.isOpen ? ThemeManager.selectedTheme.colors.onPrimary : ThemeManager.selectedTheme.colors.leftMenuFgColorV1
            onClicked: hiddenNetworkContainer.isOpen = !hiddenNetworkContainer.isOpen
        }

        // نموذج الشبكة المخفية
        Item {
            id: hiddenNetworkContainer
            Layout.fillWidth: true
            Layout.topMargin: isOpen ? 10 : 0
            property bool isOpen: false
            implicitHeight: isOpen ? contentRect.implicitHeight : 0
            clip: true
            opacity: isOpen ? 1.0 : 0.0

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
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 12
                    }
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

    // قائمة الشبكات
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
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
                onConnectClicked: (ssid, password) => root.connectToWifi(ssid, password)
                onDisconnectClicked: ssid => root.disconnectFromWifi(ssid)
                onForgetClicked: ssid => root.forgetWifi(ssid)
            }

            Label {
                anchors.centerIn: parent
                visible: listView.model.count === 0
                text: qsTr("Searching for networks ...")
                color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.7)
            }
        }
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
                        listView.currentIndex = -1;
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
                    listView.currentIndex = i;
                    return;
                }
            }
            root.expandedBssid = "";
            listView.currentIndex = -1;
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
