// windows/leftwindow/dashboard/PowerOptions.qml

import QtQuick
import QtQuick.Controls
import Quickshell.Io // Needed for the Process component
// Removed Quickshell.Services.UPower as it's no longer directly used for power actions
import org.kde.kirigami as Kirigami

import "../../../themes"
import "../../../components"

Rectangle {
    id: root

    width: ThemeManager.selectedTheme.dimensions.menuWidth - (ThemeManager.selectedTheme.dimensions.menuWidgetsMargin * 2)

    // -------------------------------------------------------------------------
    // --- Configuration Properties (Constants & Theme Aliases)
    // -------------------------------------------------------------------------

    // --- Dimensions ---
    property int componentHeight: 90
    property int defaultButtonWidth: 100
    property int defaultButtonHeight: 30
    property int componentRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property var animationDuration: 400

    property int iconTopMargin: 16
    property int iconRightMargin: 20

    property int titleTopMargin: 9
    property int titleLeftMargin: 20
    property int titleIconSpacing: 10

    property int buttonsRowTopMargin: 10
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
    property string mainTitleText: qsTr("Power Options")
    property string mainIconCharacter: "" // Power icon

    // Power option button labels (using appropriate icons from FontAwesome 6/Nerd Fonts)
    // ⏻ (U+23FB) - Power off icon
    //  (U+EB52) - Reboot icon (Nerd Font specific)
    //  (U+F08B) - Logout icon
    property string powerOffButtonLabel: qsTr("⏻")
    property string rebootButtonLabel: qsTr("")
    property string logoutButtonLabel: qsTr("")

    // Confirmation dialog texts
    property string confirmationTitleText: qsTr("Confirm Action")
    property string confirmYesText: qsTr("Yes")
    property string confirmNoText: qsTr("No")

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
    height: root.componentHeight
    color: root.componentBackgroundColor
    radius: root.componentRadius

    // The StackView will manage different "screens" within this component
    StackView {
        id: viewStack
        anchors {
            fill: parent
        }
        // The initial screen displaying the power options buttons
        initialItem: Item {
            id: mainPowerOptionsScreen
            // anchors.fill: viewStack

            // -------------------------------------------------------------------------
            // --- Visual Elements for Main Power Options Screen
            // -------------------------------------------------------------------------
            Text {
                id: iconElement
                text: root.mainIconCharacter
                font.family: root.iconFontFamily
                font.bold: true
                font.pixelSize: root.headingFontSize
                color: root.baseTextColor
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: root.iconTopMargin
                    rightMargin: root.iconRightMargin
                }
            }

            Text {
                id: titleElement
                text: root.mainTitleText
                font.pixelSize: root.headingFontSize
                font.bold: true
                color: root.baseTextColor
                horizontalAlignment: Text.AlignRight
                anchors {
                    top: parent.top
                    left: parent.left
                    right: iconElement.left
                    topMargin: root.titleTopMargin
                    rightMargin: root.titleIconSpacing
                    leftMargin: root.titleLeftMargin
                }
            }

            Row {
                id: powerOptionsButtonsRow
                anchors {
                    top: titleElement.bottom
                    verticalCenter: parent.verticalCenter // Keep centered within available space
                    horizontalCenter: parent.horizontalCenter
                    topMargin: root.buttonsRowTopMargin
                }
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
                // Use Item as the root for the pushed component, allowing flexible content and positioning
                // anchors.fill: parent

                Rectangle {
                    // This rectangle is the visual background of the confirmation dialog
                    width: parent.width * 0.9 // Make it a bit smaller than the parent to serve as a dialog
                    height: parent.height * 0.9
                    color: root.componentBackgroundColor
                    radius: root.componentRadius
                    anchors.centerIn: parent

                    Text {
                        id: confirmationTitle
                        text: root.confirmationTitleText
                        font.pixelSize: root.headingFontSize
                        font.bold: true
                        color: root.baseTextColor
                        horizontalAlignment: Text.AlignHCenter
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                            // topMargin: root.confirmationPadding
                        }
                    }

                    Text {
                        id: confirmationMessage
                        text: root.pendingActionMessage // Text updated from pendingActionMessage
                        font.pixelSize: root.confirmationMessageFontSize
                        color: root.baseTextColor
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width - (root.confirmationPadding * 2) // Confine text width
                        anchors {
                            top: confirmationTitle.bottom
                            horizontalCenter: parent.horizontalCenter
                            topMargin: -6
                        }
                    }

                    Row {
                        spacing: root.confirmationButtonsSpacing
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: 4
                        }

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
            // The NEW item (confirmation dialog content) enters
            ParallelAnimation {
                // Animate the Item itself, setting its starting rotation and position
                // The item will then slide into its default (anchored) position (x=0, y=0, rotY=0)
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.animationDuration
                    easing.type: Easing.OutQuint
                }
                // Start rotated to appear like its "back" is showing, then flip to front
                // RotationAnimation {
                //     property: "rotationY"
                //     from: 90
                //     to: 0
                //     duration: root.animationDuration
                //     easing.type: Easing.OutBack
                // }
                // Start smaller and grow
                NumberAnimation {
                    property: "scale"
                    from: 0.7
                    to: 1.0
                    duration: root.animationDuration
                    easing.type: Easing.OutBack
                }
                // Start shifted slightly off-center and slide into view
                NumberAnimation {
                    property: "x"
                    from: {
                        if (root.pendingActionCommand[1] === "dispatch") {
                            return parent.width * 0.15;
                        } else if (root.pendingActionCommand[1] === "reboot") {
                            return 0;
                        } else if (root.pendingActionCommand[1] === "poweroff") {
                            return parent.width * -0.15;
                        }
                    }
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.OutQuint
                }
            }
        }

        pushExit: Transition {
            // The OLD item (main screen content) exits
            ParallelAnimation {
                // The current item fades out completely
                // NumberAnimation {
                //     property: "opacity"
                //     to: 0
                //     duration: root.animationDuration
                //     easing.type: Easing.InQuint
                // }
                // // Flip it away in the opposite direction
                // RotationAnimation {
                //     property: "rotationY"
                //     to: -90
                //     duration: root.animationDuration
                //     easing.type: Easing.InBack
                // }
                // Shrink it as it goes away
                NumberAnimation {
                    property: "scale"
                    to: 0.7
                    duration: root.animationDuration
                    easing.type: Easing.InBack
                }
                // Slide it slightly off-center in the opposite direction
                NumberAnimation {
                    property: "x"
                    to: {
                        if (root.pendingActionCommand[1] === "dispatch") {
                            return parent.width * 0.15;
                        } else if (root.pendingActionCommand[1] === "reboot") {
                            return 0;
                        } else if (root.pendingActionCommand[1] === "poweroff") {
                            return parent.width * -0.15;
                        }
                    }
                    duration: root.animationDuration
                    easing.type: Easing.InQuint
                }
            }
        }

        // --- Pop Animations ---
        popEnter: Transition {
            // The NEW item (main screen content) enters (revealed again)
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.animationDuration
                    easing.type: Easing.OutQuint
                }
                // RotationAnimation {
                //     property: "rotationY"
                //     from: -90
                //     to: 0
                //     duration: root.animationDuration
                //     easing.type: Easing.OutBack
                // }
                NumberAnimation {
                    property: "scale"
                    from: 0.7
                    to: 1.0
                    duration: root.animationDuration
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    property: "x"
                    from: {
                        if (root.pendingActionCommand[1] === "dispatch") {
                            return parent.width * 0.15;
                        } else if (root.pendingActionCommand[1] === "reboot") {
                            return 0;
                        } else if (root.pendingActionCommand[1] === "poweroff") {
                            return parent.width * -0.15;
                        }
                    }
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.OutQuint
                }
            }
        }

        popExit: Transition {
            // The OLD item (confirmation dialog content) exits (is dismissed)
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.InQuint
                }
                // RotationAnimation {
                //     property: "rotationY"
                //     to: 90
                //     duration: root.animationDuration
                //     easing.type: Easing.InBack
                // }
                NumberAnimation {
                    property: "scale"
                    to: 0.7
                    duration: root.animationDuration
                    easing.type: Easing.InBack
                }
                NumberAnimation {
                    property: "x"
                    to: {
                        if (root.pendingActionCommand[1] === "dispatch") {
                            return parent.width * 0.15;
                        } else if (root.pendingActionCommand[1] === "reboot") {
                            return 0;
                        } else if (root.pendingActionCommand[1] === "poweroff") {
                            return parent.width * -0.15;
                        }
                    }
                    duration: root.animationDuration
                    easing.type: Easing.InQuint
                }
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
