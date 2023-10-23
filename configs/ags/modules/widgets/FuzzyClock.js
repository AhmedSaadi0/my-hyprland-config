import { Widget, Utils } from "../utils/imports.js";

const SATURDAY = 6;
const SUNDAY = 7;
const MONDAY = 1;
const TUESDAY = 2;
const WEDNESDAY = 3;
const THURSDAY = 4;
const FRIDAY = 5;

const fuzzyDay = Widget.Label({
    className:"wd-fuzzy-day",
    xalign: 0,
});

const timeNow = Widget.Label({
    className:"wd-time-now",
    xalign: 0,
})

const fuzzyTime = Widget.Label({
    className:"wd-fuzzy-time",
    xalign: 0,
})

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
                fuzzyDay.label = "اسبوع جديد ";
            } else if (day == SUNDAY) {
                fuzzyDay.label = "استمر ";
            } else if (day == MONDAY) {
                fuzzyDay.label = "واصل طريقك ";
            } else if (day == TUESDAY) {
                fuzzyDay.label = "نصف الاسبوع ⌚";
            } else if (day == WEDNESDAY) {
                fuzzyDay.label = "باقي يومين ";
            } else if (day == THURSDAY) {
                fuzzyDay.label = "ارررحب يالخميس 😉";
            } else if (day == FRIDAY) {
                fuzzyDay.label = "عطلة 😍!";
            }

            if (hour >= 0 && hour < 4) {
                fuzzyTime.label = `النوم\t😴`;
            } else if (hour >= 4 && hour < 9){
                fuzzyTime.label = `صباح الخير\t`;
            } else if (hour >= 9 && hour < 12){
                fuzzyTime.label = `الصبوح\t`;
            } else if (hour >= 12 && hour < 15){
                fuzzyTime.label = `الغداء\t`;
            } else if (hour >= 15 && hour < 18){
                fuzzyTime.label = `شاي بعد الغداء\t`;
            } else if (hour >= 18 && hour < 21){
                fuzzyTime.label = `العشاء\t`;
            } else if (hour >= 21){
                fuzzyTime.label = `ليلة سعيدة\t`;
            }

            if (hour > 12) {
                hour = hour - 12;
            }
            timeNow.label = `الساعة الان ${hour}`;

        }).catch(print)
    }]]
});

// export default clock = FuzzyClock();
