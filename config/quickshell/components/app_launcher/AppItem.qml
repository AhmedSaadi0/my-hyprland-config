// components/AppItem.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/config/EventNames.js" as Events
import "root:/utils"
import "root:/services"

Item {
    id: root

    signal clicked
    signal hovered
    signal favoriteToggled
    signal pinToggled

    property var appData
    property bool isSelected: false
    property bool isHighlighted: false
    property bool isFavorite: false
    property bool isPinnedToDock: false

    height: 64

    Component.onCompleted: {
        EventBus.on(Events.APP_MENU_CLOSE_ALL, function (data) {
            if (menuLoader && menuLoader.active && menuLoader.item && data.except !== menuLoader.item && menuLoader.item.opened) {
                menuLoader.item.close();
            }
        }, root);

        // Request theme icon resolution
        let iconKey = appData ? appData.icon : null;
        if (iconKey && !Helper.isDirectImageSource(iconKey)) {
            IconService.requestResolve([iconKey]);
        }
    }

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: ThemeManager.selectedTheme.dimensions.elementRadius

        color: {
            if (root.isHighlighted) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.25);
            }
            if (root.isSelected) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.15);
            }
            if (mouseArea.containsMouse) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.1);
            }
            return "transparent";
        }

        border.color: root.isHighlighted ? ThemeManager.selectedTheme.colors.primary : "transparent"
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
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.8
            color: ThemeManager.selectedTheme.colors.surfaceContainer

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                width: 38
                height: 38
                source: {
                    let trigger = IconService.iconUpdateTrigger;
                    let iconKey = appData ? appData.icon : "application-x-executable";
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
                text: appData ? appData.name : "Unknown"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: root.isHighlighted ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.onSurface
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: appData ? (appData.genericName || appData.comment || "") : ""
                font.pixelSize: 14
                color: ThemeManager.selectedTheme.colors.onSurfaceVariant
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
                radius: ThemeManager.selectedTheme.dimensions.shapeExtraSmall
                color: ThemeManager.selectedTheme.colors.primary.alpha(0.12)
                visible: root.isFavorite

                Text {
                    anchors.centerIn: parent
                    text: "󰓎"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 13
                    color: ThemeManager.selectedTheme.colors.primary
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignRight
                width: 24
                height: 24
                radius: ThemeManager.selectedTheme.dimensions.shapeExtraSmall
                color: ThemeManager.selectedTheme.colors.primary.alpha(0.12)
                visible: root.isPinnedToDock

                Text {
                    anchors.centerIn: parent
                    text: "󰋜"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 13
                    color: ThemeManager.selectedTheme.colors.primary
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignRight
                width: 24
                height: 24
                radius: ThemeManager.selectedTheme.dimensions.shapeExtraSmall
                color: ThemeManager.selectedTheme.colors.surfaceContainerHigh
                opacity: (mouseArea.containsMouse || root.isHighlighted || root.isSelected) ? 0.85 : 0

                Text {
                    anchors.centerIn: parent
                    text: "↵"
                    font.pixelSize: 12
                    color: ThemeManager.selectedTheme.colors.onSurfaceVariant
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

        onPressed: mouse => {
            if (mouse.button === Qt.LeftButton) {
                bounceAnim.restart();
                root.clicked();
            } else if (mouse.button === Qt.RightButton) {
                // تفعيل قائمة السياق (بناء الـ Popup في الذاكرة فقط عند الحاجة)
                menuLoader.active = true;
                menuLoader.item.x = mouse.x;
                menuLoader.item.y = mouse.y;

                if (menuLoader.item.opened) {
                    menuLoader.item.close();
                } else {
                    EventBus.emit(Events.APP_MENU_CLOSE_ALL, {
                        except: menuLoader.item
                    });
                    menuLoader.item.open();
                }
            }
        }
        onEntered: root.hovered()
    }

    // هنا السر: استخدام Loader لمنع بناء عشرات القوائم في الذاكرة عند التشغيل
    Loader {
        id: menuLoader
        active: false
        sourceComponent: Component {
            Popup {
                width: 200
                padding: 6
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                focus: true
                transformOrigin: Item.TopLeft

                // تدمير العنصر من الذاكرة عند إغلاقه لتوفير الموارد
                onClosed: menuLoader.active = false

                background: Rectangle {
                    radius: ThemeManager.selectedTheme.dimensions.elementRadius
                    color: ThemeManager.selectedTheme.colors.surfaceContainerHigh
                    border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                        color: openMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Open")
                            font.pixelSize: 14
                            color: ThemeManager.selectedTheme.colors.onSurface
                        }

                        MouseArea {
                            id: openMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                menuLoader.item.close();
                                bounceAnim.restart();
                                root.clicked();
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: ThemeManager.selectedTheme.colors.primary.alpha(0.1)
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                        color: favMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                text: "󰦢"
                                font.family: ThemeManager.selectedTheme.typography.iconFont
                                font.pixelSize: 14
                                color: root.isFavorite ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.onSurfaceVariant
                            }
                            Text {
                                text: root.isFavorite ? qsTr("Remove from favorites") : qsTr("Add to favorites")
                                font.pixelSize: 14
                                color: ThemeManager.selectedTheme.colors.onSurface
                            }
                        }

                        MouseArea {
                            id: favMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                menuLoader.item.close();
                                root.favoriteToggled();
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                        color: pinMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                text: "󰋜"
                                font.family: ThemeManager.selectedTheme.typography.iconFont
                                font.pixelSize: 14
                                color: root.isPinnedToDock ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.onSurfaceVariant
                            }
                            Text {
                                text: root.isPinnedToDock ? qsTr("Unpin from Dock") : qsTr("Pin to Dock")
                                font.pixelSize: 14
                                color: ThemeManager.selectedTheme.colors.onSurface
                            }
                        }

                        MouseArea {
                            id: pinMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                menuLoader.item.close();
                                root.pinToggled();
                            }
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
