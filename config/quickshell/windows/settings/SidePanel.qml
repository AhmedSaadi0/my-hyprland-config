// windows/settings/SidePanel.qml

// pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/config"
import "root:/themes"

Rectangle {
    id: root
    // color: Kirigami.Theme.alternateBackgroundColor
    color: "transparent"
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    signal navigateTo(int index)

    Layout.preferredWidth: 240
    Layout.fillHeight: true
    Layout.topMargin: 18
    Layout.bottomMargin: 18
    Layout.rightMargin: 10
    Layout.leftMargin: 10

    Rectangle {
        id: movingHighlight
        x: Kirigami.Units.smallSpacing / 2
        width: parent.width - Kirigami.Units.smallSpacing
        height: menuListView.currentItem ? menuListView.currentItem.height : 0
        y: menuListView.currentItem ? menuListView.currentItem.y + menuListView.anchors.topMargin : 0
        color: Kirigami.Theme.activeBackgroundColor
        border.color: Kirigami.Theme.neutralBackgroundColor
        border.width: 2
        radius: ThemeManager.selectedTheme.dimensions.elementRadius

        Behavior on y {
            SpringAnimation {
                spring: 3
                damping: 0.25
                duration: 200
            }
        }
    }

    ListView {
        id: menuListView
        anchors.fill: parent
        anchors.topMargin: 2
        clip: true
        currentIndex: 0
        spacing: 2

        model: [
            {
                name: qsTr("Wallpaper Settings"),
                icon: "preferences-system-windows"
            },
            {
                name: qsTr("Color Settings"),
                icon: "preferences-desktop-color"
            },
            {
                name: qsTr("Layout & Fonts"),
                icon: "preferences-desktop-font"
            },
            {
                name: qsTr("Desktop Clock Settings"),
                icon: "preferences-desktop-time"
            },
            {
                name: qsTr("Hyprland Settings"),
                icon: "preferences-desktop-display"
            },
            {
                name: qsTr("Integration Settings"),
                icon: "preferences-plugin"
            },
        ]

        delegate: Controls.ItemDelegate {
            width: parent.width
            height: Kirigami.Units.gridUnit * 2.5
            padding: Kirigami.Units.smallSpacing

            // State for hover effect
            property bool isHovered: false

            contentItem: RowLayout {
                spacing: Kirigami.Units.mediumSpacing

                Kirigami.Icon {
                    source: model.modelData.icon
                    color: itemLabel.color
                }

                Controls.Label {
                    id: itemLabel
                    text: model.modelData.name
                    elide: Text.ElideRight
                    color: menuListView.currentIndex === index ? ThemeManager.selectedTheme.colors.onPrimary : ThemeManager.selectedTheme.colors.topbarFgColor
                }
            }

            background: Rectangle {
                color: menuListView.currentIndex === index ? ThemeManager.selectedTheme.colors.primary : (isHovered ? ThemeManager.selectedTheme.colors.secondary.alpha(0.4) : "transparent")
                border.color: menuListView.currentIndex === index ? ThemeManager.selectedTheme.colors.primary : (isHovered ? ThemeManager.selectedTheme.colors.secondary : "transparent")
                border.width: menuListView.currentIndex === index ? 1 : (isHovered ? 1 : 0)
                radius: ThemeManager.selectedTheme.dimensions.elementRadius

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        isHovered = true;
                    }
                    onExited: {
                        isHovered = false;
                    }
                }
            }

            onClicked: {
                menuListView.currentIndex = index;
                root.navigateTo(index);
            }
        }
    }
}
