// components/Shadow.qml

import QtQuick
import QtQuick.Effects

import Qt5Compat.GraphicalEffects

// MultiEffect {
//
//     property var color: "#55000000"
//     property var radius: 0
//     property var alpha: 0
//
//     shadowEnabled: true
//     shadowBlur: 0.1
//     shadowColor: color
//     shadowHorizontalOffset: 4
//     shadowVerticalOffset: 4
//     shadowOpacity: 0.5
// }

DropShadow {

    property var alpha: 0.25

    color: palette.shadow.alpha(alpha)
    radius: 5
    spread: 0
    samples: 47
    horizontalOffset: 2
    verticalOffset: 2
    cached: true
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
