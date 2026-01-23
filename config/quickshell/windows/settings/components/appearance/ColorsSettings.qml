// windows/settings/ColorsSettings.qml

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import Qt.labs.platform

import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/windows/settings/components"

BaseThemeSettings {
    id: root

    title: qsTr("Color Settings")
    icon: ""

    // --- Local Variables ---
    property color localPrimary: "#000000"
    property color localSecondary: "#000000"
    property color localOnPrimary: "#ffffff"
    property color localOnSecondary: "#ffffff"
    property color localSubtleText: "#888888"

    property color localTertiary: "#000000"
    property color localOnTertiary: "#ffffff"
    property color localError: "#000000"
    property color localOnError: "#ffffff"
    property color localSuccess: "#000000"
    property color localOnSuccess: "#ffffff"
    property color localWarning: "#000000"
    property color localOnWarning: "#ffffff"

    property color localTopbarColor: "#000000"
    property color localTopbarFgColor: "#ffffff"
    property color localTopbarBgV1: "#000000"
    property color localTopbarFgV1: "#ffffff"
    property color localTopbarBgV2: "#000000"
    property color localTopbarFgV2: "#ffffff"
    property color localTopbarBgV3: "#000000"
    property color localTopbarFgV3: "#ffffff"

    property color localMenuBgV1: "#000000"
    property color localMenuFgV1: "#ffffff"
    property color localMenuBgV2: "#000000"
    property color localMenuFgV2: "#ffffff"
    property color localMenuBgV3: "#000000"
    property color localMenuFgV3: "#ffffff"

    property color localVolOsdBg: "#000000"
    property color localVolOsdFg: "#ffffff"

    function syncFromTheme() {
        const getCol = val => val !== undefined ? val : "#000000";

        localPrimary = getCol(theme._primary);
        localSecondary = getCol(theme._secondary);
        localOnPrimary = getCol(theme._onPrimary);
        localOnSecondary = getCol(theme._onSecondary);
        localSubtleText = getCol(theme._subtleTextColor);

        localTertiary = getCol(theme._tertiary);
        localOnTertiary = getCol(theme._onTertiary);
        localError = getCol(theme._error);
        localOnError = getCol(theme._onError);
        localSuccess = getCol(theme._success);
        localOnSuccess = getCol(theme._onSuccess);
        localWarning = getCol(theme._warning);
        localOnWarning = getCol(theme._onWarning);

        localTopbarColor = getCol(theme._topbarColor);
        localTopbarFgColor = getCol(theme._topbarFgColor);
        localTopbarBgV1 = getCol(theme._topbarBgColorV1);
        localTopbarFgV1 = getCol(theme._topbarFgColorV1);
        localTopbarBgV2 = getCol(theme._topbarBgColorV2);
        localTopbarFgV2 = getCol(theme._topbarFgColorV2);
        localTopbarBgV3 = getCol(theme._topbarBgColorV3);
        localTopbarFgV3 = getCol(theme._topbarFgColorV3);

        localMenuBgV1 = getCol(theme._leftMenuBgColorV1);
        localMenuFgV1 = getCol(theme._leftMenuFgColorV1);
        localMenuBgV2 = getCol(theme._leftMenuBgColorV2);
        localMenuFgV2 = getCol(theme._leftMenuFgColorV2);
        localMenuBgV3 = getCol(theme._leftMenuBgColorV3);
        localMenuFgV3 = getCol(theme._leftMenuFgColorV3);

        localVolOsdBg = getCol(theme._volOsdBgColor);
        localVolOsdFg = getCol(theme._volOsdFgColor);
    }

    function serializeData() {
        return {
            "_primary": localPrimary.toString(),
            "_secondary": localSecondary.toString(),
            "_onPrimary": localOnPrimary.toString(),
            "_onSecondary": localOnSecondary.toString(),
            "_subtleTextColor": localSubtleText.toString(),
            "_tertiary": localTertiary.toString(),
            "_onTertiary": localOnTertiary.toString(),
            "_error": localError.toString(),
            "_onError": localOnError.toString(),
            "_success": localSuccess.toString(),
            "_onSuccess": localOnSuccess.toString(),
            "_warning": localWarning.toString(),
            "_onWarning": localOnWarning.toString(),
            "_topbarColor": localTopbarColor.toString(),
            "_topbarFgColor": localTopbarFgColor.toString(),
            "_topbarBgColorV1": localTopbarBgV1.toString(),
            "_topbarFgColorV1": localTopbarFgV1.toString(),
            "_topbarBgColorV2": localTopbarBgV2.toString(),
            "_topbarFgColorV2": localTopbarFgV2.toString(),
            "_topbarBgColorV3": localTopbarBgV3.toString(),
            "_topbarFgColorV3": localTopbarFgV3.toString(),
            "_leftMenuBgColorV1": localMenuBgV1.toString(),
            "_leftMenuFgColorV1": localMenuFgV1.toString(),
            "_leftMenuBgColorV2": localMenuBgV2.toString(),
            "_leftMenuFgColorV2": localMenuFgV2.toString(),
            "_leftMenuBgColorV3": localMenuBgV3.toString(),
            "_leftMenuFgColorV3": localMenuFgV3.toString(),
            "_volOsdBgColor": localVolOsdBg.toString(),
            "_volOsdFgColor": localVolOsdFg.toString()
        };
    }

    // --- Helpers ---
    ColorDialog {
        id: mainColorDialog
        property var activeCallback: null
        property var targetedProp: ""
        onAccepted: {
            if (activeCallback)
                activeCallback(color.toString());
            activeCallback = null;
        }
        onRejected: activeCallback = null

        // onCurrentColorChanged: {
        //     if (activeCallback)
        //         activeCallback(currentColor.toString());
        //     activeCallback = null;
        //     // root.applySingleProperty(targetedProp, color.toString());
        // }
    }

    component ColorRow: ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        property string label
        property color value: "#000000"
        property var targetedProp: ""
        signal userChanged(string newValue)

        Controls.Label {
            text: qsTr(parent.label)
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Rectangle {
                width: 28
                height: 28
                radius: 4
                border.color: "#66ffffff"
                border.width: 1
                color: value
            }
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: value.toString()
                selectedTheme: root.theme
                onEditingFinished: userChanged(text)
            }
            MButton {
                text: "󰃉"
                Layout.preferredWidth: 35
                Layout.preferredHeight: 30
                onClicked: {
                    mainColorDialog.currentColor = value;
                    mainColorDialog.activeCallback = function (c) {
                        userChanged(c);
                    };
                    mainColorDialog.open();
                }
            }
        }
    }

    // --- UI Content ---
    ColumnLayout {
        spacing: root.dim("spacingMedium", 10)
        Layout.preferredWidth: 590

        // --- Core Palette ---
        Controls.Label {
            text: qsTr("Core Palette")
            font.pixelSize: root.typ("heading2Size", 18)
            font.bold: true
            Layout.topMargin: 10
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 15
            rowSpacing: 10

            ColorRow {
                label: qsTr("Primary")
                value: root.localPrimary
                onUserChanged: v => {
                    root.localPrimary = v;
                    root.applySingleProperty("_primary", v);
                }
            }
            ColorRow {
                label: qsTr("On Primary")
                value: root.localOnPrimary
                onUserChanged: v => {
                    root.localOnPrimary = v;
                    root.applySingleProperty("_onPrimary", v);
                }
            }
            ColorRow {
                label: qsTr("Secondary")
                value: root.localSecondary
                onUserChanged: v => {
                    root.localSecondary = v;
                    root.applySingleProperty("_secondary", v);
                }
            }
            ColorRow {
                label: qsTr("On Secondary")
                value: root.localOnSecondary
                onUserChanged: v => {
                    root.localOnSecondary = v;
                    root.applySingleProperty("_onSecondary", v);
                }
            }
            ColorRow {
                label: qsTr("Tertiary")
                value: root.localTertiary
                onUserChanged: v => {
                    root.localTertiary = v;
                    root.applySingleProperty("_tertiary", v);
                }
            }
            ColorRow {
                label: qsTr("On Tertiary")
                value: root.localOnTertiary
                onUserChanged: v => {
                    root.localOnTertiary = v;
                    root.applySingleProperty("_onTertiary", v);
                }
            }
            ColorRow {
                label: qsTr("Error")
                value: root.localError
                onUserChanged: v => {
                    root.localError = v;
                    root.applySingleProperty("_error", v);
                }
            }
            ColorRow {
                label: qsTr("On Error")
                value: root.localOnError
                onUserChanged: v => {
                    root.localOnError = v;
                    root.applySingleProperty("_onError", v);
                }
            }
            ColorRow {
                label: qsTr("Success")
                value: root.localSuccess
                onUserChanged: v => {
                    root.localSuccess = v;
                    root.applySingleProperty("_success", v);
                }
            }
            ColorRow {
                label: qsTr("On Success")
                value: root.localOnSuccess
                onUserChanged: v => {
                    root.localOnSuccess = v;
                    root.applySingleProperty("_onSuccess", v);
                }
            }
            ColorRow {
                label: qsTr("Warning")
                value: root.localWarning
                onUserChanged: v => {
                    root.localWarning = v;
                    root.applySingleProperty("_warning", v);
                }
            }
            ColorRow {
                label: qsTr("On Warning")
                value: root.localOnWarning
                onUserChanged: v => {
                    root.localOnWarning = v;
                    root.applySingleProperty("_onWarning", v);
                }
            }
            ColorRow {
                label: qsTr("Subtle Text")
                value: root.localSubtleText
                onUserChanged: v => {
                    root.localSubtleText = v;
                    root.applySingleProperty("_subtleTextColor", v);
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 15
        }

        // --- Topbar ---
        Controls.Label {
            text: qsTr("Topbar")
            font.bold: true
            font.pixelSize: 18
            Layout.topMargin: 10
        }
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 15
            rowSpacing: 10

            ColorRow {
                label: "Background"
                value: root.localTopbarColor
                onUserChanged: v => {
                    root.localTopbarColor = v;
                    root.applySingleProperty("_topbarColor", v);
                }
            }
            ColorRow {
                label: "Foreground"
                value: root.localTopbarFgColor
                onUserChanged: v => {
                    root.localTopbarFgColor = v;
                    root.applySingleProperty("_topbarFgColor", v);
                }
            }
            ColorRow {
                label: "BG V1"
                value: root.localTopbarBgV1
                onUserChanged: v => {
                    root.localTopbarBgV1 = v;
                    root.applySingleProperty("_topbarBgColorV1", v);
                }
            }
            ColorRow {
                label: "FG V1"
                value: root.localTopbarFgV1
                onUserChanged: v => {
                    root.localTopbarFgV1 = v;
                    root.applySingleProperty("_topbarFgColorV1", v);
                }
            }
            ColorRow {
                label: "BG V2"
                value: root.localTopbarBgV2
                onUserChanged: v => {
                    root.localTopbarBgV2 = v;
                    root.applySingleProperty("_topbarBgColorV2", v);
                }
            }
            ColorRow {
                label: "FG V2"
                value: root.localTopbarFgV2
                onUserChanged: v => {
                    root.localTopbarFgV2 = v;
                    root.applySingleProperty("_topbarFgColorV2", v);
                }
            }
            ColorRow {
                label: "BG V3"
                value: root.localTopbarBgV3
                onUserChanged: v => {
                    root.localTopbarBgV3 = v;
                    root.applySingleProperty("_topbarBgColorV3", v);
                }
            }
            ColorRow {
                label: "FG V3"
                value: root.localTopbarFgV3
                onUserChanged: v => {
                    root.localTopbarFgV3 = v;
                    root.applySingleProperty("_topbarFgColorV3", v);
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 15
        }

        // --- Left Menu ---
        Controls.Label {
            text: qsTr("Left Menu")
            font.bold: true
            font.pixelSize: 18
            Layout.topMargin: 10
        }
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 15
            rowSpacing: 10

            ColorRow {
                label: "BG V1"
                value: root.localMenuBgV1
                onUserChanged: v => {
                    root.localMenuBgV1 = v;
                    root.applySingleProperty("_leftMenuBgColorV1", v);
                }
            }
            ColorRow {
                label: "FG V1"
                value: root.localMenuFgV1
                onUserChanged: v => {
                    root.localMenuFgV1 = v;
                    root.applySingleProperty("_leftMenuFgColorV1", v);
                }
            }
            ColorRow {
                label: "BG V2"
                value: root.localMenuBgV2
                onUserChanged: v => {
                    root.localMenuBgV2 = v;
                    root.applySingleProperty("_leftMenuBgColorV2", v);
                }
            }
            ColorRow {
                label: "FG V2"
                value: root.localMenuFgV2
                onUserChanged: v => {
                    root.localMenuFgV2 = v;
                    root.applySingleProperty("_leftMenuFgColorV2", v);
                }
            }
            ColorRow {
                label: "BG V3"
                value: root.localMenuBgV3
                onUserChanged: v => {
                    root.localMenuBgV3 = v;
                    root.applySingleProperty("_leftMenuBgColorV3", v);
                }
            }
            ColorRow {
                label: "FG V3"
                value: root.localMenuFgV3
                onUserChanged: v => {
                    root.localMenuFgV3 = v;
                    root.applySingleProperty("_leftMenuFgColorV3", v);
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 15
        }

        // --- Misc ---
        Controls.Label {
            text: qsTr("Misc")
            font.bold: true
            font.pixelSize: 18
            Layout.topMargin: 10
        }
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 15
            rowSpacing: 10

            ColorRow {
                label: "Vol OSD BG"
                value: root.localVolOsdBg
                onUserChanged: v => {
                    root.localVolOsdBg = v;
                    root.applySingleProperty("_volOsdBgColor", v);
                }
            }
            ColorRow {
                label: "Vol OSD FG"
                value: root.localVolOsdFg
                onUserChanged: v => {
                    root.localVolOsdFg = v;
                    root.applySingleProperty("_volOsdFgColor", v);
                }
            }
        }

        Item {
            height: 20
            width: 1
        }
    }
}
