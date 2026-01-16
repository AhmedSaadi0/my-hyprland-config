import argparse
import json
import re

from config import PRESETS, get_provider

try:
    from json_repair import repair_json

    HAS_JSON_REPAIR = True
except ImportError:
    HAS_JSON_REPAIR = False


def extract_and_clean_json(raw_text):
    if not raw_text:
        return None

    # 1. تنظيف أولي للنص من علامات المارك داون
    clean_text = re.sub(r"```json\s*", "", raw_text, flags=re.IGNORECASE)
    clean_text = re.sub(r"```\s*", "", clean_text)

    # تنظيف المسافات الزائدة
    clean_text = clean_text.strip()

    # محاولة الاستخراج باستخدام المنطق الذكي للأقواس (Stack)
    # هذا يحل مشكلة النصوص المكررة في النهاية
    try:
        start_idx = clean_text.find("{")
        if start_idx == -1:
            return None  # لا يوجد بداية كائن

        balance = 0
        end_idx = -1

        # نبدأ البحث من أول قوس مفتوح ونعد التوازن للعثور على القوس المغلق الصحيح
        for i, char in enumerate(clean_text[start_idx:], start=start_idx):
            if char == "{":
                balance += 1
            elif char == "}":
                balance -= 1
                if balance == 0:
                    end_idx = i
                    break

        if end_idx != -1:
            potential_json = clean_text[start_idx : end_idx + 1]

            # json_repair إذا توفرت
            if HAS_JSON_REPAIR:
                return json.loads(repair_json(potential_json))
            else:
                # محاولة التنظيف اليدوية للرموز المخفية
                # استبدال سطر جديد داخل النصوص بمسافة لتجنب كسر الجيسون
                # هذه خطوة خطرة قليلاً لكنها ضرورية إذا كان الموديل يضع سطوراً جديدة
                return json.loads(potential_json)

    except Exception as e:
        # إذا فشل الاستخراج الدقيق، نجرب الاستخراج الخام كمحاولة أخيرة
        try:
            if HAS_JSON_REPAIR:
                return json.loads(repair_json(raw_text))
        except:
            pass

    return None


def get_fallback_response(language="en"):
    """رد احتياطي في حال فشل كل شيء لضمان عدم انهيار التطبيق"""
    msg = "I am seemingly speechless."
    if language and "Arabic" in language.lower():
        msg = "يبدو أنني عاجز عن الكلام حالياً."

    return {"emotion": "confused", "comment": msg}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--message", required=True)
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
        choices=["local", "gemini", "openrouter", "openai", "deepseek"],
        default=None,
    )
    parser.add_argument("--preferred_language", default="Arabic")
    parser.add_argument("--user_persona", default="You are Nibras")

    args = parser.parse_args()

    output = {"success": False, "response": None, "error": ""}

    try:
        final_system = args.system_instruction
        final_temp = args.temperature if args.temperature is not None else 0.7
        final_json_mode = args.json_mode

        if args.preset:
            preset_config = PRESETS[args.preset]
            if not final_system:
                final_system = preset_config["system_instruction"]
            if args.temperature is None:
                final_temp = preset_config["temperature"]
            if preset_config["json_mode"]:
                final_json_mode = True

        try:
            history = json.loads(args.history)
        except:
            history = []

        llm = get_provider(args, final_system, final_temp, final_json_mode)
        raw_response_text, _ = llm.generate(args.message, history)

        final_response_data = raw_response_text

        if final_json_mode:
            cleaned_obj = extract_and_clean_json(raw_response_text)

            if cleaned_obj is not None:
                final_response_data = cleaned_obj
            else:
                print(f"JSON Parsing failed for: {raw_response_text}")
                final_response_data = get_fallback_response(
                    args.preferred_language
                )

        output["success"] = True
        output["response"] = final_response_data
        output["updated_history"] = history

    except Exception as e:
        output["error"] = str(e)
        if args.json_mode:
            output["response"] = get_fallback_response(args.preferred_language)

    # ensure_ascii=False يضمن ظهور الحروف العربية بشكل صحيح
    print(json.dumps(output, ensure_ascii=False))


if __name__ == "__main__":
    main()
