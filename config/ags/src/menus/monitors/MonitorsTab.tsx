import CpuWidget from '../../widgets/Cpu';
import BatteryWidget from '../../widgets/Battery';
import RamWidget from '../../widgets/Ram';
import TempWidget from '../../widgets/Temp';
import { Table } from '../../widgets/Table';
import { Gtk } from 'astal/gtk3';
import { bind } from 'astal';
import {
    topCPUProcesses,
    topRamProcesses,
} from '../../utils/app-usage-monitor';

export default function HardwareBox({ name = 'monitors' }) {
    return (
        <box name={name} spacing={10} orientation={Gtk.Orientation.VERTICAL}>
            <box className="menu-monitors-box" spacing={10}>
                {CpuWidget({ progressClass: 'menu-cpu' })}
                {RamWidget({ progressClass: 'menu-ram' })}
                {BatteryWidget({ progressClass: 'menu-battery' })}
                {TempWidget({ progressClass: 'menu-temp' })}
            </box>
            <box>
                <Table
                    header={
                        <box>
                            <label
                                label="العملية"
                                css="font-weight: bold; min-width: 130px;"
                            />
                            <label label="%" css="font-weight: bold;" />
                        </box>
                    }
                    rows={bind(topCPUProcesses).as((val) =>
                        val.map((proc) => (
                            <box>
                                <label
                                    label={proc.process}
                                    css="min-width: 130px;"
                                />
                                <label label={proc.usage} />
                            </box>
                        ))
                    )}
                    boxClass="table-box"
                    headerClass="table-header"
                    spacing={10}
                    vertical
                />
                <Table
                    header={
                        <box>
                            <label
                                label="العملية"
                                css="font-weight: bold; min-width: 130px;"
                            />
                            <label label="%" css="font-weight: bold;" />
                        </box>
                    }
                    rows={bind(topRamProcesses).as((val) =>
                        val.map((proc) => (
                            <box>
                                <label
                                    label={proc.process}
                                    css="min-width: 130px;"
                                />
                                <label label={proc.usage} />
                            </box>
                        ))
                    )}
                    boxClass="table-box"
                    headerClass="table-header"
                    spacing={10}
                    vertical
                />
            </box>
        </box>
    );
}
