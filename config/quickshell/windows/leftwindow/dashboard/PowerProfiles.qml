import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import org.kde.kirigami as Kirigami

import "../../../themes"
import "../../../components"

Rectangle {
    id: root

    height: 85
    // width: 400

    color: Kirigami.Theme.backgroundColor.lighter(1.4)

    property string textHighlightColor: Kirigami.Theme.highlightedTextColor
    property string textColor: Kirigami.Theme.textColor
    property string highlightColor: Kirigami.Theme.activeTextColor

    property int buttonWidth: 100
    property int buttonHeight: 30
    property int themeRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    property var selectedProfile: PowerProfiles.profile
    property string selectedProfileText: ""

    radius: themeRadius

    layer.enabled: true
    layer.effect: Shadow {}

    Text {
        id: icon
        width: 10
        text: ""
        font.family: ThemeManager.selectedTheme.typography.iconFont
        font.bold: true
        // font.pixelSize: ThemeManager.selectedTheme.typography.heading2Size
        color: Kirigami.Theme.textColor
        anchors {
            top: parent.top
            right: parent.right
            // verticalCenter: parent.verticalCenter
            // horizontalCenter: parent.horizontalCenter
            topMargin: 17
            rightMargin: 20
            leftMargin: 20
        }
    }

    Text {
        id: title
        text: "وضع الاداء"
        // text: "english"
        font.pixelSize: ThemeManager.selectedTheme.typography.heading2Size
        font.bold: true
        color: Kirigami.Theme.textColor
        horizontalAlignment: Text.AlignRight
        anchors {
            top: parent.top
            left: parent.left
            right: icon.left
            topMargin: 5
            rightMargin: 10
            leftMargin: 20
        }
    }

    Row {
        id: widgetsRow
        // width: parent.width
        anchors {
            top: title.bottom
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
            topMargin: 5
        }

        spacing: 10

        MButton {
            id: highPerformance
            width: root.buttonWidth
            height: root.buttonHeight
            text: "High"
            onClicked: {
                root.selectedProfileText = "performance";
                profileProcess.running = true;
            }

            normalBackground: {
                if (root.selectedProfile === 2) {
                    return root.highlightColor;
                }
                return Kirigami.Theme.backgroundColor;
            }

            normalForeground: {
                if (root.selectedProfile === 2) {
                    return root.textHighlightColor;
                }
                return root.textColor;
            }
        }

        MButton {
            id: balance
            width: root.buttonWidth
            height: root.buttonHeight
            text: "Balanced"
            onClicked: {
                root.selectedProfileText = "balanced";
                profileProcess.running = true;
            }

            normalBackground: {
                if (root.selectedProfile === 1) {
                    return root.highlightColor;
                }
                return Kirigami.Theme.backgroundColor;
            }

            normalForeground: {
                if (root.selectedProfile === 1) {
                    return root.textHighlightColor;
                }
                return root.textColor;
            }
        }

        MButton {
            id: batterySaving
            width: root.buttonWidth
            height: root.buttonHeight
            text: "Low"
            onClicked: {
                root.selectedProfileText = "power-saver";
                profileProcess.running = true;
            }

            normalBackground: {
                if (root.selectedProfile === 0) {
                    return root.highlightColor;
                }
                return Kirigami.Theme.backgroundColor;
            }

            normalForeground: {
                if (root.selectedProfile === 0) {
                    return root.textHighlightColor;
                }
                return root.textColor;
            }
        }
    }

    Process {
        id: profileProcess
        running: false
        command: ["powerprofilesctl", "set", root.selectedProfileText]
        stderr: SplitParser {
            onRead: data => {
                console.error(`Error changing power profile: ${data}`);
            }
        }
        // stdout: SplitParser {
        //     onRead: data => {
        //         console.warn(`line read: ${data}`);
        //     }
        // }
    }
}
