pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
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

    property string localCursorTheme: ""
    property int localCursorSize: 24

    // --- Dynamic Options ---
    property var iconThemeOptions: []
    property var plasmaSchemeOptions: []
    property var qtStyleOptions: []
    property var kvantumThemeOptions: []
    property var konsoleProfileOptions: []
    property var gtkThemeOptions: []

    property var cursorThemeOptions: []
    property int cursorSizeOptions: 24

    // --- Loading & Error States ---
    property bool isIconThemesLoading: false
    property string iconThemesError: ""
    property bool isPlasmaSchemesLoading: false
    property string plasmaSchemesError: ""
    property bool isQtStylesLoading: false
    property string qtStylesError: ""
    property bool isKvantumThemesLoading: false
    property string kvantumThemesError: ""
    property bool isKonsoleProfilesLoading: false
    property string konsoleProfilesError: ""
    property bool isGtkThemesLoading: false
    property string gtkThemesError: ""

    property bool isCursorThemesLoading: false
    property string cursorThemesError: ""

    // --- Reusable Components (match HyprlandSettings.qml) ---
    component SectionCard: Rectangle {
        id: sectionCard
        property string title: ""
        property string subtitle: ""
        default property alias content: sectionContent.data

        Layout.fillWidth: true
        color: root.theme.colors.leftMenuBgColorV1.alpha(0.72)
        radius: root.theme.dimensions.baseRadius
        border.color: root.theme.colors.primary.alpha(0.12)
        border.width: 1

        implicitHeight: sectionColumn.implicitHeight + 28

        ColumnLayout {
            id: sectionColumn
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Controls.Label {
                    text: sectionCard.title
                    font.pixelSize: root.typ("heading4Size", 16)
                    font.bold: true
                    color: root.theme.colors.primary
                }

                SettingsHelperText {
                    visible: sectionCard.subtitle !== ""
                    text: sectionCard.subtitle
                    Layout.preferredWidth: 540
                }
            }

            ColumnLayout {
                id: sectionContent
                Layout.fillWidth: true
                spacing: 12
            }
        }
    }

    component FieldLabel: Controls.Label {
        font.bold: true
        color: root.theme.colors.leftMenuFgColorV1
    }

    // --- Helper Functions ---
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
        qtStylesLoader.running = true;
        kvantumThemesLoader.running = true;
        konsoleProfilesLoader.running = true;
        gtkThemesLoader.running = true;
        cursorThemesLoader.running = true;
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
        localCursorTheme = theme._cursorTheme;
        localCursorSize = theme._cursorSize;

        iconThemeOptions = _ensureCurrent(iconThemeOptions, localThemeIcons);
        plasmaSchemeOptions = _ensureCurrent(plasmaSchemeOptions, localPlasmaColorScheme);
        qtStyleOptions = _ensureCurrent(qtStyleOptions, localQtThemeStyle);
        kvantumThemeOptions = _ensureCurrent(kvantumThemeOptions, localKvantumTheme);
        konsoleProfileOptions = _ensureCurrent(konsoleProfileOptions, localKonsoleProfile);
        gtkThemeOptions = _ensureCurrent(gtkThemeOptions, localGtkTheme);
        cursorThemeOptions = _ensureCurrent(cursorThemeOptions, localCursorTheme);
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
            "_gtkTheme": localGtkTheme,
            "_cursorTheme": localCursorTheme,
            "_cursorSize": localCursorSize
        };
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            _startOptionLoaders();
        });
    }

    // --- Icon Themes Loader ---
    Process {
        id: iconThemesLoader
        running: false
        command: App.scripts.python.listIconThemesCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text.toString());
                    root.iconThemeOptions = root._ensureCurrent(list, root.localThemeIcons);
                    root.iconThemesError = "";
                    console.info("[IntegrationSettings] Icon themes loaded:", list.length);
                } catch (e) {
                    root.iconThemesError = qsTr("Failed to parse icon themes: %1").arg(e);
                    console.error(root.iconThemesError);
                }
                root.isIconThemesLoading = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.toString().trim() !== "") {
                    root.iconThemesError = this.text.toString().trim();
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root.isIconThemesLoading = true;
                root.iconThemesError = "";
            }
        }
    }

    // --- Plasma Schemes Loader ---
    Process {
        id: plasmaSchemesLoader
        running: false
        command: App.scripts.python.listPlasmaSchemesCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text.toString());
                    root.plasmaSchemeOptions = root._ensureCurrent(list, root.localPlasmaColorScheme);
                    root.plasmaSchemesError = "";
                    console.info("[IntegrationSettings] Plasma schemes loaded:", list.length);
                } catch (e) {
                    root.plasmaSchemesError = qsTr("Failed to parse plasma schemes: %1").arg(e);
                    console.error(root.plasmaSchemesError);
                }
                root.isPlasmaSchemesLoading = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.toString().trim() !== "") {
                    root.plasmaSchemesError = this.text.toString().trim();
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root.isPlasmaSchemesLoading = true;
                root.plasmaSchemesError = "";
            }
        }
    }

    // --- Qt Styles Loader ---
    Process {
        id: qtStylesLoader
        running: false
        command: App.scripts.python.listQtStylesCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text.toString());
                    root.qtStyleOptions = root._ensureCurrent(list, root.localQtThemeStyle);
                    root.qtStylesError = "";
                    console.info("[IntegrationSettings] Qt styles loaded:", list.length);
                } catch (e) {
                    root.qtStylesError = qsTr("Failed to parse Qt styles: %1").arg(e);
                    console.error(root.qtStylesError);
                }
                root.isQtStylesLoading = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.toString().trim() !== "") {
                    root.qtStylesError = this.text.toString().trim();
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root.isQtStylesLoading = true;
                root.qtStylesError = "";
            }
        }
    }

    // --- Kvantum Themes Loader ---
    Process {
        id: kvantumThemesLoader
        running: false
        command: App.scripts.python.listKvantumThemesCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text.toString());
                    root.kvantumThemeOptions = root._ensureCurrent(list, root.localKvantumTheme);
                    root.kvantumThemesError = "";
                    console.info("[IntegrationSettings] Kvantum themes loaded:", list.length);
                } catch (e) {
                    root.kvantumThemesError = qsTr("Failed to parse Kvantum themes: %1").arg(e);
                    console.error(root.kvantumThemesError);
                }
                root.isKvantumThemesLoading = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.toString().trim() !== "") {
                    root.kvantumThemesError = this.text.toString().trim();
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root.isKvantumThemesLoading = true;
                root.kvantumThemesError = "";
            }
        }
    }

    // --- Konsole Profiles Loader ---
    Process {
        id: konsoleProfilesLoader
        running: false
        command: App.scripts.python.listKonsoleProfilesCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text.toString());
                    root.konsoleProfileOptions = root._ensureCurrent(list, root.localKonsoleProfile);
                    root.konsoleProfilesError = "";
                    console.info("[IntegrationSettings] Konsole profiles loaded:", list.length);
                } catch (e) {
                    root.konsoleProfilesError = qsTr("Failed to parse Konsole profiles: %1").arg(e);
                    console.error(root.konsoleProfilesError);
                }
                root.isKonsoleProfilesLoading = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.toString().trim() !== "") {
                    root.konsoleProfilesError = this.text.toString().trim();
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root.isKonsoleProfilesLoading = true;
                root.konsoleProfilesError = "";
            }
        }
    }

    // --- GTK Themes Loader ---
    Process {
        id: gtkThemesLoader
        running: false
        command: App.scripts.python.listGtkThemesCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text.toString());
                    root.gtkThemeOptions = root._ensureCurrent(list, root.localGtkTheme);
                    root.gtkThemesError = "";
                    console.info("[IntegrationSettings] GTK themes loaded:", list.length);
                } catch (e) {
                    root.gtkThemesError = qsTr("Failed to parse GTK themes: %1").arg(e);
                    console.error(root.gtkThemesError);
                }
                root.isGtkThemesLoading = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.toString().trim() !== "") {
                    root.gtkThemesError = this.text.toString().trim();
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root.isGtkThemesLoading = true;
                root.gtkThemesError = "";
            }
        }
    }

    // --- Cursor Themes Loader ---
    Process {
        id: cursorThemesLoader
        running: false
        command: App.scripts.python.listCursorThemesCommand
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text.toString());
                    root.cursorThemeOptions = root._ensureCurrent(list, root.localCursorTheme);
                    root.cursorThemesError = "";
                    console.info("[IntegrationSettings] Cursor themes loaded:", list.length);
                } catch (e) {
                    root.cursorThemesError = qsTr("Failed to parse cursor themes: %1").arg(e);
                    console.error(root.cursorThemesError);
                }
                root.isCursorThemesLoading = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.toString().trim() !== "") {
                    root.cursorThemesError = this.text.toString().trim();
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root.isCursorThemesLoading = true;
                root.cursorThemesError = "";
            }
        }
    }

    // --- Debounce Timers for Safety Net ---
    Timer {
        id: themeModeApplyTimer
        interval: 300
        property string pendingValue: ""
        onTriggered: {
            if (pendingValue !== "") {
                root.applySingleProperty("_themeMode", pendingValue);
                pendingValue = "";
            }
        }
    }
    Timer {
        id: iconThemeApplyTimer
        interval: 300
        property string pendingValue: ""
        onTriggered: {
            if (pendingValue !== "") {
                root.applySingleProperty("_themeIcons", pendingValue);
                pendingValue = "";
            }
        }
    }
    Timer {
        id: plasmaSchemeApplyTimer
        interval: 300
        property string pendingValue: ""
        onTriggered: {
            if (pendingValue !== "") {
                root.applySingleProperty("_plasmaColorScheme", pendingValue);
                pendingValue = "";
            }
        }
    }
    Timer {
        id: qtStyleApplyTimer
        interval: 300
        property string pendingValue: ""
        onTriggered: {
            if (pendingValue !== "") {
                root.applySingleProperty("_qtThemeStyle", pendingValue);
                pendingValue = "";
            }
        }
    }
    Timer {
        id: kvantumThemeApplyTimer
        interval: 300
        property string pendingValue: ""
        onTriggered: {
            if (pendingValue !== "") {
                root.applySingleProperty("_kvantumTheme", pendingValue);
                pendingValue = "";
            }
        }
    }
    Timer {
        id: konsoleProfileApplyTimer
        interval: 300
        property string pendingValue: ""
        onTriggered: {
            if (pendingValue !== "") {
                root.applySingleProperty("_konsoleProfile", pendingValue);
                pendingValue = "";
            }
        }
    }
    Timer {
        id: gtkThemeApplyTimer
        interval: 300
        property string pendingValue: ""
        onTriggered: {
            if (pendingValue !== "") {
                root.applySingleProperty("_gtkTheme", pendingValue);
                pendingValue = "";
            }
        }
    }

    Timer {
        id: cursorThemeApplyTimer
        interval: 300
        property string pendingValue: ""
        onTriggered: {
            if (pendingValue !== "") {
                root.applySingleProperty("_cursorTheme", pendingValue);
                pendingValue = "";
            }
        }
    }

    Timer {
        id: cursorSizeApplyTimer
        interval: 300
        property int pendingValue: 0
        onTriggered: {
            if (pendingValue > 0) {
                root.applySingleProperty("_cursorSize", pendingValue);
                pendingValue = 0;
            }
        }
    }

    // --- Pure QML UI (matches HyprlandSettings.qml style) ---
    ColumnLayout {
        spacing: root.dim("spacingMedium", 8)
        Layout.preferredWidth: 620

        SettingsHelperText {
            Layout.fillWidth: true
            Layout.preferredWidth: 580
            text: qsTr("Configure system integration settings for Plasma, Qt, GTK, and Kvantum. All options are dynamically loaded from your system.")
        }

        SectionCard {
            title: qsTr("General")
            subtitle: qsTr("Theme mode and icon theme settings.")

            ColumnLayout {
                spacing: 4
                FieldLabel {
                    text: qsTr("Theme Mode")
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
                            themeModeApplyTimer.pendingValue = currentText;
                            themeModeApplyTimer.restart();
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 4
                FieldLabel {
                    text: qsTr("Icon Theme")
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
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
                                iconThemeApplyTimer.pendingValue = currentText;
                                iconThemeApplyTimer.restart();
                            }
                        }
                    }
                    Controls.BusyIndicator {
                        running: root.isIconThemesLoading
                        visible: running
                        implicitWidth: 24
                        implicitHeight: 24
                    }
                }
                Controls.Label {
                    text: root.iconThemesError
                    color: root.theme?.colors?.error || "#ff4444"
                    font.pixelSize: root.typ("small", 12)
                    visible: root.iconThemesError !== ""
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    FieldLabel {
                        text: qsTr("Cursor Theme")
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        SettingsComboBox {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            model: root.cursorThemeOptions
                            currentIndex: find(root.localCursorTheme)
                            onActivated: {
                                if (root.isLoading)
                                    return;
                                if (root.localCursorTheme !== currentText) {
                                    root.localCursorTheme = currentText;
                                    cursorThemeApplyTimer.pendingValue = currentText;
                                    cursorThemeApplyTimer.restart();
                                }
                            }
                        }
                        Controls.BusyIndicator {
                            running: root.isCursorThemesLoading
                            visible: running
                            implicitWidth: 24
                            implicitHeight: 24
                        }
                    }
                    Controls.Label {
                        text: root.cursorThemesError
                        color: root.theme?.colors?.error || "#ff4444"
                        font.pixelSize: root.typ("small", 12)
                        visible: root.cursorThemesError !== ""
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    FieldLabel {
                        text: qsTr("Cursor Size")
                    }
                    SliderWithLabel {
                        Layout.fillWidth: true
                        label: qsTr("px")
                        from: 8
                        to: 128
                        value: root.localCursorSize
                        onEditingFinished: v => {
                            if (root.isLoading)
                                return;
                            if (root.localCursorSize !== v) {
                                root.localCursorSize = v;
                                cursorSizeApplyTimer.pendingValue = v;
                                cursorSizeApplyTimer.restart();
                            }
                        }
                    }
                }
            }
        }

        SectionCard {
            title: qsTr("Plasma & Qt")
            subtitle: qsTr("Plasma color scheme, Qt widget style, Kvantum theme, and Konsole profile.")

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
            SettingsHelperText {
                text: qsTr("Overrides the Plasma color scheme to use the theme's primary color as a global accent color.")
                Layout.preferredWidth: 540
            }

            ColumnLayout {
                spacing: 4
                FieldLabel {
                    text: qsTr("Plasma Color Scheme")
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
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
                                plasmaSchemeApplyTimer.pendingValue = currentText;
                                plasmaSchemeApplyTimer.restart();
                            }
                        }
                    }
                    Controls.BusyIndicator {
                        running: root.isPlasmaSchemesLoading
                        visible: running
                        implicitWidth: 24
                        implicitHeight: 24
                    }
                }
                Controls.Label {
                    text: root.plasmaSchemesError
                    color: root.theme?.colors?.error || "#ff4444"
                    font.pixelSize: root.typ("small", 12)
                    visible: root.plasmaSchemesError !== ""
                }
            }

            ColumnLayout {
                spacing: 4
                FieldLabel {
                    text: qsTr("Qt Widget Style")
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: root.qtStyleOptions
                        currentIndex: find(root.localQtThemeStyle)
                        onActivated: {
                            if (root.isLoading)
                                return;
                            if (root.localQtThemeStyle !== currentText) {
                                root.localQtThemeStyle = currentText;
                                qtStyleApplyTimer.pendingValue = currentText;
                                qtStyleApplyTimer.restart();
                            }
                        }
                    }
                    Controls.BusyIndicator {
                        running: root.isQtStylesLoading
                        visible: running
                        implicitWidth: 24
                        implicitHeight: 24
                    }
                }
                Controls.Label {
                    text: root.qtStylesError
                    color: root.theme?.colors?.error || "#ff4444"
                    font.pixelSize: root.typ("small", 12)
                    visible: root.qtStylesError !== ""
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    FieldLabel {
                        text: qsTr("Kvantum Theme")
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
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
                                        kvantumThemeApplyTimer.pendingValue = currentText;
                                        kvantumThemeApplyTimer.restart();
                                    }
                                }
                            }
                        Controls.BusyIndicator {
                            running: root.isKvantumThemesLoading
                            visible: running
                            implicitWidth: 24
                            implicitHeight: 24
                        }
                    }
                    Controls.Label {
                        text: root.kvantumThemesError
                        color: root.theme?.colors?.error || "#ff4444"
                        font.pixelSize: root.typ("small", 12)
                        visible: root.kvantumThemesError !== ""
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    FieldLabel {
                        text: qsTr("Konsole Profile")
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
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
                                    konsoleProfileApplyTimer.pendingValue = currentText;
                                    konsoleProfileApplyTimer.restart();
                                }
                            }
                        }
                        Controls.BusyIndicator {
                            running: root.isKonsoleProfilesLoading
                            visible: running
                            implicitWidth: 24
                            implicitHeight: 24
                        }
                    }
                    Controls.Label {
                        text: root.konsoleProfilesError
                        color: root.theme?.colors?.error || "#ff4444"
                        font.pixelSize: root.typ("small", 12)
                        visible: root.konsoleProfilesError !== ""
                    }
                }
            }
        }

        SectionCard {
            title: qsTr("GTK")
            subtitle: qsTr("GTK theme settings for GTK applications.")

            ColumnLayout {
                spacing: 4
                FieldLabel {
                    text: qsTr("GTK Theme")
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
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
                                gtkThemeApplyTimer.pendingValue = currentText;
                                gtkThemeApplyTimer.restart();
                            }
                        }
                    }
                    Controls.BusyIndicator {
                        running: root.isGtkThemesLoading
                        visible: running
                        implicitWidth: 24
                        implicitHeight: 24
                    }
                }
                Controls.Label {
                    text: root.gtkThemesError
                    color: root.theme?.colors?.error || "#ff4444"
                    font.pixelSize: root.typ("small", 12)
                    visible: root.gtkThemesError !== ""
                }
            }
        }

        Item {
            Layout.fillHeight: true
            width: 1
        }
    }
}
