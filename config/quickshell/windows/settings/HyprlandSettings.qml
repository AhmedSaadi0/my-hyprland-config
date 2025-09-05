// settings/HyprlandSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/components"

M3GroupBox {
    id: root
    title: qsTr("Hyprland Settings")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme

    signal applyChanges
    signal saveChanges
    signal cancelChanges
    signal resetToDefault

    ColumnLayout {
        id: mainLayout

        spacing: selectedTheme.dimensions.spacingSmall

        // ====================================================================
        // --- القسم الرئيسي: Window Decoration ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Window Decoration")
            font.pixelSize: selectedTheme.typography.heading1Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        // --- الإعداد الفرعي 1.1: Border Width ---
        Controls.Label {
            text: qsTr("Border Width")
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        Controls.Label {
            text: qsTr("Sets the width of the border for all windows.")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
        }
        EditableField {
            text: workingTheme._hyprBorderWidth.toString()
            selectedTheme: root.selectedTheme
            Layout.preferredHeight: 30
            validator: IntValidator {
                bottom: 0 // يمكن أن يكون عرض الإطار 0
            }
            onEditingFinished: {
                workingTheme._hyprBorderWidth = Number(text);
                root.applyChanges();
            }
        }

        // --- الإعداد الفرعي 1.2: Rounding ---
        Controls.Label {
            text: qsTr("Rounding")
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        Controls.Label {
            text: qsTr("Sets the corner radius for all windows.")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
        }
        EditableField {
            text: workingTheme._hyprRounding.toString()
            selectedTheme: root.selectedTheme
            Layout.preferredHeight: 30
            validator: IntValidator {
                bottom: 0
            }
            onEditingFinished: {
                workingTheme._hyprRounding = Number(text);
                root.applyChanges();
            }
        }

        // --- الإعداد الفرعي 1.3: Active Border Color ---
        Controls.Label {
            text: qsTr("Active Border Color")
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        Controls.Label {
            text: qsTr("The color gradient for the active window's border.")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
        }
        EditableField {
            text: workingTheme._hyprActiveBorder
            selectedTheme: root.selectedTheme
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            onEditingFinished: {
                workingTheme._hyprActiveBorder = text;
                root.applyChanges();
            }
        }

        // --- الإعداد الفرعي 1.4: Inactive Border Color ---
        Controls.Label {
            text: qsTr("Inactive Border Color")
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        Controls.Label {
            text: qsTr("The color gradient for inactive windows' borders.")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
        }
        EditableField {
            text: workingTheme._hyprInactiveBorder
            selectedTheme: root.selectedTheme
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            onEditingFinished: {
                workingTheme._hyprInactiveBorder = text;
                root.applyChanges();
            }
        }

        // --- الإعداد الفرعي 1.5: Drop Shadow ---
        SettingSwitch {
            id: _dropShadowSwitch
            label: qsTr("Drop Shadow")
            isChecked: workingTheme._hyprDropShadow === 'yes'
            font.bold: true
            font.pixelSize: selectedTheme.typography.heading3Size
            Layout.topMargin: Kirigami.Units.mediumSpacing
            onIsCheckedChanged: {
                workingTheme._hyprDropShadow = isChecked ? 'yes' : 'no';
                root.applyChanges();
            }
        }
        Controls.Label {
            text: qsTr("Enables or disables drop shadows for windows.")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 500
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
