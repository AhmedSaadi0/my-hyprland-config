import {
    Box,
    Button,
    Label,
    CircularProgress,
} from 'resource:///com/github/Aylur/ags/widget.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import { Utils } from '../../utils/imports.js';

export const TempWidget = () => {
    const label = Label({
        className: 'temp-inner',
        label: '',
    });

    const button = Button({
        className: 'unset no-hover',
        child: label,
        onClicked: () => showHardwareMenu(),
    });

    const progress = CircularProgress({
        className: 'temp',
        child: button,
        startAt: 0,
        rounded: false,
    });

    return Box({
        className: 'bar-hw-temp-box',
    }).poll(30000, (box) => {
        execAsync(`/home/${Utils.USER}/.config/ags/scripts/temp.sh`)
            .then((val) => {
                const temps = val.split('\n');
                let total = 0;
                for (let index = 0; index < temps.length; index++) {
                    const element = temps[index]
                        .replace('+', '')
                        .replace('°C', '');
                    total += parseInt(element);
                }
                total = parseInt(total / temps.length);
                progress.value = total / 100;
                label.tooltipMarkup = `<span weight='bold' foreground='#C78DF2'>اجمالي درجة حرارة الاجهزة (${total}%)</span>`;
            })
            .catch(print);
        box.children = [progress];
        box.show_all();
    });
};
