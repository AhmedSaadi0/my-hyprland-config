import CpuWidget from '../../widgets/Cpu';
import BatteryWidget from '../../widgets/Battery';
import BrightnessWidget from '../../widgets/Brightness';
import RamWidget from '../../widgets/Ram';
import TempWidget from '../../widgets/Temp';
import AudioWidget from '../../widgets/Audio';

export default function HardwareBox() {
    return (
        <box className="hardware-box" spacing={4}>
            {CpuWidget({})}
            {RamWidget({})}
            {BatteryWidget({})}
            {TempWidget({})}
            {/* <separator className="hardware-box-separator" /> */}
            {/* {AudioWidget({})} */}
            {/* {BrightnessWidget({})} */}
        </box>
    );
}
