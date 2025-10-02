#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess
import shutil
from datetime import datetime
import sys

# --- تعريف ألوان للطباعة في الطرفية ---
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'

# --- قاموس يحتوي على كل النصوص باللغتين ---
MESSAGES = {
    "en": {
        "choose_lang": "Choose your language:",
        "main_menu_title": "NibrasShell Installation Script",
        "install_deps_menu": "1. Install Dependencies",
        "install_local": "2. Install NibrasShell (from this directory)",
        "uninstall": "3. Uninstall NibrasShell",
        "exit": "4. Exit",
        "choose_option": "Choose an option: ",
        "distro_check_fail": "Error: This script only supports Fedora and Arch Linux.",
        "installing_deps": "Installing dependencies...",
        "backing_up": "Backing up existing configurations...",
        "backup_created": "Backup created at:",
        "installing_nibrasshell": "Copying and setting up NibrasShell files...",
        "install_complete": "NibrasShell setup complete.",
        "reboot_prompt": "It is recommended to reboot your system.",
        "uninstall_prompt": "Are you sure you want to uninstall NibrasShell? (y/n) ",
        "uninstalling": "Uninstalling NibrasShell...",
        "restore_prompt": "Do you want to restore the latest backup? (y/n) ",
        "restoring_backup": "Restoring backup from:",
        "uninstall_complete": "NibrasShell has been uninstalled.",
        "no_backup_found": "No backup found to restore.",
        "invalid_option": "Invalid option, please try again.",
        "deps_menu_title": "Dependency Installation Menu",
        "install_required_only": "1. Install Required Dependencies Only",
        "install_all_deps": "2. Install All (Required + Optional) Dependencies",
    },
    "ar": {
        "choose_lang": "اختر لغتك:",
        "main_menu_title": "سكربت تثبيت NibrasShell",
        "install_deps_menu": "1. تثبيت المتطلبات",
        "install_local": "2. تثبيت الواجهة (من هذا المجلد)",
        "uninstall": "3. حذف الواجهة",
        "exit": "4. خروج",
        "choose_option": "اختر أحد الخيارات: ",
        "distro_check_fail": "خطأ: هذا السكربت يدعم فقط توزيعات فيدورا وآرش لينكس.",
        "installing_deps": "جاري تثبيت المتطلبات...",
        "backing_up": "جاري أخذ نسخة احتياطية من الإعدادات الحالية...",
        "backup_created": "تم إنشاء النسخة الاحتياطية في:",
        "installing_nibrasshell": "جاري نسخ وإعداد ملفات NibrasShell...",
        "install_complete": "اكتمل إعداد NibrasShell.",
        "reboot_prompt": "يوصى بإعادة تشغيل النظام.",
        "uninstall_prompt": "هل أنت متأكد أنك تريد حذف NibrasShell؟ (ن/ل) ",
        "uninstalling": "جاري حذف NibrasShell...",
        "restore_prompt": "هل تريد استعادة آخر نسخة احتياطية؟ (ن/ل) ",
        "restoring_backup": "جاري استعادة النسخة الاحتياطية من:",
        "uninstall_complete": "تم حذف NibrasShell.",
        "no_backup_found": "لم يتم العثور على نسخة احتياطية.",
        "invalid_option": "خيار غير صالح، يرجى المحاولة مرة أخرى.",
        "deps_menu_title": "قائمة تثبيت المتطلبات",
        "install_required_only": "1. تثبيت المتطلبات الضرورية فقط",
        "install_all_deps": "2. تثبيت كل المتطلبات (الضرورية والاختيارية)",
    }
}

LANG = "en"

def msg(key):
    return MESSAGES[LANG][key]

def run_command(command):
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"{RED}Error executing command: {command}{NC}")
        sys.exit(1)

