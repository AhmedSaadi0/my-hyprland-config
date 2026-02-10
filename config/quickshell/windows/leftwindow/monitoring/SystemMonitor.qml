// windows/leftwindow/monitoring/SystemMonitor.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/themes"

// استيراد المكونات المحلية
import "./components"

Item {
    id: root

    // --- Layout Properties ---
    Layout.fillWidth: true
    // جعل ارتفاع العنصر يساوي ارتفاع المحتوى الداخلي (ColumnLayout)
    implicitHeight: mainLayout.implicitHeight

    // --- Theme & Props ---
    readonly property var theme: ThemeManager.selectedTheme
    property string expandedEventId: ""
    property bool showBootDetails: false

    // --- Data Model ---
    ListModel {
        id: eventModel
        ListElement {
            eventId: "evt_1"
            type: "CPU"
            value: "45%"
            severity: "NORMAL"
            timestamp: "10:55:01"
            aiAnalysis: "Load average stable."
            isLoading: false
        }
        ListElement {
            eventId: "evt_2"
            type: "NET"
            value: "1.2MB/s"
            severity: "WARNING"
            timestamp: "10:56:12"
            aiAnalysis: "Unusual outbound traffic detected."
            isLoading: false
        }
        ListElement {
            eventId: "evt_3"
            type: "DISK"
            value: "Write"
            severity: "CRITICAL"
            timestamp: "11:00:05"
            aiAnalysis: "I/O wait time exceeded 500ms."
            isLoading: true
        }
    }

    // --- Main Container ---
    Rectangle {
        // نربط ارتفاع الخلفية بارتفاع المكون الكلي
        width: parent.width
        height: root.implicitHeight

        color: root.theme.colors.leftMenuBgColorV2
        radius: root.theme.dimensions.elementRadius
        clip: true

        ColumnLayout {
            id: mainLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            // 1. Header
            MonitorHeader {
                Layout.fillWidth: true
                theme: root.theme
                title: "System Guard"
                statusText: "OPTIMAL"
                isDetailsOpen: root.showBootDetails

                onToggleDetailsClicked: root.showBootDetails = !root.showBootDetails
            }

            // 2. Boot Details
            BootDetails {
                Layout.fillWidth: true
                theme: root.theme
                isOpen: root.showBootDetails
                // المكون BootDetails يجب أن يدعم تغيير implicitHeight بناءً على isOpen داخلياً
            }

            // 3. Timeline Area
            Item {
                id: timelineWrapper
                Layout.fillWidth: true

                // حساب الارتفاع بناءً على محتوى القائمة + الهوامش (top & bottom margins)
                implicitHeight: timelineList.contentHeight + (root.theme.dimensions.spacingLarge * 2)

                clip: true

                ListView {
                    id: timelineList
                    anchors.fill: parent

                    // الهوامش
                    anchors.topMargin: root.theme.dimensions.spacingLarge
                    anchors.bottomMargin: root.theme.dimensions.spacingLarge

                    spacing: root.theme.dimensions.spacingLarge

                    // تعطيل السكرول الداخلي ليعمل السكرول الخارجي في Main.qml
                    interactive: false

                    model: eventModel

                    // الـ ScrollBar الداخلي لم يعد ضرورياً إذا كنا نستخدم سكرول خارجي
                    // لكن يمكن تركه كديكور إذا أردت، وإن كان يفضل إخفاؤه لتجنب ازدواجية السكرول بار
                    // ScrollBar.vertical: null

                    delegate: EventDelegate {
                        width: timelineList.width

                        eventId: model.eventId
                        eventType: model.type
                        eventValue: model.value
                        eventSeverity: model.severity
                        eventTime: model.timestamp
                        aiText: model.aiAnalysis
                        isExpanded: root.expandedEventId === model.eventId

                        onExpandRequested: {
                            // عند التوسيع، سيتغير contentHeight للقائمة وبالتالي يكبر المكون تلقائياً
                            root.expandedEventId = (root.expandedEventId === model.eventId) ? "" : model.eventId;
                        }
                    }
                }
            }
        }
    }
}
