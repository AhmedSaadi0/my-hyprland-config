import QtQuick
import org.kde.kirigami as Kirigami
import "../../../components"
import Quickshell.Services.UPower

TopbarCircularProgress {
    id: cpuUsage
    command: ["sh", "-c", "~/.config/quickshell/scripts/cpu_usage.sh"]
    updateInterval: 1000 * 10

    // value: UPower.onBattery
    // running: false

    icon: "󰁹"
    iconColor: palette.text

    backgroundColor: palette.text.alpha(0.4)
    foregroundColor: palette.text

    onReadHandler: data => {
        const battery = UPower.devices.values[0];
        if (battery.isLaptopBattery) {
            const connected = battery.powerSupply;
            const percentage = battery.percentage;
            const changeRate = battery.changeRate;

            value = percentage;

            if (changeRate <= 0) {
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
