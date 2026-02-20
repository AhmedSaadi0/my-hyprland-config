import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

// MD3: Small Top App Bar
// شريط عنوان نظيف بدون widget — كل قائمة تضع HeaderCard الخاص بها بعده
//
// الاستخدام:
//   TopAppBar {
//       title: "Network"
//       icon: "󰖩"
//       scrollY: listView.contentY
//   }
Item {
    id: root

    readonly property int sidePadding: ThemeManager.selectedTheme.dimensions.spacingMedium
    property string title: ""
    property string icon: ""
    property var actions: []
    property string primaryActionIcon: "󰅗"
    property bool primaryActionVisible: true
    property bool showDivider: false
    property real scrollY: 0
    readonly property bool isScrolled: scrollY > 0

    signal actionTriggered(int index, var action)
    signal primaryActionTriggered

    Layout.fillWidth: true
    implicitWidth: parent?.width ?? 0
    implicitHeight: 64
    clip: false

    Rectangle {
        anchors.fill: parent
        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.04)
        radius: 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.sidePadding
        anchors.rightMargin: root.sidePadding
        spacing: 0

        // Leading Icon
        Item {
            visible: root.icon.length > 0
            width: 48
            height: 48
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.centerIn: parent
                width: 40
                height: 40
                radius: 20
                color: leadingArea.containsPress ? ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.12) : leadingArea.containsMouse ? ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.08) : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.icon
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 24
                    color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                }
            }
            MouseArea {
                id: leadingArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        // Title
        Item {
            Layout.fillWidth: true
            Layout.leftMargin: root.icon.length > 0 ? ThemeManager.selectedTheme.dimensions.spacingSmall : ThemeManager.selectedTheme.dimensions.spacingLarge
            height: parent.height

            Label {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.title
                font.pixelSize: ThemeManager.selectedTheme.typography.heading3Size
                font.family: ThemeManager.selectedTheme.typography.bodyFont
                font.weight: Font.Medium
                color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
            }
        }

        // Trailing Actions
        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: root.actions
                delegate: Item {
                    width: 48
                    height: 48

                    Rectangle {
                        anchors.centerIn: parent
                        width: 40
                        height: 40
                        radius: 20
                        color: actionArea.containsPress ? ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.12) : actionArea.containsMouse ? ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.08) : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon || ""
                            font.family: ThemeManager.selectedTheme.typography.iconFont
                            font.pixelSize: 24
                            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                        }
                    }
                    MouseArea {
                        id: actionArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData && typeof modelData.onTriggered === "function")
                                modelData.onTriggered();
                            else
                                root.actionTriggered(index, modelData);
                        }
                    }
                }
            }

            Item {
                visible: root.primaryActionVisible
                width: 48
                height: 48

                Rectangle {
                    anchors.centerIn: parent
                    width: 40
                    height: 40
                    radius: 20
                    color: primaryArea.containsPress ? ThemeManager.selectedTheme.colors.primary.alpha(0.30) : primaryArea.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.22) : ThemeManager.selectedTheme.colors.primary.alpha(0.14)
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.primaryActionIcon
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 24
                        color: ThemeManager.selectedTheme.colors.primary
                    }
                }
                MouseArea {
                    id: primaryArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.primaryActionTriggered()
                }
            }
        }
    }

    // Divider — يتلاشى عند الأعلى ويظهر كاملاً عند السكرول
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        visible: root.showDivider
        opacity: root.isScrolled ? 1.0 : 0.3
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.12)
    }
}
