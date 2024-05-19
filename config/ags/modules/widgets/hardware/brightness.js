import brightness from '../../services/BrightnessService.js';

export const BrightnessWidget = () => {
    const label = Widget.Label({
        className: 'brightness-inner',
        label: '󰃠',
    });

    const button = Widget.Button({
        className: 'unset no-hover',
        child: label,
    });

    const progress = Widget.CircularProgress({
        className: 'brightness',
        child: button,
        startAt: 0,
        rounded: false,
        // inverted: true,
    });

    return Widget.Box({
        className: 'bar-hw-brightness-box',
        children: [progress],
    }).hook(brightness, (box) => {
        const val = brightness.screen_value;
        progress.value = val;
        label.tooltipMarkup = `<span weight='bold'>مستوى السطوع (${val * 100})</span>`;

        if (val === 1) {
            label.label = '󰃠';
        } else if (val > 0.67) {
            label.label = '󰃝';
        } else if (val > 0.34) {
            label.label = '󰃟';
        } else {
            label.label = '󰃞';
        }

        box.show_all();
    });
};
