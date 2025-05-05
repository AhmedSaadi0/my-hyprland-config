function convertToH(bytes) {
  const bits = (bytes * 8) / 10;
  let speed, dim;

  if (bits < 1000) {
    speed = bits;
    dim = "b/s";
  } else if (bits < 1e6) {
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

// Example outputs:
// "123  kb/s"
// "12.3 kb/s"
// "1.23 kb/s"
// "999  gb/s"
