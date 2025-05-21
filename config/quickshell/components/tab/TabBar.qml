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
    property int barWidth: 300
    property int barHeight: 50
    implicitWidth: barWidth
    implicitHeight: barHeight

    //-----------------------
    // Color Scheme
    //-----------------------
    property color textHighlightColor: Kirigami.Theme.highlightedTextColor
    property color textColor: Kirigami.Theme.textColor
    property color hoverColor: Kirigami.Theme.activeTextColor.lighter(1.2)
    property color highlightColor: Kirigami.Theme.activeTextColor
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
            margins: 4
            leftMargin: 6
            rightMargin: 5
        }
        spacing: 12
        orientation: ListView.Horizontal
        highlightFollowsCurrentItem: false

        delegate: TabButtonDelegate {
            width: listView.currentIndex === index ? 120 : 40
            height: listView.height
            text: model.text
            icon: model.icon
            onClick: model.onClick
            isCurrent: listView.currentIndex === index

            function ensureVisible() {
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

        Component.onCompleted: if (model?.count > 0)
            currentIndex = 0

        onModelChanged: {
            if (model?.count > 0 && currentIndex >= model.count) {
                currentIndex = 0;
            }
        }
    }
}
