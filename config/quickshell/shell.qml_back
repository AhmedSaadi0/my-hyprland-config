//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Window
import Quickshell.Io

import "root:/windows/leftwindow"
import "root:/windows/settings"
import "root:/windows/cheatsheet"
import "root:/bars"
import "root:/osd"
import "root:/utils"
import "root:/config"
import "root:/desktop"
import "root:/themes"
import "root:/shadows"

ShellRoot {
    id: shellRoot

    property var settingsWindowInstance: null
    property var volumeInstance: null
    property var brightnessInstance: null
    property var notificationsInstance: null
    readonly property var _selectedTheme: ThemeManager.selectedTheme
    signal openLeftPanelRequested(int selectedIndex)

    Component.onCompleted: {
        if (ThemeManager.isInitialThemeReady) {
            console.log("ThemeManager was already ready. Activating main UI immediately.");
            activateMainUI();
        } else {
            console.log("Waiting for ThemeManager's initialThemeReady signal...");
        }
    }

    Connections {
        target: ThemeManager
        function onInitialThemeReady() {
            console.log("ShellRoot received 'initialThemeReady' signal! Activating main UI.");
            activateMainUI();
        }
    }

    function activateMainUI() {
        if (mainUiLoader.active)
            return;

        mainUiLoader.active = true;

        if (!settingsWindowInstance) {
            settingsWindowInstance = settingsWindowComponent.createObject(shellRoot);
            if (!settingsWindowInstance) {
                console.error("CRITICAL: Failed to create the Settings window component!");
            }
        }

        if (!volumeInstance) {
            volumeInstance = volumeComponent.createObject(shellRoot);
            if (!volumeInstance) {
                console.error("CRITICAL: Failed to create the Volume OSD component!");
            }
        }

        if (!brightnessInstance) {
            brightnessInstance = brightnessComponent.createObject(shellRoot);
            if (!brightnessInstance) {
                console.error("CRITICAL: Failed to create the Brightness OSD component!");
            }
        }

        if (!notificationsInstance) {
            notificationsInstance = notificationsComponent.createObject(shellRoot);
            if (!notificationsInstance) {
                console.error("CRITICAL: Failed to create the Notifications component!");
            }
        }

        splashTimer.start();
    }

    Timer {
        id: splashTimer
        interval: 1500
        repeat: false
        onTriggered: {
            splashScreen.visible = false;
        }
    }

    SplashScreen {
        id: splashScreen
        Behavior on visible {
            NumberAnimation {
                duration: 500
            }
        }
    }

    Loader {
        id: mainUiLoader
        anchors.fill: parent
        active: false
        opacity: 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }

        onStatusChanged: {
            if (status === Loader.Ready) {
                console.log("Main UI component loaded successfully. Fading in.");
                mainUiLoader.opacity = 1.0;
            } else if (status === Loader.Error) {
                console.error("CRITICAL: Failed to load the main UI component!");
            }
        }

        sourceComponent: mainUiComponent
    }

    Component {
        id: settingsWindowComponent
        Main {}
    }

    Component {
        id: volumeComponent
        Volume {}
    }
    Component {
        id: brightnessComponent
        Brightness {}
    }
    Component {
        id: notificationsComponent
        Notifications {}
    }

    Component {
        id: widgetsComponent
        Widgets {}
    }

    Component {
        id: mainUiComponent
        Item {

            Variants {
                model: Quickshell.screens
                LeftbarShadowsLayer {
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            Variants {
                model: Quickshell.screens
                TopbarShadowsLayer {
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            Variants {
                model: Quickshell.screens
                Topbar {
                    id: topBarWindow
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            Variants {
                model: Quickshell.screens
                TopRightCorner {
                    id: topRightCorners
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            Variants {
                model: Quickshell.screens
                TopLeftCorner {
                    id: topLeftCorners
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            Variants {
                model: Quickshell.screens
                BottomLeftCorner {
                    id: bottomLeftCorner
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            Variants {
                model: Quickshell.screens
                LeftBar {
                    id: leftBar
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            LeftWindowFull {
                id: leftPanelFull
            }

            Cheatsheet {
                id: cheatsheetPanel
            }

            IpcHandler {
                id: handler
                target: "LeftBar"

                property bool isMenuOpen: false
                property int targetedMenu: 0
                property int openedMenu: LeftMenuStatus.selectedIndex

                function toggleMenu() {
                    let menuToOpen = targetedMenu;

                    if (targetedMenu === openedMenu) {
                        menuToOpen = -1;
                    }

                    LeftMenuStatus.changeIndex(menuToOpen);
                }

                function toggleDashboardMenu() {
                    targetedMenu = 0;
                    toggleMenu();
                }

                function toggleNotificatoinsMenu() {
                    targetedMenu = 1;
                    toggleMenu();
                }

                function toggleWeatherMenu() {
                    targetedMenu = 2;
                    toggleMenu();
                }

                function toggleMonotoringMenu() {
                    targetedMenu = 3;
                    toggleMenu();
                }

                function toggleNetworkingMenu() {
                    targetedMenu = 4;
                    toggleMenu();
                }

                function toggleApplauncherMenu() {
                    targetedMenu = 6;
                    toggleMenu();
                }
            }
            Variants {
                model: Quickshell.screens

                Item {
                    id: widgetContainer
                    anchors.fill: parent

                    required property ShellScreen modelData

                    Component.onCompleted: {
                        const newWidgets = widgetsComponent.createObject(widgetContainer, {
                            // "modelData": modelData,
                            "screen": modelData
                        });

                        if (!newWidgets) {
                            console.error("Failed to create Widgets for screen:", modelData.name);
                        }
                    }
                }
            }
            // Variants {
            //     model: Quickshell.screens
            //     Widgets {
            //         id: desktopWidgets
            //         required property ShellScreen modelData
            //         screen: modelData
            //     }
            // }
        }
    }
}
