//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick.Window
import Quickshell.Io

import "./topbar"
import "./windows/leftwindow"
import "./osd"

ShellRoot {
    id: shellRoot

    // Variants {
    //     model: Quickshell.screens
    //     TopLeftCorner {
    //         id: topLeftCorner
    //         required property ShellScreen modelData
    //         screen: modelData
    //     }
    // }

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
        Topbar {
            id: topBarWindow

            required property ShellScreen modelData
            screen: modelData
            menuIsOpen: handler.isMenuOpen
            onOpenLeftPanelRequested: {
                handler.toggleMenu();
            }
        }
    }

    // Variants {
    //     model: Quickshell.screens
    //     BottomRightCorner {
    //         id: bottomRightCorners
    //
    //         required property ShellScreen modelData
    //         screen: modelData
    //     }
    // }
    //
    // Variants {
    //     model: Quickshell.screens
    //     BottomLeftCorner {
    //         id: bottomLeftCorners
    //
    //         required property ShellScreen modelData
    //         screen: modelData
    //     }
    // }

    LeftBar {}

    LeftWindowFull {
        // NewLeftWindow {
        id: leftPanelFull
        visible: false
        required property ShellScreen modelData
        screen: modelData
    }

    IpcHandler {
        id: handler
        target: "Topbar"

        property bool isMenuOpen: false
        property int targetedMenu: 0
        property int openedMenu: leftPanelFull.menuSelectorRef.currentIndex

        function toggleMenu() {
            if (leftPanelFull.visible) {
                if (targetedMenu != openedMenu) {
                    leftPanelFull.menuSelectorRef.changeTab(targetedMenu);
                    return;
                }
                leftPanelFull.close();
                isMenuOpen = false;
                return;
            }
            leftPanelFull.open();
            isMenuOpen = true;
            leftPanelFull.menuSelectorRef.changeTab(targetedMenu);
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
    }

    Volume {}
    Brightness {}
    Notifications {}

    // Connections {
    //     target: topBarWindow
    //     function onOpenLeftPanelRequested(btn) {
    //         if (leftPanelFull.visible) {
    //             // leftPanel.close();
    //             btn.textRotation = 0;
    //             leftPanelFull.close();
    //             return;
    //         }
    //         // leftPanel.open();
    //         btn.textRotation = 180;
    //         leftPanelFull.open();
    //     }
    // }
}
