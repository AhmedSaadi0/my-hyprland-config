import QtQuick
import "../../../components"
import Quickshell.Services.UPower

TopbarCircularProgress {
    id: batteryUsage
    command: ["sh", "-c", "~/.config/quickshell/scripts/cpu_usage.sh"]
    updateInterval: 1000 * 10

    // value: UPower.onBattery
    // running: false

    icon: "-"
    iconColor: palette.text

    backgroundColor: palette.text.alpha(0.2)
    foregroundColor: palette.text

    onReadHandler: data => {
        const battery = UPower.devices.values[0];
        if (battery.isLaptopBattery) {
            const connected = battery.powerSupply;
            const percentage = battery.percentage;
            const timeToEmpty = battery.timeToEmpty;
            const changeRate = battery.changeRate;

            value = percentage;

            if (timeToEmpty === 0) {
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
                iconFontSize = 10;
                glowIcon = changeRate > 0;
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
                glowIcon = false;
            }
        }
    }
}
