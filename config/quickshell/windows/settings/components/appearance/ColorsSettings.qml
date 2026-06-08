// windows/settings/ColorsSettings.qml

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import Qt.labs.platform

import "root:/components"
import "root:/config"
import "root:/services"
import "root:/themes"
import "root:/windows/settings/components"

BaseThemeSettings {
    id: root

    title: qsTr("Color Settings")
    icon: ""
    showUndoRedoButtons: true

    // --- Local Variables ---
    property color localPrimary: ThemeManager.selectedTheme.colors.primary
    property color localSecondary: ThemeManager.selectedTheme.colors.secondary
    property color localOnPrimary: ThemeManager.selectedTheme.colors.onPrimary
    property color localOnSecondary: ThemeManager.selectedTheme.colors.onSecondary
    property color localSubtleText: ThemeManager.selectedTheme.colors.subtleText

    property color localTertiary: ThemeManager.selectedTheme.colors.tertiary
    property color localOnTertiary: ThemeManager.selectedTheme.colors.onTertiary
    property color localError: ThemeManager.selectedTheme.colors.error
    property color localOnError: ThemeManager.selectedTheme.colors.onError
    property color localSuccess: ThemeManager.selectedTheme.colors.success
    property color localOnSuccess: ThemeManager.selectedTheme.colors.onSuccess
    property color localWarning: ThemeManager.selectedTheme.colors.warning
    property color localOnWarning: ThemeManager.selectedTheme.colors.onWarning

    property color localTopbarColor: ThemeManager.selectedTheme.colors.topbarColor
    property color localTopbarFgColor: ThemeManager.selectedTheme.colors.topbarFgColor
    property color localTopbarBgV1: ThemeManager.selectedTheme.colors.topbarBgColorV1
    property color localTopbarFgV1: ThemeManager.selectedTheme.colors.topbarFgColorV1
    property color localTopbarBgV2: ThemeManager.selectedTheme.colors.topbarBgColorV2
    property color localTopbarFgV2: ThemeManager.selectedTheme.colors.topbarFgColorV2
    property color localTopbarBgV3: ThemeManager.selectedTheme.colors.topbarBgColorV3
    property color localTopbarFgV3: ThemeManager.selectedTheme.colors.topbarFgColorV3

    property color localMenuBgV1: ThemeManager.selectedTheme.colors.leftMenuBgColorV1
    property color localMenuFgV1: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
    property color localMenuBgV2: ThemeManager.selectedTheme.colors.leftMenuBgColorV2
    property color localMenuFgV2: ThemeManager.selectedTheme.colors.leftMenuFgColorV2
    property color localMenuBgV3: ThemeManager.selectedTheme.colors.leftMenuBgColorV3
    property color localMenuFgV3: ThemeManager.selectedTheme.colors.leftMenuFgColorV3

    property color localVolOsdBg: ThemeManager.selectedTheme.colors.volOsdBgColor
    property color localVolOsdFg: ThemeManager.selectedTheme.colors.volOsdFgColor

    // --- Undo/Redo State ---
    property bool _isRestoring: false
    property string _historyThemeName: ""
    property var _colorHistory: []
    property int _historyIndex: -1
    readonly property bool canUndo: _historyIndex > 0
    readonly property bool canRedo: _historyIndex < _colorHistory.length - 1

    Component.onCompleted: {
        ThemeManager.aiThemeAssistant.chatModel = aiChatModel;
        Qt.callLater(() => {
            Qt.callLater(() => {
                recordHistory();
            });
        });
    }

    Component.onDestruction: {
        ThemeManager.aiThemeAssistant.chatModel = null;
    }

    function syncFromTheme() {
        const getCol = val => val !== undefined ? val : theme.colors.topbarColor;

        localPrimary = getCol(theme._primary);
        localSecondary = getCol(theme._secondary);
        localOnPrimary = getCol(theme._onPrimary);
        localOnSecondary = getCol(theme._onSecondary);
        localSubtleText = getCol(theme._subtleTextColor);

        localTertiary = getCol(theme._tertiary);
        localOnTertiary = getCol(theme._onTertiary);
        localError = getCol(theme._error);
        localOnError = getCol(theme._onError);
        localSuccess = getCol(theme._success);
        localOnSuccess = getCol(theme._onSuccess);
        localWarning = getCol(theme._warning);
        localOnWarning = getCol(theme._onWarning);

        localTopbarColor = getCol(theme._topbarColor);
        localTopbarFgColor = getCol(theme._topbarFgColor);
        localTopbarBgV1 = getCol(theme._topbarBgColorV1);
        localTopbarFgV1 = getCol(theme._topbarFgColorV1);
        localTopbarBgV2 = getCol(theme._topbarBgColorV2);
        localTopbarFgV2 = getCol(theme._topbarFgColorV2);
        localTopbarBgV3 = getCol(theme._topbarBgColorV3);
        localTopbarFgV3 = getCol(theme._topbarFgColorV3);

        localMenuBgV1 = getCol(theme._leftMenuBgColorV1);
        localMenuFgV1 = getCol(theme._leftMenuFgColorV1);
        localMenuBgV2 = getCol(theme._leftMenuBgColorV2);
        localMenuFgV2 = getCol(theme._leftMenuFgColorV2);
        localMenuBgV3 = getCol(theme._leftMenuBgColorV3);
        localMenuFgV3 = getCol(theme._leftMenuFgColorV3);

        localVolOsdBg = getCol(theme._volOsdBgColor);
        localVolOsdFg = getCol(theme._volOsdFgColor);
    }

    // --- Undo/Redo ---

    function recordHistory() {
        if (!root.theme)
            return;

        const themeName = root.theme.themeName;

        if (_historyThemeName !== "" && _historyThemeName !== themeName) {
            _colorHistory = [];
            _historyIndex = -1;
        }

        _historyThemeName = themeName;

        const state = serializeData();
        let newHistory = _colorHistory;

        if (_historyIndex < newHistory.length - 1) {
            newHistory = newHistory.slice(0, _historyIndex + 1);
        }

        newHistory = newHistory.concat([state]);
        _colorHistory = newHistory;
        _historyIndex = _colorHistory.length - 1;

        console.log("[Undo] recordHistory: length=" + _colorHistory.length + " index=" + _historyIndex + " canUndo=" + canUndo);
    }

    function undo() {
        if (!canUndo)
            return;

        _isRestoring = true;
        _historyIndex--;
        restoreFromHistory(_historyIndex);
        _isRestoring = false;
    }

    function redo() {
        if (!canRedo)
            return;

        _isRestoring = true;
        _historyIndex++;
        restoreFromHistory(_historyIndex);
        _isRestoring = false;
    }

    function restoreFromHistory(index) {
        const state = _colorHistory[index];
        if (!state)
            return;

        for (const key in state) {
            setLocalColor(key, state[key]);
        }

        ThemeManager.updateAndApplyTheme(state, false);
    }

    function clearHistory() {
        _colorHistory = [];
        _historyIndex = -1;
        _historyThemeName = "";
    }

    function serializeData() {
        return {
            "_primary": localPrimary.toString(),
            "_secondary": localSecondary.toString(),
            "_onPrimary": localOnPrimary.toString(),
            "_onSecondary": localOnSecondary.toString(),
            "_subtleTextColor": localSubtleText.toString(),
            "_tertiary": localTertiary.toString(),
            "_onTertiary": localOnTertiary.toString(),
            "_error": localError.toString(),
            "_onError": localOnError.toString(),
            "_success": localSuccess.toString(),
            "_onSuccess": localOnSuccess.toString(),
            "_warning": localWarning.toString(),
            "_onWarning": localOnWarning.toString(),
            "_topbarColor": localTopbarColor.toString(),
            "_topbarFgColor": localTopbarFgColor.toString(),
            "_topbarBgColorV1": localTopbarBgV1.toString(),
            "_topbarFgColorV1": localTopbarFgV1.toString(),
            "_topbarBgColorV2": localTopbarBgV2.toString(),
            "_topbarFgColorV2": localTopbarFgV2.toString(),
            "_topbarBgColorV3": localTopbarBgV3.toString(),
            "_topbarFgColorV3": localTopbarFgV3.toString(),
            "_leftMenuBgColorV1": localMenuBgV1.toString(),
            "_leftMenuFgColorV1": localMenuFgV1.toString(),
            "_leftMenuBgColorV2": localMenuBgV2.toString(),
            "_leftMenuFgColorV2": localMenuFgV2.toString(),
            "_leftMenuBgColorV3": localMenuBgV3.toString(),
            "_leftMenuFgColorV3": localMenuFgV3.toString(),
            "_volOsdBgColor": localVolOsdBg.toString(),
            "_volOsdFgColor": localVolOsdFg.toString()
        };
    }

    function setLocalColor(key, value) {
        switch (key) {
        case "_primary":
            localPrimary = value;
            return true;
        case "_secondary":
            localSecondary = value;
            return true;
        case "_onPrimary":
            localOnPrimary = value;
            return true;
        case "_onSecondary":
            localOnSecondary = value;
            return true;
        case "_subtleTextColor":
            localSubtleText = value;
            return true;
        case "_tertiary":
            localTertiary = value;
            return true;
        case "_onTertiary":
            localOnTertiary = value;
            return true;
        case "_error":
            localError = value;
            return true;
        case "_onError":
            localOnError = value;
            return true;
        case "_success":
            localSuccess = value;
            return true;
        case "_onSuccess":
            localOnSuccess = value;
            return true;
        case "_warning":
            localWarning = value;
            return true;
        case "_onWarning":
            localOnWarning = value;
            return true;
        case "_topbarColor":
            localTopbarColor = value;
            return true;
        case "_topbarFgColor":
            localTopbarFgColor = value;
            return true;
        case "_topbarBgColorV1":
            localTopbarBgV1 = value;
            return true;
        case "_topbarFgColorV1":
            localTopbarFgV1 = value;
            return true;
        case "_topbarBgColorV2":
            localTopbarBgV2 = value;
            return true;
        case "_topbarFgColorV2":
            localTopbarFgV2 = value;
            return true;
        case "_topbarBgColorV3":
            localTopbarBgV3 = value;
            return true;
        case "_topbarFgColorV3":
            localTopbarFgV3 = value;
            return true;
        case "_leftMenuBgColorV1":
            localMenuBgV1 = value;
            return true;
        case "_leftMenuFgColorV1":
            localMenuFgV1 = value;
            return true;
        case "_leftMenuBgColorV2":
            localMenuBgV2 = value;
            return true;
        case "_leftMenuFgColorV2":
            localMenuFgV2 = value;
            return true;
        case "_leftMenuBgColorV3":
            localMenuBgV3 = value;
            return true;
        case "_leftMenuFgColorV3":
            localMenuFgV3 = value;
            return true;
        case "_volOsdBgColor":
            localVolOsdBg = value;
            return true;
        case "_volOsdFgColor":
            localVolOsdFg = value;
            return true;
        }
        return false;
    }

    // --- AI Assistant Wrappers ---

    function sendColorAiMessage() {
        const message = aiInput.text.trim();
        if (!message || ThemeManager.aiThemeAssistant.aiBusy)
            return;

        aiInput.text = "";
        ThemeManager.aiThemeAssistant.sendMessage(message, root.theme, serializeData());
    }

    function applyPendingAiChanges() {
        ThemeManager.aiThemeAssistant.applyChanges(ThemeManager.aiThemeAssistant.pendingAiChanges, root.theme);
        recordHistory();
    }

    // --- Helpers ---
    ListModel {
        id: aiChatModel
    }

    Connections {
        target: root
        function onSaveChanges() {
            assistant.clearChat();
            clearHistory();
        }
        function onCancelChanges() {
            clearHistory();
        }
    }

    ColorDialog {
        id: mainColorDialog
        property var activeCallback: null
        property var targetedProp: ""
        onAccepted: {
            if (activeCallback)
                activeCallback(color.toString());
            activeCallback = null;
        }
        onRejected: activeCallback = null
    }

    component ChatMessage: Rectangle {
        id: chatMessage

        Layout.fillWidth: true
        radius: root.dim("baseRadius", 8) / 2
        color: chatMessage.isUser ? root.theme.colors.primary.alpha(0.16) : root.theme.colors.leftMenuBgColorV2.alpha(0.86)
        border.color: chatMessage.isUser ? root.theme.colors.primary.alpha(0.35) : root.theme.colors.secondary.alpha(0.22)
        border.width: 1
        implicitHeight: chatMessageColumn.implicitHeight + 16

        property string role: "assistant"
        property string message: ""
        property string changesSummary: ""
        readonly property bool isUser: role === "user"

        ColumnLayout {
            id: chatMessageColumn
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Controls.Label {
                Layout.fillWidth: true
                text: chatMessage.isUser ? qsTr("You") : qsTr("Nibras")
                color: chatMessage.isUser ? root.theme.colors.primary : root.theme.colors.secondary
                font.bold: true
                font.pixelSize: root.typ("small", 12)
            }

            Controls.Label {
                Layout.fillWidth: true
                text: chatMessage.message
                wrapMode: Text.WordWrap
                color: root.theme.colors.leftMenuFgColorV1
                font.pixelSize: root.typ("small", 12)
            }

            Controls.Label {
                Layout.fillWidth: true
                visible: chatMessage.changesSummary !== ""
                text: chatMessage.changesSummary
                wrapMode: Text.WordWrap
                color: root.theme.colors.subtleText
                font.pixelSize: root.typ("small", 12)
            }
        }
    }

    component ColorRow: ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        property string label
        property color value: root.theme.colors.topbarColor
        property var targetedProp: ""
        signal userChanged(string newValue)

        Controls.Label {
            text: qsTr(parent.label)
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Rectangle {
                width: 28
                height: 28
                radius: 4
                border.color: root.theme.colors.topbarFgColor.alpha(0.4)
                border.width: 1
                color: value
            }
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: value.toString()
                selectedTheme: root.theme
                onEditingFinished: userChanged(text)
            }
            MButton {
                text: "󰃉"
                Layout.preferredWidth: 35
                Layout.preferredHeight: 30
                onClicked: {
                    mainColorDialog.currentColor = value;
                    mainColorDialog.activeCallback = function (c) {
                        userChanged(c);
                    };
                    mainColorDialog.open();
                }
            }
        }
    }

    // --- AI Assistant References ---
    readonly property var assistant: ThemeManager.aiThemeAssistant

    // --- UI Content ---
    ColumnLayout {
        spacing: 15
        Layout.preferredWidth: 590

        SectionCard {
            title: qsTr("AI Color Assistant")
            subtitle: qsTr("Discuss the current palette and request live color changes.")
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Controls.ScrollView {
                    id: aiChatScroll
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    clip: true

                    background: Rectangle {
                        color: root.theme.colors.leftMenuBgColorV2.alpha(0.55)
                        radius: root.dim("baseRadius", 8) / 2
                        border.color: root.theme.colors.primary.alpha(0.12)
                        border.width: 1
                    }

                    ColumnLayout {
                        width: aiChatScroll.availableWidth
                        spacing: 8

                        Repeater {
                            model: aiChatModel.count

                            delegate: ChatMessage {
                                required property int index
                                readonly property var chatItem: aiChatModel.get(index)

                                role: chatItem ? (chatItem.role || "") : ""
                                message: chatItem ? (chatItem.message || "") : ""
                                changesSummary: chatItem ? (chatItem.changesSummary || "") : ""
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    EditableField {
                        id: aiInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        selectedTheme: root.theme
                        horizontalAlignment: Text.AlignLeft
                        enabled: !root.assistant.aiBusy
                        placeholderText: qsTr("Ask Nibras about these colors...")
                        onAccepted: root.sendColorAiMessage()
                    }

                    MButton {
                        text: root.assistant.aiBusy ? qsTr("...") : qsTr("Send")
                        highlighted: true
                        enabled: !root.assistant.aiBusy && aiInput.text.trim() !== ""
                        Layout.preferredWidth: 82
                        Layout.preferredHeight: 34
                        onClicked: root.sendColorAiMessage()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.assistant.aiBusy || root.assistant.hasPendingAiChanges || root.assistant.aiError !== "" || aiChatModel.count > 0
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Controls.BusyIndicator {
                            running: root.assistant.aiBusy
                            visible: running
                            implicitWidth: 18
                            implicitHeight: 18
                        }

                        Controls.Label {
                            Layout.fillWidth: true
                            text: root.assistant.aiBusy ? qsTr("Thinking...") : (root.assistant.aiError !== "" ? root.assistant.aiError : root.assistant.summarizeChanges(root.assistant.pendingAiChanges))
                            color: root.assistant.aiError !== "" ? root.theme.colors.error : root.theme.colors.subtleText
                            elide: Text.ElideRight
                            font.pixelSize: root.typ("small", 12)
                        }
                    }

                    MButton {
                        text: qsTr("Apply AI Changes")
                        visible: root.assistant.hasPendingAiChanges
                        Layout.preferredWidth: 145
                        Layout.preferredHeight: 30
                        onClicked: root.applyPendingAiChanges()
                    }

                    MButton {
                        text: qsTr("Clear")
                        visible: aiChatModel.count > 0
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 30
                        onClicked: root.assistant.clearChat()
                    }
                }
            }
        }

        // --- Core Palette ---
        SectionCard {
            title: qsTr("Core Palette")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 15
                rowSpacing: 10

                ColorRow {
                    label: qsTr("Primary")
                    value: root.localPrimary
                    onUserChanged: v => {
                        root.localPrimary = v;
                        root.applySingleProperty("_primary", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("On Primary")
                    value: root.localOnPrimary
                    onUserChanged: v => {
                        root.localOnPrimary = v;
                        root.applySingleProperty("_onPrimary", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("Secondary")
                    value: root.localSecondary
                    onUserChanged: v => {
                        root.localSecondary = v;
                        root.applySingleProperty("_secondary", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("On Secondary")
                    value: root.localOnSecondary
                    onUserChanged: v => {
                        root.localOnSecondary = v;
                        root.applySingleProperty("_onSecondary", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("Tertiary")
                    value: root.localTertiary
                    onUserChanged: v => {
                        root.localTertiary = v;
                        root.applySingleProperty("_tertiary", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("On Tertiary")
                    value: root.localOnTertiary
                    onUserChanged: v => {
                        root.localOnTertiary = v;
                        root.applySingleProperty("_onTertiary", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("Error")
                    value: root.localError
                    onUserChanged: v => {
                        root.localError = v;
                        root.applySingleProperty("_error", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("On Error")
                    value: root.localOnError
                    onUserChanged: v => {
                        root.localOnError = v;
                        root.applySingleProperty("_onError", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("Success")
                    value: root.localSuccess
                    onUserChanged: v => {
                        root.localSuccess = v;
                        root.applySingleProperty("_success", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("On Success")
                    value: root.localOnSuccess
                    onUserChanged: v => {
                        root.localOnSuccess = v;
                        root.applySingleProperty("_onSuccess", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("Warning")
                    value: root.localWarning
                    onUserChanged: v => {
                        root.localWarning = v;
                        root.applySingleProperty("_warning", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("On Warning")
                    value: root.localOnWarning
                    onUserChanged: v => {
                        root.localOnWarning = v;
                        root.applySingleProperty("_onWarning", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: qsTr("Subtle Text")
                    value: root.localSubtleText
                    onUserChanged: v => {
                        root.localSubtleText = v;
                        root.applySingleProperty("_subtleTextColor", v);
                        root.recordHistory();
                    }
                }
            }
        }

        // --- Topbar ---
        SectionCard {
            title: qsTr("Topbar")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 15
                rowSpacing: 10

                ColorRow {
                    label: "Background"
                    value: root.localTopbarColor
                    onUserChanged: v => {
                        root.localTopbarColor = v;
                        root.applySingleProperty("_topbarColor", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Foreground"
                    value: root.localTopbarFgColor
                    onUserChanged: v => {
                        root.localTopbarFgColor = v;
                        root.applySingleProperty("_topbarFgColor", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "BG V1"
                    value: root.localTopbarBgV1
                    onUserChanged: v => {
                        root.localTopbarBgV1 = v;
                        root.applySingleProperty("_topbarBgColorV1", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "FG V1"
                    value: root.localTopbarFgV1
                    onUserChanged: v => {
                        root.localTopbarFgV1 = v;
                        root.applySingleProperty("_topbarFgColorV1", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "BG V2"
                    value: root.localTopbarBgV2
                    onUserChanged: v => {
                        root.localTopbarBgV2 = v;
                        root.applySingleProperty("_topbarBgColorV2", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "FG V2"
                    value: root.localTopbarFgV2
                    onUserChanged: v => {
                        root.localTopbarFgV2 = v;
                        root.applySingleProperty("_topbarFgColorV2", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "BG V3"
                    value: root.localTopbarBgV3
                    onUserChanged: v => {
                        root.localTopbarBgV3 = v;
                        root.applySingleProperty("_topbarBgColorV3", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "FG V3"
                    value: root.localTopbarFgV3
                    onUserChanged: v => {
                        root.localTopbarFgV3 = v;
                        root.applySingleProperty("_topbarFgColorV3", v);
                        root.recordHistory();
                    }
                }
            }
        }

        // --- Left Menu ---
        SectionCard {
            title: qsTr("Left Menu")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 15
                rowSpacing: 10

                ColorRow {
                    label: "BG V1"
                    value: root.localMenuBgV1
                    onUserChanged: v => {
                        root.localMenuBgV1 = v;
                        root.applySingleProperty("_leftMenuBgColorV1", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "FG V1"
                    value: root.localMenuFgV1
                    onUserChanged: v => {
                        root.localMenuFgV1 = v;
                        root.applySingleProperty("_leftMenuFgColorV1", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "BG V2"
                    value: root.localMenuBgV2
                    onUserChanged: v => {
                        root.localMenuBgV2 = v;
                        root.applySingleProperty("_leftMenuBgColorV2", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "FG V2"
                    value: root.localMenuFgV2
                    onUserChanged: v => {
                        root.localMenuFgV2 = v;
                        root.applySingleProperty("_leftMenuFgColorV2", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "BG V3"
                    value: root.localMenuBgV3
                    onUserChanged: v => {
                        root.localMenuBgV3 = v;
                        root.applySingleProperty("_leftMenuBgColorV3", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "FG V3"
                    value: root.localMenuFgV3
                    onUserChanged: v => {
                        root.localMenuFgV3 = v;
                        root.applySingleProperty("_leftMenuFgColorV3", v);
                        root.recordHistory();
                    }
                }
            }
        }

        // --- Misc ---
        SectionCard {
            title: qsTr("Misc")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 15
                rowSpacing: 10

                ColorRow {
                    label: "Vol OSD BG"
                    value: root.localVolOsdBg
                    onUserChanged: v => {
                        root.localVolOsdBg = v;
                        root.applySingleProperty("_volOsdBgColor", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Vol OSD FG"
                    value: root.localVolOsdFg
                    onUserChanged: v => {
                        root.localVolOsdFg = v;
                        root.applySingleProperty("_volOsdFgColor", v);
                        root.recordHistory();
                    }
                }
            }
        }

        Item {
            height: 20
            width: 1
        }
    }
}
