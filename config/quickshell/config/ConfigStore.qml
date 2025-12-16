import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

QtObject {
    id: store

    property string configPath: ""

    // --------------------------------------------------------
    // الخصائص (نقلناها هنا)
    property string username: "Username"
    property string subtitle: ""
    property string profilePicture: ""
    property string networkMonitor: "wlp0s20f3"
    property int networkInterval: 400
    property string darkM3WallpaperPath: ""
    property string lightM3WallpaperPath: ""
    property string city: "sanaa"
    property string country: "yemen"
    property string weatherLocation: "sanaa"
    property bool usePrayerTimes: true
    property string geminiApiKey: ""
    property string weatherAiApiKey: ""
    property string musicAiApiKey: ""
    property string aiPreferredLanguage: "English"

    property string weatherPersona: "You are a professional Senior Meteorologist. You provide precise, actionable advice based on data. You care about the user's safety and comfort."
    property string musicPersona: "You are a chill, witty Music Companion. You enjoy good vibes and occasionally tease the user about their taste in a friendly way."

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

        // -------------------------------------------------------
        // الشبكة
        // -------------------------------------------------------
        if (data.networkMonitor !== undefined)
            store.networkMonitor = data.networkMonitor;
        if (data.networkInterval !== undefined)
            store.networkInterval = data.networkInterval;

        // -------------------------------------------------------
        // المسارات (الخلفيات)
        // -------------------------------------------------------
        if (data.darkM3WallpaperPath !== undefined)
            store.darkM3WallpaperPath = data.darkM3WallpaperPath;
        if (data.lightM3WallpaperPath !== undefined)
            store.lightM3WallpaperPath = data.lightM3WallpaperPath;

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
        if (data.geminiApiKey !== undefined)
            store.geminiApiKey = data.geminiApiKey;
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
            currentData = JSON.parse(configFile.text());
        } catch (e) {
            console.warn("ConfigStore: Creating new config object.");
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
            currentData = JSON.parse(_fileView.text());
        } catch (e) {}

        currentData[key] = value;
        saveToFile(currentData);
    }

    function saveToFile(data) {
        var jsonString = JSON.stringify(data, null, 2).replace(/'/g, "'\\''");
        fileWatcher.setText(jsonString);
    }
}
