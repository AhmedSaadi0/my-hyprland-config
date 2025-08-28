import QtQuick
import QtQuick.Window

import "../themes"

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: 0

    // property string boxColor: ThemeManager.selectedTheme.colors.topbarColor

    property int cornerWidth: 20
    property int cornerHeight: 20

    property bool topLeftVisible: true
    property bool topRightVisible: true
    property bool bottomLeftVisible: true
    property bool bottomRightVisible: true

    Rectangle {
        id: centerBox
        color: ThemeManager.selectedTheme.colors.topbarColor
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            // left: bottomLeftBarCorner.right
            right: bottomRightBarCorner.left
        }
    }

    BarCorner {
        id: bottomRightBarCorner
        width: root.cornerWidth
        height: root.cornerHeight
        visible: root.bottomLeftVisible
        anchors {
            // top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        position: "bottom-left"
        shapeColor: ThemeManager.selectedTheme.colors.topbarColor
        // rotation: 180
    }

    BarCorner {
        id: topRightBarCorner
        width: root.cornerWidth
        height: root.cornerHeight
        visible: root.topLeftVisible
        anchors {
            top: parent.top
            right: parent.right
            // bottom: parent.bottom
        }
        position: "top-left"
        shapeColor: ThemeManager.selectedTheme.colors.topbarColor
        // rotation: 270
    }

    // BarCorner {
    //     id: topLeftBarCorner
    //     width: root.cornerWidth
    //     height: root.cornerHeight
    //     visible: root.topRightVisible
    //     anchors {
    //         top: parent.top
    //         left: parent.left
    //         // bottom: parent.bottom
    //     }
    //     position: "top-right"
    //     shapeColor: root.boxColor
    //     // rotation: 270
    // }
    //
    // BarCorner {
    //     id: bottomLeftBarCorner
    //     width: root.cornerWidth
    //     height: root.cornerHeight
    //     visible: root.bottomRightVisible
    //     anchors {
    //         bottom: parent.bottom
    //         left: parent.left
    //     }
    //     position: "bottom-right"
    //     shapeColor: root.boxColor
    //     // rotation: 270
    // }
}
