import GTop from 'gi://GTop';
import GLib from 'gi://GLib';
import { Variable } from 'astal';
import type { Subscribable } from 'astal/binding';

interface NetworkInterfaceStats {
    rx: number;
    tx: number;
}

interface AggregatedNetworkStats {
    rx: number;
    tx: number;
}

/**
 * دالة لقراءة بيانات الشبكة من ملف /proc/net/dev باستخدام TextDecoder
 * @returns سجل بإحصائيات الواجهات أو null في حال الفشل
 */
function getNetworkStats(): Record<string, NetworkInterfaceStats> | null {
    const [ok, out] = GLib.spawn_command_line_sync('cat /proc/net/dev');
    if (!ok || !out) {
        return null;
    }
    const decoder = new TextDecoder('utf-8');
    const output = decoder.decode(out);
    const lines = output.split('\n');
    const stats: Record<string, NetworkInterfaceStats> = {};

    // تجاهل السطرين الأولين (رؤوس الأعمدة)
    for (let i = 2; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        const parts = line.split(/[:\s]+/);
        const iface = parts[0];
        // تجاهل واجهة loopback
        if (iface === 'lo') continue;
        stats[iface] = {
            rx: parseInt(parts[1], 10),
            tx: parseInt(parts[9], 10),
        };
    }
    return stats;
}

/**
 * دالة لتجميع إحصائيات الشبكة لجميع الواجهات (باستثناء loopback)
 * @param stats سجل الواجهات وإحصائياتها
 * @returns إحصائيات مجمعة (rx و tx)
 */
function aggregateNetworkStats(
    stats: Record<string, NetworkInterfaceStats>
): AggregatedNetworkStats {
    return Object.values(stats).reduce(
        (acc, { rx, tx }) => ({
            rx: acc.rx + rx,
            tx: acc.tx + tx,
        }),
        { rx: 0, tx: 0 }
    );
}

class SystemUsageCalculator {
    private previousCpuData: GTop.glibtop_cpu;
    private previousNetRx: number;
    private previousNetTx: number;
    private cpuUsage: Subscribable<number>;
    private ramUsage: Subscribable<number>;
    private netSpeed: Subscribable<AggregatedNetworkStats>;

    constructor() {
        // تهيئة بيانات المعالج
        this.previousCpuData = new GTop.glibtop_cpu();
        GTop.glibtop_get_cpu(this.previousCpuData);

        // تهيئة بيانات الشبكة باستخدام /proc/net/dev
        const initialStats = getNetworkStats();
        if (initialStats) {
            const aggregated = aggregateNetworkStats(initialStats);
            this.previousNetRx = aggregated.rx;
            this.previousNetTx = aggregated.tx;
        } else {
            this.previousNetRx = 0;
            this.previousNetTx = 0;
        }

        this.cpuUsage = Variable(0);
        this.ramUsage = Variable(0);
        // نبدأ بسرعة الشبكة على أنها 0 كيلو بايت/ثانية
        this.netSpeed = Variable({ rx: 0, tx: 0 });

        this.setupPolling();
    }

    /**
     * حساب نسبة استخدام المعالج
     * @returns نسبة الاستخدام كعدد صحيح
     */
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

    /**
     * حساب نسبة استخدام الذاكرة
     * @returns نسبة استخدام الذاكرة كعدد صحيح
     */
    private computeRAM(): number {
        const memData = new GTop.glibtop_mem();
        GTop.glibtop_get_mem(memData);

        const total = isNaN(memData.total) ? 0 : memData.total;
        const free = isNaN(memData.free) ? 0 : memData.free;
        const buffers = isNaN(memData.buffers) ? 0 : memData.buffers;
        const cached = isNaN(memData.cached) ? 0 : memData.cached;

        if (total === 0) {
            return 0;
        }

        const actualUsed = total - free - buffers - cached;
        const ramUsagePercentage = (actualUsed / total) * 100;
        return Number(ramUsagePercentage.toFixed(0));
    }

    /**
     * حساب سرعة الشبكة (بالكيلو بايت/ثانية) بناءً على اختلاف البيانات
     * @returns سرعة الشبكة مجمعة (rx و tx)
     */
    private computeNetwork(): AggregatedNetworkStats {
        const stats = getNetworkStats();
        if (!stats) {
            return { rx: 0, tx: 0 };
        }
        const aggregated = aggregateNetworkStats(stats);
        const rxDiff = aggregated.rx - this.previousNetRx;
        const txDiff = aggregated.tx - this.previousNetTx;

        // تحديث القيم السابقة لاستخدامها في الدورة القادمة
        this.previousNetRx = aggregated.rx;
        this.previousNetTx = aggregated.tx;

        // تحويل السرعة من بايت/ثانية إلى كيلو بايت/ثانية
        return { rx: rxDiff / 1024, tx: txDiff / 1024 };
    }

    /**
     * إعداد الاستطلاع الدوري لكل البيانات
     */
    private setupPolling(): void {
        const poll = (): void => {
            this.cpuUsage.set(this.computeCPU());
            this.ramUsage.set(this.computeRAM());
            this.netSpeed.set(this.computeNetwork());
        };

        poll();
        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
            poll();
            return true;
        });
    }

    public getCPUUsage(): Subscribable<number> {
        return this.cpuUsage;
    }

    public getRAMUsage(): Subscribable<number> {
        return this.ramUsage;
    }

    public getNetworkSpeed(): Subscribable<AggregatedNetworkStats> {
        return this.netSpeed;
    }
}

export const systemCalculator = new SystemUsageCalculator();
export const cpuUsage = systemCalculator.getCPUUsage();
export const ramUsage = systemCalculator.getRAMUsage();
export const networkSpeed = systemCalculator.getNetworkSpeed();
