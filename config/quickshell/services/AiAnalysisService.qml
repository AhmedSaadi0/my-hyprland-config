// services/AiAnalysisService.qml

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

import "root:/config"
import "root:/services"

Singleton {
    id: root

    readonly property int maxEventsCount: 50

    property ListModel eventsModel: ListModel {}
    property int _eventCounter: 0

    property int _spikeCooldownMs: 60000
    property int _tempSpikeCooldownMs: 300000
    property int _procSpikeCooldownMs: 300000
    property int _procAlertCooldownMs: 300000

    property real _tempHighThreshold: 85

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

    property var _topCpuCallbacks: []
    property var _topRamCallbacks: []

    Connections {
        target: SystemService

        function onCpuSampled(previousValue, currentValue) {
            root._checkCpuSpike(previousValue, currentValue);
        }

        function onRamSampled(previousValue, currentValue) {
            root._checkRamSpike(previousValue, currentValue);
        }

        function onTemperatureSampled(previousMax, currentMax) {
            root._checkTempSpike(previousMax, currentMax);
        }

        function onCpuAlert(value) {
            root._emitCpuAlert(value);
        }

        function onRamAlert(value) {
            root._emitRamAlert(value);
        }
    }

    function _checkCpuSpike(prev, curr) {
        if (prev < 0)
            return;

        const threshold = App.cpuHighLoadThreshold / 100;
        if (!_canTriggerSpike("cpu") || curr < threshold)
            return;

        const delta = curr - prev;
        _collectTopCpuProcesses(function (topList) {
            const procKey = _getTopProcessKey("cpu", topList);
            if (_isProcessOnCooldown("cpu", procKey))
                return;

            _lastSpikeAt.cpu = Date.now();
            _markProcessSpike("cpu", procKey);
            _createSpikeEvent("CPU", Math.round(curr * 100), Math.round(prev * 100), Math.round(delta * 100), threshold * 100, topList, null);
        });
    }

    function _checkRamSpike(prev, curr) {
        if (prev < 0)
            return;

        const threshold = App.ramHighLoadThreshold / 100;
        if (!_canTriggerSpike("ram") || curr < threshold)
            return;

        const delta = curr - prev;
        _collectTopRamProcesses(function (topList) {
            const procKey = _getTopProcessKey("ram", topList);
            if (_isProcessOnCooldown("ram", procKey))
                return;

            _lastSpikeAt.ram = Date.now();
            _markProcessSpike("ram", procKey);
            _createSpikeEvent("RAM", Math.round(curr * 100), Math.round(prev * 100), Math.round(delta * 100), threshold * 100, topList, null);
        });
    }

    function _checkTempSpike(prevMax, currMax) {
        if (prevMax < 0)
            return;
        if (!_canTriggerSpike("temp") || currMax < _tempHighThreshold)
            return;

        const delta = currMax - prevMax;
        _lastSpikeAt.temp = Date.now();

        _collectTopTempProcesses(function (topList) {
            _createSpikeEvent("TEMP", Math.round(currMax), Math.round(prevMax), Math.round(delta), _tempHighThreshold, topList, _currentTempsPayload());
        });
    }

    function _canTriggerSpike(kind) {
        return Date.now() - _lastSpikeAt[kind] >= _getSpikeCooldownMs(kind);
    }

    function _getSpikeCooldownMs(kind) {
        if (kind === "temp")
            return _tempSpikeCooldownMs;
        return _spikeCooldownMs;
    }

    function _getTopProcessKey(kind, topList) {
        if (!topList || !topList.length)
            return "";

        const top = topList[0];
        if (kind === "ram" && top.pid !== undefined && top.pid !== null)
            return `${top.pid}:${top.name || ""}`;

        return top.name || "";
    }

    function _isProcessOnCooldown(kind, procKey) {
        if (!procKey)
            return false;

        const last = _lastProcSpikeAt[kind][procKey] || 0;
        return Date.now() - last < _procSpikeCooldownMs;
    }

    function _markProcessSpike(kind, procKey) {
        if (!procKey)
            return;
        _lastProcSpikeAt[kind][procKey] = Date.now();
    }

    function _isAlertOnCooldown(kind, procKey) {
        const now = Date.now();
        if (procKey) {
            const last = _lastProcAlertAt[kind][procKey] || 0;
            return now - last < _procAlertCooldownMs;
        }
        return now - _lastAlertAt[kind] < _procAlertCooldownMs;
    }

    function _markAlert(kind, procKey) {
        const now = Date.now();
        if (procKey)
            _lastProcAlertAt[kind][procKey] = now;
        _lastAlertAt[kind] = now;
    }

    function _emitCpuAlert(value) {
        _collectTopCpuProcesses(function (topList) {
            const procKey = _getTopProcessKey("cpu", topList);
            if (_isAlertOnCooldown("cpu", procKey))
                return;

            _markAlert("cpu", procKey);
            _createSpikeEvent("CPU", Math.round(value * 100), Math.round(value * 100), 0, App.cpuHighLoadThreshold, topList, null);
        });
    }

    function _emitRamAlert(value) {
        _collectTopRamProcesses(function (topList) {
            const procKey = _getTopProcessKey("ram", topList);
            if (_isAlertOnCooldown("ram", procKey))
                return;

            _markAlert("ram", procKey);
            _createSpikeEvent("RAM", Math.round(value * 100), Math.round(value * 100), 0, App.ramHighLoadThreshold, topList, null);
        });
    }

    function _createSpikeEvent(type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride) {
        const eventId = `evt_${Date.now()}_${_eventCounter++}`;
        const severity = type === "TEMP" ? (currentValue >= _tempHighThreshold + 10 ? "CRITICAL" : "WARNING") : (currentValue >= thresholdValue ? "WARNING" : "NORMAL");

        eventsModel.insert(0, {
            eventId: eventId,
            type: type,
            value: type === "TEMP" ? `${currentValue}°C` : `${currentValue}%`,
            severity: severity,
            timestamp: _formatTime(new Date()),
            aiAnalysis: "Analyzing... Please wait.",
            aiTitle: "Analyzing...",
            aiNarrative: "",
            aiRootCause: "",
            aiConfidence: 0,
            aiThermalRisk: "",
            aiThermalDetails: "",
            aiProcessName: "",
            aiProcessBehavior: "",
            aiActions: [],
            isLoading: true,
            aiModel: App.systemAiModel || "System AI"
        });

        _trimEventsModel();
        _requestSpikeAnalysis(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride);
    }

    function _trimEventsModel() {
        while (eventsModel.count > maxEventsCount)
            eventsModel.remove(eventsModel.count - 1);
    }

    function _requestSpikeAnalysis(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride) {
        if (type === "CPU") {
            if (topListOverride && topListOverride.length) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, null);
                return;
            }

            _collectTopCpuProcesses(function (topList) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, null);
            });
            return;
        }

        if (type === "RAM") {
            if (topListOverride && topListOverride.length) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, null);
                return;
            }

            _collectTopRamProcesses(function (topList) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, null);
            });
            return;
        }

        if (type === "TEMP") {
            if (topListOverride && topListOverride.length) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride || _currentTempsPayload());
                return;
            }

            _collectTopTempProcesses(function (topList) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, tempsOverride || _currentTempsPayload());
            });
        }
    }

    function _collectTopCpuProcesses(callback) {
        _topCpuCallbacks.push(callback);
        if (!topCpuProc.running)
            topCpuProc.running = true;
    }

    function _collectTopRamProcesses(callback) {
        _topRamCallbacks.push(callback);
        if (!topRamProc.running)
            topRamProc.running = true;
    }

    function _collectTopTempProcesses(callback) {
        _collectTopCpuProcesses(function (cpuList) {
            _collectTopRamProcesses(function (ramList) {
                callback(_mergeTempProcessLists(cpuList, ramList));
            });
        });
    }

    function _mergeTempProcessLists(cpuList, ramList) {
        const combined = [];

        for (let i = 0; i < (cpuList || []).length; i++) {
            const proc = cpuList[i];
            combined.push({
                name: proc.name || "Unknown",
                value: Math.round((proc.value || 0) * 100) / 100,
                metric: "cpu"
            });
        }

        for (let i = 0; i < (ramList || []).length; i++) {
            const proc = ramList[i];
            combined.push({
                pid: proc.pid,
                name: proc.name || "Unknown",
                value: Math.round((proc.value || 0) * 100) / 100,
                memory_usage_mb: proc.memory_usage_mb || 0,
                metric: "ram"
            });
        }

        combined.sort((a, b) => (b.value || 0) - (a.value || 0));
        return combined.slice(0, 10);
    }

    function _currentTempsPayload() {
        return {
            cpu_max: SystemService.cpuMaxTemp,
            gpu_max: SystemService.gpuMaxTemp,
            storage_max: SystemService.storageMaxTemp
        };
    }

    function _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, temps) {
        const payload = {
            event_type: type,
            current_value: currentValue,
            previous_value: prevValue,
            delta: deltaValue,
            threshold: thresholdValue,
            timestamp: new Date().toISOString(),
            top_processes: topList || [],
            temps: temps || _currentTempsPayload()
        };

        AiService.sendRequest(App.scripts.python.callSpikeAnalysisAi, ["--message", JSON.stringify(payload)], function (data) {
            root._applySpikeAnalysis(eventId, data);
        }, function (errorMessage) {
            root._applySpikeAnalysis(eventId, {
                title: "Analysis Failed",
                severity: "warning",
                analysis: errorMessage || "Failed to analyze spike.",
                causes: [],
                actions: []
            });
        });
    }

    function _applySpikeAnalysis(eventId, data) {
        const idx = _findEventIndex(eventId);
        if (idx === -1)
            return;

        eventsModel.setProperty(idx, "aiTitle", data.title || "Analysis Complete");
        eventsModel.setProperty(idx, "aiNarrative", data.narrative || data.analysis || "No detailed analysis available.");
        eventsModel.setProperty(idx, "aiRootCause", data.root_cause_hypothesis || "Unknown cause");
        eventsModel.setProperty(idx, "aiConfidence", data.confidence_score || 50);

        if (data.thermal_impact) {
            eventsModel.setProperty(idx, "aiThermalRisk", data.thermal_impact.risk_level || "low");
            eventsModel.setProperty(idx, "aiThermalDetails", data.thermal_impact.details || "");
        }

        if (data.process_anomaly) {
            eventsModel.setProperty(idx, "aiProcessName", data.process_anomaly.name || "N/A");
            eventsModel.setProperty(idx, "aiProcessBehavior", data.process_anomaly.behavior || "Unknown behavior");
        }

        if (data.actions && data.actions.length)
            eventsModel.setProperty(idx, "aiActions", data.actions);
        else
            eventsModel.setProperty(idx, "aiActions", []);

        eventsModel.setProperty(idx, "isLoading", false);

        if (data.severity) {
            const sev = data.severity.toUpperCase();
            eventsModel.setProperty(idx, "severity", sev === "INFO" ? "NORMAL" : sev);
        }
    }

    function _findEventIndex(eventId) {
        for (let i = 0; i < eventsModel.count; i++) {
            if (eventsModel.get(i).eventId === eventId)
                return i;
        }
        return -1;
    }

    function _formatTime(dt) {
        const hh = dt.getHours().toString().padStart(2, "0");
        const mm = dt.getMinutes().toString().padStart(2, "0");
        const ss = dt.getSeconds().toString().padStart(2, "0");
        return `${hh}:${mm}:${ss}`;
    }

    function _flushCallbacks(callbacks, data) {
        const pending = callbacks.slice();
        callbacks.length = 0;

        for (let i = 0; i < pending.length; i++)
            pending[i](data);
    }

    Process {
        id: topCpuProc
        command: App.scripts.python.topCpuUsageCommand

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._flushCallbacks(root._topCpuCallbacks, JSON.parse(this.text.toString()));
                } catch (e) {
                    root._flushCallbacks(root._topCpuCallbacks, []);
                }
            }
        }
    }

    Process {
        id: topRamProc
        command: App.scripts.python.topRamUsageCommand

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._flushCallbacks(root._topRamCallbacks, JSON.parse(this.text.toString()));
                } catch (e) {
                    root._flushCallbacks(root._topRamCallbacks, []);
                }
            }
        }
    }

    NibrasShellShortcut {
        name: "testHighCpu"
        onPressed: SystemService.cpuAlert(0.5)
    }

    NibrasShellShortcut {
        name: "testHighRam"
        onPressed: SystemService.ramAlert(0.50)
    }
}
