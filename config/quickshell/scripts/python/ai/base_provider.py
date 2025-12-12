from abc import ABC, abstractmethod


# -----------------------------------------------------------------------------
# 1. Base Class
# -----------------------------------------------------------------------------
class LLMProvider(ABC):
    def __init__(
        self,
        api_key,
        model,
        system_instruction=None,
        temperature=0.7,
        json_mode=False,
    ):
        self.api_key = api_key
        self.model = model
        self.system_instruction = system_instruction
        self.temperature = temperature
        self.json_mode = json_mode

    @abstractmethod
    def generate(self, message, history):
        pass
