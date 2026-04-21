// windows/bottomlauncher/LauncherAppItem.qml
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

    signal clicked
    signal hovered
    signal favoriteToggled

    property var appData
    property bool isSelected: false
    property bool isHighlighted: false
    property bool isFavorite: false

    height: 64

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
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        // App Icon
        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.8
            color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                width: 32
                height: 32
                source: Quickshell.iconPath(appData ? appData.icon : "application-x-executable", "application-x-executable")
                // source: Helper.toImageSource(Quickshell.iconPath( appData.icon, "application-x-executable"))
                transformOrigin: Item.Center
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

        // App Info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: appData ? appData.name : "Unknown"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: root.isHighlighted ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: appData ? (appData.genericName || appData.comment || "") : ""
                font.pixelSize: 12
                color: ThemeManager.selectedTheme.colors.subtleText
                elide: Text.ElideRight
                visible: text !== ""
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton // السماح بالزر الأيمن والأيسر

        onPressed: mouse => {
            if (mouse.button === Qt.LeftButton) {
                bounceAnim.restart();
                root.clicked();
            } else if (mouse.button === Qt.RightButton) {
                // تحديد موقع فتح القائمة المنبثقة
                contextMenu.x = mouse.x;
                contextMenu.y = mouse.y;
                contextMenu.open();
            }
        }

        onEntered: root.hovered()
    }

    // القائمة المنبثقة (Context Menu)
    Popup {
        id: contextMenu
        width: 160
        padding: 6
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        transformOrigin: Item.TopLeft

        background: Rectangle {
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2
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
                    color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                }

                MouseArea {
                    id: openMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contextMenu.close();
                        bounceAnim.restart();
                        root.clicked();
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
                        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                    }
                }

                MouseArea {
                    id: favMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contextMenu.close();
                        root.favoriteToggled();
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
