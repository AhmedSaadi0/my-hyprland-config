// windows/leftwindow/dashboard/PowerOptions.qml

import QtQuick

import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import org.kde.kirigami as Kirigami

import "root:/themes"
import "root:/utils/helpers.js" as Helpers
import "root:/components"

MenuCard {
    id: root

    title: qsTr("Power Options")
    icon: ""

    property int buttonHeight: 25
    property int buttonsRowSpacing: 10
    property string iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    property color baseTextColor: ThemeManager.selectedTheme.colors.topbarFgColorV2
    property color highlightedStateTextColor: ThemeManager.selectedTheme.colors.onSecondary
    property color activeStateBackgroundColor: ThemeManager.selectedTheme.colors.secondary
    property color defaultStateBackgroundColor: Kirigami.Theme.activeBackgroundColor

    property string powerOffButtonLabel: qsTr("⏻")
    property string rebootButtonLabel: qsTr("")
    property string logoutButtonLabel: qsTr("")
    property string confirmNoText: qsTr("")

    property var pendingActionCommand: []
    property string pendingActionMessage: ""
    property string confirmActionText: ""

    StackView {
        id: viewStack
        Layout.fillWidth: true
        implicitHeight: root.buttonHeight

        initialItem: RowLayout {
            spacing: root.buttonsRowSpacing

            MButton {
                Layout.fillWidth: true
                Layout.preferredHeight: root.buttonHeight
                text: root.powerOffButtonLabel
                font.family: root.iconFontFamily
                onClicked: {
                    root.pendingActionCommand = ["systemctl", "poweroff"];
                    root.pendingActionMessage = qsTr("Confirm Power Off");
                    root.confirmActionText = qsTr("Power off ⏻");
                    viewStack.push(confirmationView);
                }
            }
            MButton {
                Layout.fillWidth: true
                Layout.preferredHeight: root.buttonHeight
                text: root.rebootButtonLabel
                font.family: root.iconFontFamily
                onClicked: {
                    root.pendingActionCommand = ["systemctl", "reboot"];
                    root.pendingActionMessage = qsTr("Confirm Reboot");
                    root.confirmActionText = qsTr("Reboot ");
                    viewStack.push(confirmationView);
                }
            }
            MButton {
                Layout.fillWidth: true
                Layout.preferredHeight: root.buttonHeight
                text: root.logoutButtonLabel
                font.family: root.iconFontFamily
                onClicked: {
                    root.pendingActionCommand = ["hyprctl", "dispatch", "exit"];
                    root.pendingActionMessage = qsTr("Confirm Logout");
                    root.confirmActionText = qsTr("Log out ");
                    viewStack.push(confirmationView);
                }
            }
        }

        Component {
            id: confirmationView
            RowLayout {
                spacing: 0

                MButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.buttonHeight
                    text: root.confirmNoText
                    font.family: root.iconFontFamily
                    topRightRadius: 0
                    bottomRightRadius: 0
                    onClicked: viewStack.pop()
                }

                MButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.buttonHeight
                    text: root.confirmActionText
                    normalBackground: root.activeStateBackgroundColor
                    normalForeground: Helpers.getAccurteTextColor(root.activeStateBackgroundColor)
                    font.family: root.iconFontFamily
                    topLeftRadius: 0
                    bottomLeftRadius: 0
                    onClicked: {
                        powerActionProcess.start();
                        viewStack.pop();
                    }
                }
            }
        }

        pushEnter: Transition {
            NumberAnimation {
                properties: "y"
                from: 20
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                properties: "opacity"
                from: 0
                to: 1
                duration: 150
            }
        }
        pushExit: Transition {
            NumberAnimation {
                properties: "y"
                from: 0
                to: -20
                duration: 200
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                properties: "opacity"
                from: 1
                to: 0
                duration: 150
            }
        }
        popEnter: Transition {
            NumberAnimation {
                properties: "y"
                from: -20
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                properties: "opacity"
                from: 0
                to: 1
                duration: 150
            }
        }
        popExit: Transition {
            NumberAnimation {
                properties: "y"
                from: 0
                to: 20
                duration: 200
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                properties: "opacity"
                from: 1
                to: 0
                duration: 150
            }
        }
    }

    states: [
        State {
            name: "confirmation"
            when: viewStack.depth > 1
            PropertyChanges {
                target: root
                title: root.pendingActionMessage
            }
        },
        State {
            name: "default"
            when: viewStack.depth <= 1
            PropertyChanges {
                target: root
                title: qsTr("Power Options")
            }
        }
    ]

    Process {
        id: powerActionProcess
        running: false
        property string lastStderrOutput: ""
        property string lastStdoutOutput: ""

        function start() {
            command = root.pendingActionCommand;
            running = true;
        }

        stderr: SplitParser {
            onRead: data => {
                powerActionProcess.lastStderrOutput += data;
                console.warn("Power action stderr:", data);
            }
        }

        stdout: SplitParser {
            onRead: data => {
                powerActionProcess.lastStdoutOutput += data;
                console.log("Power action stdout:", data);
            }
        }

        onRunningChanged: if (running) {
            lastStderrOutput = "";
            lastStdoutOutput = "";
        }

        onExited: {
            if (exitCode !== 0)
                console.error("Power action failed! Exit Code:", exitCode, "Stderr:", lastStderrOutput);
            else
                console.log("Power action completed successfully.");
        }
    }
}
