// components/AppLauncherBase.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import "root:/themes"
import "root:/components"
import "root:/components/unified"
import "root:/config"
import "root:/config/EventNames.js" as Events
import "root:/windows/leftwindow/applauncher"
import "root:/utils"

Item {
    id: root

    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property int contentPadding: Math.max(6, Math.round(dims.menuWidgetsMargin / 2))
    readonly property int contentSpacing: Math.max(4, Math.round((dims.spacingSmall || 8) / 2))

    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitHeight: appsHeader.implicitHeight + 320

    // ==========================================================================
    // Callback Hooks
    // ==========================================================================

    property var onAppLaunchedCallback: null
    property var onCommandExecutedCallback: null
    property var onResetStateCallback: null
    property var onRequestFocusCallback: null

    // Exposed baseLauncher
    property alias baseLauncher: baseLauncher

    // ==========================================================================
    // Base Logic Engine
    // ==========================================================================

    BaseLauncher {
        id: baseLauncher
        selectedCategory: appsHeader.selectedCategory

        onAppLaunchedCallback: function () {
            if (root.onAppLaunchedCallback)
                root.onAppLaunchedCallback();
        }
        onCommandExecutedCallback: function (cmd) {
            if (root.onCommandExecutedCallback)
                root.onCommandExecutedCallback(cmd);
        }
        onResetStateCallback: function () {
            appsHeader.searchText = "";
            appsHeader.selectedCategory = "";
            if (root.onResetStateCallback)
                root.onResetStateCallback();
        }
        onRequestFocusCallback: function () {
            appsHeader.forceSearchFocus();
            if (root.onRequestFocusCallback)
                root.onRequestFocusCallback();
        }
    }

    // ==========================================================================
    // AppsHeader with CategoryFilter + Search
    // ==========================================================================

    AppsHeader {
        id: appsHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.contentPadding
        anchors.rightMargin: root.contentPadding

        onSearchTextChanged: {
            baseLauncher.searchText = appsHeader.searchText;
            Qt.callLater(baseLauncher.ensureCommandSelection);
            Qt.callLater(baseLauncher.ensureAppSelection);
        }
        onSelectedCategoryChanged: Qt.callLater(baseLauncher.ensureAppSelection)

        onMoveSelection: dir => baseLauncher.moveSelection(dir)
        onActivateSelection: baseLauncher.activateSelection()
        onEscapePressed: {
            if (baseLauncher.activeCommandView !== "") {
                baseLauncher.activeCommandView = "";
                appsHeader.searchText = "";
                baseLauncher.searchText = "";
                appsHeader.forceSearchFocus();
            }
        }
    }

    // ==========================================================================
    // Content Stack (Custom Animated Container replacing SwipeView)
    // ==========================================================================

    Item {
        id: contentStack
        anchors.top: appsHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: root.contentSpacing
        anchors.leftMargin: root.contentPadding
        anchors.rightMargin: root.contentPadding
        anchors.bottomMargin: root.contentPadding
        clip: true

        readonly property int currentIndex: baseLauncher.currentViewIndex

        // إعدادات النابض الخاصة بالحركة الهلامية (Jelly Physics)
        readonly property real springStrength: 3.5  // قوة ارتداد النابض
        readonly property real springDamping: 0.63   // مرونة النابض (كلما قلت زاد الاهتزاز الهلامي)
        readonly property real springMass: 0.85      // كتلة العناصر أثناء الحركة

        // Page 0: Apps List
        Item {
            id: page0
            anchors.fill: parent
            visible: opacity > 0.01

            readonly property bool isActive: contentStack.currentIndex === 0

            // ربط الخصائص للحركة الانتقالية
            x: isActive ? 0 : (contentStack.currentIndex < 0 ? parent.width : -parent.width * 0.4)
            opacity: isActive ? 1.0 : 0.0
            scale: isActive ? 1.0 : 0.9

            // سلوك الانميشن الهلامي
            Behavior on x {
                SpringAnimation {
                    spring: contentStack.springStrength
                    damping: contentStack.springDamping
                    mass: contentStack.springMass
                }
            }
            Behavior on scale {
                SpringAnimation {
                    spring: contentStack.springStrength
                    damping: contentStack.springDamping
                    mass: contentStack.springMass
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            ListView {
                id: appListView
                anchors.fill: parent
                clip: true
                model: baseLauncher.filteredAppsModel.values
                spacing: 4
                topMargin: 2
                bottomMargin: root.contentPadding
                boundsBehavior: Flickable.StopAtBounds

                // حركة تباعد العناصر الهلامية عند الفلترة أو إعادة الترتيب
                displaced: Transition {
                    SpringAnimation {
                        properties: "x,y"
                        spring: 3.2
                        damping: 0.65
                        mass: 0.8
                    }
                }

                // حركة ظهور العناصر عند التصفية
                add: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 200
                        }
                        SpringAnimation {
                            property: "scale"
                            from: 0.8
                            to: 1.0
                            spring: 3.0
                            damping: 0.6
                        }
                    }
                }

                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0.0
                            duration: 150
                        }
                        NumberAnimation {
                            property: "scale"
                            to: 0.8
                            duration: 150
                        }
                    }
                }

                displayMarginBeginning: 40
                displayMarginEnd: 40

                delegate: AppDelegate {
                    entryData: modelData
                    isSelected: baseLauncher.selectedAppIndex === index
                    isHighlighted: baseLauncher.selectedAppIndex >= 0 ? index === baseLauncher.selectedAppIndex : index === baseLauncher.getFirstActualAppIndex()
                    isFavorite: modelData && modelData.appData ? baseLauncher.isFavorite(modelData.appData) : false
                    isPinnedToDock: modelData && modelData.appData ? baseLauncher.isPinnedToDock(modelData.appData) : false

                    onItemClicked: {
                        if (modelData && modelData.appData) {
                            if (typeof modelData.appData.execute === "function") {
                                modelData.appData.execute();
                            } else {
                                baseLauncher.launchApp(modelData.appData.command, modelData.appData.workingDirectory);
                            }
                            if (root.onAppLaunchedCallback) {
                                root.onAppLaunchedCallback();
                            }
                        }
                    }
                    onFavoriteToggled: {
                        if (modelData && modelData.appData) {
                            baseLauncher.toggleFavorite(modelData.appData);
                        }
                    }
                    onPinToggled: {
                        if (modelData && modelData.appData) {
                            baseLauncher.togglePinToDock(modelData.appData);
                        }
                    }
                    onHovered: {
                        if (modelData && !modelData.isHeader) {
                            baseLauncher.selectedAppIndex = index;
                        }
                    }
                }

                Connections {
                    target: baseLauncher
                    function onSelectedAppIndexChanged() {
                        if (baseLauncher.selectedAppIndex >= 0) {
                            appListView.currentIndex = baseLauncher.selectedAppIndex;
                            appListView.positionViewAtIndex(baseLauncher.selectedAppIndex, ListView.Contain);
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: baseLauncher.filteredAppsModel.values.length === 0
                    text: "No applications found"
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.onSurfaceVariant
                }
            }
        }

        // Page 1: Commands List
        Item {
            id: page1
            anchors.fill: parent
            visible: opacity > 0.01

            readonly property bool isActive: contentStack.currentIndex === 1

            x: isActive ? 0 : (contentStack.currentIndex < 1 ? parent.width : -parent.width * 0.4)
            opacity: isActive ? 1.0 : 0.0
            scale: isActive ? 1.0 : 0.9

            Behavior on x {
                SpringAnimation {
                    spring: contentStack.springStrength
                    damping: contentStack.springDamping
                    mass: contentStack.springMass
                }
            }
            Behavior on scale {
                SpringAnimation {
                    spring: contentStack.springStrength
                    damping: contentStack.springDamping
                    mass: contentStack.springMass
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            ListView {
                id: commandListView
                anchors.fill: parent
                model: baseLauncher.filteredCommands
                clip: true
                spacing: 4
                topMargin: 2
                bottomMargin: root.contentPadding

                displaced: Transition {
                    SpringAnimation {
                        properties: "x,y"
                        spring: 3.2
                        damping: 0.65
                        mass: 0.8
                    }
                }

                add: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 200
                        }
                        SpringAnimation {
                            property: "scale"
                            from: 0.8
                            to: 1.0
                            spring: 3.0
                            damping: 0.6
                        }
                    }
                }

                delegate: CommandItem {
                    width: commandListView.width
                    commandData: modelData
                    isHighlighted: index === (baseLauncher.selectedCommandIndex >= 0 ? baseLauncher.selectedCommandIndex : 0)
                    onClicked: baseLauncher.executeCommand(commandData)
                }

                Text {
                    anchors.centerIn: parent
                    visible: baseLauncher.filteredCommands.length === 0
                    text: "No commands found"
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.onSurfaceVariant
                }
            }
        }

        // Page 2: Wallpaper Selector
        Item {
            id: page2
            anchors.fill: parent
            visible: opacity > 0.01

            readonly property bool isActive: contentStack.currentIndex === 2

            x: isActive ? 0 : (contentStack.currentIndex < 2 ? parent.width : -parent.width * 0.4)
            opacity: isActive ? 1.0 : 0.0
            scale: isActive ? 1.0 : 0.9

            Behavior on x {
                SpringAnimation {
                    spring: contentStack.springStrength
                    damping: contentStack.springDamping
                    mass: contentStack.springMass
                }
            }
            Behavior on scale {
                SpringAnimation {
                    spring: contentStack.springStrength
                    damping: contentStack.springDamping
                    mass: contentStack.springMass
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            WallpaperSelector {
                anchors.fill: parent
                onWallpaperSelected: path => {
                    baseLauncher.activeCommandView = "";
                    appsHeader.searchText = "";
                    baseLauncher.searchText = "";
                    appsHeader.forceSearchFocus();
                    if (root.onAppLaunchedCallback)
                        root.onAppLaunchedCallback();
                }
                onCloseRequested: {
                    baseLauncher.activeCommandView = "";
                    appsHeader.searchText = "";
                    baseLauncher.searchText = "";
                    appsHeader.forceSearchFocus();
                }
            }
        }
    }

    // ==========================================================================
    // Keyboard Handler
    // ==========================================================================

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            EventBus.emit(Events.APP_MENU_CLOSE_ALL, {});
            if (baseLauncher.activeCommandView !== "") {
                baseLauncher.activeCommandView = "";
                appsHeader.searchText = "";
                baseLauncher.searchText = "";
                appsHeader.forceSearchFocus();
                event.accepted = true;
                return;
            }
            if (root.onAppLaunchedCallback)
                root.onAppLaunchedCallback();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Down) {
            baseLauncher.moveSelection(1);
            appsHeader.forceSearchFocus();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Up) {
            baseLauncher.moveSelection(-1);
            appsHeader.forceSearchFocus();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            baseLauncher.activateSelection();
            appsHeader.forceSearchFocus();
            event.accepted = true;
            return;
        }

        if (event.text && !appsHeader.activeFocus) {
            appsHeader.appendText(event.text);
            baseLauncher.searchText = appsHeader.searchText;
            event.accepted = true;
        }
    }

    // ==========================================================================
    // State Management
    // ==========================================================================

    onVisibleChanged: {
        if (visible) {
            appsHeader.forceSearchFocus();
        } else {
            baseLauncher.resetState();
        }
    }

    Component.onCompleted: {
        Qt.callLater(baseLauncher.ensureCommandSelection);
        Qt.callLater(baseLauncher.ensureAppSelection);
    }

    // ==========================================================================
    // Mode Change Handler
    // ==========================================================================

    Connections {
        target: baseLauncher
        function onIsCommandModeChanged() {
            if (!baseLauncher.isCommandMode && baseLauncher.activeCommandView !== "") {
                baseLauncher.activeCommandView = "";
            }
            baseLauncher.ensureCommandSelection();
            baseLauncher.ensureAppSelection();
        }

        function onSelectedCommandIndexChanged() {
            if (baseLauncher.selectedCommandIndex >= 0) {
                commandListView.currentIndex = baseLauncher.selectedCommandIndex;
                commandListView.positionViewAtIndex(baseLauncher.selectedCommandIndex, ListView.Contain);
            }
        }
    }
}
