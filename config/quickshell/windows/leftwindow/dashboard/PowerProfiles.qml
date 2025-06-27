import QtQuick
import QtQuick.Effects
import Quickshell.Io
import Quickshell.Services.UPower
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
    property int componentHeight: 85
    property int defaultButtonWidth: 100
    property int defaultButtonHeight: 30
    property int componentRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    property int iconElementWidth: 10 // Note: Text width might override this
    property int iconTopMargin: 12
    property int iconRightMargin: 20
    // property int iconLeftMargin: 20 // Was commented out in original for icon

    property int titleTopMargin: 5
    property int titleLeftMargin: 20
    property int titleIconSpacing: 10 // Was title.rightMargin

    property int buttonsRowTopMargin: 10
    property int buttonsRowSpacing: 10

    // --- Colors (Aliasing Theme colors for clarity and central access) ---
    property color componentBackgroundColor: ThemeManager.selectedTheme.colors.topbarBgColorV1
    property color baseTextColor: ThemeManager.selectedTheme.colors.topbarFgColorV1
    property color highlightedStateTextColor: Kirigami.Theme.highlightedTextColor // For active button text
    property color activeStateBackgroundColor: Kirigami.Theme.activeTextColor     // For active button background (original highlightColor)
    property color defaultStateBackgroundColor: Kirigami.Theme.activeBackgroundColor // For inactive button background

    // --- Fonts (Aliasing Theme fonts) ---
    property string iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
    property int headingFontSize: ThemeManager.selectedTheme.typography.heading3Size

    // --- Texts & Content ---
    property string mainTitleText: qsTr("Performance Mode") // "وضع الاداء"
    property string iconCharacter: ""

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

    // -------------------------------------------------------------------------
    // --- Root Visual Properties
    // -------------------------------------------------------------------------
    height: root.componentHeight
    color: root.componentBackgroundColor
    radius: root.componentRadius

    // layer.enabled: true
    // layer.effect: Shadow {} // Add specific shadow properties if needed

    // -------------------------------------------------------------------------
    // --- Visual Child Elements
    // -------------------------------------------------------------------------
    Text {
        id: iconElement // Renamed id for clarity
        width: root.iconElementWidth
        text: root.iconCharacter
        font.family: root.iconFontFamily
        font.bold: true
        font.pixelSize: root.headingFontSize
        color: root.baseTextColor
        anchors {
            top: parent.top
            right: parent.right
            topMargin: root.iconTopMargin
            rightMargin: root.iconRightMargin
            // leftMargin: root.iconLeftMargin // Kept commented
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
            right: iconElement.left // Anchor to the icon element
            topMargin: root.titleTopMargin
            rightMargin: root.titleIconSpacing // Space between title and icon
            leftMargin: root.titleLeftMargin
        }
    }

    Row {
        id: widgetsRow
        // width: parent.width // Keep commented if width should be determined by content
        anchors {
            top: titleElement.bottom
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
            topMargin: root.buttonsRowTopMargin
        }
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
