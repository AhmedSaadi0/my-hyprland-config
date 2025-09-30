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

# --- قاموس يحتوي على كل النصوص باللغتين ---
MESSAGES = {
    "en": {
        "choose_lang": "Choose your language:",
        "main_menu_title": "NibrasShell Management Script",
        "install": "Install NibrasShell",
        "uninstall": "Uninstall NibrasShell",
        "exit": "Exit",
        "choose_option": "Choose an option: ",
        "distro_not_supported": "Your distribution is not supported.",
        "installing_deps": "Installing dependencies...",
        "backing_up": "Backing up existing configurations...",
        "backup_created": "Backup created at:",
        "installing_nibrasshell": "Cloning and installing NibrasShell...",
        "install_complete": "NibrasShell installation complete. Please reboot your system.",
        "uninstall_prompt": "Are you sure you want to uninstall NibrasShell? (y/n) ",
        "uninstalling": "Uninstalling NibrasShell...",
        "restore_prompt": "Do you want to restore the latest backup? (y/n) ",
        "restoring_backup": "Restoring backup from:",
        "uninstall_complete": "NibrasShell has been uninstalled.",
        "no_backup_found": "No backup found to restore.",
        "invalid_option": "Invalid option, please try again.",
    },
    "ar": {
        "choose_lang": "اختر لغتك:",
        "main_menu_title": "سكربت إدارة NibrasShell",
        "install": "تثبيت NibrasShell",
        "uninstall": "حذف NibrasShell",
        "exit": "خروج",
        "choose_option": "اختر أحد الخيارات: ",
        "distro_not_supported": "توزيعتك غير مدعومة.",
        "installing_deps": "جاري تثبيت المتطلبات...",
        "backing_up": "جاري أخذ نسخة احتياطية من الإعدادات الحالية...",
        "backup_created": "تم إنشاء النسخة الاحتياطية في:",
        "installing_nibrasshell": "جاري تحميل وتثبيت NibrasShell...",
        "install_complete": "اكتمل تثبيت NibrasShell. يرجى إعادة تشغيل النظام.",
        "uninstall_prompt": "هل أنت متأكد أنك تريد حذف NibrasShell؟ (ن/ل) ",
        "uninstalling": "جاري حذف NibrasShell...",
        "restore_prompt": "هل تريد استعادة آخر نسخة احتياطية؟ (ن/ل) ",
        "restoring_backup": "جاري استعادة النسخة الاحتياطية من:",
        "uninstall_complete": "تم حذف NibrasShell.",
        "no_backup_found": "لم يتم العثور على نسخة احتياطية.",
        "invalid_option": "خيار غير صالح، يرجى المحاولة مرة أخرى.",
    },
}

# --- متغير لحفظ اللغة المختارة ---
LANG = "en"


def msg(key):
    """دالة لجلب النص الصحيح من قاموس النصوص"""
    return MESSAGES[LANG][key]


