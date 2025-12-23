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

    title: qsTr("Wallpaper Settings")
    showApplyButton: true

    // --- Local State ---
    property bool localEnableDynamic: false
    property bool localEnableColoring: false
    property string localDynamicPath: ""
    property int localInterval: 60
    property int localWallpaperIndex: 0
    property string localStaticWallpaper: ""

    property int preferredWidth: 600

    // 1. Override: Sync Logic
    function syncFromTheme() {
        let s = (theme && theme.systemSettings) ? theme.systemSettings : {};

        localEnableDynamic = s.enableDynamicWallpapers ?? false;
        localEnableColoring = s.enableDynamicColoring ?? false;
        localDynamicPath = s.dynamicWallpapersPath || "";

        localInterval = (s.dynamicWallpapersInterval || 60000) / 1000;
        localWallpaperIndex = s.selectedWallpaperIndex || 0;
        localStaticWallpaper = s.wallpaper || "";
    }

    function serializeData() {
        return {
            "_enableDynamicWallpapers": localEnableDynamic,
            "_enableDynamicColoring": localEnableColoring,
            "_dynamicWallpapersPath": localDynamicPath,
            // تحويل من ثواني إلى ملي ثانية عند الحفظ
            "_dynamicWallpapersInterval": localInterval * 1000,
            "_selectedWallpaperIndex": localWallpaperIndex,
            "_wallpaper": localStaticWallpaper
        };
    }

    // --- Dialogs ---
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

    // --- UI Content ---
    ColumnLayout {
        id: mainLayout
        spacing: root.dim("spacingMedium", 10)

        Controls.Label {
            text: qsTr("General")
            font.pixelSize: root.typ("heading2Size", 18)
            font.bold: true
            Layout.topMargin: 10
        }

        SettingSwitch {
            label: qsTr("Enable dynamic wallpapers")
            isChecked: root.localEnableDynamic
            onIsCheckedChanged: {
                if (root.isLoading)
                    return;
                root.localEnableDynamic = isChecked;
                root.applySingleProperty("_enableDynamicWallpapers", isChecked);
            }
        }

        Controls.Label {
            text: qsTr("Automatically cycle through a collection of wallpapers from a selected folder.")
            font.pixelSize: root.typ("small", 12)
            color: root.theme ? root.theme.colors.subtleText : "#888"
            wrapMode: Text.WordWrap
            Layout.preferredWidth: root.preferredWidth
        }

        SettingSwitch {
            label: qsTr("Dynamic colors from wallpaper")
            isChecked: root.localEnableColoring
            onIsCheckedChanged: {
                if (root.isLoading)
                    return;
                root.localEnableColoring = isChecked;
                root.applySingleProperty("_enableDynamicColoring", isChecked);
            }
        }

        Controls.Label {
            text: qsTr("Extract the main color from the current wallpaper and apply it to the application theme using the 'kde-material-you-colors' library (must be installed).")
            font.pixelSize: root.typ("small", 12)
            color: root.theme ? root.theme.colors.subtleText : "#888"
            wrapMode: Text.WordWrap
            Layout.preferredWidth: root.preferredWidth
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
        }

        // --- Dynamic Settings ---
        ColumnLayout {
            Layout.fillWidth: true
            enabled: root.localEnableDynamic
            opacity: enabled ? 1.0 : 0.5
            spacing: 12

            Controls.Label {
                text: qsTr("Dynamic Settings")
                font.pixelSize: root.typ("heading3Size", 16)
                font.bold: true
            }

            ColumnLayout {
                spacing: 4
                Controls.Label {
                    text: qsTr("Interval (seconds)")
                    font.bold: true
                }
                Controls.Label {
                    text: qsTr("The time to wait before switching to the next wallpaper.")
                    font.pixelSize: root.typ("small", 12)
                    color: root.theme ? root.theme.colors.subtleText : "#888"
                }
                EditableField {
                    text: root.localInterval.toString()
                    selectedTheme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    onEditingFinished: {
                        if (root.isLoading)
                            return;
                        let val = parseInt(text) || 60;
                        root.localInterval = val;
                        // الحفظ بالملي ثانية
                        root.applySingleProperty("_dynamicWallpapersInterval", val * 1000);
                    }
                }
            }

            ColumnLayout {
                spacing: 4
                Controls.Label {
                    text: qsTr("Current Wallpaper Index")
                    font.bold: true
                }
                Controls.Label {
                    text: qsTr("Shows the index of the currently displayed wallpaper. Use the button to switch to the next one.")
                    font.pixelSize: root.typ("small", 12)
                    color: root.theme ? root.theme.colors.subtleText : "#888"
                }
                RowLayout {
                    EditableField {
                        text: root.localWallpaperIndex.toString()
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        selectedTheme: root.theme
                        onEditingFinished: {
                            if (root.isLoading)
                                return;
                            let val = parseInt(text) || 0;
                            root.localWallpaperIndex = val;
                            root.applySingleProperty("_selectedWallpaperIndex", val);
                        }
                    }
                    MButton {
                        text: "Next"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
                        onClicked: {
                            ThemeManager.switchToNextWallpaper();
                            root.localWallpaperIndex = theme._selectedWallpaperIndex;
                            root.applySingleProperty("_selectedWallpaperIndex", root.localWallpaperIndex);
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 4
                Controls.Label {
                    text: qsTr("Wallpapers Folder Path")
                    font.bold: true
                }
                Controls.Label {
                    text: qsTr("The folder containing the images for the wallpapers.")
                    font.pixelSize: root.typ("small", 12)
                    color: root.theme ? root.theme.colors.subtleText : "#888"
                }
                RowLayout {
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
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
        }

        // --- Static Settings ---
        ColumnLayout {
            Layout.fillWidth: true
            enabled: !root.localEnableDynamic
            opacity: enabled ? 1.0 : 0.5
            spacing: 12

            Controls.Label {
                text: qsTr("Static Settings")
                font.pixelSize: root.typ("heading3Size", 16)
                font.bold: true
            }

            ColumnLayout {
                spacing: 4
                Controls.Label {
                    text: qsTr("Wallpaper Image Path")
                    font.bold: true
                }
                Controls.Label {
                    text: qsTr("The path to the single image to be used as wallpaper.")
                    font.pixelSize: root.typ("small", 12)
                    color: root.theme ? root.theme.colors.subtleText : "#888"
                }
                RowLayout {
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
}
