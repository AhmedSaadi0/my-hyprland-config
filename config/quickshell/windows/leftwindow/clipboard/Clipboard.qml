// windows/leftwindow/clipboard/Clipboard.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/config/EventNames.js" as Events
import "root:/config"
import "root:/services"
import "root:/themes"
import "root:/components"
import "../base"

BaseMenuView {
    id: root

    menuTitle: qsTr("Clipboard")
    menuIcon: "󰅍"
    showPrimaryAction: false

    Layout.fillWidth: true
    Layout.fillHeight: true

    readonly property var dims: ThemeManager.selectedTheme.dimensions

    // --- Logic & Properties ---
    property int selectedIndex: -1

    function matchesSearchAt(idx) {
        if (idx < 0 || idx >= listView.count)
            return false;
        if (!listView.currentSearchText || listView.currentSearchText === "")
            return true;
        const item = listView.model.get(idx);
        if (!item || item.text === undefined)
            return false;
        return item.text.toLowerCase().indexOf(listView.currentSearchText.toLowerCase()) !== -1;
    }

    function firstMatchingIndex() {
        for (let i = 0; i < listView.count; i++) {
            if (matchesSearchAt(i))
                return i;
        }
        return -1;
    }

    function lastMatchingIndex() {
        for (let i = listView.count - 1; i >= 0; i--) {
            if (matchesSearchAt(i))
                return i;
        }
        return -1;
    }

    function nextMatchingIndex(start, dir) {
        let i = start + dir;
        while (i >= 0 && i < listView.count) {
            if (matchesSearchAt(i))
                return i;
            i += dir;
        }
        return -1;
    }

    function ensureSelection() {
        if (listView.count === 0) {
            selectedIndex = -1;
            return;
        }
        if (!matchesSearchAt(selectedIndex))
            selectedIndex = firstMatchingIndex();
    }

    function moveSelection(dir) {
        if (listView.count === 0)
            return;
        let idx = selectedIndex;
        if (idx < 0)
            idx = dir > 0 ? firstMatchingIndex() : lastMatchingIndex();
        else
            idx = nextMatchingIndex(idx, dir);
        if (idx !== -1)
            selectedIndex = idx;
    }

    function activateSelection() {
        let idx = selectedIndex;
        if (idx < 0)
            idx = firstMatchingIndex();
        if (idx < 0 || idx >= listView.count)
            return;

        const item = listView.model.get(idx);
        if (!item)
            return;

        ClipboardService.activate(item.clipId);
        EventBus.emit(Events.CLOSE_LEFTBAR);
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Down) {
            moveSelection(1);
            header.forceSearchFocus();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Up) {
            moveSelection(-1);
            header.forceSearchFocus();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            activateSelection();
            header.forceSearchFocus();
            event.accepted = true;
            return;
        }
    }

    // --- Header Section ---
    headerContent: ClipboardHeader {
        id: header
        width: root.width
        onClearAllClicked: listView.animateAndClearAll()
        onMoveSelection: dir => root.moveSelection(dir)
        onActivateSelection: root.activateSelection()
    }

    // --- Main List Area ---
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        // ─── الإصلاح الجذري هنا ───
        // نأخذ مساحة النافذة ونطرح منها مساحة الهيدر التقريبية (حوالي 120 بكسل) لتظهر العناصر بوضوح.
        Layout.preferredHeight: root.height > 120 ? root.height - 120 : 500
        implicitHeight: 0

        Layout.leftMargin: root.dims.menuWidgetsMargin
        Layout.rightMargin: root.dims.menuWidgetsMargin
        Layout.bottomMargin: root.dims.menuWidgetsMargin

        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        rightPadding: ScrollBar.vertical.visible ? ScrollBar.vertical.width : 0

        ListView {
            id: listView
            anchors.fill: parent

            spacing: 0
            topMargin: 5
            bottomMargin: 10

            model: ClipboardService.model
            cacheBuffer: 2000

            property string currentSearchText: header.searchText
            onCurrentSearchTextChanged: root.ensureSelection()
            onCountChanged: root.ensureSelection()

            property real pullOffset: 0
            property real shockOffset: 0
            property bool userIsDragging: false

            function triggerSway() {
                swayAnim.restart();
            }

            function animateAndClearAll() {
                if (listView.count > 0) {
                    ClipboardService.wipe();
                }
            }

            Behavior on pullOffset {
                enabled: !listView.userIsDragging
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            SequentialAnimation {
                id: swayAnim
                NumberAnimation {
                    target: listView
                    property: "shockOffset"
                    to: 7
                    duration: 150
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: listView
                    property: "shockOffset"
                    to: 0
                    duration: 600
                    easing.type: Easing.OutElastic
                    easing.period: 0.8
                    easing.amplitude: 0.5
                }
            }

            SequentialAnimation {
                id: clearAllSequence
                ParallelAnimation {
                    NumberAnimation {
                        target: listView
                        property: "pullOffset"
                        to: 300
                        duration: 300
                        easing.type: Easing.InBack
                        easing.overshoot: 1.2
                    }
                    NumberAnimation {
                        target: listView
                        property: "opacity"
                        to: 0
                        duration: 250
                    }
                }
                PropertyAction {
                    target: listView
                    property: "pullOffset"
                    value: 0
                }
                PropertyAction {
                    target: listView
                    property: "opacity"
                    value: 1
                }
            }

            add: Transition {
                NumberAnimation {
                    property: "height"
                    from: 0
                    to: 50
                    duration: 300
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 300
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 400
                    easing.type: Easing.OutQuart
                }
            }

            remove: Transition {
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: 200
                        }
                        NumberAnimation {
                            property: "x"
                            to: 100
                            duration: 250
                            easing.type: Easing.InQuad
                        }
                    }
                    NumberAnimation {
                        property: "height"
                        to: 0
                        duration: 300
                        easing.type: Easing.InOutQuart
                    }
                }
            }

            delegate: ClipboardItem {}
        }
    }

    Component.onCompleted: {
        ClipboardService.refresh();
        EventBus.on(Events.LEFT_MENU_IS_OPENED, function (idx) {
            if (idx === 5) {
                ClipboardService.refresh();
                listView.positionViewAtBeginning();
                header.focusSearch();
                root.ensureSelection();
            }
        }, root);
    }

    onSelectedIndexChanged: {
        if (selectedIndex >= 0) {
            listView.currentIndex = selectedIndex;
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        } else {
            listView.currentIndex = -1;
        }
    }
}
