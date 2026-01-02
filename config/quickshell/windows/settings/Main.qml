import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs
import Qt.labs.platform

import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"
import "root:/components"
import "./audio"

Controls.ApplicationWindow {
    id: root
    visible: false
    color: Kirigami.Theme.backgroundColor

    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint
    title: "NibrasShellSettings"

    function cancelAllChanges() {
        ThemeManager.reloadTheme();
        root.visible = false;
    }

    // --- Shortcuts ---
    NibrasShellShortcut {
        name: "openSettings"
        onPressed: root.visible = !root.visible
    }

    Component.onCompleted: {
        EventBus.on(Events.OPEN_SETTINGS, () => {
            root.visible = !root.visible;
        });
    }

    RowLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 0

        SidePanel {
            onNavigateTo: index => contentStack.navigateTo(index)
        }

        Controls.StackView {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            clip: true
            smooth: true

            property var pages: []
            property int currentIndex: 0

            // --- Pages Definitions ---
            Component {
                id: generalSettingsComp
                GeneralSettings {
                    onCancelChanges: root.cancelAllChanges()
                }
            }
            Component {
                id: wallpaperSettingsComp
                WallpaperSettings {
                    onCancelChanges: root.cancelAllChanges()
                }
            }
            Component {
                id: colorsSettingsComp
                ColorsSettings {
                    onCancelChanges: root.cancelAllChanges()
                }
            }
            Component {
                id: layoutFontSettingsComp
                LayoutFontSettings {
                    onCancelChanges: root.cancelAllChanges()
                }
            }
            Component {
                id: desktopClockComp
                DesktopClockSettings {
                    onCancelChanges: root.cancelAllChanges()
                }
            }
            Component {
                id: hyprlandSettingsComp
                HyprlandSettings {
                    onCancelChanges: root.cancelAllChanges()
                }
            }
            Component {
                id: integrationSettingsComp
                IntegrationSettings {
                    onCancelChanges: root.cancelAllChanges()
                }
            }
            Component {
                id: audioDevicesComp
                AudioDevices {
                    onClose: root.visible = false
                }
            }
            Component {
                id: monitorsSettingsComp
                MonitorsSettings {}
            }

            Component.onCompleted: {
                pages = [generalSettingsComp.createObject(contentStack, {
                        visible: false
                    }), wallpaperSettingsComp.createObject(contentStack, {
                        visible: false
                    }), colorsSettingsComp.createObject(contentStack, {
                        visible: false
                    }), layoutFontSettingsComp.createObject(contentStack, {
                        visible: false
                    }), desktopClockComp.createObject(contentStack, {
                        visible: false
                    }), hyprlandSettingsComp.createObject(contentStack, {
                        visible: false
                    }), integrationSettingsComp.createObject(contentStack, {
                        visible: false
                    }), audioDevicesComp.createObject(contentStack, {
                        visible: false
                        // }), monitorsSettingsComp.createObject(contentStack, {
                        //     visible: false
                    })];

                if (pages[0])
                    contentStack.push(pages[0]);
            }

            // --- Navigation logic (Corrected currentIndex scope) ---
            function navigateTo(newIndex) {
                if (!pages[newIndex] || newIndex === contentStack.currentIndex)
                    return;
                if (newIndex > contentStack.currentIndex) {
                    contentStack.replaceEnter = enterFromBottom;
                    contentStack.replaceExit = exitToTop;
                } else {
                    contentStack.replaceEnter = enterFromTop;
                    contentStack.replaceExit = exitToBottom;
                }

                contentStack.currentIndex = newIndex;
                contentStack.replace(pages[newIndex]);
            }

            // --- Animations ---
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
