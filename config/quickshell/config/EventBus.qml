// config/EventBus.qml
pragma Singleton
import QtQuick

QtObject {
    property var signals: ({})

    function emit(eventName, data) {
        if (signals[eventName]) {
            for (var i in signals[eventName]) {
                signals[eventName][i](data);
            }
        }
    }

    function on(eventName, callback) {
        if (!signals[eventName]) {
            signals[eventName] = [];
        }
        signals[eventName].push(callback);
    }
}
