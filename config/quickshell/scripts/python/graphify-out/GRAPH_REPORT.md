# Graph Report - python  (2026-07-15)

## Corpus Check
- 55 files · ~17,781 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 228 nodes · 282 edges · 33 communities (27 shown, 6 thin omitted)
- Extraction: 93% EXTRACTED · 7% INFERRED · 0% AMBIGUOUS · INFERRED: 20 edges (avg confidence: 0.7)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]

## God Nodes (most connected - your core abstractions)
1. `ColorExporter` - 10 edges
2. `get_provider()` - 10 edges
3. `LLMProvider` - 8 edges
4. `KittyThemeExporter` - 7 edges
5. `CssThemeExporter` - 7 edges
6. `summarize_usage_with_vnstat()` - 7 edges
7. `OllamaProvider` - 6 edges
8. `OpenRouterProvider` - 6 edges
9. `OpenAIProvider` - 6 edges
10. `get_detailed_temps()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `main()` --calls--> `ColorExporter`  [INFERRED]
  m3/dynamic-m3.py → m3/plasma_color.py
- `main()` --calls--> `get_provider()`  [INFERRED]
  ai/main.py → ai/config.py
- `ColorExporter` --uses--> `CssThemeExporter`  [INFERRED]
  m3/plasma_color.py → m3/css_theme.py
- `ColorExporter` --uses--> `KittyThemeExporter`  [INFERRED]
  m3/plasma_color.py → m3/kitty_theme.py
- `GeminiProvider` --uses--> `LLMProvider`  [INFERRED]
  ai/gemini_provider.py → ai/base_provider.py

## Communities (33 total, 6 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.08
Nodes (15): ABC, LLMProvider, get_provider(), get_raw_boot_logs(), get_system_details(), # TODO: -> test logic, # TODO: -> test logic, تجميع بيانات الإقلاع واللوجات في نص واحد (+7 more)

### Community 1 - "Community 1"
Cohesion: 0.09
Nodes (11): CssThemeExporter, Handles the generation and export of CSS files based on a color schema., Generates the needed CSS classes., Writes the generated classes into the CSS file., main(), KittyThemeExporter, Handles the generation and export of CSS files based on a color schema., Generates the needed CSS classes. (+3 more)

### Community 2 - "Community 2"
Cohesion: 0.12
Nodes (22): get_app_breakdown(), get_data_usage(), يعرض استهلاك البيانات لفترة محددة بصيغة JSON.     مبني على الهيكل الفعلي لمخرجات, per-app breakdown للشهر باستخدام vnstat + nethogs ratios., calculate_app_ratios_from_db(), ensure_db(), estimate_per_app_from_vnstat(), fallback_psutil() (+14 more)

### Community 3 - "Community 3"
Cohesion: 0.13
Nodes (12): Shared constants and building blocks for all Nibras prompts.  Centralizes person, Boot solution prompt: actionable Linux remediation steps for boot analysis issue, Color palette prompt: precise UI color designer for a Quickshell theme editor., Concise few-shot examples for complex JSON schemas.  Each constant is a minimal, Idle capsule prompts: short hover replies for an idle UI widget.  IDLE_CAPSULE_P, Nibras prompt package.  All prompts are organized by task. The legacy `prompt.py, Music master prompt: mood-aware music expert with safe recommendation logic., Simple persona prompts: PROGRAMMER (coder preset) and ASSISTANT (chat preset). (+4 more)

### Community 4 - "Community 4"
Cohesion: 0.36
Nodes (6): add_temp_reading(), get_cpu_temps_psutil(), get_detailed_temps(), get_gpu_temps(), get_storage_temps(), init_temp_data()

### Community 5 - "Community 5"
Cohesion: 0.29
Nodes (9): debug(), get_images_from_dir(), get_mtime(), main(), طباعة رسائل تتبع في stderr, جلب تاريخ تعديل الملف لغرض الترتيب, تحويل المسارات إلى مسارات مطلقة وصحيحة, جلب الصور من مجلد معين (+1 more)

