import QtQuick

Item {
    id: root

    property var activeThemeInstance: null
    property string currentThemeName: ""
    signal themeLoaded(var themeInstance)
    property var _themeCache: ({})

    function loadTheme(themeName) {
        console.log(`[ThemeLoader] loadTheme called for: ${themeName}`);

        // ... (Clean Name logic) ...
        let cleanName = themeName.replace(".qml", "");

        // 1. Create Component
        if (!_themeCache[cleanName]) {
            console.log(`[ThemeLoader] Creating component for: ${cleanName}`);
            let path = "root:/themes/variants/" + cleanName + ".qml";
            let component = Qt.createComponent(path);

            if (component.status !== Component.Ready) {
                console.error(`[ThemeLoader] Component Error: ${component.errorString()}`);
                return;
            }
            _themeCache[cleanName] = component;
        }

        // 2. Create Object
        console.log(`[ThemeLoader] Creating Object Instance...`);
        let newInstance = _themeCache[cleanName].createObject(root);

        if (!newInstance) {
            console.error(`[ThemeLoader] CRITICAL: Failed to create object!`);
            return;
        }
        console.log(`[ThemeLoader] Object created successfully. ID: ${newInstance}`);

        // 3. Swap
        let oldTheme = activeThemeInstance;
        activeThemeInstance = newInstance;
        currentThemeName = cleanName;

        if (oldTheme)
            oldTheme.destroy(100);

        // 4. Signal
        console.log(`[ThemeLoader] Emitting themeLoaded signal...`);
        themeLoaded(newInstance);
    }
}
