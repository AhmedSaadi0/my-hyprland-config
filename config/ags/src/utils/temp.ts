import { Variable } from 'astal';
import type { Subscribable } from 'astal/binding';

const GLib = imports.gi.GLib;

class SystemTemperatureCalculator {
    private temperature: Subscribable<number>;

    constructor() {
        // تهيئة المتغير الذي يحمل درجة الحرارة
        this.temperature = Variable(0);
        this.setupPolling();
    }

    /**
     * تحليل ناتج lm-sensors لاستخراج درجة الحرارة.
     * يحاول أولاً البحث عن "Package id 0:" وإذا لم يجده يبحث عن "Core <رقم>:".
     */
    private parseSensorsOutput(output: string): number {
        // البحث عن درجة حرارة الحزمة الرئيسية
        const packageRegex = /Package id 0:\s+\+?([0-9.]+)°C/;
        let match = output.match(packageRegex);
        if (match && match[1]) {
            return parseFloat(match[1]);
        }
        // كبديل: البحث عن أول قراءة من "Core"
        const coreRegex = /Core\s+\d+:\s+\+?([0-9.]+)°C/;
        match = output.match(coreRegex);
        if (match && match[1]) {
            return parseFloat(match[1]);
        }
        return 0;
    }

    /**
     * تشغيل الأمر sensors وقراءة الناتج.
     */
    private readTemperatureUsingSensors(): number {
        try {
            // تشغيل الأمر sensors باستخدام GLib.spawn_command_line_sync
            const [ok, out, err, exit_status] =
                GLib.spawn_command_line_sync('sensors');
            if (ok) {
                // تحويل الناتج من Uint8Array إلى نص باستخدام TextDecoder
                const decoder = new TextDecoder('utf-8');
                const output = decoder.decode(out);
                return this.parseSensorsOutput(output);
            }
            return 0;
        } catch (error) {
            log('حدث خطأ أثناء قراءة بيانات lm-sensors: ' + error);
            return 0;
        }
    }

    private setupPolling() {
        const poll = () => {
            const temp = this.readTemperatureUsingSensors();
            this.temperature.set(temp);
            return true; // استمرار الاستطلاع
        };

        poll();
        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 15, poll);
    }

    public getTemperature(): Subscribable<number> {
        return this.temperature;
    }
}

export const systemTemperatureCalculator = new SystemTemperatureCalculator();
export const temperature = systemTemperatureCalculator.getTemperature();
