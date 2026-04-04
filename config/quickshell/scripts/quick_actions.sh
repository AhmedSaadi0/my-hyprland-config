#!/bin/sh

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

wifi_available() {
    has_cmd nmcli
}

wifi_enabled() {
    if ! wifi_available; then
        return 1
    fi

    state=$(nmcli radio wifi 2>/dev/null | head -n 1 | tr '[:upper:]' '[:lower:]')
    [ "$state" = "enabled" ]
}

bluetooth_available() {
    has_cmd bluetoothctl || has_cmd rfkill
}

bluetooth_enabled() {
    if has_cmd bluetoothctl; then
        bluetoothctl show 2>/dev/null | grep -qi "Powered: yes"
        return $?
    fi

    if has_cmd rfkill; then
        if rfkill list bluetooth 2>/dev/null | grep -qi "Soft blocked: yes"; then
            return 1
        fi
        return 0
    fi

    return 1
}

gamemode_available() {
    if ! has_cmd systemctl; then
        return 1
    fi

    if systemctl --user cat gamemoded.service >/dev/null 2>&1; then
        return 0
    fi

    if systemctl cat gamemoded.service >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

gamemode_enabled() {
    if has_cmd systemctl; then
        if systemctl --user is-active --quiet gamemoded.service >/dev/null 2>&1; then
            return 0
        fi

        if systemctl is-active --quiet gamemoded.service >/dev/null 2>&1; then
            return 0
        fi
    fi

    return 1
}

airplane_available() {
    wifi_available || bluetooth_available
}

airplane_enabled() {
    available_count=0

    if wifi_available; then
        available_count=1
        if wifi_enabled; then
            return 1
        fi
    fi

    if bluetooth_available; then
        available_count=1
        if bluetooth_enabled; then
            return 1
        fi
    fi

    [ "$available_count" -eq 1 ]
}

bool_json() {
    if "$1"; then
        printf 'true'
    else
        printf 'false'
    fi
}

print_status() {
    printf '{'
    printf '"wifi":{"available":'
    bool_json wifi_available
    printf ',"enabled":'
    bool_json wifi_enabled
    printf '},'

    printf '"bluetooth":{"available":'
    bool_json bluetooth_available
    printf ',"enabled":'
    bool_json bluetooth_enabled
    printf '},'

    printf '"airplane":{"available":'
    bool_json airplane_available
    printf ',"enabled":'
    bool_json airplane_enabled
    printf '},'

    printf '"gameMode":{"available":'
    bool_json gamemode_available
    printf ',"enabled":'
    bool_json gamemode_enabled
    printf '}'
    printf '}\n'
}

toggle_wifi() {
    if ! wifi_available; then
        echo "Wi-Fi toggle requires nmcli." >&2
        return 1
    fi

    if wifi_enabled; then
        nmcli radio wifi off >/dev/null 2>&1
    else
        nmcli radio wifi on >/dev/null 2>&1
    fi
}

toggle_bluetooth() {
    if has_cmd bluetoothctl; then
        if bluetooth_enabled; then
            bluetoothctl power off >/dev/null 2>&1
        else
            bluetoothctl power on >/dev/null 2>&1
        fi
        return $?
    fi

    if has_cmd rfkill; then
        if bluetooth_enabled; then
            rfkill block bluetooth >/dev/null 2>&1
        else
            rfkill unblock bluetooth >/dev/null 2>&1
        fi
        return $?
    fi

    echo "Bluetooth toggle requires bluetoothctl or rfkill." >&2
    return 1
}

toggle_airplane() {
    result=0

    if airplane_enabled; then
        if wifi_available; then
            nmcli radio wifi on >/dev/null 2>&1 || result=1
        fi

        if has_cmd bluetoothctl; then
            bluetoothctl power on >/dev/null 2>&1 || result=1
        elif has_cmd rfkill; then
            rfkill unblock bluetooth >/dev/null 2>&1 || result=1
        fi
    else
        if wifi_available; then
            nmcli radio wifi off >/dev/null 2>&1 || result=1
        fi

        if has_cmd bluetoothctl; then
            bluetoothctl power off >/dev/null 2>&1 || result=1
        elif has_cmd rfkill; then
            rfkill block bluetooth >/dev/null 2>&1 || result=1
        fi
    fi

    return $result
}

toggle_gamemode() {
    if ! gamemode_available; then
        echo "GameMode is unavailable on this system." >&2
        return 1
    fi

    if gamemode_enabled; then
        if has_cmd systemctl && systemctl --user is-active --quiet gamemoded.service >/dev/null 2>&1; then
            systemctl --user stop gamemoded.service >/dev/null 2>&1
            return $?
        fi

        if has_cmd systemctl && systemctl is-active --quiet gamemoded.service >/dev/null 2>&1; then
            systemctl stop gamemoded.service >/dev/null 2>&1
            return $?
        fi

        echo "GameMode is not running." >&2
        return 1
    fi

    if has_cmd systemctl && systemctl --user cat gamemoded.service >/dev/null 2>&1; then
        systemctl --user start gamemoded.service >/dev/null 2>&1
        return $?
    fi

    if has_cmd systemctl && systemctl cat gamemoded.service >/dev/null 2>&1; then
        systemctl start gamemoded.service >/dev/null 2>&1
        return $?
    fi

    echo "gamemoded.service was not found." >&2
    return 1
}

toggle_action() {
    case "$1" in
        wifi)
            toggle_wifi
            ;;
        bluetooth)
            toggle_bluetooth
            ;;
        airplane)
            toggle_airplane
            ;;
        gameMode)
            toggle_gamemode
            ;;
        *)
            echo "Unknown action: $1" >&2
            return 1
            ;;
    esac
}

case "$1" in
    status)
        print_status
        ;;
    toggle)
        toggle_action "$2"
        ;;
    *)
        echo "Usage: $0 {status|toggle <wifi|bluetooth|airplane|gameMode>}" >&2
        exit 1
        ;;
esac
