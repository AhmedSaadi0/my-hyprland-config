import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// import org.kde.kirigami as Kirigami

import "../../themes"
import "../../components/tab"

import "./dashboard" as Dashboard

ColumnLayout {
    id: root
    // anchors.fill: parent
    spacing: 10

    property var windowsRadius: ThemeManager.selectedTheme.dimensions.elementRadius - 5
    property var selectedWindow: 0

    property var animationDuration: 400

    property ListModel tabModel: ListModel {
        ListElement {
            text: "Control"
            icon: "󰨝"
            onClick: function () {
                myStackView.pop(null);
                selectedWindow = 0;
            }
        }

        ListElement {
            text: "Notifications"
            icon: "󰂞"
            onClick: function () {
                if (selectedWindow == 1) {
                    return;
                }
                if (selectedWindow > 1) {
                    myStackView.pop("dashboard/Dashboard3.qml");
                } else {
                    myStackView.push("dashboard/Dashboard.qml");
                    myStackView.push("dashboard/Dashboard2.qml");
                }
                selectedWindow = 1;
            }
        }

        ListElement {
            text: "Weather"
            icon: "󰨹"
            onClick: function () {
                if (selectedWindow == 2) {
                    return;
                }
                if (selectedWindow > 2) {
                    myStackView.pop();
                } else {
                    myStackView.push("dashboard/Dashboard.qml");
                    myStackView.push("dashboard/Dashboard2.qml");
                    myStackView.push("dashboard/Dashboard3.qml");
                }
                selectedWindow = 2;
            }
        }

        ListElement {
            text: "Monitors"
            icon: ""
            onClick: function () {
                if (selectedWindow == 2) {
                    return;
                }
                if (selectedWindow > 2) {
                    myStackView.pop();
                } else {
                    myStackView.push("dashboard/Dashboard.qml");
                    myStackView.push("dashboard/Dashboard2.qml");
                    myStackView.push("dashboard/Dashboard3.qml");
                }
                selectedWindow = 2;
            }
        }

        ListElement {
            text: "Network"
            icon: ""
            onClick: function () {
                if (selectedWindow == 2) {
                    return;
                }
                if (selectedWindow > 2) {
                    myStackView.pop();
                } else {
                    myStackView.push("dashboard/Dashboard.qml");
                    myStackView.push("dashboard/Dashboard2.qml");
                    myStackView.push("dashboard/Dashboard3.qml");
                }
                selectedWindow = 2;
            }
        }
    }

    TabBar {
        id: mainTabBar
        model: tabModel
        barWidth: parent.width
        barHeight: 30
    }

    StackView {
        id: myStackView
        width: root.width
        height: root.height - mainTabBar.height - root.spacing

        initialItem: "dashboard/Dashboard.qml"

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
    }
}
