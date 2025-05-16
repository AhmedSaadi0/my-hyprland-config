import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// import org.kde.kirigami as Kirigami

import "../../themes"
import "../../components"

// import "./dashboard"

ColumnLayout {
    id: layout
    // anchors.fill: parent
    spacing: 10

    property var windowsRadius: ThemeManager.selectedTheme.dimensions.elementRadius - 5
    property var selectedWindow: 0

    property ListModel tabModel: ListModel {
        ListElement {
            text: "Home"
            onClick: function () {
                myStackView.pop(null);
                selectedWindow = 0;
            }
        }

        ListElement {
            text: "Create"
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
            text: "About"
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
        height: layout.height - mainTabBar.height - 10
        initialItem: "dashboard/Dashboard.qml"

        pushEnter: Transition {
            PropertyAnimation {
                property: "x"
                from: myStackView.width
                to: 0
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        pushExit: Transition {
            PropertyAnimation {
                property: "x"
                from: 0
                to: -myStackView.width
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        // Pop animation (when going back)
        popEnter: Transition {
            PropertyAnimation {
                property: "x"
                from: -myStackView.width
                to: 0
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        popExit: Transition {
            PropertyAnimation {
                property: "x"
                from: 0
                to: myStackView.width
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }
}
