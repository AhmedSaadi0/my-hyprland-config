pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "root:/utils" as Utils
import "root:/config"

Singleton {
    id: root

    signal selectedThemeUpdated

    property bool _isThemeLoading: false
    property bool _initialThemeIsReady: false
    property bool isCreatingOverlayImage: false
    property var _activeThemeInstance: null
    property string _currentThemeFile: ""
    property var _originalThemeCache: ({})
    property var wallpapersList: []
    property bool _initialLoadComplete: false

    readonly property alias selectedTheme: root._activeThemeInstance
    // readonly property string targetedCacheThemeFile: App.themeCacheFolderPath + `/${selectedTheme.themeName}.json`
    readonly property string targetedCacheThemeFile: App.themeCacheFolderPath + `/${_currentThemeFile}.json`

    readonly property var _colorPropertyKeys: ["themeName", "_primary", "_secondary", "_onPrimary", "_onSecondary", "_topbarColor", "_topbarFgColor", "_topbarBgColorV1", "_topbarBgColorV2", "_topbarBgColorV2", "_topbarBgColorV2", "_topbarBgColorV3", "_topbarFgColorV1", "_topbarFgColorV2", "_topbarFgColorV3", "_leftMenuBgColorV1", "_leftMenuBgColorV2", "_leftMenuBgColorV3", "_leftMenuFgColorV1", "_leftMenuFgColorV2", "_leftMenuFgColorV3", "_subtleTextColor", "_volOsdBgColor", "_volOsdFgColor",]
    readonly property var _dimensionPropertyKeys: ["_baseRadius", "_barHeight", "_barBottomMargin", "_barWidgetsHeight", "_menuHeight", "_menuWidth", "_menuWidgetsMargin", "_elementRadius", "_spacingSmall", "_spacingMedium", "_spacingLarge"]
    readonly property var _typographyPropertyKeys: ["_iconFont", "_bodyFont", "_baseFontSize", "_heading1Size", "_heading2Size", "_heading2Size", "_heading3Size", "_heading4Size", "_mediumFontSize", "_smallFontSize"]
    // readonly property var _hyprlandPropertyKeys: ["_hyprBorderWidth", "_hyprActiveBorder", "_hyprInactiveBorder", "_hyprRounding", "_hyprDropShadow"]
    readonly property var _hyprlandPropertyKeys: [
        // Decoration
        "_hyprBorderWidth", "_hyprActiveBorder", "_hyprInactiveBorder", "_hyprRounding", "_hyprDropShadow",
        // Gaps & Layout
        "_hyprGapsIn", "_hyprGapsOut", "_hyprLayout",
        // Animations
        "_hyprAnimationsEnabled", "_hyprBezier", "_hyprAnimWindows", "_hyprAnimWorkspaces",
        // Visual Effects
        "_hyprBlurEnabled", "_hyprBlurSize", "_hyprBlurPasses", "_hyprDimInactive", "_hyprDimStrength",
        // Shadow Enhancements
        "_hyprShadowRange", "_hyprShadowOffset", "_hyprShadowColor"]
    readonly property var _wallpaperSystemPropertyKeys: ["_enableDynamicColoring", "_enableDynamicWallpapers", "_dynamicWallpapersInterval", "_dynamicWallpapersPath", "_selectedWallpaperIndex", "_wallpaper"]
    readonly property var _plasmaPropertyKeys: ["_qtThemeStyle", "_kvantumTheme", "_plasmaColorScheme", "_konsoleProfile", "_enableAccentColoring"]
    readonly property var _gtkPropertyKeys: ["_gtkTheme", "_themeIcons", "_themeMode"]
    readonly property var _desktopClockPropertyKeys: ["_desktopClockLocal", "_desktopClockFont", "_desktopClockEnabled", "_desktopClockColor", "_desktopClockFormat", "_desktopClockPosition", "_desktopClockDepthEffectEnabled", "_desktopClockDepthModel", "_desktopClockDepthOverlayPath", "_desktopClockSize", "_desktopClockSahdowColor", "_desktopClockSahdowEnabled", "_desktopClockUseThemeColor", "_desktopClockUseAnimation"]
    readonly property var _allSerializableKeys: _colorPropertyKeys.concat(_dimensionPropertyKeys).concat(_typographyPropertyKeys).concat(_hyprlandPropertyKeys).concat(_desktopClockPropertyKeys).concat(_wallpaperSystemPropertyKeys).concat(_plasmaPropertyKeys).concat(_gtkPropertyKeys)

    signal initialThemeReady

    Component.onCompleted: {
        console.info("Application starting. Loading last session...");
        // _activeThemeInstance = ColorsTheme;
        startUpTimer.start();
    }

    //================================================================
    // Public API
    //================================================================

    function requestLoadTheme(themeFile, reload = false) {
        if (_isThemeLoading) {
            console.warn(`Request to load '${themeFile}' ignored: a theme is already being loaded.`);
            return;
        }

        if (_currentThemeFile === themeFile && _activeThemeInstance && !reload) {
            console.log("Theme already loaded:", themeFile);
            return;
        }

        console.log("Starting to load theme:", themeFile);
        _isThemeLoading = true;

        _stopRunningAllProcess();
        _performLoadAndApply(themeFile);
    }

    function reloadTheme() {
        _stopRunningAllProcess();
        requestLoadTheme(_currentThemeFile, true);
    }

    function updateAndApplyTheme(modifiedThemeData, saveTheme, notifySaving = false) {
        if (!selectedTheme || !modifiedThemeData) {
            console.error("Cannot update theme: invalid data received.");
            return;
        }

        const preserveColorBindings = modifiedThemeData._enableDynamicColoring;
        console.info("Updating live theme. Preserving reactive color bindings:", preserveColorBindings);

        for (const key in modifiedThemeData) {
            if (root.selectedTheme.hasOwnProperty(key)) {
                if (preserveColorBindings && _colorPropertyKeys.includes(key)) {
                    continue;
                }
                root.selectedTheme[key] = modifiedThemeData[key];
            }
        }

        _applyExternalSettings(saveTheme, notifySaving);
    }

    function exportCurrentTheme(destinationPath) {
        console.log(`Exporting current theme '${selectedTheme.themeName}' to '${destinationPath}'`);

        _cacheAppliedData(false);

        const sourcePath = targetedCacheThemeFile;
        _dispatchCommand("Exporting Theme", Utils.Helper.copyFile(sourcePath, destinationPath));

        App.dispatchCommand("send notification", Utils.Helper.sendNotification({
            summary: "Theme Exported",
            body: `'${selectedTheme.themeName}' has been exported successfully.`
        }));
    }

    function importThemeFromFile(sourcePath) {
        // const themeName = sourcePath.substring(sourcePath.lastIndexOf('/') + 1, sourcePath.lastIndexOf('.'));
        const destinationPath = targetedCacheThemeFile;
        _dispatchCommand("Importing Theme", Utils.Helper.copyFile(sourcePath, destinationPath));
        reloadTheme();
    // requestLoadTheme(destinationPath, true);
    }

    function saveThemeAs(newName) {
        if (!newName || newName.trim() === "") {
            console.error("Save As failed: New name cannot be empty.");
            return;
        }

        console.log(`Saving current theme as '${newName}'`);
        selectedTheme.themeName = newName.trim();

        _cacheAppliedData(true);
    }

    function switchToNextWallpaper() {
        if (!selectedTheme.systemSettings.enableDynamicWallpapers || wallpapersList.length <= 1) {
            console.info("Cannot switch wallpaper: Dynamic wallpapers are not enabled or list is too short.");
            return;
        }
        console.info("Switching to the next wallpaper manually.");
        wallpaperTimer.triggered();
        wallpaperTimer.restart();
    }

    function resetColorSettings() {
        console.info("Resetting color settings to default.");
        _resetPropertiesToDefault(_colorPropertyKeys);
    }

    function resetWallpaperSystemSettings() {
        console.info("Resetting wallpaper system settings to default.");
        _resetPropertiesToDefault(_wallpaperSystemPropertyKeys);
    }

    function resetHyprlandSettings() {
        console.info("Resetting Hyprland settings to default.");
        _resetPropertiesToDefault(_hyprlandPropertyKeys);
    }

    function resetPlasmaSettings() {
        console.info("Resetting Plasma settings to default.");
        _resetPropertiesToDefault(_plasmaPropertyKeys);
    }

    function resetGtkSettings() {
        console.info("Resetting GTK settings to default.");
        _resetPropertiesToDefault(_gtkPropertyKeys);
    }

    function resetClockSettings() {
        console.info("Resetting Desktop Clock settings to default.");
        _resetPropertiesToDefault(_desktopClockPropertyKeys);
    }

    function resetDimensionSettings() {
        console.info("Resetting Desktop Clock settings to default.");
        _resetPropertiesToDefault(_dimensionPropertyKeys);
    }

    function resetTypographySettings() {
        console.info("Resetting Desktop Clock settings to default.");
        _resetPropertiesToDefault(_typographyPropertyKeys);
    }

    function resetWholeTheme() {
        resetColorSettings();
        resetWallpaperSystemSettings();
        resetHyprlandSettings();
        resetPlasmaSettings();
        resetGtkSettings();
        resetClockSettings();
        resetDimensionSettings();
        resetTypographySettings();
    }

    function createImageOverlay(options) {
        const settings = selectedTheme.systemSettings;
        const cacheFolderPath = App.cacheFolderPath;
        const cachedImageName = Utils.Helper.generateRandomString(10);
        const newImagePath = `${cacheFolderPath}/${cachedImageName}.png`;

        let currentIndex = settings.selectedWallpaperIndex;
        const dynamicWallpaper = wallpapersList[currentIndex];
        const wallpaper = settings.enableDynamicWallpapers ? dynamicWallpaper : settings.wallpaper;

        const commandOptions = {
            wallpaperPath: wallpaper,
            outputPath: newImagePath,
            model: options.model || "u2net",
            alphaMatting: options.alphaMatting || false,
            foregroundThreshold: options.foregroundThreshold || 240,
            backgroundThreshold: options.backgroundThreshold || 10,
            erodeSize: options.erodeSize || 10
        };

        createOverlayImageProcess.command = Utils.Helper.createImageOverlayRembg(commandOptions);
        createOverlayImageProcess.start(newImagePath);
    }

    //================================================================
    // Internal State Machine & Logic
    //================================================================

    function _performLoadAndApply(themeFile) {
        if (!_originalThemeCache[themeFile]) {
            const component = Qt.createComponent(`${themeFile}.qml`);
            if (component.status !== Component.Ready) {
                console.error("Failed to load theme component:", component.errorString());
                if (component)
                    component.destroy();
                _finalizeThemeLoad(false);
                return;
            }
            _originalThemeCache[themeFile] = component;
        }
        const cachedComponent = _originalThemeCache[themeFile];
        const newThemeInstance = cachedComponent.createObject(root);

        if (!newThemeInstance) {
            console.error("Failed to create theme object from cached component:", themeFile);
            _finalizeThemeLoad(false);
            return;
        }

        const oldThemeInstance = root._activeThemeInstance;
        root._activeThemeInstance = newThemeInstance;
        root._currentThemeFile = themeFile;

        if (oldThemeInstance) {
            if (themeDestroyerTimer.running) {
                themeDestroyerTimer.triggered();
                themeDestroyerTimer.stop();
            }
            themeDestroyerTimer.themeToDestroy = oldThemeInstance;
            themeDestroyerTimer.start();
        }

        sessionSaver.setText(JSON.stringify({
            activeThemeName: themeFile
        }));

        cacheThemeFile.path = App.themeCacheFolderPath + `${themeFile}.json`;
        cacheThemeFile.reload();
    }

    function _onCacheLoaded(text) {
        let data = {};
        try {
            data = JSON.parse(text);
        } catch (e) {
            console.error("Failed to parse cache file, applying default values.", e);
        }

        updateAndApplyTheme(data, true);
        _finalizeThemeLoad(true);
    }

    function _finalizeThemeLoad(success) {
        if (success) {
            console.info("Theme loading process completed successfully for:", root._currentThemeFile);
            _initialLoadComplete = true;
            if (!_initialThemeIsReady) {
                console.log(">>>> Initial theme is now ready! Notifying the shell. <<<<");
                _initialThemeIsReady = true;
                initialThemeReady();
            }
        } else {
            console.error("Theme loading process failed.");
        }
        _isThemeLoading = false;
    }

    function _applyExternalSettings(saveTheme, notifySaving = false) {
        if (!root.selectedTheme)
            return;

        console.info("Applying external settings for:", root.selectedTheme.themeName);
        const settings = root.selectedTheme.systemSettings;

        wallpaperTimer.stop();
        getWallpapersList.running = false;

        if (settings.enableDynamicWallpapers) {
            getWallpapersList.command = Utils.Helper.getWallpapersList(settings.dynamicWallpapersPath);
            getWallpapersList.running = true;
        } else {
            _applyStaticTheme(settings);
        }

        if (saveTheme) {
            sendChangedSignalTimer.notifySaving = notifySaving;
            sendChangedSignalTimer.start();
        }

        if (!settings.enableDynamicColoring && settings.enableAccentColoring) {
            applyAccentColorTimer.start();
        }
    }

    function _applyCoreThemeSettings(settings, wallpaperPath) {
        _changeWallpaper(wallpaperPath);
        _applyDynamicColoring(wallpaperPath, settings);
        _changeQtTheme(settings);
        _changeGtkTheme(settings);
        _changeGtk4Theme(settings);
        _setHyprlandConfigurations();
    }

    function _applyStaticTheme(settings) {
        _applyCoreThemeSettings(settings, settings.wallpaper);
    }

    function _applyDynamicWallpaper() {
        const settings = selectedTheme.systemSettings;
        let currentIndex = settings.selectedWallpaperIndex;

        if (currentIndex >= wallpapersList.length && wallpapersList.length !== 0) {
            currentIndex = 0;
            selectedTheme._selectedWallpaperIndex = 0;
        }

        const selectedWallpaper = wallpapersList[currentIndex];
        _applyCoreThemeSettings(settings, selectedWallpaper);

        wallpaperTimer.running = settings.enableDynamicWallpapers || settings.enableDynamicColoring;
    }

    function _applyDynamicColoring(selectedWallpaper, settings) {
        if (settings.enableDynamicColoring) {
            _dispatchCommand("Apply M3 Theming", Utils.Helper.applyM3PlasmaColor(selectedWallpaper, settings.themeMode));
        }
    }

    function _dispatchCommand(description, commandArray) {
        App.dispatchCommand(description, commandArray);
    }

    function _changeWallpaper(path) {
        _dispatchCommand("Changing Wallpaper", Utils.Helper.changeWallpaper(path));
    }

    function _setHyprlandConfigurations() {
        const cfg = root.selectedTheme.hyprlandConfiguration;
        console.info("Applying Hyprland configurations (individual command strategy)...");

        // دالة مساعدة لتنفيذ أمر واحد بعد تنظيفه وطباعته للسجل
        function dispatchCommand(key, value) {
            // قم بتنظيف القيمة وإضافة علامات الاقتباس فقط إذا كانت القيمة تحتوي على مسافات أو فواصل
            let finalValue = String(value).trim();
            const needsQuotes = finalValue.includes(' ') || finalValue.includes(',');

            if (needsQuotes) {
                finalValue = `'${finalValue}'`;
            }

            const command = `exec hyprctl keyword ${key} ${finalValue}`;

            // سجل الأمر النهائي قبل إرساله. هذا مهم جدًا للتصحيح.
            console.log("Dispatching Hyprland Command:", command);
            Hyprland.dispatch(command);
        }

        // --- إرسال جميع الأوامر بشكل فردي ومنظم ---

        // General
        dispatchCommand('general:gaps_in', cfg.gapsIn);
        dispatchCommand('general:gaps_out', cfg.gapsOut);
        dispatchCommand('general:border_size', cfg.borderWidth);
        dispatchCommand('general:col.active_border', cfg.activeBorder);
        dispatchCommand('general:col.inactive_border', cfg.inactiveBorder);
        dispatchCommand('general:layout', cfg.layout);

        // Decoration
        dispatchCommand('decoration:rounding', cfg.rounding);

        // dispatchCommand('decoration:shadow:enabled', cfg.dropShadow);
        // dispatchCommand('decoration:shadow:range', cfg.shadowRange);
        // dispatchCommand('decoration:shadow:offset', `${cfg.shadowOffset.x} ${cfg.shadowOffset.y}`);
        // dispatchCommand('decoration:shadow:color', cfg.shadowColor);

        dispatchCommand('decoration:dim_inactive', cfg.dimInactive ? "yes" : "no");
        dispatchCommand('decoration:dim_strength', cfg.dimStrength);

        // Blur
        dispatchCommand('decoration:blur:enabled', cfg.blurEnabled ? "yes" : "no");
        dispatchCommand('decoration:blur:size', cfg.blurSize);
        dispatchCommand('decoration:blur:passes', cfg.blurPasses);

        // Animations (يتم إرسالها بالترتيب الصحيح)
        dispatchCommand('animations:enabled', cfg.animationsEnabled ? "yes" : "no");

        // يتم إرسال كل سطر من Bezier كأمر منفصل
        cfg.bezier.trim().split('\n').forEach(line => {
            if (line.trim()) {
                dispatchCommand('animations:bezier', line.trim());
            }
        });

        // يتم إرسال كل قاعدة animation كأمر منفصل، وهذا يمنع الكتابة فوقها
        if (cfg.animWindows.trim()) {
            dispatchCommand('animations:animation', `windows, ${cfg.animWindows.trim()}`);
        }
        if (cfg.animWorkspaces.trim()) {
            dispatchCommand('animations:animation', `workspaces, ${cfg.animWorkspaces.trim()}`);
        }

        console.info("Hyprland configurations application process finished.");
    }

    // function _setHyprlandConfigurations() {
    //     const cfg = root.selectedTheme.hyprlandConfiguration;
    //     const keywords = [[`general:border_size`, cfg.borderWidth], [`general:col.active_border`, `'${cfg.activeBorder}'`], [`general:col.inactive_border`, `'${cfg.inactiveBorder}'`], [`decoration:rounding`, cfg.rounding], [`decoration:drop_shadow`, cfg.dropShadow ? "yes" : "no"]];
    //
    //     for (const [key, value] of keywords) {
    //         Hyprland.dispatch(`exec hyprctl keyword ${key} ${value}`);
    //     }
    // }

    function _changeQtTheme(settings) {
        _dispatchCommand("Plasma Color", Utils.Helper.changePlasmaColor(settings.plasmaColorScheme));
        _dispatchCommand("Plasma Icons", Utils.Helper.changePlasmaIcons(settings.themeIcons));
        _dispatchCommand("Konsole Profile", Utils.Helper.changeKonsoleProfile(settings.konsoleProfile));
        _dispatchCommand("Qt Style", Utils.Helper.changeQtStyle(settings.qtThemeStyle));
        _dispatchCommand("Kvantum Theme", Utils.Helper.changeKvantumTheme(settings.kvantumTheme));
    }

    function _changeGtkTheme(settings) {
        const fontSize = root.selectedTheme.typography.baseFontSize;
        _dispatchCommand("GTK Theme", Utils.Helper.changeGtkTheme(settings.gtkTheme));
        _dispatchCommand("GTK Icons", Utils.Helper.changeGtkIcons(settings.themeIcons));
        _dispatchCommand("GTK Font", Utils.Helper.changeGtkFont(settings.fontName, fontSize));
    }

    function _changeGtk4Theme(settings) {
        _dispatchCommand("GTK 4 Theme", Utils.Helper.removeOldGtk4Theme());
        _dispatchCommand("GTK 4 Theme", Utils.Helper.changeGtk4Theme(settings.gtkTheme));
    }

    function _applyAccentColor() {
        const accentColor = selectedTheme.colors.primary;
        _dispatchCommand("Plasma Accent Color", Utils.Helper.changePlasmaAccentColor(accentColor));
    }

    function _resetPropertiesToDefault(keysToReset) {
        if (!_currentThemeFile || !_originalThemeCache[_currentThemeFile]) {
            console.error("Cannot reset properties: The original theme component is not cached.");
            return;
        }

        const cachedComponent = _originalThemeCache[_currentThemeFile];
        const defaultThemeObject = cachedComponent.createObject();

        if (!defaultThemeObject) {
            console.error("Failed to create temporary theme object for reset.");
            return;
        }

        let modifiedData = {};
        for (const key of keysToReset) {
            if (root.selectedTheme.hasOwnProperty(key) && defaultThemeObject.hasOwnProperty(key)) {
                const defaultValue = defaultThemeObject[key];
                root.selectedTheme[key] = defaultValue;
                modifiedData[key] = defaultValue;
            }
        }

        defaultThemeObject.destroy();
        updateAndApplyTheme(modifiedData, true);
    }

    function _cacheAppliedData(notifySaving = false) {
        let dataToSave = {};
        for (const key of _allSerializableKeys) {
            if (root.selectedTheme.hasOwnProperty(key)) {
                dataToSave[key] = root.selectedTheme[key];
            }
        }
        cacheThemeFile.setText(JSON.stringify(dataToSave, null, 2));
        const message = `Data for '${selectedTheme.themeName}' saved to ${cacheThemeFile.path}`;

        console.info(message);

        root.selectedThemeUpdated();

        if (notifySaving) {
            App.dispatchCommand("send notification", Utils.Helper.sendNotification({
                summary: "Theme saved successfully",
                body: message
            }));
            App.dispatchCommand("play sound", Utils.Helper.playSoundCommand(App.assets.audio.notificationAlert));
        }
    }

    function _stopRunningAllProcess() {
        getWallpapersList.running = false;
        wallpaperTimer.stop();
        applyAccentColorTimer.stop();
        startUpTimer.stop();
        sendChangedSignalTimer.stop();
    }

    function cleardUnusedOverlayImages() {
        const jsonDir = App.themeCacheFolderPath;
        const imagesDir = App.cacheFolderPath;

        removeUnusedCachedOverlayImagesProcess.command = Utils.Helper.removeUnusedCachedOverlayImages({
            jsonDir: jsonDir,
            imagesDir: imagesDir
        });
        removeUnusedCachedOverlayImagesProcess.start();
    }

    //================================================================
    // Child Components & Workers
    //================================================================
    FileView {
        id: sessionLoader
        onLoaded: {
            try {
                const session = JSON.parse(this.text());
                root.requestLoadTheme(session.activeThemeName || "ColorsTheme");
            } catch (e) {
                console.error("Failed to parse session file, loading default theme.", e);
                root.requestLoadTheme("ColorsTheme");
            }
        }
        onLoadFailed: {
            console.info("Session file not found. Starting with default theme.");
            root.requestLoadTheme("ColorsTheme");
        }
    }

    FileView {
        id: sessionSaver
        path: App.themeCacheFilePath
    }

    FileView {
        id: cacheThemeFile
        watchChanges: false
        onLoaded: {
            if (root._isThemeLoading) {
                _onCacheLoaded(this.text());
            } else {
                console.warn("Ignoring stale cache load for:", this.path);
            }
        }
        onLoadFailed: {
            if (root._isThemeLoading) {
                console.info("Cache file not found. Applying default values.");
                _onCacheLoaded("{}");
            } else {
                console.warn("Ignoring stale cache load failure for:", this.path);
            }
        }
    }

    Process {
        id: getWallpapersList
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.wallpapersList = JSON.parse(this.text);
                    root._applyDynamicWallpaper();
                } catch (e) {
                    console.error("Failed to parse wallpapers list:", e);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("Error getting wallpaper list:", data)
        }
    }

    Process {
        id: createOverlayImageProcess
        property string newImagePath
        stdout: StdioCollector {
            onStreamFinished: {
                App.dispatchCommand("send notification", Utils.Helper.sendNotification({
                    summary: "Image created",
                    body: `Overlay image created successfully in: ${createOverlayImageProcess.newImagePath}`
                }));
                App.dispatchCommand("play sound", Utils.Helper.playSoundCommand(App.assets.audio.notificationAlert));
                selectedTheme._desktopClockDepthOverlayPath = createOverlayImageProcess.newImagePath;
                _cacheAppliedData();

                root.isCreatingOverlayImage = false;
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("Error creating wallpaper overlay:", data)
        }

        function start(imagePath) {
            this.newImagePath = imagePath;
            this.running = true;
            root.isCreatingOverlayImage = true;
        }
    }

    Process {
        id: removeUnusedCachedOverlayImagesProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    // console.info(this.text);
                    App.dispatchCommand("send notification", Utils.Helper.sendNotification({
                        summary: "Cached Images Deleted",
                        body: this.text.trim()
                    }));
                    App.dispatchCommand("play sound", Utils.Helper.playSoundCommand(App.assets.audio.notificationAlert));
                } catch (e) {
                    console.error("Failed to parse wallpapers list:", e);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("Error getting wallpaper list:", data)
        }

        function start(imagePath) {
            this.running = true;
        }
    }

    Timer {
        id: wallpaperTimer
        repeat: true
        running: false
        interval: root.selectedTheme?.systemSettings?.dynamicWallpapersInterval || 60000
        onTriggered: {
            root.selectedTheme._selectedWallpaperIndex++;
            root._applyDynamicWallpaper();
            sendChangedSignalTimer.start();
        }
    }

    Timer {
        id: applyAccentColorTimer
        interval: 2000
        repeat: false
        onTriggered: {
            root._applyAccentColor();
            root._applyAccentColor();
        }
    }

    Timer {
        id: startUpTimer
        interval: 1000
        repeat: false
        onTriggered: sessionLoader.path = App.themeCacheFilePath
    }

    Timer {
        id: sendChangedSignalTimer
        interval: 1000
        repeat: false

        property bool notifySaving: false

        onTriggered: {
            root._cacheAppliedData(notifySaving);
            notifySaving = false;
        }
    }

    Timer {
        id: themeDestroyerTimer
        interval: 1000
        repeat: false
        property var themeToDestroy: null
        onTriggered: {
            if (themeToDestroy) {
                console.info(`(Delayed) Destroying old theme instance '${themeToDestroy.themeName}'.`);
                themeToDestroy.destroy();
                themeToDestroy = null;
            }
        }
    }
}
