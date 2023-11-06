import { Box, Button, Label, CircularProgress } from 'resource:///com/github/Aylur/ags/widget.js'
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

const label = Label({
    className: "cpu-inner",
    label: ""
})

const button = Button({
    className: "unset no-hover",
    child: label,
});

const progress = CircularProgress({
    className: "cpu",
    child: button,
    startAt: 0,
    rounded: false,
    inverted: true,
});

export const CpuWidget = () => Box({
    style: "margin-left: 1.0em;",
    connections: [
        [1000, box => {
            execAsync(`/home/ahmed/.config/ags/scripts/cpu.sh`)
                .then(val => {
                    progress.value = val / 100;
                    label.tooltipMarkup = `<span weight='bold' foreground='#FDC227'>يتم استخدام (${val}%) من المعالج</span>`
                }).catch(print);

            box.children = [
                progress
            ];
            box.show_all();
        }],
    ],
});
