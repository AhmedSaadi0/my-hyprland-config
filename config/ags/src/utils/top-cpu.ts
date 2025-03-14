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

    constructor() {
        // متغير لتخزين قائمة العمليات الأكثر استهلاكًا للمعالج
        this.topCPUProcesses = Variable([]);
        this.startMonitoring();
    }

    private fetchTopCPUProcesses(): ProcessUsage[] {
        try {
            const output = exec(settings.scripts.topCpu);

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
            const processes = this.fetchTopCPUProcesses();
            this.topCPUProcesses.set(processes);
            return true; // استمرار التحديث الدوري
        };

        updateProcesses();
        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 3, updateProcesses);
    }

    public getTopCPUProcesses(): Subscribable<ProcessUsage[]> {
        return this.topCPUProcesses;
    }
}

export const cpuUsageMonitor = new CPUUsageMonitor();
export const topCPUProcesses = cpuUsageMonitor.getTopCPUProcesses();
