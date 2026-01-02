import requests
from base_provider import LLMProvider


class LocalProvider(LLMProvider):
    def generate(self, message, history):
        prompt = self._build_prompt(message, history)

        payload = {
            "prompt": prompt,
            "temperature": self.temperature or 0.7,
            "top_p": 0.9,
            "n_predict": 512,
            "stop": ["</User>", "</System>"],
        }

        try:
            response = requests.post(
                "http://127.0.0.1:8080/completion", json=payload, timeout=60
            )
            response.raise_for_status()
            data = response.json()
            text = data.get("content", "").strip()
            return text, {}

        except Exception as e:
            return f"[Local LLM Error] {e}", {}

    def _build_prompt(self, message, history):
        prompt = ""

        if self.system_instruction:
            prompt += f"<System>\n{self.system_instruction}\n</System>\n"

        for h in history:
            role = h.get("role", "user")
            content = h.get("content", "")
            if role == "user":
                prompt += f"<User>\n{content}\n</User>\n"
            else:
                prompt += f"<Assistant>\n{content}\n</Assistant>\n"

        prompt += f"<User>\n{message}\n</User>\n<Assistant>\n"
        return prompt
