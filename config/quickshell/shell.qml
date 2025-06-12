import Quickshell
import QtQuick.Window

import "./topbar"
import "./windows/leftwindow"

ShellRoot {
    id: shellRoot

    Topbar {
        id: topBarWindow
    }

    // RightBar {
    //     id: rightBarWindow
    // }
    //
    // BottomBar {
    //     id: bottomBarWindow
    // }

    // LeftWindow {
    //     id: leftPanel
    // }

    LeftWindowFull {
        id: leftPanelFull
        visible: false
    }

    TopLeftCorner {
        id: topLeftCorner
    }

    TopRightCorner {
        id: topRightCorners
    }

    BottomRightCorner {
        id: bottomRightCorners
    }

    BottomLeftCorner {
        id: bottomLeftCorners
    }

    Connections {
        target: topBarWindow
        function onOpenLeftPanelRequested(btn) {
            if (leftPanelFull.visible) {
                // leftPanel.close();
                btn.textRotation = 0;
                leftPanelFull.close();
                return;
            }
            // leftPanel.open();
            btn.textRotation = 180;
            leftPanelFull.open();
        }
    }
}
