import os
import sys
from pathlib import Path

# Ensure absolute imports like `import config` resolve to nibras_installer/config.py
ROOT = Path(__file__).resolve().parents[1]
NIBRAS_DIR = ROOT / "nibras_installer"
if str(NIBRAS_DIR) not in sys.path:
    sys.path.insert(0, str(NIBRAS_DIR))

# Keep project root on sys.path for package imports
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

# Ensure tests don't read or write to the real HOME
os.environ.setdefault("HOME", str(ROOT / ".pytest_home"))
