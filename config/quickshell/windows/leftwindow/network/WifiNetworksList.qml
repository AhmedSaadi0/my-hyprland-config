// windows/leftwindow/network/WifiNetworksList.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"
import "."

Item {
    id: root

    property var model
    property string expandedBssid: ""
    property string loadingBssid: ""
    property int currentIndex: -1

    signal expandedBssidSelected(string bssid)
    signal connectClicked(string ssid, string password)
    signal disconnectClicked(string ssid)
    signal forgetClicked(string ssid)

    Layout.fillWidth: true
    implicitHeight: contentColumn.implicitHeight

    Column {
        id: contentColumn
        width: parent.width
        spacing: ThemeManager.selectedTheme.dimensions.spacingMedium

        Repeater {
            model: root.model

            Row {
                width: contentColumn.width
                height: wifiItem.height
                spacing: 0

                WifiItem {
                    id: wifiItem
                    width: parent.width
                    ssid: model.ssid
                    bssid: model.bssid
                    signal: model.signal
                    security: model.security
                    in_use: model.in_use
                    is_saved: model.is_saved
                    expanded: root.expandedBssid === model.bssid
                    isLoading: root.loadingBssid === model.bssid

                    onItemToggled: {
                        if (root.loadingBssid === wifiItem.bssid)
                            return;
                        root.currentIndex = (root.currentIndex === index ? -1 : index);
                        const newBssid = (root.currentIndex !== -1) ? wifiItem.bssid : "";
                        root.expandedBssidSelected(newBssid);
                    }
                    onConnectClicked: (ssid, password) => root.connectClicked(ssid, password)
                    onDisconnectClicked: ssid => root.disconnectClicked(ssid)
                    onForgetClicked: ssid => root.forgetClicked(ssid)
                }
            }
        }

        Label {
            width: contentColumn.width
            horizontalAlignment: Text.AlignHCenter
            topPadding: ThemeManager.selectedTheme.dimensions.spacingMedium
            bottomPadding: ThemeManager.selectedTheme.dimensions.spacingMedium
            visible: root.model && root.model.count === 0
            text: qsTr("Searching for networks ...")
            color: ThemeManager.selectedTheme.colors.onSurface.alpha(0.7)
        }
    }
}
