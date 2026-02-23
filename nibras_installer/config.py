# config.py
import os

# تعريف الألوان
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
NC = "\033[0m"  # No Color

# تحديد المسار الجذري للمشروع (مجلد الريبو الذي يحتوي على config/ و scripts/)
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
