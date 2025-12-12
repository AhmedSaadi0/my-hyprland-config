import argparse
import json

from config import PRESETS, get_provider


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

    # القيمة الافتراضية للرد ستكون نصاً فارغاً
    output = {"success": False, "response": None, "error": ""}

    try:
        # إعداد المتغيرات
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

        # التوليد
        llm = get_provider(args, final_system, final_temp, final_json_mode)
        raw_response_text, _ = llm.generate(args.message, history)

        # ---------------------------------------------------------
        # التعديل الهام هنا: تحويل النص إلى Object إذا كان JSON Mode
        # ---------------------------------------------------------
        final_response_data = raw_response_text  # الافتراضي: نص

        if final_json_mode:
            try:
                # تنظيف النص من علامات الماركداون
                clean_text = (
                    raw_response_text.replace("```json", "")
                    .replace("```", "")
                    .strip()
                )
                # تحويل النص إلى قاموس بايثون حقيقي (Dict)
                # هذا ما سيجعل المخرجات نظيفة وبدون \n \"
                final_response_data = json.loads(clean_text)
            except json.JSONDecodeError:
                # إذا فشل التحويل، نبقيها كنص كما هي لتظهر كخطأ أو محتوى عادي
                pass

        output["success"] = True
        output["response"] = final_response_data
        output["updated_history"] = history

    except Exception as e:
        output["error"] = str(e)

    # طباعة الجيسون النهائي
    print(json.dumps(output, ensure_ascii=False))


if __name__ == "__main__":
    main()
