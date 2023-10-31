import { TitleText } from "../utils/helpers.js";
import { Widget, Utils } from "../utils/imports.js";

const SATURDAY = 6;
const SUNDAY = 7;
const MONDAY = 1;
const TUESDAY = 2;
const WEDNESDAY = 3;
const THURSDAY = 4;
const FRIDAY = 5;


const FuzzyDay = () => TitleText({
    title: "",
    text: "",
    titleClass: "wd-fuzzy-day-text",
    textClass: "wd-fuzzy-day-icon",
    boxClass: "wd-fuzzy-day-box",
    titleXalign: 0,
    textXalign: 0,
    vertical: false,
});

const TimeNow = () => Widget.Label({
    className: "wd-time-now",
    xalign: 0,
})

const FuzzyTime = () => TitleText({
    title: "",
    text: "",
    titleClass: "wd-fuzzy-time-text",
    textClass: "wd-fuzzy-time-icon",
    boxClass: "wd-fuzzy-time-box",
    titleXalign: 0,
    textXalign: 0,
    vertical: false,
});

export default className => Widget.Box({
    className: className || "wd-fuzzy-clock-box",
    vertical: true,
    children: [
        FuzzyDay(),
        TimeNow(),
        FuzzyTime(),
    ],
    connections: [[(15 * 1000 * 60), box => {
        Utils.execAsync([
            'date',
            '+%u|%-k'
        ]).then(val => {
            const date = val.split("|")
            const day = date[0]
            let hour = date[1]

            let usedFuzzyDay = box.children[0];
            let usedTimeNow = box.children[1];
            let usedFuzzyTime = box.children[2];

            if (day == SATURDAY) {
                usedFuzzyDay.children[0].label = "اسبوع جديد";
                usedFuzzyDay.children[1].label = "";
            } else if (day == SUNDAY) {
                usedFuzzyDay.children[0].label = "استمر";
                usedFuzzyDay.children[1].label = "";
            } else if (day == MONDAY) {
                // fuzzyDatWd.children[0].label = "واصل طريقك";
                usedFuzzyDay.children[0].label = "جلسة";
                // fuzzyDatWd.children[1].label = "🎶";
                usedFuzzyDay.children[1].label = "";
            } else if (day == TUESDAY) {
                usedFuzzyDay.children[0].label = "نصف الاسبوع";
                // fuzzyDatWd.children[1].label = "";
                usedFuzzyDay.children[1].label = "";
            } else if (day == WEDNESDAY) {
                usedFuzzyDay.children[0].label = "باقي يومين";
                // fuzzyDatWd.children[1].label = "";
                usedFuzzyDay.children[1].label = "";
            } else if (day == THURSDAY) {
                usedFuzzyDay.children[0].label = "ارررحب يالخميس";
                usedFuzzyDay.children[1].label = "";
            } else if (day == FRIDAY) {
                usedFuzzyDay.children[0].label = "عطلة";
                // fuzzyDatWd.children[1].label = "";
                usedFuzzyDay.children[1].label = "";
            }


            if (hour >= 0 && hour < 4) {
                usedFuzzyTime.children[0].label = "وقت البرمجة";
                // usedFuzzyTime.children[1].label = "";
                usedFuzzyTime.children[1].label = "";
            } else if (hour >= 4 && hour < 9) {
                usedFuzzyTime.children[0].label = "صباح الخير";
                usedFuzzyTime.children[1].label = "";
            } else if (hour >= 9 && hour < 12) {
                usedFuzzyTime.children[0].label = "الصبوح";
                usedFuzzyTime.children[1].label = "";
            } else if (hour >= 12 && hour < 15) {
                usedFuzzyTime.children[0].label = "الغداء";
                usedFuzzyTime.children[1].label = "";
            } else if (hour >= 15 && hour < 18) {
                usedFuzzyTime.children[0].label = "شاي بعد الغداء";
                usedFuzzyTime.children[1].label = "";
            } else if (hour >= 18 && hour < 21) {
                usedFuzzyTime.children[0].label = "العشاء";
                usedFuzzyTime.children[1].label = "";
            } else if (hour >= 21) {
                usedFuzzyTime.children[0].label = "ليلة سعيدة";
                usedFuzzyTime.children[1].label = "";
            }

            usedTimeNow.label = createFuzzyHour();

        }).catch(print)
    }]]
});

// export default clock = FuzzyClock();

function createFuzzyHour() {
    const now = new Date();
    const hours = now.getHours();
    // const timeOfDay = hours >= 12 ? "مساءً" : "صباحًا";
    let timeOfDay = "";

    if (hours >= 15) {
        timeOfDay = "مساءً";
    } else if (hours >= 12) {
        timeOfDay = "ظهرا";
    } else if (hours >= 6) {
        timeOfDay = "صباحًا";
    } else if (hours >= 4) {
        timeOfDay = "فجرا";
    } else if (hours > 0) {
        timeOfDay = "بعد منتصف الليل";
    }


    const arabicNumbers = [
        "الواحدة",
        "الثانية",
        "الثالثة",
        "الرابعة",
        "الخامسة",
        "السادسة",
        "السابعة",
        "الثامنة",
        "التاسعة",
        "العاشرة",
        "الحادية عشر",
        "الثانية عشر",
    ];

    let timeInArabicWords = "الساعة الآن ";

    if (hours === 0) {
        timeInArabicWords += "الثانية عشر ليلاً";
    } else if (hours === 12) {
        timeInArabicWords += "الثانية عشر ظهرًا";
    } else {
        timeInArabicWords += arabicNumbers[hours % 12 - 1] + " " + timeOfDay;
    }

    return timeInArabicWords;
}
