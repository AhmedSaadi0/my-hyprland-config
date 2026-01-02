# modules/utils.py
import os
import subprocess
import sys

from config import NC, RED, YELLOW


def run_command(command, exit_on_fail=True):
    try:
        subprocess.run(
            command,
            check=True,
            shell=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
        )
    except subprocess.CalledProcessError as e:
        print(
            f"{RED}Error executing command: {command}\n{e.stderr.decode()}{NC}"
        )
        if exit_on_fail:
            sys.exit(1)


def run_command_verbose(command):
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError:
        print(f"{RED}Error executing command: {command}{NC}")
        sys.exit(1)


def detect_distro():
    if os.path.exists("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("ID="):
                    return line.strip().split("=")[1].lower().strip('"')
    return None


def is_arch_based():
    try:
        with open("/etc/os-release", "r") as f:
            lines = f.readlines()

        os_info = {
            k.strip(): v.strip().strip('"')
            for k, v in (line.split("=", 1) for line in lines if "=" in line)
        }

        if os_info.get("ID") == "arch":
            return True
        if "arch" in os_info.get("ID_LIKE", "").split():
            return True
    except FileNotFoundError:
        return False
    return False


def check_for_root():
    if os.geteuid() == 0:
        print(
            f"{RED}Error: Do not run this script with sudo or as the root user.{NC}"
        )
        print(
            f"{YELLOW}Please run it as your normal user: python3 main.py{NC}"
        )
        sys.exit(1)
