// components/monitors/Battery.qml

import QtQuick
import Quickshell.Services.UPower

import "root:/components"
import "root:/themes"
import "root:/services"

TopbarCircularProgress {
    id: batteryUsage

    activeProcess: false

    value: SystemService.batteryPercent
    icon: SystemService.batteryIcon
    glowIcon: SystemService.isCharging
}
