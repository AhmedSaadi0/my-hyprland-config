import { TitleText } from "../utils/helpers.js";
import { Widget, Utils } from "../utils/imports.js";

const SATURDAY = 6;
const SUNDAY = 7;
const MONDAY = 1;
const TUESDAY = 2;
const WEDNESDAY = 3;
const THURSDAY = 4;
const FRIDAY = 5;


const fuzzyDay = TitleText({
    title: "",
    text: "",
    titleClass: "wd-fuzzy-day-text",
    textClass: "wd-fuzzy-day-icon",
    boxClass: "wd-fuzzy-day-box",
    titleXalign: 0,
    textXalign: 0,
    vertical: false,
});

const timeNow = Widget.Label({
    className: "wd-time-now",
    xalign: 0,
})

const fuzzyTime = TitleText({
    title: "",
    text: "",
    titleClass: "wd-fuzzy-time-text",
    textClass: "wd-fuzzy-time-icon",
    boxClass: "wd-fuzzy-time-box",
    titleXalign: 0,
    textXalign: 0,
    vertical: false,
});

export default FuzzyClock => Widget.Box({
    className: "wd-fuzzy-clock-box",
    vertical: true,
    children: [
        fuzzyDay,
        timeNow,
        fuzzyTime,
    ],
    connections: [[900000, box => {
        Utils.execAsync([
            'date',
            '+%u|%-k'
        ]).then(val => {
            const date = val.split("|")
            const day = date[0]
            let hour = date[1]

            if (day == SATURDAY) {
                fuzzyDay.children[0].label = "اسبوع جديد";
                fuzzyDay.children[1].label = "";
            } else if (day == SUNDAY) {
                fuzzyDay.children[0].label = "استمر";
                fuzzyDay.children[1].label = "";
            } else if (day == MONDAY) {
                // fuzzyDay.children[0].label = "واصل طريقك";
                fuzzyDay.children[0].label = "جلسة";
                // fuzzyDay.children[1].label = "🎶";
                fuzzyDay.children[1].label = "";
            } else if (day == TUESDAY) {
                fuzzyDay.children[0].label = "نصف الاسبوع";
                // fuzzyDay.children[1].label = "";
                fuzzyDay.children[1].label = "";
            } else if (day == WEDNESDAY) {
                fuzzyDay.children[0].label = "باقي يومين";
                // fuzzyDay.children[1].label = "";
                fuzzyDay.children[1].label = "";
            } else if (day == THURSDAY) {
                fuzzyDay.children[0].label = "ارررحب يالخميس";
                fuzzyDay.children[1].label = "";
            } else if (day == FRIDAY) {
                fuzzyDay.children[0].label = "عطلة";
                // fuzzyDay.children[1].label = "";
                fuzzyDay.children[1].label = "";
            }


            if (hour >= 0 && hour < 4) {
                fuzzyTime.children[0].label = "وقت البرمجة";
                // fuzzyTime.children[1].label = "";
                fuzzyTime.children[1].label = "";
            } else if (hour >= 4 && hour < 9) {
                fuzzyTime.children[0].label = "صباح الخير";
                fuzzyTime.children[1].label = "";
            } else if (hour >= 9 && hour < 12) {
                fuzzyTime.children[0].label = "الصبوح";
                fuzzyTime.children[1].label = "";
            } else if (hour >= 12 && hour < 15) {
                fuzzyTime.children[0].label = "الغداء";
                fuzzyTime.children[1].label = "";
            } else if (hour >= 15 && hour < 18) {
                fuzzyTime.children[0].label = "شاي بعد الغداء";
                fuzzyTime.children[1].label = "";
            } else if (hour >= 18 && hour < 21) {
                fuzzyTime.children[0].label = "العشاء";
                fuzzyTime.children[1].label = "";
            } else if (hour >= 21) {
                fuzzyTime.children[0].label = "ليلة سعيدة";
                fuzzyTime.children[1].label = "";
            }

            if (hour > 12) {
                hour = hour - 12;
            }
            timeNow.label = `الساعة الان ${hour}`;

        }).catch(print)
    }]]
});

// export default clock = FuzzyClock();
