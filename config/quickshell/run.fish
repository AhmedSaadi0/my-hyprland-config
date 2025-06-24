#!/usr/bin/env fish

set -l dbus 'quickshell.dbus.properties.warning = false;quickshell.dbus.dbusmenu.warning = false'  # System tray dbus property errors
set -l notifs 'quickshell.service.notifications.warning = false'  # Notification server warnings on reload
set -l sni 'quickshell.service.sni.host.warning = false'  # StatusNotifierItem warnings on reload
set -l process 'QProcess: Destroyed while process'  # Long running processes on reload

qs -p (dirname (status filename)) --log-rules "$dbus;$notifs;$sni" | grep -vE -e $process
