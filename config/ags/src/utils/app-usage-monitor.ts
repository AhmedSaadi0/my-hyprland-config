import { exec, GLib, Variable } from 'astal';
import type { Subscribable } from 'astal/binding';
import settings from './settings';

interface ProcessUsage {
    pid: number;
    process: string;
    usage: number;
}

class CPUUsageMonitor {
    private topCPUProcesses: Subscribable<ProcessUsage[]>;
    private topRAMProcesses: Subscribable<ProcessUsage[]>;

    constructor() {
        // متغير لتخزين قائمة العمليات الأكثر استهلاكًا للمعالج
        this.topCPUProcesses = Variable([]);
        this.topRAMProcesses = Variable([]);
        this.startMonitoring();
    }

    private fetchTop(script: string): ProcessUsage[] {
        try {
            const output = exec(script);

            if (!output) {
                print('⚠️ لم يتم الحصول على أي بيانات من السكربت.');
                return [];
            }

            const parsedData: ProcessUsage[] = JSON.parse(output);

            return parsedData.map((process) => ({
                pid: process.pid,
                process: process.process,
                usage: process.usage,
            }));
        } catch (error) {
            print(
                '❌ خطأ أثناء جلب العمليات الأكثر استهلاكًا للمعالج: ' + error
            );
            return [];
        }
    }

    private startMonitoring() {
        const updateProcesses = () => {
            const processes = this.fetchTop(settings.scripts.topCpu);
            const memory = this.fetchTop(settings.scripts.topRam);
            this.topCPUProcesses.set(processes);
            this.topRAMProcesses.set(memory);
            return true; // استمرار التحديث الدوري
        };

        updateProcesses();
        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, updateProcesses);
    }

    public getTopCPUProcesses(): Subscribable<ProcessUsage[]> {
        return this.topCPUProcesses;
    }

    public getTopRAMProcesses(): Subscribable<ProcessUsage[]> {
        return this.topRAMProcesses;
    }
}

export const cpuUsageMonitor = new CPUUsageMonitor();
export const topCPUProcesses = cpuUsageMonitor.getTopCPUProcesses();
export const topRamProcesses = cpuUsageMonitor.getTopRAMProcesses();
