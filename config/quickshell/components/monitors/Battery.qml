// components/monitors/Battery.qml

import QtQuick
import Quickshell.Services.UPower

import "root:/components"
import "root:/themes"

TopbarCircularProgress {
    id: batteryUsage
    command: ["ls"] // TODO: -> use a better way than calling fake command to run the interval
    updateInterval: 1000 * 10
    activetProcess: false

    icon: ""

    onReadHandler: data => {
        const battery = UPower.devices.values[0];
        if (battery && battery.isLaptopBattery) {
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
                // iconFontSize = batteryUsage.iconFontSize - 1;
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
