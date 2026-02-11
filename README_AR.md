# توثيق NibrasShell (نسخة شاملة بالعربية)

## نبذة سريعة
NibrasShell هو سطح مكتب مبني على Hyprland و Quickshell، يركّز على واجهة حديثة قابلة للتخصيص، ويجمع بين شريط علوي، شريط جانبي، كبسولة ذكية، ولوحة إعدادات متكاملة، بالإضافة إلى خدمات خلفية للطقس والوسائط والإشعارات والمراقبة.

**حالة المشروع:** قيد التطوير المستمر.

## المعمارية العامة
- المحرك الرئيسي مبني بـ QML عبر Quickshell.
- التكامل مع Hyprland يتم عبر Hyprland API داخل Quickshell.
- الإعدادات تُقرأ وتُحفظ في `~/.nibrasshell.json`.
- البيانات المؤقتة والكاش في `~/.cache/nibrasshell`.
- كاش الثيمات في `~/.cache/nibrasshell/themes`.

## المكونات الواجهة الرئيسية

**الشريط العلوي**
- System Tray عبر `systemtray`.
- مؤشر سرعة الشبكة اللحظي.
- عنوان النافذة النشطة بعرض ديناميكي.
- ودجت مراقبة سريعة: حرارة، بطارية، رام، معالج.
- ودجت مساحات العمل مع أيقونات قابلة للتخصيص وسكرول أفقي.

**الشريط الجانبي**
- مجموعات أيقونات منظمة (نظام، إنتاجية، تطبيقات).
- فتح/إغلاق القائمة الجانبية مع أنماط متعددة: `floating` و `docked_fixed` و `docked_moving`.
- عناصر القائمة: `Dashboard` و `Notifications` و `Weather` و `Monitoring` و `Network` و `Clipboard` و `Todo` و `Translator` و `AI Bot` و `App Launcher` و `Power`.

**نافذة القائمة الجانبية**
- لوحة تحكم الثيمات وتخصيصها.
- التحكم بوضع الطاقة (Power Profiles).
- مركز إشعارات كامل مع DND وزر تنظيف.
- صفحة الطقس مع تفاصيل يومية/ساعية وتحليل ذكي.
- صفحة مراقبة النظام والجداول العليا للعمليات.
- صفحة الشبكات مع اتصال/فصل/نسيان واستهلاك بيانات يومي وشهري.
- مدير الحافظة مع تفعيل/حذف/مسح.
- قائمة مهام مع تواريخ وأولوية وإكمال.
- مشغل تطبيقات مع بحث وتصنيفات وأوامر خاصة.

**الكبسولة الذكية**
- وضع خامل يعرض الطقس أو معلومات ذكية حسب الأولوية.
- وضع موسّع بتبويبَي الطقس والميديا.
- طبقة ذكاء اصطناعي تعرض ملخصات ذكية للطقس أو تعليق موسيقي.
- مؤثرات بصرية ديناميكية أثناء تشغيل الموسيقى.
- عين ذكية تتغير حسب السياق.

**سطح المكتب والخلفيات**
- خلفية ثابتة أو ديناميكية.
- دعم الصور والفيديوهات كخلفية.
- ضبابية الخلفية عند فتح القوائم.
- تأثير عمق للساعة مع طبقة Overlay.
- ودجت ساعة سطح المكتب قابل للحجم والموقع والظل والخط.

**الإشعارات**
- إشعارات نظامية عبر `NotificationServer`.
- Toasts متحركة مع مؤقت وزر إغلاق.
- مركز إشعارات داخل القائمة الجانبية.
- وضع عدم الإزعاج.
- أصوات تنبيه قابلة للتخصيص.

**مشغل التطبيقات**
- مشغل جانبي داخل القائمة اليسرى.
- مشغل سفلي اختياري.
- وضع أوامر `>` لتنفيذ إجراءات مثل فتح الإعدادات أو التنقل بين الخلفيات.

**قائمة الطاقة**
- إيقاف، إعادة تشغيل، تعليق، تسجيل خروج.
- نافذة تأكيد قبل التنفيذ.

**لوحة الاختصارات**
- نافذة اختصارات Hyprland تُستخرج تلقائياً عبر `hyprctl binds -j`.

## الخدمات الخلفية

**SystemService**
- مراقبة CPU/RAM/Temp مع كشف ارتفاعات مفاجئة (Spike Analysis).
- تحليل إقلاع النظام عبر الذكاء الاصطناعي.
- قراءة البطارية وحالة الشحن.
- تتبع تخطيط لوحة المفاتيح.

