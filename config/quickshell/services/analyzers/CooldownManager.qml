import QtQuick

QtObject {
    id: root

    property int spikeCooldownMs: 30000
    property int tempSpikeCooldownMs: 300000
    property int procSpikeCooldownMs: 30000
    property int procAlertCooldownMs: 30000

    property var _lastSpikeAt: ({
        cpu: 0,
        ram: 0,
        temp: 0
    })

    property var _lastProcSpikeAt: ({
        cpu: ({}),
        ram: ({})
    })

    property var _lastProcAlertAt: ({
        cpu: ({}),
        ram: ({})
    })

    property var _lastAlertAt: ({
        cpu: 0,
        ram: 0
    })

    function canTriggerSpike(kind) {
        return Date.now() - _lastSpikeAt[kind] >= _getSpikeCooldownMs(kind);
    }

    function _getSpikeCooldownMs(kind) {
        if (kind === "temp")
            return tempSpikeCooldownMs;
        return spikeCooldownMs;
    }

    function markSpike(kind) {
        _lastSpikeAt[kind] = Date.now();
    }

    function getTopProcessKey(topList) {
        if (!topList || !topList.length)
            return "";

        const top = topList[0];
        if (top.pid !== undefined && top.pid !== null)
            return `${top.pid}:${top.name || ""}`;

        return top.name || "";
    }

    function isProcessOnCooldown(kind, procKey) {
        if (!procKey)
            return false;

        const last = _lastProcSpikeAt[kind][procKey] || 0;
        return Date.now() - last < procSpikeCooldownMs;
    }

    function markProcessSpike(kind, procKey) {
        if (!procKey)
            return;
        _lastProcSpikeAt[kind][procKey] = Date.now();
    }

    function isAlertOnCooldown(kind, procKey) {
        const now = Date.now();
        if (procKey) {
            const last = _lastProcAlertAt[kind][procKey] || 0;
            return now - last < procAlertCooldownMs;
        }
        return now - _lastAlertAt[kind] < procAlertCooldownMs;
    }

    function markAlert(kind, procKey) {
        const now = Date.now();
        if (procKey)
            _lastProcAlertAt[kind][procKey] = now;
        _lastAlertAt[kind] = now;
    }
}
