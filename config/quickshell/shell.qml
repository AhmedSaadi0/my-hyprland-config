//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Quickshell.Io
import org.kde.kirigami as Kirigami

import "root:/themes"
import "root:/bars"
import "root:/windows/leftwindow"
import "root:/osd"
import "root:/utils"
import "root:/config"
import "root:/desktop"
import "root:/windows/settings"

ApplicationWindow {
    id: rootWindow
    width: 1024
    height: 768
    visible: shellLoader.status !== Loader.Ready
    title: "NibrasShell"
    visibility: "FullScreen"

    color: Kirigami.Theme.backgroundColor
    flags: Qt.Window | Qt.FramelessWindowHint

    Item {
        id: splashScreen
        anchors.fill: parent
        visible: shellLoader.status !== Loader.Ready

        opacity: shellLoader.status !== Loader.Ready ? 1 : 0

        Behavior on opacity {
            OpacityAnimator {
                duration: 300
            }
        }

        Text {
            anchors.centerIn: parent
            text: "Loading NibrasShell..."
            color: Kirigami.Theme.textColor
            font.pixelSize: 24
        }
    }

    Loader {
        id: shellLoader
        anchors.fill: parent
        active: false
        sourceComponent: shellComponent

        onStatusChanged: {
            if (status === Loader.Ready) {
                console.log("Shell component loaded successfully.");
                item.visible = true;
            }
        }
    }

    Component {
        id: shellComponent

        ShellRoot {
            id: shellRoot
            // visible: false

            readonly property var _selectedTheme: ThemeManager.selectedTheme
            Component.onCompleted: {
                console.log("ShellRoot Component.onCompleted");
                Qt.setContextProperty("currentTheme", _selectedTheme);
                // visible = true;
            }
            Connections {
                target: ThemeManager
                function onSelectedThemeChanged() {
                    Qt.setContextProperty("currentTheme", ThemeManager.selectedTheme);
                }
            }

            signal openLeftPanelRequested(int selectedIndex)
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
                LeftBar {
                    id: leftBar
                    required property ShellScreen modelData
                    screen: modelData
                }
            }
            LeftWindowFull {
                id: leftPanelFull
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
            Volume {}
            Brightness {}
            Notifications {}
            Variants {
                model: Quickshell.screens
                Widgets {
                    id: desktopWidgets
                    required property ShellScreen modelData
                    screen: modelData
                }
            }
            Main {
                id: settingWindow
            }
        }
    }

    // --- منطق تفعيل الواجهة ---
    function activateShell() {
        if (shellLoader.active)
            return;
        console.info("Activating the main shell UI...");
        shellLoader.active = true;
    }

    Component.onCompleted: {
        if (ThemeManager._initialLoadComplete) {
            console.warn("ThemeManager finished before shell could connect. Activating shell directly.");
            activateShell();
        }
    }

    Connections {
        target: ThemeManager

        function onSelectedThemeUpdated() {
            if (ThemeManager._initialLoadComplete && !shellLoader.active) {
                console.info("Shell received selectedThemeUpdated signal for the first time.");
                activateShell();
            }
        }
    }
}