def detect_distro():
    if os.path.exists("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("ID="):
                    return line.strip().split("=")[1].lower().strip('"')
    return None

def install_dependencies(distro, install_optional=False):
    print(f"{YELLOW}{msg('installing_deps')}{NC}")

    if distro == "arch":
        required_pkgs = "base-devel brightnessctl network-manager-applet konsole dolphin playerctl polkit-kde-agent jq gammastep wl-clipboard hyprpicker hyprshot-git bc sysstat sassc systemsettings acpi fish kde-material-you-colors power-profiles-daemon swww python-regex copyq quickshell ttf-fantasque-sans-mono-nerd"
        optional_pkgs = "blueman ark ffmpegthumbs kvantum gufw tar easyeffects kitty plasma5support plasma5-integration plasma-framework5 ttf-jetbrains-mono-nerd powerdevil libjpeg6-turbo orchis-theme-git discord firefox visual-studio-code-bin nwg-look-bin qt5ct telegram-desktop strawberry"
        command = f"yay -S --needed {required_pkgs}"
        if install_optional:
            command += f" {optional_pkgs}"
        run_command(command)

    elif distro == "fedora":
        print(YELLOW + "Enabling RPM Fusion and COPR repositories..." + NC)
        run_command("sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm")
        run_command("sudo dnf copr enable -y solopasha/hyprland")
        run_command("sudo dnf copr enable -y errornointernet/quickshell")
        run_command("sudo dnf copr enable -y luisbocanegra/kde-material-you-colors")

        run_command("sudo dnf install -y hyprland quickshell kde-material-you-colors")

        required_pkgs = "plasma-nm playerctl polkit-kde dolphin konsole brightnessctl gammastep wl-clipboard sysstat bc sassc plasma-systemsettings acpi fish gnome-bluetooth-libs power-profiles-daemon lm_sensors copyq vnstat nethogs"
        optional_pkgs = "strawberry easyeffects blueman telegram-desktop discord kvantum firefox"

        command = f"sudo dnf install -y {required_pkgs}"
        if install_optional:
            command += f" {optional_pkgs}"

        print(YELLOW + "Installing main packages..." + NC)
        run_command(command)

    print(f"{GREEN}Dependencies installed successfully.{NC}")

def backup_configs():
    print(f"{YELLOW}{msg('backing_up')}{NC}")
    home_dir = os.path.expanduser("~")
    config_dir = os.path.join(home_dir, ".config")
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    backup_dir = os.path.join(config_dir, "nibrasshell_backups", f"backup-{timestamp}")
    os.makedirs(backup_dir, exist_ok=True)

    configs_to_backup = ["hypr", "quickshell", "easyeffects"]
    fish_config_path = os.path.join(config_dir, "fish", "config.fish")

    for config in configs_to_backup:
        src = os.path.join(config_dir, config)
        if os.path.exists(src):
            shutil.move(src, os.path.join(backup_dir, config))

    if os.path.exists(fish_config_path):
        os.makedirs(os.path.join(backup_dir, "fish"), exist_ok=True)
        shutil.copy(fish_config_path, os.path.join(backup_dir, "fish", "config.back.fish"))

    print(f"{GREEN}{msg('backup_created')} {backup_dir}{NC}")

def install_nibrasshell():
    backup_configs()

    print(f"{YELLOW}{msg('installing_nibrasshell')}{NC}")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    home_dir = os.path.expanduser("~")
    config_dir = os.path.join(home_dir, ".config")
    hypr_dest_dir = os.path.join(config_dir, "hypr")

    shutil.copytree(script_dir, hypr_dest_dir, dirs_exist_ok=True)

    shutil.copytree(os.path.join(hypr_dest_dir, "config", "quickshell"), os.path.join(config_dir, "quickshell"), dirs_exist_ok=True)
    shutil.copytree(os.path.join(hypr_dest_dir, "config", "easyeffects"), os.path.join(config_dir, "easyeffects"), dirs_exist_ok=True)

    os.makedirs(os.path.join(config_dir, "fish"), exist_ok=True)
    shutil.copy(os.path.join(hypr_dest_dir, "config", "config.fish"), os.path.join(config_dir, "fish", "config.fish"))

    run_command(f"chmod +x {hypr_dest_dir}/scripts/*")
    run_command(f"chmod +x {config_dir}/quickshell/scripts/*")

    installer_in_dest = os.path.join(hypr_dest_dir, os.path.basename(__file__))
    if os.path.exists(installer_in_dest):
        os.remove(installer_in_dest)

    print(f"{GREEN}{msg('install_complete')}{NC}")
    print(f"{YELLOW}{msg('reboot_prompt')}{NC}")

def uninstall_nibrasshell():
    confirm = input(f"{YELLOW}{msg('uninstall_prompt')}{NC}").lower()
    if confirm in ['y', 'yes', 'ن', 'نعم']:
        print(f"{YELLOW}{msg('uninstalling')}{NC}")
        home_dir = os.path.expanduser("~")
        config_dir = os.path.join(home_dir, ".config")

        for d in ["hypr", "quickshell", "easyeffects"]:
            path = os.path.join(config_dir, d)
            if os.path.exists(path):
                shutil.rmtree(path)

        restore_confirm = input(f"{YELLOW}{msg('restore_prompt')}{NC}").lower()
        if restore_confirm in ['y', 'yes', 'ن', 'نعم']:
            backup_base_dir = os.path.join(config_dir, "nibrasshell_backups")
            if os.path.exists(backup_base_dir) and os.listdir(backup_base_dir):
                all_backups = sorted(os.listdir(backup_base_dir), reverse=True)
                latest_backup_dir = os.path.join(backup_base_dir, all_backups[0])
                print(f"{YELLOW}{msg('restoring_backup')} {latest_backup_dir}{NC}")

                for item in os.listdir(latest_backup_dir):
                    src_path = os.path.join(latest_backup_dir, item)
                    dest_path = os.path.join(config_dir, item)
                    if os.path.isdir(src_path):
                        shutil.copytree(src_path, dest_path, dirs_exist_ok=True)
            else:
                print(f"{RED}{msg('no_backup_found')}{NC}")
        print(f"{GREEN}{msg('uninstall_complete')}{NC}")

def show_dependency_menu():
    distro = detect_distro()
    if distro not in ["arch", "fedora"]:
        print(f"{RED}{msg('distro_check_fail')}{NC}")
        return

    print("\n" + "="*30)
    print(f"{GREEN}{msg('deps_menu_title')}{NC}")
    print("="*30)
    print(msg('install_required_only'))
    print(msg('install_all_deps'))

    choice = input(f"{YELLOW}{msg('choose_option')}{NC}")
    if choice == '1':
        install_dependencies(distro, install_optional=False)
    elif choice == '2':
        install_dependencies(distro, install_optional=True)
    else:
        print(f"{RED}{msg('invalid_option')}{NC}")

def check_for_root():
    """[جديد] دالة للتحقق إذا كان السكربت يعمل بصلاحيات root"""
    if os.geteuid() == 0:
        print(f"{RED}Error: Do not run this script with sudo or as the root user.{NC}")
        print(f"{YELLOW}Please run it as your normal user: python3 install.py{NC}")
        print(f"{YELLOW}The script will ask for your password when it needs it.{NC}")
        print("\n--- العربية ---\n")
        print(f"{RED}خطأ: لا تقم بتشغيل هذا السكربت باستخدام sudo أو كمستخدم root.{NC}")
        print(f"{YELLOW}يرجى تشغيله كمستخدمك العادي: python3 install.py{NC}")
        print(f"{YELLOW}سيقوم السكربت بطلب كلمة المرور عند الحاجة فقط.{NC}")
        sys.exit(1)

def main():
    check_for_root() # <-- [جديد] استدعاء دالة التحقق في البداية

    global LANG
    print(f"{GREEN}Choose your language / اختر لغتك:{NC}")
    print("1. English")
    print("2. العربية")
    lang_choice = input("> ")
    if lang_choice == "2":
        LANG = "ar"

    while True:
        print("\n" + "="*45)
        print(f"{GREEN}{msg('main_menu_title')}{NC}")
        print("="*45)
        print(msg('install_deps_menu'))
        print(msg('install_local'))
        print(msg('uninstall'))
        print(msg('exit'))

        choice = input(f"{YELLOW}{msg('choose_option')}{NC}")

        if choice == '1':
            show_dependency_menu()
        elif choice == '2':
            install_nibrasshell()
        elif choice == '3':
            uninstall_nibrasshell()
        elif choice == '4':
            break
        else:
            print(f"{RED}{msg('invalid_option')}{NC}")

if __name__ == "__main__":
    main()
