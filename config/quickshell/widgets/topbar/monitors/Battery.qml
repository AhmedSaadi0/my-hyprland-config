import QtQuick
import org.kde.kirigami as Kirigami
import "../../../components"
import Quickshell.Services.UPower

TopbarCircularProgress {
    id: cpuUsage
    icon: "󰁹"
    command: ["sh", "-c", "~/.config/quickshell/scripts/cpu_usage.sh"]
    value: UPower.onBattery
    // running: false
    updateInterval: 1000 * 10
    textColor: Kirigami.Theme.textColor
    backgroundColor: Kirigami.Theme.textColor.alpha(0.3)
    foregroundColor: Kirigami.Theme.textColor

    onReadHandler: data => {
        const battery = UPower.devices.values[0];
        if (battery.isLaptopBattery) {
            const connected = battery.powerSupply;
            const percentage = battery.percentage;
            const timeToFull = battery.timeToFull; // 0 means discharged

            value = percentage;

            if (timeToFull) {
                if (percentage <= 0.10) {
                    icon = '󰢜';
                } else if (percentage <= 0.20) {
                    icon = '󰂆';
                } else if (percentage <= 0.30) {
                    icon = '󰂇';
                } else if (percentage <= 0.40) {
                    icon = '󰂈';
                } else if (percentage <= 0.50) {
                    icon = '󰢝';
                } else if (percentage <= 0.60) {
                    icon = '󰂉';
                } else if (percentage <= 0.70) {
                    icon = '󰢞';
                } else if (percentage <= 0.80) {
                    icon = '󰂊';
                } else if (percentage <= 0.90) {
                    icon = '󰂋';
                } else {
                    icon = '󰂅';
                }
                iconFontSize = 12;
            } else {
                if (percentage <= 0.10) {
                    icon = '󰁺';
                } else if (percentage <= 0.20) {
                    icon = '󰁻';
                } else if (percentage <= 0.30) {
                    icon = '󰁼';
                } else if (percentage <= 0.40) {
                    icon = '󰁽';
                } else if (percentage <= 0.50) {
                    icon = '󰁾';
                } else if (percentage <= 0.60) {
                    icon = '󰁿';
                } else if (percentage <= 0.70) {
                    icon = '󰂀';
                } else if (percentage <= 0.80) {
                    icon = '󰂁';
                } else if (percentage <= 0.90) {
                    icon = '󰂂';
                } else {
                    icon = '󰁹';
                }
                iconFontSize = 14;
            }
        }
    }
}
