// components/Shadow.qml

import QtQuick
import QtQuick.Effects
import "root:/themes"

MultiEffect {
    property var color: ThemeManager.selectedTheme.colors.shadow.alpha(0.8)
    property var radius: 0
    property var alpha: 0

    shadowEnabled: true
    shadowColor: color
    shadowBlur: 0.6
    shadowOpacity: 0.6
}

// DropShadow {
//     property var alpha: 0.25
//
//     // color: palette.shadow.alpha(alpha)
//     color: ThemeManager.selectedTheme.colors.shadow.alpha(alpha)
//     radius: 5
//     spread: 0
//     samples: 9
//     horizontalOffset: 2
//     verticalOffset: 2
//     cached: true
//     // color: Qt.darker(ThemeManager.selectedTheme.colors.surface, 1.4).alpha(alpha)
//     // radius: 9
//     // spread: 0
//     // samples: 15
//     // enabled: false
//     // visible: false
//     // verticalOffset: 0
//     // horizontalOffset: 4 // Matches CSS horizontal offset (1px)
//     // sourceRect: parent.parent.sourceRect // Optional: control shadow bounds
// }
