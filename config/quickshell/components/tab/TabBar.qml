// components/tab/TabBar.qml

import QtQuick
import org.kde.kirigami as Kirigami
import "root:/themes"

Rectangle {
    id: root

    //-----------------------
    // Appearance Properties
    //-----------------------
    color: Kirigami.Theme.backgroundColor.lighter(1.7)
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    //-----------------------
    // Size Configuration
    //-----------------------
    property int barLength: 300
    property int barThickness: 50
    property bool vertical: false
    property bool ensureVisibility: false

    // Default sizes (Fallback values)
    property int defaultExpandedSize: 100
    property int defaultClosedSize: 40

    implicitWidth: vertical ? barThickness : barLength
    implicitHeight: vertical ? barLength : barThickness

    //-----------------------
    // Color Scheme
    //-----------------------
    property color textHighlightColor: Kirigami.Theme.highlightedTextColor
    property color textColor: Kirigami.Theme.textColor
    property color hoverColor: Kirigami.Theme.activeTextColor.lighter(1.2)
    property color highlightColor: palette.accent
    property int animationDuration: 300

    //-----------------------
    // Public Interface
    //-----------------------
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex
    property int listViewSpacing: 8

    ListView {
        id: listView
        anchors {
            fill: parent
            margins: 6
        }
        spacing: root.listViewSpacing
        orientation: root.vertical ? ListView.Vertical : ListView.Horizontal
        highlightFollowsCurrentItem: false

        // delegateModelAccess: DelegateModel.ReadOnly

        NumberAnimation {
            id: scrollAnimation
            target: listView
            property: root.vertical ? "contentY" : "contentX"
            duration: 300
            easing.type: Easing.OutCubic
        }

        delegate: TabButtonDelegate {
            id: tabDelegate

            readonly property int itemExpandedWidth: (modelData && modelData.expandedWidth !== undefined) ? modelData.expandedWidth : root.defaultExpandedSize
            readonly property int itemClosedWidth: (modelData && modelData.closedWidth !== undefined) ? modelData.closedWidth : root.defaultClosedSize

            readonly property int itemExpandedHeight: root.defaultExpandedSize
            readonly property int itemClosedHeight: root.defaultClosedSize

            width: root.vertical ? listView.width : (listView.currentIndex === index ? itemExpandedWidth : itemClosedWidth)
            height: root.vertical ? (listView.currentIndex === index ? itemExpandedHeight : itemClosedHeight) : listView.height

            // --------------------------------------
            vertical: root.vertical

            text: modelData.text
            icon: modelData.icon
            onClick: modelData.onClick
            isCurrent: listView.currentIndex === index

            function ensureVisible() {
                if (!root.ensureVisibility) {
                    return;
                }
                var targetPos = 0;
                var viewSize = 0;
                var contentSize = 0;

                if (root.vertical) {
                    viewSize = listView.height;
                    contentSize = listView.contentHeight;
                    targetPos = (y + height / 2) - (viewSize / 2);
                } else {
                    viewSize = listView.width;
                    contentSize = listView.contentWidth;
                    targetPos = (x + width / 2) - (viewSize / 2);
                }

                var maxPos = Math.max(0, contentSize - viewSize);
                targetPos = Math.max(0, Math.min(targetPos, maxPos));

                scrollAnimation.stop();
                scrollAnimation.to = targetPos;
                scrollAnimation.restart();
            }
        }

        Component.onCompleted: {
            if (listView.count > 0) {
                currentIndex = 0;
            }
        }

        onModelChanged: {
            if (listView.count > 0 && currentIndex >= listView.count) {
                currentIndex = 0;
            }
        }
    }
}
