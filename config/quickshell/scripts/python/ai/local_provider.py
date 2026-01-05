import requests
from base_provider import LLMProvider


class LocalProvider(LLMProvider):
    def generate(self, message, history):
        # 1. تجهيز قائمة الرسائل بدلاً من نص واحد
        # هذا يسمح للسيرفر بضبط التنسيق (ChatML) تلقائياً للمودل
        messages = []

        # إضافة تعليمات النظام
        if self.system_instruction:
            messages.append(
                {"role": "system", "content": self.system_instruction}
            )

        # إضافة التاريخ
        for h in history:
            role = h.get("role", "user")
            content = h.get("content", "")
            messages.append({"role": role, "content": content})

        # 2. إضافة رسالة المستخدم الحالية مع أمر منع التفكير
        # نضع الأمر داخل النص لكي يقرأه المودل كجزء من الطلب
        full_message = f"{message} /no_think"
        messages.append({"role": "user", "content": full_message})

        payload = {
            "messages": messages,  # نرسل القائمة بدلاً من "prompt"
            "temperature": self.temperature or 0.7,
            "top_p": 0.9,
            "max_tokens": 512,  # تم تغيير الاسم من n_predict إلى max_tokens حسب معايير OpenAI
            "stream": False,
        }

        try:
            # 3. تغيير الرابط إلى Endpoint المخصص للمحادثة
            response = requests.post(
                "http://127.0.0.1:8080/v1/chat/completions",
                json=payload,
            )
            response.raise_for_status()
            data = response.json()

            # استخراج النص من الهيكل الجديد
            text = data["choices"][0]["message"]["content"].strip()
            return text, {}

        except Exception as e:
            print(f"Error details: {e}")
            return f"[Local LLM Error] {e}", {}

    # لم نعد نحتاج دالة _build_prompt اليدوية
