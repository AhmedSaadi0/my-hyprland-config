// settings/IntegrationSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/windows/settings/components"

BaseThemeSettings {
    id: root

    // --- Header ---
    title: qsTr("System Integration Settings")
    icon: "󰒋"

    showApplyButton: true

    // --- Local State ---
    property string localThemeMode: "dark"
    property string localThemeIcons: ""
    property bool localEnableAccentColoring: false
    property string localPlasmaColorScheme: ""
    property string localQtThemeStyle: ""
    property string localKvantumTheme: ""
    property string localKonsoleProfile: ""
    property string localGtkTheme: ""

    function syncFromTheme() {
        localThemeMode = theme._themeMode;
        localThemeIcons = theme._themeIcons;
        localEnableAccentColoring = theme._enableAccentColoring;
        localPlasmaColorScheme = theme._plasmaColorScheme;
        localQtThemeStyle = theme._qtThemeStyle;
        localKvantumTheme = theme._kvantumTheme;
        localKonsoleProfile = theme._konsoleProfile;
        localGtkTheme = theme._gtkTheme;
    }

    function serializeData() {
        return {
            "_themeMode": localThemeMode,
            "_themeIcons": localThemeIcons,
            "_enableAccentColoring": localEnableAccentColoring,
            "_plasmaColorScheme": localPlasmaColorScheme,
            "_qtThemeStyle": localQtThemeStyle,
            "_kvantumTheme": localKvantumTheme,
            "_konsoleProfile": localKonsoleProfile,
            "_gtkTheme": localGtkTheme
        };
    }

    ColumnLayout {
        id: mainLayout
        spacing: root.dim("spacingSmall", 5)
        Layout.preferredWidth: 590

        // ====================================================================
        // --- (General) ---
        // ====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Controls.Label {
                text: qsTr("General")
                font.pixelSize: root.typ("heading2Size", 18)
                font.bold: true
                Layout.bottomMargin: 5
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.dim("spacingMedium", 10)

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
                        currentIndex: find(root.localThemeMode)
                        onCurrentTextChanged: {
                            if (root.isLoading)
                                return;
                            if (root.localThemeMode !== currentText) {
                                root.localThemeMode = currentText;
                                root.applySingleProperty("_themeMode", currentText);
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
                        text: root.localThemeIcons
                        selectedTheme: root.theme
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onEditingFinished: {
                            if (root.isLoading)
                                return;
                            root.localThemeIcons = text;
                            root.applySingleProperty("_themeIcons", text);
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

        // ====================================================================
        // --- Plasma & Qt ---
        // ====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Controls.Label {
                text: qsTr("Plasma & Qt")
                font.pixelSize: root.typ("heading2Size", 18)
                font.bold: true
                Layout.bottomMargin: 5
            }

            SettingSwitch {
                label: qsTr("Apply single accent color")
                isChecked: root.localEnableAccentColoring
                font.bold: true
                onIsCheckedChanged: {
                    if (root.isLoading)
                        return;
                    root.localEnableAccentColoring = isChecked;
                    root.applySingleProperty("_enableAccentColoring", isChecked);
                }
            }
            Controls.Label {
                text: qsTr("Overrides the Plasma color scheme to use the theme's primary color as a global accent color.")
                font.pixelSize: root.typ("small", 12)
                color: root.theme ? root.theme.colors.subtleText : "#888"
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 500
                Layout.bottomMargin: 10
            }

            // --- بقية إعدادات Plasma & Qt ---
            Controls.Label {
                text: qsTr("Plasma Color Scheme")
                font.bold: true
            }
            EditableField {
                text: root.localPlasmaColorScheme
                selectedTheme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                onEditingFinished: {
                    if (root.isLoading)
                        return;
                    root.localPlasmaColorScheme = text;
                    root.applySingleProperty("_plasmaColorScheme", text);
                }
            }

            Controls.Label {
                text: qsTr("Qt Widget Style")
                font.bold: true
                Layout.topMargin: 10
            }
            SettingsComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: ["Breeze", "Fusion", "Windows"]
                editable: true
                editText: root.localQtThemeStyle
                onAccepted: {
                    if (root.isLoading)
                        return;
                    if (root.localQtThemeStyle !== editText) {
                        root.localQtThemeStyle = editText;
                        root.applySingleProperty("_qtThemeStyle", editText);
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: root.dim("spacingMedium", 10)

                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Kvantum Theme")
                        font.bold: true
                    }
                    EditableField {
                        text: root.localKvantumTheme
                        selectedTheme: root.theme
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onEditingFinished: {
                            if (root.isLoading)
                                return;
                            root.localKvantumTheme = text;
                            root.applySingleProperty("_kvantumTheme", text);
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
                        text: root.localKonsoleProfile
                        selectedTheme: root.theme
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onEditingFinished: {
                            if (root.isLoading)
                                return;
                            root.localKonsoleProfile = text;
                            root.applySingleProperty("_konsoleProfile", text);
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

        // ====================================================================
        // --- القسم الثالث: GTK ---
        // ====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Controls.Label {
                text: qsTr("GTK")
                font.pixelSize: root.typ("heading2Size", 18)
                font.bold: true
                Layout.bottomMargin: 5
            }

            Controls.Label {
                text: qsTr("GTK Theme")
                font.bold: true
            }
            EditableField {
                text: root.localGtkTheme
                selectedTheme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                onEditingFinished: {
                    if (root.isLoading)
                        return;
                    root.localGtkTheme = text;
                    root.applySingleProperty("_gtkTheme", text);
                }
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
            width: 1
        }
    }
}
