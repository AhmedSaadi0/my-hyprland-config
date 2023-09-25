import { BatteryWidget } from "./battery.js";
import { CpuWidget } from "./cpu.js";
import { TempWidget } from "./temp.js";
import { RamWidget } from "./ram.js";
const { Box } = ags.Widget


export const HardwareBox = () => Box({
    className: "hardware-box",
    children:[
        CpuWidget(),
        RamWidget(),
        BatteryWidget(),
        TempWidget()
    ]
})