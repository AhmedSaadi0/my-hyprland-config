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
var TOGGLE_POWER_MENU = 10;

// --- Smart Capsule Priorities (مستويات الأهمية) ---
const IDLE = 0; // الساعة (الوضع الافتراضي)
const HOVER = 1; // عند تمرير الماوس
const TRANSIENT = 2; // تنبيهات سريعة (صوت، سطوع، تغيير أغنية)
const NOTIFICATION = 3;
const WARNING = 4; // تحذيرات (بطارية، طقس)
const CRITICAL = 5; // أخطاء حرجة

// --- Data Sources (مصادر البيانات) ---
const SRC_MUSIC = "music";
const SRC_SYSTEM = "system";
const SRC_BATTERY = "battery";
const SRC_WEATHER = "weather";

// --- Capsule States (حالة النافذة) ---
const STATE_IDLE = "idle";
const STATE_EXPANDED = "expanded";

const FLOATING = "floating";
const DOCKED_FIXED_BAR = "docked_fixed_bar";
const DOCKED_MOVING_BAR = "docked_moving_bar";
