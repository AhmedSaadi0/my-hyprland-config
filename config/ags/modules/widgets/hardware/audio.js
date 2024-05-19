const audio = await Service.import('audio');

export const AudioWidget = () => {
    const label = Widget.Label({
        className: 'volume-inner',
        label: '',
    });

    const button = Widget.Button({
        className: 'unset no-hover',
        child: label,
    });

    const progress = Widget.CircularProgress({
        className: 'volume',
        child: button,
        startAt: 0,
        rounded: false,
        // inverted: true,
    });

    return Widget.Box({
        children: [progress],
    }).hook(audio, (box) => {
        const vol = audio.speaker.volume;
        progress.value = vol;

        if (audio.speaker.is_muted) {
            label.label = '';
        } else if (vol > 0.7) {
            label.label = '';
        } else if (vol > 0.3 && vol < 0.7) {
            label.label = '';
        } else {
            label.label = '';
        }

        box.show_all();
        label.tooltipMarkup = `<span weight='bold'>مستوى الصوت (${parseInt(vol * 100)})</span>`;
    });
};
