import prayerService from '../services/PrayerTimesService.js';
import { local, TitleText } from '../utils/helpers.js';
import { Widget } from '../utils/imports.js';
import settings from '../settings.js';

const MenuRevealer = () => {
    const header = TitleText({
        title: 'اوقات الصلوات',
        text: '',
        titleClass: 'prayer-times-menu-header-title',
        textClass: 'prayer-times-menu-header-icon',
        vertical: false,
        boxClass: 'prayer-times-menu-header',
        titleXalign: 0,
    });

    const fajr = TitleText({
        title: 'صلاة الفجر',
        text: '',
        vertical: false,
        boxClass: 'prayer-time-item-box-class',
        spacing: 25,
        titleXalign: 0,
    });

    const dhuhr = TitleText({
        title: 'صلاة الظهر',
        text: '',
        vertical: false,
        boxClass: 'prayer-time-item-box-class',
        spacing: 25,
        titleXalign: 0,
    });

    const asr = TitleText({
        title: 'صلاة العصر',
        text: '',
        vertical: false,
        boxClass: 'prayer-time-item-box-class',
        spacing: 25,
        titleXalign: 0,
    });

    const maghrib = TitleText({
        title: 'صلاة المغرب',
        text: '',
        vertical: false,
        boxClass: 'prayer-time-item-box-class',
        spacing: 14,
        titleXalign: 0,
    });

    const isha = TitleText({
        title: 'صلاة العشاء',
        text: '',
        vertical: false,
        boxClass: 'prayer-time-item-box-class isha-item',
        spacing: 17,
        titleXalign: 0,
    });

    return Widget.Revealer({
        transition: settings.theme.menuTransitions.prayerTimesMenu,
        transitionDuration:
            settings.theme.menuTransitions.prayerTimesMenuDuration,
        child: Widget.Box({
            className: 'prayer-times-menu-box',
            vertical: true,
            children: [header, fajr, dhuhr, asr, maghrib, isha],
        }).hook(prayerService, (box) => {
            const nextPrayer = prayerService.nextPrayerName;

            box.children[1].children[1].label = `${prayerService.fajr}`;
            box.children[2].children[1].label = `${prayerService.dhuhr}`;
            box.children[3].children[1].label = `${prayerService.asr}`;
            box.children[4].children[1].label = `${prayerService.maghrib}`;
            box.children[5].children[1].label = `${prayerService.isha}`;

            if (typeof prayerService.hijriDate === 'string') {
                header.children[0].label = prayerService.hijriDate;
            } else {
                header.children[0].label = '';
            }

            if (nextPrayer === 'الفجر') {
                updateClasses(box, 1);
            } else if (nextPrayer === 'الظهر') {
                updateClasses(box, 2);
            } else if (nextPrayer === 'العصر') {
                updateClasses(box, 3);
            } else if (nextPrayer === 'المغرب') {
                updateClasses(box, 4);
            } else if (nextPrayer === 'العشاء') {
                updateClasses(box, 5);
            }
        }),
    });
};

function updateClasses(box, selected) {
    box.children[1].className = `prayer-time-item-box-class`;
    box.children[2].className = `prayer-time-item-box-class`;
    box.children[3].className = `prayer-time-item-box-class`;
    box.children[4].className = `prayer-time-item-box-class`;
    box.children[5].className = `prayer-time-item-box-class`;

    var isha = '';
    if (selected === 5) {
        isha = 'isha-item';
    }

    box.children[selected].className =
        `prayer-time-item-box-class next-prayer ${isha}`;
}

const menuRevealer = MenuRevealer();

export const PrayerTimesMenu = () =>
    Widget.Window({
        name: `prayer_times_menu`,
        margins: [2, 510],
        anchor: ['top', local === 'RTL' ? 'right' : 'left'],
        child: Widget.Box({
            css: `
            min-height: 2px;
        `,
            children: [menuRevealer],
        }),
    });

globalThis.showPrayerTimesMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild;
};