**خدمة الطقس**
- جلب الطقس من `wttr.in`.
- تحليل ذكي للطقس وإطلاق تنبيهات (مطر، ثلج، صقيع، رياح، رعد…).
- تحديث ذكي لفترات الجلب حسب الحالة.

**خدمة الموسيقى**
- تكامل MPRIS مع مشغلات متعددة.
- تعليق ذكي على الموسيقى.
- سجل تشغيل حديث.

**خدمة الحافظة**
- مراقبة عبر `wl-paste`.
- قائمة/تفعيل/حذف/مسح عبر سكربت Python.

**مدير الإشعارات**
- إدارة الإشعارات الحية والقديمة.
- تشغيل أصوات التنبيه.

**الصوت والسطوع**
- الصوت عبر Pipewire.
- السطوع عبر `brightnessctl` أو `ddcutil` حسب الشاشة.

## الثيمات والخلفيات

**الثيمات الجاهزة**
- Dracula
- Catppuccin
- Material (Material You)
- Nord
- Gruvbox
- Tokyo Night

**ثيمات مفردة**
- Colors
- Deer

**نظام الخلفيات**
- خلفية ثابتة أو ديناميكية من مجلد.
- بحث وتنزيل خلفيات من Wallhaven.
- التبديل اليدوي بين الخلفيات.
- توليد ألوان النظام تلقائياً من الخلفية.

## إعدادات المستخدم `~/.nibrasshell.json`

**بيانات المستخدم والموقع**
- `username` اسم المستخدم.
- `subtitle` وصف مختصر.
- `profilePicture` مسار الصورة.
- `city` و `country` و `weatherLocation`.
- `firstDayOfWeek` أول يوم في الأسبوع.
- `usePrayerTimes` تفعيل مواقيت الصلاة (الإعداد موجود والتنفيذ الكامل ضمن خطة التطوير).

**الشبكة**
- `networkMonitor` واجهة الشبكة.
- `networkInterval` زمن التحديث.

**الذكاء الاصطناعي**
- `aiProvider` مزود الذكاء الاصطناعي.
- `aiApiKey` المفتاح العام.
- `weatherAiApiKey` و `musicAiApiKey` و `systemAiApiKey`.
- `weatherAiModel` و `musicAiModel` و `systemAiModel`.
- `aiPreferredLanguage` لغة الرد.
- `weatherPersona` و `musicPersona`.

**تنبيهات الموارد**
- `enableHighCpuAlert` و `enableHighRamAlert`.
- `cpuHighLoadThreshold` و `ramHighLoadThreshold`.
- `playCpuAlarmSound` و `playRamAlarmSound`.

**تخطيط الواجهة**
- `menuStyle` نمط القائمة الجانبية.
- `useBottomLauncher` تفعيل المشغل السفلي.
- `bottomLauncherWidth` العرض.
- `topBarActiveWindowMinWidth` و `topBarActiveWindowMaxWidth`.
- `dynamicWorkspaces`.
- `activeWorkspacesIcons` و `inActiveWorkspacesIcons`.

## لوحة الإعدادات داخل النظام

**صفحات عامة**
- معلومات المستخدم والمدينة والدولة ومكان الطقس وصورة الحساب.
- تغيير أول يوم في الأسبوع.
- تفعيل مواقيت الصلاة.
- إعدادات الشبكة والواجهة الأساسية.
- إعدادات الذكاء الاصطناعي والمفاتيح والنماذج والشخصيات.
- إعدادات تنبيهات CPU/RAM والعتبات.

**صفحات المظهر**
- الخلفيات (ثابتة/ديناميكية، زمن التبديل، الضبابية).
- تفعيل Material You وتعديل متغيراته.
- تخصيص الألوان الأساسية والمتقدمة.
- الخطوط والأحجام والمسافات والزوايا وأبعاد البارات.
- إعدادات ساعة سطح المكتب (الخط، اللون، التنسيق، العمق، الظل).
- إعدادات Hyprland (الحواف، الفجوات، التظليل، البلور، الأنيميشن).
- تكامل النظام (GTK، Kvantum، Qt، Konsole، Plasma).

**الأجهزة**
- إدارة أجهزة الصوت (إخراج/إدخال) عبر Pipewire.

## سكربتات وأدوات مدمجة

