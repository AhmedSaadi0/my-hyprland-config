import QtQuick.Layouts
import QtQuick

import "../../components/monitors/"

RowLayout {
    // anchors.fill: parent
    // width: 120
    spacing: 6

    Tempreture {}
    Battery {
        glowIcon: false
    }
    Ram {}
    Cpu {}
}
