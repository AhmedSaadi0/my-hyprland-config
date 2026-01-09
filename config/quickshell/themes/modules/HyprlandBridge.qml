import QtQuick
import Quickshell.Hyprland
import "root:/config"
import "root:/config/ConstValues.js" as C

QtObject {
    id: root

    function applyConfig(hyprConfig) {
        if (!hyprConfig)
            return;

        console.info("[HyprlandBridge] HyprlandBridge: Dispatching configuration...");

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
        if (App.menuStyle == C.FLOATING) {
            dispatch('general:gaps_out', hyprConfig.gapsOut);
        }
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

    function addLeftMenuSpacing(hyprConfig, dimensions) {
        if (!hyprConfig || !dimensions)
            return;

        let gapsStr = hyprConfig.gapsOut; // EX -> : "10, 10, 10, 52"
        let menuWidth = dimensions.menuWidth + (hyprConfig.gapsIn * 2);

        // 2. تقسيم النص إلى مصفوفة أرقام [Top, Right, Bottom, Left]
        // نستخدم split(',') للفصل و parseInt لتحويل النص لرقم
        let gapsArray = gapsStr.split(',').map(val => parseInt(val.trim()));

        // 3. التحقق والحساب
        if (gapsArray.length === 4) {
            let top = gapsArray[0];
            let right = gapsArray[1];
            let bottom = gapsArray[2];
            let left = gapsArray[3];

            // المعادلة: الهامش الجديد = الهامش الأصلي + عرض القائمة
            let newLeftGap = left + menuWidth - 5;

            // 4. إرسال الأمر
            Hyprland.dispatch(`exec hyprctl keyword general:gaps_out ${top}, ${right}, ${bottom}, ${newLeftGap}`);
        } else {
            console.warn("Error: gapsOut format in theme should be 'T, R, B, L'");
        }
    }

    function resetLeftMenuSpacing(hyprConfig) {
        if (!hyprConfig)
            return;
        const gapsOut = hyprConfig.gapsOut;
        Hyprland.dispatch(`exec hyprctl keyword general:gaps_out ${gapsOut}`);
    }
}
