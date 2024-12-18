import { BatteryWidget } from './battery.js';
import { CpuWidget } from './cpu.js';
import { TempWidget } from './temp.js';
import { RamWidget } from './ram.js';
import { AudioWidget } from './audio.js';
import { BrightnessWidget } from './brightness.js';
import { Box } from 'resource:///com/github/Aylur/ags/widget.js';

export const HardwareBox = () =>
    Box({
        className: 'hardware-box small-shadow unset',
        children: [
            CpuWidget(),
            RamWidget(),
            BatteryWidget(),
            TempWidget(),
            Widget.Separator({
                className: 'hardware-box-separator',
                // vertical: false,
            }),
            AudioWidget(),
            BrightnessWidget(),
        ],
    });
