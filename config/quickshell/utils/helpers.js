function convertToH(bytes) {
  const bits = (bytes * 8) / 10;
  let speed, dim;

  if (bits < 1e6) {
    speed = bits / 1e3;
    dim = "kb/s";
  } else if (bits < 1e9) {
    speed = bits / 1e6;
    dim = "mb/s";
  } else {
    speed = bits / 1e9;
    dim = "gb/s";
  }

  // Format to fixed 6-character length
  let formatted;
  if (speed >= 100) {
    formatted = Math.floor(speed).toString().padStart(3, " ");
  } else if (speed >= 10) {
    formatted = speed.toFixed(1).padStart(4, " ");
  } else {
    formatted = speed.toFixed(2).padStart(5, " ");
  }

  // Combine with unit (fixed 4-character unit)
  return `${formatted} ${dim.padEnd(4, " ")}`.slice(0, 9);
}

function calculateSpeed(currentBytes, oldBytes, intervalMs) {
  if (
    typeof currentBytes !== "number" ||
    typeof oldBytes !== "number" ||
    intervalMs <= 0
  ) {
    return 0;
  }
  return (currentBytes - oldBytes) / (intervalMs / 1000);
}

function signalStrengthToIcon(strength) {
  if (typeof strength !== "number" || isNaN(strength)) {
    return "󰤮";
  }
  if (strength > 85) {
    return "󰤨";
  } else if (strength > 70) {
    return "󰤥";
  } else if (strength > 50) {
    return "󰤢";
  } else if (strength > 20) {
    return "󰤟";
  } else {
    return "󰤠";
  }
}

function isValidPositiveInt(value) {
  return Number.isInteger(value) && value >= 0;
}

function formatNetworkName(name) {
  if (typeof name !== "string" || name.trim() === "") {
    return null;
  }
  return name;
}

function getAccurteTextColor(bg) {
  let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
  return luminance > 0.5 ? "black" : "white";
}
