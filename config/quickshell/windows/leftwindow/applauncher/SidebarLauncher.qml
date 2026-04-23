// windows/leftwindow/applauncher/SidebarLauncher.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "root:/config"
import "root:/config/EventNames.js" as Events
import "../base"

BaseMenuView {
    id: root

    menuTitle: qsTr("Apps")
    menuIcon: "󰀻"
    showPrimaryAction: false

    Layout.fillWidth: true
    Layout.fillHeight: true

    readonly property var dims: ThemeManager.selectedTheme.dimensions

    pageContent: AppLauncherBase {
        id: appLauncherBase
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: root.height > root.topAppBarHeight ? root.height - root.topAppBarHeight : 520

        onAppLaunchedCallback: function() {
            EventBus.emit(Events.CLOSE_LEFTBAR);
        }
        onCommandExecutedCallback: function(cmd) {
            if (cmd.isAction) {
                EventBus.emit(Events.CLOSE_LEFTBAR);
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(appLauncherBase.baseLauncher.doGainFocus);
        } else {
            appLauncherBase.baseLauncher.resetState();
        }
    }
}
