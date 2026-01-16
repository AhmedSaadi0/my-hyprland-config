//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQml
import QtQuick.Window
import Quickshell.Io

import "root:/windows/leftwindow"
import "root:/windows/smart_capsule"
import "root:/windows/settings"
import "root:/windows/cheatsheet"
import "root:/windows/bottomlauncher"
import "root:/windows/poweroption"
import "root:/bars"
import "root:/osd"
import "root:/utils"
import "root:/config"
import "root:/desktop"
import "root:/themes"
import "root:/shadows"
import "root:/windows/smart_capsule/logic"
import "root:/config/ConstValues.js" as Consts
import "root:/config/EventNames.js" as Events

ShellRoot {
    id: shellRoot

    // --- Properties ---
    property var settingsWindowInstance: null
    property var notificationsInstance: null
    readonly property var _selectedTheme: ThemeManager.selectedTheme

    signal openLeftPanelRequested(int selectedIndex)

    Component.onCompleted: {
        Qt.uiLanguage = "ar";
    }

    // // --- Initialization Logic ---
    // Component.onCompleted: {
    //     if (ThemeManager.isInitialThemeReady) {
    //         activateMainUI();
    //     } else {
    //         console.log("Waiting for ThemeManager...");
    //     }
    // }

    Connections {
        target: ThemeManager
        function onInitialThemeReady() {
            startComp.start();
        }
    }

    Timer {
        id: startComp
        interval: 1000
        repeat: false
        onTriggered: {
            activateMainUI();
        }
    }

    function activateMainUI() {
        if (mainUiLoader.active)
            return;

        mainUiLoader.active = true;
        initializeGlobalWindows();
        splashTimer.start();
    }

    function initializeGlobalWindows() {
        // دالة مساعدة لإنشاء النوافذ العامة مرة واحدة
        const createGlobalWindow = (component, name) => {
            const instance = component.createObject(shellRoot);
            if (!instance)
                console.error(`CRITICAL: Failed to create ${name}!`);
            return instance;
        };

        if (!settingsWindowInstance) {
            settingsWindowInstance = createGlobalWindow(settingsWindowComponent, "Settings Window");
        }

        if (!notificationsInstance) {
            notificationsInstance = createGlobalWindow(notificationsComponent, "Notifications");
        }
    }

    // --- Splash Screen ---
    Timer {
        id: splashTimer
        interval: 1000
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

    // --- Main UI Loader ---
    Loader {
        id: mainUiLoader
        anchors.fill: parent
        active: false
        opacity: 0.0
        sourceComponent: mainUiComponent

        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }

        onStatusChanged: {
            if (status === Loader.Ready) {
                console.log("Main UI Loaded.");
                mainUiLoader.opacity = 1.0;
            } else if (status === Loader.Error) {
                console.error("CRITICAL: Failed to load Main UI!");
            }
        }
    }

    // --- Components Definitions ---
    Component {
        id: settingsWindowComponent
        Main {}
    }

    Component {
        id: notificationsComponent
        Notifications {}
    }

    // --- Main UI Structure ---
    Component {
        id: mainUiComponent
        Item {

            Variants {
                model: Quickshell.screens
                Desktop {
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            // 1. Dynamic Island
            Variants {
                model: Quickshell.screens
                SmartCapsule {
                    id: dynamicIsland
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            // 2. Shadows Layers
            // Variants {
            //     model: Quickshell.screens
            //     LeftbarShadowsLayer {
            //         required property ShellScreen modelData
            //         screen: modelData
            //     }
            // }

            // Variants {
            //     model: Quickshell.screens
            //     TopbarShadowsLayer {
            //         required property ShellScreen modelData
            //         screen: modelData
            //     }
            // }

            // 3. Bars & Corners
            Variants {
                model: Quickshell.screens
                Topbar {
                    id: topBarWindow
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            // Variants {
            //     model: Quickshell.screens
            //     TopRightCorner {
            //         id: topRightCorners
            //         required property ShellScreen modelData
            //         screen: modelData
            //     }
            // }
            //
            // Variants {
            //     model: Quickshell.screens
            //     TopLeftCorner {
            //         id: topLeftCorners
            //         required property ShellScreen modelData
            //         screen: modelData
            //     }
            // }
            //
            // Variants {
            //     model: Quickshell.screens
            //     BottomLeftCorner {
            //         id: bottomLeftCorner
            //         required property ShellScreen modelData
            //         screen: modelData
            //     }
            // }

            Variants {
                model: Quickshell.screens
                LeftBar {
                    id: leftBar
                    required property ShellScreen modelData
                    screen: modelData
                }
            }

            // 4. Global Panels (Single instance)
            LeftWindowFull {
                id: leftPanelFull
            }
            Cheatsheet {
                id: cheatsheetPanel
            }
            BottomAppLauncher {
                id: bottomLauncherPanel
            }
            PowerMenuWindow {
                id: powerMenuWindow
                // visible is handled via the connection below
            }

            // Event listener for bottom launcher toggle from LeftBar
            Connections {
                target: null
                Component.onCompleted: {
                    EventBus.on(Events.TOGGLE_BOTTOM_LAUNCHER, () => {
                        bottomLauncherPanel.toggle();
                    });
                }
            }

            // 5. IPC Handler (Refactored Logic)
            IpcHandler {
                id: handler
                target: "LeftBar"

                property int openedMenu: LeftMenuStatus.selectedIndex

                function toggleMenu(targetIndex: int) {
                    let index = Number(targetIndex);
                    let menuToOpen = index;

                    if (index === openedMenu) {
                        menuToOpen = -1;
                    }

                    LeftMenuStatus.changeIndex(menuToOpen);
                    EventBus.emit(Events.OPEN_LEFTBAR, menuToOpen);
                }

                function toggleDashboardMenu() {
                    toggleMenu(Consts.DASHBOARD_MENU_INDEX);
                }
                function toggleNotificationsMenu() {
                    toggleMenu(Consts.NOTIFICATION_MENU_INDEX);
                }
                function toggleWeatherMenu() {
                    toggleMenu(Consts.WEATHER_MENU_INDEX);
                }
                function toggleMonitoringMenu() {
                    toggleMenu(Consts.MONIROTS_MENU_INDEX);
                }
                function toggleNetworkingMenu() {
                    toggleMenu(Consts.NETWORK_MENU_INDEX);
                }
                function toggleClipboardMenu() {
                    toggleMenu(Consts.CLIPBOARD_MENU_INDEX);
                }
                function toggleTodoMenu() {
                    toggleMenu(Consts.TODO_MENU_INDEX);
                }
                function toggleAiMenu() {
                    toggleMenu(Consts.AI_BOT_MENU_INDEX);
                }
                function toggleApplauncherMenu() {
                    if (App.useBottomLauncher) {
                        bottomLauncherPanel.toggle();
                    } else {
                        toggleMenu(Consts.APPLICATIONS_MENU_INDEX);
                    }
                }
                function togglePowerMenu() {
                    EventBus.emit(Events.TOGGLE_POWER_MENU);
                }
            }
        }
    }
}
