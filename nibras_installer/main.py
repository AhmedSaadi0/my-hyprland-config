#!/usr/bin/env python3
# main.py

from modules.dependencies import show_dependency_menu
from modules.i18n import load_languages, msg, set_lang
from modules.installer import (
    install_nibrasshell,
    uninstall_nibrasshell,
    update_quickshell,
)
from modules.user_config import create_user_config_file
from modules.utils import check_for_root

from config import GREEN, NC, RED, YELLOW


def main():
    check_for_root()
    load_languages()

    print(f"{GREEN}Choose your language / اختر لغتك / Vyberte jazyk:{NC}")
    print("1. English")
    print("2. العربية")
    print("3. Česky")
    lang_choice = input("> ")

    if lang_choice == "2":
        set_lang("ar")
    elif lang_choice == "3":
        set_lang("cs")
    else:
        set_lang("en")

    while True:
        print("\n" + "=" * 45)
        print(f"{GREEN}{msg('main_menu_title')}{NC}")
        print("=" * 45)
        print(msg("install_deps_menu"))
        print(msg("install_local"))
        print(msg("update_quickshell"))
        print(msg("uninstall"))
        print(msg("create_config"))
        print(msg("exit"))

        choice = input(f"{YELLOW}{msg('choose_option')}{NC}")

        if choice == "1":
            show_dependency_menu()
        elif choice == "2":
            install_nibrasshell()
        elif choice == "3":
            update_quickshell()
        elif choice == "4":
            uninstall_nibrasshell()
        elif choice == "5":
            create_user_config_file()
        elif choice == "6":
            print("Goodbye!")
            break
        else:
            print(f"{RED}{msg('invalid_option')}{NC}")


if __name__ == "__main__":
    main()
