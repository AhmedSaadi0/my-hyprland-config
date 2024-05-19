import settings from '../settings.js';
import { notify } from '../utils/helpers.js';
import { Service, Utils, App } from '../utils/imports.js';

const currentDate = new Date();

const day = currentDate.getDate();
const month = currentDate.getMonth() + 1;
const year = currentDate.getFullYear();

// Create a function to add leading zeros if necessary
function addLeadingZero(number) {
    return number < 10 ? `0${number}` : number;
}

const formattedDate = `${addLeadingZero(day)}-${addLeadingZero(month)}-${year}`;

class PrayerTimesService extends Service {
    static {
        Service.register(
            this,
            {},
            {
                nextPrayerName: ['string', 'r'],
                nextPrayerTime: ['string', 'r'],

                prayerNow: ['string', 'r'],

                hijriDate: ['string', 'r'],
                hijriDay: ['string', 'r'],
                hijriWeekday: ['string', 'r'],
                hijriMonth: ['string', 'r'],
                hijriYear: ['string', 'r'],

                isha: ['string', 'r'],
                maghrib: ['string', 'r'],
                asr: ['string', 'r'],
                dhuhr: ['string', 'r'],
                fajr: ['string', 'r'],
            }
        );
    }

    _prayerNow = null;
    source = null;

    constructor() {
        super();
        this.state = {};
        this.initPrayerTimes();
    }

    initPrayerTimes() {
        Utils.execAsync([
            `curl`,
            `https://api.aladhan.com/v1/timingsByCity/${formattedDate}?city=${settings.prayerTimes.city}&country=${settings.prayerTimes.country}`,
        ])
            .then((val) => {
                const jsonData = JSON.parse(val);
                this.state = jsonData;
                this.emit('changed');
            })
            .catch(() => {
                const source = setTimeout(
                    () => {
                        this.initPrayerTimes();
                        source.destroy();
                    },
                    15 * 60 * 1000
                );
            });
    }

    getMillisecondsBetweenDates(date1, date2) {
        // Get the difference in milliseconds between the two dates.
        let differenceInMilliseconds = date2.getTime() - date1.getTime();
        if (differenceInMilliseconds < 0) {
            differenceInMilliseconds = differenceInMilliseconds * -1;
        }
        return differenceInMilliseconds;
    }

    millisecondsToTime(milliseconds) {
        const totalMilliseconds = parseInt(milliseconds);

        const hours = Math.floor(totalMilliseconds / 3600000);
        const minutes = Math.floor((totalMilliseconds % 3600000) / 60000);
        const seconds = Math.floor(
            ((totalMilliseconds % 3600000) % 60000) / 1000
        );

        // Return the time as a string.
        return `${hours}:${minutes}:${seconds}`;
    }

    getPrayerNameAr(prayerTime) {
        switch (prayerTime) {
            case 'Isha':
                return 'العشاء';
            case 'Maghrib':
                return 'المغرب';
            case 'Asr':
                return 'العصر';
            case 'Dhuhr':
                return 'الظهر';
            case 'Fajr':
                return 'الفجر';
            default:
                return '';
        }
    }

    notifyForCurrentPrayerTime(now, secondTime, prayerName) {
        this.source = setTimeout(
            () => {
                notify({
                    title: 'اوقات الصلوات !',
                    message: `حان الان موعد صلاة (${prayerName})`,
                    icon: settings.assets.icons.mosque,
                    tonePath: settings.assets.audio.prayer_time,
                });
                this._prayerNow = null;

                this.emit('changed');
                // this.calculateForNextPrayerTime();
                this.source.destroy();
            },
            this.getMillisecondsBetweenDates(now, secondTime)
        );
    }

    calculateForNextPrayerTime() {
        const calculate = setTimeout(
            () => {
                this._prayerNow = null;
                this.emit('changed');
                calculate.destroy();
            },
            20 * 60 * 1000
        );
    }

    getHoursMinutes(date) {
        if (date === null || date === undefined) {
            return '-';
        }

        const hours = date.getHours();
        const minutes = date.getMinutes();
        // const ampm = hours >= 12 ? 'PM' : 'AM';
        let formattedHours = hours % 12 || 12; // Convert 0 to 12 for AM/PM display
        const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes;

        formattedHours =
            formattedHours < 10 ? `0${formattedHours}` : formattedHours;

        const formattedTime = `${formattedHours}:${formattedMinutes}`;

        return formattedTime;
    }

