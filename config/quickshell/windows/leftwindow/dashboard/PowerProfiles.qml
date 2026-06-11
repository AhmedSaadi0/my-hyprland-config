// windows/leftwindow/dashboard/PowerProfiles.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import org.kde.kirigami as Kirigami

import "root:/windows/smart_capsule/logic"
import "root:/themes"
import "root:/components"
import "root:/config/ConstValues.js" as Consts

MenuCard {
    id: root

    // --- Texts & Content ---
    title: qsTr("Power Profiles") // "وضع الاداء"
    icon: ""
    cardColor: ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.7)
    textColor: ThemeManager.selectedTheme.colors.onSecondaryContainer

    property int defaultButtonWidth: 100
    property int defaultButtonHeight: 30

    property int buttonsRowSpacing: 7
    property int innerRadiusDiv: 3

    property string highPerformanceButtonLabel: qsTr("High")
    property string balancedButtonLabel: qsTr("Balanced")
    property string lowButtonLabel: qsTr("Low")

    // --- Power Profile Enums (from Quickshell.Services.UPower) ---
    readonly property int profileIndexPerformance: PowerProfile.Performance
    readonly property int profileIndexBalanced: PowerProfile.Balanced
    readonly property int profileIndexPowerSaver: PowerProfile.PowerSaver

    // -------------------------------------------------------------------------
    // --- State Properties
    // -------------------------------------------------------------------------
    property var selectedProfile: PowerProfiles.profile // Comes from UPower
    property bool _readyForNotifications: false
    property int _lastNotifiedProfile: -1
    property int _pendingProfile: -1
    property bool _pendingUserChange: false

    function _notifyProfileChange(profile) {
        CapsuleCoordinator.handlePowerProfileChange(profile);
    }

    function _notifyProfileError(message) {
        CapsuleCoordinator.handlePowerProfileError(message);
    }

    function _requestProfileChange(profile) {
        if (PowerProfiles.profile === profile)
            return;

        _pendingProfile = profile;
        _pendingUserChange = true;
        PowerProfiles.profile = profile;
        profileChangeTimer.restart();
    }

    onSelectedProfileChanged: {
        if (!_readyForNotifications) {
            _lastNotifiedProfile = selectedProfile;
            return;
        }

        if (selectedProfile === _lastNotifiedProfile)
            return;

        _lastNotifiedProfile = selectedProfile;

        if (_pendingUserChange && selectedProfile === _pendingProfile) {
            _pendingUserChange = false;
            profileChangeTimer.stop();
        }

        _notifyProfileChange(selectedProfile);
    }

    Component.onCompleted: {
        _readyForNotifications = true;
        _lastNotifiedProfile = selectedProfile;
    }

    Timer {
        id: profileChangeTimer
        interval: 2500
        repeat: false
        onTriggered: {
            if (_pendingUserChange && PowerProfiles.profile !== _pendingProfile) {
                _pendingUserChange = false;
                _notifyProfileError(qsTr("Failed to change power profile. Check system permissions."));
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        Layout.fillWidth: true
        spacing: 6

        // Replace Row with RowLayout
        RowLayout { // <--- MODIFIED: Was 'Row'
            id: widgetsRow
            Layout.fillWidth: true // <--- ADDED: Tell the layout to fill the available width
            spacing: root.buttonsRowSpacing

            // Now, you can decide how the buttons should behave inside the RowLayout.
            // Option 1: Keep them fixed width (they will be aligned to the left).
            // Option 2 (Recommended): Make them fill the available space equally.

            // --- Using Option 2 (Recommended for a better look) ---

            MButton {
                id: highPerformanceButton
                Layout.fillWidth: true // <--- ADDED: Make button fill available width
                height: root.defaultButtonHeight
                text: root.highPerformanceButtonLabel
                onClicked: {
                    _requestProfileChange(PowerProfile.Performance);
                }
                enabled: PowerProfiles.hasPerformanceProfile
                isActive: root.selectedProfile === root.profileIndexPerformance
                normalBackground: {
                    let base = ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.6);
                    return ThemeManager.selectedTheme._themeMode === "dark"
                        ? Qt.lighter(base, 1.15)
                        : Qt.darker(base, 1.12);
                }
                // normalBackground: (root.selectedProfile === root.profileIndexPerformance) ? root.activeStateBackgroundColor : root.defaultStateBackgroundColor
                // normalForeground: (root.selectedProfile === root.profileIndexPerformance) ? root.highlightedStateTextColor : root.baseTextColor

                topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
            }

            MButton {
                id: balancedButton
                Layout.fillWidth: true // <--- ADDED
                height: root.defaultButtonHeight
                text: root.balancedButtonLabel
                normalBackground: {
                    let base = ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.6);
                    return ThemeManager.selectedTheme._themeMode === "dark"
                        ? Qt.lighter(base, 1.15)
                        : Qt.darker(base, 1.12);
                }
                onClicked: {
                    _requestProfileChange(PowerProfile.Balanced);
                }

                isActive: root.selectedProfile === root.profileIndexBalanced
                // normalBackground: (root.selectedProfile === root.profileIndexBalanced) ? root.activeStateBackgroundColor : root.defaultStateBackgroundColor
                // normalForeground: (root.selectedProfile === root.profileIndexBalanced) ? root.highlightedStateTextColor : root.baseTextColor

                topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
            }

            MButton {
                id: batterySavingButton
                Layout.fillWidth: true // <--- ADDED
                height: root.defaultButtonHeight
                text: root.lowButtonLabel
                normalBackground: {
                    let base = ThemeManager.selectedTheme.colors.secondaryContainer.alpha(0.6);
                    return ThemeManager.selectedTheme._themeMode === "dark"
                        ? Qt.lighter(base, 1.15)
                        : Qt.darker(base, 1.12);
                }
                onClicked: {
                    _requestProfileChange(PowerProfile.PowerSaver);
                }
                isActive: root.selectedProfile === root.profileIndexPowerSaver
                // normalBackground: (root.selectedProfile === root.profileIndexPowerSaver) ? root.activeStateBackgroundColor : root.defaultStateBackgroundColor
                // normalForeground: (root.selectedProfile === root.profileIndexPowerSaver) ? root.highlightedStateTextColor : root.baseTextColor

                bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
                topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / (isActive ? Consts.M3_BUTTON_RADIUS_DIVISOR : innerRadiusDiv)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: !PowerProfiles.hasPerformanceProfile

            Text {
                text: ""
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 12
                color: ThemeManager.selectedTheme.colors.onSecondaryContainer
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("High performance profile is not available on this device.")
                font.family: ThemeManager.selectedTheme.typography.bodyFont
                font.pixelSize: 11
                color: ThemeManager.selectedTheme.colors.onSecondaryContainer
                wrapMode: Text.Wrap
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
