
let isProcessing = false; // Flag to track processing status
let timeoutId; // Store the timeout ID


export const ShowWindow = (windowName, timeout = 5000) => {
    if (isProcessing) {
        // If processing, reset the timer and do something else
        clearTimeout(timeoutId);
    } else {
        // If not processing, do something
        ags.App.toggleWindow(windowName);
    }

    // Set a 5-second delay before doing something else
    timeoutId = setTimeout(() => {
        ags.App.toggleWindow(windowName);
        isProcessing = false; // Reset the processing flag
    }, timeout);

    isProcessing = true; // Set the processing flag
}
