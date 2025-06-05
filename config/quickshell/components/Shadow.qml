import QtQuick
import Qt5Compat.GraphicalEffects

DropShadow {

    property var alpha: 0.25

    color: palette.shadow.alpha(alpha)
    radius: 5       // Reduced for sharper results
    spread: 0
    samples: 8      // Balanced quality/performance
    horizontalOffset: 2
    verticalOffset: 2

    // color: palette.shadow.alpha(alpha)
    // radius: 9
    // spread: 0
    // samples: 15
    // enabled: false
    // visible: false
    // verticalOffset: 0
    // horizontalOffset: 4 // Matches CSS horizontal offset (1px)
    // sourceRect: parent.parent.sourceRect // Optional: control shadow bounds
}
