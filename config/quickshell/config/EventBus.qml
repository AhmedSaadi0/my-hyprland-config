// config/EventBus.qml
pragma Singleton
import QtQuick

QtObject {
    property var signals: ({})

    function emit(eventName, data) {
        const list = signals[eventName];
        if (!list)
            return;

        // Iterate backwards so we can safely remove stale entries.
        for (var i = list.length - 1; i >= 0; i--) {
            const entry = list[i];
            let callback = entry;
            let owner = null;

            if (entry && typeof entry === "object" && entry.cb) {
                callback = entry.cb;
                owner = entry.owner;

                if (owner === null) {
                    list.splice(i, 1);
                    continue;
                }
            }

            if (typeof callback === "function") {
                try {
                    callback(data);
                } catch (error) {
                    // مستمع قديم يشير إلى نافذة مُدمَّرة (فصل/إعادة تركيب شاشة مثلاً) — نزيله ليتوقف التحذير المتكرر
                    console.warn(`EventBus: removing stale listener for "${eventName}": ${error}`);
                    list.splice(i, 1);
                }
            } else {
                list.splice(i, 1);
            }
        }

        if (list.length === 0) {
            delete signals[eventName];
        }
    }

    function on(eventName, callback, owner) {
        if (!signals[eventName]) {
            signals[eventName] = [];
        }

        if (owner !== undefined) {
            const entry = {
                cb: callback,
                owner: owner
            };
            signals[eventName].push(entry);

            if (owner && Qt.isQtObject(owner) && owner.destroyed) {
                owner.destroyed.connect(function () {
                    off(eventName, entry);
                });
            }
            return entry;
        }

        signals[eventName].push(callback);
        return callback;
    }

    function off(eventName, callbackOrEntry) {
        const list = signals[eventName];
        if (!list)
            return;

        for (var i = list.length - 1; i >= 0; i--) {
            const entry = list[i];
            if (entry === callbackOrEntry) {
                list.splice(i, 1);
            } else if (entry && entry.cb === callbackOrEntry) {
                list.splice(i, 1);
            }
        }

        if (list.length === 0) {
            delete signals[eventName];
        }
    }

    function clearOwner(owner) {
        _clearOwnerFromSignals(owner);

        if (owner && Qt.isQtObject(owner) && owner.children) {
            for (var i = 0; i < owner.children.length; i++) {
                clearOwner(owner.children[i]);
            }
        }
    }

    function _clearOwnerFromSignals(owner) {
        for (let eventName in signals) {
            const list = signals[eventName];
            for (var i = list.length - 1; i >= 0; i--) {
                const entry = list[i];
                if (entry && typeof entry === "object" && entry.owner === owner) {
                    list.splice(i, 1);
                }
            }
            if (list.length === 0) {
                delete signals[eventName];
            }
        }
    }
}
