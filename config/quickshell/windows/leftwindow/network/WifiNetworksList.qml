// windows/leftwindow/network/WifiNetworksList.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"
import "."

ScrollView {
    id: root

    property var model
    property string expandedBssid: ""
    property string loadingBssid: ""
    property alias currentIndex: listView.currentIndex

    signal expandedBssidSelected(string bssid)
    signal connectClicked(string ssid, string password)
    signal disconnectClicked(string ssid)
    signal forgetClicked(string ssid)

    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ListView {
        id: listView
        anchors.fill: parent
        model: root.model
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
                const newBssid = (listView.currentIndex !== -1) ? model.bssid : "";
                root.expandedBssidSelected(newBssid);
            }
            onConnectClicked: (ssid, password) => root.connectClicked(ssid, password)
            onDisconnectClicked: ssid => root.disconnectClicked(ssid)
            onForgetClicked: ssid => root.forgetClicked(ssid)
        }

        Label {
            anchors.centerIn: parent
            visible: listView.model && listView.model.count === 0
            text: qsTr("Searching for networks ...")
            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.7)
        }
    }
}
