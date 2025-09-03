import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs

import "root:/components"
import "root:/themes"

Kirigami.ScrollablePage {
    title: "Theme Settings"

    signal applyClicked
    signal saveClicked
    signal revertClicked

    CustomColorDialog {
        id: colorDialog
    }

    FontDialog {
        id: fontDialog
        title: "Select a Font"
        modality: Qt.ApplicationModal
        onAccepted: {
            fontNameField.text = selectedFont.family;
        }
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: Kirigami.Units.largeSpacing
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - Kirigami.Units.largeSpacing * 2, Kirigami.Units.gridUnit * 90)

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Controls.Label {
                text: "Theme: MyCustomTheme"
                font.bold: true
                Kirigami.FormData.isSection: true
            }

            Controls.Label {
                text: "Colors"
                font.bold: true
                Kirigami.FormData.isSection: true
            }

            Controls.Label {
                text: "Primary Color:"
            }
            RowLayout {
                EditableField {
                    id: primaryColorField
                    selectedTheme: ThemeManager.selectedTheme
                    text: "#8be9fd"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                }
                Rectangle {
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 30
                    color: primaryColorField.text
                    border.color: "gray"
                    border.width: 1
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                }
                MButton {
                    text: "󰃉"
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 30
                    onClicked: {
                        colorDialog.targetField = primaryColorField;
                        colorDialog.open();
                    }
                }
            }

            Controls.Label {
                text: "Secondary Color:"
            }
            RowLayout {
                EditableField {
                    id: secondaryColorField
                    selectedTheme: ThemeManager.selectedTheme
                    text: "#50fa7b"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                }
                Rectangle {
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 30
                    color: secondaryColorField.text
                    border.color: "gray"
                    border.width: 1
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                }
                MButton {
                    text: "󰃉"
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 30
                    onClicked: {
                        colorDialog.targetField = secondaryColorField;
                        colorDialog.open();
                    }
                }
            }

            Controls.Label {
                text: "Dimensions"
                font.bold: true
                Kirigami.FormData.isSection: true
            }
            Controls.Label {
                text: "Border Radius:"
            }
            RowLayout {
                spacing: Kirigami.Units.gridUnit
                Controls.Slider {
                    id: radiusSlider
                    Layout.preferredWidth: 200
                    from: 0
                    to: 20
                    value: 12
                    Layout.fillWidth: true
                }
                Controls.Label {
                    text: radiusSlider.value.toFixed(2)
                }
            }
            Controls.Label {
                text: "Header Height:"
            }
            Controls.SpinBox {
                value: 40
                from: 20
                to: 80
            }

            Controls.Label {
                text: "Fonts"
                font.bold: true
                Kirigami.FormData.isSection: true
            }
            Controls.Label {
                text: "Primary Font:"
            }
            RowLayout {
                EditableField {
                    id: fontNameField
                    selectedTheme: ThemeManager.selectedTheme
                    text: "Fira Code"
                    readOnly: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                }
                MButton {
                    text: "󰃉"
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 30
                    onClicked: {
                        fontDialog.open();
                    }
                }
            }
        }
    }

    footer: Controls.Frame {
        width: parent.width
        padding: Kirigami.Units.smallSpacing

        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.largeSpacing

            // --- هذا هو السطر الذي تمت إضافته ---
            anchors.bottomMargin: Kirigami.Units.smallSpacing

            spacing: Kirigami.Units.smallSpacing

            MButton {
                text: "Revert"
                Layout.preferredWidth: 80
                onClicked: revertClicked()
            }
            MButton {
                text: "Apply"
                Layout.preferredWidth: 80
                onClicked: applyClicked()
            }
            MButton {
                text: "Save"
                Layout.preferredWidth: 80
                highlighted: true
                onClicked: saveClicked()
            }
        }
    }
}
