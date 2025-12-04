// Menu Values
var DASHBOARD_MENU_INDEX = 0;
var NOTIFICATION_MENU_INDEX = 1;
var WEATHER_MENU_INDEX = 2;
var MONIROTS_MENU_INDEX = 3;
var NETWORK_MENU_INDEX = 4;
var CLIPBOARD_MENU_INDEX = 5;
var TODO_MENU_INDEX = 6;
var TRANSLATE_MENU_INDEX = 7;
var AI_BOT_MENU_INDEX = 8;
var FAVIORTE_APPS_MENU_INDEX = 9;
var APPLICATIONS_MENU_INDEX = 9;

// --- Smart Capsule Priorities (مستويات الأهمية) ---
var IDLE = 0; // الساعة (الوضع الافتراضي)
var HOVER = 1; // عند تمرير الماوس
var TRANSIENT = 2; // تنبيهات سريعة (صوت، سطوع، تغيير أغنية)
var WARNING = 3; // تحذيرات (بطارية، طقس)
var CRITICAL = 4; // أخطاء حرجة

// --- Data Sources (مصادر البيانات) ---
var SRC_MUSIC = "music";
var SRC_SYSTEM = "system";
var SRC_BATTERY = "battery";
var SRC_WEATHER = "weather";

// --- Capsule States (حالة النافذة) ---
var STATE_IDLE = "idle";
var STATE_EXPANDED = "expanded";
