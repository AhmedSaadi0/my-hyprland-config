#!/bin/bash

# Function to get kernel version
get_kernel_version() {
    uname -r
}

# Function to get host name
get_host_name() {
    hostname
}

# Function to get current user
get_current_user() {
    whoami
}

# Function to get the number of installed packages and package manager
get_installed_packages_and_manager() {
    if command -v dnf &>/dev/null; then
        pkg_manager="dnf"
        installed_packages=$(dnf list installed | wc -l)
    elif command -v yum &>/dev/null; then
        pkg_manager="yum"
        installed_packages=$(yum list installed | wc -l)
    elif command -v apt &>/dev/null; then
        pkg_manager="apt"
        installed_packages=$(dpkg-query -f '${binary:Package}\n' -W | wc -l)
    elif command -v pacman &>/dev/null; then
        pkg_manager="pacman"
        installed_packages=$(pacman -Q | wc -l)
    elif command -v zypper &>/dev/null; then
        pkg_manager="zypper"
        installed_packages=$(zypper se --installed-only | wc -l)
    elif command -v rpm &>/dev/null; then
        pkg_manager="rpm"
        installed_packages=$(rpm -qa | wc -l)
    else
        pkg_manager="unknown"
        installed_packages="0"
    fi

    echo "{\"package_manager\": \"$pkg_manager\", \"installed_packages\": $installed_packages}"
}

# Function to get system uptime
get_uptime() {
    uptime -p | jq -R -c '. | {"uptime": .}'
}

# Get package manager and number of installed packages
pkg_info=$(get_installed_packages_and_manager)
pkg_manager=$(echo $pkg_info | jq -r '.package_manager')
installed_packages=$(echo $pkg_info | jq -r '.installed_packages')

# Combine all the information into a JSON object
json_output=$(jq -n \
    --arg kernel_version "$(get_kernel_version)" \
    --arg host_name "$(get_host_name)" \
    --arg current_user "$(get_current_user)" \
    --arg package_manager "$pkg_manager" \
    --argjson installed_packages "$installed_packages" \
    --argjson uptime "$(get_uptime)" \
    '{
    "kernel_version": $kernel_version,
    "host_name": $host_name,
    "current_user": $current_user,
    "package_manager": $package_manager,
    "installed_packages": $installed_packages,
    "uptime": $uptime.uptime
  }')

# Print the JSON output
echo "$json_output"
