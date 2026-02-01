from base_provider import LLMProvider
from ollama import Client


class OllamaProvider(LLMProvider):
    def __init__(
        self,
        api_key,
        model,
        system_instruction=None,
        temperature=0.7,
        json_mode=False,
        base_url=None,
    ):
        super().__init__(
            api_key,
            model,
            system_instruction,
            temperature,
            json_mode,
        )

        # إذا لم يتم تمرير host، نستخدم الافتراضي
        self.host = base_url or "https://ollama.com"

        headers = {}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"

        self.client = Client(host=self.host, headers=headers)

    def generate(self, message, history):
        # تجهيز الرسائل (Messages List)
        messages = []

        # 1. إضافة تعليمات النظام
        if self.system_instruction:
            messages.append(
                {"role": "system", "content": self.system_instruction}
            )

        # 2. إضافة تاريخ المحادثة
        for msg in history:
            messages.append({"role": msg["role"], "content": msg["content"]})

        # 3. إضافة الرسالة الحالية
        messages.append({"role": "user", "content": message})

        try:
            # طلب التوليد من Ollama
            response = self.client.chat(
                model=self.model,
                messages=messages,
                options={
                    "temperature": self.temperature,
                },
                format="json" if self.json_mode else "",
                stream=False,  # يجب أن يكون False ليتوافق مع main.py
                # TODO: في المستقبل ادعم الرد المباشر
            )

            # استخراج النص
            content = response.message.content

            # إرجاع النص ومعلومات إضافية (Metadata)
            return content, {"model": self.model, "host": self.host}

        except Exception as e:
            # نرفع الاستثناء ليتم معالجته في main.py داخل الـ try-except الكبرى
            raise Exception(f"Ollama Error: {str(e)}")
