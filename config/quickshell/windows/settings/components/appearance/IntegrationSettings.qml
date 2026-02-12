// settings/IntegrationSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import Quickshell.Io

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

    property var iconThemeOptions: []
    property var plasmaSchemeOptions: []
    property var kvantumThemeOptions: []
    property var konsoleProfileOptions: []
    property var gtkThemeOptions: []

    function _parseListOutput(text) {
        if (!text || text.trim() === "")
            return [];
        let lines = text.split(/\r?\n/);
        let unique = {};
        for (let i = 0; i < lines.length; i++) {
            let v = lines[i].trim();
            if (v !== "")
                unique[v] = true;
        }
        return Object.keys(unique).sort();
    }

    function _ensureCurrent(list, currentValue) {
        if (!currentValue || currentValue === "")
            return list;
        if (list.indexOf(currentValue) === -1)
            return [currentValue].concat(list);
        return list;
    }

    function _startOptionLoaders() {
        iconThemesLoader.running = true;
        plasmaSchemesLoader.running = true;
        kvantumThemesLoader.running = true;
        konsoleProfilesLoader.running = true;
        gtkThemesLoader.running = true;
    }

    function syncFromTheme() {
        localThemeMode = theme._themeMode;
        localThemeIcons = theme._themeIcons;
        localEnableAccentColoring = theme._enableAccentColoring;
        localPlasmaColorScheme = theme._plasmaColorScheme;
        localQtThemeStyle = theme._qtThemeStyle;
        localKvantumTheme = theme._kvantumTheme;
        localKonsoleProfile = theme._konsoleProfile;
        localGtkTheme = theme._gtkTheme;

        iconThemeOptions = _ensureCurrent(iconThemeOptions, localThemeIcons);
        plasmaSchemeOptions = _ensureCurrent(plasmaSchemeOptions, localPlasmaColorScheme);
        kvantumThemeOptions = _ensureCurrent(kvantumThemeOptions, localKvantumTheme);
        konsoleProfileOptions = _ensureCurrent(konsoleProfileOptions, localKonsoleProfile);
        gtkThemeOptions = _ensureCurrent(gtkThemeOptions, localGtkTheme);
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

    Component.onCompleted: {
        Qt.callLater(() => {
            _startOptionLoaders();
        });
    }

    Process {
        id: iconThemesLoader
        running: false
        command: [
            "bash",
            "-lc",
            "for d in /usr/share/icons ~/.icons ~/.local/share/icons; do [ -d \"$d\" ] && find \"$d\" -maxdepth 2 -name index.theme -printf '%h\\n'; done | xargs -r -n1 basename | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let list = root._parseListOutput(this.text.toString());
                root.iconThemeOptions = root._ensureCurrent(list, root.localThemeIcons);
                console.info("[IntegrationSettings] Icon themes loaded:", root.iconThemeOptions.length);
            }
        }
    }

    Process {
        id: plasmaSchemesLoader
        running: false
        command: [
            "bash",
            "-lc",
            "for d in /usr/share/color-schemes ~/.local/share/color-schemes; do [ -d \"$d\" ] && find \"$d\" -maxdepth 1 -name '*.colors' -printf '%f\\n'; done | sed 's/\\.colors$//' | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let list = root._parseListOutput(this.text.toString());
                root.plasmaSchemeOptions = root._ensureCurrent(list, root.localPlasmaColorScheme);
                console.info("[IntegrationSettings] Plasma schemes loaded:", root.plasmaSchemeOptions.length);
            }
        }
    }

    Process {
        id: kvantumThemesLoader
        running: false
        command: [
            "bash",
            "-lc",
            "for d in /usr/share/Kvantum ~/.config/Kvantum; do [ -d \"$d\" ] && find \"$d\" -maxdepth 2 -name '*.kvconfig' -printf '%h\\n'; done | xargs -r -n1 basename | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let list = root._parseListOutput(this.text.toString());
                root.kvantumThemeOptions = root._ensureCurrent(list, root.localKvantumTheme);
                console.info("[IntegrationSettings] Kvantum themes loaded:", root.kvantumThemeOptions.length);
            }
        }
    }

    Process {
        id: konsoleProfilesLoader
        running: false
        command: [
            "bash",
            "-lc",
            "for d in /usr/share/konsole ~/.local/share/konsole; do [ -d \"$d\" ] && find \"$d\" -maxdepth 1 -name '*.profile' -printf '%f\\n'; done | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let list = root._parseListOutput(this.text.toString());
                root.konsoleProfileOptions = root._ensureCurrent(list, root.localKonsoleProfile);
                console.info("[IntegrationSettings] Konsole profiles loaded:", root.konsoleProfileOptions.length);
            }
        }
    }

    Process {
        id: gtkThemesLoader
        running: false
        command: [
            "bash",
            "-lc",
            "for d in /usr/share/themes ~/.themes ~/.local/share/themes; do [ -d \"$d\" ] && find \"$d\" -maxdepth 2 -type d -name gtk-3.0 -printf '%h\\n'; done | xargs -r -n1 basename | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let list = root._parseListOutput(this.text.toString());
                root.gtkThemeOptions = root._ensureCurrent(list, root.localGtkTheme);
                console.info("[IntegrationSettings] GTK themes loaded:", root.gtkThemeOptions.length);
            }
        }
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
                        onActivated: {
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
                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: root.iconThemeOptions
                        currentIndex: find(root.localThemeIcons)
                        onActivated: {
                            if (root.isLoading)
                                return;
                            if (root.localThemeIcons !== currentText) {
                                root.localThemeIcons = currentText;
                                root.applySingleProperty("_themeIcons", currentText);
                            }
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
            SettingsComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: root.plasmaSchemeOptions
                currentIndex: find(root.localPlasmaColorScheme)
                onActivated: {
                    if (root.isLoading)
                        return;
                    if (root.localPlasmaColorScheme !== currentText) {
                        root.localPlasmaColorScheme = currentText;
                        root.applySingleProperty("_plasmaColorScheme", currentText);
                    }
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
                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: root.kvantumThemeOptions
                        currentIndex: find(root.localKvantumTheme)
                        onActivated: {
                            if (root.isLoading)
                                return;
                            if (root.localKvantumTheme !== currentText) {
                                root.localKvantumTheme = currentText;
                                root.applySingleProperty("_kvantumTheme", currentText);
                            }
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Konsole Profile")
                        font.bold: true
                    }
                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: root.konsoleProfileOptions
                        currentIndex: find(root.localKonsoleProfile)
                        onActivated: {
                            if (root.isLoading)
                                return;
                            if (root.localKonsoleProfile !== currentText) {
                                root.localKonsoleProfile = currentText;
                                root.applySingleProperty("_konsoleProfile", currentText);
                            }
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
            SettingsComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: root.gtkThemeOptions
                currentIndex: find(root.localGtkTheme)
                onActivated: {
                    if (root.isLoading)
                        return;
                    if (root.localGtkTheme !== currentText) {
                        root.localGtkTheme = currentText;
                        root.applySingleProperty("_gtkTheme", currentText);
                    }
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
