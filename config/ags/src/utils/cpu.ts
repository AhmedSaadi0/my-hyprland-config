import GTop from 'gi://GTop';
import { Variable } from 'astal';
import type { Subscribable } from 'astal/binding';

class CPUUsageCalculator {
    private previousCpuData: GTop.glibtop_cpu;
    private cpuUsage: Subscribable<number>;

    constructor() {
        this.previousCpuData = new GTop.glibtop_cpu();
        GTop.glibtop_get_cpu(this.previousCpuData);

        this.cpuUsage = Variable(0);
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

    private setupPolling() {
        const poll = () => {
            this.cpuUsage.set(this.computeCPU());
        };

        poll();
        setInterval(poll, 2000);
    }

    public getCPUUsage(): Subscribable<number> {
        return this.cpuUsage;
    }
}

export const cpuCalculator = new CPUUsageCalculator();
export const cpuUsage = cpuCalculator.getCPUUsage();
