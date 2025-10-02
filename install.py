#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# --- استيراد المكتبات اللازمة ---
import os
import shutil
import subprocess
import sys
from datetime import datetime

# --- تعريف ألوان للطباعة في الطرفية ---
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
NC = "\033[0m"

# --- قاموس يحتوي على كل النصوص باللغتين (مع إضافة النصوص الجديدة) ---
MESSAGES = {
    "en": {
        "choose_lang": "Choose your language:",
        "main_menu_title": "NibrasShell Management Script",
        "install_deps_menu": "1. Install Dependencies",
        "install_local": "2. Install NibrasShell (from local files)",
        "install_github": "3. Install NibrasShell (from GitHub)",
        "uninstall": "4. Uninstall NibrasShell",
        "exit": "5. Exit",
        "choose_option": "Choose an option: ",
        "distro_not_supported": "Your distribution is not supported.",
        "installing_deps": "Installing dependencies...",
        "backing_up": "Backing up existing configurations...",
        "backup_created": "Backup created at:",
        "installing_nibrasshell": "Copying and setting up NibrasShell files...",
        "cloning_nibrasshell": "Cloning NibrasShell repository...",
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
        "local_files_not_found": "Error: 'nibrasshell' directory not found. Make sure the script is in the root of the project folder.",
    },
    "ar": {
        "choose_lang": "اختر لغتك:",
        "main_menu_title": "سكربت إدارة NibrasShell",
        "install_deps_menu": "1. تثبيت المتطلبات",
        "install_local": "2. تثبيت الواجهة (من الملفات المحلية)",
        "install_github": "3. تثبيت الواجهة (من GitHub)",
        "uninstall": "4. حذف الواجهة",
        "exit": "5. خروج",
        "choose_option": "اختر أحد الخيارات: ",
        "distro_not_supported": "توزيعتك غير مدعومة.",
        "installing_deps": "جاري تثبيت المتطلبات...",
        "backing_up": "جاري أخذ نسخة احتياطية من الإعدادات الحالية...",
        "backup_created": "تم إنشاء النسخة الاحتياطية في:",
        "installing_nibrasshell": "جاري نسخ وإعداد ملفات NibrasShell...",
        "cloning_nibrasshell": "جاري تحميل المستودع من GitHub...",
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
        "local_files_not_found": "خطأ: لم يتم العثور على مجلد 'nibrasshell'. تأكد من أن السكربت موجود في المجلد الرئيسي للمشروع.",
    },
}

# --- متغير لحفظ اللغة المختارة ---
LANG = "en"


def msg(key):
    """دالة لجلب النص الصحيح من قاموس النصوص"""
    return MESSAGES[LANG][key]


