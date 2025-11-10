import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs
import Qt.labs.platform

import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"
import "root:/components"
import "./audio"

import Quickshell.Services.Pipewire

Controls.ApplicationWindow {
    id: root
    // width: 900
    // height: 1200
    visible: false

    color: Kirigami.Theme.backgroundColor

    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint
    title: "NibrasShellSettings"

    property var workingTheme: root.copyTheme(ThemeManager.selectedTheme)
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

    // function updateWorkingTheme(sourceTheme) {
    //     if (!sourceTheme || !workingTheme)
    //         return;
    //
    //     // مسح الخصائص القديمة (اختياري ولكنه جيد لتجنب بقاء قيم قديمة)
    //     for (const key in workingTheme) {
    //         delete workingTheme[key];
    //     }
    //
    //     // نسخ الخصائص الجديدة إلى الكائن الموجود
    //     for (const key of root.themePropertyKeys) {
    //         if (sourceTheme.hasOwnProperty(key)) {
    //             workingTheme[key] = sourceTheme[key];
    //         }
    //     }
    // }

    // Connections {
    //     target: ThemeManager
    //     function onSelectedThemeUpdated() {
    //         root.updateWorkingTheme(ThemeManager.selectedTheme);
    //     // root.workingThemeChanged();
    //     }
    // }

    NibrasShellShortcut {
        id: openSettingsShortcut
        name: "openSettings"
        onPressed: root.visible = !root.visible
    }

    Component.onCompleted: {
        EventBus.on(Events.OPEN_SETTINGS, function () {
            root.visible = !root.visible;
        });
    }

    FolderDialog {
        id: dynamicWallpaperFolderDialog
        title: "Please choose a wallpapers folder"
        onAccepted: {
            const folderPath = this.folder.toString().replace("file://", "");
            workingTheme._dynamicWallpapersPath = folderPath;
            root._saveTheme(true);
        }
    }

    FileDialog {
        id: staticWallpaperFileDialog
        title: "Please choose a static wallpaper"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp)", "All files (*.*)"]
        onAccepted: {
            const filePath = file.toString().replace("file://", "");
            workingTheme._wallpaper = filePath;
            root._saveTheme(true);
        }
    }

    FontDialog {
        id: fontDialog
        title: "Select a Font"
        modality: Qt.ApplicationModal
        // currentFont.pointSize: 20

        property var targetedFieldName
        property bool updateOnChange: true

        onCurrentFontChanged:
        // if (updateOnChange) {
        //     root.workingTheme[targetedFieldName] = currentFont.family;
        //     root._applyTheme();
        // }
        {}

        onAccepted: {
            // if (!updateOnChange) {
            root.workingTheme[targetedFieldName] = currentFont.family;
            root._applyTheme();
            // }
        }
    }

    ColorDialog {
        id: colorDialog
        property var targetedFieldName

        modality: Qt.ApplicationModal
        title: qsTr("Chose a color")

        onVisibleChanged: {
            if (visible && targetedFieldName) {
                color = root.workingTheme[targetedFieldName];
            }
        }

        onAccepted: {
            root.workingTheme[targetedFieldName] = color;
            root._applyTheme();
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        SidePanel {
            onNavigateTo: index => {
                contentStack.navigateTo(index);
            }
        }

        // -------------------------------------
        // 2. حاوية المحتوى (Content Area)
        // -------------------------------------
        Controls.StackView {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 20
            Layout.bottomMargin: 20
            Layout.rightMargin: 20

            clip: true
            smooth: true

            property int previousIndex: 0
            property int currentIndex: 0

            property var generalAppearancePage
            property var wallpaperSettingsPage
            property var hyprlandSettingsPage
            property var desktopClockPage
            property var integrationSettingsPage
            property var colorsSettingsPage
            property var layoutFontSettingsPage
            property var audioDevicesSettingsPage
            property var monitorsSettingsPage

            Component {
                id: generalAppearanceComp
                GeneralAppearance {
                    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme

                    onSaveThemeAs: function (themeName) {
                        ThemeManager.saveThemeAs(themeName);
                    }
                    onImportTheme: function (selectedFile) {
                        ThemeManager.importThemeFromFile(selectedFile);
                    }
                    onExportTheme: function (selectedFile) {
                        ThemeManager.exportCurrentTheme(selectedFile);
                    }
                    onResetAllSettings: function () {
                        ThemeManager.resetWholeTheme();
                    }
                }
            }

            Component {
                id: wallpaperSettingsComp
                WallpaperSettings {
                    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme

                    onOpenFolderDialog: dynamicWallpaperFolderDialog.open()
                    onOpenFileDialog: staticWallpaperFileDialog.open()
                    onDynamicColoringChanged: {}

                    onResetToDefault: ThemeManager.resetWallpaperSystemSettings()
                    onNextWallpaperClicked: ThemeManager.switchToNextWallpaper()

                    onApplyChanges: root._applyTheme()
                    onSaveChanges: root._saveTheme(true)
                    onCancelChanges: root._cancelChanges()
                }
            }

            Component {
                id: hyprlandSettingsComp
                HyprlandSettings {
                    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme

                    onApplyChanges: {
                        // ThemeManager._setHyprlandConfigurations();
                        root._applyTheme();
                    }

                    onSaveChanges: root._saveTheme(true)
                    onCancelChanges: root._cancelChanges()
                    onResetToDefault: ThemeManager.resetHyprlandSettings()
                }
            }

            Component {
                id: desktopClockPageComp
                DesktopClockSettings {
                    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme
                    isCreatingOverlayImage: ThemeManager.isCreatingOverlayImage

                    onApplyChanges: root._applyTheme()
                    onSaveChanges: root._saveTheme(true)
                    onCancelChanges: root._cancelChanges()
                    onResetToDefault: ThemeManager.resetClockSettings()

                    onOpenFontDialog: {
                        fontDialog.currentFont.family = root.workingTheme._desktopClockFont;
                        fontDialog.targetedFieldName = "_desktopClockFont";
                        fontDialog.open();
                    }

                    onOpenClockColorDialog: {
                        colorDialog.targetedFieldName = "_desktopClockColor";
                        colorDialog.open();
                    }

                    onOpenShadowColorDialog: {
                        colorDialog.targetedFieldName = "_desktopClockSahdowColor";
                        colorDialog.open();
                    }
                    onCreateOverlayImageButtonClicked: ThemeManager.createImageOverlay(data)
                    onClearUnusedCache: ThemeManager.cleardUnusedOverlayImages()
                }
            }

            Component {
                id: integrationSettingsComp
                IntegrationSettings {
                    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme

                    onApplyChanges: root._applyTheme()
                    onSaveChanges: root._saveTheme(true)
                    onCancelChanges: root._cancelChanges()
                    onResetToDefault: {
                        ThemeManager.resetPlasmaSettings();
                        ThemeManager.resetGtkSettings();
                    }
                }
            }

            Component {
                id: colorsSettingsComp
                ColorsSettings {
                    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme

                    onApplyChanges: root._applyTheme()
                    onSaveChanges: root._saveTheme(true)
                    onCancelChanges: root._cancelChanges()
                    onResetToDefault: ThemeManager.resetColorSettings()
                    onOpenColorDialog: function (colorProperty) {
                        colorDialog.targetedFieldName = colorProperty;
                        colorDialog.open();
                    }
                }
            }

            Component {
                id: layoutFontSettingsComp
                LayoutFontSettings {
                    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme

                    onOpenFontDialog: function (propertyName) {
                        fontDialog.targetedFieldName = propertyName;
                        fontDialog.updateOnChange = false;
                        fontDialog.open();
                    }

                    onApplyChanges: root._applyTheme()
                    onSaveChanges: root._saveTheme(true)
                    onCancelChanges: root._cancelChanges()
                    onResetToDefault: {
                        ThemeManager.resetTypographySettings();
                        ThemeManager.resetDimensionSettings();
                    }
                }
            }

            Component {
                id: audioDevicesSettingsComp
                AudioDevices {
                    //    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme
                }
            }

            Component {
                id: monitorsSettingsComp
                MonitorsSettings {
                    workingTheme: root.workingTheme
                    selectedTheme: ThemeManager.selectedTheme
                }
            }

            function getPage(index) {
                return [wallpaperSettingsPage, colorsSettingsPage, layoutFontSettingsPage, desktopClockPage, hyprlandSettingsPage, integrationSettingsPage, audioDevicesSettingsPage, monitorsSettingsPage][index];
            }

            Component.onCompleted: {
                // generalAppearancePage = generalAppearanceComp.createObject(contentStack, {
                //     "visible": false
                //     // "anchors.fill": stackView
                // });
                wallpaperSettingsPage = wallpaperSettingsComp.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                hyprlandSettingsPage = hyprlandSettingsComp.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                desktopClockPage = desktopClockPageComp.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                integrationSettingsPage = integrationSettingsComp.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                colorsSettingsPage = colorsSettingsComp.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                layoutFontSettingsPage = layoutFontSettingsComp.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                audioDevicesSettingsPage = audioDevicesSettingsComp.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                monitorsSettingsPage = monitorsSettingsComp.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                push(wallpaperSettingsPage);
            }

            function navigateTo(newIndex) {
                if (newIndex === currentIndex)
                    return;

                previousIndex = currentIndex;

                if (newIndex > currentIndex) {
                    contentStack.replaceEnter = enterFromBottom;
                    contentStack.replaceExit = exitToTop;
                } else {
                    contentStack.replaceEnter = enterFromTop;
                    contentStack.replaceExit = exitToBottom;
                }

                currentIndex = newIndex;
                contentStack.replace(getPage(newIndex));
            }

            // --- تعريف تأثيرات الحركة (Transitions) بالتنسيق الصحيح ---
            Transition {
                id: enterFromBottom
                SequentialAnimation {
                    PropertyAction {
                        property: "opacity"
                        value: 0
                    }
                    PropertyAction {
                        property: "scale"
                        value: 0.92
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            property: "y"
                            from: contentStack.height * 0.6
                            to: 0
                            duration: 420
                            easing.type: Easing.OutBack
                        }
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 350
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.92
                            to: 1.0
                            duration: 380
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            Transition {
                id: exitToTop
                ParallelAnimation {
                    NumberAnimation {
                        property: "y"
                        from: 0
                        to: -contentStack.height * 0.3
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 280
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 1.0
                        to: 0.95
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                }
            }

            Transition {
                id: enterFromTop
                SequentialAnimation {
                    PropertyAction {
                        property: "opacity"
                        value: 0
                    }
                    PropertyAction {
                        property: "scale"
                        value: 0.92
                    }
                    PropertyAction {
                        property: "y"
                        value: -contentStack.height * 0.3
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            property: "y"
                            from: -contentStack.height * 0.3
                            to: 0
                            duration: 420
                            easing.type: Easing.OutBack
                        }
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 350
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.92
                            to: 1.0
                            duration: 380
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            Transition {
                id: exitToBottom
                ParallelAnimation {
                    NumberAnimation {
                        property: "y"
                        from: 0
                        to: contentStack.height * 0.6
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 280
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 1.0
                        to: 0.95
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                }
            }
        }
    }

    function _applyTheme() {
        if (!ThemeManager._isThemeLoading) {
            ThemeManager.updateAndApplyTheme(workingTheme, false);
        }
    }

    function _saveTheme(notifySaving = false) {
        if (!ThemeManager._isThemeLoading) {
            ThemeManager.updateAndApplyTheme(workingTheme, true, notifySaving);
            root.visible = false;
        }
    }

    function _cancelChanges() {
        ThemeManager.reloadTheme();
        root.visible = false;
    }
}
