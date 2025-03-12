import CpuWidget from '../../widgets/Cpu';
import BatteryWidget from '../../widgets/Battery';
import RamWidget from '../../widgets/Ram';
import TempWidget from '../../widgets/Temp';

export default function HardwareBox({ name = 'monitors' }) {
    return (
        <box name={name} className="menu-monitors-box" spacing={17}>
            {CpuWidget({ progressClass: 'menu-cpu' })}
            {RamWidget({ progressClass: 'menu-ram' })}
            {BatteryWidget({ progressClass: 'menu-battery' })}
            {TempWidget({ progressClass: 'menu-temp' })}
        </box>
    );
}
