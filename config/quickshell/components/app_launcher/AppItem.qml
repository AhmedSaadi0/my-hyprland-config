// components/app_launcher/AppItem.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/config/ConstValues.js" as Consts
import "root:/config/EventNames.js" as Events
import "root:/utils"
import "root:/services"

Item {
    id: root

    signal clicked
    signal hovered
    signal favoriteToggled
    signal pinToggled
    signal openWithDefaultLocale

    property var appData
    property bool isSelected: false
    property bool isHighlighted: false
    property bool isFavorite: false
    property bool isPinnedToDock: false

    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var typo: ThemeManager.selectedTheme.typography

    property real pendingMenuX: 0
    property real pendingMenuY: 0

    height: Consts.APP_ITEM_HEIGHT

    Component.onCompleted: {
        EventBus.on(Events.APP_MENU_CLOSE_ALL, function (data) {
            if (menuLoader && menuLoader.active && menuLoader.item && data.except !== menuLoader.item && menuLoader.item.opened) {
                menuLoader.item.close();
            }
        }, root);

        _requestIconResolve();
    }

    Connections {
        target: root
        function onAppDataChanged() {
            _requestIconResolve();
        }
    }

    function _requestIconResolve() {
        var iconKey = root.appData ? root.appData.icon : null;
        if (iconKey && !Helper.isDirectImageSource(iconKey)) {
            IconService.requestResolve([iconKey]);
        }
    }

    Connections {
        target: menuLoader
        function onItemChanged() {
            if (menuLoader.item) {
                menuLoader.item.x = root.pendingMenuX;
                menuLoader.item.y = root.pendingMenuY;

                EventBus.emit(Events.APP_MENU_CLOSE_ALL, {
                    except: menuLoader.item
                });
                menuLoader.item.open();
            }
        }
    }

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: root.dims.elementRadius

        color: {
            if (root.isHighlighted) {
                return root.colors.primary.alpha(0.25);
            }
            if (root.isSelected) {
                return root.colors.primary.alpha(0.15);
            }
            if (mouseArea.containsMouse) {
                return root.colors.primary.alpha(0.1);
            }
            return "transparent";
        }

        border.color: root.isHighlighted ? root.colors.primary : "transparent"
        border.width: root.isHighlighted ? 1 : 0

        Behavior on color {
            ColorAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: Consts.APP_ICON_CONTAINER_SIZE
            Layout.preferredHeight: Consts.APP_ICON_CONTAINER_SIZE
            Layout.alignment: Qt.AlignVCenter
            radius: root.dims.elementRadius * 0.8
            color: root.colors.surfaceContainer

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                width: Consts.APP_ICON_SIZE
                height: Consts.APP_ICON_SIZE
                source: {
                    var trigger = IconService.iconUpdateTrigger;
                    var iconKey = root.appData ? root.appData.icon : "application-x-executable";
                    return IconService.getCached(iconKey);
                }
                transformOrigin: Item.Center

                scale: (root.isHighlighted || mouseArea.containsMouse) ? 1.12 : 1.0
                rotation: (root.isHighlighted || mouseArea.containsMouse) ? 4 : 0

                Behavior on scale {
                    SpringAnimation {
                        spring: 7.0
                        damping: 0.55
                        mass: 0.6
                    }
                }

                Behavior on rotation {
                    SpringAnimation {
                        spring: 6.0
                        damping: 0.50
                        mass: 0.7
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.appData ? root.appData.name : "Unknown"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: root.isHighlighted ? root.colors.primary : root.colors.onSurface
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.appData ? (root.appData.genericName || root.appData.comment || "") : ""
                font.pixelSize: 14
                color: root.colors.onSurfaceVariant
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 4

            Rectangle {
                Layout.alignment: Qt.AlignRight
                width: 24
                height: 24
                radius: root.dims.shapeExtraSmall
                color: root.colors.primary.alpha(0.12)
                visible: root.isFavorite

                Text {
                    anchors.centerIn: parent
                    text: "󰓎"
                    font.family: root.typo.iconFont
                    font.pixelSize: 13
                    color: root.colors.primary
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignRight
                width: 24
                height: 24
                radius: root.dims.shapeExtraSmall
                color: root.colors.primary.alpha(0.12)
                visible: root.isPinnedToDock

                Text {
                    anchors.centerIn: parent
                    text: "󰋜"
                    font.family: root.typo.iconFont
                    font.pixelSize: 13
                    color: root.colors.primary
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignRight
                width: 24
                height: 24
                radius: root.dims.shapeExtraSmall
                color: root.colors.surfaceContainerHigh
                opacity: (mouseArea.containsMouse || root.isHighlighted || root.isSelected) ? 0.85 : 0

                Text {
                    anchors.centerIn: parent
                    text: "↵"
                    font.pixelSize: 12
                    color: root.colors.onSurfaceVariant
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                bounceAnim.restart();
                root.clicked();
            } else if (mouse.button === Qt.RightButton) {
                root.pendingMenuX = mouse.x;
                root.pendingMenuY = mouse.y;
                menuLoader.active = true;

                if (menuLoader.item) {
                    if (menuLoader.item.opened) {
                        menuLoader.item.close();
                    } else {
                        menuLoader.item.x = mouse.x;
                        menuLoader.item.y = mouse.y;
                        EventBus.emit(Events.APP_MENU_CLOSE_ALL, {
                            except: menuLoader.item
                        });
                        menuLoader.item.open();
                    }
                }
            }
        }
        onEntered: root.hovered()
    }

    Loader {
        id: menuLoader
        active: false
        sourceComponent: Component {
            Popup {
                width: Consts.CONTEXT_MENU_WIDTH
                padding: 6
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                focus: true
                transformOrigin: Item.TopLeft

                onClosed: menuLoader.active = false

                background: Rectangle {
                    radius: root.dims.elementRadius
                    color: root.colors.surfaceContainerHigh
                    border.color: root.colors.primary.alpha(0.3)
                    border.width: 1
                }

                enter: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.8
                            to: 1.0
                            duration: 200
                            easing.type: Easing.OutBack
                        }
                    }
                }

                exit: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 1.0
                            to: 0.0
                            duration: 120
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 1.0
                            to: 0.9
                            duration: 120
                            easing.type: Easing.InQuad
                        }
                    }
                }

                contentItem: ColumnLayout {
                    spacing: 4

                    ContextMenuItem {
                        iconText: "󰐊"
                        label: qsTr("Open")
                        onClicked: {
                            menuLoader.item.close();
                            bounceAnim.restart();
                            root.clicked();
                        }
                    }

                    ContextMenuItem {
                        iconText: "󰗊"
                        label: qsTr("Open with C locale")
                        onClicked: {
                            menuLoader.item.close();
                            bounceAnim.restart();
                            console.info("[Locale][AppItem] openWithDefaultLocale clicked, name=" + (root.appData ? root.appData.name : "null"));
                            root.openWithDefaultLocale();
                        }
                    }

                    ContextMenuItem { showDivider: true }

                    ContextMenuItem {
                        iconText: "󰦢"
                        label: root.isFavorite ? qsTr("Remove from favorites") : qsTr("Add to favorites")
                        isHighlighted: root.isFavorite
                        onClicked: {
                            menuLoader.item.close();
                            root.favoriteToggled();
                        }
                    }

                    ContextMenuItem {
                        iconText: "󰋜"
                        label: root.isPinnedToDock ? qsTr("Unpin from Dock") : qsTr("Pin to Dock")
                        isHighlighted: root.isPinnedToDock
                        onClicked: {
                            menuLoader.item.close();
                            root.pinToggled();
                        }
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: bounceAnim
        running: false
        PropertyAnimation {
            target: appIcon
            property: "scale"
            to: 0.85
            duration: 80
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: appIcon
            property: "scale"
            to: 1.1
            duration: 100
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: appIcon
            property: "scale"
            to: 1.0
            duration: 80
            easing.type: Easing.OutQuad
        }
    }
}
