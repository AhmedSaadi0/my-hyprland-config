import QtQuick
import Quickshell.Io
import "root:/utils" as Utils
import "root:/themes" as Theme
import "root:/config"

Item {
    id: root

    // =========================================================
    // API
    // =========================================================
    property string currentWallpaperPath: ""
    signal wallpaperReady(string path)

    // =========================================================
    // Configuration
    // =========================================================
    property bool dynamicEnabled: false
    property string dynamicPath: ""
    property int interval: 60000
    property var wallpapersList: []
    property int currentIndex: 0
    property bool isLoading: false

    function configure(settings) {
        // 1. تنظيف الحالة القديمة
        wallpaperTimer.stop();
        getWallpapersListProcess.running = false;

        root.dynamicEnabled = settings.enableDynamicWallpapers;
        root.dynamicPath = settings.dynamicWallpapersPath;
        root.interval = settings.dynamicWallpapersInterval || 60000;
        root.wallpapersList = [];

        let initialWall = settings.wallpaper || "";
        let resolvedPath = _resolvePath(initialWall);

        if (root.dynamicEnabled) {
            root.isLoading = true;
            root.currentIndex = settings.selectedWallpaperIndex || 0;

            // تعيين مؤقت لمنع الومضات
            root.currentWallpaperPath = resolvedPath;
            // بدء جلب القائمة
            getWallpapersListProcess.command = Utils.Helper.getWallpapersList(root.dynamicPath);
            getWallpapersListProcess.running = true;
        } else {
            // الحالة الثابتة (Static)
            root.isLoading = false;
            root.currentWallpaperPath = resolvedPath;
            if (resolvedPath !== "") {
                console.info("WallpaperController: Static wallpaper ready ->", resolvedPath);
                wallpaperReady(resolvedPath);
            }
        }
    }

    function nextWallpaper() {
        if (!root.dynamicEnabled || root.wallpapersList.length === 0)
            return;

        root.currentIndex++;
        if (root.currentIndex >= root.wallpapersList.length) {
            root.currentIndex = 0;
        }

        // المسار من القائمة يكون كاملاً عادةً (لأن السكربت يرجعه كذلك)
        let path = root.wallpapersList[root.currentIndex];
        root.currentWallpaperPath = path;

        wallpaperReady(path);

        Theme.ThemeManager.updateAndApplyTheme({
            "_selectedWallpaperIndex": root.currentIndex
        }, true);
    }

    function _resolvePath(path) {
        if (!path || path === "")
            return "";
        // إذا كان يحتوي على / فهو مسار كامل، وإلا فهو في الـ assets
        if (path.indexOf("/") === -1) {
            return App.assets.getWallpaperPath(path);
        }
        return path;
    }

    // =========================================================
    // Processes
    // =========================================================
    Process {
        id: getWallpapersListProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var list = JSON.parse(this.text);
                    if (list.length === 0) {
                        console.warn("WallpaperController: Empty list.");
                        root.isLoading = false;
                        root.wallpaperReady(root.currentWallpaperPath);
                        return;
                    }
                    root.wallpapersList = list;

                    if (root.currentIndex >= list.length)
                        root.currentIndex = 0;

                    let firstPath = list[root.currentIndex];
                    root.currentWallpaperPath = firstPath;

                    // الآن فقط نطلق الإشارة للديناميك
                    console.info("WallpaperController: Dynamic wallpaper ready ->", firstPath);
                    root.wallpaperReady(firstPath);

                    wallpaperTimer.interval = root.interval;
                    wallpaperTimer.start();
                    root.isLoading = false;
                } catch (e) {
                    console.error("WallpaperController Error:", e);
                    root.isLoading = false;
                }
            }
        }
    }

    Timer {
        id: wallpaperTimer
        repeat: true
        onTriggered: root.nextWallpaper()
    }
}
