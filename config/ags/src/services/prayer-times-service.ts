import { execAsync, exec } from 'astal/process';
import { timeout } from 'astal/time';
import settings from '../utils/settings';

class PrayerTimes {
    private state: any = {};
    private prayerNow: string | null = null;
    private source: any = null;

    constructor() {
        if (settings.usePrayerTimes) {
            console.log('Starting prayer times service');
            this.initPrayerTimes();
        }
    }

    private async initPrayerTimes() {
        const currentDate = new Date();
        const formattedDate = `${this.addLeadingZero(currentDate.getDate())}-${this.addLeadingZero(currentDate.getMonth() + 1)}-${currentDate.getFullYear()}`;

        try {
            const url = `https://api.aladhan.com/v1/timingsByCity/${formattedDate}?city=${settings.prayerTimes.city}&country=${settings.prayerTimes.country}`;
            const response = await execAsync(['curl', '-s', url]);
            this.state = JSON.parse(response);
            this.emitChange();
        } catch (error) {
            console.error('Failed to fetch prayer times:', error);
            this.scheduleRetry();
        }
    }

    private scheduleRetry() {
        timeout(15 * 60 * 1000, () => {
            this.initPrayerTimes();
        });
    }

    private addLeadingZero(value: number): string {
        return value < 10 ? `0${value}` : `${value}`;
    }

    private emitChange() {
        // Implement event emission logic if needed
        console.log('Prayer times updated', this.state);
    }

    private notify({
        title,
        message,
        icon,
        tonePath,
    }: {
        title: string;
        message: string;
        icon?: string;
        tonePath?: string;
    }) {
        const iconOption = icon ? `-i ${icon}` : '';
        exec(['notify-send', iconOption, title, message]);

        if (tonePath) {
            exec(['bash', '-c', `paplay ${tonePath}`]);
        }
    }
}

const prayerService = new PrayerTimes();
export default prayerService;
