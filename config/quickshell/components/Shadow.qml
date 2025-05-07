import QtQuick
import Qt5Compat.GraphicalEffects

DropShadow {
    color: palette.shadow.alpha(0.2)
    radius: 9
    spread: 0
    samples: 15
    // verticalOffset: 0
    // horizontalOffset: 4 // Matches CSS horizontal offset (1px)
    // sourceRect: parent.parent.sourceRect // Optional: control shadow bounds
}