    calculateTimes(json, now) {
        const prayerTimes = ['Isha', 'Maghrib', 'Asr', 'Dhuhr', 'Fajr'];

        for (const prayerTime of prayerTimes) {
            // Checks if it is now a prayer time
            const prayerTimeObj = this.timeToDateObj(
                json.data.timings[prayerTime]
            );
            const fifteenMinutesAfterPrayerTime = new Date(
                prayerTimeObj.getTime() + 20 * 60 * 1000
            ); // Adds 15 minutes to prayer time in milliseconds

            if (now >= prayerTimeObj && now < fifteenMinutesAfterPrayerTime) {
                this._prayerNow = this.getPrayerNameAr(prayerTime);
                this.calculateForNextPrayerTime();
                break;
            }
        }

        if (this.source) {
            this.source.destroy();
        }
    }

    getNextPrayerTime(json) {
        const now = new Date();

        if (Object.keys(json).length === 0 || json.code === 404) {
            return {
                name: '',
                time: '',
            };
        }

        let isha = this.timeToDateObj(json.data.timings.Isha);
        let maghrib = this.timeToDateObj(json.data.timings.Maghrib);
        let asr = this.timeToDateObj(json.data.timings.Asr);
        let dhuhr = this.timeToDateObj(json.data.timings.Dhuhr);
        let fajr = this.timeToDateObj(json.data.timings.Fajr);

        this.calculateTimes(json, now);

        if (now >= isha || now < fajr) {
            this.notifyForCurrentPrayerTime(now, fajr, 'الفجر');
            return {
                name: 'الفجر',
                time: this.getHoursMinutes(fajr),
            };
        }

        if (now >= maghrib && now < isha) {
            this.notifyForCurrentPrayerTime(now, isha, 'العشاء');
            return {
                name: 'العشاء',
                time: this.getHoursMinutes(isha),
            };
        }

        if (now >= asr && now < maghrib) {
            this.notifyForCurrentPrayerTime(now, maghrib, 'المغرب');
            return {
                name: 'المغرب',
                time: this.getHoursMinutes(maghrib),
            };
        }

        if (now >= dhuhr && now < asr) {
            this.notifyForCurrentPrayerTime(now, asr, 'العصر');
            return {
                name: 'العصر',
                time: this.getHoursMinutes(asr),
            };
        } else {
            this.notifyForCurrentPrayerTime(now, dhuhr, 'الظهر');
            return {
                name: 'الظهر',
                time: this.getHoursMinutes(dhuhr),
            };
        }
    }

    timeToDateObj(time) {
        // Split the time string into hours and minutes
        if (time === undefined) {
            return null;
        }

        const [hours, minutes] = time.split(':');

        // Create a new Date object
        const date = new Date();

        // Set the hours and minutes of the Date object
        date.setHours(hours);
        date.setMinutes(minutes);

        // Return the Date object
        return date;
    }

    // Getters
    get prayerNow() {
        return this._prayerNow;
    }

    get nextPrayerName() {
        return this.getNextPrayerTime(this.state).name;
    }

    get nextPrayerTime() {
        return this.getNextPrayerTime(this.state).time;
    }

    get hijriDate() {
        return this.state?.data?.date.hijri.date;
    }

    get hijriDay() {
        return this.state?.data?.date?.hijri.day;
    }

    get hijriWeekday() {
        return decodeUnicode(this.state?.data?.date.hijri.weekday.ar);
    }

    get hijriMonth() {
        return decodeUnicode(this.state?.data?.date.hijri.month.ar);
    }

    get hijriYear() {
        return this.state?.data.date.hijri.year;
    }

    get isha() {
        let isha = this.timeToDateObj(this.state?.data?.timings.Isha);
        return this.getHoursMinutes(isha);
    }
    get maghrib() {
        let maghrib = this.timeToDateObj(this.state?.data?.timings.Maghrib);
        return this.getHoursMinutes(maghrib);
    }
    get asr() {
        let asr = this.timeToDateObj(this.state?.data?.timings.Asr);
        return this.getHoursMinutes(asr);
    }
    get dhuhr() {
        let dhuhr = this.timeToDateObj(this.state?.data?.timings.Dhuhr);
        return this.getHoursMinutes(dhuhr);
    }
    get fajr() {
        return this.state?.data?.timings.Fajr;
    }

    decodeUnicode(str) {
        // Create a regular expression to match Unicode escape sequences
        const regex = /\\u([a-fA-F0-9]{4})/g;

        // Replace all Unicode escape sequences with their corresponding characters
        const decodedStr = str.replace(regex, (match, uCode) => {
            return String.fromCharCode(parseInt(uCode, 16));
        });

        // Return the decoded string
        return decodedStr;
    }
}

// the singleton instance
const prayerService = new PrayerTimesService();

// export to use in other modules
export default prayerService;
