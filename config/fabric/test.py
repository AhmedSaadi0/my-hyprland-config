import gi

try:
    gi.require_version("Cvc", "1.0")
    from gi.repository import Cvc

    print("Cvc import successful!")
except Exception as e:
    print(f"Cvc import failed: {e}")
