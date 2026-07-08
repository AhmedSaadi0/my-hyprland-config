import QtQuick
import Quickshell
import Quickshell.Io

import "root:/config"
import "root:/services"
import "root:/services/analyzers"

pragma Singleton

Singleton {
    id: root

    property alias eventsModel: eventStore.eventsModel

    CooldownManager {
        id: cooldownManager
    }

    DiagnosticsCollector {
        id: diagnosticsCollector
    }

    EventStore {
        id: eventStore
    }

    SpikeDetector {
        id: spikeDetector
        cooldownManager: cooldownManager
        diagnosticsCollector: diagnosticsCollector
        eventStore: eventStore
    }

    Component.onCompleted: {
        cooldownManager.spikeCooldownMs = App.resourceAlertCooldownMs;
        cooldownManager.procSpikeCooldownMs = App.resourceAlertCooldownMs;
        cooldownManager.procAlertCooldownMs = App.resourceAlertCooldownMs;
        spikeDetector.tempHighThreshold = Math.max(1, App.tempHighThreshold || 85);
    }

    Connections {
        target: SystemService

        function onCpuSampled(previousValue, currentValue) {
            return;
        }

        function onRamSampled(previousValue, currentValue) {
            return;
        }

        function onTemperatureSampled(previousMax, currentMax) {
            spikeDetector.checkTempSpike(previousMax, currentMax);
        }

        function onCpuAlert(value, isReminder, activeForMs) {
            spikeDetector.emitCpuAlert(value, isReminder, activeForMs);
        }

        function onRamAlert(value, isReminder, activeForMs) {
            spikeDetector.emitRamAlert(value, isReminder, activeForMs);
        }
    }

    NibrasShellShortcut {
        name: "testHighCpu"
        onPressed: SystemService.cpuAlert(0.5, false, 0)
    }

    NibrasShellShortcut {
        name: "testHighRam"
        onPressed: SystemService.ramAlert(0.50, false, 0)
    }
}
