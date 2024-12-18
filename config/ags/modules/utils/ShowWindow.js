const windowTimers = {}; // Object to store timeout IDs for each window
const windowStates = {}; // Object to store processing status for each window

export default (windowName, timeout = 5000) => {
    if (windowStates[windowName]) {
        // If the window is already open and processing, reset its timer
        clearTimeout(windowTimers[windowName]);
    } else {
        // If the window is not open or processing, show it
        App.openWindow(windowName);
        windowStates[windowName] = true; // Set the processing status for this window
    }

    // Set a timeout to close the window after the specified time
    windowTimers[windowName] = setTimeout(() => {
        App.closeWindow(windowName);
        delete windowStates[windowName]; // Reset the processing status for this window
        delete windowTimers[windowName]; // Remove the timer for this window
    }, timeout);
};
