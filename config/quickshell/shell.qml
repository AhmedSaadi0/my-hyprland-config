//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Window
import Quickshell.Io

import "root:/bars"
import "root:/windows/leftwindow"
import "root:/osd"
import "root:/utils"
import "root:/config"
import "root:/desktop"

ShellRoot {
    id: shellRoot

    readonly property var _selectedTheme: ThemeManager.selectedTheme

    Component.onCompleted: {
        Qt.setContextProperty("currentTheme", _selectedTheme);
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
}
