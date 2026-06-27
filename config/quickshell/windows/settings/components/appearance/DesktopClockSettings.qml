// windows/settings/DesktopClockSettings.qml

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt.labs.platform

import "root:/components"
import "root:/components/settings"
import "root:/config"
import "root:/themes"
import "root:/windows/settings/components"

BaseThemeSettings {
    id: root

    // --- Header ---
    title: qsTr("Desktop & Clock Settings")
    icon: ""

    // --- Local State ---
    property bool localEnabled: true
    property string localFont: ""
    property string localFormat: ""
    property string localLocale: ""

    property bool localUseThemeColor: true
    property color localColor: ThemeManager.selectedTheme.colors.primary
    property bool localShadowEnabled: false
    property color localShadowColor: ThemeManager.selectedTheme.colors.surface.alpha(0.55)

    property bool localDepthEnabled: false
    property string localDepthModel: "u2net"
    property string localOverlayPath: ""

    property bool alphaMatting: false
    property int foregroundThreshold: 240
    property int backgroundThreshold: 10
    property int erodeSize: 10
    property bool isCreatingOverlayImage: false

    signal createOverlayImageButtonClicked(var data)

    function clearUnusedCache() {
        ThemeManager.cleardUnusedOverlayImages();
    }

    function syncFromTheme() {
        // General
        localEnabled = theme._desktopClockEnabled;
        localFont = theme._desktopClockFont;
        localFormat = theme._desktopClockFormat;
        localLocale = theme._desktopClockLocal;

        // Appearance
        localUseThemeColor = theme._desktopClockUseThemeColor;
        localColor = theme._desktopClockColor !== undefined ? theme._desktopClockColor : theme.colors.primary;
        localShadowEnabled = theme._desktopClockShadowEnabled;
        localShadowColor = theme._desktopClockShadowColor !== undefined ? theme._desktopClockShadowColor : theme.colors.surface.alpha(0.55);

        // Depth
        localDepthEnabled = theme._desktopClockDepthEffectEnabled;
        localDepthModel = theme._desktopClockDepthModel;
        localOverlayPath = theme._desktopClockDepthOverlayPath;
    }

    function serializeData() {
        return {
            "_desktopClockEnabled": localEnabled,
            "_desktopClockFont": localFont,
            "_desktopClockFormat": localFormat,
            "_desktopClockLocal": localLocale,
            "_desktopClockUseThemeColor": localUseThemeColor,
            "_desktopClockColor": localColor.toString(),
            "_desktopClockShadowEnabled": localShadowEnabled,
            "_desktopClockShadowColor": localShadowColor.toString(),
            "_desktopClockDepthEffectEnabled": localDepthEnabled,
            "_desktopClockDepthModel": localDepthModel,
            "_desktopClockDepthOverlayPath": localOverlayPath
        };
    }

    Connections {
        target: ThemeManager
        function onSelectedThemeUpdated() {
            if (!root.isLoading)
                refresh(false);
        }

        function onCreatingOverlayImageStarted() {
            depthEffectUi.enabled = false;
        }
        function onCreatingOverlayImageFinished(newPath) {
            depthEffectUi.enabled = true;
            refresh();
        }
    }

    // --- Dialogs ---
    FontDialog {
        id: fontDialog
        onAccepted: {
            root.localFont = font.family;
        }
        onCurrentFontChanged: {
            root.applySingleProperty("_desktopClockFont", currentFont.family);
        }
    }

    ColorDialog {
        id: colorDialog
        property string target: "main"
        onAccepted: {
            if (target === "main") {
                root.localColor = color;
                root.applySingleProperty("_desktopClockColor", color.toString());
            } else if (target === "shadow") {
                root.localShadowColor = color;
                root.applySingleProperty("_desktopClockShadowColor", color.toString());
            }
        }
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["Images (*.png *.jpg *.jpeg)"]
        onAccepted: {
            var path = file.toString();
            if (path.startsWith("file://"))
                path = path.substring(7);
            root.localOverlayPath = path;
            root.applySingleProperty("_desktopClockDepthOverlayPath", path);
        }
    }

    // --- Content ---
    ColumnLayout {
        Layout.preferredWidth: 590
        spacing: 15

        // --- Enable Switch (kept separate, not in SectionCard) ---
        SettingSwitch {
            id: _clockEnabledSwitch
            label: qsTr("Enable Desktop Clock")
            isChecked: root.localEnabled
            font.bold: true
            font.pixelSize: root.typ("heading3Size", 18)
            onIsCheckedChanged: {
                if (root.isLoading)
                    return;
                root.localEnabled = isChecked;
                root.applySingleProperty("_desktopClockEnabled", isChecked);
            }
        }

        Controls.Label {
            text: qsTr("Display a customizable clock on the desktop.")
            font.pixelSize: root.typ("small", 12)
            color: root.theme.colors.onSurfaceVariant
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 500
        }

        // --- Depth Effect Section ---
        SectionCard {
            id: depthEffectUi
            title: qsTr("Depth Effect")
            Layout.fillWidth: true
            enabled: root.localEnabled

            SettingSwitch {
                label: qsTr("Enable depth effect")
                isChecked: root.localDepthEnabled
                font.bold: true
                onIsCheckedChanged: {
                    if (root.isLoading)
                        return;
                    root.localDepthEnabled = isChecked;
                    root.applySingleProperty("_desktopClockDepthEffectEnabled", isChecked);
                }
            }

            ColumnLayout {
                enabled: root.localDepthEnabled
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    ColumnLayout {
                        Layout.fillWidth: true
                        Controls.Label {
                            text: qsTr("Model")
                            font.bold: true
                        }
                        SettingsComboBox {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            model: ["u2net", "isnet-general-use"]
                            Component.onCompleted: currentIndex = find(root.localDepthModel)
                            onCurrentTextChanged: {
                                if (root.isLoading)
                                    return;
                                root.localDepthModel = currentText;
                                root.applySingleProperty("_desktopClockDepthModel", currentText);
                            }
                        }
                    }

                    MButton {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 180
                        Layout.alignment: Qt.AlignBottom
                        text: "Create Overlay Image"
                        iconText: "󰙴"
                        enabled: !root.isCreatingOverlayImage
                        highlighted: true
                        textPreferredWidth: 4
                        iconPreferredWidth: 1
                        onClicked: {
                            const wallpaper = ThemeManager.currentWallpaper;

                            const data = {
                                wallpaper: wallpaper,
                                model: root.localDepthModel,
                                alphaMatting: root.alphaMatting,
                                foregroundThreshold: root.foregroundThreshold,
                                backgroundThreshold: root.backgroundThreshold,
                                erodeSize: root.erodeSize
                            };
                            root.createOverlayImageButtonClicked(data);
                            ThemeManager.requestCreateOverlayImage(data);
                        }
                    }
                }

                SettingSwitch {
                    id: _alphaMattingSwitch
                    label: "Alpha Matting"
                    isChecked: root.alphaMatting
                    Layout.topMargin: 10
                    onIsCheckedChanged: root.alphaMatting = isChecked
                }

                ColumnLayout {
                    enabled: _alphaMattingSwitch.isChecked
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    spacing: 10

                    SliderWithLabel {
                        label: qsTr("Background Threshold")
                        from: 0
                        to: 255
                        stepSize: 1
                        decimals: 0
                        value: root.backgroundThreshold
                        onEditingFinished: val => root.backgroundThreshold = parseInt(val)
                    }

                    SliderWithLabel {
                        label: qsTr("Foreground Threshold")
                        from: 0
                        to: 255
                        stepSize: 1
                        decimals: 0
                        value: root.foregroundThreshold
                        onEditingFinished: val => root.foregroundThreshold = parseInt(val)
                    }

                    SliderWithLabel {
                        label: qsTr("Erode Size")
                        from: 0
                        to: 50
                        stepSize: 1
                        decimals: 0
                        value: root.erodeSize
                        onEditingFinished: val => root.erodeSize = parseInt(val)
                    }
                }

                // Overlay Path
                Controls.Label {
                    text: qsTr("Overlay image path")
                    font.bold: true
                    Layout.topMargin: 10
                }
                RowLayout {
                    Layout.fillWidth: true
                    EditableField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        Layout.minimumWidth: 50
                        text: root.localOverlayPath
                        selectedTheme: root.theme
                        onEditingFinished: {
                            if (root.isLoading)
                                return;
                            root.localOverlayPath = text;
                            root.applySingleProperty("_desktopClockDepthOverlayPath", text);
                        }
                    }
                    MButton {
                        text: ""
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 40
                        font.family: root.theme ? root.theme.typography.iconFont : ""
                        onClicked: fileDialog.open()
                    }
                }
            }
        }

        // --- General Section ---
        SectionCard {
            title: qsTr("General")
            Layout.fillWidth: true
            enabled: root.localEnabled

            // Font
            Controls.Label {
                text: qsTr("Font")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                EditableField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    Layout.minimumWidth: 50
                    text: root.localFont
                    selectedTheme: root.theme
                    onEditingFinished: {
                        if (root.isLoading)
                            return;
                        root.localFont = text;
                        root.applySingleProperty("_desktopClockFont", text);
                    }
                }
                MButton {
                    text: ""
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 40
                    font.family: root.theme ? root.theme.typography.iconFont : ""
                    onClicked: {
                        fontDialog.currentFont.family = root.localFont;
                        fontDialog.open();
                    }
                }
            }

            // Format
            Controls.Label {
                text: qsTr("Format")
                font.bold: true
                Layout.topMargin: 10
            }
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.minimumWidth: 50
                text: root.localFormat
                selectedTheme: root.theme
                onEditingFinished: {
                    if (root.isLoading)
                        return;
                    root.localFormat = text;
                    root.applySingleProperty("_desktopClockFormat", text);
                }
            }

            // Locale
            Controls.Label {
                text: qsTr("Locale")
                font.bold: true
                Layout.topMargin: 10
            }
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.minimumWidth: 50
                text: root.localLocale
                selectedTheme: root.theme
                onEditingFinished: {
                    if (root.isLoading)
                        return;
                    root.localLocale = text;
                    root.applySingleProperty("_desktopClockLocal", text);
                }
            }
        }

        // --- Appearance Section ---
        SectionCard {
            title: qsTr("Appearance")
            Layout.fillWidth: true
            enabled: root.localEnabled

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Color Settings
                ColumnLayout {
                    Layout.fillWidth: true

                    SettingSwitch {
                        label: qsTr("Use theme color")
                        isChecked: root.localUseThemeColor
                        font.bold: true
                        onIsCheckedChanged: {
                            if (root.isLoading)
                                return;
                            root.localUseThemeColor = isChecked;
                            root.applySingleProperty("_desktopClockUseThemeColor", isChecked);
                        }
                    }

                    ColumnLayout {
                        enabled: !root.localUseThemeColor
                        Layout.fillWidth: true

                        Controls.Label {
                            text: qsTr("Clock Color")
                            font.bold: true
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            EditableField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                Layout.minimumWidth: 50
                                text: root.localColor.toString()
                                selectedTheme: root.theme
                                onEditingFinished: {
                                    if (root.isLoading)
                                        return;
                                    root.localColor = text;
                                    root.applySingleProperty("_desktopClockColor", text);
                                }
                            }
                            Rectangle {
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 30
                                color: root.localColor
                                border.color: root.theme.colors.onSurfaceVariant
                                border.width: 1
                                radius: root.theme.dimensions.shapeExtraSmall
                            }
                            MButton {
                                text: "󰃉"
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 30
                                onClicked: {
                                    colorDialog.target = "main";
                                    colorDialog.currentColor = root.localColor;
                                    colorDialog.open();
                                }
                            }
                        }
                    }
                }

                // Shadow Settings
                ColumnLayout {
                    Layout.fillWidth: true

                    SettingSwitch {
                        label: qsTr("Enable shadow")
                        isChecked: root.localShadowEnabled
                        font.bold: true
                        onIsCheckedChanged: {
                            if (root.isLoading)
                                return;
                            root.localShadowEnabled = isChecked;
                            root.applySingleProperty("_desktopClockShadowEnabled", isChecked);
                        }
                    }

                    ColumnLayout {
                        enabled: root.localShadowEnabled
                        Layout.fillWidth: true

                        Controls.Label {
                            text: qsTr("Shadow Color")
                            font.bold: true
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            EditableField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                Layout.minimumWidth: 50
                                text: root.localShadowColor.toString()
                                selectedTheme: root.theme
                                onEditingFinished: {
                                    if (root.isLoading)
                                        return;
                                    root.localShadowColor = text;
                                    root.applySingleProperty("_desktopClockShadowColor", text);
                                }
                            }
                            Rectangle {
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 30
                                color: root.localShadowColor
                                border.color: root.theme.colors.onSurfaceVariant
                                border.width: 1
                                radius: root.theme.dimensions.shapeExtraSmall
                            }
                            MButton {
                                text: "󰃉"
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 30
                                onClicked: {
                                    colorDialog.target = "shadow";
                                    colorDialog.currentColor = root.localShadowColor;
                                    colorDialog.open();
                                }
                            }
                        }
                    }
                }
            }
        }

        // Spacer to push footer down if needed
        Item {
            Layout.fillHeight: true
            width: 1
        }
    }
}
