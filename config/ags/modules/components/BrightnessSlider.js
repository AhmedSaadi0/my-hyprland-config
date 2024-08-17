import brightness from '../services/BrightnessService.js';
import { local } from '../utils/helpers.js';

const margin = local === 'RTL' ? 'margin-right:0.5rem;' : 'margin-left:0.5rem;';

export const BrightnessSlider = () =>
    Widget.Box({
        className: 'brightness-menu-slider',
        css: 'min-width: 140px',
        children: [
            Widget.Stack({
                className: 'vol-stack',
                children: {
                    b_100: Widget.Label({ css: margin, label: '󰃠' }),
                    b_67: Widget.Label({ css: margin, label: '󰃝' }),
                    b_34: Widget.Label({ css: margin, label: '󰃟' }),
                    b_1: Widget.Label({ css: margin, label: '󰃞' }),
                    b_0: Widget.Label({ css: margin, label: '󰃞' }),
                },
            }).hook(
                brightness,
                (stack) => {
                    const val = brightness.screen_value;

                    const show = [100, 67, 34, 1, 0].find(
                        (threshold) => threshold <= val * 100
                    );

                    stack.shown = `b_${show}`;
                },
                'screen-changed'
            ),
            Widget.Slider({
                hexpand: true,
                className: 'unset',
                drawValue: false,
                onChange: ({ value }) => (brightness.screen_value = value),
            }).hook(
                brightness,
                (slider) => {
                    const val = brightness.screen_value;
                    slider.value = val;
                },
                'screen-changed'
            ),
        ],
    });
