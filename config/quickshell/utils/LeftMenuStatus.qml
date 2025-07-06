// utils/LeftMenuStatus.qml
pragma Singleton
import QtQuick

QtObject {
    property int selectedIndex: -1

    signal selectedIndexTargeted(int newIndex)

    function changeIndex(index) {
        if (selectedIndex !== index) {
            selectedIndex = index;
            selectedIndexTargeted(index);
        }
    }
}
