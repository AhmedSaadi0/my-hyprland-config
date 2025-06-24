import Quickshell
import QtQuick.Window
import Quickshell.Io

import "./topbar"
import "./windows/leftwindow"

ShellRoot {
    id: shellRoot

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

    IpcHandler {
        id: handler
        target: "Topbar"

        property bool isMenuOpen: false

        function toggleMenu() {
            if (leftPanelFull.visible) {
                // leftPanel.close();
                // btn.textRotation = 0;
                leftPanelFull.close();
                isMenuOpen = false;
                return;
            }
            // leftPanel.open();
            // btn.textRotation = 180;
            leftPanelFull.open();
            isMenuOpen = true;
        }
    }

    Variants {
        model: Quickshell.screens
        TopLeftCorner {
            id: topLeftCorner

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
        BottomRightCorner {
            id: bottomRightCorners

            required property ShellScreen modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        BottomLeftCorner {
            id: bottomLeftCorners

            required property ShellScreen modelData
            screen: modelData
        }
    }

    LeftWindowFull {
        id: leftPanelFull
        visible: false
        required property ShellScreen modelData
        screen: modelData
    }

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
