// settings/GeneralSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs
import Qt.labs.platform

import "root:/components"

M3GroupBox {
    id: root
    title: qsTr("General Settings")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme

    signal saveThemeAs(string themeName)
    signal importTheme(var selectedFile)
    signal exportTheme(var selectedFile)
    signal resetAllSettings
    // signal applyChanges

    ColumnLayout {
        id: mainLayout
        spacing: selectedTheme.dimensions.spacingSmall

        // ====================================================================
        // --- القسم الأول: معلومات الثيم (Theme Information) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Theme Information")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }
        Controls.Label {
            text: qsTr("Theme Name")
            font.bold: true
        }
        EditableField {
            text: workingTheme.themeName
            selectedTheme: root.selectedTheme
            enabled: false

            Layout.fillWidth: true
            Layout.preferredHeight: 30
            onEditingFinished: {
                workingTheme.themeName = text;
                root.applyChanges();
            }
        }

        Kirigami.Separator {
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        // ====================================================================
        // --- القسم الثاني: إدارة الثيمات (Theme Management) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Theme Management")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: selectedTheme.dimensions.spacingMedium

            // MButton {
            //     Layout.fillWidth: true
            //     text: qsTr("Save As...")
            //     onClicked: saveAsDialog.open()
            // }
            MButton {
                Layout.fillWidth: true
                text: qsTr("Import")
                onClicked: importDialog.open()
            }
            MButton {
                Layout.fillWidth: true
                text: qsTr("Export")
                onClicked: exportDialog.open()
            }
        }

        Kirigami.Separator {
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        // ====================================================================
        // --- القسم الثالث: الخطر (Danger Zone) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Danger Zone")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            color: Kirigami.Theme.negativeTextColor // لون تحذيري
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        MButton {
            text: qsTr("Reset All Settings")
            Layout.fillWidth: true
            highlighted: true // Or some other property to make it look dangerous
            // Maybe use a different color for the button if possible
            onClicked: root.resetAllSettings()
        }
        Controls.Label {
            text: qsTr("This will reset all settings across all pages to their default values. This action cannot be undone.")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
            wrapMode: Text.WordWrap
        }
    }

    // Controls.Dialog {
    //     id: saveAsDialog
    //
    //     title: "Save Theme As"
    //     standardButtons: Controls.Dialog.Ok | Controls.Dialog.Cancel
    //     modal: true
    //     width: 300
    //
    //     onAccepted: {
    //         root.saveThemeAs(newNameInput.text);
    //     }
    //
    //     contentItem: Controls.TextField {
    //         id: newNameInput
    //         placeholderText: qsTr("Enter new theme name")
    //         // قم بتعبئة الحقل بالاسم الحالي
    //         // text: selectedTheme.themeName
    //     }
    // }

    FileDialog {
        id: importDialog

        onAccepted: {
            root.importTheme(file.toString().replace("file://", ""));
        }
    }

    FileDialog {
        id: exportDialog
        fileMode: FileDialog.SaveFile
        folder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        nameFilters: ["Theme files (*.json)", "All files (*)"]
        onAccepted: {
            console.info("CALLING EXPORT");
            root.exportTheme(file.toString().replace("file://", ""));
        }
    }
    // No footer needed here as save/cancel is for the whole theme, not this page.
}
