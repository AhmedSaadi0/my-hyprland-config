import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// import org.kde.kirigami as Kirigami

import "../../themes"
import "../../components"

import "./dashboard" as Dashboard

ColumnLayout {
    id: layout
    // anchors.fill: parent
    spacing: 10

    property var windowsRadius: ThemeManager.selectedTheme.dimensions.elementRadius - 5
    property var selectedWindow: 0

    property var animationDuration: 300

    property ListModel tabModel: ListModel {
        ListElement {
            text: "Control"
            onClick: function () {
                myStackView.pop(null);
                selectedWindow = 0;
            }
        }

        ListElement {
            text: "Notifications"
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

    CustomTabBar {
        id: mainTabBar
        model: tabModel
        barWidth: parent.width + 2
        barHeight: 30
    }

    StackView {
        id: myStackView
        width: layout.width
        height: layout.height - mainTabBar.height - layout.spacing

        initialItem: "dashboard/Dashboard.qml"

        // --- BEAUTIFIED ZOOM & CROSSFADE ANIMATIONS ---

        // When a NEW item is pushed ON TOP of the stack
        pushEnter: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: parent.width
                    to: 0
                    duration: 200
                    easing.type: Easing.OutQuart
                }
                PropertyAnimation {
                    property: "rotation"
                    from: -15
                    to: 0
                    duration: 200
                    easing.type: Easing.OutBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                }
            }
        }

        pushExit: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: 0
                    to: -parent.width
                    duration: 200
                    easing.type: Easing.InQuart
                }
                PropertyAnimation {
                    property: "rotation"
                    from: 0
                    to: 15
                    duration: 200
                    easing.type: Easing.InBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to: 0.5
                    duration: 200
                }
            }
        }

        popEnter: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: -parent.width
                    to: 0
                    duration: 200
                    easing.type: Easing.OutQuart
                }
                PropertyAnimation {
                    property: "rotation"
                    from: 15
                    to: 0
                    duration: 200
                    easing.type: Easing.OutBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0.5
                    to: 1
                    duration: 200
                }
            }
        }

        popExit: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: 0
                    to: parent.width
                    duration: 200
                    easing.type: Easing.InQuart
                }
                PropertyAnimation {
                    property: "rotation"
                    from: 0
                    to: -15
                    duration: 200
                    easing.type: Easing.InBack
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 200
                }
            }
        }

        transformOrigin: Item.Center // ESSENTIAL for scale animations around the center
    }
}
