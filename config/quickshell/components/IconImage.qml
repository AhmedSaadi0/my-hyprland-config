// components/IconImage.qml
import QtQuick
import QtQuick.Controls
import "root:/themes"
import "root:/utils"

Image {
    id: root

    // Default icon size - can be overridden by explicit width/height
    property int iconSize: 24
    property bool useThemeColor: false
    // property color themeColor: ""

    // Handle source changes to apply theme color if needed
    onSourceChanged: {
        if (useThemeColor && themeColor !== "") {
            // For SVG icons, we could potentially colorize them here
            // But for now, we'll rely on the source already being colored
            // or use Image.Colorize effect if needed
        }
    }

    // Ensure we don't get extremely large SVG renderings
    // Use explicit width/height if set, otherwise fall back to iconSize
    width: iconSize
    height: iconSize
    fillMode: Image.PreserveAspectFit
    smooth: true
    asynchronous: true
    cache: false

    // Handle errors gracefully
    onStatusChanged: {
        if (status === Image.Error) {
            console.warn("IconImage: Failed to load icon:", source)
            // Optionally set a fallback icon here
        }
    }
}
