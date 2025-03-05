import AudioWidget from './Audio';
import BatteryWidget from './Battery';
import BrightnessWidget from './Brightness';
import CpuWidget from './Cpu';
import RamWidget from './Ram';
import TempWidget from './Temp';

export default function HardwareBox() {
    return (
        <box className="hardware-box" spacing={4}>
            {CpuWidget()}
            {RamWidget()}
            {BatteryWidget()}
            {TempWidget()}
            {/* <separator className="hardware-box-separator" /> */}
            {AudioWidget()}
            {BrightnessWidget()}
        </box>
    );
}
