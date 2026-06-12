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

    // --- Local Variables (M3 Tokens) ---
    property color localPrimary: ThemeManager.selectedTheme.colors.primary
    property color localSecondary: ThemeManager.selectedTheme.colors.secondary
    property color localOnPrimary: ThemeManager.selectedTheme.colors.onPrimary
    property color localOnSecondary: ThemeManager.selectedTheme.colors.onSecondary
    property color localTertiary: ThemeManager.selectedTheme.colors.tertiary
    property color localOnTertiary: ThemeManager.selectedTheme.colors.onTertiary
    property color localError: ThemeManager.selectedTheme.colors.error
    property color localOnError: ThemeManager.selectedTheme.colors.onError

    property color localSurface: ThemeManager.selectedTheme.colors.surface
    property color localOnSurface: ThemeManager.selectedTheme.colors.onSurface
    property color localSurfaceDim: ThemeManager.selectedTheme.colors.surfaceDim
    property color localSurfaceBright: ThemeManager.selectedTheme.colors.surfaceBright

    property color localSurfaceContainerLowest: ThemeManager.selectedTheme.colors.surfaceContainerLowest
    property color localSurfaceContainerLow: ThemeManager.selectedTheme.colors.surfaceContainerLow
    property color localSurfaceContainer: ThemeManager.selectedTheme.colors.surfaceContainer
    property color localSurfaceContainerHigh: ThemeManager.selectedTheme.colors.surfaceContainerHigh
    property color localSurfaceContainerHighest: ThemeManager.selectedTheme.colors.surfaceContainerHighest

    property color localSurfaceVariant: ThemeManager.selectedTheme.colors.surfaceVariant
    property color localOnSurfaceVariant: ThemeManager.selectedTheme.colors.onSurfaceVariant

    property color localPrimaryContainer: ThemeManager.selectedTheme.colors.primaryContainer
    property color localOnPrimaryContainer: ThemeManager.selectedTheme.colors.onPrimaryContainer
    property color localSecondaryContainer: ThemeManager.selectedTheme.colors.secondaryContainer
    property color localOnSecondaryContainer: ThemeManager.selectedTheme.colors.onSecondaryContainer
    property color localTertiaryContainer: ThemeManager.selectedTheme.colors.tertiaryContainer
    property color localOnTertiaryContainer: ThemeManager.selectedTheme.colors.onTertiaryContainer
    property color localErrorContainer: ThemeManager.selectedTheme.colors.errorContainer
    property color localOnErrorContainer: ThemeManager.selectedTheme.colors.onErrorContainer

    property color localOutline: ThemeManager.selectedTheme.colors.outline
    property color localOutlineVariant: ThemeManager.selectedTheme.colors.outlineVariant

    property color localInverseSurface: ThemeManager.selectedTheme.colors.inverseSurface
    property color localOnInverseSurface: ThemeManager.selectedTheme.colors.onInverseSurface
    property color localInversePrimary: ThemeManager.selectedTheme.colors.inversePrimary

    property color localShadow: ThemeManager.selectedTheme.colors.shadow
    property color localScrim: ThemeManager.selectedTheme.colors.scrim

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
        const getCol = val => val !== undefined ? val : theme.colors.surface;

        localPrimary = getCol(theme._primary);
        localSecondary = getCol(theme._secondary);
        localOnPrimary = getCol(theme._onPrimary);
        localOnSecondary = getCol(theme._onSecondary);
        localTertiary = getCol(theme._tertiary);
        localOnTertiary = getCol(theme._onTertiary);
        localError = getCol(theme._error);
        localOnError = getCol(theme._onError);

        localSurface = getCol(theme._surface);
        localOnSurface = getCol(theme._onSurface);
        localSurfaceDim = getCol(theme._surfaceDim);
        localSurfaceBright = getCol(theme._surfaceBright);

        localSurfaceContainerLowest = getCol(theme._surfaceContainerLowest);
        localSurfaceContainerLow = getCol(theme._surfaceContainerLow);
        localSurfaceContainer = getCol(theme._surfaceContainer);
        localSurfaceContainerHigh = getCol(theme._surfaceContainerHigh);
        localSurfaceContainerHighest = getCol(theme._surfaceContainerHighest);

        localSurfaceVariant = getCol(theme._surfaceVariant);
        localOnSurfaceVariant = getCol(theme._onSurfaceVariant);

        localPrimaryContainer = getCol(theme._primaryContainer);
        localOnPrimaryContainer = getCol(theme._onPrimaryContainer);
        localSecondaryContainer = getCol(theme._secondaryContainer);
        localOnSecondaryContainer = getCol(theme._onSecondaryContainer);
        localTertiaryContainer = getCol(theme._tertiaryContainer);
        localOnTertiaryContainer = getCol(theme._onTertiaryContainer);
        localErrorContainer = getCol(theme._errorContainer);
        localOnErrorContainer = getCol(theme._onErrorContainer);

        localOutline = getCol(theme._outline);
        localOutlineVariant = getCol(theme._outlineVariant);

        localInverseSurface = getCol(theme._inverseSurface);
        localOnInverseSurface = getCol(theme._onInverseSurface);
        localInversePrimary = getCol(theme._inversePrimary);

        localShadow = getCol(theme._shadow);
        localScrim = getCol(theme._scrim);
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
            "_tertiary": localTertiary.toString(),
            "_onTertiary": localOnTertiary.toString(),
            "_error": localError.toString(),
            "_onError": localOnError.toString(),
            "_surface": localSurface.toString(),
            "_onSurface": localOnSurface.toString(),
            "_surfaceDim": localSurfaceDim.toString(),
            "_surfaceBright": localSurfaceBright.toString(),
            "_surfaceContainerLowest": localSurfaceContainerLowest.toString(),
            "_surfaceContainerLow": localSurfaceContainerLow.toString(),
            "_surfaceContainer": localSurfaceContainer.toString(),
            "_surfaceContainerHigh": localSurfaceContainerHigh.toString(),
            "_surfaceContainerHighest": localSurfaceContainerHighest.toString(),
            "_surfaceVariant": localSurfaceVariant.toString(),
            "_onSurfaceVariant": localOnSurfaceVariant.toString(),
            "_primaryContainer": localPrimaryContainer.toString(),
            "_onPrimaryContainer": localOnPrimaryContainer.toString(),
            "_secondaryContainer": localSecondaryContainer.toString(),
            "_onSecondaryContainer": localOnSecondaryContainer.toString(),
            "_tertiaryContainer": localTertiaryContainer.toString(),
            "_onTertiaryContainer": localOnTertiaryContainer.toString(),
            "_errorContainer": localErrorContainer.toString(),
            "_onErrorContainer": localOnErrorContainer.toString(),
            "_outline": localOutline.toString(),
            "_outlineVariant": localOutlineVariant.toString(),
            "_inverseSurface": localInverseSurface.toString(),
            "_onInverseSurface": localOnInverseSurface.toString(),
            "_inversePrimary": localInversePrimary.toString(),
            "_shadow": localShadow.toString(),
            "_scrim": localScrim.toString()
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
        case "_surface":
            localSurface = value;
            return true;
        case "_onSurface":
            localOnSurface = value;
            return true;
        case "_surfaceDim":
            localSurfaceDim = value;
            return true;
        case "_surfaceBright":
            localSurfaceBright = value;
            return true;
        case "_surfaceContainerLowest":
            localSurfaceContainerLowest = value;
            return true;
        case "_surfaceContainerLow":
            localSurfaceContainerLow = value;
            return true;
        case "_surfaceContainer":
            localSurfaceContainer = value;
            return true;
        case "_surfaceContainerHigh":
            localSurfaceContainerHigh = value;
            return true;
        case "_surfaceContainerHighest":
            localSurfaceContainerHighest = value;
            return true;
        case "_surfaceVariant":
            localSurfaceVariant = value;
            return true;
        case "_onSurfaceVariant":
            localOnSurfaceVariant = value;
            return true;
        case "_primaryContainer":
            localPrimaryContainer = value;
            return true;
        case "_onPrimaryContainer":
            localOnPrimaryContainer = value;
            return true;
        case "_secondaryContainer":
            localSecondaryContainer = value;
            return true;
        case "_onSecondaryContainer":
            localOnSecondaryContainer = value;
            return true;
        case "_tertiaryContainer":
            localTertiaryContainer = value;
            return true;
        case "_onTertiaryContainer":
            localOnTertiaryContainer = value;
            return true;
        case "_errorContainer":
            localErrorContainer = value;
            return true;
        case "_onErrorContainer":
            localOnErrorContainer = value;
            return true;
        case "_outline":
            localOutline = value;
            return true;
        case "_outlineVariant":
            localOutlineVariant = value;
            return true;
        case "_inverseSurface":
            localInverseSurface = value;
            return true;
        case "_onInverseSurface":
            localOnInverseSurface = value;
            return true;
        case "_inversePrimary":
            localInversePrimary = value;
            return true;
        case "_shadow":
            localShadow = value;
            return true;
        case "_scrim":
            localScrim = value;
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
        color: chatMessage.isUser ? root.theme.colors.primary.alpha(0.16) : root.theme.colors.surfaceContainerHigh.alpha(0.86)
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
                color: root.theme.colors.onSurface
                font.pixelSize: root.typ("small", 12)
            }

            Controls.Label {
                Layout.fillWidth: true
                visible: chatMessage.changesSummary !== ""
                text: chatMessage.changesSummary
                wrapMode: Text.WordWrap
                color: root.theme.colors.onSurfaceVariant
                font.pixelSize: root.typ("small", 12)
            }
        }
    }

    component ColorRow: ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        property string label
        property color value: root.theme.colors.surface
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
                border.color: root.theme.colors.onSurface.alpha(0.4)
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
                        color: root.theme.colors.surfaceContainerHigh.alpha(0.55)
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
                            color: root.assistant.aiError !== "" ? root.theme.colors.error : root.theme.colors.onSurfaceVariant
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
            }
        }

        // --- Surface ---
        SectionCard {
            title: qsTr("Surface")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 15
                rowSpacing: 10

                ColorRow {
                    label: "Surface"
                    value: root.localSurface
                    onUserChanged: v => {
                        root.localSurface = v;
                        root.applySingleProperty("_surface", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "On Surface"
                    value: root.localOnSurface
                    onUserChanged: v => {
                        root.localOnSurface = v;
                        root.applySingleProperty("_onSurface", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Surface Dim"
                    value: root.localSurfaceDim
                    onUserChanged: v => {
                        root.localSurfaceDim = v;
                        root.applySingleProperty("_surfaceDim", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Surface Bright"
                    value: root.localSurfaceBright
                    onUserChanged: v => {
                        root.localSurfaceBright = v;
                        root.applySingleProperty("_surfaceBright", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Surface Variant"
                    value: root.localSurfaceVariant
                    onUserChanged: v => {
                        root.localSurfaceVariant = v;
                        root.applySingleProperty("_surfaceVariant", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "On Surface Variant"
                    value: root.localOnSurfaceVariant
                    onUserChanged: v => {
                        root.localOnSurfaceVariant = v;
                        root.applySingleProperty("_onSurfaceVariant", v);
                        root.recordHistory();
                    }
                }
            }
        }

        // --- Surface Containers ---
        SectionCard {
            title: qsTr("Surface Containers")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 15
                rowSpacing: 10

                ColorRow {
                    label: "Container Lowest"
                    value: root.localSurfaceContainerLowest
                    onUserChanged: v => {
                        root.localSurfaceContainerLowest = v;
                        root.applySingleProperty("_surfaceContainerLowest", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Container Low"
                    value: root.localSurfaceContainerLow
                    onUserChanged: v => {
                        root.localSurfaceContainerLow = v;
                        root.applySingleProperty("_surfaceContainerLow", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Container"
                    value: root.localSurfaceContainer
                    onUserChanged: v => {
                        root.localSurfaceContainer = v;
                        root.applySingleProperty("_surfaceContainer", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Container High"
                    value: root.localSurfaceContainerHigh
                    onUserChanged: v => {
                        root.localSurfaceContainerHigh = v;
                        root.applySingleProperty("_surfaceContainerHigh", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Container Highest"
                    value: root.localSurfaceContainerHighest
                    onUserChanged: v => {
                        root.localSurfaceContainerHighest = v;
                        root.applySingleProperty("_surfaceContainerHighest", v);
                        root.recordHistory();
                    }
                }
            }
        }

        // --- Container Colors ---
        SectionCard {
            title: qsTr("Container Colors")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 15
                rowSpacing: 10

                ColorRow {
                    label: "Primary Container"
                    value: root.localPrimaryContainer
                    onUserChanged: v => {
                        root.localPrimaryContainer = v;
                        root.applySingleProperty("_primaryContainer", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "On Primary Container"
                    value: root.localOnPrimaryContainer
                    onUserChanged: v => {
                        root.localOnPrimaryContainer = v;
                        root.applySingleProperty("_onPrimaryContainer", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Secondary Container"
                    value: root.localSecondaryContainer
                    onUserChanged: v => {
                        root.localSecondaryContainer = v;
                        root.applySingleProperty("_secondaryContainer", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "On Secondary Container"
                    value: root.localOnSecondaryContainer
                    onUserChanged: v => {
                        root.localOnSecondaryContainer = v;
                        root.applySingleProperty("_onSecondaryContainer", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Tertiary Container"
                    value: root.localTertiaryContainer
                    onUserChanged: v => {
                        root.localTertiaryContainer = v;
                        root.applySingleProperty("_tertiaryContainer", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "On Tertiary Container"
                    value: root.localOnTertiaryContainer
                    onUserChanged: v => {
                        root.localOnTertiaryContainer = v;
                        root.applySingleProperty("_onTertiaryContainer", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Error Container"
                    value: root.localErrorContainer
                    onUserChanged: v => {
                        root.localErrorContainer = v;
                        root.applySingleProperty("_errorContainer", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "On Error Container"
                    value: root.localOnErrorContainer
                    onUserChanged: v => {
                        root.localOnErrorContainer = v;
                        root.applySingleProperty("_onErrorContainer", v);
                        root.recordHistory();
                    }
                }
            }
        }

        // --- Outline & Inverse ---
        SectionCard {
            title: qsTr("Outline & Inverse")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 15
                rowSpacing: 10

                ColorRow {
                    label: "Outline"
                    value: root.localOutline
                    onUserChanged: v => {
                        root.localOutline = v;
                        root.applySingleProperty("_outline", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Outline Variant"
                    value: root.localOutlineVariant
                    onUserChanged: v => {
                        root.localOutlineVariant = v;
                        root.applySingleProperty("_outlineVariant", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Inverse Surface"
                    value: root.localInverseSurface
                    onUserChanged: v => {
                        root.localInverseSurface = v;
                        root.applySingleProperty("_inverseSurface", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "On Inverse Surface"
                    value: root.localOnInverseSurface
                    onUserChanged: v => {
                        root.localOnInverseSurface = v;
                        root.applySingleProperty("_onInverseSurface", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Inverse Primary"
                    value: root.localInversePrimary
                    onUserChanged: v => {
                        root.localInversePrimary = v;
                        root.applySingleProperty("_inversePrimary", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Shadow"
                    value: root.localShadow
                    onUserChanged: v => {
                        root.localShadow = v;
                        root.applySingleProperty("_shadow", v);
                        root.recordHistory();
                    }
                }
                ColorRow {
                    label: "Scrim"
                    value: root.localScrim
                    onUserChanged: v => {
                        root.localScrim = v;
                        root.applySingleProperty("_scrim", v);
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
