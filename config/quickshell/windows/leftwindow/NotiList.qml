// windows/leftwindow/NotiList.qml
import QtQuick
// import Quickshell.Services.Notifications

import "../../utils"

ListView {
    id: notificationMenu
    objectName: "notifications"

    model: NotifServer.notifications.values
    Text {
        text: {
            // console.info(NotifServer.notifications.values);
            return "ss";
        }
    }

    delegate: Text {
        text: model.appName
    }
}
