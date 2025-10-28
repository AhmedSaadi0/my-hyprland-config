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

    // Rectangle {
    //     id: movingHighlight
    //     x: Kirigami.Units.smallSpacing / 2
    //     width: parent.width - Kirigami.Units.smallSpacing
    //     height: menuListView.currentItem ? menuListView.currentItem.height : 0
    //     y: menuListView.currentItem ? menuListView.currentItem.y + menuListView.anchors.topMargin : 0
    //     color: Kirigami.Theme.activeBackgroundColor
    //     border.color: Kirigami.Theme.neutralBackgroundColor
    //     border.width: 2
    //     radius: ThemeManager.selectedTheme.dimensions.elementRadius
    //
    //     anchors {
    //         top: headerTitle.bottom
    //     }
    //
    //     Behavior on y {
    //         SpringAnimation {
    //             spring: 3
    //             damping: 0.25
    //             duration: 200
    //         }
    //     }
    // }

    ListView {
        id: menuListView
        anchors.fill: parent
        anchors.topMargin: headerTitle.implicitHeight + 5
        clip: true
        currentIndex: 1
        spacing: 2

        model: [
            {
                name: qsTr("Appearance"),
                type: "header" // هذا عنصر عنوان
            },
            {
                name: qsTr("Wallpaper Settings"),
                icon: "preferences-system-windows",
                type: "item", // هذا عنصر عادي
                pageIndex: 0  // فهرس الصفحة للانتقال
            },
            {
                name: qsTr("Color Settings"),
                icon: "preferences-desktop-color",
                type: "item",
                pageIndex: 1
            },
            {
                name: qsTr("Layout & Fonts"),
                icon: "preferences-desktop-font",
                type: "item",
                pageIndex: 2
            },
            {
                name: qsTr("Desktop Clock Settings"),
                icon: "preferences-desktop-time",
                type: "item",
                pageIndex: 3
            },
            {
                name: qsTr("Hyprland Settings"),
                icon: "preferences-desktop-display",
                type: "item",
                pageIndex: 4
            },
            {
                name: qsTr("Integration Settings"),
                icon: "preferences-plugin",
                type: "item",
                pageIndex: 5
            },
            {
                name: qsTr("Devices"),
                type: "header" // عنوان القسم الثاني
            },
            {
                name: qsTr("Audio Devices"),
                icon: "audio-card",
                type: "item",
                pageIndex: 6
            },
            {
                name: qsTr("Display Devices"),
                icon: "video-display",
                type: "item",
                pageIndex: 7
            },
            {
                name: qsTr("Capture Devices"),
                icon: "camera-web",
                type: "item",
                pageIndex: 8
            },
            {
                name: qsTr("Usb Peripherals"),
                icon: "drive-removable-media-usb",
                type: "item",
                pageIndex: 9
            }
        ]

        delegate: Controls.ItemDelegate {
            width: parent.width

            height: model.modelData.type === "header" 
                    ? Kirigami.Units.gridUnit * 1.8 
                    : Kirigami.Units.gridUnit * 2.5

            padding: model.modelData.type === "header" ? Kirigami.Units.smallSpacing : 0
            leftPadding: model.modelData.type === "header" ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing

            enabled: model.modelData.type === "item"

            // State for hover effect
            property bool isHovered: false

            RowLayout {
                width: parent.width // اجعل RowLayout يملأ عرض الحاوية الأب
                visible: model.modelData.type === "header"

                Text {
                    id: label
                    text: model.modelData.name
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    opacity: 0.7
                }

                Rectangle {
                    // هذا هو الخط
                    Layout.fillWidth: true // هذا يجعل الخط يملأ كل المساحة المتبقية
                    Layout.alignment: Qt.AlignVCenter // لمحاذاة الخط عموديًا في المنتصف
                    height: 1 // سماكة الخط
                    color: Kirigami.Theme.textColor
                    opacity: 0.5
                }

                // خاصية الـ spacing في RowLayout تضيف هامشًا بين النص والخط
                spacing: 10 // يمكنك تعديل هذه القيمة حسب الحاجة
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
                color: menuListView.currentIndex === index ? ThemeManager.selectedTheme.colors.primary : (isHovered ? ThemeManager.selectedTheme.colors.secondary.alpha(0.4) : "transparent")
                border.color: menuListView.currentIndex === index ? ThemeManager.selectedTheme.colors.primary : (isHovered ? ThemeManager.selectedTheme.colors.secondary : "transparent")
                border.width: menuListView.currentIndex === index ? 1 : (isHovered ? 1 : 0)
                radius: ThemeManager.selectedTheme.dimensions.elementRadius

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: model.modelData.type === "item" ? true : false;
                    onEntered: {
                        isHovered = model.modelData.type === "item" ? true : false;
                    }
                    onExited: {
                        isHovered = model.modelData.type === "item" ? false : true ;
                    }
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
