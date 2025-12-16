// settings/GeneralSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import Qt.labs.platform
import Quickshell.Io

import "root:/components"
import "root:/config"

M3GroupBox {
    id: root
    title: qsTr("General Configuration")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var selectedTheme

    readonly property string defaultWeatherPersona: "You are a professional Senior Meteorologist. You provide precise, actionable advice based on data. You care about the user safety and comfort."
    readonly property string defaultMusicPersona: "You are a chill, witty Music Companion. You enjoy good vibes and occasionally tease the user about their taste in a friendly way."

    QtObject {
        id: tempConfig
        property string username: ""
        property string subtitle: ""
        property string profilePicture: ""
        property string city: ""
        property string country: ""
        property string weatherLocation: ""
        property bool usePrayerTimes: true
        property string networkMonitor: ""
        property int networkInterval: 1000
        property string aiPreferredLanguage: "English"
        property string geminiApiKey: ""
        property string weatherAiApiKey: ""
        property string musicAiApiKey: ""
        property string weatherPersona: ""
        property string musicPersona: ""
    }

    // ====================================================================
    // 2. أدوات مساعدة
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
    // 3. التحميل والحفظ
    // ====================================================================

    function loadCurrentSettings() {
        tempConfig.username = App.username;
        tempConfig.subtitle = App.subtitle;
        tempConfig.profilePicture = App.profilePicture;
        tempConfig.city = App.city;
        tempConfig.country = App.country;
        tempConfig.weatherLocation = App.weatherLocation;
        tempConfig.usePrayerTimes = App.usePrayerTimes;
        tempConfig.networkMonitor = App.networkMonitor;
        tempConfig.networkInterval = App.networkInterval;
        tempConfig.aiPreferredLanguage = App.aiPreferredLanguage;
        tempConfig.geminiApiKey = App.geminiApiKey;
        tempConfig.weatherAiApiKey = App.weatherAiApiKey;
        tempConfig.musicAiApiKey = App.musicAiApiKey;

        tempConfig.weatherPersona = App.weatherPersona || defaultWeatherPersona;
        tempConfig.musicPersona = App.musicPersona || defaultMusicPersona;

        refreshNetworkList();
    }

    function saveSettings() {
        var dataToSave = {
            "username": tempConfig.username,
            "subtitle": tempConfig.subtitle,
            "profilePicture": tempConfig.profilePicture,
            "city": tempConfig.city,
            "country": tempConfig.country,
            "weatherLocation": tempConfig.weatherLocation,
            "usePrayerTimes": tempConfig.usePrayerTimes,
            "networkMonitor": tempConfig.networkMonitor,
            "networkInterval": tempConfig.networkInterval,
            "aiPreferredLanguage": tempConfig.aiPreferredLanguage,
            "geminiApiKey": tempConfig.geminiApiKey,
            "weatherAiApiKey": tempConfig.weatherAiApiKey,
            "musicAiApiKey": tempConfig.musicAiApiKey,
            "weatherPersona": tempConfig.weatherPersona,
            "musicPersona": tempConfig.musicPersona
        };

        App.updateConfigMultiple(dataToSave);
        console.info("General settings saved successfully.");
        root.saveChanges();
    }

    signal saveChanges
    signal cancelChanges

    Component.onCompleted: loadCurrentSettings()

    // ====================================================================
    // 4. الواجهة الرسومية
    // ====================================================================
    ColumnLayout {
        id: mainLayout
        spacing: selectedTheme.dimensions.spacingSmall

        // --- User Profile ---
        Controls.Label {
            text: qsTr("User Profile")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium

            // === [تعديل] الاسم والسب تيتل في صف واحد ===
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
            // ==========================================

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
            Layout.topMargin: selectedTheme.dimensions.spacingLarge
        }

        // --- Location & Weather ---
        Controls.Label {
            text: qsTr("Location & Weather Settings")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: selectedTheme.dimensions.spacingMedium
        }

        ColumnLayout {
            Layout.preferredWidth: 590
            spacing: selectedTheme.dimensions.spacingMedium

            // === [تعديل] الدولة والمدينة وموقع الطقس في صف واحد ===
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
                        text: qsTr("Weather Location (API)")
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
            // ====================================================

            SettingSwitch {
                label: qsTr("Enable Prayer Times")
                isChecked: tempConfig.usePrayerTimes
                onIsCheckedChanged: tempConfig.usePrayerTimes = isChecked
            }
        }

        Kirigami.Separator {
            Layout.topMargin: selectedTheme.dimensions.spacingLarge
        }

        // --- AI Configuration & Persona ---
        Controls.Label {
            text: qsTr("AI & Personas")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: selectedTheme.dimensions.spacingMedium
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium

            // 1. Preferred Language
            Controls.Label {
                text: qsTr("Preferred Language")
                font.bold: true
            }
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: tempConfig.aiPreferredLanguage
                selectedTheme: root.selectedTheme
                placeholderText: "e.g. English, Arabic, Japanese..."
                onEditingFinished: tempConfig.aiPreferredLanguage = text
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

                Controls.TextArea {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
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
                        Behavior on border.width {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                    }
                }

                Controls.Label {
                    text: qsTr("Describe who presents the weather.")
                    font.pixelSize: selectedTheme.typography.small
                    color: selectedTheme.colors.subtleText
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

                Controls.TextArea {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
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
                        Behavior on border.width {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                    }
                }

                Controls.Label {
                    text: qsTr("Describe your music companion.")
                    font.pixelSize: selectedTheme.typography.small
                    color: selectedTheme.colors.subtleText
                }
            }

            // API Keys
            Controls.Label {
                text: qsTr("Gemini API Key")
                font.bold: true
                Layout.topMargin: 10
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                EditableField {
                    Layout.fillWidth: true
                    text: tempConfig.geminiApiKey
                    selectedTheme: root.selectedTheme
                    echoMode: geminiShowBtn.checked ? TextInput.Normal : TextInput.Password
                    onEditingFinished: tempConfig.geminiApiKey = text
                }
                MButton {
                    id: geminiShowBtn
                    checkable: true
                    text: checked ? "👁️" : "🔒"
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                }
            }

            Controls.Label {
                text: qsTr("Specific Keys (Optional)")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    EditableField {
                        Layout.fillWidth: true
                        placeholderText: "Weather API Key"
                        text: tempConfig.weatherAiApiKey
                        selectedTheme: root.selectedTheme
                        echoMode: weatherShowBtn.checked ? TextInput.Normal : TextInput.Password
                        onEditingFinished: tempConfig.weatherAiApiKey = text
                    }
                    MButton {
                        id: weatherShowBtn
                        checkable: true
                        text: checked ? "👁️" : "🔒"
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    EditableField {
                        Layout.fillWidth: true
                        placeholderText: "Music API Key"
                        text: tempConfig.musicAiApiKey
                        selectedTheme: root.selectedTheme
                        echoMode: musicShowBtn.checked ? TextInput.Normal : TextInput.Password
                        onEditingFinished: tempConfig.musicAiApiKey = text
                    }
                    MButton {
                        id: musicShowBtn
                        checkable: true
                        text: checked ? "👁️" : "🔒"
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.topMargin: selectedTheme.dimensions.spacingLarge
        }

        // --- System & Network ---
        Controls.Label {
            text: qsTr("System & Network")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: selectedTheme.dimensions.spacingMedium
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium

            Controls.Label {
                text: qsTr("Network Interface")
                font.bold: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
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
                label: qsTr("Network Update Interval (ms)")
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
