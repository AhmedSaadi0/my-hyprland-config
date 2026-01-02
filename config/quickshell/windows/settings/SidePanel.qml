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

    Text {
        id: headerTitle
        text: qsTr("Settings")
        font.bold: true
        font.pixelSize: 24
        color: ThemeManager.selectedTheme.colors.topbarFgColor
        anchors {
            top: parent.top
        }
    }

    Rectangle {
        id: movingHighlight
        width: parent.width - 10
        height: menuListView.currentItem ? menuListView.currentItem.height : 0
        x: 0 + 5
        y: menuListView.currentItem ? menuListView.currentItem.y + menuListView.anchors.topMargin : 0

        color: ThemeManager.selectedTheme.colors.primary
        radius: ThemeManager.selectedTheme.dimensions.elementRadius

        Behavior on y {
            SpringAnimation {
                spring: 3
                damping: 0.25
            }
        }
        Behavior on height {
            SmoothedAnimation {
                duration: 200
            }
        }
    }

    ListView {
        id: menuListView
        anchors.fill: parent
        anchors.topMargin: headerTitle.implicitHeight + 5
        clip: true
        currentIndex: 1
        spacing: 2

        model: [
            {
                name: qsTr("General"),
                type: "header"
            },
            {
                name: qsTr("General Configuration"),
                icon: "preferences-system" // أيقونة الإعدادات العامة
                ,
                type: "item",
                pageIndex: 0 // الصفحة رقم 0 في StackView
            },

            // --- القسم السابق: المظهر (تم تحديث الـ pageIndex) ---
            {
                name: qsTr("Appearance"),
                type: "header"
            },
            {
                name: qsTr("Wallpaper Settings"),
                icon: "preferences-system-windows",
                type: "item",
                pageIndex: 1 // كان 0 أصبح 1
            },
            {
                name: qsTr("Color Settings"),
                icon: "preferences-desktop-color",
                type: "item",
                pageIndex: 2 // كان 1 أصبح 2
            },
            {
                name: qsTr("Layout & Fonts"),
                icon: "preferences-desktop-font",
                type: "item",
                pageIndex: 3 // كان 2 أصبح 3
            },
            {
                name: qsTr("Desktop Clock Settings"),
                icon: "preferences-desktop-time",
                type: "item",
                pageIndex: 4 // ...
            },
            {
                name: qsTr("Hyprland Settings"),
                icon: "preferences-desktop-display",
                type: "item",
                pageIndex: 5
            },
            {
                name: qsTr("Integration Settings"),
                icon: "preferences-plugin",
                type: "item",
                pageIndex: 6
            },

            // --- قسم الأجهزة ---
            {
                name: qsTr("Devices"),
                type: "header"
            },
            {
                name: qsTr("Audio Devices"),
                icon: "audio-card",
                type: "item",
                pageIndex: 7
            }
            // {
            //     name: qsTr("Display Devices"),
            //     icon: "video-display",
            //     type: "item",
            //     pageIndex: 8
            // },
            // {
            //     name: qsTr("Capture Devices"),
            //     icon: "camera-web",
            //     type: "item",
            //     pageIndex: 9
            // },
            // {
            //     name: qsTr("Usb Peripherals"),
            //     icon: "drive-removable-media-usb",
            //     type: "item",
            //     pageIndex: 10
            // }
            ,
        ]

        delegate: Controls.ItemDelegate {
            width: parent.width

            height: model.modelData.type === "header" ? Kirigami.Units.gridUnit * 1.8 : Kirigami.Units.gridUnit * 2.5

            padding: model.modelData.type === "header" ? Kirigami.Units.smallSpacing : 0
            leftPadding: model.modelData.type === "header" ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing

            enabled: model.modelData.type === "item"

            property bool isHovered: false

            RowLayout {
                width: parent.width
                visible: model.modelData.type === "header"

                Text {
                    id: label
                    text: model.modelData.name
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    opacity: 0.7
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    height: 1
                    color: Kirigami.Theme.textColor
                    opacity: 0.5
                }

                spacing: 10
            }

            contentItem: RowLayout {
                spacing: Kirigami.Units.mediumSpacing
                visible: model.modelData.type === "item"

                Kirigami.Icon {
                    source: model.modelData.icon
                    color: itemLabel.color
                    Layout.leftMargin: 8
                    Layout.rightMargin: 4
                }

                // Text {
                //     // text: model.modelData.icon
                //     color: itemLabel.color
                //     text: "󰸉"
                //     Layout.leftMargin: 10
                //     Layout.rightMargin: 10
                // }

                Text {
                    id: itemLabel
                    text: model.modelData.name
                    elide: Text.ElideLeft
                    color: menuListView.currentIndex === index ? ThemeManager.selectedTheme.colors.onPrimary : ThemeManager.selectedTheme.colors.topbarFgColor
                    Layout.fillWidth: true
                }
            }

            background: Rectangle {
                id: bgRect
                color: menuListView.currentIndex === index ? ThemeManager.selectedTheme.colors.primary : (isHovered ? ThemeManager.selectedTheme.colors.secondary.alpha(0.4) : "transparent")
                // width: 20
                // border.color: menuListView.currentIndex === index ? ThemeManager.selectedTheme.colors.primary : (isHovered ? ThemeManager.selectedTheme.colors.secondary : "transparent")
                // border.width: menuListView.currentIndex === index ? 1 : (isHovered ? 1 : 0)
                radius: ThemeManager.selectedTheme.dimensions.elementRadius

                Behavior on color {
                    ColorAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on border.width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: model.modelData.type === "item"
                    onEntered: isHovered = model.modelData.type === "item"
                    onExited: isHovered = false
                }
            }

            onClicked: {
                if (model.modelData.type === "item") {
                    menuListView.currentIndex = index;
                    root.navigateTo(model.modelData.pageIndex);
                }
            }
        }
    }
}
