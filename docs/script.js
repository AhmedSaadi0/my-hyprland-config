const themeSelect = document.getElementById("themeSelect");
const langSelect = document.getElementById("langSelect");
const navToggle = document.getElementById("navToggle");
const navRoot = document.getElementById("navRoot");
const heroImage = document.getElementById("heroImage");

const translations = {
  ar: {
    page_title: "نِبراس شِل - واجهة مدمجة بالذكاء الاصطناعي",
    brand_name: "نِبراس شِل",
    brand_tagline: "واجهة مدمجة بالذكاء الاصطناعي",
    nav_home: "الرئيسية",
    nav_features: "المميزات",
    nav_gallery: "الصور",
    nav_install: "التثبيت",
    nav_docs: "الوثائق",
    nav_dev: "المطورون",
    nav_changelog: "التغييرات",
    nav_roadmap: "خارطة الطريق",
    nav_faq: "الأسئلة",
    nav_menu: "فتح القائمة",

    hero_badge: "واجهة مدمجة بالذكاء الاصطناعي",
    hero_title: "تجربة سطح مكتب حديثة، ذكية، ومتكاملة",
    hero_desc:
      "واجهة تركّز على أفضل ما في التجربة: شريط علوي ذكي، كبسولة تفاعلية، وثيمات مصممة بعناية.",
    hero_chip_1: "الكبسولة الذكية",
    hero_chip_2: "الثيمات الديناميكية",
    hero_chip_3: "مراقبة النظام",
    cta_features: "استعرض المميزات",
    cta_install: "ابدأ التثبيت",
    cta_docs: "اقرأ الوثائق",
    cta_github: "المستودع",
    stat_themes: "ثيمات جاهزة",
    stat_modules: "وحدات رئيسية",
    stat_live: "مراقبة حيّة",
    ticker_1: "واجهة متجددة باستمرار",
    ticker_2: "ذكاء مدمج في تفاصيل التجربة",
    ticker_3: "تخصيص عميق بضغطة واحدة",
    signal_1: "واجهة متجددة باستمرار",
    signal_2: "ذكاء مدمج في تفاصيل التجربة",
    signal_3: "تخصيص عميق بضغطة واحدة",
    ai_providers_note:
      "يدعم عدة مزودين للذكاء الاصطناعي، بما فيها مزود محلي عبر:",
    smart_preview_label: "معاينة الكبسولة الذكية",

    why_title: "لماذا نبراس شِل؟",
    why_1_title: "واجهة ذكية",
    why_1_desc:
      "كبسولة ذكية تتفاعل مع المستخدم عبر الهوفر، وتعرض رسائل الذكاء الاصطناعي مع ملخصات الطقس والموسيقى.",
    why_2_title: "تخصيص عميق",
    why_2_desc: "تحكم شامل بالألوان والخطوط والخلفيات وأسلوب القوائم.",
    why_3_title: "خدمات متكاملة",
    why_3_desc: "مراقبة النظام، إشعارات ذكية، شبكة، حافظة، ومركز إعدادات كامل.",
    tools_title: "أدوات تحكم وإنتاجية متكاملة",
    tools_sub: "كل ما تحتاجه للتحكم في نظامك موجود بداخل الواجهة.",
    tool_settings_title: "تطبيق إعدادات مدمج وشامل",
    tool_settings_desc:
      "لا حاجة لتعديل ملفات التكوين يدوياً. تطبيق الإعدادات المدمج يمنحك السيطرة الكاملة على الألوان، الثيمات، الخلفيات، وحتى اختيار نماذج الذكاء الاصطناعي المفضلة لديك.",
    tool_settings_li1: "تعديل الثيمات والألوان لحظياً.",
    tool_settings_li2: "إدارة نماذج AI وتخصيصها.",

    tool_launcher_title: "مشغل تطبيقات ذكي ومتصل",
    tool_launcher_desc:
      "أكثر من مجرد قائمة تطبيقات. يوفر لك وضع الأوامر المتطور وخاصية جلب الخلفيات مباشرة.",
    tool_launcher_li1: "استخدم الرمز > للوصول لأوامر النظام السريعة.",
    tool_launcher_li2: "تكامل مع Wallhaven لجلب وتغيير الخلفيات مباشرة.",

    shots_title: "لقطات من الواجهة",
    shots_desc: "صور قليلة تبيّن الجو العام للواجهة والثيمات.",
    quick_value_title: "ما الذي يميز الواجهة بسرعة؟",
    quick_value_desc: "نظرة مختصرة على أهم نقاط القوة العملية للمستخدم اليومي.",
    quick_value_1_title: "أداء متوازن",
    quick_value_1_desc:
      "واجهة خفيفة نسبيًا مع تنظيم واضح للعناصر المهمة بدون فوضى.",
    quick_value_2_title: "وصول أسرع",
    quick_value_2_desc:
      "الإعدادات، التطبيقات، والإشعارات في أماكن ثابتة وسهلة الوصول.",
    quick_value_3_title: "ذكاء مفيد",
    quick_value_3_desc:
      "تحليلات وتلميحات ذكية تركز على المعلومات التي تهمك فعلاً.",

    components_title: "لمحة عن المكونات",
    components_1: "الشريط العلوي مع مؤشرات النظام ومساحات العمل.",
    components_2: "الشريط الجانبي مع لوحة تنقل ذكية.",
    components_3: "كبسولة ذكية ثنائية الوضع (خامل وموسع).",
    components_4: "سطح مكتب بخلفيات ديناميكية وتأثير عمق للساعة.",
    components_5: "لوحة إعدادات شاملة لكل التفاصيل.",
    ai_now_title: "الذكاء الاصطناعي حالياً",
    ai_now_1: "تحليل بيانات الطقس.",
    ai_now_2: "تحليل الموسيقى.",
    ai_now_3: "تحليل حالة النظام بعد الإقلاع مباشرة.",
    ai_now_4: "تلخيص ما حدث عند ارتفاع مفاجئ في CPU/RAM/الحرارة داخل سجل.",
    ai_future_title: "وحدات مرتبطة بالذكاء الاصطناعي (قريباً)",
    ai_future_1: "الحافظة: ربطها بالذكاء الاصطناعي لجلب ملخصات لاحقاً.",
    ai_future_2: "قائمة المهام: ملخصات وتنبيهات بحسب التاريخ.",
    ai_future_3: "مراقب الشبكة: ملخص الاستهلاك بحسب التطبيق.",

    quick_gallery_title: "معرض سريع",
    quick_gallery_btn: "عرض كل الصور",

    quick_start_title: "ابدأ بسرعة",

    compat_title: "التوافق",
    compat_supported: "توزيعات مدعومة في السكربت",
    compat_distros: "Arch و Fedora و Void",
    compat_note_title: "تنويه",
    compat_note: "يمكن التثبيت اليدوي على أي توزيعة أخرى.",
    footer_pages: "هذا الموقع يُعرض عبر GitHub Pages.",

    features_title: "المميزات",
    features_sub: "نظرة تفصيلية لأهم ما يميز الواجهة.",
    feat_capsule_title: "الكبسولة الذكية",
    feat_capsule_desc: "عرض موجز للطقس والميديا مع توسعة تفاعلية وطبقة AI.",
    feat_menu_title: "القائمة الجانبية",
    feat_menu_desc: "تنقّل سريع بين الأقسام مع نمط عائم أو ثابت.",
    feat_monitor_title: "مراقبة النظام",
    feat_monitor_desc:
      "CPU و RAM و الحرارة والبطارية مع تحليل ارتفاعات مفاجئة.",
    feat_weather_title: "الطقس الذكي",
    feat_weather_desc: "تحليل ذكي وتنبيهات جوية مع تحديثات مرنة حسب الحالة.",
    feat_themes_title: "الثيمات والخلفيات",
    feat_themes_desc:
      "ثيمات جاهزة مع دعم خلفيات ديناميكية وتوليد ألوان تلقائي.",
    feat_settings_title: "لوحة إعدادات احترافية",
    feat_settings_desc: "تحكم كامل بالواجهة والموارد والذكاء الاصطناعي.",
    feat_list_title: "قائمة مختصرة بالمزايا",
    feat_list_1: "شريط علوي غني بعناصر النظام ومساحات العمل.",
    feat_list_2: "مشغل تطبيقات جانبي وسفلي.",
    feat_list_3: "إشعارات فورية ومركز إشعارات.",
    feat_list_4: "تأثير عمق للساعة مع Overlay.",
    feat_list_5: "تكامل مع Pipewire و MPRIS و wl-clipboard.",
    feat_footer: "للتفاصيل التقنية الكاملة، انتقل إلى الوثائق.",

    install_title: "التثبيت",
    install_sub: "خطوات التثبيت السريعة والملاحظات الأساسية.",
    install_auto_title: "الطريقة التلقائية (موصى بها)",
    install_auto_desc:
      'قم باستنساخ المستودع، ثم قم بتشغيل السكربت التالي الذي سيهتم بكل شيء، بما في ذلك إنشاء ملف الإعدادات <span dir="ltr">.nibrasshell.json</span>:',

    install_manual_toggle: "التثبيت اليدوي (اضغط للفتح)",
    install_manual_deps: "برامج ضرورية",
    install_manual_optional: "برامج اختيارية",

    install_arch_title: "تثبيت البرامج لمستخدمي Arch:",
    install_fedora_title: "مستخدمي Fedora",
    install_other_distros:
      "<strong>ملاحظة:</strong> إذا كنت تستخدم نظام تشغيل آخر غير أرش او فيدورا فسوف تحتاج إلى تثبيت جميع البرامج الضرورية. قد تختلف الخطوات بناءً على نوع توزيعتك.",

    install_depth_effect: "متطلبات تأثير العمق للساعة في سطح المكتب",
    install_depth_desc:
      "نحتاج مكتبه rembg و pillow لانشاء الصور ذات تاثير العمق",

    install_script_step: "الآن يمكنك استخدام سكربت التثبيت واختيار رقم 2",
    install_manual_files:
      "في حال لم يعمل السكربت الآن اكمل مع التثبيت اليدوي لتهيئة الملفات:",
    install_final_note:
      "بإمكانك تغيير خط الجهاز إلى 'JF Flat' وتخصيص الواجهة من خلال الإعدادات المتقدمة (win+s).",

    // الابقاء على الاكواد البرمجية للترجمة اذا لزم الامر
    install_manual_config_title: "إعداد ملف الإعدادات",
    install_supported: "التوزيعات المدعومة في السكربت",
    install_notes: "ملاحظات مهمة",
    install_note_1: "قد تختلف أسماء الحزم حسب التوزيعة.",
    install_note_2: "يفضّل إعادة تشغيل النظام بعد التثبيت.",
    install_note_3: "يمكنك التثبيت اليدوي على أي توزيعة أخرى.",
    install_script_step_2: `
python install.py
Choose your language / اختر لغتك / Vyberte jazyk:
1. English
2. العربية
3. Česky
> 2

=============================================
سكربت تثبيت NibrasShell
=============================================
1. تثبيت المتطلبات
2. تثبيت الواجهة
3. تحديث QuickShell
4. حذف الواجهة
5. إنشاء/تعديل ملف الإعدادات
6. خروج
اختر أحد الخيارات: 2
`,

    docs_title: "الوثائق",
    docs_sub: "كل شيء في مكان واحد: التثبيت الكامل وتوثيق التطوير.",
    docs_sidebar_title: "دليل الوثائق",
    docs_sidebar_overview: "نظرة عامة",
    docs_sidebar_install: "التثبيت الكامل",
    docs_sidebar_dev: "توثيق التطوير",
    docs_overview_title: "الوثائق",
    docs_overview_desc:
      "اختر القسم المناسب من الشريط الجانبي للوصول إلى شرح التثبيت أو توثيق التطوير.",
    docs_overview_install_title: "التثبيت الكامل",
    docs_overview_install_desc:
      "خطوات تلقائية ويدوية مفصلة مع أمثلة للتوزيعات.",
    docs_overview_install_btn: "افتح التثبيت",
    docs_overview_dev_title: "توثيق التطوير",
    docs_overview_dev_desc: "المعمارية، السكربتات، والخدمات الأساسية.",
    docs_overview_dev_btn: "افتح التوثيق",
    docs_ui_title: "الواجهة",
    docs_ui_1: "الشريط العلوي",
    docs_ui_2: "القائمة الجانبية",
    docs_ui_3: "الكبسولة الذكية",
    docs_ui_4: "سطح المكتب والخلفيات",
    docs_services_title: "الخدمات",
    docs_services_1: "SystemService",
    docs_services_2: "Weather",
    docs_services_3: "MusicService",
    docs_services_4: "ClipboardService",
    docs_settings_title: "الإعدادات",
    docs_settings_1: "ملف الإعدادات `~/.nibrasshell.json`",
    docs_settings_2: "لوحة الإعدادات الداخلية",
    docs_settings_3: "الثيمات والألوان",
    docs_dev_title: "المطورون",
    docs_dev_1: "سكربتات Python و Bash",
    docs_dev_2: "نظام الخلفيات",
    docs_dev_3: "تأثيرات العمق والبلور",
    docs_dev_cta_title: "توثيق المطورين",
    docs_dev_cta_desc:
      "انتقل إلى صفحة المطورين لمعرفة المعمارية والخدمات والسكربتات بالتفصيل.",
    docs_dev_cta_btn: "وثائق المطورين",
    docs_footer: "هذه الصفحة مختصرة، بينما التفاصيل الكاملة في الوثائق.",

    roadmap_title: "خارطة الطريق",
    roadmap_sub: "ملخص للأفكار والمهام القادمة.",
    roadmap_ai_title: "الكبسولة الذكية والذكاء الاصطناعي",
    roadmap_ai_1: "تخصيص ألوان الكبسولة الذكية.",
    roadmap_ai_2: "ربط Fuzzy Clock بالذكاء الاصطناعي.",
    roadmap_ai_3: "ردود ذكية عند ارتفاع CPU و RAM.",
    roadmap_ai_4: "تلخيص النص المنسوخ بالذكاء الاصطناعي.",
    roadmap_ui_title: "الواجهة والثيمات",
    roadmap_ui_1: "وضع Game Mode للأداء.",
    roadmap_ui_2: "تخصيص ظل البار وعرض القائمة اليسرى.",
    roadmap_ui_3: "تأثيرات عمق متقدمة لكل خلفية.",
    roadmap_ui_4: "ثيمات جديدة مثل Solarized و Rosé Pine و Oxocarbon.",
    roadmap_ui_5: "إيقاف تدوير الخلفيات الديناميكية.",
    roadmap_prod_title: "الودجت والإنتاجية",
    roadmap_prod_1: "ملاحظات سريعة.",
    roadmap_prod_2: "التطبيقات المفضلة.",
    roadmap_prod_3: "قائمة مساعدين الذكاء الاصطناعي.",
    roadmap_sys_title: "النظام والأجهزة",
    roadmap_sys_1: "مدير بلوتوث كامل.",
    roadmap_sys_2: "إعدادات العرض.",
    roadmap_sys_3: "مؤشر VPN.",
    roadmap_sys_4: "مفاتيح سريعة للشبكة ووضع الطيران و Gammastep.",
    roadmap_sys_5: "مؤشر لغة لوحة المفاتيح.",
    roadmap_footer: "هذه الخارطة تتطابق مع `todo.md` وتحدّث باستمرار.",

    faq_title: "الأسئلة الشائعة",
    faq_sub: "إجابات سريعة عن أكثر الأسئلة تكراراً.",
    faq_q1: "هل المشروع جاهز بالكامل؟",
    faq_a1: "المشروع قيد التطوير مع ميزات جاهزة وميزات قادمة.",
    faq_q2: "هل يدعم خلفيات الفيديو؟",
    faq_a2: "نعم، يدعم الخلفيات بصيغ فيديو عبر `Wallpaper.qml`.",
    faq_q3: "هل يمكن التثبيت على توزيعات أخرى؟",
    faq_a3: "نعم عبر التثبيت اليدوي، والسكربت يدعم Arch و Fedora و Void.",
    faq_q4: "أين أجد الاختصارات؟",
    faq_a4: "داخل نافذة الـ Cheatsheet أو من Hyprland مباشرة.",
    faq_footer: "للاستفسارات التقنية، راجع الوثائق.",

    gallery_title: "معرض الصور",
    gallery_sub: "لقطات حالية للواجهة، وسيتم تحديثها لاحقاً.",
    gallery_footer: "سيتم تحديث لقطات الشاشة لاحقاً عندما تتوفر لقطات أجمل.",
    cap_smart: "الكبسولة الذكية",
    cap_settings: "لوحة الإعدادات",
    cap_m3_dark: "Material You – داكن",
    cap_m3_light: "Material You – فاتح",
    cap_dracula_light: "Dracula – فاتح",
    cap_capp_dark: "Catppuccin – داكن",
    cap_capp_light: "Catppuccin – فاتح",
    cap_nord_dark: "Nord – داكن",
    cap_nord_light: "Nord – فاتح",
    cap_gruv_dark: "Gruvbox – داكن",
    cap_gruv_light: "Gruvbox – فاتح",
    cap_gruv_mix: "Gruvbox – متنوع",
    cap_colors: "Colors Theme",
    cap_tokyo: "Tokyo Night",
    cap_tokyo_light: "Tokyo Night – فاتح",
    cap_deer: "Deer Theme",

    dev_title: "وثائق المطورين",
    dev_sub: "خريطة تقنية مختصرة لفهم بنية المشروع وكيفية توسعته.",
    dev_arch: "المعمارية العامة",
    dev_arch_1: "واجهة QML عبر Quickshell.",
    dev_arch_2: "Hyprland للتعامل مع النوافذ والشاشات والأحداث.",
    dev_arch_3: "خدمات خلفية في `config/quickshell/services`.",
    dev_arch_4:
      "سكربتات Python/Bash في `config/quickshell/scripts` و `scripts`.",
    dev_entry: "نقطة البداية",
    dev_entry_hint: "المكوّن الرئيسي في:",
    dev_entry_desc:
      "هذا الملف يجمع الطبقات الأساسية مثل الشريط العلوي والقائمة الجانبية والكبسولة الذكية.",
    dev_settings: "إدارة الإعدادات",
    dev_settings_1:
      "قراءة الإعدادات من `~/.nibrasshell.json` عبر `ConfigStore.qml`.",
    dev_settings_2: "الواجهة تستخدم `App.qml` لتوحيد المسارات والأوامر.",
    dev_settings_3: "الكاش في `~/.cache/nibrasshell`.",
    dev_themes: "إدارة الثيمات والخلفيات",
    dev_themes_1: "`ThemeManager.qml` مسؤول عن تحميل الثيمات وتطبيقها.",
    dev_themes_2:
      "`WallpaperController.qml` لإدارة الخلفيات الثابتة والديناميكية.",
    dev_themes_3: "`DepthEffectController.qml` لتوليد طبقات العمق.",
    dev_services: "الخدمات الأساسية",
    dev_services_th1: "الخدمة",
    dev_services_th2: "الدور",
    dev_services_row1: "مراقبة الموارد وتحليل الإقلاع وارتفاعات الأداء",
    dev_services_row2: "جلب الطقس والتحليل الذكي والتنبيهات",
    dev_services_row3: "تكامل MPRIS والتعليق الذكي",
    dev_services_row4: "إدارة الإشعارات ووضع عدم الإزعاج",
    dev_services_row5: "مراقبة الحافظة وإدارتها",
    dev_scripts: "السكربتات المهمة",
    dev_python: "Python",
    dev_bash: "Bash",
    dev_run: "تشغيل Quickshell",
    dev_run_desc: "هذا السكربت يضبط log rules لتقليل الضوضاء أثناء التشغيل.",
    dev_notes: "ملاحظات تطوير",
    dev_note_1: "الكبسولة الذكية في `config/quickshell/windows/smart_capsule`.",
    dev_note_2: "القائمة الجانبية في `config/quickshell/windows/leftwindow`.",
    dev_note_3: "الإعدادات في `config/quickshell/windows/settings`.",
    dev_footer: "هذه الصفحة ملخصة ويمكن توسيعها لاحقاً بمخططات ورسوم.",

    change_title: "سجل التغييرات",
    change_sub: "قالب جاهز لإضافة الإصدارات لاحقاً.",
    change_soon: "قادم",
    change_note_1: "ضع ملخص التغييرات هنا.",
    change_note_2: "يمكنك إضافة مميزات أو إصلاحات أو تحسينات.",
    change_note_3: "قالب إصدار إضافي.",
    change_footer: "سيتم تحديث سجل التغييرات عند كل إصدار.",
  },
  en: {
    page_title: "NibrasShell - AI integrated shell",
    brand_name: "NibrasShell",
    brand_tagline: "AI integrated shell",
    nav_home: "Home",
    nav_features: "Features",
    nav_gallery: "Gallery",
    nav_install: "Install",
    nav_docs: "Docs",
    nav_dev: "Developers",
    nav_changelog: "Changelog",
    nav_roadmap: "Roadmap",
    nav_faq: "FAQ",
    nav_menu: "Open menu",

    hero_badge: "AI integrated shell",
    hero_title: "A modern, smart, and complete desktop experience",
    hero_desc:
      "A focused UI that highlights the best: a smart top bar, an interactive capsule, and carefully crafted themes.",
    hero_chip_1: "Smart Capsule",
    hero_chip_2: "Dynamic Themes",
    hero_chip_3: "System Monitoring",
    cta_features: "Explore Features",
    cta_install: "Start Install",
    cta_docs: "Read Docs",
    cta_github: "Repository",
    stat_themes: "Ready themes",
    stat_modules: "Core modules",
    stat_live: "Live monitoring",
    ticker_1: "Continuously evolving interface",
    ticker_2: "Intelligence built into the experience",
    ticker_3: "Deep customization in one click",
    signal_1: "Continuously evolving interface",
    signal_2: "Intelligence built into the experience",
    signal_3: "Deep customization in one click",
    ai_providers_note:
      "Supports multiple AI providers, including a local provider via:",
    smart_preview_label: "Smart capsule preview",

    tools_title: "Integrated Control & Productivity",
    tools_sub: "Everything you need to control your system is built right in.",
    tool_settings_title: "Comprehensive Built-in Settings",
    tool_settings_desc:
      "No need to edit config files manually. The built-in settings app gives you full control over colors, themes, wallpapers, and even your preferred AI models.",
    tool_settings_li1: "Modify themes and colors instantly.",
    tool_settings_li2: "Manage and customize AI models.",

    tool_launcher_title: "Smart Connected Launcher",
    tool_launcher_desc:
      "More than just an app list. It offers an advanced command mode and direct wallpaper fetching.",
    tool_launcher_li1: "Use the > symbol for quick system commands.",
    tool_launcher_li2: "Wallhaven integration to fetch wallpapers directly.",
    why_title: "Why NibrasShell?",
    why_1_title: "Smart UI",
    why_1_desc:
      "A smart capsule that reacts to user hover and shows AI messages with weather and music summaries.",
    why_2_title: "Deep Customization",
    why_2_desc:
      "Full control over colors, fonts, wallpapers, and menu behavior.",
    why_3_title: "Integrated Services",
    why_3_desc:
      "System monitoring, smart notifications, network, clipboard, and a full settings hub.",

    shots_title: "UI Highlights",
    shots_desc: "A few shots that capture the look and feel of the themes.",
    quick_value_title: "Why this interface works",
    quick_value_desc:
      "A compact view of the most practical strengths for daily use.",
    quick_value_1_title: "Balanced performance",
    quick_value_1_desc:
      "Relatively lightweight UI with clear structure and less visual noise.",
    quick_value_2_title: "Faster access",
    quick_value_2_desc:
      "Settings, apps, and notifications stay in predictable, easy-to-reach places.",
    quick_value_3_title: "Useful intelligence",
    quick_value_3_desc:
      "Smart summaries and hints focused on the information that actually matters.",

    components_title: "Components at a glance",
    components_1: "Top bar with system indicators and workspaces.",
    components_2: "Side bar with smart navigation.",
    components_3: "Two-mode smart capsule (idle and expanded).",
    components_4: "Desktop with dynamic wallpapers and depth clock effect.",
    components_5: "Complete settings panel for everything.",
    ai_now_title: "AI (Current)",
    ai_now_1: "Weather data analysis.",
    ai_now_2: "Music analysis.",
    ai_now_3: "Boot-up system status analysis.",
    ai_now_4: "Spike summaries for CPU/RAM/temperature in logs.",
    ai_future_title: "AI-connected modules (Coming soon)",
    ai_future_1: "Clipboard: AI summaries for copied text.",
    ai_future_2: "Todo list: summaries and date-based alerts.",
    ai_future_3: "Network monitor: per-app usage summaries.",

    quick_gallery_title: "Quick Gallery",
    quick_gallery_btn: "View All Screenshots",

    quick_start_title: "Quick Start",

    compat_title: "Compatibility",
    compat_supported: "Distro support in script",
    compat_distros: "Arch, Fedora, Void",
    compat_note_title: "Note",
    compat_note: "Manual installation works on other distros.",
    footer_pages: "This site is hosted on GitHub Pages.",

    features_title: "Features",
    features_sub: "A detailed look at what makes the UI special.",
    feat_capsule_title: "Smart Capsule",
    feat_capsule_desc:
      "Weather and media summary with interactive expansion and AI overlay.",
    feat_menu_title: "Side Menu",
    feat_menu_desc: "Fast navigation with floating or docked modes.",
    feat_monitor_title: "System Monitoring",
    feat_monitor_desc: "CPU, RAM, temps, battery with spike analysis.",
    feat_weather_title: "Smart Weather",
    feat_weather_desc: "AI-driven insights and severe weather alerts.",
    feat_themes_title: "Themes & Wallpapers",
    feat_themes_desc:
      "Ready themes, dynamic wallpapers, and auto color generation.",
    feat_settings_title: "Pro Settings Panel",
    feat_settings_desc: "Full control over UI, resources, and AI.",
    feat_list_title: "Feature Highlights",
    feat_list_1: "Rich top bar with system info and workspaces.",
    feat_list_2: "Side and bottom app launcher.",
    feat_list_3: "Live notifications and notification center.",
    feat_list_4: "Depth effect for the desktop clock.",
    feat_list_5: "Integration with Pipewire, MPRIS, and wl-clipboard.",
    feat_footer: "For the full technical breakdown, see the docs.",

    install_title: "Installation",
    install_sub: "Quick installation steps and essential notes.",
    install_auto_title: "Automatic Method (Recommended)",
    install_auto_desc:
      'Clone the repository, then run the following script which handles everything, including creating the <span dir="ltr">.nibrasshell.json</span> config file:',

    install_manual_toggle: "Manual Installation (Click to expand)",
    install_manual_deps: "Essential Software",
    install_manual_optional: "Optional Software",

    install_arch_title: "Software installation for Arch users:",
    install_fedora_title: "Fedora users",
    install_other_distros:
      "<strong>Note:</strong> If you are using an OS other than Arch or Fedora, you will need to install all necessary software manually. Steps may vary by distro.",

    install_depth_effect: "Desktop Clock Depth Effect Requirements",
    install_depth_desc:
      "We need 'rembg' and 'pillow' libraries to generate depth effect images.",

    install_script_step:
      "Now you can use the installation script and choose option 2",
    install_manual_files:
      "If the script doesn't work, proceed with manual file setup:",
    install_final_note:
      "You can change the system font to 'JF Flat' and customize the UI through Advanced Settings (win+s).",

    install_manual_config_title: "Config File Setup",
    install_supported: "Supported Distros in Script",
    install_notes: "Important Notes",
    install_note_1: "Package names may vary by distro.",
    install_note_2: "System reboot is recommended after installation.",
    install_note_3: "Manual installation is possible on any other distro.",
    install_script_step_2: `
$ python3 install.py
Choose your language / اختر لغتك / Vyberte jazyk:
1. English
2. العربية
3. Česky
> 1

=============================================
NibrasShell Installation Script
=============================================
1. Install Dependencies
2. Install NibrasShell
3. Update QuickShell
4. Uninstall NibrasShell
5. Create/Edit User Config
6. Exit
Choose an option: 2
`,

    docs_title: "Docs",
    docs_sub: "Everything in one place: full install and developer docs.",
    docs_sidebar_title: "Docs Guide",
    docs_sidebar_overview: "Overview",
    docs_sidebar_install: "Full Install",
    docs_sidebar_dev: "Developer Docs",
    docs_overview_title: "Documentation",
    docs_overview_desc:
      "Pick a section from the sidebar to reach install steps or developer docs.",
    docs_overview_install_title: "Full Install",
    docs_overview_install_desc:
      "Automatic and manual steps with distro examples.",
    docs_overview_install_btn: "Open Install",
    docs_overview_dev_title: "Developer Docs",
    docs_overview_dev_desc: "Architecture, scripts, and core services.",
    docs_overview_dev_btn: "Open Docs",
    docs_ui_title: "UI",
    docs_ui_1: "Top Bar",
    docs_ui_2: "Side Menu",
    docs_ui_3: "Smart Capsule",
    docs_ui_4: "Desktop & Wallpapers",
    docs_services_title: "Services",
    docs_services_1: "SystemService",
    docs_services_2: "Weather",
    docs_services_3: "MusicService",
    docs_services_4: "ClipboardService",
    docs_settings_title: "Settings",
    docs_settings_1: "User config `~/.nibrasshell.json`",
    docs_settings_2: "In-app settings panel",
    docs_settings_3: "Themes & Colors",
    docs_dev_title: "Developers",
    docs_dev_1: "Python & Bash scripts",
    docs_dev_2: "Wallpaper system",
    docs_dev_3: "Depth & blur effects",
    docs_dev_cta_title: "Developer Docs",
    docs_dev_cta_desc:
      "Go to developer docs for architecture, services, and scripts.",
    docs_dev_cta_btn: "Developer Docs",
    docs_footer: "This page is a summary; full details are in the docs.",

    roadmap_title: "Roadmap",
    roadmap_sub: "A summary of upcoming work.",
    roadmap_ai_title: "Smart Capsule & AI",
    roadmap_ai_1: "Smart capsule color customization.",
    roadmap_ai_2: "Fuzzy clock linked with AI.",
    roadmap_ai_3: "AI responses for CPU/RAM spikes.",
    roadmap_ai_4: "Clipboard AI summarization.",
    roadmap_ui_title: "UI & Themes",
    roadmap_ui_1: "Game Mode for performance.",
    roadmap_ui_2: "Bar shadow and left menu width controls.",
    roadmap_ui_3: "Advanced depth effects for each wallpaper.",
    roadmap_ui_4: "New themes: Solarized, Rosé Pine, Oxocarbon.",
    roadmap_ui_5: "Pause dynamic wallpaper rotation.",
    roadmap_prod_title: "Widgets & Productivity",
    roadmap_prod_1: "Quick notes widget.",
    roadmap_prod_2: "Favorite apps section.",
    roadmap_prod_3: "AI assistants menu.",
    roadmap_sys_title: "System & Devices",
    roadmap_sys_1: "Full Bluetooth manager.",
    roadmap_sys_2: "Display settings.",
    roadmap_sys_3: "VPN indicator.",
    roadmap_sys_4: "Quick toggles for Wi‑Fi, Airplane, Gammastep.",
    roadmap_sys_5: "Keyboard layout indicator.",
    roadmap_footer: "Roadmap mirrors `todo.md` and updates over time.",

    faq_title: "FAQ",
    faq_sub: "Quick answers to common questions.",
    faq_q1: "Is the project production-ready?",
    faq_a1:
      "It is under active development with both stable and upcoming features.",
    faq_q2: "Does it support video wallpapers?",
    faq_a2: "Yes, via `Wallpaper.qml`.",
    faq_q3: "Can I install on other distros?",
    faq_a3:
      "Yes via manual installation; the script supports Arch, Fedora, and Void.",
    faq_q4: "Where are the shortcuts?",
    faq_a4: "In the Cheatsheet window or directly from Hyprland.",
    faq_footer: "For technical questions, check the docs.",

    gallery_title: "Gallery",
    gallery_sub: "Current screenshots; will be updated later.",
    gallery_footer:
      "Screenshots will be updated when nicer shots are available.",
    cap_smart: "Smart Capsule",
    cap_settings: "Settings Panel",
    cap_m3_dark: "Material You – Dark",
    cap_m3_light: "Material You – Light",
    cap_dracula_light: "Dracula – Light",
    cap_capp_dark: "Catppuccin – Dark",
    cap_capp_light: "Catppuccin – Light",
    cap_nord_dark: "Nord – Dark",
    cap_nord_light: "Nord – Light",
    cap_gruv_dark: "Gruvbox – Dark",
    cap_gruv_light: "Gruvbox – Light",
    cap_gruv_mix: "Gruvbox – Mixed",
    cap_colors: "Colors Theme",
    cap_tokyo: "Tokyo Night",
    cap_tokyo_light: "Tokyo Night – Light",
    cap_deer: "Deer Theme",

    dev_title: "Developer Docs",
    dev_sub: "A compact technical map for architecture and extensibility.",
    dev_arch: "Overall Architecture",
    dev_arch_1: "QML UI via Quickshell.",
    dev_arch_2: "Hyprland for window/screen/event handling.",
    dev_arch_3: "Background services in `config/quickshell/services`.",
    dev_arch_4:
      "Python/Bash scripts in `config/quickshell/scripts` and `scripts`.",
    dev_entry: "Entry Point",
    dev_entry_hint: "Main entry file:",
    dev_entry_desc:
      "This file assembles the top bar, side menu, and smart capsule layers.",
    dev_settings: "Settings Management",
    dev_settings_1:
      "Settings read from `~/.nibrasshell.json` via `ConfigStore.qml`.",
    dev_settings_2: "`App.qml` unifies paths and commands.",
    dev_settings_3: "Cache stored in `~/.cache/nibrasshell`.",
    dev_themes: "Themes & Wallpapers",
    dev_themes_1: "`ThemeManager.qml` handles loading and applying themes.",
    dev_themes_2:
      "`WallpaperController.qml` manages static and dynamic wallpapers.",
    dev_themes_3: "`DepthEffectController.qml` builds depth overlays.",
    dev_services: "Core Services",
    dev_services_th1: "Service",
    dev_services_th2: "Role",
    dev_services_row1: "Resource monitoring, boot analysis, and spike insights",
    dev_services_row2: "Weather fetch, AI analysis, and alerts",
    dev_services_row3: "MPRIS integration and AI commentary",
    dev_services_row4: "Notifications management and DND",
    dev_services_row5: "Clipboard monitoring and actions",
    dev_scripts: "Key Scripts",
    dev_python: "Python",
    dev_bash: "Bash",
    dev_run: "Run Quickshell",
    dev_run_desc: "This script sets log rules to reduce noise during runtime.",
    dev_notes: "Dev Notes",
    dev_note_1: "Smart capsule at `config/quickshell/windows/smart_capsule`.",
    dev_note_2: "Side menu at `config/quickshell/windows/leftwindow`.",
    dev_note_3: "Settings at `config/quickshell/windows/settings`.",
    dev_footer: "This page is a summary and can be expanded later.",

    change_title: "Changelog",
    change_sub: "Template ready for upcoming releases.",
    change_soon: "Coming",
    change_note_1: "Add your release highlights here.",
    change_note_2: "List features, fixes, and improvements.",
    change_note_3: "Another release template.",
    change_footer: "Changelog will be updated with each release.",
  },
};

