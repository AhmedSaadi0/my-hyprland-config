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
    property var _actionsCache: ({})
    property int _eventCounter: 0

    property int _spikeCooldownMs: App.resourceAlertCooldownMs
    property int _tempSpikeCooldownMs: 300000
    property int _procSpikeCooldownMs: App.resourceAlertCooldownMs
    property int _procAlertCooldownMs: App.resourceAlertCooldownMs

    property real _tempHighThreshold: Math.max(1, App.tempHighThreshold || 85)

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

    Connections {
        target: SystemService

        function onCpuSampled(previousValue, currentValue) {
            return;
        }

        function onRamSampled(previousValue, currentValue) {
            return;
        }

        function onTemperatureSampled(previousMax, currentMax) {
            root._checkTempSpike(previousMax, currentMax);
        }

        function onCpuAlert(value, isReminder, activeForMs) {
            root._emitCpuAlert(value, isReminder, activeForMs);
        }

        function onRamAlert(value, isReminder, activeForMs) {
            root._emitRamAlert(value, isReminder, activeForMs);
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

        _collectTopCpuProcesses(function (topList) {
            _collectTempDiagnostics(function (tempsData) {
                _createSpikeEvent("TEMP", Math.round(currMax), Math.round(prevMax), Math.round(delta), _tempHighThreshold, topList, _tempsSummaryFromData(tempsData), _buildTempDevicesList(tempsData));
            });
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
        if (top.pid !== undefined && top.pid !== null)
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

    function _emitCpuAlert(value, isReminder, activeForMs) {
        _collectTopCpuProcesses(function (topList) {
            const procKey = _getTopProcessKey("cpu", topList);
            if (_isAlertOnCooldown("cpu", procKey))
                return;

            _markAlert("cpu", procKey);
            _createSpikeEvent("CPU", Math.round(value * 100), Math.round(value * 100), isReminder ? Math.round((activeForMs || 0) / 1000) : 0, App.cpuHighLoadThreshold, topList, null);
        });
    }

    function _emitRamAlert(value, isReminder, activeForMs) {
        _collectTopRamProcesses(function (topList) {
            const procKey = _getTopProcessKey("ram", topList);
            if (_isAlertOnCooldown("ram", procKey))
                return;

            _markAlert("ram", procKey);
            _createSpikeEvent("RAM", Math.round(value * 100), Math.round(value * 100), isReminder ? Math.round((activeForMs || 0) / 1000) : 0, App.ramHighLoadThreshold, topList, null);
        });
    }

    function _createSpikeEvent(type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride, tempDevicesOverride) {
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

        _actionsCache[eventId] = [];
        _trimEventsModel();
        _requestSpikeAnalysis(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride, tempDevicesOverride);
    }

    function _trimEventsModel() {
        while (eventsModel.count > maxEventsCount)
            eventsModel.remove(eventsModel.count - 1);
    }

    function _requestSpikeAnalysis(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride, tempDevicesOverride) {
        if (type === "CPU") {
            if (topListOverride && topListOverride.length) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, null, []);
                return;
            }

            _collectTopCpuProcesses(function (topList) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, null, []);
            });
            return;
        }

        if (type === "RAM") {
            if (topListOverride && topListOverride.length) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, null, []);
                return;
            }

            _collectTopRamProcesses(function (topList) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, null, []);
            });
            return;
        }

        if (type === "TEMP") {
            if (topListOverride && topListOverride.length && tempDevicesOverride) {
                _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride || _currentTempsPayload(), tempDevicesOverride);
                return;
            }

            _collectTopCpuProcesses(function (topList) {
                _collectTempDiagnostics(function (tempsData) {
                    _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride && topListOverride.length ? topListOverride : topList, tempsOverride || _tempsSummaryFromData(tempsData), tempDevicesOverride || _buildTempDevicesList(tempsData));
                });
            });
        }
    }

    function _collectTopCpuProcesses(callback) {
        SystemService.requestTopCpuProcesses(function (data) {
            callback(_normalizeDiagnosticResult("cpu", data));
        });
    }

    function _collectTopRamProcesses(callback) {
        SystemService.requestTopRamProcesses(function (data) {
            callback(_normalizeDiagnosticResult("ram", data));
        });
    }

    function _collectTempDiagnostics(callback) {
        SystemService.requestTempDiagnostics(function (data) {
            callback(_normalizeDiagnosticResult("temps", data));
        });
    }

    function _defaultDiagnosticResult(action) {
        return action === "temps" ? {} : [];
    }

    function _normalizeDiagnosticResult(action, data) {
        if (!data || data.error) {
            if (data && data.error)
                console.error(`[AiAnalysisService] Diagnostics error for ${action}: ${data.error}`);
            return _defaultDiagnosticResult(action);
        }

        if (action === "temps")
            return typeof data === "object" ? data : {};

        return Array.isArray(data) ? data : [];
    }

    function _buildTempDevicesList(tempsData) {
        const combined = [];

        _appendTempDevices(combined, tempsData ? tempsData.cpu_temps : [], "cpu");
        _appendTempDevices(combined, tempsData ? tempsData.gpu_temps : [], "gpu");
        _appendTempDevices(combined, tempsData ? tempsData.storage_temps : [], "storage");

        combined.sort((a, b) => (b.value || 0) - (a.value || 0));
        return combined;
    }

    function _appendTempDevices(target, entries, category) {
        if (!entries || !entries.length)
            return;

        for (let i = 0; i < entries.length; i++) {
            const entry = entries[i];
            if (!entry || entry.temperature === undefined || entry.temperature === null)
                continue;

            target.push({
                name: entry.label || `${category}_${i + 1}`,
                value: Math.round(Number(entry.temperature) * 100) / 100,
                metric: "temp",
                category: category,
                source: entry.source || ""
            });
        }
    }

    function _tempsSummaryFromData(tempsData) {
        if (!tempsData)
            return _currentTempsPayload();

        return {
            cpu_max: tempsData.cpu_max_temp !== undefined && tempsData.cpu_max_temp !== null ? tempsData.cpu_max_temp : SystemService.cpuMaxTemp,
            gpu_max: tempsData.gpu_max_temp !== undefined && tempsData.gpu_max_temp !== null ? tempsData.gpu_max_temp : SystemService.gpuMaxTemp,
            storage_max: tempsData.storage_max_temp !== undefined && tempsData.storage_max_temp !== null ? tempsData.storage_max_temp : SystemService.storageMaxTemp
        };
    }

    function _currentTempsPayload() {
        return {
            cpu_max: SystemService.cpuMaxTemp,
            gpu_max: SystemService.gpuMaxTemp,
            storage_max: SystemService.storageMaxTemp
        };
    }

    function _safePrettyJson(value) {
        try {
            return JSON.stringify(value, null, 2);
        } catch (e) {
            return `[unserializable: ${e}]`;
        }
    }

    function _sendSpikeAi(eventId, type, currentValue, prevValue, deltaValue, thresholdValue, topList, temps, tempDevices) {
        const payload = {
            event_type: type,
            current_value: currentValue,
            previous_value: prevValue,
            delta: deltaValue,
            threshold: thresholdValue,
            timestamp: new Date().toISOString(),
            top_processes: topList || [],
            temp_devices: tempDevices || [],
            temps: temps || _currentTempsPayload()
        };

        console.info(`[AiAnalysisService] Sending spike analysis for ${type} event ${eventId}`);
        console.info(`[AiAnalysisService] Spike payload:\n${_safePrettyJson(payload)}`);

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
        }, "spike_analyze_" + eventId, 2);
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
            _actionsCache[eventId] = data.actions;
        else
            _actionsCache[eventId] = [];

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

    function getActionsForEvent(eventId) {
        return _actionsCache[eventId] || [];
    }

    function _formatTime(dt) {
        const hh = dt.getHours().toString().padStart(2, "0");
        const mm = dt.getMinutes().toString().padStart(2, "0");
        const ss = dt.getSeconds().toString().padStart(2, "0");
        return `${hh}:${mm}:${ss}`;
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
