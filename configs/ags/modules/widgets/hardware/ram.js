import { Box, Button, Label, CircularProgress } from 'resource:///com/github/Aylur/ags/widget.js'
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
// import { CircularProgressBarBin2 } from "../circular.js"
import App  from "resource:///com/github/Aylur/ags/app.js";

const label = Label({
    className: "ram-inner",
    label: "󰄯"
})

const button = Button({
    className: "unset no-hover",
    child: label,
    onClicked: () => App.toggleWindow('vol_osd'),
});

const progress = CircularProgress({
    className: "ram",
    startAt: 0,
    rounded: false,
    inverted: true,
    child: button,
});

export const RamWidget = () => Box({
    style: "margin-left: 1.0em;",
    connections: [
        [30000, box => {
            execAsync(`/home/ahmed/.config/ags/scripts/ram.sh`)
                .then(val => {
                    progress.value = (val / 100);
                    label.tooltipMarkup = `<span weight='bold' foreground='#79A7EC'>نسبة الرام المستهلكة (${val}%)</span>`
                }).catch(print);

            box.children = [
                progress
            ];
            box.show_all();
        }],
    ],
});
