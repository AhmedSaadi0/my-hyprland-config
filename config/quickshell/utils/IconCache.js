// utils/IconCache.js
.pragma library

var resolvedIcons = {};

function get(iconKey, themeName) {
    const cacheKey = themeName + "::" + iconKey;
    return resolvedIcons[cacheKey] || null;
}

function set(iconKey, themeName, resolvedPath) {
    const cacheKey = themeName + "::" + iconKey;
    resolvedIcons[cacheKey] = resolvedPath;
}

// دالة جديدة لتفريغ الكاش بالكامل عند تغيير الثيم
function clear() {
    resolvedIcons = {};
}

// إرجاع أسماء الأيقونات المخزنة لثيم معيّن فقط
// (تُستخدم لإعادة حلّها تلقائياً في الثيم الجديد)
function getAllForTheme(themeName) {
    if (!themeName)
        return [];
    const prefix = themeName + "::";
    const result = [];
    for (const key in resolvedIcons) {
        if (key.startsWith(prefix))
            result.push(key.substring(prefix.length));
    }
    return result;
}
