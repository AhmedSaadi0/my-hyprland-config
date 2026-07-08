import QtQuick
import "root:/config"

QtObject {
    id: root

    readonly property int maxEventsCount: 50

    property ListModel eventsModel: ListModel {}

    property int _eventCounter: 0

    function createSpikeEvent(type, currentValue, prevValue, deltaValue, thresholdValue, topListOverride, tempsOverride, tempDevicesOverride, tempHighThreshold, onReady) {
        const eventId = `evt_${Date.now()}_${_eventCounter++}`;
        const severity = type === "TEMP" ? (currentValue >= tempHighThreshold + 10 ? "CRITICAL" : "WARNING") : (currentValue >= thresholdValue ? "WARNING" : "NORMAL");

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
        onReady(eventId);
    }

    function _trimEventsModel() {
        while (eventsModel.count > maxEventsCount)
            eventsModel.remove(eventsModel.count - 1);
    }

    function applySpikeAnalysis(eventId, data) {
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

        eventsModel.setProperty(idx, "aiActions", data.actions || []);
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
}
