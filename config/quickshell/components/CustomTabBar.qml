import QtQuick
import org.kde.kirigami as Kirigami

import "../themes"

Rectangle {
    id: root
    color: Kirigami.Theme.backgroundColor
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    property int barWidth: 300
    property int barHeight: 50

    // Initial dimensions
    implicitHeight: barHeight
    implicitWidth: barWidth

    property string textHighlightColor: Kirigami.Theme.highlightedTextColor
    property string textColor: Kirigami.Theme.textColor
    property string highlightColor: Kirigami.Theme.activeTextColor
    property int animationDuration: 200

    // Expose these two properties for use outside implicitHeight:
    // the control
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex

    // Display tab buttons
    ListView {
        id: listView
        spacing: 1
        anchors {
            fill: parent
            margins: 1
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        currentIndex: 0
        orientation: Qt.Horizontal
        highlightFollowsCurrentItem: false // Important: we handle highlight movement manually

        // Ensure currentItem is valid before accessing its properties
        property bool currentItemValid: currentItem !== null && count > 0

        delegate: Item {
            id: listDelegate
            // Calculate width more robustly, especially if model count can be 0
            width: listView.model && listView.model.count > 0 ? listView.width / listView.model.count : listView.width
            height: listView.height

            property string label: model.text
            property var onClick: model.onClick

            Text {
                id: labelText
                text: parent.label
                anchors.centerIn: parent
                // Animate color change
                Behavior on color {
                    ColorAnimation {
                        duration: root.animationDuration
                    }
                }
                color: listView.currentIndex === index ? root.textHighlightColor : root.textColor
                font.pixelSize: 14
                font.bold: listView.currentIndex === index
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    listView.currentIndex = index;
                    if (typeof listDelegate.onClick === "function") {
                        listDelegate.onClick();
                    }
                }
            }
        }

        highlight: Rectangle {
            // Changed from Item to Rectangle for direct radius
            // Bind to currentItem if valid, otherwise use sensible defaults or hide
            width: listView.currentItemValid ? listView.currentItem.width : 0
            height: listView.currentItemValid ? listView.currentItem.height : 0
            x: listView.currentItemValid ? listView.currentItem.x : -width // Hide off-screen if not valid

            // Animate X position
            Behavior on x {
                enabled: listView.currentItemValid // Only animate if item is valid
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.InOutQuad // Smoother easing
                }
            }

            // Animate Width
            Behavior on width {
                enabled: listView.currentItemValid
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.InOutQuad // Smoother easing
                }
            }

            // Visuals of the highlight
            color: root.highlightColor
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            anchors.margins: 2 // Keep the margin for the inner look
            opacity: listView.currentItemValid ? 1 : 0 // Fade out if no valid item

            Behavior on opacity {
                // Animate opacity for smooth appearance/disappearance
                NumberAnimation {
                    duration: root.animationDuration / 2
                }
            }
        }

        // Handle case where model might be empty initially or becomes empty
        Component.onCompleted: {
            if (model && model.count > 0) {
                listView.currentIndex = 0;
            }
        }

        onModelChanged: {
            if (model && model.count > 0 && listView.currentIndex >= model.count) {
                listView.currentIndex = 0;
            } else if (!model || model.count === 0)
            // Handle empty model, maybe set currentIndex to -1 or hide highlight
            {}
        }
    }
}
