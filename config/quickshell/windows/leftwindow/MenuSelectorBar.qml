// windows/leftwindow/MenuSelectorBar.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// import org.kde.kirigami as Kirigami

import "../../themes"
import "../../components/tab"
// import "../../components"

import "./dashboard" as Dashboard
import "./monitoring" as Monitoring

ColumnLayout {
    id: root
    // anchors.fill: parent
    spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    readonly property int dashboardMenuIndex: 0
    readonly property int notificationMenuIndex: 1
    readonly property int weatherMenuIndex: 2
    readonly property int monotoringMenuIndex: 3
    readonly property int networkMenuIndex: 4

    property var windowsRadius: ThemeManager.selectedTheme.dimensions.elementRadius - 5
    property var currentMenu: dashboardMenuIndex
    property var currentList: []
    property var animationDuration: 400
    property var currentViewIndex: 0
    property int previousViewIndex: -1

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
        Monitoring.Main {}
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
                currentViewIndex = dashboardMenuIndex;
                myStackView.popToIndex(0);
                currentMenu = dashboardMenuIndex;
                currentList = [];
            }
        }

        ListElement {
            text: "Notifications"
            icon: "󰂞"
            onClick: function () {
                currentViewIndex = notificationMenuIndex;
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
                currentViewIndex = weatherMenuIndex;
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
                currentViewIndex = monotoringMenuIndex;
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
                currentViewIndex = networkMenuIndex;
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
        // layer.enabled: true
        // layer.effect: Shadow {} // Add specific shadow properties if needed

        // onCurrentIndexChanged: {
        //     if (root.currentViewIndex !== currentIndex) {
        //         // Update previousViewIndex *before* changing currentViewIndex
        //         // This is important for the slide animation direction.
        //         root.previousViewIndex = root.currentViewIndex;
        //         root.currentViewIndex = currentIndex;
        //     }
        // }
    }

    StackView {
        id: myStackView
        // width: ThemeManager.selectedTheme.dimensions.menuWidth
        width: root.width
        height: root.height - mainTabBar.height - root.spacing

        initialItem: dashboardMenu

        smooth: true

        // pushExit: Transition {
        //     ParallelAnimation {
        //         PropertyAnimation {
        //             property: "x"
        //             from: 0
        //             to: -parent.width
        //             duration: root.animationDuration
        //             easing.type: Easing.InQuart
        //         }
        //         PropertyAnimation {
        //             property: "rotation"
        //             from: 0
        //             to: 15
        //             duration: root.animationDuration
        //             easing.type: Easing.InBack
        //         }
        //         PropertyAnimation {
        //             property: "opacity"
        //             from: 1
        //             to: 0.5
        //             duration: root.animationDuration
        //         }
        //     }
        // }
        //
        // popEnter: Transition {
        //     ParallelAnimation {
        //         PropertyAnimation {
        //             property: "x"
        //             from: -parent.width
        //             to: 0
        //             duration: root.animationDuration
        //             easing.type: Easing.OutQuart
        //         }
        //         PropertyAnimation {
        //             property: "rotation"
        //             from: 15
        //             to: 0
        //             duration: root.animationDuration
        //             easing.type: Easing.OutBack
        //         }
        //         PropertyAnimation {
        //             property: "opacity"
        //             from: 0.5
        //             to: 1
        //             duration: root.animationDuration
        //         }
        //     }
        // }
        //
        // popExit: Transition {
        //     ParallelAnimation {
        //         PropertyAnimation {
        //             property: "x"
        //             from: 0
        //             to: parent.width
        //             duration: root.animationDuration
        //             easing.type: Easing.InQuart
        //         }
        //         PropertyAnimation {
        //             property: "rotation"
        //             from: 0
        //             to: -15
        //             duration: root.animationDuration
        //             easing.type: Easing.InBack
        //         }
        //         PropertyAnimation {
        //             property: "opacity"
        //             from: 1
        //             to: 0
        //             duration: root.animationDuration
        //         }
        //     }
        // }

        // --- Push ---
        pushEnter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.animationDuration
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 1.05
                    to: 1.0
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
                // Blur attempt (conceptual - see notes below)
                // NumberAnimation { target: effectOnSharedImage; property: "blurRadius"; from: 5; to: 0; duration: root.animationDuration }
            }
        }

        pushExit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 1.0
                    to: 0.95
                    duration: root.animationDuration
                    easing.type: Easing.InCubic
                }
                // Blur attempt
                // NumberAnimation { target: effectOnSharedImage; property: "blurRadius"; from: 0; to: 5; duration: root.animationDuration }
            }
        }

        // --- Pop (Symmetrical to Push) ---
        popEnter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.animationDuration
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.95
                    to: 1.0
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        popExit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: root.animationDuration
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 1.0
                    to: 1.05
                    duration: root.animationDuration
                    easing.type: Easing.InCubic
                }
            }
        }

        transformOrigin: Item.Center

        // Component.onCompleted: {
        //     myStackView.push(...root.menuViews);
        // }
    }
    // StackLayout {
    //     id: viewContainer
    //     Layout.fillWidth: true  // Take available width
    //     Layout.fillHeight: true // Take available height (important for ColumnLayout)
    //     currentIndex: root.currentViewIndex
    //     clip: true
    //
    //     readonly property int slideOffset: 50 // How far items slide from/to
    //
    //     Dashboard.Dashboard {
    //         id: dashboard
    //         readonly property int myIndex: root.dashboardMenuIndex
    //         opacity: viewContainer.currentIndex === myIndex ? 1 : 0
    //
    //         Behavior on opacity {
    //             NumberAnimation {
    //                 duration: root.animationDuration
    //             }
    //         }
    //
    //         // Transform for Slide Animation
    //         // Slides in from left if new index is greater, from right if smaller
    //         transform: Translate {
    //             x: {
    //                 if (viewContainer.currentIndex === dashboard.myIndex) {
    //                     return 0; // Final position
    //                 } else {
    //                     if (root.previousViewIndex !== -1 && root.currentViewIndex !== dashboard.myIndex) {
    //                         // If I was the one just navigated away from
    //                         if (root.previousViewIndex === dashboard.myIndex) {
    //                             return root.currentViewIndex > dashboard.myIndex ? -viewContainer.width : viewContainer.width;
    //                         }
    //                     }
    //                     // Default off-screen position if not involved in current transition
    //                     return viewContainer.width; // Arbitrary default off-screen
    //                 }
    //             }
    //             // When this item *becomes* the current item, animate its x position.
    //             Behavior on x {
    //                 enabled: viewContainer.currentIndex === dashboard.myIndex || (viewContainer.currentIndex !== dashboard.myIndex && root.previousViewIndex === dashboard.myIndex)
    //                 NumberAnimation {
    //                     duration: root.animationDuration
    //                     easing.type: Easing.OutQuad
    //                 }
    //             }
    //         }
    //     }
    //
    //     NotiList {
    //         id: notifications
    //         readonly property int myIndex: root.notificationMenuIndex
    //         opacity: viewContainer.currentIndex === myIndex ? 1 : 0
    //
    //         Behavior on opacity {
    //             NumberAnimation {
    //                 duration: root.animationDuration
    //             }
    //         }
    //
    //         transform: Translate {
    //             x: {
    //                 if (viewContainer.currentIndex === notifications.myIndex)
    //                     return 0;
    //                 if (root.currentViewIndex === notifications.myIndex && root.previousViewIndex !== -1) {
    //                     return root.previousViewIndex < notifications.myIndex ? -viewContainer.slideOffset : viewContainer.slideOffset;
    //                 }
    //                 if (root.currentViewIndex !== notifications.myIndex && root.previousViewIndex === notifications.myIndex) {
    //                     return root.currentViewIndex > notifications.myIndex ? -viewContainer.slideOffset : viewContainer.slideOffset;
    //                 }
    //                 return 0; // (or viewContainer.width to keep it off-screen)
    //             }
    //             Behavior on x {
    //                 enabled: (viewContainer.currentIndex === notifications.myIndex && x !== 0) || (root.previousViewIndex === notifications.myIndex && viewContainer.currentIndex !== notifications.myIndex && x === 0)
    //                 NumberAnimation {
    //                     duration: root.animationDuration
    //                     easing.type: Easing.OutCubic
    //                 }
    //             }
    //         }
    //     }
    //
    //     Dashboard.Dashboard2 {
    //         id: weather
    //         readonly property int myIndex: root.weatherMenuIndex
    //         opacity: viewContainer.currentIndex === weather.myIndex ? 1 : 0
    //
    //         Behavior on opacity {
    //             NumberAnimation {
    //                 duration: root.animationDuration
    //             }
    //         }
    //
    //         // Simple Slide-in for the current item
    //         x: viewContainer.currentIndex === weather.myIndex ? 0 : (root.currentViewIndex > root.previousViewIndex ? viewContainer.width : -viewContainer.width)
    //         Behavior on x {
    //             enabled: viewContainer.currentIndex === weather.myIndex // Only animate x when this item *becomes* current
    //             NumberAnimation {
    //                 duration: root.animationDuration
    //                 easing.type: Easing.OutQuad
    //             }
    //         }
    //     }
    //
    //     Monitoring.Main {
    //         id: monotoring
    //         readonly property int myIndex: root.monotoringMenuIndex
    //         opacity: viewContainer.currentIndex === myIndex ? 1 : 0
    //
    //         Behavior on opacity {
    //             NumberAnimation {
    //                 duration: root.animationDuration
    //             }
    //         }
    //
    //         x: viewContainer.currentIndex === monotoring.myIndex ? 0 : (root.currentViewIndex > root.previousViewIndex ? viewContainer.width : -viewContainer.width)
    //         Behavior on x {
    //             enabled: viewContainer.currentIndex === monotoring.myIndex
    //             NumberAnimation {
    //                 duration: root.animationDuration
    //                 easing.type: Easing.OutQuad
    //             }
    //         }
    //     }
    //
    //     Dashboard.Dashboard3 {
    //         id: network
    //         readonly property int myIndex: root.networkMenuIndex
    //         opacity: viewContainer.currentIndex === network.myIndex ? 1 : 0
    //
    //         Behavior on opacity {
    //             NumberAnimation {
    //                 duration: root.animationDuration
    //             }
    //         }
    //
    //         x: viewContainer.currentIndex === network.myIndex ? 0 : (root.currentViewIndex > root.previousViewIndex ? viewContainer.width : -viewContainer.width)
    //         Behavior on x {
    //             enabled: viewContainer.currentIndex === network.myIndex
    //             NumberAnimation {
    //                 duration: root.animationDuration
    //                 easing.type: Easing.OutQuad
    //             }
    //         }
    //     }
    // }
    //
    // Component.onCompleted: {
    //     console.log("MyTabView component initialized. All StackLayout pages are ready.");
    //     // If this component might be initialized with a currentViewIndex other than the default,
    //     // ensure the TabBar reflects it. The two-way binding should handle this,
    //     // but an explicit set can be a safeguard or for initial setup if not relying on binding.
    //     mainTabBar.currentIndex = root.currentViewIndex;
    // }
}