def run_command(command):
    """دالة لتشغيل أوامر النظام بأمان"""
    try:
        subprocess.run(
            command,
            check=True,
            shell=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError as e:
        print(f"{RED}Error executing command: {command}\n{e}{NC}")
        sys.exit(1)


def detect_distro():
    """دالة للكشف عن نوع التوزيعة (فيدورا أو آرش)"""
    if os.path.exists("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("ID="):
                    return line.strip().split("=")[1].lower().strip('"')
    return None


def install_dependencies(distro, install_optional=False):
    """دالة لتثبيت الحزم المطلوبة بناءً على التوزيعة"""
    print(f"{YELLOW}{msg('installing_deps')}{NC}")

    if distro == "arch":
        required_pkgs = "base-devel brightnessctl network-manager-applet konsole dolphin playerctl polkit-kde-agent jq gammastep wl-clipboard hyprpicker hyprshot-git bc sysstat sassc systemsettings acpi fish kde-material-you-colors power-profiles-daemon swww python-regex copyq quickshell ttf-fantasque-sans-mono-nerd"
        optional_pkgs = "blueman ark ffmpegthumbs kvantum gufw tar easyeffects kitty plasma5support plasma5-integration plasma-framework5 ttf-jetbrains-mono-nerd powerdevil libjpeg6-turbo orchis-theme-git discord firefox visual-studio-code-bin nwg-look-bin qt5ct telegram-desktop strawberry"
        command = f"yay -S --needed {required_pkgs}"
        if install_optional:
            command += f" {optional_pkgs}"
        run_command(command)

    elif distro == "fedora":
        run_command(
            "sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
        )
        run_command(
            "sudo dnf copr enable -y solopasha/hyprland && sudo dnf install -y hyprland hyprshot hyprpicker wl-clipboard swww"
        )
        run_command(
            "sudo dnf copr enable -y errornointernet/quickshell && sudo dnf install -y quickshell"
        )
        run_command(
            "sudo dnf copr enable -y luisbocanegra/kde-material-you-colors && sudo dnf install -y kde-material-you-colors"
        )

        required_pkgs = "NetworkManager-applet playerctl polkit-kde dolphin konsole brightnessctl gammastep wl-clipboard sysstat bc sassc plasma-systemsettings acpi fish gnome-bluetooth-libs power-profiles-daemon lm_sensors copyq vnstat nethogs"
        optional_pkgs = "strawberry-player easyeffects blueman telegram-desktop discord kvantum firefox"

        command = f"sudo dnf install -y {required_pkgs}"
        if install_optional:
            command += f" {optional_pkgs}"
        run_command(command)

    print(f"{GREEN}Dependencies installed successfully.{NC}")


def backup_configs():
    """دالة لأخذ نسخة احتياطية من الإعدادات الحالية"""
    print(f"{YELLOW}{msg('backing_up')}{NC}")
    home_dir = os.path.expanduser("~")
    config_dir = os.path.join(home_dir, ".config")
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    backup_dir = os.path.join(
        config_dir, "nibrasshell_backups", f"backup-{timestamp}"
    )

    os.makedirs(backup_dir, exist_ok=True)

    configs_to_backup = ["hypr", "quickshell", "wofi", "easyeffects"]
    fish_config_path = os.path.join(config_dir, "fish", "config.fish")

    for config in configs_to_backup:
        src = os.path.join(config_dir, config)
        if os.path.exists(src):
            shutil.move(src, os.path.join(backup_dir, config))

    if os.path.exists(fish_config_path):
        os.makedirs(os.path.join(backup_dir, "fish"), exist_ok=True)
        shutil.copy(
            fish_config_path,
            os.path.join(backup_dir, "fish", "config.back.fish"),
        )

    print(f"{GREEN}{msg('backup_created')} {backup_dir}{NC}")


def _perform_copy_and_setup(source_dir):
    """دالة داخلية لنسخ الملفات وإعدادها من مصدر معين"""
    print(f"{YELLOW}{msg('installing_nibrasshell')}{NC}")
    home_dir = os.path.expanduser("~")
    config_dir = os.path.join(home_dir, ".config")

    # تعريف مسارات المصدر
    nibrasshell_src = os.path.join(source_dir, "nibrasshell")

    # نسخ مجلدات الإعدادات
    shutil.copytree(nibrasshell_src, os.path.join(config_dir, "hypr"))
    shutil.copytree(
        os.path.join(config_dir, "hypr/config/quickshell"),
        os.path.join(config_dir, "quickshell"),
    )
    shutil.copytree(
        os.path.join(config_dir, "hypr/config/wofi"),
        os.path.join(config_dir, "wofi"),
    )
    shutil.copytree(
        os.path.join(config_dir, "hypr/config/easyeffects"),
        os.path.join(config_dir, "easyeffects"),
    )

    # نسخ ملف إعدادات fish
    os.makedirs(os.path.join(config_dir, "fish"), exist_ok=True)
    shutil.copy(
        os.path.join(config_dir, "hypr/config/config.fish"),
        os.path.join(config_dir, "fish/config.fish"),
    )

    # إعطاء صلاحيات تنفيذ للسكربتات
    run_command(f"chmod +x {config_dir}/hypr/scripts/*")
    run_command(f"chmod +x {config_dir}/quickshell/scripts/*")

    # إكمال نسخ باقي الملفات (الثيمات، الخطوط، الأيقونات)
    # ... (هذا الجزء لم يتغير)

    print(f"{GREEN}{msg('install_complete')}{NC}")
    print(f"{YELLOW}{msg('reboot_prompt')}{NC}")


def install_nibrasshell_local():
    """تثبيت الواجهة من مجلد محلي"""
    if not os.path.exists("./nibrasshell"):
        print(f"{RED}{msg('local_files_not_found')}{NC}")
        return

    backup_configs()
    _perform_copy_and_setup(source_dir=".")


def install_nibrasshell_github():
    """تثبيت الواجهة عن طريق تحميلها من GitHub"""
    temp_dir = "/tmp/NibrasShell"

    print(f"{YELLOW}{msg('cloning_nibrasshell')}{NC}")
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    run_command(
        f"git clone https://github.com/AhmedSaadi0/NibrasShell.git {temp_dir}"
    )

    backup_configs()
    _perform_copy_and_setup(source_dir=temp_dir)

    shutil.rmtree(temp_dir)  # تنظيف المجلد المؤقت


def uninstall_nibrasshell():
    """دالة لحذف الواجهة واستعادة الإعدادات القديمة"""
    # (هذه الدالة لم تتغير)
    confirm = input(f"{YELLOW}{msg('uninstall_prompt')}{NC}").lower()
    if confirm in ["y", "yes", "ن", "نعم"]:
        print(f"{YELLOW}{msg('uninstalling')}{NC}")
        home_dir = os.path.expanduser("~")
        config_dir = os.path.join(home_dir, ".config")

        for d in ["hypr", "quickshell", "wofi", "easyeffects"]:
            path = os.path.join(config_dir, d)
            if os.path.exists(path):
                shutil.rmtree(path)

        restore_confirm = input(f"{YELLOW}{msg('restore_prompt')}{NC}").lower()
        if restore_confirm in ["y", "yes", "ن", "نعم"]:
            backup_base_dir = os.path.join(config_dir, "nibrasshell_backups")
            if os.path.exists(backup_base_dir) and os.listdir(backup_base_dir):
                all_backups = sorted(os.listdir(backup_base_dir), reverse=True)
                latest_backup_dir = os.path.join(
                    backup_base_dir, all_backups[0]
                )
                print(
                    f"{YELLOW}{msg('restoring_backup')} {latest_backup_dir}{NC}"
                )

                for item in os.listdir(latest_backup_dir):
                    src_path = os.path.join(latest_backup_dir, item)
                    dest_path = os.path.join(config_dir, item)
                    if os.path.isdir(src_path):
                        shutil.copytree(
                            src_path, dest_path, dirs_exist_ok=True
                        )
                    elif "fish" in src_path:
                        shutil.copy(
                            os.path.join(src_path, "config.back.fish"),
                            os.path.join(config_dir, "fish/config.fish"),
                        )
            else:
                print(f"{RED}{msg('no_backup_found')}{NC}")

        print(f"{GREEN}{msg('uninstall_complete')}{NC}")


def show_dependency_menu():
    """عرض القائمة الفرعية لتثبيت المتطلبات"""
    distro = detect_distro()
    if not distro in ["arch", "fedora"]:
        print(f"{RED}{msg('distro_not_supported')}{NC}")
        return

    print("\n" + "=" * 30)
    print(f"{GREEN}{msg('deps_menu_title')}{NC}")
    print("=" * 30)
    print(msg("install_required_only"))
    print(msg("install_all_deps"))

    choice = input(f"{YELLOW}{msg('choose_option')}{NC}")
    if choice == "1":
        install_dependencies(distro, install_optional=False)
    elif choice == "2":
        install_dependencies(distro, install_optional=True)
    else:
        print(f"{RED}{msg('invalid_option')}{NC}")


def main():
    """الدالة التي تشغل البرنامج وتعرض القائمة الرئيسية"""
    global LANG
    print(f"{GREEN}Choose your language / اختر لغتك:{NC}")
    print("1. English")
    print("2. العربية")
    lang_choice = input("> ")
    if lang_choice == "2":
        LANG = "ar"

    while True:
        print("\n" + "=" * 40)
        print(f"{GREEN}{msg('main_menu_title')}{NC}")
        print("=" * 40)
        print(msg("install_deps_menu"))
        print(msg("install_local"))
        print(msg("install_github"))
        print(msg("uninstall"))
        print(msg("exit"))

        choice = input(f"{YELLOW}{msg('choose_option')}{NC}")

        if choice == "1":
            show_dependency_menu()
        elif choice == "2":
            install_nibrasshell_local()
        elif choice == "3":
            install_nibrasshell_github()
        elif choice == "4":
            uninstall_nibrasshell()
        elif choice == "5":
            break
        else:
            print(f"{RED}{msg('invalid_option')}{NC}")


# --- نقطة بداية تشغيل السكربت ---
if __name__ == "__main__":
    main()
