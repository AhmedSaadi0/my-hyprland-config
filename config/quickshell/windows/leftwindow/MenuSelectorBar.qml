import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// import org.kde.kirigami as Kirigami

import "../../themes"
import "../../components/tab"
import "../../components"

import "./dashboard" as Dashboard
import "./monitoring" as Monitoring

ColumnLayout {
    id: root
    // anchors.fill: parent
    spacing: 10

    readonly property int dashboardMenuIndex: 0
    readonly property int notificationMenuIndex: 1
    readonly property int weatherMenuIndex: 2
    readonly property int monotoringMenuIndex: 3
    readonly property int networkMenuIndex: 4

    property var windowsRadius: ThemeManager.selectedTheme.dimensions.elementRadius - 5
    property var currentMenu: dashboardMenuIndex
    property var currentList: []
    property var animationDuration: 400

    Component {
        id: dashboardMenu
        Dashboard.Dashboard {}
    }

    Component {
        id: notificationMenu
        NotiList {}
    }

    Component {
        id: weatherMenu
        Dashboard.Dashboard2 {}
    }

    Component {
        id: monotoringMenu
        Monitoring.Main {
            id: md
        }
    }

    Component {
        id: networkMenu
        Dashboard.Dashboard3 {}
    }

    property ListModel tabModel: ListModel {
        ListElement {
            text: "Control"
            icon: "󰨝"
            onClick: function () {
                myStackView.popToIndex(0);
                currentMenu = dashboardMenuIndex;
                currentList = [];
            }
        }

        ListElement {
            text: "Notifications"
            icon: "󰂞"
            onClick: function () {
                if (currentMenu === notificationMenuIndex) {
                    return;
                }
                if (currentMenu > notificationMenuIndex) {
                    myStackView.popToIndex(notificationMenuIndex);
                    root.popToIndex(notificationMenuIndex);
                } else {
                    root.addToList(notificationMenu);
                }
                currentMenu = notificationMenuIndex;
            }
        }

        ListElement {
            text: "Weather"
            icon: "󰨹"
            onClick: function () {
                if (currentMenu === weatherMenuIndex) {
                    return;
                }
                if (currentMenu > weatherMenuIndex) {
                    myStackView.popToIndex(weatherMenuIndex);
                    root.popToIndex(weatherMenuIndex);
                } else {
                    root.addToList(notificationMenu);
                    root.addToList(weatherMenu);
                }
                currentMenu = weatherMenuIndex;
            }
        }

        ListElement {
            text: "Monitors"
            icon: ""
            onClick: function () {
                if (currentMenu === monotoringMenuIndex) {
                    return;
                }
                if (currentMenu > monotoringMenuIndex) {
                    myStackView.popToIndex(monotoringMenuIndex);
                    root.popToIndex(monotoringMenuIndex);
                } else {
                    root.addToList(notificationMenu);
                    root.addToList(weatherMenu);
                    root.addToList(monotoringMenu);
                }
                currentMenu = monotoringMenuIndex;
            }
        }

        ListElement {
            text: "Network"
            icon: ""
            onClick: function () {
                if (currentMenu === networkMenuIndex) {
                    return;
                }
                if (currentMenu > networkMenuIndex) {
                    myStackView.popToIndex(networkMenuIndex);
                    root.popToIndex(networkMenuIndex);
                } else {
                    root.addToList(notificationMenu);
                    root.addToList(weatherMenu);
                    root.addToList(monotoringMenu);
                    root.addToList(networkMenu);
                }
                currentMenu = networkMenuIndex;
            }
        }
    }

    function addToList(menu) {
        if (currentList.includes(menu)) {
            return;
        }
        currentList.push(menu);
        myStackView.push(menu);
    }

    function popToIndex(index) {
        if (index < currentList.length) {
            currentList.splice(index);
        } else {
            currentList = [];
        }
    }

    TabBar {
        id: mainTabBar
        model: tabModel
        barWidth: parent.width
        barHeight: 35
        layer.enabled: true
        layer.effect: Shadow {} // Add specific shadow properties if needed

    }

    StackView {
        id: myStackView
        width: root.width
        height: root.height - mainTabBar.height - root.spacing

        initialItem: dashboardMenu

        smooth: true

        // --- BEAUTIFIED ZOOM & CROSSFADE ANIMATIONS ---

        // When a NEW item is pushed ON TOP of the stack
        pushEnter: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: parent.width
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.OutQuart
                }
                PropertyAnimation {
                    property: "rotation"
                    from: -15
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.OutBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.animationDuration
                }
            }
        }

        pushExit: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: 0
                    to: -parent.width
                    duration: root.animationDuration
                    easing.type: Easing.InQuart
                }
                PropertyAnimation {
                    property: "rotation"
                    from: 0
                    to: 15
                    duration: root.animationDuration
                    easing.type: Easing.InBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to: 0.5
                    duration: root.animationDuration
                }
            }
        }

        popEnter: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: -parent.width
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.OutQuart
                }
                PropertyAnimation {
                    property: "rotation"
                    from: 15
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.OutBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0.5
                    to: 1
                    duration: root.animationDuration
                }
            }
        }

        popExit: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: 0
                    to: parent.width
                    duration: root.animationDuration
                    easing.type: Easing.InQuart
                }
                PropertyAnimation {
                    property: "rotation"
                    from: 0
                    to: -15
                    duration: root.animationDuration
                    easing.type: Easing.InBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: root.animationDuration
                }
            }
        }

        transformOrigin: Item.Center // ESSENTIAL for scale animations around the center

        // Component.onCompleted: {
        //     myStackView.push(...root.menuViews);
        // }
    }
}
