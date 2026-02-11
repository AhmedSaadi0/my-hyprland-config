const highlights = document.querySelectorAll("[data-highlight]");
if (highlights.length) {
  let i = 0;
  setInterval(() => {
    highlights.forEach(el => el.classList.remove("active"));
    highlights[i % highlights.length].classList.add("active");
    i++;
  }, 2400);
}
