import Quickshell.Services.SystemTray
import QtQuick

Item {
    id: root

    readonly property Repeater items: items

    clip: true
    visible: width > 0 && height > 0 // To avoid warnings about being visible with no size

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Row {
        id: layout
        spacing: 9

        add: Transition {
            NumberAnimation {
                properties: "scale"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.BezierSpline
                // easing.bezierCurve:[]
            }
        }

        Repeater {
            id: items
            model: SystemTray.items
            // The delegate for the repeater is defined in your other file.
            // Assuming it's named 'TrayItem.qml'
            delegate: TrayItem {}
        }
    }

    // Behavior on implicitWidth {
    //     NumberAnimation {
    //         duration: 300
    //         easing.type: Easing.BezierSpline
    //         // easing.bezierCurve: Appearance.anim.curves.emphasized
    //     }
    // }
    //
    // Behavior on implicitHeight {
    //     NumberAnimation {
    //         duration: 300
    //         easing.type: Easing.BezierSpline
    //         // easing.bezierCurve: Appearance.anim.curves.emphasized
    //     }
    // }
}
