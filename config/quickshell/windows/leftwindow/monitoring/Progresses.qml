// windows/leftwindow/monitoring/Progresses.qml

import QtQuick

import "../../../components/monitors"

Row {
    id: root
    width: parent.width
    height: 100
    spacing: 8
    // color: "#FEEBEA"

    property int progressWidth: 70
    property int progressHeight: 70
    property int thickness: 8
    property int iconFontSize: 28

    Tempreture {
        id: temp
        width: root.progressWidth
        height: root.progressHeight
        thickness: root.thickness
        iconFontSize: root.iconFontSize
        // anchors {
        //     top: parent.top
        //     left: parent.left
        // }
    }

    Battery {
        id: bat
        width: root.progressWidth
        height: root.progressHeight
        thickness: root.thickness
        iconFontSize: root.iconFontSize
        // anchors {
        // anchors {
        //     top: parent.top
        //     left: temp.right
        // }
    }

    Ram {
        id: ram
        width: root.progressWidth
        height: root.progressHeight
        thickness: root.thickness
        iconFontSize: root.iconFontSize
        // anchors {
        // anchors {
        //     top: parent.top
        //     left: bat.right
        // }
    }

    Cpu {
        id: cpu
        width: root.progressWidth
        height: root.progressHeight
        thickness: root.thickness
        iconFontSize: root.iconFontSize
        // anchors {
        // anchors {
        //     top: parent.top
        //     left: ram.right
        // }
    }
}
