import weatherService from '../services/WeatherService.js';
import { local, TitleText } from '../utils/helpers.js';
import { Widget } from '../utils/imports.js';


const MenuRevealer = () => {

    const header = TitleText({
        title: "اوقات الصلوات",
        text: "",
        titleClass: "prayer-times-menu-header-title",
        textClass: "prayer-times-menu-header-icon",
        vertical: false,
        boxClass: "prayer-times-menu-header",
        titleXalign: 0,
    })

    const fajr = TitleText({
        title: "صلاة الفجر",
        text: "",
        vertical: false,
        boxClass: "prayer-time-item-box-class",
        spacing: 25,
        titleXalign: 0,
    })

    const dhuhr = TitleText({
        title: "صلاة الظهر",
        text: "",
        vertical: false,
        boxClass: "prayer-time-item-box-class",
        spacing: 25,
        titleXalign: 0,
    })

    const asr = TitleText({
        title: "صلاة العصر",
        text: "",
        vertical: false,
        boxClass: "prayer-time-item-box-class",
        spacing: 25,
        titleXalign: 0,
    })

    const maghrib = TitleText({
        title: "صلاة المغرب",
        text: "",
        vertical: false,
        boxClass: "prayer-time-item-box-class",
        spacing: 14,
        titleXalign: 0,
    })

    const isha = TitleText({
        title: "صلاة العشاء",
        text: "",
        vertical: false,
        boxClass: "prayer-time-item-box-class isha-item",
        spacing: 17,
        titleXalign: 0,
    })

    return Widget.Revealer({
        transition: "slide_down",
        child: Widget.Box({
            className: "prayer-times-menu-box",
            vertical: true,
            children: [
                header,
                fajr,
                dhuhr,
                asr,
                maghrib,
                isha,
            ],
        }).hook(weatherService, box => {
            console.log(weatherService);
        }),
    })
}

const menuRevealer = MenuRevealer();

export const WeatherMenu = () => Widget.Window({
    name: `weather_menu`,
    margins: [6, 510],
    anchor: ['top', local === "RTL" ? "right" : "left"],
    child: Widget.Box({
        css: `
            min-height: 2px;
        `,
        children: [
            menuRevealer,
        ],
    })
});

globalThis.showWeatherMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild
};
