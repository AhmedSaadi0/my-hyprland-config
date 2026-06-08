# Graph Report - .  (2026-05-06)

## Corpus Check
- Large corpus: 103 files · ~1,110,039 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder, or use --no-semantic to run AST-only.

## Summary
- 229 nodes · 268 edges · 39 communities (31 shown, 8 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 28 edges (avg confidence: 0.72)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_AI Provider System|AI Provider System]]
- [[_COMMUNITY_Material Design CSS|Material Design CSS]]
- [[_COMMUNITY_Python Dependencies|Python Dependencies]]
- [[_COMMUNITY_Audio Device Management|Audio Device Management]]
- [[_COMMUNITY_Network Data Usage|Network Data Usage]]
- [[_COMMUNITY_Wallpaper Scanner|Wallpaper Scanner]]
- [[_COMMUNITY_AI Main Controller|AI Main Controller]]
- [[_COMMUNITY_Temperature Monitoring|Temperature Monitoring]]
- [[_COMMUNITY_Battery Information|Battery Information]]
- [[_COMMUNITY_Konsole Profile Manager|Konsole Profile Manager]]
- [[_COMMUNITY_Theme Icon Resolver|Theme Icon Resolver]]
- [[_COMMUNITY_WiFi Network List|WiFi Network List]]
- [[_COMMUNITY_GTK Theme Manager|GTK Theme Manager]]
- [[_COMMUNITY_System Monitor|System Monitor]]
- [[_COMMUNITY_Depth Image Rembg|Depth Image Rembg]]
- [[_COMMUNITY_Cache Image Cleaner|Cache Image Cleaner]]
- [[_COMMUNITY_Icon Theme List|Icon Theme List]]
- [[_COMMUNITY_GTK Theme List|GTK Theme List]]
- [[_COMMUNITY_Cursor Theme List|Cursor Theme List]]
- [[_COMMUNITY_WiFi Connection|WiFi Connection]]
- [[_COMMUNITY_Data Usage Tracker|Data Usage Tracker]]

## God Nodes (most connected - your core abstractions)
1. `ColorExporter` - 10 edges
2. `get_provider()` - 10 edges
3. `Development Roadmap` - 10 edges
4. `Python Dependencies 3.13` - 9 edges
5. `LLMProvider` - 8 edges
6. `KittyThemeExporter` - 7 edges
7. `CssThemeExporter` - 7 edges
8. `OllamaProvider` - 6 edges
9. `OpenRouterProvider` - 6 edges
10. `OpenAIProvider` - 6 edges

## Surprising Connections (you probably didn't know these)
- `AI Weather Analysts` --references--> `google-generativeai`  [INFERRED]
  todo.md → scripts/python/requirements-3.13.txt
- `AI Audiophile` --references--> `google-generativeai`  [INFERRED]
  todo.md → scripts/python/requirements-3.13.txt
- `Clipboard Manager` --references--> `psutil`  [INFERRED]
  todo.md → scripts/python/requirements-3.13.txt
- `Todo List` --references--> `PyQt6`  [INFERRED]
  todo.md → scripts/python/requirements-3.13.txt
- `ThemeManager` --references--> `kde-material-you-colors`  [INFERRED]
  todo.md → scripts/python/requirements-3.13.txt

## Communities (39 total, 8 thin omitted)

### Community 0 - "AI Provider System"
Cohesion: 0.08
Nodes (15): ABC, LLMProvider, get_provider(), get_raw_boot_logs(), get_system_details(), # TODO: -> test logic, # TODO: -> test logic, تجميع بيانات الإقلاع واللوجات في نص واحد (+7 more)

### Community 1 - "Material Design CSS"
Cohesion: 0.09
Nodes (11): CssThemeExporter, Handles the generation and export of CSS files based on a color schema., Generates the needed CSS classes., Writes the generated classes into the CSS file., main(), KittyThemeExporter, Handles the generation and export of CSS files based on a color schema., Generates the needed CSS classes. (+3 more)

### Community 2 - "Python Dependencies"
Cohesion: 0.14
Nodes (21): Python Dependencies 3.13, google-generativeai, json-repair, kde-material-you-colors, ollama, openai, pillow, psutil (+13 more)

### Community 3 - "Audio Device Management"
Cohesion: 0.26
Nodes (11): classify_audio_device(), get_audio_device_group_key(), get_audio_devices(), get_audio_devices_control(), get_capture_devices(), get_display_devices_hyprland(), get_usb_peripherals(), main() (+3 more)

