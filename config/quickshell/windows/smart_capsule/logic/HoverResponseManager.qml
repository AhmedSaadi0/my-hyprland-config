// windows/smart_capsule/logic/HoverResponseManager.qml
pragma Singleton

import Quickshell
import QtQuick
import "root:/services"
import "root:/config"
import "root:/config/ConstValues.js" as C
import "root:/windows/smart_capsule/logic"

Singleton {
    id: root

    property var hoverResponses: []
    property bool isPrefetching: false
    property int lastHoverIndex: -1
    property double lastFreshRequestAt: 0
    property int freshCooldownMs: 60000
    property int hoverCounter: 0

    signal freshResponseReady(var item)

    readonly property var fallbackResponses: [
        {
            "text": "Hey there",
            "emotion": "happy"
        },
        {
            "text": "Yes, I am here",
            "emotion": "listening"
        },
        {
            "text": "Need something quick",
            "emotion": "focused"
        },
        {
            "text": "Thinking quietly",
            "emotion": "thinking"
        },
        {
            "text": "Watching you",
            "emotion": "suspicious"
        },
        {
            "text": "Almost awake",
            "emotion": "sleeping"
        },
        {
            "text": "Listening",
            "emotion": "listening"
        },
        {
            "text": "I am smart",
            "emotion": "wink"
        },
        {
            "text": "Tiny joke",
            "emotion": "happy"
        },
        {
            "text": "Ready now",
            "emotion": "shocked"
        }
    ]

    function _trimToEightWords(text) {
        let words = text.trim().split(/\s+/);
        if (words.length <= 8)
            return text.trim();
        return words.slice(0, 8).join(" ");
    }

    function _isValidExtra(text) {
        if (!text)
            return false;
        let trimmed = _trimToEightWords(text);
        return trimmed.trim().length >= 20;
    }

    function ensureHoverResponses() {
        if (hoverResponses.length > 0 || isPrefetching)
            return;

        if (!App.aiApiKey || App.aiApiKey === "") {
            hoverResponses = fallbackResponses.slice(0);
            console.info("[HoverResponseManager] AI key missing -> using fallback responses:", hoverResponses.length);
            return;
        }

        requestIdleResponses(24, false);
    }

    function requestIdleResponses(count, allowReplace) {
        if (isPrefetching)
            return;

        isPrefetching = true;

        let message = `Generate ${count} short hover replies for an idle UI widget. Use variety and keep them under 8 words. Some responses should include extra_text (a follow-up line, at least 20 characters) and extra_delay_ms (1200-2500).`;
        const command = App.scripts.python.callIdleCapsuleAi;
        const args = ["--message", message];

        AiService.sendRequest(command, args, function (data) {
            isPrefetching = false;
            let list = (data && data.responses && Array.isArray(data.responses)) ? data.responses : [];
            let cleaned = [];
            for (let i = 0; i < list.length; i++) {
                let item = list[i];
                if (!item || !item.text)
                    continue;
                let text = String(item.text).trim();
                text = _trimToEightWords(text);
                if (text === "")
                    continue;
                let emotion = item.emotion ? String(item.emotion).trim() : "happy";
                let extraText = item.extra_text ? String(item.extra_text).trim() : "";
                extraText = _trimToEightWords(extraText);
                extraText = _isValidExtra(extraText) ? extraText : "";
                let extraDelay = (item.extra_delay_ms !== undefined) ? Number(item.extra_delay_ms) : 0;
                if (!Number.isFinite(extraDelay) || extraDelay <= 0)
                    extraDelay = 1400;
                cleaned.push({
                    "text": text,
                    "emotion": emotion,
                    "extra_text": extraText,
                    "extra_delay_ms": extraDelay
                });
            }
            if (cleaned.length === 0) {
                console.info("[HoverResponseManager] AI responses empty -> fallback");
                if (hoverResponses.length === 0)
                    hoverResponses = fallbackResponses.slice(0);
                return;
            }

            if (allowReplace) {
                hoverResponses = cleaned;
            } else {
                hoverResponses = hoverResponses.concat(cleaned);
            }
            console.info("[HoverResponseManager] AI responses loaded:", cleaned.length, "total:", hoverResponses.length);
        }, function (errorMessage) {
            isPrefetching = false;
            console.error("[HoverResponseManager] AI request failed:", errorMessage);
            if (hoverResponses.length === 0)
                hoverResponses = fallbackResponses.slice(0);
        });
    }

    function pickHoverResponse() {
        if (hoverResponses.length === 0)
            hoverResponses = fallbackResponses.slice(0);

        hoverCounter += 1;

        let pool = hoverResponses;
        if (hoverCounter % 3 === 0) {
            let withExtra = [];
            for (let i = 0; i < hoverResponses.length; i++) {
                if (_isValidExtra(hoverResponses[i].extra_text))
                    withExtra.push(hoverResponses[i]);
            }
            if (withExtra.length > 0)
                pool = withExtra;
        }

        if (pool.length === 1)
            return pool[0];
        let idx = Math.floor(Math.random() * pool.length);
        if (idx === lastHoverIndex)
            idx = (idx + 1) % pool.length;
        lastHoverIndex = idx;
        return pool[idx];
    }

    function scheduleExtraIfAny(response) {
        if (!response || !_isValidExtra(response.extra_text))
            return;
        extraTextTimer.stop();
        extraTextTimer.interval = response.extra_delay_ms ? response.extra_delay_ms : 1400;
        extraTextTimer.pendingText = response.extra_text;
        extraTextTimer.pendingEmotion = response.emotion || "";
        extraTextTimer.start();
    }

    function requestFreshResponseIfAllowed() {
        let now = Date.now();
        if (now - lastFreshRequestAt < freshCooldownMs)
            return;
        lastFreshRequestAt = now;

        let message = "Generate 1 short hover reply for right now. Keep it playful and under 8 words. You may include extra_text (at least 20 characters).";
        const command = App.scripts.python.callIdleCapsuleAi;
        const args = ["--message", message];

        AiService.sendRequest(command, args, function (data) {
            let list = (data && data.responses && Array.isArray(data.responses)) ? data.responses : [];
            if (list.length === 0 || !list[0].text)
                return;
            let text = String(list[0].text).trim();
            text = _trimToEightWords(text);
            if (text === "")
                return;
            let emotion = list[0].emotion ? String(list[0].emotion).trim() : "happy";
            let extraText = list[0].extra_text ? String(list[0].extra_text).trim() : "";
            extraText = _trimToEightWords(extraText);
            extraText = _isValidExtra(extraText) ? extraText : "";
            let extraDelay = (list[0].extra_delay_ms !== undefined) ? Number(list[0].extra_delay_ms) : 0;
            if (!Number.isFinite(extraDelay) || extraDelay <= 0)
                extraDelay = 1400;
            let item = {
                "text": text,
                "emotion": emotion,
                "extra_text": extraText,
                "extra_delay_ms": extraDelay
            };
            hoverResponses.push(item);
            freshResponseReady(item);
        }, function () {});
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            ensureHoverResponses();
        });
    }

    Timer {
        id: extraTextTimer
        property string pendingText: ""
        property string pendingEmotion: ""
        repeat: false
        onTriggered: {
            if (!pendingText || pendingText === "")
                return;
            CapsuleCoordinator.notifyHoverExtra(pendingText, pendingEmotion);
            pendingText = "";
            pendingEmotion = "";
        }
    }
}
