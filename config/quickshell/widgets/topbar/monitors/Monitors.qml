import QtQuick.Layouts
import QtQuick
import org.kde.kirigami as Kirigami

import "../../../components"
import "../../../themes"

RowLayout {
    // anchors.fill: parent
    // width: 120
    spacing: 6

    Tempreture {}
    Battery {}
    Ram {}
    Cpu {}
}
