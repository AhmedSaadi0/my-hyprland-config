// components/tab/TabButtonDelegate.qml

import QtQuick
import "root:/themes"

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
            rotation: delegateRoot.vertical ? 90 : 0 // Rotate -90 degrees (upwards)
            width: delegateRoot.vertical ? parent.height : parent.width
            height: delegateRoot.vertical ? parent.width : parent.height
            anchors.centerIn: parent
            isCurrent: delegateRoot.isCurrent

            iconText: icon
            labelText: isCurrent ? text : ""
            isActive: isCurrent || mouseArea.containsMouse
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
            onClick();
        }
    }
}
