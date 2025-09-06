// settings/IntegrationSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/components"

M3GroupBox {
    id: root
    title: qsTr("System Integration Settings")
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
        // --- القسم الأول: عام (General) ---
        // ====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Controls.Label {
                text: qsTr("General")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: selectedTheme.dimensions.spacingMedium

                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Theme Mode")
                        font.bold: true
                    }
                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ["dark", "light"]
                        currentIndex: find(workingTheme._themeMode)
                        onCurrentTextChanged: {
                            if (workingTheme._themeMode !== currentText) {
                                workingTheme._themeMode = currentText;
                                root.applyChanges();
                            }
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Icon Theme")
                        font.bold: true
                    }
                    EditableField {
                        text: workingTheme._themeIcons
                        selectedTheme: root.selectedTheme
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onEditingFinished: {
                            workingTheme._themeIcons = text;
                            root.applyChanges();
                        }
                    }
                }
            }
        }

        // ====================================================================
        // --- القسم الثاني: Plasma & Qt ---
        // ====================================================================
        ColumnLayout {
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            spacing: 0

            Controls.Label {
                text: qsTr("Plasma & Qt")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            SettingSwitch {
                label: qsTr("Apply single accent color")
                isChecked: workingTheme._enableAccentColoring
                font.bold: true
                onIsCheckedChanged: {
                    workingTheme._enableAccentColoring = isChecked;
                    root.applyChanges();
                }
            }
            Controls.Label {
                text: qsTr("Overrides the Plasma color scheme to use the theme's primary color as a global accent color.")
                font.pixelSize: selectedTheme.typography.small
                color: selectedTheme.colors.subtleText
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 500
                Layout.bottomMargin: Kirigami.Units.mediumSpacing
            }

            // --- بقية إعدادات Plasma & Qt ---
            Controls.Label {
                text: qsTr("Plasma Color Scheme")
                font.bold: true
            }
            EditableField {
                text: workingTheme._plasmaColorScheme
                selectedTheme: root.selectedTheme
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                onEditingFinished: {
                    workingTheme._plasmaColorScheme = text;
                    root.applyChanges();
                }
            }

            Controls.Label {
                text: qsTr("Qt Widget Style")
                font.bold: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
            }
            SettingsComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: ["Breeze", "Fusion", "Windows"]
                editable: true
                editText: workingTheme._qtThemeStyle
                onAccepted: {
                    if (workingTheme._qtThemeStyle !== editText) {
                        workingTheme._qtThemeStyle = editText;
                        root.applyChanges();
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
                spacing: selectedTheme.dimensions.spacingMedium

                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Kvantum Theme")
                        font.bold: true
                    }
                    EditableField {
                        text: workingTheme._kvantumTheme
                        selectedTheme: root.selectedTheme
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onEditingFinished: {
                            workingTheme._kvantumTheme = text;
                            root.applyChanges();
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Konsole Profile")
                        font.bold: true
                    }
                    EditableField {
                        text: workingTheme._konsoleProfile
                        selectedTheme: root.selectedTheme
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onEditingFinished: {
                            workingTheme._konsoleProfile = text;
                            root.applyChanges();
                        }
                    }
                }
            }
        }

        // ====================================================================
        // --- القسم الثالث: GTK ---
        // ====================================================================
        ColumnLayout {
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            spacing: 0

            Controls.Label {
                text: qsTr("GTK")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            Controls.Label {
                text: qsTr("GTK Theme")
                font.bold: true
            }
            EditableField {
                text: workingTheme._gtkTheme
                selectedTheme: root.selectedTheme
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                onEditingFinished: {
                    workingTheme._gtkTheme = text;
                    root.applyChanges();
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
