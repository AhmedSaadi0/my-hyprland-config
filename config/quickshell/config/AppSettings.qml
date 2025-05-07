pragma Singleton

import QtQuick
import QtQml
import Quickshell

QtObject {

    PersistentProperties {
        id: appSettingsStorage
        reloadableId: "globalAppSettings"

        property real panelHeight: 30
        property int clockFormat: 12
        property bool showBattery: true
        property string weatherLocation: "Cairo"
        property bool animationsEnabled: true
    }

    property alias panelHeight: appSettingsStorage.panelHeight
    property alias clockFormat: appSettingsStorage.clockFormat
    property alias showBattery: appSettingsStorage.showBattery
    property alias weatherLocation: appSettingsStorage.weatherLocation
    property alias animationsEnabled: appSettingsStorage.animationsEnabled
}
