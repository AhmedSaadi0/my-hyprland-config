import Quickshell
import QtQuick.Window
import QtQuick.Controls

import "./themes"
import "./widgets"
import "./windows/leftwindow"

ShellRoot {
    id: shellRoot

    Topbar {
        id: topBarWindow

        Button {
            onClicked: {
                if (root.visible) {
                    root.close();
                    return;
                }
                root.open();
            }
        }
    }

    LeftWindow {
        id: root
    }
}
