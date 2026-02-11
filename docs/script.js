const themeSelect = document.getElementById("themeSelect");
const savedTheme = localStorage.getItem("nibras-theme");
if (savedTheme) {
  document.documentElement.setAttribute("data-theme", savedTheme);
  if (themeSelect) themeSelect.value = savedTheme;
}

if (themeSelect) {
  themeSelect.addEventListener("change", (e) => {
    const theme = e.target.value;
    document.documentElement.setAttribute("data-theme", theme);
    localStorage.setItem("nibras-theme", theme);
  });
}
