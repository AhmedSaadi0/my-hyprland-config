import { BatteryWidget } from './battery.js';
import { CpuWidget } from './cpu.js';
import { TempWidget } from './temp.js';
import { RamWidget } from './ram.js';
import { Box } from 'resource:///com/github/Aylur/ags/widget.js';

export const HardwareBox = () =>
  Box({
    className: 'hardware-box unset',
    children: [CpuWidget(), RamWidget(), BatteryWidget(), TempWidget()],
  });

