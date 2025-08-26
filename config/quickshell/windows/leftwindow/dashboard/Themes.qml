// windows/leftwindow/dashboard/Themes.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs
import Qt.labs.platform

import "../../../components"
import "../../../themes"
import "./settings"
import "root:/utils/helpers.js" as Helper

MenuCard {
    id: root

    title: "Themes & Customization"
    icon: ""

    property bool settingsExpanded: false
    property bool alphaMatting: false
    property int foregroundThreshold: 240
    property int backgroundThreshold: 10
    property int erodeSize: 10

    readonly property int fixedHeight: (grid.implicitHeight + settingsHeader.height + fullThemesRow.implicitHeight + fullThemesRow2.implicitHeight - 35) * 2
    height: settingsExpanded ? settingsLayout.implicitHeight + padding + fixedHeight : fixedHeight

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    // property var workingTheme: ({})
    property var workingTheme: root.copyTheme(ThemeManager.selectedTheme)

    ListModel {
        id: colorModel
    }

    readonly property var themePropertyKeys: ThemeManager._allSerializableKeys

    function updateWorkingTheme(sourceTheme) {
        if (!sourceTheme || !workingTheme)
            return;

        // مسح الخصائص القديمة (اختياري ولكنه جيد لتجنب بقاء قيم قديمة)
        for (const key in workingTheme) {
            delete workingTheme[key];
        }

        // نسخ الخصائص الجديدة إلى الكائن الموجود
        for (const key of root.themePropertyKeys) {
            if (sourceTheme.hasOwnProperty(key)) {
                workingTheme[key] = sourceTheme[key];
            }
        }
    }

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
        if (!theme || Object.keys(theme).length === 0) {
            colorModel.clear();
            return;
        }

        // استخدام bulk update لتحسين الأداء ومنع التسريبات المحتملة
        var newModelData = [];

        function appendColor(label, bgProp, fgProp, isEnabled) {
            const bgColor = theme[bgProp];
            const fgColor = fgProp ? theme[fgProp] : "transparent";

            // إضافة فحص للتأكد من أن الألوان ليست undefined قبل استخدامها
            if (typeof bgColor === 'undefined') {
                console.warn(`Warning: '${bgProp}' is undefined in the current theme.`);
                return; // تخطي هذا اللون لتجنب الأخطاء
            }

            newModelData.push({
                "label": label,
                "bgPropName": bgProp,
                "fgPropName": fgProp,
                "bgColor": bgColor,
                "fgColor": fgColor,
                "bgColorString": Qt.color(bgColor).toString(),
                "fgColorString": Qt.color(fgColor).toString(),
                "enabled": isEnabled
            });
        }

        const isDynamic = !theme._enableDynamicColoring;
        appendColor("Primary", "_primary", "_onPrimary", !workingTheme._enableDynamicColoring);
        appendColor("Secondary", "_secondary", "_onSecondary", isDynamic);
        appendColor("Topbar Color", "_topbarColor", "_topbarFgColor", !workingTheme._enableDynamicColoring);
        appendColor("Topbar BG V1", "_topbarBgColorV1", "_topbarFgColorV1", !workingTheme._enableDynamicColoring);
        appendColor("Topbar BG V2", "_topbarBgColorV2", "_topbarFgColorV2", !workingTheme._enableDynamicColoring);
        appendColor("Topbar BG V3", "_topbarBgColorV3", "_topbarFgColorV3", !workingTheme._enableDynamicColoring);
        appendColor("Left Menu BG V1", "_leftMenuBgColorV1", "_leftMenuFgColorV1", !workingTheme._enableDynamicColoring);
        appendColor("Left Menu BG V2", "_leftMenuBgColorV2", "_leftMenuFgColorV2", !workingTheme._enableDynamicColoring);
        appendColor("Left Menu BG V3", "_leftMenuBgColorV3", "_leftMenuFgColorV3", !workingTheme._enableDynamicColoring);
        appendColor("OSD", "_volOsdBgColor", "_volOsdFgColor", !workingTheme._enableDynamicColoring);
        appendColor("Subtle Text", "_subtleTextColor", "_subtleTextColor", !workingTheme._enableDynamicColoring);

        colorModel.clear();
        colorModel.append(newModelData);
    }

    Component.onCompleted: {
        // لم نعد بحاجة لتهيئة workingTheme هنا لأنه تم تهيئته عند التعريف.
        // نحتاج فقط لملء النموذج لأول مرة.
        populateColorModel(root.workingTheme);
    }

    // --- (4) تعديل: تبسيط Connections ---
    Connections {
        target: ThemeManager
        function onSelectedThemeUpdated() {
            // تحديث workingTheme بالقيم الجديدة من الثيم الذي تم تحميله
            root.updateWorkingTheme(ThemeManager.selectedTheme);
            populateColorModel(root.workingTheme);

            // إشعار الواجهة بالتغييرات
            root.workingThemeChanged();
        }
    }

    FolderDialog {
        id: dynamicWallpaperFolderDialog
        title: "Please choose a wallpapers folder"
        onAccepted: {
            // FolderDialog يُرجع المسار في خاصية اسمها folder
            const folderPath = this.folder.toString().replace("file://", "");
            wallpaperFolderSelectButton.text = folderPath;
            workingTheme._dynamicWallpapersPath = folderPath;
        }
    }

    FileDialog {
        id: staticWallpaperFileDialog
        title: "Please choose a static wallpaper"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp)", "All files (*.*)"]
        onAccepted: {
            const filePath = file.toString().replace("file://", "");
            wallpaperImageSelectButton.text = filePath;
            workingTheme._wallpaper = filePath;
        }
    }

    FileDialog {
        id: clockDepthOverlayDialog
        title: "Select Overlay Image"
        nameFilters: ["Image files (*.jpg *.jpeg *.png)", "All files (*.*)"]
        onAccepted: {
            const filePath = file.toString().replace("file://", "");
            overlayImageButton.text = filePath;
            workingTheme._desktopClockDepthOverlayPath = filePath;
        }
    }

    ColumnLayout {
        id: mainLayout
        spacing: 10

        RowLayout {
            id: fullThemesRow
            Layout.fillWidth: true
            spacing: 10 // مسافة بين البطاقات

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: "Dracula"
                lightThemeName: "DraculaLight"
                darkThemeName: "DraculaDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: "Catppuccin"
                lightThemeName: "CatppuccinLight"
                darkThemeName: "CatppuccinDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: "Material"
                lightThemeName: "M3Light"
                darkThemeName: "M3Dark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }
        }

        RowLayout {
            id: fullThemesRow2
            Layout.fillWidth: true
            spacing: 10 // مسافة بين البطاقات

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: "Nord"
                lightThemeName: "NordLight"
                darkThemeName: "NordDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }

            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: "Gruvbox"
                lightThemeName: "GruvboxLight"
                darkThemeName: "GruvboxDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }
            ThemeSelectorCard {
                Layout.fillWidth: true // مهم جدًا: اجعل البطاقة تملأ العرض
                themeTitle: "Tokyo Night"
                lightThemeName: "TokyoNightLight"
                darkThemeName: "TokyoNightDark"

                isSelected: ThemeManager.selectedTheme.themeName === lightThemeName || ThemeManager.selectedTheme.themeName === darkThemeName
            }
        }

        Label {
            id: singleThemeLabel
            text: "Single Themes"
            font.pointSize: 10
            font.bold: true
            color: Kirigami.Theme.textColor
            opacity: 0.8
            Layout.topMargin: 5
            // Layout.horizontalCenter: parent.horizontalCenter

        }

        GridLayout {
            id: grid
            columns: 3 // استخدام عمودين مناسب للأزرار الصغيرة
            Layout.fillWidth: true
            columnSpacing: 10
            rowSpacing: 10

            MButton {
                text: "Colors"
                onClicked: ThemeManager.loadTheme("ColorsTheme")
                Layout.fillWidth: true
                iconText: ""
                isActive: ThemeManager.selectedTheme.themeName === "ColorsTheme"
            }
            MButton {
                text: "Deer"
                onClicked: ThemeManager.loadTheme("DeerTheme")
                Layout.fillWidth: true
                iconText: ""
                isActive: ThemeManager.selectedTheme.themeName === "DeerTheme"
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

            ActionsAndResets {}

            // TODO: -> Mode to new files and use components
            M3GroupBox {
                title: "Wallpaper Settings"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: 5

                    // ... (الأكواد الخاصة بـ enableDynamicWallpapersSwitch و enableDynamicColoringSwitch بدون تغيير) ...
                    Label {
                        text: "Enable dynamic wallpapers"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Switch {
                        id: enableDynamicWallpapersSwitch
                        Layout.alignment: Qt.AlignRight
                        checked: workingTheme._enableDynamicWallpapers
                        onCheckedChanged: workingTheme._enableDynamicWallpapers = checked
                    }

                    Label {
                        text: "Enable dynamic colors"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Switch {
                        Layout.alignment: Qt.AlignRight
                        checked: workingTheme._enableDynamicColoring
                        onCheckedChanged: {
                            workingTheme._enableDynamicColoring = checked;
                            populateColorModel(workingTheme);
                        }
                    }

                    Label {
                        text: "Wallpapers interval"
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._dynamicWallpapersInterval
                        onEditingFinished: workingTheme._dynamicWallpapersInterval = Number(text)
                    }

                    Label {
                        text: "Selected Wallpaper"
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._selectedWallpaperIndex
                        onEditingFinished: workingTheme._selectedWallpaperIndex = Number(text)
                    }

                    // --- (3) تعديل: الكود الخاص باختيار المجلد لم يتغير هنا، التغيير كان في تعريف dynamicWallpaperFolderDialog في الأعلى ---
                    Label {
                        text: "Wallpapers folder"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        enabled: enableDynamicWallpapersSwitch.checked

                        // TextField {
                        //     Layout.fillWidth: true
                        //     text: workingTheme._dynamicWallpapersPath
                        //     placeholderText: "Select a folder..."
                        //     readOnly: true // من الأفضل جعله للقراءة فقط
                        // }
                        MButton {
                            id: wallpaperFolderSelectButton
                            iconText: ""
                            text: workingTheme._dynamicWallpapersPath
                            Layout.fillWidth: true
                            onClicked: dynamicWallpaperFolderDialog.open()
                            textElide: Text.ElideLeft
                            showTooltip: true
                            iconPreferredWidth: 1
                            textPreferredWidth: 3
                        }
                    }

                    // --- الكود الخاص بالخلفية الثابتة يبقى كما هو لأنه يعمل بشكل صحيح ---
                    Label {
                        text: "Static Wallpaper"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        enabled: !enableDynamicWallpapersSwitch.checked

                        // TextField {
                        //     Layout.fillWidth: true
                        //     text: workingTheme._wallpaper
                        //     placeholderText: "Select a file..."
                        //     readOnly: true // من الأفضل جعله للقراءة فقط
                        // }
                        MButton {
                            id: wallpaperImageSelectButton
                            iconText: ""
                            text: workingTheme._wallpaper
                            Layout.fillWidth: true
                            onClicked: staticWallpaperFileDialog.open()
                            textElide: Text.ElideLeft
                            showTooltip: true
                            iconPreferredWidth: 1
                            textPreferredWidth: 3
                        }
                    }
                }
            }

            M3GroupBox {
                id: clockSettingsGroup
                title: "Clock Widget Settings"
                Layout.fillWidth: true

                // جعل المجموعة بأكملها غير مفعلة إذا تم تعطيل الساعة

                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: 5
                    columnSpacing: 10

                    // مفتاح لتفعيل أو تعطيل الويدجت بالكامل
                    Label {
                        text: "Enable Clock Widget"
                        Layout.alignment: Qt.AlignVCenter
                        // جعل النص باهتًا إذا تم تعطيل الويدجت الرئيسي
                        opacity: clockSettingsGroup.enabled ? 1.0 : 0.5
                    }
                    Switch {
                        Layout.alignment: Qt.AlignRight
                        // هذا المفتاح يتحكم في خاصية "enabled" للمجموعة كلها
                        checked: workingTheme._desktopClockEnabled
                        onCheckedChanged: workingTheme._desktopClockEnabled = checked
                    }

                    // حقل لتغيير لون الساعة
                    Label {
                        text: "Clock Color"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableColorField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25
                        // ربط القيم بخصائص الساعة في الثيم
                        text: Qt.color(workingTheme._desktopClockColor).toString()
                        normalForeground: Helper.getAccurteTextColor(workingTheme._desktopClockColor)
                        normalBackground: workingTheme._desktopClockColor
                        onValidColorUpdated: workingTheme._desktopClockColor = newColor
                        enabled: workingTheme._desktopClockEnabled
                    }

                    Label {
                        text: "Enable Shadow"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Switch {
                        id: colorShadowSwitch
                        Layout.alignment: Qt.AlignRight
                        checked: workingTheme._desktopClockSahdowEnabled
                        onCheckedChanged: workingTheme._desktopClockSahdowEnabled = checked
                        enabled: workingTheme._desktopClockEnabled
                    }

                    Label {
                        text: "Shadow Color"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableColorField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25
                        text: Qt.color(workingTheme._desktopClockSahdowColor).toString()
                        normalForeground: Helper.getAccurteTextColor(workingTheme._desktopClockSahdowColor)
                        normalBackground: workingTheme._desktopClockSahdowColor
                        onValidColorUpdated: workingTheme._desktopClockSahdowColor = newColor
                        enabled: colorShadowSwitch.checked
                    }

                    Label {
                        text: "Clock Format"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._desktopClockFormat
                        placeholderText: "e.g., hh:mm or h:mm A"
                        onEditingFinished: workingTheme._desktopClockFormat = text
                        enabled: workingTheme._desktopClockEnabled
                    }

                    Label {
                        text: "Clock Local"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._desktopClockLocal
                        placeholderText: "e.g., en_US"
                        onEditingFinished: workingTheme._desktopClockLocal = text
                        enabled: workingTheme._desktopClockEnabled
                    }

                    Label {
                        text: "Clock Font"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._desktopClockFont
                        onEditingFinished: workingTheme._desktopClockFont = text
                        enabled: workingTheme._desktopClockEnabled
                    }

                    // --- إعدادات تأثير العمق ---
                    Rectangle {
                        // فاصل بصري
                        Layout.fillWidth: true
                        Layout.columnSpan: 2 // اجعل الفاصل يمتد على العمودين
                        Layout.topMargin: 5
                        Layout.bottomMargin: 5
                        height: 1
                        color: ThemeManager.selectedTheme.colors.topbarFgColorV1.alpha(0.2)
                        enabled: workingTheme._desktopClockEnabled
                    }

                    Label {
                        text: "Enable Depth Effect"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Switch {
                        id: depthEffectSwitch
                        Layout.alignment: Qt.AlignRight
                        checked: workingTheme._desktopClockDepthEffectEnabled
                        onCheckedChanged: workingTheme._desktopClockDepthEffectEnabled = checked
                    }

                    Label {
                        text: "AI Model"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ComboBox {
                        id: modelComboBox
                        Layout.fillWidth: true
                        enabled: depthEffectSwitch.checked

                        model: ["u2net", "isnet-general-use"]

                        currentIndex: workingTheme._desktopClockDepthModel ? model.indexOf(workingTheme._desktopClockDepthModel) : 0

                        onCurrentTextChanged: {
                            workingTheme._desktopClockDepthModel = currentText;
                        }
                    }

                    Label {
                        text: "Alpha Matting"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Switch {
                        id: alphaMattingComboBox
                        Layout.alignment: Qt.AlignRight
                        checked: root.alphaMatting
                        onCheckedChanged: root.alphaMatting = checked
                        enabled: depthEffectSwitch.checked
                    }

                    Label {
                        text: "BG Threshold"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: root.backgroundThreshold
                        onEditingFinished: root.backgroundThreshold = text
                        enabled: alphaMattingComboBox.checked
                    }

                    Label {
                        text: "FG Threshold"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: root.foregroundThreshold
                        onEditingFinished: root.foregroundThreshold = text
                        enabled: alphaMattingComboBox.checked
                    }

                    Label {
                        text: "Erode Size"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: root.erodeSize
                        onEditingFinished: root.erodeSize = text
                        enabled: alphaMattingComboBox.checked
                    }

                    Label {
                        text: "Create Overlay Image"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    MButton {
                        id: createOverlayImageButton
                        Layout.fillWidth: true
                        enabled: depthEffectSwitch.checked
                        text: "Create..."
                        textElide: Text.ElideLeft
                        onClicked: {
                            ThemeManager.createImageOverlay({
                                model: workingTheme._desktopClockDepthModel,
                                alphaMatting: root.alphaMatting,
                                foregroundThreshold: root.foregroundThreshold,
                                backgroundThreshold: root.backgroundThreshold,
                                erodeSize: root.erodeSize
                            });
                        }
                        showTooltip: true
                    }

                    Label {
                        text: "Overlay Image"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    MButton {
                        id: overlayImageButton
                        Layout.fillWidth: true
                        enabled: depthEffectSwitch.checked
                        text: workingTheme._desktopClockDepthOverlayPath || "Select Image..."
                        textElide: Text.ElideLeft
                        onClicked: clockDepthOverlayDialog.open()
                        showTooltip: true
                    }
                }
            }

            M3GroupBox {
                title: "General Appearance"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: 50
                    rowSpacing: 5

                    Label {
                        text: "Enable accent color"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Switch {
                        Layout.alignment: Qt.AlignRight
                        checked: workingTheme._enableAccentColoring
                        onCheckedChanged: workingTheme._enableAccentColoring = checked
                    }

                    Label {
                        text: "Base Corner Radius"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        id: baseRadiusField
                        Layout.fillWidth: true
                        text: workingTheme._baseRadius
                        horizontalAlignment: TextInput.AlignRight

                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: {
                            const newRadius = Number(text);
                            workingTheme._baseRadius = newRadius;
                            workingTheme._elementRadius = newRadius;
                            workingTheme._hyprRounding = newRadius;
                        }
                    }
                }
            }

            M3GroupBox {
                title: "Component Themes"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: 10
                    rowSpacing: 5

                    Label {
                        text: "Plasma color scheme"
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._plasmaColorScheme
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._plasmaColorScheme = text
                    }

                    Label {
                        text: "QT style (e.g., Kvantum)"
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._qtThemeStyle
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._qtThemeStyle = text
                    }

                    Label {
                        text: "Kvantum theme name"
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._kvantumTheme
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._kvantumTheme = text
                    }

                    Label {
                        text: "Konsole profile name"
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._konsoleProfile
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._konsoleProfile = text
                    }

                    Label {
                        text: "GTK theme name"
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._gtkTheme
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._gtkTheme = text
                    }

                    Label {
                        text: "Icon pack name"
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._themeIcons
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._themeIcons = text
                    }
                }
            }

            M3GroupBox {
                title: "Hyprland Settings"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: 10
                    rowSpacing: 5

                    Label {
                        text: "Border Width"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._hyprBorderWidth
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._hyprBorderWidth = Number(text)
                    }

                    Label {
                        text: "Rounding"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._hyprRounding
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._hyprRounding = Number(text)
                    }

                    Label {
                        text: "Active Border"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._hyprActiveBorder
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._hyprActiveBorder = text
                    }

                    Label {
                        text: "Inactive Border"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    EditableField {
                        Layout.fillWidth: true
                        text: workingTheme._hyprInactiveBorder
                        // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                        onEditingFinished: workingTheme._hyprInactiveBorder = text
                    }

                    Label {
                        text: "Drop Shadow"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Switch {
                        Layout.alignment: Qt.AlignLeft
                        checked: workingTheme._hyprDropShadow
                        onCheckedChanged: workingTheme._hyprDropShadow = checked
                    }
                }
            }

            M3GroupBox {
                title: "Dimensions & Spacing"
                Layout.fillWidth: true
                visible: false
                GridLayout {
                    columns: 1
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
                            EditableField {
                                Layout.preferredWidth: 80
                                text: workingTheme[modelData]
                                horizontalAlignment: TextInput.AlignRight
                                // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                                onEditingFinished: workingTheme[modelData] = Number(text)
                            }
                        }
                    }
                }
            }

            M3GroupBox {
                title: "Typography"
                Layout.fillWidth: true
                visible: false
                GridLayout {
                    columns: 1
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
                            EditableField {
                                Layout.preferredWidth: 150
                                text: workingTheme[modelData]
                                horizontalAlignment: TextInput.AlignRight
                                // --- التعديل هنا: من onAccepted إلى onEditingFinished ---
                                onEditingFinished: workingTheme[modelData] = (typeof ThemeManager.selectedTheme[modelData] === "number") ? Number(text) : text
                            }
                        }
                    }
                }
            }

            M3GroupBox {
                id: colorsBox
                title: "Colors & Appearance"
                Layout.fillWidth: true
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
                title: "Apply Changes"
                Layout.fillWidth: true
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    MButton {
                        id: applyBtn
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
