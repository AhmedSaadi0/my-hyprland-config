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
    usedFuzzyTime.children[0].label = 'لا تنسى ان تصلي تهجد للة في هذا الوقت';
    usedFuzzyTime.children[1].label = '󱠧';
  } else if (hour >= 3 && hour < 5) {
    usedFuzzyTime.children[0].label = 'وقت السحور، بادر بالاستعداد للصيام';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 5 && hour < 12) {
    usedFuzzyTime.children[0].label =
      'صباح الخير! بداية جديدة ليوم رمضاني مبارك';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 12 && hour < 15) {
    usedFuzzyTime.children[0].label =
      'حان وقت الظهر، استرح وادع الله بقلب خاشع';
    usedFuzzyTime.children[1].label = '󱠧';
  } else if (hour >= 15 && hour < 16) {
    usedFuzzyTime.children[0].label = 'استرخِ مع قراءة الأذكار في هذا الوقت';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 16 && hour < 18) {
    usedFuzzyTime.children[0].label = 'استغل هذا الوقت في اناجز بعض من عملك';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 18 && hour < 20) {
    usedFuzzyTime.children[0].label = 'استمتع بالإفطار مع أحبائك وعائلتك';
    usedFuzzyTime.children[1].label = '';
  } else if (hour >= 20 && hour < 22) {
    usedFuzzyTime.children[0].label = 'استعد للتراويح والتسابيح في هذه الليلة';
    usedFuzzyTime.children[1].label = '󱠧';
  } else if (hour >= 22) {
    usedFuzzyTime.children[0].label =
      'عملك في الدنيا يعكس إيمانك وينفعك وينفع وغيرك.';
    usedFuzzyTime.children[1].label = '';
  }
}

function setFuzzyDays(day, usedFuzzyDay, usedTimeNow) {
  if (day == SATURDAY) {
    usedFuzzyDay.children[0].label = 'مرحبًا بك في يوم جديد،';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'أهلاً ببداية يوم السبت، استعد للصيام والعبادة.';
  } else if (day == SUNDAY) {
    usedFuzzyDay.children[0].label = 'أهلاً بالأحد';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'استمر في السعي نحو الخيرات في هذا اليوم.';
  } else if (day == MONDAY) {
    usedFuzzyDay.children[0].label = 'رمضان يزورنا اليوم';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'استمتع بلحظة الصيام وتقرب إلى الله.';
  } else if (day == TUESDAY) {
    usedFuzzyDay.children[0].label = 'نصف الاسبوع قد حل';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'حافظ على الزخم في عباداتك والطاعات.';
  } else if (day == WEDNESDAY) {
    usedFuzzyDay.children[0].label = 'الأجواء الرمضانية معك الآن';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'استمتع بالأجواء وتعمق في قراءة القرآن.';
  } else if (day == THURSDAY) {
    usedFuzzyDay.children[0].label = 'يوم الخميس الطيب';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'استعد لليلة الجمعة وابتهج بالقرب من الله.';
  } else if (day == FRIDAY) {
    usedFuzzyDay.children[0].label = 'يوم الجمعة المبارك';
    usedFuzzyDay.children[1].label = '';
    usedTimeNow.label = 'استمتع بلحظات الجمعة المباركة والصلوات المستجابة.';
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
