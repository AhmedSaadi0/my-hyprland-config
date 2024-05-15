const windowTimers = {};
let currentWindow = null;

export default (windowName, timeout = 5000) => {
  if (currentWindow && currentWindow !== windowName) {
    App.closeWindow(currentWindow);
    clearTimeout(windowTimers[currentWindow]);
    delete windowTimers[currentWindow];
  }

  App.openWindow(windowName);
  currentWindow = windowName;

  windowTimers[windowName] = setTimeout(() => {
    App.closeWindow(windowName);
    delete windowTimers[windowName];
    if (currentWindow === windowName) {
      currentWindow = null;
    }
  }, timeout);
};
