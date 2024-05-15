import ShowWindow from '../utils/ShowWindow.js';
import brightness from '../services/BrightnessService.js';

const Box = Widget.Box;
const Stack = Widget.Stack;
const Label = Widget.Label;
const Slider = Widget.Slider;
const Window = Widget.Window;

var oldValue = 0;

import { local } from '../utils/helpers.js';

const margin = local === 'RTL' ? 'margin-right:0.5rem;' : 'margin-left:0.5rem;';

export const BrightnessBox = () =>
  Box({
    className: 'vol-osd shadow',
    css: 'min-width: 140px',
    children: [
      Stack({
        className: 'vol-stack',
        children: {
          // tuples of [string, Widget]
          100: Label({ css: margin, label: '󰃠' }),
          67: Label({ css: margin, label: '󰃝' }),
          34: Label({ css: margin, label: '󰃟' }),
          1: Label({ css: margin, label: '󰃞' }),
          0: Label({ css: margin, label: '󰃞' }),
        },
      }).hook(
        brightness,
        (stack) => {
          const val = brightness.screen_value;

          const show = [100, 67, 34, 1, 0].find(
            (threshold) => threshold <= val * 100
          );

          stack.shown = `${show}`;
        },
        'screen-changed'
      ),
      Slider({
        hexpand: true,
        className: 'unset',
        drawValue: false,
        onChange: ({ value }) => (Audio.speaker.volume = value),
      }).hook(
        brightness,
        (slider) => {
          const val = brightness.screen_value;

          // App.closeWindow('vol_osd');
          ShowWindow('brightness_osd');

          oldValue = val;
          slider.value = oldValue;
        },
        'screen-changed'
      ),
    ],
  });

export const BrightnessOSD = () =>
  Window({
    name: `brightness_osd`,
    focusable: false,
    margins: [0, 0, 140, 0],
    layer: 'overlay',
    popup: true,
    anchor: ['bottom'],
    child: BrightnessBox(),
  });
