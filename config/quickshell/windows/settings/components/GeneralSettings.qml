// windows/settings/components/GeneralSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import Qt.labs.platform
import Quickshell.Io

import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/config/ConstValues.js" as C

M3GroupBox {
    id: root
    title: qsTr("General Configuration")
    titleTopMargin: 10

    property var selectedTheme: ThemeManager.selectedTheme

    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    // --- Default Personas ---
    readonly property string defaultWeatherPersona: "**ROLE**: Strategic Weather Advisor & Bio-Meteorologist.\n**MODE**: Predictive Lifestyle Analysis.\n\n**INTELLIGENCE RULES (Apply Strictly)**:\n1.  **Trajectory Analysis (CRITICAL)**: You are receiving full-day data. Do not focus only on \"Now\".\n    -   Compare *Current Temp* vs. *Forecasted Temp* for the next 4-6 hours.\n    -   Identify the *Shift*: Is it cooling down rapidly? Is rain approaching? Is the wind picking up?\n    \n2.  **Sensory Translation**: \n    -   Translate the number (e.g., 17°C) into a human feeling relative to the shift.\n    -   *Example*: \"Currently pleasant (17°C), but dropping fast.\"\n\n3.  **Layering Strategy (Wardrobe)**:\n    -   If the weather changes significantly (e.g., warm day -> cold night), advise on *layers*.\n    -   *Example*: \"Wear a t-shirt now, but absolutely bring a jacket for the evening drop.\"\n\n4.  **JSON Output Logic (`smart_summary`)**:\n    -   Construct the text in this format: [Current Feeling/Action] + [The Pivot/Future Change].\n    -   *Bad*: \"It is 17 degrees. It will be 12 later.\"\n    -   *Good*: \"Feels crisp and fresh right now. However, expect a sharp drop in temperature by sunset—keep a heavy layer nearby.\"\n\n5.  **Tagging Logic**: Use the `tags` array to highlight the *change* (e.g., [\"Cooling Down\", \"Windy Later\", \"Rain Incoming\"])."
    readonly property string defaultMusicPersona: "Role: You are \"VibeCheck,\" a chill, witty, and highly knowledgeable Audio-Visual Expert and Music Companion.\n\nExpertise: \n- Deep knowledge of Music Theory, History, and Production (Mixing/Mastering).\n- Expert in Cinematography, Video Editing, Color Grading, and Visual Aesthetics.\n- Up-to-date with Pop Culture, Memes, and Internet Media trends.\n\nPersonality & Tone:\n- Chill & Laid-back: You keep things relaxed. No stiff, robotic language.\n- Witty & Sarcastic: You enjoy clever humor and banter.\n- Brutally Honest (but Friendly): If the user shares a generic pop song or a poorly edited video, tease them about it. Call their taste \"basic\" or \"guilty pleasure\" in a fun way, but then provide genuine, high-level analysis or better recommendations.\n\nAlso make sure you do not just recommand songs, you recommand also actions like drinking coffee, reading a book, walking in calm, taking a shower ... etc, be creative. \nAlso don't ask the user to change the vibe ever, and if there is no recomandation, dont say try this song or anythink like that."

    readonly property string modeFloating: C.FLOATING
    readonly property string modeDockedFixed: C.DOCKED_FIXED_BAR
    readonly property string modeDockedMoving: C.DOCKED_MOVING_BAR

    // --- Config Object ---
    QtObject {
        id: tempConfig
        property string username: ""
        property string subtitle: ""
        property string profilePicture: ""
        property string city: ""
        property string country: ""

        // 0=Sun, 1=Mon, ..., 6=Sat
        property int firstDayOfWeek: 6

        property string weatherLocation: ""
        property bool usePrayerTimes: true
        property string networkMonitor: ""
        property int networkInterval: 1000
        property string aiPreferredLanguage: "English"
        property string aiProvider: "gemini" //choices=["local", "gemini", "openai", "deepseek", "openrouter"]
        property string geminiApiKey: ""
        property string openrouterApiKey: ""
        property string weatherAiApiKey: ""
        property string musicAiApiKey: ""
        property string weatherPersona: ""
        property string musicPersona: ""
        property string weatherAiModel: ""
        property string musicAiModel: ""

        // Monitoring
        property bool enableHighCpuAlert: false
        property bool playCpuAlarmSound: false
        property int cpuHighLoadThreshold: 90
        property bool enableHighRamAlert: false
        property bool playRamAlarmSound: false
        property int ramHighLoadThreshold: 90

        // Launcher Layout
        property bool useBottomLauncher: false
        property int bottomLauncherWidth: 800
        property string menuStyle: "floating"
    }

    // ====================================================================
    // 2. أدوات مساعدة (Helpers)
    // ====================================================================

    FileDialog {
        id: profilePicDialog
        title: "Select Profile Picture"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.webp *.bmp)", "All files (*.*)"]
        onAccepted: {
            const path = file.toString().replace("file://", "");
            tempConfig.profilePicture = path;
        }
    }

    Process {
        id: networkInterfacesProcess
        command: ["ls", "/sys/class/net"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const interfaceName = data.trim();
                if (interfaceName !== "") {
                    networkModel.append({
                        text: interfaceName
                    });
                    if (interfaceName === tempConfig.networkMonitor) {
                        networkCombo.currentIndex = networkModel.count - 1;
                    }
                }
            }
        }
    }

    function refreshNetworkList() {
        networkModel.clear();
        networkInterfacesProcess.running = true;
    }

    ListModel {
        id: networkModel
    }

    // ====================================================================
    // 3. التحميل والحفظ (Logic)
    // ====================================================================

    function loadCurrentSettings() {
        tempConfig.username = App.username;
        tempConfig.subtitle = App.subtitle;
        tempConfig.profilePicture = App.profilePicture;
        tempConfig.city = App.city;
        tempConfig.country = App.country;

        // تحميل بداية الأسبوع
        tempConfig.firstDayOfWeek = App.firstDayOfWeek !== undefined ? App.firstDayOfWeek : 6;

        tempConfig.weatherLocation = App.weatherLocation;
        tempConfig.usePrayerTimes = App.usePrayerTimes;
        tempConfig.networkMonitor = App.networkMonitor;
        tempConfig.networkInterval = App.networkInterval;
        tempConfig.aiPreferredLanguage = App.aiPreferredLanguage;
        tempConfig.aiProvider = App.aiProvider;
        tempConfig.geminiApiKey = App.geminiApiKey;
        tempConfig.weatherAiApiKey = App.weatherAiApiKey;
        tempConfig.musicAiApiKey = App.musicAiApiKey;

        tempConfig.weatherPersona = App.weatherPersona || defaultWeatherPersona;
        tempConfig.musicPersona = App.musicPersona || defaultMusicPersona;

        tempConfig.weatherAiModel = App.weatherAiModel;
        tempConfig.musicAiModel = App.musicAiModel;
        tempConfig.openrouterApiKey = App.openrouterApiKey || "";

        tempConfig.enableHighCpuAlert = App.enableHighCpuAlert;
        tempConfig.playCpuAlarmSound = App.playCpuAlarmSound;
        tempConfig.cpuHighLoadThreshold = App.cpuHighLoadThreshold;

        tempConfig.enableHighRamAlert = App.enableHighRamAlert;
        tempConfig.playRamAlarmSound = App.playRamAlarmSound;
        tempConfig.ramHighLoadThreshold = App.ramHighLoadThreshold;

        tempConfig.useBottomLauncher = App.useBottomLauncher;
        tempConfig.bottomLauncherWidth = App.bottomLauncherWidth;
        tempConfig.menuStyle = App.menuStyle || modeFloating;

        if (App.availableGeminiWeatherModels.length === 0)
            App.modelsManager.refreshAll();

        refreshNetworkList();
    }

    function saveSettings() {
        var dataToSave = {
            "username": tempConfig.username,
            "subtitle": tempConfig.subtitle,
            "profilePicture": tempConfig.profilePicture,
            "city": tempConfig.city,
            "country": tempConfig.country,

            // حفظ بداية الأسبوع
            "firstDayOfWeek": tempConfig.firstDayOfWeek,
            "weatherLocation": tempConfig.weatherLocation,
            "usePrayerTimes": tempConfig.usePrayerTimes,
            "networkMonitor": tempConfig.networkMonitor,
            "networkInterval": tempConfig.networkInterval,
            "aiPreferredLanguage": tempConfig.aiPreferredLanguage,
            "aiProvider": tempConfig.aiProvider,
            "geminiApiKey": tempConfig.geminiApiKey,
            "openrouterApiKey": tempConfig.openrouterApiKey,
            "weatherAiApiKey": tempConfig.weatherAiApiKey,
            "musicAiApiKey": tempConfig.musicAiApiKey,
            "weatherPersona": tempConfig.weatherPersona,
            "musicPersona": tempConfig.musicPersona,
            "weatherAiModel": tempConfig.weatherAiModel,
            "musicAiModel": tempConfig.musicAiModel,
            "enableHighCpuAlert": tempConfig.enableHighCpuAlert,
            "playCpuAlarmSound": tempConfig.playCpuAlarmSound,
            "cpuHighLoadThreshold": tempConfig.cpuHighLoadThreshold,
            "enableHighRamAlert": tempConfig.enableHighRamAlert,
            "playRamAlarmSound": tempConfig.playRamAlarmSound,
            "ramHighLoadThreshold": tempConfig.ramHighLoadThreshold,
            "useBottomLauncher": tempConfig.useBottomLauncher,
            "bottomLauncherWidth": tempConfig.bottomLauncherWidth,
            "menuStyle": tempConfig.menuStyle
        };

        App.updateConfigMultiple(dataToSave);
        console.info("General settings saved successfully.");
        root.saveChanges();
    }

    signal saveChanges
    signal cancelChanges

    Component.onCompleted: loadCurrentSettings()

    // ====================================================================
    // 4. الواجهة الرسومية (Main UI)
    // ====================================================================
    ColumnLayout {
        id: mainLayout
        spacing: 0 // Spacing handled by sections

        // =================================================================
        // SECTION 1: USER PROFILE
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium
            Layout.bottomMargin: selectedTheme.dimensions.spacingLarge

            Controls.Label {
                text: qsTr("User Profile")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                color: selectedTheme.colors.primary
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                // Username
                ColumnLayout {
                    Layout.preferredWidth: 100
                    Controls.Label {
                        text: qsTr("Username")
                        font.bold: true
                    }
                    EditableField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: tempConfig.username
                        selectedTheme: root.selectedTheme
                        onEditingFinished: tempConfig.username = text
                    }
                }

                // Subtitle
                ColumnLayout {
                    Layout.preferredWidth: 250
                    Controls.Label {
                        text: qsTr("Subtitle / Quote")
                        font.bold: true
                    }
                    EditableField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: tempConfig.subtitle
                        selectedTheme: root.selectedTheme
                        onEditingFinished: tempConfig.subtitle = text
                    }
                }
            }

            Controls.Label {
                text: qsTr("Profile Picture")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                EditableField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    text: tempConfig.profilePicture
                    selectedTheme: root.selectedTheme
                    onEditingFinished: tempConfig.profilePicture = text
                }
                MButton {
                    text: "Browse"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 30
                    onClicked: profilePicDialog.open()
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: selectedTheme.dimensions.spacingMedium
        }

        // =================================================================
        // SECTION: LAUNCHER & SIDEBAR LAYOUT
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium
            Layout.bottomMargin: selectedTheme.dimensions.spacingLarge

            Controls.Label {
                text: qsTr("Layout Configuration")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                color: selectedTheme.colors.primary
            }

            // --- جزء القائمة الجانبية (الجديد) ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Controls.Label {
                    text: qsTr("Sidebar Menu Style")
                    font.bold: true
                }

                SettingsComboBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    // النصوص التي تظهر للمستخدم
                    model: [qsTr("Floating (Overlay)")             // Index 0
                        , qsTr("Docked - Icons Fixed Left")      // Index 1
                        , qsTr("Docked - Icons Push Right")       // Index 2
                    ]

                    // تحديد العنصر المختار بناءً على قيمة المتغير
                    currentIndex: {
                        if (tempConfig.menuStyle === modeDockedFixed)
                            return 1;
                        if (tempConfig.menuStyle === modeDockedMoving)
                            return 2;
                        return 0; // Default: Floating
                    }

                    // عند الاختيار، نحدث قيمة tempConfig بالثوابت المطلوبة
                    onActivated: index => {
                        if (index === 0)
                            tempConfig.menuStyle = modeFloating;
                        else if (index === 1)
                            tempConfig.menuStyle = modeDockedFixed;
                        else if (index === 2)
                            tempConfig.menuStyle = modeDockedMoving;
                    }
                }

                // نص توضيحي بسيط يظهر أسفل القائمة
                Controls.Label {
                    text: {
                        if (tempConfig.menuStyle === modeDockedFixed)
                            return qsTr("Menu reserves space. Icons stay fixed on the left.");
                        if (tempConfig.menuStyle === modeDockedMoving)
                            return qsTr("Menu reserves space. Icons move to the right of the menu.");
                        return qsTr("Menu floats above windows without resizing workspace.");
                    }
                    font.pixelSize: selectedTheme.typography.small
                    color: selectedTheme.colors.primary
                    opacity: 0.7
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.margins: 5
            }

            // --- جزء اللانشر السفلي (الموجود سابقاً) ---
            SettingSwitch {
                label: qsTr("Use Bottom Launcher")
                tooltip: qsTr("Toggle between side launcher (left panel) and bottom launcher.")
                isChecked: tempConfig.useBottomLauncher
                onIsCheckedChanged: tempConfig.useBottomLauncher = isChecked
            }

            // ... بقية كود اللانشر السفلي (Slider وتفاصيله) ...
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                visible: tempConfig.useBottomLauncher

                Controls.Label {
                    text: qsTr("Launcher Width: %1px").arg(tempConfig.bottomLauncherWidth)
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Controls.Slider {
                        id: launcherWidthSlider
                        Layout.fillWidth: true
                        from: 550
                        to: 1200
                        stepSize: 50
                        value: tempConfig.bottomLauncherWidth
                        onMoved: tempConfig.bottomLauncherWidth = value
                    }
                    Controls.Label {
                        text: "550"
                        font.pixelSize: selectedTheme.typography.small
                        opacity: 0.6
                    }
                    Controls.Label {
                        text: "1200"
                        font.pixelSize: selectedTheme.typography.small
                        opacity: 0.6
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: selectedTheme.dimensions.spacingMedium
        }

        // =================================================================
        // SECTION 2: LOCATION & WEATHER
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 590
            spacing: selectedTheme.dimensions.spacingMedium
            Layout.bottomMargin: selectedTheme.dimensions.spacingLarge

            Controls.Label {
                text: qsTr("Location & Region")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                color: selectedTheme.colors.primary
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                // Country
                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Country")
                        font.bold: true
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: tempConfig.country
                        selectedTheme: root.selectedTheme
                        onEditingFinished: tempConfig.country = text
                    }
                }

                // City
                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("City")
                        font.bold: true
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: tempConfig.city
                        selectedTheme: root.selectedTheme
                        onEditingFinished: tempConfig.city = text
                    }
                }

                // Weather Location
                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Weather API Location")
                        font.bold: true
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: tempConfig.weatherLocation
                        selectedTheme: root.selectedTheme
                        onEditingFinished: tempConfig.weatherLocation = text
                    }
                }
            }

            // --- First Day of Week Selection ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Controls.Label {
                        text: qsTr("First Day of Week")
                        font.bold: true
                    }

                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        // الموديل يعكس الترتيب القياسي (0=الأحد)
                        model: [qsTr("Sunday")    // Index 0
                            , qsTr("Monday")    // Index 1
                            , qsTr("Tuesday")   // Index 2
                            , qsTr("Wednesday") // Index 3
                            , qsTr("Thursday")  // Index 4
                            , qsTr("Friday")    // Index 5
                            , qsTr("Saturday")   // Index 6
                        ]

                        // نحدد العنصر المختار بناءً على القيمة المحفوظة
                        currentIndex: tempConfig.firstDayOfWeek

                        // عند الاختيار، نحدث قيمة tempConfig
                        onActivated: index => tempConfig.firstDayOfWeek = index
                    }
                }

                // Placeholder to balance layout if needed or add more regional settings here
                Item {
                    Layout.fillWidth: true
                }
            }

            SettingSwitch {
                label: qsTr("Enable Prayer Times")
                isChecked: tempConfig.usePrayerTimes
                onIsCheckedChanged: tempConfig.usePrayerTimes = isChecked
                visible: false
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: selectedTheme.dimensions.spacingMedium
        }

        // =================================================================
        // SECTION 3: AI PERSONAS
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium
            Layout.bottomMargin: selectedTheme.dimensions.spacingLarge

            Controls.Label {
                text: qsTr("AI Personalities")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                color: selectedTheme.colors.primary
            }

            // Language
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                // 1. Preferred Language
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Controls.Label {
                        text: qsTr("Preferred Language")
                        font.bold: true
                    }
                    EditableField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: tempConfig.aiPreferredLanguage
                        selectedTheme: root.selectedTheme
                        placeholderText: "e.g. English, Arabic..."
                        onEditingFinished: tempConfig.aiPreferredLanguage = text
                    }
                }

                // 2. AI Provider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Controls.Label {
                        text: qsTr("AI Provider")
                        font.bold: true
                    }
                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ["local", "gemini", "openai", "deepseek", "openrouter"]
                        currentIndex: model.indexOf(tempConfig.aiProvider)
                        displayText: currentIndex === -1 ? tempConfig.aiProvider : currentText
                        onActivated: index => tempConfig.aiProvider = textAt(index)
                    }
                }
            }

            // Weather Persona
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                RowLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Weather AI Persona")
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    MButton {
                        text: "Reset Default"
                        iconText: "󰑏"
                        iconPreferredWidth: 1
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 25
                        flat: true
                        onClicked: tempConfig.weatherPersona = defaultWeatherPersona
                    }
                }
                Controls.ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    clip: true
                    Controls.TextArea {
                        wrapMode: TextEdit.Wrap
                        text: tempConfig.weatherPersona
                        onEditingFinished: tempConfig.weatherPersona = text
                        color: selectedTheme.colors.leftMenuFgColorV1
                        selectedTextColor: selectedTheme.colors.onPrimary
                        selectionColor: selectedTheme.colors.primary
                        font.pixelSize: selectedTheme.typography.small
                        background: Rectangle {
                            color: selectedTheme.colors.leftMenuBgColorV1
                            radius: selectedTheme.dimensions.baseRadius / 2
                            border.width: parent.activeFocus ? 1 : 0
                            border.color: selectedTheme.colors.primary
                        }
                    }
                }
            }

            // Music Persona
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                RowLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Music AI Persona")
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    MButton {
                        text: "Reset Default"
                        iconText: "󰑏"
                        iconPreferredWidth: 1
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 25
                        flat: true
                        onClicked: tempConfig.musicPersona = defaultMusicPersona
                    }
                }
                Controls.ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    clip: true
                    Controls.TextArea {
                        wrapMode: TextEdit.Wrap
                        text: tempConfig.musicPersona
                        onEditingFinished: tempConfig.musicPersona = text
                        color: selectedTheme.colors.leftMenuFgColorV1
                        selectedTextColor: selectedTheme.colors.onPrimary
                        selectionColor: selectedTheme.colors.primary
                        font.pixelSize: selectedTheme.typography.small
                        background: Rectangle {
                            color: selectedTheme.colors.leftMenuBgColorV1
                            radius: selectedTheme.dimensions.baseRadius / 2
                            border.width: parent.activeFocus ? 1 : 0
                            border.color: selectedTheme.colors.primary
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: selectedTheme.dimensions.spacingMedium
        }

        // =================================================================
        // SECTION 4: API KEYS & MODELS
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            visible: tempConfig.aiProvider === "openrouter"
            spacing: 5

            Controls.Label {
                text: qsTr("OpenRouter Master API Key")
                font.bold: true
                color: selectedTheme.colors.primary
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                EditableField {
                    Layout.fillWidth: true
                    placeholderText: "sk-or-v1-..."
                    text: tempConfig.openrouterApiKey
                    selectedTheme: root.selectedTheme
                    echoMode: orShowBtn.checked ? TextInput.Normal : TextInput.Password
                    onEditingFinished: tempConfig.openrouterApiKey = text
                }
                MButton {
                    id: orShowBtn
                    checkable: true
                    text: checked ? "" : ""
                    font.family: selectedTheme.typography.iconFont
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                }
            }
            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.topMargin: 5
                Layout.bottomMargin: 5
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium
            Layout.bottomMargin: selectedTheme.dimensions.spacingLarge

            RowLayout {
                Layout.fillWidth: true
                Controls.Label {
                    text: qsTr("API Connections")
                    font.bold: true
                    font.pixelSize: selectedTheme.typography.heading2Size
                    color: selectedTheme.colors.primary
                }
                Item {
                    Layout.fillWidth: true
                }
                MButton {
                    text: App.modelsManager.isLoading ? "Loading..." : "Refresh Models"
                    iconText: "󰑐"
                    enabled: !App.modelsManager.isLoading
                    onClicked: App.modelsManager.refreshAll()
                    Layout.preferredHeight: 30
                    iconPreferredWidth: 1
                    Layout.preferredWidth: 150
                }
            }

            // Error Message
            Controls.Label {
                visible: App.modelsManager.lastError !== ""
                text: "Error: " + App.modelsManager.lastError
                color: selectedTheme.colors.secondary
                font.pixelSize: selectedTheme.typography.small
            }

            // Weather Configuration
            Controls.Label {
                text: qsTr("Weather Service")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 3
                    spacing: 5
                    EditableField {
                        Layout.fillWidth: true
                        placeholderText: "Specific Weather API Key"
                        text: tempConfig.weatherAiApiKey
                        selectedTheme: root.selectedTheme
                        echoMode: weatherShowBtn.checked ? TextInput.Normal : TextInput.Password
                        onEditingFinished: tempConfig.weatherAiApiKey = text
                    }
                    MButton {
                        id: weatherShowBtn
                        checkable: true
                        text: checked ? "" : ""
                        font.family: selectedTheme.typography.iconFont
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                    }
                }
                SettingsComboBox {
                    visible: tempConfig.aiProvider !== "openrouter"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 30
                    model: App.availableGeminiWeatherModels
                    currentIndex: model.indexOf(tempConfig.weatherAiModel)
                    displayText: currentIndex === -1 ? (tempConfig.weatherAiModel || "Select Model") : currentText
                    onActivated: index => tempConfig.weatherAiModel = textAt(index)
                    enabled: !App.modelsManager.isLoading
                }
                EditableField {
                    visible: tempConfig.aiProvider === "openrouter"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 30
                    placeholderText: "e.g. qwen/qwen-2-7b:free"
                    text: tempConfig.weatherAiModel
                    selectedTheme: root.selectedTheme
                    onEditingFinished: tempConfig.weatherAiModel = text
                }
            }

            // Music Configuration
            Controls.Label {
                text: qsTr("Music Service")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 3
                    spacing: 5
                    EditableField {
                        Layout.fillWidth: true
                        placeholderText: "Specific Music API Key"
                        text: tempConfig.musicAiApiKey
                        selectedTheme: root.selectedTheme
                        echoMode: musicShowBtn.checked ? TextInput.Normal : TextInput.Password
                        onEditingFinished: tempConfig.musicAiApiKey = text
                    }
                    MButton {
                        id: musicShowBtn
                        checkable: true
                        text: checked ? "" : ""
                        font.family: selectedTheme.typography.iconFont
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                    }
                }
                SettingsComboBox {
                    visible: tempConfig.aiProvider !== "openrouter"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 30
                    model: App.availableGeminiMusicModels
                    currentIndex: model.indexOf(tempConfig.musicAiModel)
                    displayText: currentIndex === -1 ? (tempConfig.musicAiModel || "Select Model") : currentText
                    onActivated: index => tempConfig.musicAiModel = textAt(index)
                    enabled: !App.modelsManager.isLoading
                }
                EditableField {
                    visible: tempConfig.aiProvider === "openrouter"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 30
                    placeholderText: "e.g. anthropic/claude-3-haiku"
                    text: tempConfig.musicAiModel
                    selectedTheme: root.selectedTheme
                    onEditingFinished: tempConfig.musicAiModel = text
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: selectedTheme.dimensions.spacingMedium
        }

        // =================================================================
        // SECTION 5: MONITORING & NETWORK
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium

            // --- A. Resource Monitoring ---
            Controls.Label {
                text: qsTr("Resource Alerts (CPU/RAM)")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                color: selectedTheme.colors.primary
            }

            // CPU
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                SettingSwitch {
                    label: qsTr("Enable CPU High Load Alert")
                    isChecked: tempConfig.enableHighCpuAlert
                    onIsCheckedChanged: tempConfig.enableHighCpuAlert = isChecked
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: tempConfig.enableHighCpuAlert
                    Layout.leftMargin: 20
                    SettingSwitch {
                        label: qsTr("Play Sound")
                        isChecked: tempConfig.playCpuAlarmSound
                        onIsCheckedChanged: tempConfig.playCpuAlarmSound = isChecked
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    SliderWithLabel {
                        Layout.preferredWidth: 300
                        label: qsTr("Threshold (%)")
                        from: 0
                        to: 100
                        stepSize: 1
                        value: tempConfig.cpuHighLoadThreshold
                        onEditingFinished: finalValue => tempConfig.cpuHighLoadThreshold = finalValue
                    }
                }
            }

            // RAM
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                SettingSwitch {
                    label: qsTr("Enable RAM High Load Alert")
                    isChecked: tempConfig.enableHighRamAlert
                    onIsCheckedChanged: tempConfig.enableHighRamAlert = isChecked
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: tempConfig.enableHighRamAlert
                    Layout.leftMargin: 20
                    SettingSwitch {
                        label: qsTr("Play Sound")
                        isChecked: tempConfig.playRamAlarmSound
                        onIsCheckedChanged: tempConfig.playRamAlarmSound = isChecked
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    SliderWithLabel {
                        Layout.preferredWidth: 300
                        label: qsTr("Threshold (%)")
                        from: 0
                        to: 100
                        stepSize: 1
                        value: tempConfig.ramHighLoadThreshold
                        onEditingFinished: finalValue => tempConfig.ramHighLoadThreshold = finalValue
                    }
                }
            }

            // Separator within the section
            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.bottomMargin: 10
            }

            // --- B. Network ---
            Controls.Label {
                text: qsTr("Network Configuration")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                color: selectedTheme.colors.primary
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                Controls.Label {
                    text: qsTr("Interface:")
                    font.bold: true
                }
                SettingsComboBox {
                    id: networkCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    model: networkModel
                    editable: false
                    displayText: currentIndex === -1 ? tempConfig.networkMonitor : currentText
                    onActivated: index => tempConfig.networkMonitor = textAt(index)
                }
                MButton {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    text: "↻"
                    font.pixelSize: 16
                    font.bold: true
                    onClicked: refreshNetworkList()
                }
            }
            SliderWithLabel {
                label: qsTr("Update Interval (ms)")
                from: 100
                to: 5000
                stepSize: 100
                value: tempConfig.networkInterval
                onEditingFinished: finalValue => tempConfig.networkInterval = finalValue
            }
        }
    }

    // ====================================================================
    // Footer
    // ====================================================================
    footer: RowLayout {
        spacing: selectedTheme.dimensions.spacingMedium
        MButton {
            text: "Reset"
            Layout.preferredWidth: 100
            onClicked: loadCurrentSettings()
        }
        Item {
            Layout.fillWidth: true
        }
        MButton {
            text: "Cancel"
            Layout.preferredWidth: 100
            onClicked: root.cancelChanges()
        }
        MButton {
            text: "Save"
            Layout.preferredWidth: 100
            highlighted: true
            onClicked: saveSettings()
        }
    }
}
