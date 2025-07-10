import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import org.kde.kirigami as Kirigami

import "root:/themes"
import "root:/components"

MenuCard {
    id: root

    // --- Texts & Content ---
    title: qsTr("Performance Mode") // "وضع الاداء"
    icon: ""

    property int defaultButtonWidth: 100
    property int defaultButtonHeight: 30

    property int buttonsRowSpacing: 10

    // --- Colors (Aliasing Theme colors for clarity and central access) ---
    property color baseTextColor: ThemeManager.selectedTheme.colors.topbarFgColorV1
    property color highlightedStateTextColor: {
        let bg = activeStateBackgroundColor;

        let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
        return luminance > 0.5 ? "black" : "white";
    }
    property color activeStateBackgroundColor: Kirigami.Theme.activeTextColor     // For active button background (original highlightColor)
    property color defaultStateBackgroundColor: Kirigami.Theme.activeBackgroundColor // For inactive button background

    property string highPerformanceButtonLabel: qsTr("High")
    property string balancedButtonLabel: qsTr("Balanced")
    property string lowButtonLabel: qsTr("Low")

    property string highPerformanceProfileCmd: "performance"
    property string balancedProfileCmd: "balanced"
    property string powerSaverProfileCmd: "power-saver"

    // --- Constants for Profile Indices (matching UPower.profile values) ---
    readonly property int profileIndexPerformance: 2
    readonly property int profileIndexBalanced: 1
    readonly property int profileIndexPowerSaver: 0

    // -------------------------------------------------------------------------
    // --- State Properties
    // -------------------------------------------------------------------------
    property var selectedProfile: PowerProfiles.profile // Comes from UPower
    property string profileToSetOnClick: "" // Stores the command string for the Process

    Row {
        id: widgetsRow
        // width: parent.width // Keep commented if width should be determined by content

        spacing: root.buttonsRowSpacing

        MButton {
            id: highPerformanceButton
            width: root.defaultButtonWidth
            height: root.defaultButtonHeight
            text: root.highPerformanceButtonLabel
            onClicked: {
                root.profileToSetOnClick = root.highPerformanceProfileCmd;
                profileProcess.running = true;
            }

            // Dynamic properties for styling based on selectedProfile
            normalBackground: (root.selectedProfile === root.profileIndexPerformance) ? root.activeStateBackgroundColor : root.defaultStateBackgroundColor
            normalForeground: (root.selectedProfile === root.profileIndexPerformance) ? root.highlightedStateTextColor : root.baseTextColor
        }

        MButton {
            id: balancedButton
            width: root.defaultButtonWidth
            height: root.defaultButtonHeight
            text: root.balancedButtonLabel
            onClicked: {
                root.profileToSetOnClick = root.balancedProfileCmd;
                profileProcess.running = true;
            }

            normalBackground: (root.selectedProfile === root.profileIndexBalanced) ? root.activeStateBackgroundColor : root.defaultStateBackgroundColor
            normalForeground: (root.selectedProfile === root.profileIndexBalanced) ? root.highlightedStateTextColor : root.baseTextColor
        }

        MButton {
            id: batterySavingButton
            width: root.defaultButtonWidth
            height: root.defaultButtonHeight
            text: root.lowButtonLabel
            onClicked: {
                root.profileToSetOnClick = root.powerSaverProfileCmd;
                profileProcess.running = true; // Or profileProcess.start()
            }

            normalBackground: (root.selectedProfile === root.profileIndexPowerSaver) ? root.activeStateBackgroundColor : root.defaultStateBackgroundColor
            normalForeground: (root.selectedProfile === root.profileIndexPowerSaver) ? root.highlightedStateTextColor : root.baseTextColor
        }
    }

    // -------------------------------------------------------------------------
    // --- Non-Visual Child Elements (Logic, Processes, etc.)
    // -------------------------------------------------------------------------
    Process {
        id: profileProcess
        running: false
        command: ["powerprofilesctl", "set", root.profileToSetOnClick]

        property string stdErrString: ""
        property string stdOutString: ""

        stderr: SplitParser {
            onRead: data => {
                profileProcess.stdErrString += data;
            }
        }
        stdout: SplitParser {
            onRead: data => {
                profileProcess.stdOutString += data;
            }
        }

        onRunningChanged: {
            if (running) {
                stdErrString = "";
                stdOutString = "";
            }
        }
    }

    // TODO: -> improve this and see where to use it
    // Connections {
    //     target: PowerProfiles
    //     function onProfileChanged() {
    //         // console.log("PowerProfiles.profile changed externally to:", PowerProfiles.profile);
    //         // root.selectedProfile already reflects this due to direct binding
    //     }
    // }
}
