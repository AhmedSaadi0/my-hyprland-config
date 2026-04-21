// windows/leftwindow/applauncher/AppItem.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/themes"
import "root:/config"
import "root:/utils"

Item {
    id: root
    signal itemClicked
    property var desktopEntity
    property bool isSelected: false
    property bool isFavorite: false

    width: listView.width
    height: 70

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: {
            if (root.isSelected) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.15);
            }
            if (mouseArea.containsMouse) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.1);
            }
            return "transparent";
        }

        Behavior on color {
            ColorAnimation {
                duration: 180
                easing.type: Easing.OutQuad
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        IconImage {
            id: icon
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignVCenter
            source: desktopEntity && desktopEntity.icon ? Helper.toImageSource(Quickshell.iconPath(desktopEntity.icon, "application-x-executable")) : ""
            transformOrigin: Item.Center
            asynchronous: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: desktopEntity ? desktopEntity.name : "Not available"
                font.pixelSize: 16
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }
            Text {
                text: desktopEntity ? (desktopEntity.genericName || desktopEntity.comment || "") : ""
                font.pixelSize: 12
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1.alpha(0.7)
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                visible: text !== ""
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton // السماح بالزرين

        onPressed: mouse => {
            if (mouse.button === Qt.LeftButton) {
                bounceAnim.restart();
                root.itemClicked();
            } else if (mouse.button === Qt.RightButton) {
                contextMenu.x = mouse.x;
                contextMenu.y = mouse.y;
                contextMenu.open();
            }
        }
    }

    // القائمة المنبثقة (Context Menu)
    Popup {
        id: contextMenu
        width: 170
        padding: 6
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        transformOrigin: Item.TopLeft

        background: Rectangle {
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2 || "#2A2A2A" // Fallback color if undefined
            border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
            border.width: 1
        }

        // أنيميشن الفتح
        enter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 200
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.8
                    to: 1.0
                    duration: 250
                    easing.type: Easing.OutBack
                }
            }
        }

        // أنيميشن الإغلاق
        exit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: 150
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 1.0
                    to: 0.9
                    duration: 150
                    easing.type: Easing.InQuad
                }
            }
        }

        contentItem: ColumnLayout {
            spacing: 4

            // زر فتح التطبيق
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                color: openMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "فتح"
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                }

                MouseArea {
                    id: openMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contextMenu.close();
                        bounceAnim.restart();
                        root.itemClicked();
                    }
                }
            }

            // خط فاصل
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: ThemeManager.selectedTheme.colors.primary.alpha(0.1)
            }

            // زر المفضلة
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
                        color: root.isFavorite ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.subtleText
                    }

                    Text {
                        text: root.isFavorite ? "إزالة من المفضلة" : "إضافة للمفضلة"
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                    }
                }

                MouseArea {
                    id: favMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contextMenu.close();
                        // اللوجيك الخاص بإضافة/حذف التطبيق من المفضلة
                        const appId = desktopEntity.name;
                        const index = App.favoriteApps.indexOf(appId);
                        if (index === -1) {
                            App.favoriteApps.push(appId);
                        } else {
                            App.favoriteApps.splice(index, 1);
                        }
                        App.updateConfig("favoriteApps", App.favoriteApps);
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: bounceAnim
        running: false
        PropertyAnimation {
            target: icon
            property: "scale"
            to: 0.85
            duration: 100
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: icon
            property: "scale"
            to: 1.1
            duration: 120
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: icon
            property: "scale"
            to: 1.0
            duration: 100
            easing.type: Easing.OutBack
        }
    }
}
