// windows/leftwindow/dashboard/PowerOptions.qml

// import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick
import QtQuick.Controls
import Quickshell.Io // Needed for the Process component
// Removed Quickshell.Services.UPower as it's no longer directly used for power actions
import org.kde.kirigami as Kirigami

import "../../../themes"
import "../../../components"

// Rectangle {
MenuCard {
    id: root

    width: ThemeManager.selectedTheme.dimensions.menuWidth - (ThemeManager.selectedTheme.dimensions.menuWidgetsMargin * 2)
    height: 120

    // -------------------------------------------------------------------------
    // --- Configuration Properties (Constants & Theme Aliases)
    // -------------------------------------------------------------------------

    // --- Dimensions ---
    property int defaultButtonWidth: 100
    property int defaultButtonHeight: 30
    property int componentRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property var animationDuration: 400

    property int buttonsRowSpacing: 10

    // Confirmation dialog dimensions/margins
    property int confirmationPadding: 22
    property int confirmationButtonWidth: 160
    property int confirmationButtonHeight: 25
    property int confirmationButtonsSpacing: 0

    // --- Colors (Aliasing Theme colors for clarity and central access) ---
    property color componentBackgroundColor: ThemeManager.selectedTheme.colors.topbarBgColorV2
    property color baseTextColor: ThemeManager.selectedTheme.colors.topbarFgColorV2
    property color highlightedStateTextColor: Kirigami.Theme.highlightedTextColor
    property color activeStateBackgroundColor: Kirigami.Theme.activeTextColor
    property color defaultStateBackgroundColor: Kirigami.Theme.activeBackgroundColor

    // --- Fonts (Aliasing Theme fonts) ---
    property string iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    property int headingFontSize: ThemeManager.selectedTheme.typography.heading3Size
    property int confirmationMessageFontSize: Kirigami.Theme.defaultFont.pixelSize * 1.2

    // --- Texts & Content ---
    title: qsTr("Power Options")
    icon: ""

    // Power option button labels (using appropriate icons from FontAwesome 6/Nerd Fonts)
    // ⏻ (U+23FB) - Power off icon
    //  (U+EB52) - Reboot icon (Nerd Font specific)
    //  (U+F08B) - Logout icon
    property string powerOffButtonLabel: qsTr("⏻")
    property string rebootButtonLabel: qsTr("")
    property string logoutButtonLabel: qsTr("")

    // Confirmation dialog texts
    property string confirmationTitleText: qsTr("Confirm Action")
    property string confirmYesText: qsTr("Continue  ")
    property string confirmNoText: qsTr("")

    // -------------------------------------------------------------------------
    // --- State Properties for confirmation logic
    // -------------------------------------------------------------------------
    // Stores the command array to be executed upon 'Yes' confirmation
    property var pendingActionCommand: []
    // Stores the descriptive message for the confirmation dialog
    property string pendingActionMessage: ""

    // -------------------------------------------------------------------------
    // --- Root Visual Properties
    // -------------------------------------------------------------------------
    // color: root.componentBackgroundColor
    // radius: root.componentRadius

    // The StackView will manage different "screens" within this component
    StackView {
        id: viewStack

        implicitWidth: parent.implicitWidth

        // The initial screen displaying the power options buttons
        initialItem: Item {
            id: mainPowerOptionsScreen
            // anchors.fill: viewStack

            Row {
                id: powerOptionsButtonsRow

                spacing: root.buttonsRowSpacing

                MButton {
                    id: powerOffButton
                    width: root.defaultButtonWidth
                    height: root.defaultButtonHeight
                    text: root.powerOffButtonLabel
                    font.family: ThemeManager.selectedTheme.typography.iconFont // Use icon font
                    normalBackground: root.defaultStateBackgroundColor // Consistent styling
                    normalForeground: root.baseTextColor
                    onClicked: {
                        root.pendingActionCommand = ["systemctl", "poweroff"];
                        root.pendingActionMessage = qsTr("Are you sure you want to power off?");
                        root.confirmYesText = qsTr("Power off");
                        viewStack.push(confirmationDialogComponent);
                    }
                }

                MButton {
                    id: logoutButton
                    width: root.defaultButtonWidth
                    height: root.defaultButtonHeight
                    text: root.logoutButtonLabel
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    normalBackground: root.defaultStateBackgroundColor
                    normalForeground: root.baseTextColor
                    onClicked: {
                        // For KDE Plasma logout using qdbus to KSMServer
                        // root.pendingActionCommand = ["qdbus", "org.kde.ksmserver", "/KSMServer", "logout", "0", "0", "0"];
                        // root.pendingActionCommand = ["loginctl", "kill-session", "self"];
                        root.pendingActionCommand = ["hyprctl", "dispatch", "exit"];
                        root.pendingActionMessage = qsTr("Are you sure you want to log out?");
                        root.confirmYesText = qsTr("Log out");
                        viewStack.push(confirmationDialogComponent);
                    }
                }

                MButton {
                    id: rebootButton
                    width: root.defaultButtonWidth
                    height: root.defaultButtonHeight
                    text: root.rebootButtonLabel
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    normalBackground: root.defaultStateBackgroundColor
                    normalForeground: root.baseTextColor
                    onClicked: {
                        root.pendingActionCommand = ["systemctl", "reboot"];
                        root.pendingActionMessage = qsTr("Are you sure you want to reboot?");
                        root.confirmYesText = qsTr("Reboot");
                        viewStack.push(confirmationDialogComponent);
                    }
                }
            }
        } // End of mainPowerOptionsScreen

        // -------------------------------------------------------------------------
        // --- Confirmation Dialog Component (Pushed onto StackView)
        // -------------------------------------------------------------------------
        Component {
            id: confirmationDialogComponent

            Item {
                width: root.width
                // Use Item as the root for the pushed component, allowing flexible content and positioning
                // anchors.fill: parent

                Rectangle {
                    // This rectangle is the visual background of the confirmation dialog
                    width: parent.width * 0.9 // Make it a bit smaller than the parent to serve as a dialog
                    height: parent.height * 0.9
                    color: root.componentBackgroundColor
                    radius: root.componentRadius
                    // anchors.centerIn: parent

                    // Text {
                    //     id: confirmationTitle
                    //     text: root.confirmationTitleText
                    //     font.pixelSize: root.headingFontSize
                    //     font.bold: true
                    //     color: root.baseTextColor
                    //     horizontalAlignment: Text.AlignHCenter
                    //     anchors {
                    //         top: parent.top
                    //         horizontalCenter: parent.horizontalCenter
                    //         // topMargin: root.confirmationPadding
                    //     }
                    // }
                    //
                    // Text {
                    //     id: confirmationMessage
                    //     text: root.pendingActionMessage // Text updated from pendingActionMessage
                    //     font.pixelSize: root.confirmationMessageFontSize
                    //     color: root.baseTextColor
                    //     wrapMode: Text.WordWrap
                    //     horizontalAlignment: Text.AlignHCenter
                    //     width: parent.width - (root.confirmationPadding * 2) // Confine text width
                    //     anchors {
                    //         top: confirmationTitle.bottom
                    //         horizontalCenter: parent.horizontalCenter
                    //         topMargin: -6
                    //     }
                    // }

                    Row {
                        spacing: root.confirmationButtonsSpacing
                        // anchors {
                        //     horizontalCenter: parent.horizontalCenter
                        //     bottom: parent.bottom
                        //     // bottomMargin: 4
                        // }

                        MButton {
                            id: noButton
                            width: root.confirmationButtonWidth
                            height: root.confirmationButtonHeight
                            text: root.confirmNoText
                            normalBackground: root.defaultStateBackgroundColor
                            normalForeground: root.baseTextColor
                            topRightRadius: 0
                            bottomRightRadius: 0
                            onClicked: {
                                viewStack.pop(); // Pop the confirmation and go back to the main screen
                            }
                        }

                        MButton {
                            id: yesButton
                            width: root.confirmationButtonWidth
                            height: root.confirmationButtonHeight
                            text: root.confirmYesText
                            // normalBackground: root.activeStateBackgroundColor.alpha(0.5) // Make 'Yes' button visually distinct
                            // normalForeground: root.highlightedStateTextColor
                            topLeftRadius: 0
                            bottomLeftRadius: 0
                            onClicked: {
                                powerActionProcess.command = root.pendingActionCommand; // Set the command
                                powerActionProcess.running = true;
                                viewStack.pop(); // Pop the confirmation regardless of success/failure for simple UX
                            }
                        }
                    }
                } // End of confirmation Rectangle
            } // End of Item (for pushed confirmation dialog)
        } // End of confirmationDialogComponent

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

        transformOrigin: Item.Center
    } // End of StackView

    // -------------------------------------------------------------------------
    // --- Non-Visual Child Elements (Logic, Processes, etc.)
    // -------------------------------------------------------------------------
    Process {
        id: powerActionProcess
        // The command will be dynamically set by `root.pendingActionCommand` just before starting
        running: false // Process is started explicitly by calling .start()

        property string lastStderrOutput: ""
        property string lastStdoutOutput: ""

        stderr: SplitParser {
            onRead: data => {
                powerActionProcess.lastStderrOutput += data;
                // Log stderr for debugging, in a real app, might show an error to user
                console.warn("Power action stderr:", data);
            }
        }
        stdout: SplitParser {
            onRead: data => {
                powerActionProcess.lastStdoutOutput += data;
                console.log("Power action stdout:", data);
            }
        }

        onRunningChanged: {
            // Reset outputs when a new command starts
            if (running) {
                lastStderrOutput = "";
                lastStdoutOutput = "";
            }
        }

        onExited: {
            if (exitCode !== 0) {
                console.error("Power action failed! Exit Code:", exitCode, "Stderr:", lastStderrOutput);
                // TODO: Consider showing a user-friendly error message or notification
            } else {
                console.log("Power action completed successfully.");
                // TODO: Depending on the action (e.g., logout) the app might close here.
            }
        }
    }
}
