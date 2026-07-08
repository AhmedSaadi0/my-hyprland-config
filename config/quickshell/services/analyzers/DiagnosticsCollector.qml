import QtQuick
import "root:/services"

QtObject {
    id: root

    function collectTopCpuProcesses(callback) {
        SystemService.requestTopCpuProcesses(function (data) {
            callback(_normalizeDiagnosticResult("cpu", data));
        });
    }

    function collectTopRamProcesses(callback) {
        SystemService.requestTopRamProcesses(function (data) {
            callback(_normalizeDiagnosticResult("ram", data));
        });
    }

    function collectTempDiagnostics(callback) {
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
                console.error(`[DiagnosticsCollector] Diagnostics error for ${action}: ${data.error}`);
            return _defaultDiagnosticResult(action);
        }

        if (action === "temps")
            return typeof data === "object" ? data : {};

        return Array.isArray(data) ? data : [];
    }

    function buildTempDevicesList(tempsData) {
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

    function tempsSummaryFromData(tempsData) {
        if (!tempsData)
            return currentTempsPayload();

        return {
            cpu_max: tempsData.cpu_max_temp !== undefined && tempsData.cpu_max_temp !== null ? tempsData.cpu_max_temp : SystemService.cpuMaxTemp,
            gpu_max: tempsData.gpu_max_temp !== undefined && tempsData.gpu_max_temp !== null ? tempsData.gpu_max_temp : SystemService.gpuMaxTemp,
            storage_max: tempsData.storage_max_temp !== undefined && tempsData.storage_max_temp !== null ? tempsData.storage_max_temp : SystemService.storageMaxTemp
        };
    }

    function currentTempsPayload() {
        return {
            cpu_max: SystemService.cpuMaxTemp,
            gpu_max: SystemService.gpuMaxTemp,
            storage_max: SystemService.storageMaxTemp
        };
    }
}
