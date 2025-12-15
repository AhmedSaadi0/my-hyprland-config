import argparse
import json
import re

from config import PRESETS, get_provider


def extract_and_clean_json(raw_text):
    if not raw_text:
        return None

    try:
        # 1. إزالة علامات المارك داون الصريحة أولاً
        clean_text = re.sub(r"```json\s*", "", raw_text, flags=re.IGNORECASE)
        clean_text = re.sub(r"```\s*", "", clean_text)

        # 2. البحث عن أول قوس '{' وآخر قوس '}'
        # هذا يتجاهل أي نصوص ثرثرة (Chatter) قبل أو بعد الكود
        start_idx = clean_text.find("{")
        end_idx = clean_text.rfind("}")

        if start_idx != -1 and end_idx != -1:
            # قص النص ليكون من البداية للنهاية الصحيحة فقط
            json_str = clean_text[start_idx : end_idx + 1]

            # 3. محاولة التحويل إلى كائن بايثون
            return json.loads(json_str)
        else:
            return None

    except Exception:
        return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--api_key", required=True)
    parser.add_argument("--model", required=True)
    parser.add_argument("--message", required=True)
    parser.add_argument("--preset", choices=PRESETS.keys(), default=None)
    parser.add_argument("--base_url", default=None)
    parser.add_argument("--history", default="[]")
    parser.add_argument("--system_instruction", default=None)
    parser.add_argument("--temperature", type=float, default=None)
    parser.add_argument("--json_mode", action="store_true")
    parser.add_argument(
        "--provider", choices=["gemini", "openai", "deepseek"], default=None
    )
    parser.add_argument("--preferred_language", default=None)

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
                pass

        output["success"] = True
        output["response"] = final_response_data
        output["updated_history"] = history

    except Exception as e:
        output["error"] = str(e)

    # ensure_ascii=False يضمن ظهور الحروف العربية بشكل صحيح وليس رموزاً
    print(json.dumps(output, ensure_ascii=False))


if __name__ == "__main__":
    main()
