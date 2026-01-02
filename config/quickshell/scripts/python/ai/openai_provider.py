from base_provider import LLMProvider
from openai import OpenAI


# -----------------------------------------------------------------------------
# 3. OpenAI/DeepSeek Provider
# -----------------------------------------------------------------------------
class OpenAIProvider(LLMProvider):
    def __init__(
        self,
        api_key,
        model,
        base_url=None,
        system_instruction=None,
        temperature=0.7,
        json_mode=False,
    ):
        super().__init__(
            api_key, model, system_instruction, temperature, json_mode
        )
        self.base_url = base_url

    def generate(self, message, history):
        client = OpenAI(api_key=self.api_key, base_url=self.base_url)

        messages = []
        if self.system_instruction:
            messages.append(
                {"role": "system", "content": self.system_instruction}
            )

        messages.extend(history)
        messages.append({"role": "user", "content": message})

        resp_format = {"type": "json_object"} if self.json_mode else None

        response = client.chat.completions.create(
            model=self.model,
            messages=messages,
            temperature=self.temperature,
            response_format=resp_format,
        )

        return response.choices[0].message.content, {}
