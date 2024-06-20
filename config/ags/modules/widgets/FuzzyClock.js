import strings from '../strings.js';
import { TitleText, local } from '../utils/helpers.js';
import { Widget, Utils } from '../utils/imports.js';

const SATURDAY = 6;
const SUNDAY = 7;
const MONDAY = 1;
const TUESDAY = 2;
const WEDNESDAY = 3;
const THURSDAY = 4;
const FRIDAY = 5;

const FuzzyDay = () =>
    TitleText({
        title: '',
        text: '',
        titleClass: 'wd-fuzzy-day-text',
        textClass: 'wd-fuzzy-day-icon',
        boxClass: 'wd-fuzzy-day-box',
        titleXalign: 0, // local === "RTL" ? 0 : 1,
        textXalign: 0, // local === "RTL" ? 0 : 1,
        vertical: false,
    });

const TimeNow = () =>
    Widget.Label({
        className: 'wd-time-now',
        xalign: 0, // local === "RTL" ? 0 : 1,
    });

const FuzzyTime = () =>
    TitleText({
        title: '',
        text: '',
        titleClass: 'wd-fuzzy-time-text',
        textClass: 'wd-fuzzy-time-icon',
        boxClass: 'wd-fuzzy-time-box',
        titleXalign: 0, // local === "RTL" ? 0 : 1,
        textXalign: 0, // local === "RTL" ? 0 : 1,
        vertical: false,
    });

function setFuzzyWeekdayTimes(hour, usedFuzzyTime) {
    if (hour >= 0 && hour < 4) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockProgrammingTime;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 4 && hour < 9) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockMorning;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 9 && hour < 12) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockCoffee;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 12 && hour < 13) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockLunch;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 13 && hour < 16) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockCreative;
        usedFuzzyTime.children[1].label = '󱈹';
    } else if (hour >= 16 && hour < 18) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockTea;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 18 && hour < 21) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockDinner;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 21) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockNight;
        usedFuzzyTime.children[1].label = '';
    }
}

function setFuzzyWednesdayTimes(hour, usedFuzzyTime) {
    if (hour >= 0 && hour < 4) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockProgrammingTime;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 4 && hour < 9) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockMorning;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 9 && hour < 12) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockCoffee;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 12 && hour < 13) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockLunch;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 13 && hour < 16) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockCreative;
        usedFuzzyTime.children[1].label = '󱈹';
    } else if (hour >= 16 && hour < 18) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockTea;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 18 && hour < 21) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockDinner;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 21) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockNight;
        usedFuzzyTime.children[1].label = '';
    }
}

function setFuzzyFridayTimes(hour, usedFuzzyTime) {
    if (hour >= 0 && hour < 4) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockProgrammingTime;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 4 && hour < 9) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockPray;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 9 && hour < 12) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockBath;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 12 && hour < 13) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockFridayPrayer;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 13 && hour < 15) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockFamily;
        usedFuzzyTime.children[1].label = '󱜜';
    } else if (hour >= 15 && hour < 21) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockFriends;
        usedFuzzyTime.children[1].label = '';
    } else if (hour >= 21) {
        usedFuzzyTime.children[0].label = strings.fuzzyClockRelax;
        usedFuzzyTime.children[1].label = '';
    }
}

function setFuzzyDays(day, usedFuzzyDay, usedTimeNow, hour, usedFuzzyTime) {
    setFuzzyWeekdayTimes(hour, usedFuzzyTime);
    if (day == SATURDAY) {
        usedFuzzyDay.children[0].label = strings.fuzzyDaySaturday;
        usedFuzzyDay.children[1].label = '';
        usedTimeNow.label = strings.usedTimeNowSaturday;
    } else if (day == SUNDAY) {
        usedFuzzyDay.children[0].label = strings.fuzzyDaySunday;
        usedFuzzyDay.children[1].label = '';
        usedTimeNow.label = strings.usedTimeNowSunday;
    } else if (day == MONDAY) {
        usedFuzzyDay.children[0].label = strings.fuzzyDayMonday;
        usedFuzzyDay.children[1].label = '';
        usedTimeNow.label = strings.usedTimeNowMonday;
    } else if (day == TUESDAY) {
        usedFuzzyDay.children[0].label = strings.fuzzyDayTuesday;
        usedFuzzyDay.children[1].label = '';
        usedTimeNow.label = strings.usedTimeNowTuesday;
    } else if (day == WEDNESDAY) {
        usedFuzzyDay.children[0].label = strings.fuzzyDayWednesday;
        usedFuzzyDay.children[1].label = '󰃰';
        usedTimeNow.label = strings.usedTimeNowWednesday;
        setFuzzyWednesdayTimes(hour, usedFuzzyTime);
    } else if (day == THURSDAY) {
        usedFuzzyDay.children[0].label = strings.fuzzyClockThursday;
        usedFuzzyDay.children[1].label = '';
        usedTimeNow.label = strings.usedTimeNowThursday;
        usedFuzzyTime.children[0].label = strings.fuzzyTimeThursday;
        usedFuzzyTime.children[1].label = '';
    } else if (day == FRIDAY) {
        usedFuzzyDay.children[0].label = strings.fuzzyDayFriday;
        usedFuzzyDay.children[1].label = '';
        usedTimeNow.label = strings.usedTimeNowFriday;
        setFuzzyFridayTimes(hour, usedFuzzyTime);
    }
}

export default (className) =>
    Widget.Box({
        className: className || 'wd-fuzzy-clock-box',
        vertical: true,
        children: [FuzzyDay(), TimeNow(), FuzzyTime()],
    }).poll(15 * 1000 * 60, (box) => {
        Utils.execAsync(['date', '+%u|%-k'])
            .then((val) => {
                const date = val.split('|');
                const day = parseInt(date[0]);
                let hour = parseInt(date[1]);

                let usedFuzzyDay = box.children[0];
                let usedTimeNow = box.children[1];
                let usedFuzzyTime = box.children[2];

                setFuzzyDays(
                    day,
                    usedFuzzyDay,
                    usedTimeNow,
                    hour,
                    usedFuzzyTime
                );
            })
            .catch(print);
    });

// export default clock = FuzzyClock();

function createFuzzyHour() {
    const now = new Date();
    const hours = now.getHours();
    let timeOfDay = '';

    if (hours >= 15) {
        timeOfDay = 'مساءً';
    } else if (hours >= 12) {
        timeOfDay = 'ظهرا';
    } else if (hours >= 6) {
        timeOfDay = 'صباحًا';
    } else if (hours >= 4) {
        timeOfDay = 'فجرا';
    } else if (hours > 0) {
        timeOfDay = 'بعد منتصف الليل';
    }

    const arabicNumbers = [
        'الواحدة',
        'الثانية',
        'الثالثة',
        'الرابعة',
        'الخامسة',
        'السادسة',
        'السابعة',
        'الثامنة',
        'التاسعة',
        'العاشرة',
        'الحادية عشر',
        'الثانية عشر',
    ];

    let timeInArabicWords = 'الساعة الآن ';

    if (hours === 0) {
        timeInArabicWords += 'الثانية عشر ليلاً';
    } else if (hours === 12) {
        timeInArabicWords += 'الثانية عشر ظهرًا';
    } else {
        timeInArabicWords += arabicNumbers[(hours % 12) - 1] + ' ' + timeOfDay;
    }

    return timeInArabicWords;
}
