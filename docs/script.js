const themeSelect = document.getElementById("themeSelect");
const langSelect = document.getElementById("langSelect");
const navToggle = document.getElementById("navToggle");
const navRoot = document.getElementById("navRoot");
const heroImage = document.getElementById("heroImage");

const translations = {
  ar: {
    // --- العلامة التجارية والقائمة (Global) ---
    page_title: "نِبراس شِل - واجهة مدمجة بالذكاء الاصطناعي",
    brand_name: "نِبراس شِل",
    brand_tagline: "واجهة مدمجة بالذكاء الاصطناعي",
    nav_home: "الرئيسية",
    nav_docs: "الوثائق",
    nav_roadmap: "خارطة الطريق",
    nav_menu: "فتح القائمة",

    // --- الصفحة الرئيسية: الهيرو (Hero) ---
    hero_badge: "واجهة مدمجة بالذكاء الاصطناعي",
    hero_title: "تجربة سطح مكتب حديثة، ذكية، ومتكاملة",
    hero_desc:
      "واجهة تركّز على أفضل ما في التجربة: شريط علوي ذكي، كبسولة تفاعلية، وثيمات مصممة بعناية.",
    cta_docs: "اقرأ الوثائق",
    cta_github: "المستودع",
    stat_themes: "ثيمات جاهزة",
    stat_modules: "وحدات رئيسية",
    stat_live: "مراقبة حيّة",
    signal_1: "واجهة متجددة باستمرار",
    signal_2: "ذكاء مدمج في تفاصيل التجربة",
    signal_3: "تخصيص عميق بضغطة واحدة",
    ai_providers_note:
      "يدعم عدة مزودين للذكاء الاصطناعي، بما فيها مزود محلي عبر:",

    // --- الصفحة الرئيسية: لماذا والأدوات ---
    why_title: "لماذا نبراس شِل؟",
    tools_title: "هي هواية، ليس إلا",
    tools_sub:
      "كل سطر كود في هذه الأدوات كُتب من أجل المتعة الشخصية وحب الاستكشاف، دون أي أهداف أخرى.",

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

    // --- الصفحة الرئيسية: المميزات (Bento) ---
    why_1_title: "واجهة ذكية",
    why_1_desc:
      "كبسولة ذكية تتفاعل مع المستخدم عبر الهوفر، وتعرض رسائل الذكاء الاصطناعي مع ملخصات الطقس والموسيقى.",
    smart_preview_label: "معاينة الكبسولة الذكية",
    why_2_title: "تخصيص عميق",
    why_2_desc: "تحكم شامل بالألوان والخطوط والخلفيات وأسلوب القوائم.",
    why_3_title: "خدمات متكاملة",
    why_3_desc: "مراقبة النظام، إشعارات ذكية، شبكة، حافظة، ومركز إعدادات كامل.",

    // --- الصفحة الرئيسية: المعرض والقيم ---
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

    // --- صفحة خارطة الطريق (Roadmap) - العناوين ---
    roadmap_title: "خارطة الطريق",
    roadmap_sub:
      "نبراس شِل هو نتاج هوايتي المستمرة. إليك ما أعمل عليه الآن وما أطمح لتحقيقه في المستقبل.",
    roadmap_ai_title: "الذكاء الاصطناعي والكبسولة الذكية",
    roadmap_desktop_title: "تخطيط سطح المكتب والشل",
    roadmap_ui_title: "الواجهة والثيمات",
    roadmap_sys_title: "الإنتاجية والنظام",
    roadmap_archive_title: "ما تم إنجازه (أرشيف الإصدارات السابقة)",

    // --- خارطة الطريق - القوائم التفصيلية ---
    rd_ai_phases: "الجزء 1: خارطة العقل (الذكاء المدمج)",
    rd_ai_li1: "المرحلة 1: المراقبة والتسجيل (تحليل السجلات)",
    rd_ai_li2: "المرحلة 2: التشخيص (المودل يحدد الأخطاء بدقة)",
    rd_ai_li3: "المرحلة 3: المحادثة السياقية حول المشكلة",
    rd_ai_li4: "المرحلة 4: اقتراح الحلول البرمجية",
    rd_ai_li5: "المرحلة 5: التنفيذ الذاتي (المعالجة الذاتية - تجريبي)",

    rd_capsule_features: "الجزء 2: ميزات الجسد (الكبسولة)",
    rd_cap_li1: "ردود فعل النظام: فكاهة عند ضغط المعالج/الذاكرة",
    rd_cap_li2: "ألوان الكبسولة: إعدادات ألوان مستقلة",
    rd_cap_li3: "ساعة تقريبية (Fuzzy Clock) متصلة بالذكاء",
    rd_cap_li4: "ملخص الحافظة الذكي (Clipboard AI)",

    rd_desktop_bars: "الأشرطة والدك (Bars & Dock)",
    rd_desk_li1: "تغيير مواقع الأشرطة (علوي، سفلي، جانبي)",
    rd_desk_li2: "الإخفاء التلقائي للأشرطة",
    rd_desk_li3: "إضافة شريط تطبيقات سفلي مستقل (Dock)",
    rd_desk_li4: "التكيف الذكي للـ Dock عند تغيير موقع الشريط",

    rd_desktop_workspaces: "مساحات العمل (Workspaces)",
    rd_ws_li1: "أيقونات ديناميكية بدلاً من الأرقام",
    rd_ws_li2: "سحب وإفلات الأيقونات لنقل التطبيقات",
    rd_ws_li3: "واجهة مرئية (Overview) لاستعراض مساحات العمل",
    rd_ws_li4: "النقر على الأيقونة للتركيز والانتقال للمساحة",

    rd_ui_li1: "تحسين هيكلية ThemeManager",
    rd_ui_li2: "دعم خلفيات GIF و Video",
    rd_ui_li3: "ضبط متغيرات Material 3 الديناميكية",
    rd_ui_li4: "وضع الألعاب (Game Mode) للأداء العالي",
    rd_ui_li5: "تأثير العمق التلقائي وربطه بـ Cava",
    rd_ui_li6: "ثيمات جديدة: Solarized, Rosé Pine, Oxocarbon",

    rd_sys_li1: "مؤشر اللغة، البطارية، وأوضاع الطاقة",
    rd_sys_li2: "مدير الحافظة وقائمة المهام",
    rd_sys_li3: "ودجت الملاحظات السريعة والتطبيقات المفضلة",
    rd_sys_li4: "مواقيت الصلاة والتاريخ الهجري",
    rd_sys_li5: "مدير البلوتوث وإعدادات الشاشة الكاملة",
    rd_sys_li6: "تحسين الكود: الانتقال إلى نظام EventBus",

    // --- صفحة الوثائق (Docs) ---
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

    // --- صفحة التثبيت (Install) ---
    install_title: "التثبيت",
    install_auto_title: "الطريقة التلقائية (موصى بها)",
    install_auto_desc:
      "قم باستنساخ المستودع، ثم قم بتشغيل السكربت التالي الذي سيهتم بكل شيء، بما في ذلك إنشاء ملف الإعدادات",

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
    install_script_step_2: `
$ python3 install.py                                                                                       ↵ 130
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
...`,
    install_manual_files:
      "في حال لم يعمل السكربت الآن اكمل مع التثبيت اليدوي لتهيئة الملفات:",
    install_final_note:
      "بإمكانك تغيير خط الجهاز إلى 'JF Flat' وتخصيص الواجهة من خلال الإعدادات المتقدمة (win+s).",

    // --- صفحة المطورين (Dev Docs) ---
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
    donate_title: "دعم المشروع؟",
    donate_desc:
      "إذا كنت ترغب في دعمي مالياً، فشكراً لك! لكن الحمد لله وضعي المادي جيد. بدلاً من ذلك، أدعوك للتبرع لأهلنا في غزة، فهم في أمسّ الحاجة للدعم الآن.",
    donate_btn: "تبرع لغزة الآن 🇵🇸",
    org_medical: "إغاثة طبية للأطفال",
    org_general: "إغاثة عامة وطوارئ",
    org_food: "توفير الغذاء والوجبات",
    org_msf: "دعم الفرق الطبية",
    // --- Footer ---
    footer_pages: "NibrasShell Project © " + new Date().getFullYear(),
  },

  en: {
    // --- Global ---
    page_title: "NibrasShell - AI Integrated Shell",
    brand_name: "NibrasShell",
    brand_tagline: "AI Integrated Shell",
    nav_home: "Home",
    nav_docs: "Docs",
    nav_roadmap: "Roadmap",
    nav_menu: "Open Menu",

    // --- Hero ---
    hero_badge: "AI Integrated Shell",
    hero_title: "A modern, smart, and complete desktop experience",
    hero_desc:
      "A focused UI that highlights the best: a smart top bar, an interactive capsule, and carefully crafted themes.",
    cta_docs: "Read Docs",
    cta_github: "Repository",
    stat_themes: "Ready themes",
    stat_modules: "Core modules",
    stat_live: "Live monitoring",
    signal_1: "Continuously evolving interface",
    signal_2: "Intelligence built into the experience",
    signal_3: "Deep customization in one click",
    ai_providers_note:
      "Supports multiple AI providers, including a local provider via:",

    // --- Why & Tools ---
    why_title: "Why NibrasShell?",
    tools_title: "It's just a hobby, nothing more",
    tools_sub:
      "Every line of code in these tools was written for personal enjoyment and the love of exploration, with no other goals.",

    tool_settings_title: "Comprehensive Built-in Settings",
    tool_settings_desc:
      "No need to edit config files manually. The built-in settings app gives you full control over colors, themes, wallpapers, and AI models.",
    tool_settings_li1: "Modify themes and colors instantly.",
    tool_settings_li2: "Manage and customize AI models.",

    tool_launcher_title: "Smart Connected Launcher",
    tool_launcher_desc:
      "More than just an app list. It offers an advanced command mode and direct wallpaper fetching.",
    tool_launcher_li1: "Use the > symbol for quick system commands.",
    tool_launcher_li2: "Wallhaven integration to fetch wallpapers directly.",

    // --- Features (Bento) ---
    why_1_title: "Smart Interactions",
    why_1_desc:
      "A smart capsule that reacts to user hover and shows AI messages with weather and music summaries.",
    smart_preview_label: "Smart Capsule Preview",
    why_2_title: "Deep Customization",
    why_2_desc:
      "Full control over colors, fonts, wallpapers, and menu behavior.",
    why_3_title: "Integrated Services",
    why_3_desc:
      "System monitoring, smart notifications, network, clipboard, and a full settings hub.",

    // --- Shots & Value ---
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

    // --- Roadmap ---
    roadmap_title: "Roadmap",
    roadmap_sub:
      "NibrasShell is a product of my ongoing hobby. Here is what I am working on now and what I aim to achieve.",
    roadmap_ai_title: "AI & Smart Capsule",
    roadmap_desktop_title: "Desktop & Shell",
    roadmap_ui_title: "UI & Theming",
    roadmap_sys_title: "System & Productivity",
    roadmap_archive_title: "Completed (Archive)",

    // --- Roadmap List Items ---
    rd_ai_phases: "Part 1: The Brain Roadmap (AI Phases)",
    rd_ai_li1: "Phase 1: Observation & Logging (Log analysis)",
    rd_ai_li2: "Phase 2: Diagnosis (Model identifies errors)",
    rd_ai_li3: "Phase 3: Contextual Chat (Issue-based chat)",
    rd_ai_li4: "Phase 4: Solution Proposal (Suggesting fixes)",
    rd_ai_li5: "Phase 5: Autonomous Execution (Experimental)",

    rd_capsule_features: "Part 2: The Body Features (Capsule)",
    rd_cap_li1: "System Reactions: Humor/Reactions to CPU/RAM spikes",
    rd_cap_li2: "Capsule Colors: Independent color settings",
    rd_cap_li3: "Fuzzy Clock: AI-connected rough time logic",
    rd_cap_li4: "Clipboard AI: Summarizer for copied text",

    rd_desktop_bars: "Bars & Dock",
    rd_desk_li1: "Positioning: Move default bars (Top, Bottom, Side)",
    rd_desk_li2: "Auto-hide: Implement auto-hide for bars",
    rd_desk_li3: "Standalone Dock: Add a bottom application dock",
    rd_desk_li4: "Smart Adaptation: Dock auto-adjusts layout",

    rd_desktop_workspaces: "Workspaces",
    rd_ws_li1: "Dynamic Icons: Show app icons instead of numbers",
    rd_ws_li2: "Drag-and-Drop: Move apps between workspaces",
    rd_ws_li3: "Visual Overview: New UI view for workspace previews",
    rd_ws_li4: "Click-to-Focus: Click app icon to focus window",

    rd_ui_li1: "Improve Themes: Restructure ThemeManager",
    rd_ui_li2: "GIF & Video Wallpapers support",
    rd_ui_li3: "Dynamic Coloring: Configure Material 3 variants",
    rd_ui_li4: "Game Mode: Toggle for high performance",
    rd_ui_li5: "Depth Effect: Auto-generation linked with Cava",
    rd_ui_li6: "New Themes: Solarized, Rosé Pine, Oxocarbon",

    rd_sys_li1: "Indicators: Language, Battery, Power Profiles",
    rd_sys_li2: "Clipboard Manager & Todo List",
    rd_sys_li3: "Widgets: Quick Notes & Favorite Apps",
    rd_sys_li4: "Prayer Times & Hijri Date",
    rd_sys_li5: "Bluetooth Manager & Display Settings",
    rd_sys_li6: "Code Refactoring: Migration to EventBus",

    // --- Docs ---
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

    // --- Install ---
    install_title: "Installation",
    install_auto_title: "Automatic Method (Recommended)",
    install_auto_desc:
      'Clone the repo and run <span dir="ltr">python install.py</span>.',
    install_manual_toggle: "Manual Installation (Click to expand)",
    install_manual_deps: "Essential Software",
    install_manual_optional: "Optional Software",
    install_arch_title: "Arch Users:",
    install_fedora_title: "Fedora Users:",
    install_other_distros:
      "<strong>Note:</strong> For other distros, install dependencies manually.",
    install_depth_effect: "Depth Effect Requirements",
    install_depth_desc: "We need 'rembg' and 'pillow' libraries.",
    install_script_step: "Now run the install script and choose option 2",
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
    install_manual_files: "If script fails, proceed with manual file setup:",
    install_final_note:
      "You can change system font to 'JF Flat' and customize via (win+s).",

    // --- Dev Docs ---
    dev_title: "Developer Docs",
    dev_sub: "A technical map to understand project structure.",
    dev_arch: "Architecture",
    dev_arch_1: "QML UI via Quickshell.",
    dev_arch_2: "Hyprland for window/event handling.",
    dev_arch_3: "Background services in `config/quickshell/services`.",
    dev_arch_4: "Python/Bash scripts in `scripts` folders.",
    dev_entry: "Entry Point",
    dev_entry_hint: "Main file:",
    dev_entry_desc: "Assembles top bar, side menu, and capsule.",
    dev_settings: "Settings Management",
    dev_settings_1: "Reads `~/.nibrasshell.json` via `ConfigStore.qml`.",
    dev_settings_2: "`App.qml` unifies paths.",
    dev_settings_3: "Cache in `~/.cache/nibrasshell`.",
    dev_themes: "Themes & Wallpapers",
    dev_themes_1: "`ThemeManager.qml` handles themes.",
    dev_themes_2: "`WallpaperController.qml` manages wallpapers.",
    dev_themes_3: "`DepthEffectController.qml` handles depth.",
    dev_services: "Core Services",
    dev_services_th1: "Service",
    dev_services_th2: "Role",
    dev_services_row1: "Resource monitoring & Boot analysis",
    dev_services_row2: "Weather & AI analysis",
    dev_services_row3: "MPRIS & AI commentary",
    dev_services_row4: "Notifications & DND",
    dev_services_row5: "Clipboard monitoring",
    dev_scripts: "Key Scripts",
    dev_python: "Python",
    dev_bash: "Bash",
    dev_run: "Run Quickshell",
    dev_run_desc: "Sets log rules to reduce noise.",
    dev_notes: "Dev Notes",
    dev_note_1: "Smart capsule: `config/quickshell/windows/smart_capsule`.",
    dev_note_2: "Side menu: `config/quickshell/windows/leftwindow`.",
    dev_note_3: "Settings: `config/quickshell/windows/settings`.",
    donate_title: "Support the project?",
    donate_desc:
      "If you're considering a financial donation, thank you! However, my financial situation is stable. Instead, I invite you to donate to the people of Gaza, as they are in much greater need of support right now.",
    donate_btn: "Donate to Gaza Now 🇵🇸",
    org_medical: "Medical relief for children",
    org_general: "General & emergency relief",
    org_food: "Food & meal programs",
    org_msf: "Support medical teams",
    // --- Footer ---
    footer_pages: "NibrasShell Project © " + new Date().getFullYear(),
  },
};

