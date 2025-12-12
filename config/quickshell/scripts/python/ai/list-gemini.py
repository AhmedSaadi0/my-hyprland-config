import argparse
import json

import google.generativeai as genai


def main():
    parser = argparse.ArgumentParser(
        description="List available Gemini models"
    )
    parser.add_argument(
        "--api_key", required=True, help="Google Gemini API Key"
    )

    args = parser.parse_args()

    result = {"success": False, "models": [], "error": ""}

    try:
        genai.configure(api_key=args.api_key)

        # جلب كل المودلات المتاحة
        all_models = genai.list_models()

        for m in all_models:
            # نحن نهتم فقط بالمودلات التي تدعم توليد المحتوى (Chat)
            if "generateContent" in m.supported_generation_methods:
                model_info = {
                    "name": m.name.replace(
                        "models/", ""
                    ),  # إزالة البادئة لتسهيل الاستخدام
                    "display_name": m.display_name,
                    "description": m.description,
                    "input_token_limit": m.input_token_limit,
                    "output_token_limit": m.output_token_limit,
                    "temperature_support": True,  # افتراضياً أغلبها يدعم
                }
                result["models"].append(model_info)

        result["success"] = True

    except Exception as e:
        result["error"] = str(e)

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