### Community 4 - "Network Data Usage"
Cohesion: 0.29
Nodes (7): ensure_db(), fallback_psutil(), get_live_usage(), parse_nethogs_output(), parse_nethogs_process(), persist_rows(), run_nethogs()

### Community 5 - "Wallpaper Scanner"
Cohesion: 0.29
Nodes (9): debug(), get_images_from_dir(), get_mtime(), main(), طباعة رسائل تتبع في stderr, جلب تاريخ تعديل الملف لغرض الترتيب, تحويل المسارات إلى مسارات مطلقة وصحيحة, جلب الصور من مجلد معين (+1 more)

### Community 6 - "AI Main Controller"
Cohesion: 0.24
Nodes (6): extract_and_clean_json(), get_fallback_response(), main(), رد احتياطي في حال فشل كل شيء لضمان عدم انهيار التطبيق, get_system_data(), main()

### Community 7 - "Temperature Monitoring"
Cohesion: 0.42
Nodes (6): add_temp_reading(), get_cpu_temps_psutil(), get_detailed_temps(), get_gpu_temps(), get_storage_temps(), init_temp_data()

### Community 8 - "Battery Information"
Cohesion: 0.31
Nodes (8): get_battery_info(), get_linux_battery_details(), get_macos_battery_details(), get_windows_battery_details(), يسترجع تفاصيل البطارية الخاصة بنظام Windows عبر WMI., يسترجع تفاصيل البطارية الخاصة بنظام macOS باستخدام ioreg., يسترجع تفاصيل البطارية الخاصة بنظام Linux من Sysfs.     يتوقع وجود البطارية الأو, يجمع معلومات البطارية الأساسية من psutil ومعلومات متقدمة خاصة بنظام التشغيل.

### Community 9 - "Konsole Profile Manager"
Cohesion: 0.5
Nodes (7): apply_profile_to_session(), list_konsole_services(), list_session_paths(), main(), pick_qdbus_bin(), qdbus_candidates(), run_qdbus()

### Community 10 - "Theme Icon Resolver"
Cohesion: 0.5
Nodes (6): build_theme_chain(), existing_theme_dir(), expand_dirs(), main(), read_theme_meta(), resolve_icon()

### Community 11 - "WiFi Network List"
Cohesion: 0.38
Nodes (6): is_ssid_saved(), list_available_networks(), parse_nmcli_line(), يتحقق مما إذا كان ملف تعريف اتصال لـ SSID معين موجودًا., تعرض شبكات الواي فاي المتاحة، باستخدام طريقة تحقق فردية., محلل مخصص لأسطر nmcli الذي يتعامل مع الحروف المهملة (escaped characters).

### Community 15 - "System Monitor"
Cohesion: 0.67
Nodes (3): get_max_temp(), main(), نفس منطق سكربت الباش الخاص بك ولكن بلغة بايثون للحصول على دقة وأداء أعلى

## Knowledge Gaps
- **36 isolated node(s):** `يعالج صورة لإزالة الخلفية باستخدام rembg مع خيارات قابلة للتخصيص.`, `يسترجع تفاصيل البطارية الخاصة بنظام Linux من Sysfs.     يتوقع وجود البطارية الأو`, `يسترجع تفاصيل البطارية الخاصة بنظام Windows عبر WMI.`, `يسترجع تفاصيل البطارية الخاصة بنظام macOS باستخدام ioreg.`, `يجمع معلومات البطارية الأساسية من psutil ومعلومات متقدمة خاصة بنظام التشغيل.` (+31 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `get_provider()` connect `AI Provider System` to `AI Main Controller`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `ColorExporter` (e.g. with `CssThemeExporter` and `KittyThemeExporter`) actually correct?**
  _`ColorExporter` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 7 inferred relationships involving `get_provider()` (e.g. with `main()` and `GeminiProvider`) actually correct?**
  _`get_provider()` has 7 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `LLMProvider` (e.g. with `GeminiProvider` and `LocalProvider`) actually correct?**
  _`LLMProvider` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `يعالج صورة لإزالة الخلفية باستخدام rembg مع خيارات قابلة للتخصيص.`, `يسترجع تفاصيل البطارية الخاصة بنظام Linux من Sysfs.     يتوقع وجود البطارية الأو`, `يسترجع تفاصيل البطارية الخاصة بنظام Windows عبر WMI.` to the rest of the system?**
  _36 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `AI Provider System` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Material Design CSS` be split into smaller, more focused modules?**
  _Cohesion score 0.09 - nodes in this community are weakly interconnected._