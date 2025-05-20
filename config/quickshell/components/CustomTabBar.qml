import QtQuick
import org.kde.kirigami as Kirigami

import "../themes"

Rectangle {
    id: root
    color: Kirigami.Theme.activeBackgroundColor
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    property int barWidth: 300
    property int barHeight: 50

    // Initial dimensions
    implicitHeight: barHeight
    implicitWidth: barWidth

    property var textHighlightColor: Kirigami.Theme.highlightedTextColor
    property var textColor: Kirigami.Theme.textColor
    property var hoverColor: Kirigami.Theme.activeTextColor.lighter(1.2)
    property var highlightColor: Kirigami.Theme.activeTextColor
    property int animationDuration: 300

    // Expose these two properties for use outside implicitHeight:
    // the control
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex

    // Display tab buttons
    ListView {
        id: listView
        spacing: 8
        anchors {
            fill: parent
            topMargin: 4
            bottomMargin: 4
            leftMargin: 6
            rightMargin: 5
            // margins: 4
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
            // width: listView.model && listView.model.count > 0 ? listView.width / listView.model.count : listView.width
            width: listView.currentIndex === index ? 120 : 50
            height: listView.height

            property string label: model.text
            property string icon: model.icon
            property var onClick: model.onClick

            Rectangle {
                id: container
                width: parent.width
                height: parent.height
                anchors.centerIn: parent

                radius: ThemeManager.selectedTheme.dimensions.elementRadius - 2
                // color: listView.currentIndex === index ? root.highlightColor : "transparent"
                color: {
                    if (listView.currentIndex === index) {
                        root.highlightColor;
                    } else if (mouseArea.containsMouse) {
                        root.hoverColor;
                    } else {
                        "transparent";
                    }
                }

                Text {
                    id: icon
                    width: Math.max(10, paintedWidth)
                    text: listDelegate.icon
                    // color: listView.currentIndex === index ? root.textHighlightColor : root.textColor
                    color: {
                        if (listView.currentIndex === index || mouseArea.containsMouse) {
                            root.textHighlightColor;
                        } else {
                            root.textColor;
                        }
                    }
                    // color: root.textHighlightColor
                    font.pixelSize: 14
                    font.bold: listView.currentIndex === index
                    elide: Text.Center
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 15
                        // horizontalCenter: parent.horizontalCenter
                    }
                }

                Text {
                    id: labelText
                    width: listView.currentIndex === index ? 70 : 10
                    text: listView.currentIndex === index ? listDelegate.label : ""
                    color: listView.currentIndex === index ? root.textHighlightColor : root.textColor
                    // color: root.textHighlightColor
                    font.pixelSize: 14
                    font.bold: listView.currentIndex === index
                    elide: Text.ElideRight
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                    anchors {
                        left: icon.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 15
                        // rightMargin: 10
                    }

                    Behavior on width {
                        // enabled: isExpanding
                        NumberAnimation {
                            duration: root.animationDuration
                            easing.type: Easing.OutBack
                        }
                    }
                }

                Behavior on width {
                    // enabled: isExpanding
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutBack
                    }
                }

                Behavior on color {
                    // enabled: mouseArea.containsMouse
                    ColorAnimation {
                        duration: root.animationDuration + 100
                        easing.type: Easing.OutQuad
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    listView.currentIndex = index;
                    if (typeof listDelegate.onClick === "function") {
                        listDelegate.onClick();
                    }
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
