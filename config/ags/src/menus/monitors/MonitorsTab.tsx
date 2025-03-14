import CpuWidget from '../../widgets/Cpu';
import BatteryWidget from '../../widgets/Battery';
import RamWidget from '../../widgets/Ram';
import TempWidget from '../../widgets/Temp';
import { Table } from '../../widgets/Table';
import { Gtk } from 'astal/gtk3';
import { bind, execAsync, interval } from 'astal';
import settings from '../../utils/settings';
import { topCPUProcesses } from '../../utils/top-cpu';

export default function HardwareBox({ name = 'monitors' }) {
    const fakeProcesses = [
        { name: 'firefox', cpu: '12.3%' },
        { name: 'gnome-shell', cpu: '8.5%' },
        { name: 'chrome', cpu: '6.7%' },
        { name: 'systemd', cpu: '4.2%' },
        { name: 'code', cpu: '3.1%' },
    ];

    const topCpu = bind(topCPUProcesses).as((val) => val);

    return (
        <box name={name} spacing={10} orientation={Gtk.Orientation.VERTICAL}>
            <box className="menu-monitors-box" spacing={10}>
                {CpuWidget({ progressClass: 'menu-cpu' })}
                {RamWidget({ progressClass: 'menu-ram' })}
                {BatteryWidget({ progressClass: 'menu-battery' })}
                {TempWidget({ progressClass: 'menu-temp' })}
            </box>
            <Table
                header={
                    <box>
                        <label
                            label="العملية"
                            css="font-weight: bold; min-width: 150px;"
                        />
                        <label label="%" css="font-weight: bold;" />
                    </box>
                }
                rows={bind(topCPUProcesses).as((val) => {
                    return val.map((proc) => (
                        <box>
                            <label
                                label={proc.process}
                                css="min-width: 150px;"
                            />
                            <label label={proc.usage} />
                        </box>
                    ));
                })}
                boxClass="table-box"
                headerClass="table-header"
                rowClass="table-row"
                spacing={10}
                vertical
            />
        </box>
    );
}