// وظيفة تطبيق اللغة (محدثة لتشغيل معالجة الأكواد بعدها)
function applyLanguage(lang) {
  const dict = translations[lang] || translations.en;
  document.documentElement.lang = lang === "en" ? "en" : "ar";
  document.documentElement.dir = lang === "en" ? "ltr" : "rtl";
  if (dict.page_title) document.title = dict.page_title;

  document.querySelectorAll("[data-i18n]").forEach((el) => {
    const key = el.getAttribute("data-i18n");
    if (dict[key]) el.textContent = dict[key];
  });

  document.querySelectorAll("[data-i18n-html]").forEach((el) => {
    const key = el.getAttribute("data-i18n-html");
    if (dict[key]) el.innerHTML = dict[key];
  });

  // بعد انتهاء الترجمة، نقوم بتجهيز صناديق الكود
  setupCodeBlocks();
}

// وظيفة تنظيف الكود وإضافة زر النسخ (محدثة لتجنب الاختفاء)
function setupCodeBlocks() {
  const codeBlocks = document.querySelectorAll(".code");
  const currentLang = localStorage.getItem("nibras-lang") || "ar";

  codeBlocks.forEach((block) => {
    // 1. إزالة أي زر نسخ قديم (لتجنب التكرار عند تغيير اللغة)
    const oldBtn = block.querySelector(".copy-btn");
    if (oldBtn) oldBtn.remove();

    // 2. تنظيف النص (Trim)
    // نستخدم textContent لضمان الحصول على النص الخام الذي وضعه سكربت الترجمة
    let codeContent = block.textContent.trim();
    block.textContent = codeContent;

    // 3. إنشاء زر النسخ
    const copyBtn = document.createElement("button");
    copyBtn.className = "copy-btn";
    copyBtn.type = "button";
    copyBtn.innerText = currentLang === "ar" ? "نسخ" : "Copy";

    // 4. وظيفة النسخ
    copyBtn.addEventListener("click", (e) => {
      e.stopPropagation(); // منع تداخل الأحداث
      navigator.clipboard.writeText(codeContent).then(() => {
        const originalText = copyBtn.innerText;
        copyBtn.innerText = currentLang === "ar" ? "تم!" : "Done!";
        copyBtn.classList.add("copied");

        setTimeout(() => {
          copyBtn.innerText = originalText;
          copyBtn.classList.remove("copied");
        }, 2000);
      });
    });

    // 5. إضافة الزر للكرت
    block.appendChild(copyBtn);
  });
}

