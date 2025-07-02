// ملف: FinalTest.qml
import QtQuick
import QtQuick.Window
import QtQuick.Shapes

import "../../components"
import "../themes"

Rectangle {
    id: root
    color: "transparent"

    property string boxColor : ThemeManager.selectedTheme.colors.topbarColor

    Rectangle {
        id: centerBox
        color: boxColor
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
        anchors {
            // top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        position: "bottom-left"
        shapeColor: palette.window
        // rotation: 90
    }

    BarCorner {
        id: topRightBarCorner
        anchors {
            top: parent.top
            right: parent.right
            // bottom: parent.bottom
        }
        position: "top-left"
        shapeColor: palette.window
        // rotation: 270
    }

    BarCorner {
        id: topLeftBarCorner
        anchors {
            top: parent.top
            left: parent.left
            // bottom: parent.bottom
        }
        position: "top-right"
        shapeColor: palette.window
        // rotation: 270
    }

    BarCorner {
        id: bottomLeftBarCorner
        anchors {
            bottom: parent.bottom
            left: parent.left
        }
        position: "bottom-right"
        shapeColor: palette.window
        // rotation: 270
    }
}