**سكربتات Python**
- المراقبة: `battery_info.py` و `devices_temp.py` و `top_cpu_usage.py` و `top_ram_usage.py`.
- الخلفيات: `scan_wallpapers.py` و `m3/dynamic-m3.py`.
- التأثير العميق: `create_depth_image_rembg.py` و `create_depth_image_opencv.py` و `overlay_cache_images_cleaner.py`.
- الشبكات: `network/list_wifi.py` و `network/connect_wifi.py` و `network/data_usage.py` و `network/live_usage.py`.
- الذكاء الاصطناعي: `ai/main.py` و `ai/list-gemini.py`.
- الحافظة: `get_clipboard.py`.

**سكربتات Bash**
- `cpu_usage.sh` و `ram_usage.sh` و `internet.sh` و `temp.sh`.
- `playerctl.sh`.

## الاختصارات المضمنة (أسماء داخلية)
- فتح الإعدادات: `openSettings`.
- فتح كتيب الاختصارات: `openCheatsheet`.
- التحكم بالموسيقى: `nextSong` و `previousSong` و `togglePlaying` و `stopPlay` و `switchPlayer`.
- السطوع: `brightnessUp` و `brightnessDown`.
- الكبسولة الذكية: `toggleMediaIsland` و `toggleWeatherIsland`.
- المشغل السفلي: `toggleBottomLauncher`.

**ملاحظة:** الاختصارات الفعلية تُستخرج من Hyprland عبر نافذة الـ Cheatsheet.

## المتطلبات

**حزم أساسية**
- Hyprland
- Quickshell
- network-manager-applet
- playerctl
- polkit-kde-agent أو polkit-gnome
- FantasqueSansM Nerd Font
- dolphin
- konsole
- brightnessctl
- gammastep
- wl-clipboard
- hyprpicker
- sysstat
- bc
- sassc
- swww
- systemsettings
- acpi
- fish
- gnome-bluetooth-3.0
- power-profiles-daemon
- lm_sensors
- copyq
- kde-material-you-colors
- vnstat
- nethogs

**حزم اختيارية**
- strawberry
- easyeffects
- blueman
- telegram-desktop
- discord
- kvantum
- firefox

## التثبيت

**تثبيت تلقائي**
```bash
git clone --depth 1 https://github.com/AhmedSaadi0/NibrasShell.git
cd NibrasShell
python install.py
```

**مزايا سكربت التثبيت**
- تثبيت المتطلبات.
- إعداد الملفات.
- إنشاء ملف الإعدادات `~/.nibrasshell.json`.
- تحديث Quickshell.
- إزالة الواجهة عند الحاجة.

**التوزيعات المدعومة في السكربت**
- Arch
- Fedora
- Void

## مسارات مهمة
- إعدادات Hyprland: `hyprland.conf` وملفات `binding.conf` و `env.conf` و `exec-once.conf` و `rules.conf` و `monitors.conf`.
- ملفات Quickshell: `config/quickshell`.
- الثيمات والموارد: `config/quickshell/assets`.
- سكربتات Quickshell: `config/quickshell/scripts`.
- الكاش: `~/.cache/nibrasshell`.

## ملاحظات إضافية
- واجهة المستخدم مضبوطة افتراضياً على العربية داخل الكود.
- صفحات أو عناصر ما زالت قيد الإكمال مثل `AI Bot` و `Translator` ضمن القائمة الجانبية.
- إعدادات الشاشات في الإعدادات نموذجية حالياً.

## خارطة الطريق (من todo.md)

**الكبسولة الذكية والذكاء الاصطناعي**
- تخصيص ألوان الكبسولة الذكية.
- ربط Fuzzy Clock بالذكاء الاصطناعي.
- ردود ذكية عند ارتفاع الضغط على CPU/RAM.
- تلخيص النصوص المنسوخة بالذكاء الاصطناعي.

**الواجهة والثيمات**
- وضع Game Mode للأداء.
- تخصيص ظل البار وعرض القائمة اليسرى.
- تأثيرات عمق متقدمة مع دعم لكل خلفية.
- ثيمات جديدة مثل Solarized و Rosé Pine و Oxocarbon.
- إيقاف تدوير الخلفيات الديناميكية.

**الودجت والإنتاجية**
- ملاحظات سريعة.
- التطبيقات المفضلة.
- قائمة مساعدين الذكاء الاصطناعي.
- خيار منطق فتح القائمة (محجوز/عائم).

**النظام والأجهزة**
- مدير بلوتوث كامل.
- إعدادات العرض (الدقة والشاشة).
- مؤشر VPN.
- مفاتيح سريعة (Wi‑Fi و Airplane و Gammastep).
- مؤشر لغة لوحة المفاتيح.

**تنظيف الكود**
- استبدال `LeftMenuStatus` بـ `EventBus`.
- تنظيم المكونات في مساراتها الصحيحة.
