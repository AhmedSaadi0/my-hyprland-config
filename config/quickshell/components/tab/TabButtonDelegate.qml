import QtQuick

import "../../themes"
import "../../components"

Item {
    property string text
    property string icon
    property var onClick
    property bool isCurrent

    Rectangle {
        id: container
        // width: isCurrent ? 120 : 40
        // height: 22
        anchors {
            fill: parent
            verticalCenter: parent.verticalCenter
        }
        radius: ThemeManager.selectedTheme.dimensions.elementRadius - 2

        color: {
            if (isCurrent)
                return root.highlightColor;
            return mouseArea.containsMouse ? root.hoverColor : "transparent";
        }

        layer {
            enabled: true
            effect: Shadow {
                alpha: 0.3
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: root.animationDuration + 100
                easing.type: Easing.OutQuad
            }
        }

        IconLabel {
            iconText: icon
            labelText: isCurrent ? text : ""
            isActive: isCurrent || mouseArea.containsMouse
            currentWidth: parent.width
            anchors.centerIn: parent
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: root.animationDuration
            // easing.type: Easing.OutBack
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
