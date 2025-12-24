// windows/settings/WallpaperSettings.qml
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

    title: qsTr("Wallpaper & Colors")
    showApplyButton: true
    property int preferredWidth: 600

    // ========================================================================
    // Local State (Holds unsaved changes)
    // ========================================================================
    property bool localEnableDynamic: false
    property bool localEnableColoring: false
    property string localDynamicPath: ""
    property int localInterval: 60
    property int localWallpaperIndex: 0
    property string localStaticWallpaper: ""

    // New Color Engine Variables
    property int localSchemeVariant: 2
    property real localChromaMult: 2.5
    property real localToneMult: 1.0

    // ========================================================================
    // Logic: Sync & Serialize
    // ========================================================================
    function syncFromTheme() {
        let s = (theme && theme.systemSettings) ? theme.systemSettings : {};

        localEnableDynamic = s.enableDynamicWallpapers ?? false;
        localEnableColoring = s.enableDynamicColoring ?? false;
        localDynamicPath = s.dynamicWallpapersPath || "";
        localInterval = (s.dynamicWallpapersInterval || 60000) / 1000;
        localWallpaperIndex = s.selectedWallpaperIndex || 0;
        localStaticWallpaper = s.wallpaper || "";

        // Sync New Variables
        localSchemeVariant = s.dynamicColoringSchemeVariant !== undefined ? s.dynamicColoringSchemeVariant : 2;
        localChromaMult = s.dynamicColoringChromaMult !== undefined ? s.dynamicColoringChromaMult : 2.5;
        localToneMult = s.dynamicColoringToneMult !== undefined ? s.dynamicColoringToneMult : 1.0;
    }

    function serializeData() {
        return {
            "_enableDynamicWallpapers": localEnableDynamic,
            "_enableDynamicColoring": localEnableColoring,
            "_dynamicWallpapersPath": localDynamicPath,
            "_dynamicWallpapersInterval": localInterval * 1000 // To ms
            ,
            "_selectedWallpaperIndex": localWallpaperIndex,
            "_wallpaper": localStaticWallpaper,
            // Serialize New Variables
            "_dynamicColoringSchemeVariant": localSchemeVariant,
            "_dynamicColoringChromaMult": localChromaMult,
            "_dynamicColoringToneMult": localToneMult
        };
    }

    // ========================================================================
    // Dialogs
    // ========================================================================
    FolderDialog {
        id: dirDialog
        title: "Select Wallpapers Folder"
        onAccepted: {
            var path = folder.toString().replace("file://", "");
            root.localDynamicPath = path;
            root.applySingleProperty("_dynamicWallpapersPath", path);
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select Wallpaper Image"
        nameFilters: ["Image files (*.jpg *.png *.webp *.bmp)"]
        onAccepted: {
            var path = file.toString().replace("file://", "");
            root.localStaticWallpaper = path;
            root.applySingleProperty("_wallpaper", path);
        }
    }

    // ========================================================================
    // Main UI
    // ========================================================================
    ColumnLayout {
        id: mainLayout
        spacing: 0 // Spacing handled by sections

        // --------------------------------------------------------------------
        // SECTION 1: ACTIVATION MODES
        // --------------------------------------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            Layout.bottomMargin: 15

            Controls.Label {
                text: qsTr("Modes & Activation")
                font.pixelSize: root.typ("heading2Size", 18)
                font.bold: true
                color: root.theme ? root.theme.colors.primary : "#fff"
            }

            // Dynamic Switch
            SettingSwitch {
                label: qsTr("Enable Dynamic Wallpapers")
                isChecked: root.localEnableDynamic
                onIsCheckedChanged: {
                    if (!root.isLoading) {
                        root.localEnableDynamic = isChecked;
                        root.applySingleProperty("_enableDynamicWallpapers", isChecked);
                    }
                }
            }
            Controls.Label {
                text: qsTr("Automatically cycle through wallpapers from a folder.")
                font.pixelSize: root.typ("small", 12)
                color: root.theme ? root.theme.colors.subtleText : "#888"
                Layout.leftMargin: 20
            }

            // Coloring Switch
            SettingSwitch {
                label: qsTr("Enable Material You Coloring")
                isChecked: root.localEnableColoring
                onIsCheckedChanged: {
                    if (!root.isLoading) {
                        root.localEnableColoring = isChecked;
                        root.applySingleProperty("_enableDynamicColoring", isChecked);
                    }
                }
            }
            Controls.Label {
                text: qsTr("Extract colors from wallpaper to theme the application.")
                font.pixelSize: root.typ("small", 12)
                color: root.theme ? root.theme.colors.subtleText : "#888"
                Layout.leftMargin: 20
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: 15
        }

        // --------------------------------------------------------------------
        // SECTION 2: COLOR ENGINE CONFIGURATION
        // --------------------------------------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            Layout.bottomMargin: 15
            visible: root.localEnableColoring // Hide if disabled

            Controls.Label {
                text: qsTr("Dynamic Color Engine")
                font.pixelSize: root.typ("heading2Size", 18)
                font.bold: true
                color: root.theme ? root.theme.colors.primary : "#fff"
            }

            // 1. Scheme Variant
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Controls.Label {
                    text: qsTr("Color Scheme:")
                    font.bold: true
                    Layout.preferredWidth: 100
                }
                SettingsComboBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    model: ["Content", "Expressive", "Fidelity", "Monochrome", "Neutral", "TonalSpot", "Vibrant", "Rainbow", "FruitSalad"]
                    currentIndex: root.localSchemeVariant
                    onActivated: index => {
                        root.localSchemeVariant = index;
                        root.applySingleProperty("_dynamicColoringSchemeVariant", index);
                    }
                }
            }

            // 2. Chroma Multiplier
            SliderWithLabel {
                label: qsTr("Chroma Multiplier")
                from: 0.0
                to: 5.0
                stepSize: 0.1
                decimals: 1
                value: root.localChromaMult
                onEditingFinished: val => {
                    root.localChromaMult = val;
                    root.applySingleProperty("_dynamicColoringChromaMult", val);
                }
            }

            // 3. Tone Multiplier
            SliderWithLabel {
                label: qsTr("Tone Multiplier")
                from: 0.0
                to: 5.0
                stepSize: 0.1
                decimals: 1
                value: root.localToneMult
                onEditingFinished: val => {
                    root.localToneMult = val;
                    root.applySingleProperty("_dynamicColoringToneMult", val);
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: 15
            visible: root.localEnableColoring
        }

        // --------------------------------------------------------------------
        // SECTION 3: WALLPAPER SOURCE (Dynamic OR Static)
        // --------------------------------------------------------------------

        // A. DYNAMIC MODE UI
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: root.localEnableDynamic

            Controls.Label {
                text: qsTr("Dynamic Collection Config")
                font.pixelSize: root.typ("heading2Size", 18)
                font.bold: true
                color: root.theme ? root.theme.colors.primary : "#fff"
            }

            // Folder Path
            Controls.Label {
                text: qsTr("Source Folder")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                EditableField {
                    text: root.localDynamicPath
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    selectedTheme: root.theme
                    onEditingFinished: {
                        if (root.isLoading)
                            return;
                        root.localDynamicPath = text;
                        root.applySingleProperty("_dynamicWallpapersPath", text);
                    }
                }
                MButton {
                    text: ""
                    font.family: root.typ("iconFont", "Arial")
                    onClicked: dirDialog.open()
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 30
                }
            }

            // Interval
            SliderWithLabel {
                label: qsTr("Change Interval (seconds)")
                from: 10
                to: 3600
                stepSize: 10
                value: root.localInterval
                onEditingFinished: val => {
                    root.localInterval = val;
                    root.applySingleProperty("_dynamicWallpapersInterval", val * 1000);
                }
            }

            // Navigation
            Controls.Label {
                text: qsTr("Current State")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Controls.Label {
                    text: "Index: " + root.localWallpaperIndex
                    Layout.fillWidth: true
                    color: root.theme ? root.theme.colors.subtleText : "#888"
                }
                MButton {
                    text: "Skip Wallpaper "
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 30
                    onClicked: {
                        ThemeManager.switchToNextWallpaper();
                        root.localWallpaperIndex = theme._selectedWallpaperIndex;
                        root.applySingleProperty("_selectedWallpaperIndex", root.localWallpaperIndex);
                    }
                }
            }
        }

        // B. STATIC MODE UI
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: !root.localEnableDynamic

            Controls.Label {
                text: qsTr("Static Image Config")
                font.pixelSize: root.typ("heading2Size", 18)
                font.bold: true
                color: root.theme ? root.theme.colors.primary : "#fff"
            }

            Controls.Label {
                text: qsTr("Image Path")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                EditableField {
                    text: root.localStaticWallpaper
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    selectedTheme: root.theme
                    onEditingFinished: {
                        if (root.isLoading)
                            return;
                        root.localStaticWallpaper = text;
                        root.applySingleProperty("_wallpaper", text);
                    }
                }
                MButton {
                    text: ""
                    font.family: root.typ("iconFont", "Arial")
                    onClicked: fileDialog.open()
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 30
                }
            }
        }
    }
}
