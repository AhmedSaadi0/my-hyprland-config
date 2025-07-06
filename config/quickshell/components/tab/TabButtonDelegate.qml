// components/tab/TabButtonDelegate.qml

import QtQuick
import "../../themes"

Item {
    id: delegateRoot

    property string text
    property string icon
    property var onClick
    property bool isCurrent
    property bool vertical: false

    Rectangle {
        id: container
        anchors.fill: parent
        radius: ThemeManager.selectedTheme.dimensions.elementRadius - 2

        color: {
            if (isCurrent)
                return root.highlightColor;
            return mouseArea.containsMouse ? root.hoverColor : "transparent";
        }

        Behavior on color {
            ColorAnimation {
                duration: root.animationDuration + 100
                easing.type: Easing.OutQuad
            }
        }

        IconLabel {
            // This is the key change:
            // 1. Rotate the component if vertical
            // 2. Swap width/height to fit the new orientation
            // 3. Anchor it to the center
            rotation: delegateRoot.vertical ? 90 : 0 // Rotate -90 degrees (upwards)
            width: delegateRoot.vertical ? parent.height : parent.width
            height: delegateRoot.vertical ? parent.width : parent.height
            anchors.centerIn: parent

            iconText: icon
            labelText: isCurrent ? text : ""
            isActive: isCurrent || mouseArea.containsMouse
            // The `currentWidth` property is no longer needed as IconLabel's width is set directly

        }
    }

    Behavior on width {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutExpo
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutExpo
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            listView.currentIndex = index;
            ensureVisible();
            onClick?.();
        }
    }
}
