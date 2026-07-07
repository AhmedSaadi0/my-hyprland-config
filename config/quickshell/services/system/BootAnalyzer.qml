// services/system/BootAnalyzer.qml

import QtQuick
import Quickshell

import "root:/config"
import "root:/services"

Item {
    id: root

    property string bootAnalysisStatus: "IDLE"
    property string bootStatusTitle: "System Check"
    property string bootStatusIcon: ""
    property string bootStatusColor: "green"
    property string aiBootSummary: "Waiting for analysis..."
    property string bootTimeText: "--"
    property var bootLogsModel: []

    property string bootSolutionStatus: "IDLE"
    property var bootSolutionsModel: []

    function requestBootSolutions(bootLogs) {
        if (bootSolutionStatus === "LOADING")
            return;

        console.info("[BootAnalyzer] Requesting boot solutions...");
        bootSolutionStatus = "LOADING";

        const payload = {
            logs: bootLogs || [],
            boot_duration: root.bootTimeText,
            title: root.bootStatusTitle,
            summary: root.aiBootSummary,
            status_color: root.bootStatusColor
        };

        AiService.sendRequest(App.scripts.python.callBootSolutionAi, ["--message", JSON.stringify(payload)], function (data) {
            if (data && data.solutions) {
                console.info("[BootAnalyzer] Boot solutions received: " + data.solutions.length + " solutions");
                root.bootSolutionsModel = data.solutions;
                root.bootSolutionStatus = "SUCCESS";
            } else {
                console.warn("[BootAnalyzer] Boot solutions response has no solutions array");
                root.bootSolutionStatus = "ERROR";
            }
        }, function (errorMessage) {
            console.error("[BootAnalyzer] Boot solutions error: " + errorMessage);
            root.bootSolutionStatus = "ERROR";
        }, "BootSolutions", 0);
    }

    function refreshBootDetails() {
        if (bootAnalysisStatus === "LOADING")
            return;

        console.info("[BootAnalyzer] Starting Boot Analysis...");
        bootAnalysisStatus = "LOADING";
        bootSolutionStatus = "IDLE";
        bootSolutionsModel = [];

        const baseCommand = App.scripts.python.callBootAnalysisAi;
        const extraArgs = ["--message", "Analyze Boot Logs"];

        AiService.sendRequest(baseCommand, extraArgs, function (data) {
            if (data && data.title) {
                console.info("[BootAnalyzer] AI Analysis Received: " + data.title);

                root.bootStatusTitle = data.title;
                root.bootStatusIcon = data.icon;
                root.bootStatusColor = data.status_color;
                root.aiBootSummary = data.summary;
                root.bootTimeText = data.boot_duration;
                root.bootLogsModel = data.logs;
                root.bootAnalysisStatus = "SUCCESS";

                if (data.logs && data.logs.length > 0) {
                    Qt.callLater(function () {
                        root.requestBootSolutions(data.logs);
                    });
                }
            } else {
                console.error("[BootAnalyzer] Data received but structure is unexpected");
                root.bootAnalysisStatus = "ERROR";
            }
        }, function (errorMessage) {
            console.error("[BootAnalyzer] AI Process Error: " + errorMessage);
            root.bootAnalysisStatus = "ERROR";
        }, "BootDetails", 0);
    }

    function retryBootAnalysis() {
        if (root.bootAnalysisStatus === "LOADING")
            return;
        root.bootAnalysisStatus = "IDLE";
        root.bootSolutionStatus = "IDLE";
        root.bootSolutionsModel = [];
        root.refreshBootDetails();
    }

    Timer {
        interval: 3000
        running: true
        repeat: false
        onTriggered: root.refreshBootDetails()
    }
}