function resolveHeroImage(theme) {
  const map = {
    tokyonight: "assets/tokyonight-dark.png",
    "tokyonight-light": "assets/tokyonight-light.jpg",
    dracula: "assets/dracula-dark.png",
    "dracula-light": "assets/dracula-light.png",
    catppuccin: "assets/catppuccin-dark.png",
    "catppuccin-light": "assets/catppuccin-light.jpg",
    gruvbox: "assets/gruvbox-dark.png",
    "gruvbox-light": "assets/gruvbox-light.png",
    nord: "assets/nord-dark.png",
    "nord-light": "assets/nord-light.png",
    material: "assets/material-dark.png",
    "material-light": "assets/material-light.png",
  };
  return map[theme] || "assets/material-dark.png";
}

function applyTheme(theme) {
  if (!theme) return;
  document.documentElement.setAttribute("data-theme", theme);
  if (themeSelect) themeSelect.value = theme;
  if (heroImage) heroImage.src = resolveHeroImage(theme);
}

const savedTheme = localStorage.getItem("nibras-theme");
const initialTheme = savedTheme || (themeSelect ? themeSelect.value : null);
if (initialTheme) {
  applyTheme(initialTheme);
}

const savedLang = localStorage.getItem("nibras-lang");
const browserLang = (navigator.language || "").toLowerCase();
const initialLang = savedLang || (browserLang.startsWith("ar") ? "ar" : "en");
if (langSelect) langSelect.value = initialLang;
applyLanguage(initialLang);

if (themeSelect) {
  themeSelect.addEventListener("change", (e) => {
    const theme = e.target.value;
    applyTheme(theme);
    localStorage.setItem("nibras-theme", theme);
  });
}

if (langSelect) {
  langSelect.addEventListener("change", (e) => {
    const lang = e.target.value;
    localStorage.setItem("nibras-lang", lang);
    applyLanguage(lang);
  });
}

if (navToggle && navRoot) {
  navToggle.addEventListener("click", () => {
    navRoot.classList.toggle("open");
  });
}

// تشغيل الوظيفة عند تحميل الصفحة
document.addEventListener("DOMContentLoaded", setupCodeBlocks);
