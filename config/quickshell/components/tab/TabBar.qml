// components/tab/TabBar.qml

import QtQuick
import org.kde.kirigami as Kirigami
import "../../themes"

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
    // CHANGED: Renamed properties for clarity in both orientations
    property int barLength: 300
    property int barThickness: 50
    property bool vertical: false
    property bool ensureVisibility: false

    // CHANGED: implicit size now depends on orientation
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

    ListView {
        id: listView
        anchors {
            fill: parent
            margins: 6
        }
        spacing: 14
        // CHANGED: Orientation is now dynamic
        orientation: root.vertical ? ListView.Vertical : ListView.Horizontal
        highlightFollowsCurrentItem: false

        delegate: TabButtonDelegate {
            // CHANGED: Width and height are now conditional based on orientation
            width: root.vertical ? listView.width : (listView.currentIndex === index ? 120 : 40)
            height: root.vertical ? (listView.currentIndex === index ? 120 : 40) : listView.height

            // ADDED: Pass the vertical property down to the delegate
            vertical: root.vertical

            text: model.text
            icon: model.icon
            onClick: model.onClick
            isCurrent: listView.currentIndex === index

            // CHANGED: This function now handles both orientations
            function ensureVisible() {
                if (!root.ensureVisibility) {
                    return;
                }
                if (root.vertical) {
                    const itemCenter = mapToItem(listView.contentItem, 0, height / 2).y;
                    const viewCenter = listView.height / 2;
                    if (itemCenter < viewCenter) {
                        listView.contentY = Math.max(0, itemCenter - viewCenter);
                    } else {
                        const maxY = listView.contentHeight - listView.height;
                        listView.contentY = Math.min(maxY, itemCenter - viewCenter);
                    }
                } else {
                    const itemCenter = mapToItem(listView.contentItem, width / 2, 0).x;
                    const viewCenter = listView.width / 2;
                    if (itemCenter < viewCenter) {
                        listView.contentX = Math.max(0, itemCenter - viewCenter);
                    } else {
                        const maxX = listView.contentWidth - listView.width;
                        listView.contentX = Math.min(maxX, itemCenter - viewCenter);
                    }
                }
            }
        }

        Component.onCompleted: if (model?.count > 0)
            currentIndex = 0

        onModelChanged: {
            if (model?.count > 0 && currentIndex >= model.count) {
                currentIndex = 0;
            }
        }
    }
}
