import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
// import Quickshell
// import Quickshell.Wayland

import "root:/config"
import "root:/themes"

Controls.ApplicationWindow {
    id: root
    width: 900
    height: 700
    visible: false

    color: Kirigami.Theme.backgroundColor

    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint

    NibrasShellShortcut {
        name: "openSettings"
        onPressed: root.visible = !root.visible
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // -------------------------------------
        // 1. القائمة الجانبية (Sidebar)
        // -------------------------------------
        Rectangle {
            id: sidebar
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 12
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            Layout.margins: 8

            Rectangle {
                id: movingHighlight
                x: Kirigami.Units.smallSpacing / 2
                width: parent.width - Kirigami.Units.smallSpacing
                height: menuListView.currentItem ? menuListView.currentItem.height : 0
                y: menuListView.currentItem ? menuListView.currentItem.y + menuListView.anchors.topMargin : 0
                color: Kirigami.Theme.activeBackgroundColor
                border.color: Kirigami.Theme.neutralBackgroundColor
                border.width: 2
                radius: 12

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
                        name: "المظهر العام",
                        icon: "preferences-desktop-theme"
                    },
                    {
                        name: "النظام والخلفية",
                        icon: "preferences-system-windows"
                    },
                    {
                        name: "Hyprland",
                        icon: "preferences-desktop-display"
                    },
                    {
                        name: "ساعة سطح المكتب",
                        icon: "preferences-desktop-time"
                    },
                    {
                        name: "التكامل",
                        icon: "preferences-plugin"
                    }
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
                        radius: 12

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
                        contentStack.navigateTo(index);
                    }
                }
            }
        }

        // -------------------------------------
        // 2. حاوية المحتوى (Content Area)
        // -------------------------------------
        Controls.StackView {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            smooth: true

            property int previousIndex: 0
            property int currentIndex: 0

            property var page1
            property var page2
            property var page3
            property var page4
            property var page5

            Component {
                id: page1Component
                GeneralAppearance {}
            }

            Component {
                id: page2Component
                WallpaperSettings {}
            }

            Component {
                id: page3Component
                HyprlandSettings {}
            }

            Component {
                id: page4Component
                DesktopClockSettings {}
            }

            Component {
                id: page5Component
                IntegrationSettings {}
            }

            function getPage(index) {
                return [page1, page2, page3, page4, page5][index];
            }

            Component.onCompleted: {
                page1 = page1Component.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                page2 = page2Component.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                page3 = page3Component.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                page4 = page4Component.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                page5 = page5Component.createObject(contentStack, {
                    "visible": false
                    // "anchors.fill": stackView
                });
                push(page1);
            }

            function navigateTo(newIndex) {
                if (newIndex === currentIndex)
                    return;

                previousIndex = currentIndex;

                if (newIndex > currentIndex) {
                    contentStack.replaceEnter = enterFromBottom;
                    contentStack.replaceExit = exitToTop;
                } else {
                    contentStack.replaceEnter = enterFromTop;
                    contentStack.replaceExit = exitToBottom;
                }

                currentIndex = newIndex;
                contentStack.replace(getPage(newIndex));
            }

            // --- تعريف تأثيرات الحركة (Transitions) بالتنسيق الصحيح ---
            Transition {
                id: enterFromBottom
                SequentialAnimation {
                    PropertyAction {
                        property: "opacity"
                        value: 0
                    }
                    PropertyAction {
                        property: "scale"
                        value: 0.92
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            property: "y"
                            from: contentStack.height * 0.6
                            to: 0
                            duration: 420
                            easing.type: Easing.OutBack
                        }
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 350
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.92
                            to: 1.0
                            duration: 380
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            Transition {
                id: exitToTop
                ParallelAnimation {
                    NumberAnimation {
                        property: "y"
                        from: 0
                        to: -contentStack.height * 0.3
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 280
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 1.0
                        to: 0.95
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                }
            }

            Transition {
                id: enterFromTop
                SequentialAnimation {
                    PropertyAction {
                        property: "opacity"
                        value: 0
                    }
                    PropertyAction {
                        property: "scale"
                        value: 0.92
                    }
                    PropertyAction {
                        property: "y"
                        value: -contentStack.height * 0.3
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            property: "y"
                            from: -contentStack.height * 0.3
                            to: 0
                            duration: 420
                            easing.type: Easing.OutBack
                        }
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 350
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.92
                            to: 1.0
                            duration: 380
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            Transition {
                id: exitToBottom
                ParallelAnimation {
                    NumberAnimation {
                        property: "y"
                        from: 0
                        to: contentStack.height * 0.6
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 280
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 1.0
                        to: 0.95
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                }
            }
        }
    }
}
