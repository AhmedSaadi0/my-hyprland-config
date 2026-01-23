// windows/settings/pages/AIPage.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt.labs.platform

import "root:/components"
import "root:/windows/settings/components"
import "root:/config"

BaseGeneralSettings {
    id: page
    title: qsTr("Intelligence & AI")
    icon: ""

    property var theme: page.selectedTheme

    // =========================================================
    // 1. الثوابت والنصوص الافتراضية
    // =========================================================
    readonly property string defaultWeatherPersona: "**ROLE**: Strategic Weather Advisor & Bio-Meteorologist.\n**MODE**: Predictive Lifestyle Analysis.\n\n**INTELLIGENCE RULES (Apply Strictly)**:\n1.  **Trajectory Analysis (CRITICAL)**: You are receiving full-day data. Do not focus only on \"Now\".\n    -   Compare *Current Temp* vs. *Forecasted Temp* for the next 4-6 hours.\n    -   Identify the *Shift*: Is it cooling down rapidly? Is rain approaching? Is the wind picking up?\n    \n2.  **Sensory Translation**: \n    -   Translate the number (e.g., 17°C) into a human feeling relative to the shift.\n    -   *Example*: \"Currently pleasant (17°C), but dropping fast.\"\n\n3.  **Layering Strategy (Wardrobe)**:\n    -   If the weather changes significantly (e.g., warm day -> cold night), advise on *layers*.\n    -   *Example*: \"Wear a t-shirt now, but absolutely bring a jacket for the evening drop.\"\n\n4.  **JSON Output Logic (`smart_summary`)**:\n    -   Construct the text in this format: [Current Feeling/Action] + [The Pivot/Future Change].\n    -   *Bad*: \"It is 17 degrees. It will be 12 later.\"\n    -   *Good*: \"Feels crisp and fresh right now. However, expect a sharp drop in temperature by sunset—keep a heavy layer nearby.\"\n\n5.  **Tagging Logic**: Use the `tags` array to highlight the *change* (e.g., [\"Cooling Down\", \"Windy Later\", \"Rain Incoming\"])."

    readonly property string defaultMusicPersona: "Role: You are \"VibeCheck,\" a chill, witty, and highly knowledgeable Audio-Visual Expert and Music Companion.\n\nExpertise: \n- Deep knowledge of Music Theory, History, and Production (Mixing/Mastering).\n- Expert in Cinematography, Video Editing, Color Grading, and Visual Aesthetics.\n- Up-to-date with Pop Culture, Memes, and Internet Media trends.\n\nPersonality & Tone:\n- Chill & Laid-back: You keep things relaxed. No stiff, robotic language.\n- Witty & Sarcastic: You enjoy clever humor and banter.\n- Brutally Honest (but Friendly): If the user shares a generic pop song or a poorly edited video, tease them about it. Call their taste \"basic\" or \"guilty pleasure\" in a fun way, but then provide genuine, high-level analysis or better recommendations.\n\nAlso make sure you do not just recommand songs, you recommand also actions like drinking coffee, reading a book, walking in calm, taking a shower ... etc, be creative. \nAlso don't ask the user to change the vibe ever, and if there is no recomandation, dont say try this song or anythink like that."

    // =========================================================
    // 2. المتغيرات المحلية
    // =========================================================
    property string localProvider: "gemini"
    property string localLanguage: "English"

    // Keys
    property string localMainKey: ""
    property string localWeatherKey: ""
    property string localMusicKey: ""

    // Models
    property string localWeatherModel: ""
    property string localMusicModel: ""

    // Personas
    property string localWeatherPersona: ""
    property string localMusicPersona: ""

    // Toggle Visibility
    property bool showKeys: false

    // =========================================================
    // 3. المزامنة (Read)
    // =========================================================
    function syncFromConfig() {
        localProvider = App.aiProvider || "gemini";
        localLanguage = App.aiPreferredLanguage || "English";

        localMainKey = App.aiApiKey || "";
        localWeatherKey = App.weatherAiApiKey || "";
        localMusicKey = App.musicAiApiKey || "";

        localWeatherModel = App.weatherAiModel || "";
        localMusicModel = App.musicAiModel || "";

        localWeatherPersona = App.weatherPersona || defaultWeatherPersona;
        localMusicPersona = App.musicPersona || defaultMusicPersona;

        // إذا لم تكن هناك موديلات محملة، نحاول التحديث
        if (App.availableGeminiWeatherModels.length === 0)
            App.modelsManager.refreshAll();
    }

    // =========================================================
    // 4. التجهيز للحفظ (Write)
    // =========================================================
    function serializeData() {
        return {
            "aiProvider": localProvider,
            "aiPreferredLanguage": localLanguage,
            "aiApiKey": localMainKey,
            "weatherAiApiKey": localWeatherKey,
            "musicAiApiKey": localMusicKey,
            "weatherAiModel": localWeatherModel,
            "musicAiModel": localMusicModel,
            "weatherPersona": localWeatherPersona,
            "musicPersona": localMusicPersona
        };
    }

    // =========================================================
    // 5. مكونات مساعدة
    // =========================================================
    // TextArea مخصص بنفس ستايل الحقول
    component StyledTextArea: Controls.ScrollView {
        id: sv
        property alias text: ta.text
        implicitHeight: 120
        clip: true

        Controls.TextArea {
            id: ta
            wrapMode: TextEdit.Wrap
            font.family: theme.typography.bodyFont
            font.pixelSize: theme.typography.small
            color: theme.colors.leftMenuFgColorV1
            selectedTextColor: theme.colors.onPrimary
            selectionColor: theme.colors.primary

            background: Rectangle {
                color: theme.colors.leftMenuBgColorV1
                radius: theme.dimensions.baseRadius / 2
                border.color: parent.activeFocus ? theme.colors.primary : theme.colors.subtleText
                border.width: 1
                opacity: 0.8
            }
        }
    }

    // =========================================================
    // 6. الواجهة
    // =========================================================
    ColumnLayout {
        spacing: theme.dimensions.spacingLarge
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        // --- FORM CONTENT ---
        GridLayout {
            Layout.preferredWidth: 580
            Layout.alignment: Qt.AlignHCenter
            columns: 2
            rowSpacing: 20
            columnSpacing: 20

            // ==========================
            // Section 1: Provider
            // ==========================
            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: "" // Gears
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("Provider & Locale")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
            }

            // AI Provider
            Controls.Label {
                text: qsTr("AI Provider")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: theme.colors.secondary
                Layout.alignment: Qt.AlignVCenter
            }
            SettingsComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: ["gemini", "openrouter", "local"]

                currentIndex: {
                    var idx = model.indexOf(page.localProvider);
                    return idx !== -1 ? idx : 0;
                }
                onActivated: index => page.localProvider = textAt(index)
            }

            // Language
            Controls.Label {
                text: qsTr("Preferred Language")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: theme.colors.secondary
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 6
            }
            EditableField {
                Layout.fillWidth: true
                text: page.localLanguage
                placeholderText: "e.g. English, Arabic"
                selectedTheme: page.theme
                onEditingFinished: page.localLanguage = text
            }

            // ==========================
            // Section 2: API Keys
            // ==========================
            Item {
                Layout.columnSpan: 2
                height: 10
            }

            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: "" // Key Icon
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("API Configuration")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
                Item {
                    Layout.fillWidth: true
                }
                // Show/Hide Password Button
                MButton {
                    text: page.showKeys ? "" : ""
                    font.family: theme.typography.iconFont
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    checkable: true
                    checked: page.showKeys
                    onClicked: page.showKeys = !page.showKeys
                }
            }

            Controls.Label {
                visible: page.localProvider !== "local"
                text: qsTr("Main API Key")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: theme.colors.secondary
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 6
            }
            EditableField {
                visible: page.localProvider !== "local"
                Layout.fillWidth: true
                text: page.localMainKey
                placeholderText: "sk-..."
                echoMode: page.showKeys ? TextInput.Normal : TextInput.Password
                selectedTheme: page.theme
                onEditingFinished: page.localMainKey = text
            }

            // ==========================
            // Section 3: Models
            // ==========================
            Item {
                Layout.columnSpan: 2
                height: 10
            }

            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: "" // Models Icon
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("Models Selection")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
                Item {
                    Layout.fillWidth: true
                }
                MButton {
                    text: App.modelsManager.isLoading ? "Loading..." : "Refresh"
                    iconText: ""
                    enabled: !App.modelsManager.isLoading
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 120
                    onClicked: App.modelsManager.refreshAll()
                    visible: page.localProvider === "gemini"
                }
            }

            // Error Message
            Text {
                visible: App.modelsManager.lastError !== ""
                text: "Error: " + App.modelsManager.lastError
                color: theme.colors.error
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.small
                Layout.columnSpan: 2
            }

            // --- Weather Model Logic ---
            Controls.Label {
                text: qsTr("Weather Model")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: theme.colors.secondary
                Layout.alignment: Qt.AlignVCenter
            }

            // 1. الخيار الأول: ComboBox (إذا لم يكن OpenRouter)
            SettingsComboBox {
                visible: page.localProvider !== "openrouter"
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: App.availableGeminiWeatherModels
                currentIndex: model.indexOf(page.localWeatherModel)
                displayText: currentIndex === -1 ? (page.localWeatherModel || "Select Model") : currentText
                onActivated: index => page.localWeatherModel = textAt(index)
            }

            // 2. الخيار الثاني: EditableField (إذا كان OpenRouter)
            EditableField {
                visible: page.localProvider === "openrouter"
                Layout.fillWidth: true
                placeholderText: "e.g. qwen/qwen-2-7b:free"
                text: page.localWeatherModel
                selectedTheme: page.theme
                onEditingFinished: page.localWeatherModel = text
            }

            // Specific Key for Weather (Optional)
            Controls.Label {
                text: qsTr("Specific Key (Opt)")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: theme.colors.secondary
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 6
            }
            EditableField {
                Layout.fillWidth: true
                text: page.localWeatherKey
                placeholderText: "Leave empty to use main key"
                echoMode: page.showKeys ? TextInput.Normal : TextInput.Password
                selectedTheme: page.theme
                onEditingFinished: page.localWeatherKey = text
            }

            // --- Music Model Logic ---
            Controls.Label {
                text: qsTr("Music Model")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: theme.colors.secondary
                Layout.alignment: Qt.AlignVCenter
            }

            // 1. ComboBox
            SettingsComboBox {
                visible: page.localProvider !== "openrouter"
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: App.availableGeminiMusicModels
                currentIndex: model.indexOf(page.localMusicModel)
                displayText: currentIndex === -1 ? (page.localMusicModel || "Select Model") : currentText
                onActivated: index => page.localMusicModel = textAt(index)
            }

            // 2. EditableField
            EditableField {
                visible: page.localProvider === "openrouter"
                Layout.fillWidth: true
                placeholderText: "e.g. anthropic/claude-3-haiku"
                text: page.localMusicModel
                selectedTheme: page.theme
                onEditingFinished: page.localMusicModel = text
            }

            // Specific Key for Music (Optional)
            Controls.Label {
                text: qsTr("Specific Key (Opt)")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: theme.colors.secondary
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 6
            }
            EditableField {
                Layout.fillWidth: true
                text: page.localMusicKey
                placeholderText: "Leave empty to use main key"
                echoMode: page.showKeys ? TextInput.Normal : TextInput.Password
                selectedTheme: page.theme
                onEditingFinished: page.localMusicKey = text
            }

            // ==========================
            // Section 4: Personas
            // ==========================
            Item {
                Layout.columnSpan: 2
                height: 10
            }

            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: "" // Script/Text Icon
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("System Personas")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
            }

            // Weather Persona
            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Controls.Label {
                    text: qsTr("Weather Assistant Persona")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    color: theme.colors.secondary
                }
                Item {
                    Layout.fillWidth: true
                }
                MButton {
                    text: "Reset Default"
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 120
                    flat: true
                    onClicked: page.localWeatherPersona = page.defaultWeatherPersona
                }
            }
            StyledTextArea {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                text: page.localWeatherPersona
                onTextChanged: page.localWeatherPersona = text
            }

            // Music Persona
            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Layout.topMargin: 10
                Controls.Label {
                    text: qsTr("Music Assistant Persona")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    color: theme.colors.secondary
                }
                Item {
                    Layout.fillWidth: true
                }
                MButton {
                    text: "Reset Default"
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 120
                    flat: true
                    onClicked: page.localMusicPersona = page.defaultMusicPersona
                }
            }
            StyledTextArea {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                text: page.localMusicPersona
                onTextChanged: page.localMusicPersona = text
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