def run_command(command, capture_output=False, text=False):
    """دالة لتشغيل أوامر النظام بأمان"""
    try:
        return subprocess.run(
            command,
            check=True,
            shell=True,
            capture_output=capture_output,
            text=text,
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


def install_dependencies_arch():
    """دالة لتثبيت الحزم المطلوبة لآرش لينكس"""
    print(f"{YELLOW}{msg('installing_deps')}{NC}")
    packages = "base-devel brightnessctl network-manager-applet konsole blueman ark dolphin ffmpegthumbs playerctl kvantum polkit-kde-agent jq gufw tar gammastep wl-clipboard easyeffects hyprpicker hyprshot-git bc sysstat kitty sassc systemsettings acpi fish kde-material-you-colors plasma5support plasma5-integration plasma-framework5 ttf-jetbrains-mono-nerd ttf-fantasque-sans-mono-nerd powerdevil power-profiles-daemon libjpeg6-turbo swww python-regex copyq quickshell"
    run_command(f"yay -S --needed {packages}")


def install_dependencies_fedora():
    """دالة لتثبيت الحزم المطلوبة لفيدورا"""
    print(f"{YELLOW}{msg('installing_deps')}{NC}")
    run_command(
        "sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    )
    run_command("sudo dnf install -y ffmpeg --allowerasing")
    packages = "lsp-plugins calf rubberband zam-plugins breeze-gtk-gtk4 breeze-gtk-gtk3 kde-connect ffmpegthumbs bluedevil kde-gtk-config kde-settings-pulseaudio kdebugsettings kdenetwork-filesharing kdeplasma-addons plasma-nm plasma-systemmonitor plasma-vault sddm-breeze xwaylandvideobridge NetworkManager-l2tp NetworkManager-libreswan kde-settings-sddm kde-connect-libs imsettings imsettings-libs sddm network-manager-applet playerctl brightnessctl gammastep sysstat sassc plasma-systemsettings acpi fish gnome-bluetooth lm_sensors easyeffects blueman telegram-desktop kvantum konsole pulseaudio-utils polkit-qt polkit-kde gstreamer1-libav strawberry dnf-plugins-core gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld ffmpeg gstreamer1-plugins-base-devel vnstat nethogs copyq jq"
    run_command(f"sudo dnf install -y {packages}")
    run_command(
        "sudo dnf copr enable -y solopasha/hyprland && sudo dnf install -y hyprland hyprshot hyprpicker wl-clipboard swww"
    )
    run_command(
        "sudo dnf copr enable -y errornointernet/quickshell && sudo dnf install -y quickshell"
    )
    run_command(
        "sudo dnf copr enable -y luisbocanegra/kde-material-you-colors && sudo dnf install -y kde-material-you-colors"
    )


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

    # قائمة المجلدات والملفات لأخذ نسخة احتياطية منها
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


def install_nibrasshell():
    """الدالة الرئيسية لتثبيت الواجهة"""
    distro = detect_distro()
    if distro == "arch":
        install_dependencies_arch()
    elif distro == "fedora":
        install_dependencies_fedora()
    else:
        print(f"{RED}{msg('distro_not_supported')}{NC}")
        return

    backup_configs()

    print(f"{YELLOW}{msg('installing_nibrasshell')}{NC}")
    home_dir = os.path.expanduser("~")
    config_dir = os.path.join(home_dir, ".config")
    temp_dir = "/tmp/NibrasShell"

    # تحميل المستودع
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    run_command(
        f"git clone https://github.com/AhmedSaadi0/NibrasShell.git {temp_dir}"
    )

    # نسخ مجلدات الإعدادات
    shutil.copytree(
        os.path.join(temp_dir, "nibrasshell"), os.path.join(config_dir, "hypr")
    )
    shutil.copytree(
        os.path.join(config_dir, "hypr", "config", "quickshell"),
        os.path.join(config_dir, "quickshell"),
    )
    shutil.copytree(
        os.path.join(config_dir, "hypr", "config", "wofi"),
        os.path.join(config_dir, "wofi"),
    )
    shutil.copytree(
        os.path.join(config_dir, "hypr", "config", "easyeffects"),
        os.path.join(config_dir, "easyeffects"),
    )

    # نسخ ملف إعدادات fish
    if not os.path.exists(os.path.join(config_dir, "fish")):
        os.makedirs(os.path.join(config_dir, "fish"))
    shutil.copy(
        os.path.join(config_dir, "hypr", "config", "config.fish"),
        os.path.join(config_dir, "fish", "config.fish"),
    )

    # إعطاء صلاحيات تنفيذ للسكربتات
    run_command(f"chmod +x {config_dir}/hypr/scripts/*")
    run_command(f"chmod +x {config_dir}/quickshell/scripts/*")

    # إنشاء المجلدات ونسخ ملفات الثيمات
    dirs_to_create = [
        os.path.join(home_dir, ".local/share/color-schemes"),
        os.path.join(home_dir, ".local/share/konsole"),
        os.path.join(home_dir, ".config/Kvantum"),
        os.path.join(home_dir, ".config/qt5ct"),
        os.path.join(home_dir, ".config/qt6ct"),
        os.path.join(home_dir, ".fonts"),
        os.path.join(home_dir, ".local/share/icons"),
    ]
    for d in dirs_to_create:
        os.makedirs(d, exist_ok=True)

    shutil.copytree(
        os.path.join(config_dir, "hypr/config/plasma-colors"),
        dirs_to_create[0],
        dirs_exist_ok=True,
    )
    shutil.copytree(
        os.path.join(config_dir, "hypr/config/kvantum-themes"),
        dirs_to_create[2],
        dirs_exist_ok=True,
    )
    shutil.copytree(
        os.path.join(config_dir, "hypr/config/konsole"),
        dirs_to_create[1],
        dirs_exist_ok=True,
    )
    shutil.copy(
        os.path.join(config_dir, "hypr/config/qt5ct.conf"), dirs_to_create[3]
    )
    shutil.copy(
        os.path.join(config_dir, "hypr/config/qt6ct.conf"), dirs_to_create[4]
    )
    shutil.copytree(
        os.path.join(config_dir, "hypr/config/.fonts"),
        dirs_to_create[5],
        dirs_exist_ok=True,
    )

    # فك ضغط الأيقونات
    icons_path = os.path.join(config_dir, "hypr/config/icons")
    for icon_file in os.listdir(icons_path):
        if icon_file.endswith(".tar.gz"):
            run_command(
                f"tar xvf {os.path.join(icons_path, icon_file)} -C {dirs_to_create[6]}"
            )

    # حذف المجلد المؤقت
    shutil.rmtree(temp_dir)
    print(f"{GREEN}{msg('install_complete')}{NC}")


def uninstall_nibrasshell():
    """دالة لحذف الواجهة واستعادة الإعدادات القديمة"""
    confirm = input(f"{YELLOW}{msg('uninstall_prompt')}{NC}").lower()
    if confirm in ["y", "yes", "ن", "نعم"]:
        print(f"{YELLOW}{msg('uninstalling')}{NC}")
        home_dir = os.path.expanduser("~")
        config_dir = os.path.join(home_dir, ".config")

        # حذف مجلدات الإعدادات
        for d in ["hypr", "quickshell", "wofi", "easyeffects"]:
            path = os.path.join(config_dir, d)
            if os.path.exists(path):
                shutil.rmtree(path)

        # سؤال المستخدم لاستعادة النسخة الاحتياطية
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

                # استعادة المجلدات والملفات
                for item in os.listdir(latest_backup_dir):
                    src_path = os.path.join(latest_backup_dir, item)
                    dest_path = os.path.join(config_dir, item)
                    if os.path.isdir(src_path):
                        shutil.copytree(src_path, dest_path)
                    elif item == "fish":  # حالة خاصة لملف fish
                        fish_backup_file = os.path.join(
                            src_path, "config.back.fish"
                        )
                        if os.path.exists(fish_backup_file):
                            shutil.copy(
                                fish_backup_file,
                                os.path.join(
                                    config_dir, "fish", "config.fish"
                                ),
                            )
            else:
                print(f"{RED}{msg('no_backup_found')}{NC}")

        print(f"{GREEN}{msg('uninstall_complete')}{NC}")


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
        print(f"1. {msg('install')}")
        print(f"2. {msg('uninstall')}")
        print(f"3. {msg('exit')}")

        choice = input(f"{YELLOW}{msg('choose_option')}{NC}")

        if choice == "1":
            install_nibrasshell()
        elif choice == "2":
            uninstall_nibrasshell()
        elif choice == "3":
            break
        else:
            print(f"{RED}{msg('invalid_option')}{NC}")


# --- نقطة بداية تشغيل السكربت ---
if __name__ == "__main__":
    main()
