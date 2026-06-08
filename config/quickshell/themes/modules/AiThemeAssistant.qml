// themes/modules/AiThemeAssistant.qml

import QtQuick
import "root:/config"
import "root:/services"
import "root:/themes"

QtObject {
    id: root

    // =========================================================
    // 1. State Properties
    // =========================================================
    property bool aiBusy: false
    property string aiError: ""
    property var pendingAiChanges: []
    readonly property bool hasPendingAiChanges: pendingAiChanges.length > 0

    // Reference to the Chat UI ListModel (set by the settings page)
    property var chatModel: null

    // =========================================================
    // 2. Metadata
    // =========================================================
    readonly property var editableColorKeys: [
        { "key": "_primary", "label": "Primary", "group": "Core Palette" },
        { "key": "_onPrimary", "label": "On Primary", "group": "Core Palette" },
        { "key": "_secondary", "label": "Secondary", "group": "Core Palette" },
        { "key": "_onSecondary", "label": "On Secondary", "group": "Core Palette" },
        { "key": "_tertiary", "label": "Tertiary", "group": "Core Palette" },
        { "key": "_onTertiary", "label": "On Tertiary", "group": "Core Palette" },
        { "key": "_error", "label": "Error", "group": "Core Palette" },
        { "key": "_onError", "label": "On Error", "group": "Core Palette" },
        { "key": "_success", "label": "Success", "group": "Core Palette" },
        { "key": "_onSuccess", "label": "On Success", "group": "Core Palette" },
        { "key": "_warning", "label": "Warning", "group": "Core Palette" },
        { "key": "_onWarning", "label": "On Warning", "group": "Core Palette" },
        { "key": "_subtleTextColor", "label": "Subtle Text", "group": "Core Palette" },
        { "key": "_topbarColor", "label": "Topbar Background", "group": "Topbar" },
        { "key": "_topbarFgColor", "label": "Topbar Foreground", "group": "Topbar" },
        { "key": "_topbarBgColorV1", "label": "Topbar BG V1", "group": "Topbar" },
        { "key": "_topbarFgColorV1", "label": "Topbar FG V1", "group": "Topbar" },
        { "key": "_topbarBgColorV2", "label": "Topbar BG V2", "group": "Topbar" },
        { "key": "_topbarFgColorV2", "label": "Topbar FG V2", "group": "Topbar" },
        { "key": "_topbarBgColorV3", "label": "Topbar BG V3", "group": "Topbar" },
        { "key": "_topbarFgColorV3", "label": "Topbar FG V3", "group": "Topbar" },
        { "key": "_leftMenuBgColorV1", "label": "Left Menu BG V1", "group": "Left Menu" },
        { "key": "_leftMenuFgColorV1", "label": "Left Menu FG V1", "group": "Left Menu" },
        { "key": "_leftMenuBgColorV2", "label": "Left Menu BG V2", "group": "Left Menu" },
        { "key": "_leftMenuFgColorV2", "label": "Left Menu FG V2", "group": "Left Menu" },
        { "key": "_leftMenuBgColorV3", "label": "Left Menu BG V3", "group": "Left Menu" },
        { "key": "_leftMenuFgColorV3", "label": "Left Menu FG V3", "group": "Left Menu" },
        { "key": "_volOsdBgColor", "label": "Volume OSD BG", "group": "Misc" },
        { "key": "_volOsdFgColor", "label": "Volume OSD FG", "group": "Misc" }
    ]

    function editableColorMetadata() {
        let data = [];
        for (let i = 0; i < editableColorKeys.length; i++) {
            data.push({
                "key": editableColorKeys[i].key,
                "label": editableColorKeys[i].label,
                "group": editableColorKeys[i].group
            });
        }
        return data;
    }

    // =========================================================
    // 3. Private Helper Functions
    // =========================================================
    function colorKeyExists(key) {
        for (let i = 0; i < editableColorKeys.length; i++) {
            if (editableColorKeys[i].key === key)
                return true;
        }
        return false;
    }

    function colorKeyLabel(key) {
        for (let i = 0; i < editableColorKeys.length; i++) {
            if (editableColorKeys[i].key === key)
                return editableColorKeys[i].label;
        }
        return key;
    }

    function normalizeAiColor(value) {
        if (value === undefined || value === null)
            return "";

        const text = value.toString().trim();
        const match = text.match(/^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/);
        return match ? "#" + match[1].toUpperCase() : "";
    }

    function normalizeAiChanges(changes) {
        let normalized = [];

        if (!Array.isArray(changes))
            return normalized;

        for (let i = 0; i < changes.length; i++) {
            const change = changes[i] || {};
            const key = change.key ? change.key.toString() : "";
            const value = normalizeAiColor(change.value);

            if (!colorKeyExists(key) || value === "")
                continue;

            normalized.push({
                "key": key,
                "value": value,
                "reason": change.reason ? change.reason.toString() : ""
            });
        }

        return normalized;
    }

    function summarizeChanges(changes) {
        if (!changes || changes.length === 0)
            return "";

        let parts = [];
        for (let i = 0; i < changes.length; i++) {
            parts.push(colorKeyLabel(changes[i].key) + " -> " + changes[i].value);
        }
        return parts.join(" | ");
    }

    function chatHistoryForAi() {
        if (!chatModel)
            return [];

        let history = [];
        const start = Math.max(0, chatModel.count - 8);
        for (let i = start; i < chatModel.count; i++) {
            const item = chatModel.get(i);
            history.push({
                "role": item.role,
                "content": item.message,
                "changes": item.changesSummary || ""
            });
        }
        return history;
    }

    function addAiMessage(role, message, changesSummary) {
        if (chatModel) {
            chatModel.append({
                "role": role,
                "message": message,
                "changesSummary": changesSummary || ""
            });
        }
    }

    // =========================================================
    // 4. Public API Functions
    // =========================================================

    /**
     * @function sendMessage
     * @description Sends a user message to the AI color palette service and handles the response.
     * @param {string} message - The user's input message.
     * @param {var} currentTheme - The current active theme instance.
     * @param {var} serializedData - The serialized color data from the settings page.
     */
    function sendMessage(message, currentTheme, serializedData) {
        if (!message || message.trim() === "" || aiBusy)
            return;

        aiError = "";
        pendingAiChanges = [];
        addAiMessage("user", message.trim(), "");

        const payload = {
            "user_message": message.trim(),
            "theme_name": currentTheme ? currentTheme.themeName : "",
            "current_palette": serializedData,
            "editable_keys": editableColorMetadata(),
            "conversation": chatHistoryForAi()
        };

        console.info("[AiThemeAssistant] Sending request to AI service...");
        aiBusy = true;

        AiService.sendRequest(App.scripts.python.callColorPaletteAi, ["--message", JSON.stringify(payload)], function (data) {
            aiBusy = false;

            const reply = data && data.reply ? data.reply.toString().trim() : qsTr("No response.");
            const changes = normalizeAiChanges(data ? data.changes : []);
            let summary = summarizeChanges(changes);

            if (data && data.apply === true && changes.length > 0) {
                applyChanges(changes, currentTheme);
                if (summary !== "")
                    summary = qsTr("Applied: ") + summary;
            } else {
                pendingAiChanges = changes;
            }

            addAiMessage("assistant", reply, summary);

            if (data && Array.isArray(data.warnings) && data.warnings.length > 0)
                aiError = data.warnings.join(" ");
        }, function (errorMessage) {
            aiBusy = false;
            aiError = errorMessage;
            addAiMessage("assistant", qsTr("AI request failed."), "");
        }, "color_palette_ai", 2);
    }

    /**
     * @function applyChanges
     * @description Applies AI-proposed color changes to the theme and generates a Plasma color scheme.
     * @param {var} changes - Array of {key, value} color changes.
     * @param {var} currentTheme - The current active theme instance.
     */
    function applyChanges(changes, currentTheme) {
        if (!changes || changes.length === 0 || !currentTheme)
            return;

        let data = {};
        for (let i = 0; i < changes.length; i++) {
            data[changes[i].key] = changes[i].value;
        }

        if (Object.keys(data).length > 0) {
            const date = new Date();
            const pad = num => num.toString().padStart(2, '0');
            const timestamp = `${date.getFullYear()}${pad(date.getMonth() + 1)}${pad(date.getDate())}_${pad(date.getHours())}${pad(date.getMinutes())}${pad(date.getSeconds())}`;
            const plasmaSchemeName = `NibrasShellAiGenerated-${timestamp}`;

            data["_plasmaColorScheme"] = plasmaSchemeName;
            console.info("[AiThemeAssistant] Applying", Object.keys(data).length, "color changes to theme...");
            ThemeManager.updateThemeColorsOnly(data, false);

            console.info("[AiThemeAssistant] Generating Plasma color scheme:", plasmaSchemeName);
            ThemeManager.bridgeSystem.applyCustomColorScheme(ThemeManager.selectedTheme, plasmaSchemeName);
        }

        pendingAiChanges = [];
    }

    /**
     * @function clearChat
     * @description Clears the chat history and resets AI error/pending states.
     */
    function clearChat() {
        if (chatModel)
            chatModel.clear();
        aiError = "";
        pendingAiChanges = [];
    }
}
