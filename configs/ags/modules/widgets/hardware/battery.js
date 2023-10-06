const { Button, Label, CircularProgress } = ags.Widget
const { Battery: battery } = ags.Service

const label = Label({
    className: "battery-inner",
    label: "󰄯"
})

const button = Button({
    className: "unset no-hover",
    child: label,
});

export const BatteryWidget = () => CircularProgress({
    className: "battery",
    child: button,
    connections: [
        [battery, batteryProgress => {

            if (battery.charging) {
                label.className = "battery-inner-charging";
            } else {
                label.className = "battery-inner";
            }
            batteryProgress.value = (battery.percent / 100) - 0.04;
            label.tooltipMarkup = `<span weight='bold' foreground='#FF8580'>نسبة البطارية (${battery.percent}%)</span>`

        }],
    ],
});
