// MenuCard.qml (الإصدار المصحح)

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "../../../components"
import "../../../themes"

MenuCard {
    id: root

    property bool settingsExpanded: false

    readonly property int fixedHeight: (grid.implicitHeight + settingsHeader.height + 5) * 2
    height: settingsExpanded ? settingsLayout.implicitHeight + padding + fixedHeight : fixedHeight

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    title: "Themes & Customization"
    icon: ""

    property var workingTheme: ({})
    ListModel {
        id: colorModel
    }

    readonly property var themePropertyKeys: ThemeManager._allSerializableKeys

    function copyTheme(themeObject) {
        if (!themeObject)
            return {};
        const newTheme = {};
        for (const key of root.themePropertyKeys) {
            if (themeObject.hasOwnProperty(key)) {
                newTheme[key] = themeObject[key];
            }
        }
        return newTheme;
    }

    function populateColorModel(theme) {
        colorModel.clear();
        if (!theme || Object.keys(theme).length === 0)
            return;

        function appendColor(label, bgProp, fgProp, isEnabled) {
            const bgColor = theme[bgProp];
            const fgColor = fgProp ? theme[fgProp] : "transparent";
            const enabled = isEnabled;

            colorModel.append({
                "label": label,
                "bgPropName": bgProp,
                "fgPropName": fgProp,
                "bgColor": bgColor,
                "fgColor": fgColor,
                "bgColorString": Qt.color(bgColor).toString(),
                "fgColorString": Qt.color(fgColor).toString(),
                "enabled": enabled
            });
        }

        appendColor("Primary", "_primary", "_onPrimary", !workingTheme._enableDynamicColoring);
        appendColor("Secondary", "_secondary", "_onSecondary", !workingTheme._enableDynamicColoring);
        appendColor("Topbar BG V1", "_topbarBgColorV1", "_topbarFgColorV1", !workingTheme._enableDynamicColoring);
        appendColor("Topbar BG V2", "_topbarBgColorV2", "_topbarFgColorV2", !workingTheme._enableDynamicColoring);
        appendColor("Topbar BG V3", "_topbarBgColorV3", "_topbarFgColorV3", !workingTheme._enableDynamicColoring);
        appendColor("Left Menu BG V1", "_leftMenuBgColorV1", "_leftMenuFgColorV1", !workingTheme._enableDynamicColoring);
        appendColor("Left Menu BG V2", "_leftMenuBgColorV2", "_leftMenuFgColorV2", !workingTheme._enableDynamicColoring);
        appendColor("Left Menu BG V3", "_leftMenuBgColorV3", "_leftMenuFgColorV3", !workingTheme._enableDynamicColoring);
        appendColor("Volume OSD", "_volOsdBgColor", "_volOsdFgColor", !workingTheme._enableDynamicColoring);
        appendColor("Subtle Text", "_subtleTextColor", "_subtleTextColor", !workingTheme._enableDynamicColoring);
    }

    Component.onCompleted: {
        root.workingTheme = copyTheme(ThemeManager.selectedTheme);
        populateColorModel(root.workingTheme);
    }

    Connections {
        target: ThemeManager
        function onSelectedThemeUpdated() {
            root.workingTheme = copyTheme(ThemeManager.selectedTheme);
            populateColorModel(root.workingTheme);
        }
    }

    ColumnLayout {
        id: mainLayout
        spacing: 10

        GridLayout {
            id: grid
            columns: 3
            Layout.fillWidth: true
            MButton {
                text: "Colors"
                onClicked: ThemeManager.loadTheme("ColorsTheme")
                Layout.fillWidth: true
                iconText: ""
            }
            MButton {
                text: "Deer"
                onClicked: ThemeManager.loadTheme("DeerTheme")
                Layout.fillWidth: true
                iconText: ""
            }
            MButton {
                text: "M3 Dark"
                onClicked: ThemeManager.loadTheme("M3Dark")
                Layout.fillWidth: true
                iconText: "󰖔"
            }
            MButton {
                text: "Harmony"
                onClicked: ThemeManager.loadTheme("HarmonyTheme")
                Layout.fillWidth: true
                iconText: "󰔉"
            }
            MButton {
                text: "Dark"
                onClicked: ThemeManager.loadTheme("DarkTheme")
                Layout.fillWidth: true
                iconText: "󱀝"
            }
            MButton {
                text: "M3 Light"
                onClicked: ThemeManager.loadTheme("M3Light")
                Layout.fillWidth: true
                iconText: ""
            }
        }

        Rectangle {
            id: sperator
            Layout.fillWidth: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            height: 1
            color: ThemeManager.selectedTheme.colors.topbarFgColorV1.alpha(0.2)
        }

        Rectangle {
            id: settingsHeader
            Layout.fillWidth: true
            height: 30
            color: "transparent"
            radius: 4
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Label {
                    text: "Advanced Customization"
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }
                Item {
                    Layout.fillWidth: true
                }
                Label {
                    id: expandIcon
                    text: ""
                    font.family: "FantasqueSansM Nerd Font Propo"
                    font.pixelSize: 16
                    color: Kirigami.Theme.textColor
                    rotation: root.settingsExpanded ? 180 : 0
                    Behavior on rotation {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.settingsExpanded = !root.settingsExpanded
            }
        }

        ColumnLayout {
            id: settingsLayout
            spacing: 12
            Layout.fillWidth: true
            height: root.settingsExpanded ? implicitHeight : 0
            opacity: root.settingsExpanded ? 1.0 : 0.0
            clip: true
            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuad
                }
            }

            M3GroupBox {
                title: "Wallpaper Settings"
                Layout.fillWidth: true
                Switch {
                    text: "Enable dynamic wallpapers"
                    checked: workingTheme._enableDynamicWallpapers
                    onCheckedChanged: workingTheme._enableDynamicWallpapers = checked
                }
                Switch {
                    text: "Enable colors from wallpaper"
                    checked: workingTheme._enableDynamicColoring
                    onCheckedChanged: workingTheme._enableDynamicColoring = checked
                }
                TextField {
                    placeholderText: "Wallpapers interval"
                    text: workingTheme._dynamicWallpapersInterval
                    onAccepted: workingTheme._dynamicWallpapersInterval = Number(text)
                }
                TextField {
                    placeholderText: "Wallpapers folder path"
                    text: workingTheme._dynamicWallpapersPath
                    enabled: workingTheme._enableDynamicWallpapers
                    onAccepted: workingTheme._dynamicWallpapersPath = text
                }
                TextField {
                    placeholderText: "Static Wallpaper Path"
                    text: workingTheme._wallpaper
                    enabled: !workingTheme._enableDynamicWallpapers
                    onAccepted: workingTheme._wallpaper = text
                }
            }

            M3GroupBox {
                title: "Component Themes"
                Layout.fillWidth: true
                TextField {
                    placeholderText: "Plasma color scheme"
                    text: workingTheme._plasmaColorScheme
                    onAccepted: workingTheme._plasmaColorScheme = text
                }
                TextField {
                    placeholderText: "QT style (e.g., Kvantum)"
                    text: workingTheme._qtThemeStyle
                    onAccepted: workingTheme._qtThemeStyle = text
                }
                TextField {
                    placeholderText: "Kvantum theme name"
                    text: workingTheme._kvantumTheme
                    onAccepted: workingTheme._kvantumTheme = text
                }
                TextField {
                    placeholderText: "Konsole profile name"
                    text: workingTheme._konsoleProfile
                    onAccepted: workingTheme._konsoleProfile = text
                }
                TextField {
                    placeholderText: "GTK theme name"
                    text: workingTheme._gtkTheme
                    onAccepted: workingTheme._gtkTheme = text
                }
                TextField {
                    placeholderText: "Icon pack name"
                    text: workingTheme._themeIcons
                    onAccepted: workingTheme._themeIcons = text
                }
                ComboBox {
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        {
                            text: "Light Mode",
                            value: "light"
                        },
                        {
                            text: "Dark Mode",
                            value: "dark"
                        }
                    ]
                    currentIndex: workingTheme._themeMode === "light" ? 0 : 1
                    onActivated: workingTheme._themeMode = model[currentIndex].value
                }
            }

            // --- الكود المصحح هنا ---
            M3GroupBox {
                title: "Hyprland Settings"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true

                    Label {
                        text: "Border Width"
                    }
                    TextField {
                        Layout.fillWidth: true
                        text: workingTheme._hyprBorderWidth
                        onAccepted: workingTheme._hyprBorderWidth = Number(text)
                    }

                    Label {
                        text: "Rounding"
                    }
                    TextField {
                        Layout.fillWidth: true
                        text: workingTheme._hyprRounding
                        onAccepted: workingTheme._hyprRounding = Number(text)
                    }

                    Label {
                        text: "Active Border"
                    }
                    TextField {
                        Layout.fillWidth: true
                        text: workingTheme._hyprActiveBorder
                        onAccepted: workingTheme._hyprActiveBorder = text
                    }

                    Label {
                        text: "Inactive Border"
                    }
                    TextField {
                        Layout.fillWidth: true
                        text: workingTheme._hyprInactiveBorder
                        onAccepted: workingTheme._hyprInactiveBorder = text
                    }

                    Label {
                        text: "Drop Shadow"
                    }
                    Switch {
                        checked: workingTheme._hyprDropShadow
                        onCheckedChanged: workingTheme._hyprDropShadow = checked
                    }
                }
            }

            M3GroupBox {
                title: "Dimensions & Spacing"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    Repeater {
                        model: ThemeManager._dimensionPropertyKeys
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: modelData.substring(1).replace(/([A-Z])/g, ' $1').trim()
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            TextField {
                                Layout.preferredWidth: 80
                                text: workingTheme[modelData]
                                horizontalAlignment: TextInput.AlignRight
                                onAccepted: workingTheme[modelData] = Number(text)
                            }
                        }
                    }
                }
            }

            M3GroupBox {
                title: "Typography"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    Repeater {
                        model: ThemeManager._typographyPropertyKeys
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: modelData.substring(1).replace(/([A-Z])/g, ' $1').trim()
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            TextField {
                                Layout.preferredWidth: 150
                                text: workingTheme[modelData]
                                horizontalAlignment: TextInput.AlignRight
                                onAccepted: workingTheme[modelData] = (typeof ThemeManager.selectedTheme[modelData] === "number") ? Number(text) : text
                            }
                        }
                    }
                }
            }

            M3GroupBox {
                id: colorsBox
                title: "Colors & Appearance"
                Layout.fillWidth: true
                Layout.topMargin: 10
                enabled: !workingTheme._enableDynamicColoring
                Repeater {
                    model: colorModel
                    delegate: GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 0
                        Label {
                            text: model.label
                            Layout.preferredWidth: parent.width / 2
                            Layout.fillWidth: true
                        }
                        EditableColorField {
                            Layout.preferredWidth: parent.width * (model.fgPropName !== null ? 2 / 6 : 4 / 6)
                            Layout.fillWidth: true
                            Layout.preferredHeight: 25
                            text: model.bgColorString
                            normalBackground: model.bgColor
                            normalForeground: model.fgColor
                            topRightRadius: 0
                            enabled: model.enabled
                            bottomRightRadius: 0
                            topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
                            bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
                            onValidColorUpdated: function (newColor) {
                                root.workingTheme[model.bgPropName] = newColor;
                            }
                        }
                        EditableColorField {
                            visible: model.fgPropName !== null
                            Layout.preferredWidth: parent.width * 2 / 6
                            Layout.fillWidth: true
                            Layout.preferredHeight: 25
                            text: model.fgColorString
                            enabled: model.enabled
                            normalBackground: model.fgColor
                            normalForeground: model.bgColor
                            topLeftRadius: 0
                            bottomLeftRadius: 0
                            topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
                            bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
                            onValidColorUpdated: function (newColor) {
                                root.workingTheme[model.fgPropName] = newColor;
                            }
                        }
                    }
                }
            }

            M3GroupBox {
                title: "Actions & Resets"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    MButton {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 30
                        text: "Reset Colors"
                        onClicked: ThemeManager.resetColorSettings()
                    }
                    MButton {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 30
                        text: "Reset Wallpapers"
                        onClicked: ThemeManager.resetWallpaperSystemSettings()
                    }
                    MButton {
                        Layout.fillWidth: true
                        text: "Reset Hyprland"
                        onClicked: ThemeManager.resetHyprlandSettings()
                    }
                    MButton {
                        Layout.fillWidth: true
                        text: "Reset Plasma/QT"
                        onClicked: ThemeManager.resetPlasmaSettings()
                    }
                    MButton {
                        Layout.fillWidth: true
                        text: "Reset GTK"
                        onClicked: ThemeManager.resetGtkSettings()
                    }
                    MButton {
                        Layout.fillWidth: true
                        text: "Next Wallpaper"
                        onClicked: ThemeManager.switchToNextWallpaper()
                        iconText: ""
                    }
                }
            }

            M3GroupBox {
                title: "Apply Changes"
                Layout.fillWidth: true
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    MButton {
                        Layout.fillWidth: true
                        text: "Apply"
                        iconText: ""
                        onClicked: ThemeManager.updateAndApplyTheme(workingTheme, false)
                        textPreferredWidth: 3
                    }
                    MButton {
                        Layout.fillWidth: true
                        text: "Apply & Save"
                        iconText: ""
                        highlighted: true
                        onClicked: ThemeManager.updateAndApplyTheme(workingTheme, true)
                        textPreferredWidth: 5
                    }
                }
            }
        }
    }
}
