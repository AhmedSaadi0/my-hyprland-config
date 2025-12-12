import google.generativeai as genai
from base_provider import LLMProvider


# --------------------------------------------------------------------------
# 2. Gemini Provider
# -----------------------------------------------------------------------------
class GeminiProvider(LLMProvider):
    def generate(self, message, history):
        genai.configure(api_key=self.api_key)

        mime_type = "application/json" if self.json_mode else "text/plain"

        generation_config = genai.types.GenerationConfig(
            temperature=self.temperature, response_mime_type=mime_type
        )

        gemini_history = []
        for msg in history:
            role = "model" if msg["role"] == "assistant" else "user"
            gemini_history.append({"role": role, "parts": [msg["content"]]})

        model = genai.GenerativeModel(
            model_name=self.model,
            system_instruction=self.system_instruction,
            generation_config=generation_config,
        )

        chat = model.start_chat(history=gemini_history)
        response = chat.send_message(message)
        return response.text, {}
