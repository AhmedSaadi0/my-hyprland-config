// services/system/ResourceDiagnostics.qml

import QtQuick
import Quickshell
import Quickshell.Io

import "root:/config"

QtObject {
    id: root

    property var _resourceDiagnosticCallbacks: ({})
    property var _resourceDiagnosticQueue: []
    property string _activeResourceDiagnosticAction: ""
    property string _resourceDiagnosticStdoutText: ""
    property string _resourceDiagnosticStderrText: ""
    property int _resourceDiagnosticExitCode: 0
    property int _resourceDiagnosticExitStatus: 0

    signal tempDiagnosticsReady(var data)

    function _defaultResourceDiagnosticResult() {
        return [];
    }

    function _readResourceDiagnosticOutput(action, rawText) {
        const text = (rawText || "").toString().trim();
        if (!text)
            return action === "temps" ? {} : _defaultResourceDiagnosticResult();

        try {
            const parsed = JSON.parse(text);
            if (parsed && !parsed.error) {
                if (action === "temps")
                    return typeof parsed === "object" ? parsed : {};
                if (Array.isArray(parsed))
                    return parsed;
            }
            return action === "temps" ? {} : _defaultResourceDiagnosticResult();
        } catch (e) {
            console.error(`[ResourceDiagnostics] Failed to parse resource diagnostics output for action '${action}': ${e}`);
            console.error(`[ResourceDiagnostics] Raw output was: \n${rawText}`);
            return action === "temps" ? {} : _defaultResourceDiagnosticResult();
        }
    }

    function _flushResourceCallbacks(callbacks, data) {
        const pending = callbacks.slice();
        callbacks.length = 0;

        for (let i = 0; i < pending.length; i++)
            pending[i](data);
    }

    function _finishResourceDiagnosticRequest(action, data) {
        if (!action)
            return;

        if (action === "temps" && data && !data.error)
            root.tempDiagnosticsReady(data);

        const callbacks = _resourceDiagnosticCallbacks[action] || [];
        _resourceDiagnosticCallbacks[action] = [];
        _flushResourceCallbacks(callbacks, data);
        _activeResourceDiagnosticAction = "";
        _pumpResourceDiagnosticsQueue();
    }

    function _enqueueResourceDiagnosticRequest(action, callback) {
        if (!_resourceDiagnosticCallbacks[action])
            _resourceDiagnosticCallbacks[action] = [];

        _resourceDiagnosticCallbacks[action].push(callback);

        if (_activeResourceDiagnosticAction === action || _resourceDiagnosticQueue.indexOf(action) !== -1)
            return;

        _resourceDiagnosticQueue.push(action);
        _pumpResourceDiagnosticsQueue();
    }

    function _pumpResourceDiagnosticsQueue() {
        if (_activeResourceDiagnosticAction || !_resourceDiagnosticQueue.length)
            return;

        _activeResourceDiagnosticAction = _resourceDiagnosticQueue.shift();
        _resourceDiagnosticStdoutText = "";
        _resourceDiagnosticStderrText = "";
        _resourceDiagnosticExitCode = 0;
        _resourceDiagnosticExitStatus = 0;
        _resourceDiagnosticsProc.command = [...App.scripts.python.systemDiagnosticsCommand, "--action", _activeResourceDiagnosticAction];
        _resourceDiagnosticsProc.running = true;
    }

    function requestTopCpuProcesses(callback) {
        _enqueueResourceDiagnosticRequest("cpu", callback);
    }

    function requestTopRamProcesses(callback) {
        _enqueueResourceDiagnosticRequest("ram", callback);
    }

    function requestTempDiagnostics(callback) {
        _enqueueResourceDiagnosticRequest("temps", callback);
    }

    property Process _resourceDiagnosticsProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                root._resourceDiagnosticStdoutText = this.text.toString();
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                root._resourceDiagnosticStderrText = this.text.toString();
            }
        }

        onExited: (exitCode, exitStatus) => {
            root._resourceDiagnosticExitCode = exitCode;
            root._resourceDiagnosticExitStatus = exitStatus;
        }

        onRunningChanged: {
            if (running)
                return;

            const action = root._activeResourceDiagnosticAction;

            if (root._resourceDiagnosticStderrText.trim().length)
                console.error(`[ResourceDiagnostics] Resource diagnostics stderr for ${action}: ${root._resourceDiagnosticStderrText.trim()}`);

            if (root._resourceDiagnosticExitCode !== 0) {
                console.error(`[ResourceDiagnostics] Resource diagnostics failed for ${action} with exit code ${root._resourceDiagnosticExitCode} (${root._resourceDiagnosticExitStatus})`);
                root._finishResourceDiagnosticRequest(action, action === "temps" ? {} : root._defaultResourceDiagnosticResult());
                return;
            }

            root._finishResourceDiagnosticRequest(action, root._readResourceDiagnosticOutput(action, root._resourceDiagnosticStdoutText));
        }
    }
}
