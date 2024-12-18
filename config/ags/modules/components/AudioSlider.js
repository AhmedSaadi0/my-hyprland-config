const Audio = await Service.import('audio');

export const AudioSlider = () =>
    Widget.Box({
        className: 'audio-menu-slider',
        css: 'min-width: 140px',
        children: [
            Widget.Stack({
                className: 'vol-stack',
                children: {
                    v_101: Widget.Icon('audio-volume-overamplified-symbolic'),
                    v_67: Widget.Icon('audio-volume-high-symbolic'),
                    v_34: Widget.Icon('audio-volume-medium-symbolic'),
                    v_1: Widget.Icon('audio-volume-low-symbolic'),
                    v_0: Widget.Icon('audio-volume-muted-symbolic'),
                },
            }).hook(
                Audio,
                (stack) => {
                    if (!Audio.speaker) return;

                    if (Audio.speaker.isMuted) {
                        stack.shown = 'v_0';
                        return;
                    }

                    const show = [101, 67, 34, 1, 0].find(
                        (threshold) => threshold <= Audio.speaker.volume * 100
                    );

                    stack.shown = `v_${show}`;
                },
                'speaker-changed'
            ),
            Widget.Slider({
                hexpand: true,
                className: 'unset',
                drawValue: false,
                onChange: ({ value }) => (Audio.speaker.volume = value),
            }).hook(
                Audio,
                (slider) => {
                    slider.value = Audio.speaker.volume;
                },
                'speaker-changed'
            ),
        ],
    });
