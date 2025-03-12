import GTop from 'gi://GTop';
import { Variable } from 'astal';
import type { Subscribable } from 'astal/binding';

class SystemUsageCalculator {
    private previousCpuData: GTop.glibtop_cpu;
    private cpuUsage: Subscribable<number>;
    private ramUsage: Subscribable<number>;

    constructor() {
        // تهيئة بيانات المعالج
        this.previousCpuData = new GTop.glibtop_cpu();
        GTop.glibtop_get_cpu(this.previousCpuData);

        this.cpuUsage = Variable(0);
        this.ramUsage = Variable(0);

        this.setupPolling();
    }

    private computeCPU(): number {
        const currentCpuData = new GTop.glibtop_cpu();
        GTop.glibtop_get_cpu(currentCpuData);

        const totalDiff = currentCpuData.total - this.previousCpuData.total;
        const idleDiff = currentCpuData.idle - this.previousCpuData.idle;

        const cpuUsagePercentage =
            totalDiff > 0
                ? Math.min(((totalDiff - idleDiff) / totalDiff) * 100, 100)
                : 0;

        this.previousCpuData = currentCpuData;
        return Number(cpuUsagePercentage.toFixed(0));
    }

    private computeRAM(): number {
        const memData = new GTop.glibtop_mem();
        GTop.glibtop_get_mem(memData);

        // استبدال أي قيمة NaN بصفر
        const total = isNaN(memData.total) ? 0 : memData.total;
        const free = isNaN(memData.free) ? 0 : memData.free;
        const buffers = isNaN(memData.buffers) ? 0 : memData.buffers;
        const cached = isNaN(memData.cached) ? 0 : memData.cached;

        // تجنب القسمة على صفر
        if (total === 0) {
            return 0;
        }

        const actualUsed = total - free - buffers - cached;
        const ramUsagePercentage = (actualUsed / total) * 100;
        return Number(ramUsagePercentage.toFixed(0));
    }

    private setupPolling() {
        const poll = () => {
            this.cpuUsage.set(this.computeCPU());
            this.ramUsage.set(this.computeRAM());
        };

        poll();
        setInterval(poll, 1000);
    }

    public getCPUUsage(): Subscribable<number> {
        return this.cpuUsage;
    }

    public getRAMUsage(): Subscribable<number> {
        return this.ramUsage;
    }
}

export const systemCalculator = new SystemUsageCalculator();
export const cpuUsage = systemCalculator.getCPUUsage();
export const ramUsage = systemCalculator.getRAMUsage();
