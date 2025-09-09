// settings/WallpaperSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/components"

M3GroupBox {
    id: root
    title: qsTr("Wallpaper Settings")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme

    signal openFolderDialog
    signal openFileDialog
    signal dynamicColoringChanged
    signal nextWallpaperClicked
    signal applyChanges
    signal saveChanges
    signal cancelChanges
    signal resetToDefault

    ColumnLayout {
        id: mainLayout

        spacing: selectedTheme.dimensions.spacingSmall

        // ====================================================================
        // --- القسم الرئيسي الأول: General ---
        // ====================================================================
        Controls.Label {
            text: qsTr("General")
            font.pixelSize: selectedTheme.typography.heading1Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        // --- الإعداد الفرعي 1.1: Enable dynamic wallpapers ---
        SettingSwitch {
            id: _enableDynamicWallpapersSwitch
            label: qsTr("Enable dynamic wallpapers")
            isChecked: workingTheme._enableDynamicWallpapers
            font.bold: true
            font.pixelSize: selectedTheme.typography.heading3Size
            onIsCheckedChanged: {
                workingTheme._enableDynamicWallpapers = isChecked;
                root.applyChanges();
            }
        }
        Controls.Label {
            text: qsTr("Automatically cycle through a collection of wallpapers from a selected folder.")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 500
        }

        // --- الإعداد الفرعي 1.2: Dynamic colors ---
        SettingSwitch {
            label: qsTr("Dynamic colors from wallpaper")
            isChecked: workingTheme._enableDynamicColoring
            font.pixelSize: selectedTheme.typography.heading3Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
            onIsCheckedChanged: {
                workingTheme._enableDynamicColoring = isChecked;
                if (isChecked) {
                    root.dynamicColoringChanged();
                    return;
                }
                root.applyChanges();
            }
        }
        Controls.Label {
            text: qsTr("Extract the main color from the current wallpaper and apply it to the application theme using the 'kde-material-you-colors' library (must be installed).")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 620
        }

        ColumnLayout {
            Layout.topMargin: Kirigami.Units.largeSpacing
            enabled: _enableDynamicWallpapersSwitch.isChecked

            // spacing: selectedTheme.dimensions.spacingSmall
            spacing: 0

            Controls.Label {
                text: qsTr("Dynamic Wallpaper Settings")
                // font.pixelSize: selectedTheme.typography.heading2Size
                font.pixelSize: selectedTheme.typography.heading3Size
                font.bold: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            // --- الإعداد الفرعي 2.1: Interval ---
            Controls.Label {
                text: qsTr("Wallpapers interval (seconds)")
                font.bold: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
            }
            Controls.Label {
                text: qsTr("The time to wait before switching to the next wallpaper.")
                font.pixelSize: selectedTheme.typography.small
                color: selectedTheme.colors.subtleText
            }
            EditableField {
                text: (workingTheme._dynamicWallpapersInterval / 1000).toString()
                selectedTheme: root.selectedTheme
                Layout.preferredHeight: 30
                validator: IntValidator {
                    bottom: 1
                }
                onEditingFinished: {
                    workingTheme._dynamicWallpapersInterval = Number(text) * 1000;
                    root.applyChanges();
                }
            }

            // --- الإعداد الفرعي 2.2: Current Wallpaper ---
            Controls.Label {
                text: qsTr("Current wallpaper")
                font.bold: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
            }
            Controls.Label {
                text: qsTr("Shows the index of the currently displayed wallpaper. Use the button to switch to the next one.")
                font.pixelSize: selectedTheme.typography.small
                color: selectedTheme.colors.subtleText
            }
            RowLayout {
                EditableField {
                    text: workingTheme._selectedWallpaperIndex
                    // readOnly: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    selectedTheme: root.selectedTheme
                    validator: IntValidator {
                        bottom: 1
                    }
                    onEditingFinished: {
                        workingTheme._selectedWallpaperIndex = Number(text);
                        root.applyChanges();
                    }
                }
                MButton {
                    text: qsTr("Next Wallpaper")
                    iconText: ""
                    iconPreferredWidth: 1
                    textPreferredWidth: 4
                    onClicked: root.nextWallpaperClicked()
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 30
                }
            }

            // --- الإعداد الفرعي 2.3: Wallpapers Folder ---
            Controls.Label {
                text: qsTr("Wallpapers folder")
                font.bold: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
            }
            Controls.Label {
                text: qsTr("The folder containing the images for the wallpapers.")
                font.pixelSize: selectedTheme.typography.small
                color: selectedTheme.colors.subtleText
            }
            RowLayout {
                EditableField {
                    text: workingTheme._dynamicWallpapersPath
                    // readOnly: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    selectedTheme: root.selectedTheme
                }
                MButton {
                    text: ""
                    font: selectedTheme.typography.iconFont
                    onClicked: root.openFolderDialog()
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 30
                }
            }
        }

        // ====================================================================
        // --- القسم الرئيسي الثالث: Static Wallpaper Settings ---
        // ====================================================================
        ColumnLayout {
            Layout.topMargin: Kirigami.Units.largeSpacing
            enabled: !_enableDynamicWallpapersSwitch.isChecked
            spacing: Kirigami.Units.smallSpacing

            Controls.Label {
                text: qsTr("Static Wallpaper")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            // --- الإعداد الفرعي 3.1: Image Path ---
            Controls.Label {
                text: qsTr("Image path")
                font.bold: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
            }
            Controls.Label {
                text: qsTr("The path to the single image to be used as wallpaper.")

                font.pixelSize: selectedTheme.typography.small
                color: selectedTheme.colors.subtleText
            }
            RowLayout {
                Layout.fillWidth: true
                EditableField {
                    text: workingTheme._wallpaper
                    // readOnly: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    selectedTheme: root.selectedTheme
                }
                MButton {
                    text: ""
                    font: selectedTheme.typography.iconFont
                    onClicked: root.openFileDialog()
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 40
                }
            }
        }
    }

    footer: RowLayout {
        spacing: ThemeManager.selectedTheme.dimensions.spacingMedium

        MButton {
            text: "Reset to default"
            Layout.preferredWidth: 150
            onClicked: resetToDefault()
        }
        MButton {
            text: "Cancel"
            Layout.preferredWidth: 80
            onClicked: cancelChanges()
        }

        // عنصر فارغ لدفع زر الحفظ إلى اليمين
        Item {
            Layout.fillWidth: true
        }

        MButton {
            text: "Save"
            Layout.preferredWidth: 80
            highlighted: true
            onClicked: saveChanges()
        }
    }
}
