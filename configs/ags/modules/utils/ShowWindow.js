
let isProcessing = false; // Flag to track processing status
let timeoutId; // Store the timeout ID

export default (windowName, timeout = 5000) => {
    if (isProcessing) {
        // If processing, reset the timer
        clearTimeout(timeoutId);
    } else {
        // If not processing, show or hide the window
        ags.App.toggleWindow(windowName);
    }

    // Set a 5-second delay before show or hide the window
    timeoutId = setTimeout(() => {
        ags.App.toggleWindow(windowName);
        isProcessing = false; // Reset the processing flag
    }, timeout);

    isProcessing = true; // Set the processing flag
}
