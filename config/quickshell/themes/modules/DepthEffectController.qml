// themes/modules/DepthEffectController.qml

import QtQuick
import Quickshell
import Quickshell.Io
import "root:/config"
import "root:/utils" as Utils

QtObject {
    id: root

    property var activeThemeInstance: null
    property string currentThemeName: ""

    signal creatingOverlayImageStarted
    signal creatingOverlayImageFinished(string newImagePath)

    function createOverlayImage({
        wallpaper,
        outputPath,
        model = "u2net",
        alphaMatting = false,
        foregroundThreshold = 240,
        backgroundThreshold = 10,
        erodeSize = 10
    }) {
        const cacheFolderPath = App.cacheFolderPath;
        const cachedImageName = Utils.Helper.generateRandomString(10);
        const newImagePath = `${cacheFolderPath}/${cachedImageName}.png`;

        const commandOptions = {
            wallpaperPath: wallpaper,
            outputPath: newImagePath,
            model: model || "u2net",
            alphaMatting: alphaMatting || false,
            foregroundThreshold: foregroundThreshold || 240,
            backgroundThreshold: backgroundThreshold || 10,
            erodeSize: erodeSize || 10
        };

        createOverlayImageProcess.command = Utils.Helper.createImageOverlayRembg(commandOptions);
        createOverlayImageProcess.start(newImagePath);
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

    property var createOverlayImageProcess: Process {
        // id: createOverlayImageProcess
        property string newImagePath
        stdout: StdioCollector {
            onStreamFinished: {
                App.dispatchCommand("send notification", Utils.Helper.sendNotification({
                    summary: "Image created",
                    body: `Overlay image created successfully in: ${createOverlayImageProcess.newImagePath}`
                }));
                App.dispatchCommand("play sound", Utils.Helper.playSoundCommand(App.assets.audio.notificationAlert));
                // selectedTheme._desktopClockDepthOverlayPath = createOverlayImageProcess.newImagePath;
                // _cacheAppliedData();

                root.creatingOverlayImageFinished(createOverlayImageProcess.newImagePath);
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("Error creating wallpaper overlay:", data)
        }

        function start(imagePath) {
            this.newImagePath = imagePath;
            this.running = true;
            root.creatingOverlayImageStarted();
        }
    }

    property var removeUnusedCachedOverlayImagesProcess: Process {
        // id: removeUnusedCachedOverlayImagesProcess
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
}