### Community 6 - "Community 6"
Cohesion: 0.31
Nodes (8): get_battery_info(), get_linux_battery_details(), get_macos_battery_details(), get_windows_battery_details(), يسترجع تفاصيل البطارية الخاصة بنظام Windows عبر WMI., يسترجع تفاصيل البطارية الخاصة بنظام macOS باستخدام ioreg., يسترجع تفاصيل البطارية الخاصة بنظام Linux من Sysfs.     يتوقع وجود البطارية الأو, يجمع معلومات البطارية الأساسية من psutil ومعلومات متقدمة خاصة بنظام التشغيل.

### Community 7 - "Community 7"
Cohesion: 0.25
Nodes (7): build_message(), Backward-compatible re-export of all Nibras prompts.  The actual definitions liv, DEPRECATED: use prompts.idle_capsule.build_idle_user_message() instead.      Kep, build_idle_user_message(), Build a user message for the idle capsule prompt.      key: one of 'idle_capsule, get_system_data(), main()

### Community 8 - "Community 8"
Cohesion: 0.5
Nodes (7): apply_profile_to_session(), list_konsole_services(), list_session_paths(), main(), pick_qdbus_bin(), qdbus_candidates(), run_qdbus()

### Community 9 - "Community 9"
Cohesion: 0.5
Nodes (6): build_theme_chain(), existing_theme_dir(), expand_dirs(), main(), read_theme_meta(), resolve_icon()

### Community 10 - "Community 10"
Cohesion: 0.25
Nodes (5): build_full(), list_battery_levels(), System action prompt: short, engaging responses for system actions (shutdown, re, Return a dict of every category -> its sub-prompt.      Call this ONCE at system, Return all battery thresholds (sorted ascending).

### Community 11 - "Community 11"
Cohesion: 0.38
Nodes (6): is_ssid_saved(), list_available_networks(), parse_nmcli_line(), يتحقق مما إذا كان ملف تعريف اتصال لـ SSID معين موجودًا., تعرض شبكات الواي فاي المتاحة، باستخدام طريقة تحقق فردية., محلل مخصص لأسطر nmcli الذي يتعامل مع الحروف المهملة (escaped characters).

### Community 13 - "Community 13"
Cohesion: 0.6
Nodes (4): extract_and_clean_json(), get_fallback_response(), main(), رد احتياطي في حال فشل كل شيء لضمان عدم انهيار التطبيق

### Community 14 - "Community 14"
Cohesion: 0.67
Nodes (3): get_max_temp(), main(), الحصول على أعلى درجة حرارة من المسارات المخزنة مسبقاً

## Knowledge Gaps
- **52 isolated node(s):** `يعالج صورة لإزالة الخلفية باستخدام rembg مع خيارات قابلة للتخصيص.`, `يسترجع تفاصيل البطارية الخاصة بنظام Linux من Sysfs.     يتوقع وجود البطارية الأو`, `يسترجع تفاصيل البطارية الخاصة بنظام Windows عبر WMI.`, `يسترجع تفاصيل البطارية الخاصة بنظام macOS باستخدام ioreg.`, `يجمع معلومات البطارية الأساسية من psutil ومعلومات متقدمة خاصة بنظام التشغيل.` (+47 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `get_provider()` connect `Community 0` to `Community 13`, `Community 7`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Why does `build_idle_user_message()` connect `Community 7` to `Community 3`?**
  _High betweenness centrality (0.058) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `ColorExporter` (e.g. with `CssThemeExporter` and `KittyThemeExporter`) actually correct?**
  _`ColorExporter` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 6 inferred relationships involving `get_provider()` (e.g. with `main()` and `LocalProvider`) actually correct?**
  _`get_provider()` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `LLMProvider` (e.g. with `GeminiProvider` and `LocalProvider`) actually correct?**
  _`LLMProvider` has 5 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `KittyThemeExporter` (e.g. with `ColorExporter` and `.export_kitty_config()`) actually correct?**
  _`KittyThemeExporter` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `CssThemeExporter` (e.g. with `ColorExporter` and `.export_css_theme()`) actually correct?**
  _`CssThemeExporter` has 2 INFERRED edges - model-reasoned connections that need verification._