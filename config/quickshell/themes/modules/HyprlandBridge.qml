import QtQuick
import Quickshell.Hyprland

QtObject {
    id: root

    function applyConfig(hyprConfig) {
        if (!hyprConfig)
            return;

        console.info("HyprlandBridge: Dispatching configuration...");

        // دالة مساعدة داخلية للتنفيذ
        const dispatch = (cmd, val) => {
            let valueStr = String(val).trim();
            // وضع علامات تنصيص إذا كانت القيمة تحتوي مسافات أو فواصل (مثل الألوان المتدرجة)
            if (valueStr.includes(' ') || valueStr.includes(',')) {
                valueStr = `'${valueStr}'`;
            }
            Hyprland.dispatch(`exec hyprctl keyword ${cmd} ${valueStr}`);
        };

        // --- General ---
        dispatch('general:gaps_in', hyprConfig.gapsIn);
        dispatch('general:gaps_out', hyprConfig.gapsOut);
        dispatch('general:border_size', hyprConfig.borderWidth);
        dispatch('general:col.active_border', hyprConfig.activeBorder);
        dispatch('general:col.inactive_border', hyprConfig.inactiveBorder);
        dispatch('general:layout', hyprConfig.layout);

        // --- Decoration ---
        dispatch('decoration:rounding', hyprConfig.rounding);
        dispatch('decoration:dim_inactive', hyprConfig.dimInactive ? "yes" : "no");
        dispatch('decoration:dim_strength', hyprConfig.dimStrength);

        // Blur
        dispatch('decoration:blur:enabled', hyprConfig.blurEnabled ? "yes" : "no");
        dispatch('decoration:blur:size', hyprConfig.blurSize);
        dispatch('decoration:blur:passes', hyprConfig.blurPasses);

        // --- Animations ---
        dispatch('animations:enabled', hyprConfig.animationsEnabled ? "yes" : "no");

        // معالجة Bezier (أسطر متعددة)
        if (hyprConfig.bezier) {
            hyprConfig.bezier.split('\n').forEach(line => {
                if (line.trim())
                    dispatch('animations:bezier', line.trim());
            });
        }

        // معالجة Animations
        if (hyprConfig.animWindows)
            dispatch('animations:animation', `windows, ${hyprConfig.animWindows}`);
        if (hyprConfig.animWorkspaces)
            dispatch('animations:animation', `workspaces, ${hyprConfig.animWorkspaces}`);

    // dispatch('decoration:drop_shadow', hyprConfig.dropShadow ? "yes" : "no");
    }
}
