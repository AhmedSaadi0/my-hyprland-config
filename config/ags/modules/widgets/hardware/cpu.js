import {
    Box,
    Button,
    Label,
    CircularProgress,
} from 'resource:///com/github/Aylur/ags/widget.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import { Utils } from '../../utils/imports.js';
import strings from '../../strings.js';
import settings from '../../settings.js';

export const CpuWidget = () => {
    const label = Label({
        className: 'cpu-inner',
        label: '',
    });

    const button = Button({
        className: 'unset no-hover',
        child: label,
        onClicked: () => toggleMonitors(),
    });

    const progress = CircularProgress({
        className: 'cpu',
        child: button,
        startAt: 0,
        rounded: false,
        // inverted: true,
    });

    return Box({
        className: 'bar-hw-cpu-box',
    }).poll(1000, (box) => {
        execAsync(settings.scripts.cpu)
            .then((val) => {
                progress.value = val / 100;
                label.tooltipMarkup = `<span weight='bold' foreground='#FDC227'>${strings.cpuUsage} (${val}%)</span>`;
            })
            .catch(print);
        box.children = [progress];
        box.show_all();
    });
};