// --- وظيفة تطبيق اللغة ---
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

  document.querySelectorAll("[data-i18n-aria]").forEach((el) => {
    const key = el.getAttribute("data-i18n-aria");
    if (dict[key]) el.setAttribute("aria-label", dict[key]);
  });

  // إعادة ضبط الأكواد بعد الترجمة (لضمان ظهور النصوص وزر النسخ)
  setupCodeBlocks();
}

// --- وظيفة تنظيف الكود وإضافة زر النسخ ---
function setupCodeBlocks() {
  const codeBlocks = document.querySelectorAll(".code");
  const currentLang = localStorage.getItem("nibras-lang") || "ar";

  codeBlocks.forEach((block) => {
    // إزالة الزر القديم لتجنب التكرار
    const oldBtn = block.querySelector(".copy-btn");
    if (oldBtn) oldBtn.remove();

    // تنظيف النص (Trim) من المسافات الزائدة
    // ملاحظة: نستخدم textContent للحصول على النص الخام فقط
    // إذا كان هناك نص سابق تم تنظيفه، نستخدمه
    if (!block.dataset.original) {
      block.dataset.original = block.textContent;
    }
    let codeContent = block.dataset.original.trim();
    block.textContent = codeContent;

    // إنشاء زر النسخ
    const copyBtn = document.createElement("button");
    copyBtn.className = "copy-btn";
    copyBtn.type = "button";
    copyBtn.innerText = currentLang === "ar" ? "نسخ" : "Copy";

    copyBtn.addEventListener("click", (e) => {
      e.stopPropagation();
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

    block.appendChild(copyBtn);
  });
}

// --- إدارة الثيمات والصور ---
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

// --- تهيئة الصفحة عند التحميل ---
document.addEventListener("DOMContentLoaded", () => {
  // تحميل الثيم المحفوظ
  const savedTheme = localStorage.getItem("nibras-theme") || "material";
  applyTheme(savedTheme);

  // تحميل اللغة المحفوظة
  const savedLang =
    localStorage.getItem("nibras-lang") ||
    (navigator.language.startsWith("ar") ? "ar" : "en");

  if (langSelect) langSelect.value = savedLang;
  applyLanguage(savedLang);

  // مستمعي الأحداث (Event Listeners)
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
});
