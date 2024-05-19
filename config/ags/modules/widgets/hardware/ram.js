import {
    Box,
    Button,
    Label,
    CircularProgress,
} from 'resource:///com/github/Aylur/ags/widget.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import { Utils } from '../../utils/imports.js';

export const RamWidget = () => {
    const label = Label({
        className: 'ram-inner',
        label: '',
    });

    const button = Button({
        className: 'unset no-hover',
        child: label,
        onClicked: () => showHardwareMenu(),
    });

    const progress = CircularProgress({
        className: 'ram',
        startAt: 0,
        rounded: false,
        // inverted: true,
        child: button,
    });

    return Box({
        className: 'bar-hw-ram-box',
    }).poll(30000, (box) => {
        execAsync(`/home/${Utils.USER}/.config/ags/scripts/ram.sh`)
            .then((val) => {
                progress.value = val / 100;
                label.tooltipMarkup = `<span weight='bold' foreground='#79A7EC'>نسبة الرام المستهلكة (${val}%)</span>`;
            })
            .catch(print);

        box.children = [progress];
        box.show_all();
    });
};
