import argparse
import json
import re
import sys
from typing import Any, Dict, List, Optional, Union

import prompt

from config import PRESETS, get_provider

try:
    from json_repair import repair_json

    HAS_JSON_REPAIR = True
except ImportError:
    HAS_JSON_REPAIR = False


def extract_and_clean_json(
    raw_text: str,
) -> Optional[Union[Dict[str, Any], List[Any]]]:
    if not raw_text:
        return None

    # 1. تنظيف أولي للنص من علامات المارك داون
    clean_text = re.sub(r"```json\s*", "", raw_text, flags=re.IGNORECASE)
    clean_text = re.sub(r"```\s*", "", clean_text).strip()

    # 2. البحث عن أول قوس مفتوح سواء كان كائن { أو مصفوفة [
    match = re.search(r"[\{\[]", clean_text)
    if not match:
        # إذا لم نجد أي أقواس، نجرب استدعاء json_repair على النص بأكمله كمحاولة أخيرة
        if HAS_JSON_REPAIR:
            try:
                return json.loads(repair_json(raw_text))
            except Exception:
                pass
        return None

    start_idx = match.start()
    start_char = match.group()
    # تحديد قوس الإغلاق المقابل بناءً على نوع البداية
    end_char = "}" if start_char == "{" else "]"

    balance = 0
    end_idx = -1

    # نبدأ البحث من أول قوس مفتوح ونعد التوازن للعثور على القوس المغلق الصحيح
    for i, char in enumerate(clean_text[start_idx:], start=start_idx):
        if char == start_char:
            balance += 1
        elif char == end_char:
            balance -= 1
            if balance == 0:
                end_idx = i
                break

    if end_idx != -1:
        potential_json = clean_text[start_idx : end_idx + 1]

        # محاولة التحليل (Parsing)
        try:
            if HAS_JSON_REPAIR:
                return json.loads(repair_json(potential_json))
            else:
                return json.loads(potential_json)
        except Exception:
            pass

    # إذا فشل الاستخراج الدقيق بالأقواس، نجرب الاستخراج الخام كمحاولة أخيرة
    try:
        if HAS_JSON_REPAIR:
            return json.loads(repair_json(raw_text))
    except Exception:
        pass

    return None


def get_fallback_response(language: str = "en") -> Dict[str, Any]:
    """رد احتياطي في حال فشل كل شيء لضمان عدم انهيار التطبيق"""
    msg = "I am seemingly speechless."
    if language and "Arabic" in language.lower():
        msg = "يبدو أنني عاجز عن الكلام حالياً."

    return {"reply": msg, "apply": False, "changes": [], "warnings": []}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--message", default=None)
    parser.add_argument("--message_key", default=None)
    parser.add_argument("--message_vars", default="{}")
    parser.add_argument("--api_key")
    parser.add_argument("--model")
    parser.add_argument("--preset", choices=PRESETS.keys(), default=None)
    parser.add_argument("--base_url", default=None)
    parser.add_argument("--history", default="[]")
    parser.add_argument("--system_instruction", default=None)
    parser.add_argument("--temperature", type=float, default=None)
    parser.add_argument("--json_mode", action="store_true")
    parser.add_argument(
        "--provider",
        choices=[
            "local",
            "gemini",
            "openrouter",
            "openai",
            "deepseek",
            "ollama",
        ],
        default=None,
    )
    parser.add_argument("--preferred_language", default="Arabic")
    parser.add_argument("--user_persona", default="You are Nibras")

    args = parser.parse_args()

    # الهيكل العام للمخرجات
    output: Dict[str, Any] = {
        "success": False,
        "response": None,
        "updated_history": [],
        "error": "",
    }

    try:
        # قراءة وتجهيز التاريخ الحالي
        try:
            history: List[Dict[str, str]] = json.loads(args.history)
        except Exception as e:
            print(
                f"[Warning] Failed to parse history JSON: {e}. Defaulting to empty list.",
                file=sys.stderr,
            )
            history = []

        # تجهيز الرسالة
        final_message = args.message
        if not final_message and args.message_key:
            try:
                message_vars = (
                    json.loads(args.message_vars) if args.message_vars else {}
                )
            except Exception as e:
                print(
                    f"[Warning] Failed to parse message_vars JSON: {e}. Defaulting to empty dict.",
                    file=sys.stderr,
                )
                message_vars = {}
            final_message = prompt.build_message(
                args.message_key, **message_vars
            )

        if not final_message:
            raise ValueError("Missing --message or invalid --message_key")

        final_system = args.system_instruction
        final_temp = args.temperature if args.temperature is not None else 0.7
        final_json_mode = args.json_mode

        # تطبيق الإعدادات المسبقة (Presets) إذا تم توفيرها
        if args.preset:
            preset_config = PRESETS[args.preset]
            if not final_system:
                final_system = preset_config.get("system_instruction")
            if args.temperature is None:
                final_temp = preset_config.get("temperature", final_temp)
            if preset_config.get("json_mode"):
                final_json_mode = True

        # الحصول على الـ Provider وتوليد الإجابة
        llm = get_provider(args, final_system, final_temp, final_json_mode)
        raw_response_text, _ = llm.generate(final_message, history)

        # تحضير الرد النهائي
        final_response_data = raw_response_text

        if final_json_mode:
            cleaned_obj = extract_and_clean_json(raw_response_text)
            if cleaned_obj is not None:
                final_response_data = cleaned_obj
            else:
                print(
                    f"JSON Parsing failed for: {raw_response_text}",
                    file=sys.stderr,
                )
                final_response_data = get_fallback_response(
                    args.preferred_language
                )

        # تحديث التاريخ قبل إرجاعه (إضافة دورة المحادثة الحالية)
        updated_history = list(history)
        updated_history.append({"role": "user", "content": final_message})
        updated_history.append(
            {"role": "assistant", "content": raw_response_text}
        )

        # ملء بيانات المخرجات بنجاح
        output["success"] = True
        output["response"] = final_response_data
        output["updated_history"] = updated_history

    except Exception as e:
        output["error"] = str(e)
        if args.json_mode:
            output["response"] = get_fallback_response(args.preferred_language)
        # الحفاظ على التاريخ القديم في حال حدوث خطأ
        output["updated_history"] = history

    # ensure_ascii=False يضمن ظهور الحروف العربية بشكل صحيح في الطرفية والملفات
    print(json.dumps(output, ensure_ascii=False))


if __name__ == "__main__":
    main()
