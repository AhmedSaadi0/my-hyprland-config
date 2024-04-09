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

function setFuzzyTimes(hour, usedFuzzyTime) {
  if (hour >= 0 && hour < 3) {
    usedFuzzyTime.children[0].label =
      'ليلة العيد، استعد لاستقبال الضيوف وتبادل التهاني';
    usedFuzzyTime.children[1].label = '󱠧';
  } else if (hour >= 3 && hour < 6) {
    usedFuzzyTime.children[0].label =
      'صباح العيد، استقبل الصباح بالبهجة والفرح';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 6 && hour < 12) {
    usedFuzzyTime.children[0].label =
      'استمتع بأوقات الصباح الجميلة والتواصل مع الأهل والأصدقاء';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 12 && hour < 15) {
    usedFuzzyTime.children[0].label =
      'حان وقت الظهر، استرح وقم بالصلاة واستمتع بأجواء العيد';
    usedFuzzyTime.children[1].label = '󱠧';
  } else if (hour >= 15 && hour < 18) {
    usedFuzzyTime.children[0].label =
      'اجعل بعد الظهر فرصة للترفيه والتسلية مع الأحباب';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 18 && hour < 21) {
    usedFuzzyTime.children[0].label =
      'قم بالخروج والاستمتاع بسهرة العيد مع الأصدقاء';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 21 && hour < 24) {
    usedFuzzyTime.children[0].label =
      'استرخِ في لحظات العيد الهادئة وتأمل اللحظات الجميلة';
    usedFuzzyTime.children[1].label = '';
  }
}

function setFuzzyDays(day, usedFuzzyDay, usedTimeNow) {
  if (day == WEDNESDAY) {
    usedFuzzyDay.children[0].label = 'بداية عيد الفطر المبارك';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'بداية العيد، تهانينا ودعواتنا لكم.';
  } else if (day == THURSDAY) {
    usedFuzzyDay.children[0].label = 'اليوم الثاني من عيد الفطر';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'اليوم الثاني من العيد، استمتعوا بأوقاتكم.';
  } else if (day == FRIDAY) {
    usedFuzzyDay.children[0].label = 'اليوم الثالث من عيد الفطر';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'يوم العيد الثالث، احتفلوا بفرح وسرور.';
  } else if (day == SATURDAY) {
    usedFuzzyDay.children[0].label = 'اليوم الرابع من عيد الفطر';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'الرابع من العيد، تواصلوا مع الأحباب.';
  } else if (day == SUNDAY) {
    usedFuzzyDay.children[0].label = 'اليوم الخامس من عيد الفطر';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'الخامس من العيد، اجعلوا كل لحظة فرح وسرور.';
  } else if (day == MONDAY) {
    usedFuzzyDay.children[0].label = 'اليوم السادس من عيد الفطر';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'السادس من العيد، استمتعوا بالأوقات الجميلة.';
  } else if (day == TUESDAY) {
    usedFuzzyDay.children[0].label = 'اليوم السابع من عيد الفطر';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'السابع من العيد، استمر بالاحتفال والتقرب إلى الله.';
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
        const day = date[0];
        let hour = date[1];

        let usedFuzzyDay = box.children[0];
        let usedTimeNow = box.children[1];
        let usedFuzzyTime = box.children[2];

        setFuzzyDays(day, usedFuzzyDay, usedTimeNow);
        setFuzzyTimes(hour, usedFuzzyTime);

        // usedTimeNow.label = createFuzzyHour();
      })
      .catch(print);
  });

// export default clock = FuzzyClock();

function createFuzzyHour() {
  const now = new Date();
  const hours = now.getHours();
  // const timeOfDay = hours >= 12 ? "مساءً" : "صباحًا";
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
