import Quickshell
import QtQuick.Window

import "./widgets"
import "./windows/leftwindow"

ShellRoot {
    id: shellRoot

    Topbar {
        id: topBarWindow
    }

    LeftWindow {
        id: leftPanel
    }

    Connections {
        target: topBarWindow
        function onOpenLeftPanelRequested(btn) {
            if (leftPanel.visible) {
                leftPanel.close();
                btn.textRotation = 0;
                return;
            }
            leftPanel.open();
            btn.textRotation = 180;
        }
    }
}
