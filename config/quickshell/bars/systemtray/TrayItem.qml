pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

MouseArea {
    id: root

    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: 13
    implicitHeight: 13

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else if (modelData.hasMenu) {
            menu.open();
        }
    }

    QsMenuAnchor {
        id: menu
        menu: root.modelData.menu
        anchor.window: this.QsWindow.window
    }

    IconImage {
        id: trayIcon
        width: parent.implicitWidth
        height: parent.implicitHeight
        // visible:
        source: root.modelData.icon
        anchors.centerIn: parent
        // onPaletteChanged: {
        //     // var oldSource = source;
        //     // source = "";
        //     // source = oldSource;
        //     console.info("CHHH -> " + oldSource);
        // }
    }
}
