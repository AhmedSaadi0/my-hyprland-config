// config/ConfigStore.qml

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "root:/config/ConstValues.js" as C

QtObject {
    id: store

    property string configPath: ""

    signal settingsLoaded

    // --------------------------------------------------------
    property string username: "Username"
    property string subtitle: ""
    property string profilePicture: ""
    property string networkMonitor: "wlp0s20f3"
    property int networkInterval: 400
    property string city: "sanaa"
    property string country: "yemen"
    property string weatherLocation: "sanaa"
    property bool usePrayerTimes: true
    property string aiApiKey: ""
    property string weatherAiApiKey: ""
    property string musicAiApiKey: ""
    property string aiPreferredLanguage: "English"

    property string aiProvider: "gemini" // choices=["local", "gemini", "openai", "deepseek", "openrouter"]
    property string weatherAiModel: "gemini-flash-lite-latest"
    property string musicAiModel: "gemini-flash-lite-latest"

    property string weatherPersona: "**ROLE**: Strategic Weather Advisor & Bio-Meteorologist.\n**MODE**: Predictive Lifestyle Analysis.\n\n**INTELLIGENCE RULES (Apply Strictly)**:\n1.  **Trajectory Analysis (CRITICAL)**: You are receiving full-day data. Do not focus only on \"Now\".\n    -   Compare *Current Temp* vs. *Forecasted Temp* for the next 4-6 hours.\n    -   Identify the *Shift*: Is it cooling down rapidly? Is rain approaching? Is the wind picking up?\n    \n2.  **Sensory Translation**: \n    -   Translate the number (e.g., 17°C) into a human feeling relative to the shift.\n    -   *Example*: \"Currently pleasant (17°C), but dropping fast.\"\n\n3.  **Layering Strategy (Wardrobe)**:\n    -   If the weather changes significantly (e.g., warm day -> cold night), advise on *layers*.\n    -   *Example*: \"Wear a t-shirt now, but absolutely bring a jacket for the evening drop.\"\n\n4.  **JSON Output Logic (`smart_summary`)**:\n    -   Construct the text in this format: [Current Feeling/Action] + [The Pivot/Future Change].\n    -   *Bad*: \"It is 17 degrees. It will be 12 later.\"\n    -   *Good*: \"Feels crisp and fresh right now. However, expect a sharp drop in temperature by sunset—keep a heavy layer nearby.\"\n\n5.  **Tagging Logic**: Use the `tags` array to highlight the *change* (e.g., [\"Cooling Down\", \"Windy Later\", \"Rain Incoming\"])."
    property string musicPersona: "Role: You are \"VibeCheck,\" a chill, witty, and highly knowledgeable Audio-Visual Expert and Music Companion.\n\nExpertise: \n- Deep knowledge of Music Theory, History, and Production (Mixing/Mastering).\n- Expert in Cinematography, Video Editing, Color Grading, and Visual Aesthetics.\n- Up-to-date with Pop Culture, Memes, and Internet Media trends.\n\nPersonality & Tone:\n- Chill & Laid-back: You keep things relaxed. No stiff, robotic language.\n- Witty & Sarcastic: You enjoy clever humor and banter.\n- Brutally Honest (but Friendly): If the user shares a generic pop song or a poorly edited video, tease them about it. Call their taste \"basic\" or \"guilty pleasure\" in a fun way, but then provide genuine, high-level analysis or better recommendations.\n\nAlso make sure you do not just recommand songs, you recommand also actions like drinking coffee, reading a book, walking in calm, taking a shower ... etc, be creative. \nAlso don't ask the user to change the vibe ever, and if there is no recomandation, dont say try this song or anythink like that."

    property bool enableHighCpuAlert: true
    property bool enableHighRamAlert: true
    property bool playCpuAlarmSound: true
    property bool playRamAlarmSound: true

    property int cpuHighLoadThreshold: 85
    property int ramHighLoadThreshold: 85

    property int firstDayOfWeek: 6 // Saturday

    property bool useBottomLauncher: false  // false = side launcher, true = bottom launcher
    property int bottomLauncherWidth: 800

    property string menuStyle: C.DOCKED_FIXED_BAR

    property var _fileView: FileView {
        id: fileWatcher
        path: Qt.resolvedUrl(store.configPath)
        watchChanges: true
        atomicWrites: true

        onLoaded: {
            if (!text() || text().trim() === "")
                return;
            try {
                const data = JSON.parse(text());

                store.updateProperties(data);
            } catch (e) {
                console.error("JSON Parse Error: " + e);
            }
        }

        onSaved: console.info("Settings saved successfully to .nibrasshell.json")
        onSaveFailed: error => console.error("Failed to save settings: " + error)
        onFileChanged: reload()
    }

    function updateProperties(data) {
        if (data.username !== undefined)
            store.username = data.username;
        if (data.subtitle !== undefined)
            store.subtitle = data.subtitle;
        if (data.profilePicture !== undefined)
            store.profilePicture = data.profilePicture;
        if (data.firstDayOfWeek !== undefined)
            store.firstDayOfWeek = data.firstDayOfWeek;

        // -------------------------------------------------------
        // الشبكة
        // -------------------------------------------------------
        if (data.networkMonitor !== undefined)
            store.networkMonitor = data.networkMonitor;
        if (data.networkInterval !== undefined)
            store.networkInterval = data.networkInterval;

        // -------------------------------------------------------
        // التخطيط
        // -------------------------------------------------------
        if (data.menuStyle !== undefined)
            store.menuStyle = data.menuStyle;
        if (data.useBottomLauncher !== undefined)
            store.useBottomLauncher = data.useBottomLauncher;
        if (data.bottomLauncherWidth !== undefined)
            store.bottomLauncherWidth = data.bottomLauncherWidth;

        // -------------------------------------------------------
        // الموقع والطقس
        // -------------------------------------------------------
        if (data.city !== undefined)
            store.city = data.city;
        if (data.country !== undefined)
            store.country = data.country;
        if (data.weatherLocation !== undefined)
            store.weatherLocation = data.weatherLocation;

        // -------------------------------------------------------
        // إعدادات الصلاة (Boolean)
        // مهم جداً التحقق بهذه الطريقة لأن القيمة قد تكون false
        // -------------------------------------------------------
        if (data.usePrayerTimes !== undefined)
            store.usePrayerTimes = data.usePrayerTimes;

        // -------------------------------------------------------
        // مفاتيح الذكاء الاصطناعي واللغة
        // -------------------------------------------------------
        if (data.aiProvider !== undefined)
            store.aiProvider = data.aiProvider;

        if (data.aiApiKey !== undefined)
            store.aiApiKey = data.aiApiKey;

        if (data.weatherAiApiKey !== undefined)
            store.weatherAiApiKey = data.weatherAiApiKey;

        if (data.musicAiApiKey !== undefined)
            store.musicAiApiKey = data.musicAiApiKey;

        if (data.aiPreferredLanguage !== undefined)
            store.aiPreferredLanguage = data.aiPreferredLanguage;

        if (data.weatherPersona !== undefined)
            store.weatherPersona = data.weatherPersona;
        if (data.musicPersona !== undefined)
            store.musicPersona = data.musicPersona;

        if (data.weatherAiModel !== undefined)
            store.weatherAiModel = data.weatherAiModel;

        if (data.musicAiModel !== undefined)
            store.musicAiModel = data.musicAiModel;

        // -------------------------------------------------------
        // انذارات الرام والمعالج
        // -------------------------------------------------------
        if (data.enableHighCpuAlert !== undefined)
            store.enableHighCpuAlert = data.enableHighCpuAlert;
        if (data.enableHighRamAlert !== undefined)
            store.enableHighRamAlert = data.enableHighRamAlert;

        if (data.playCpuAlarmSound !== undefined)
            store.playCpuAlarmSound = data.playCpuAlarmSound;
        if (data.playRamAlarmSound !== undefined)
            store.playRamAlarmSound = data.playRamAlarmSound;

        if (data.cpuHighLoadThreshold !== undefined)
            store.cpuHighLoadThreshold = data.cpuHighLoadThreshold;
        if (data.ramHighLoadThreshold !== undefined)
            store.ramHighLoadThreshold = data.ramHighLoadThreshold;

        store.settingsLoaded();
        console.info("Config reloaded successfully.");
    }

    function setMultiple(propertiesMap) {
        var keys = Object.keys(propertiesMap);
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (store.hasOwnProperty(key)) {
                store[key] = propertiesMap[key];
            }
        }

        var currentData = {};
        try {
            // التصحيح: استخدام fileWatcher والتحقق من النص
            var txt = fileWatcher.text();
            if (txt && txt.trim() !== "") {
                currentData = JSON.parse(txt);
            }
        } catch (e) {
            console.warn("ConfigStore: Creating new config object (Parse error or empty).");
        }

        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            currentData[key] = propertiesMap[key];
        }

        console.info("ConfigStore: Saving multiple settings...");
        saveToFile(currentData);
    }

    function set(key, value) {
        if (store.hasOwnProperty(key)) {
            store[key] = value;
        }

        var currentData = {};
        try {
            var txt = fileWatcher.text();
            if (txt && txt.trim() !== "") {
                currentData = JSON.parse(txt);
            }
        } catch (e) {}

        currentData[key] = value;
        saveToFile(currentData);
    }

    function saveToFile(data) {
        var jsonString = JSON.stringify(data, null, 2);
        fileWatcher.setText(jsonString);
    }
}
