# modules/dependencies.py
import subprocess
import sys

from config import GREEN, NC, RED, YELLOW

from .i18n import msg
from .utils import (
    detect_distro,
    is_arch_based,
    run_command,
    run_command_verbose,
)


def install_fedora(install_optional):
    print(YELLOW + "Enabling RPM Fusion and COPR repositories..." + NC)
    run_command_verbose(
        "sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    )
    run_command_verbose("sudo dnf copr enable -y solopasha/hyprland")
    run_command_verbose("sudo dnf copr enable -y errornointernet/quickshell")
    run_command_verbose("sudo dnf install -y hyprland quickshell")

    required_pkgs = "plasma-nm playerctl polkit-kde dolphin konsole brightnessctl gammastep wl-clipboard sysstat bc sassc plasma-systemsettings acpi fish gnome-bluetooth-libs power-profiles-daemon lm_sensors copyq vnstat nethogs swww jq dbus-devel python3-devel python3.13"
    optional_pkgs = "strawberry easyeffects blueman telegram-desktop discord kvantum firefox"

    base_command = f"sudo dnf install -y {required_pkgs}"
    if install_optional:
        base_command += f" {optional_pkgs}"

    print(YELLOW + "Installing main packages..." + NC)

    # محاولة التثبيت والتعامل مع الأخطاء
    try:
        # نستخدم subprocess مباشرة هنا لنتمكن من التقاط الخطأ (Exception)
        subprocess.run(base_command, check=True, shell=True)
    except subprocess.CalledProcessError:
        print(f"\n{RED}{msg('dnf_error')}{NC}")
        print(f"{YELLOW}{msg('dnf_conflict_prompt')}{NC}")
        print(msg("opt_allow_erasing"))
        print(msg("opt_skip_broken"))
        print(msg("opt_cancel"))

        choice = input(f"{YELLOW}{msg('choose_option')}{NC}")

        retry_command = base_command
        if choice == "1":
            print(YELLOW + "Retrying with --allowerasing..." + NC)
            retry_command += " --allowerasing"
        elif choice == "2":
            print(YELLOW + "Retrying with --skip-broken..." + NC)
            retry_command += " --skip-broken"
        else:
            print(RED + "Installation cancelled by user." + NC)
            sys.exit(1)

        # المحاولة الثانية بناءً على اختيار المستخدم
        try:
            run_command_verbose(retry_command)
        except SystemExit:
            # run_command_verbose يقوم بعمل sys.exit إذا فشل، لذا لا داعي لعمل شيء هنا
            pass

    print(YELLOW + "Installing python needed packages using pip" + NC)
    run_command("pip install pillow psutil")
    run_command("pipx install kde-material-you-colors", exit_on_fail=False)

    # Python 3.13 setup for rembg
    run_command("curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py")
    run_command("python3.13 get-pip.py")
    run_command("python3.13 -m pip install 'rembg[gpu]'")
    run_command("rm get-pip.py")


def install_arch(install_optional):
    print(YELLOW + "Starting Arch installer" + NC)
    required_pkgs = "base-devel quickshell brightnessctl network-manager-applet konsole ark dolphin ffmpegthumbs playerctl polkit-kde-agent jq gammastep wl-clipboard hyprpicker hyprshot-git bc sysstat sassc systemsettings acpi fish kde-material-you-colors plasma5support plasma5-integration plasma-framework5 ttf-jetbrains-mono-nerd ttf-fantasque-nerd powerdevil gnome-bluetooth-3.0 power-profiles-daemon libjpeg6-turbo swww python-regex copyq swww python-pillow python-psutil"
    optional_pkgs = "strawberry easyeffects blueman telegram-desktop discord kvantum firefox"

    command = f"yay -S {required_pkgs}"
    if install_optional:
        command += f" {optional_pkgs}"
    run_command_verbose(command)


def install_void(install_optional):
    print(YELLOW + "Adding Void extra repository with hyprland..." + NC)
    run_command_verbose(
        "echo repository=https://raw.githubusercontent.com/Encoded14/void-extra/repository-x86_64-glibc | sudo tee /etc/xbps.d/20-void-extra.conf"
    )
    run_command_verbose("sudo xbps-install -S")

    required_pkgs = "hyprland quickshell plasma-nm playerctl polkit-kde-agent dolphin konsole brightnessctl gammastep wl-clipboard sysstat bc sassc systemsettings acpi fish-shell gnome-bluetooth power-profiles-daemon lm_sensors CopyQ vnstat nethogs xz swww jq"
    optional_pkgs = (
        "strawberry easyeffects blueman telegram-desktop kvantum firefox"
    )

    command = f"sudo xbps-install -y {required_pkgs}"
    if install_optional:
        command += f" {optional_pkgs}"

    print(YELLOW + "Installing main packages..." + NC)
    run_command_verbose(command)


def install_dependencies(distro, install_optional=False):
    print(f"{YELLOW}{msg('installing_deps')}{NC}")

    if distro == "fedora":
        install_fedora(install_optional)
    elif is_arch_based():
        install_arch(install_optional)
    elif distro == "void":
        install_void(install_optional)

    print(f"{GREEN}{msg('deps_success_msg')}{NC}")

    # print(
    #     f"{GREEN}Dependencies installed successfully. You can do step 2 now{NC}"
    # )


def show_dependency_menu():
    distro = detect_distro()
    # Basic logic check for supported distros
    if distro != "fedora" and distro != "void" and not is_arch_based():
        print(f"{RED}{msg('distro_check_fail')}{NC}")
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
