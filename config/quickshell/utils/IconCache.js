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
