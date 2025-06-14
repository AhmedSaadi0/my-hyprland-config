// windows/leftwindow/MenuSelectorBar.qml

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 // SwipeView is in Controls
import "../../themes"
import "../../components/tab"
import "./dashboard" as Dashboard
import "./monitoring" as Monitoring

ColumnLayout {
    id: root
    spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    // The single source of truth for the currently active tab index.
    property int currentIndex: 0

    // The data model for the tabs.
    // Note: The onClick handlers have been removed as they are no longer needed.
    // The TabBar component itself will manage changing the index.
    property ListModel tabModel: ListModel {
        ListElement {
            text: "Control"
            icon: "󰨝"
        }
        ListElement {
            text: "Notifications"
            icon: "󰂞"
        }
        ListElement {
            text: "Weather"
            icon: "󰨹"
        }
        ListElement {
            text: "Monitors"
            icon: ""
        }
        ListElement {
            text: "Network"
            icon: ""
        }
    }

    // --- Tab Bar ---
    // This bar displays the tabs and allows the user to change the currentIndex.
    TabBar {
        id: mainTabBar
        Layout.fillWidth: true
        barHeight: 35
        model: tabModel

        // Two-way binding:
        // 1. When root.currentIndex changes, the TabBar updates.
        // 2. When the user clicks a tab, the TabBar's currentIndex changes,
        //    which in turn updates root.currentIndex.
        currentIndex: root.currentIndex
        onCurrentIndexChanged: root.currentIndex = currentIndex
    }

    // --- Page Container ---
    // SwipeView is designed for exactly this use-case: a set of pages
    // that the user can swipe between, with smooth, built-in animations.
    SwipeView {
        id: viewContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true // Ensures pages don't draw outside the container during animation

        // Two-way binding with the root's currentIndex.
        // 1. When root.currentIndex changes (e.g., from the TabBar), the SwipeView animates to the correct page.
        // 2. If the user swipes, the SwipeView's currentIndex changes, which updates the root.currentIndex.
        currentIndex: root.currentIndex
        onCurrentIndexChanged: root.currentIndex = currentIndex

        // --- Pages ---
        // The pages are now direct children of the SwipeView.
        // No need to manually manage 'x' or 'visible' properties.
        // The SwipeView handles all positioning and visibility automatically.

        Dashboard.Dashboard {}

        NotiList {}

        Dashboard.Dashboard2 {}

        Monitoring.Main {}

        Dashboard.Dashboard3 {}
    }
}
