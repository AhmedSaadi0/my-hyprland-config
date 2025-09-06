import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs

import "root:/components"
import "root:/themes"

M3GroupBox {
    id: root
    title: qsTr("Color Settings")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme

    signal applyChanges
    signal saveChanges
    signal cancelChanges
    signal resetToDefault
    signal openColorDialog(string colorProperty)

    // دالة مساعدة لتجنب تكرار الكود
    function createColorRow(parent, label, colorProperty) {
        var column = Qt.createQmlObject(`
            import QtQuick;
            import QtQuick.Layouts;
            import QtQuick.Controls as Controls;
            import "root:/components";

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Controls.Label { text: qsTr("` + label + `"); font.bold: true; }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        width: 28; height: 28
                        radius: 4
                        border.color: "#888"
                        border.width: 1
                        color: workingTheme.` + colorProperty + `
                    }

                    EditableField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: workingTheme.` + colorProperty + `.toString()
                        selectedTheme: root.selectedTheme
                        onEditingFinished: {
                            workingTheme.` + colorProperty + ` = text;
                            root.applyChanges();
                        }
                    }
                    MButton {
                        text: "󰃉"
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 30
                        onClicked: root.openColorDialog('` + colorProperty + `')
                    }
                }
            }
        `, parent, "dynamicColorRow");
        return column;
    }

    ColumnLayout {
        id: mainLayout
        spacing: selectedTheme.dimensions.spacingSmall

        // ====================================================================
        // --- القسم الأول: الألوان الأساسية (Core Palette) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Core Palette")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        GridLayout {
            columns: 2
            columnSpacing: selectedTheme.dimensions.spacingMedium
            rowSpacing: selectedTheme.dimensions.spacingMedium
            Layout.fillWidth: true

            Component.onCompleted: {
                createColorRow(this, "Primary", "_primary");
                createColorRow(this, "Secondary", "_secondary");
                createColorRow(this, "On Primary", "_onPrimary");
                createColorRow(this, "On Secondary", "_onSecondary");
                createColorRow(this, "Subtle Text", "_subtleTextColor");
            }
        }

        Kirigami.Separator {
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        // ====================================================================
        // --- القسم الثاني: الشريط العلوي (Topbar) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Topbar")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        GridLayout {
            columns: 2
            columnSpacing: selectedTheme.dimensions.spacingMedium
            rowSpacing: selectedTheme.dimensions.spacingMedium
            Layout.fillWidth: true

            Component.onCompleted: {
                createColorRow(this, "Color", "_topbarColor");
                createColorRow(this, "Foreground", "_topbarFgColor");
                createColorRow(this, "BG V1", "_topbarBgColorV1");
                createColorRow(this, "FG V1", "_topbarFgColorV1");
                createColorRow(this, "BG V2", "_topbarBgColorV2");
                createColorRow(this, "FG V2", "_topbarFgColorV2");
                createColorRow(this, "BG V3", "_topbarBgColorV3");
                createColorRow(this, "FG V3", "_topbarFgColorV3");
            }
        }

        Kirigami.Separator {
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        // ====================================================================
        // --- القسم الثالث: القائمة الجانبية (Left Menu) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Left Menu")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        GridLayout {
            columns: 2
            columnSpacing: selectedTheme.dimensions.spacingMedium
            rowSpacing: selectedTheme.dimensions.spacingMedium
            Layout.fillWidth: true

            Component.onCompleted: {
                createColorRow(this, "BG V1", "_leftMenuBgColorV1");
                createColorRow(this, "FG V1", "_leftMenuFgColorV1");
                createColorRow(this, "BG V2", "_leftMenuBgColorV2");
                createColorRow(this, "FG V2", "_leftMenuFgColorV2");
                createColorRow(this, "BG V3", "_leftMenuBgColorV3");
                createColorRow(this, "FG V3", "_leftMenuFgColorV3");
            }
        }

        Kirigami.Separator {
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        // ====================================================================
        // --- القسم الرابع: متفرقات (Miscellaneous) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Miscellaneous")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        GridLayout {
            columns: 2
            columnSpacing: selectedTheme.dimensions.spacingMedium
            rowSpacing: selectedTheme.dimensions.spacingMedium
            Layout.fillWidth: true

            Component.onCompleted: {
                createColorRow(this, "Volume OSD BG", "_volOsdBgColor");
                createColorRow(this, "Volume OSD FG", "_volOsdFgColor");
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
