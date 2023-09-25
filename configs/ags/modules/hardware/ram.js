const { Box, Button, Label, CircularProgress } = ags.Widget
const { execAsync } = ags.Utils;
// import { CircularProgressBarBin2 } from "../circular.js"

const label = Label({
    className: "ram-inner",
    label: "󰄯"
})

const button = Button({
    className: "unset",
    child: label,
    onClicked: () => ags.App.toggleWindow('vol_osd'),
});

const progress = CircularProgress({
    className: "ram",
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
