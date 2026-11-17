const menuToggle = document.getElementById('menuToggle');
const mainNav = document.getElementById('mainNav');
if (menuToggle && mainNav) {
  menuToggle.addEventListener('click', () => {
    const isOpen = mainNav.classList.toggle('open');
    menuToggle.setAttribute('aria-expanded', String(isOpen));
  });
  mainNav.querySelectorAll('a').forEach(link => link.addEventListener('click', () => {
    mainNav.classList.remove('open');
    menuToggle.setAttribute('aria-expanded', 'false');
  }));
}
const year = document.getElementById('year');
if (year) year.textContent = new Date().getFullYear();

// This chart is deliberately illustrative. Replace it only with a sourced dataset
// and update the labels, units, reporting period and source note before publication.
const chartCanvas = document.getElementById('sampleChart');
if (chartCanvas && window.Chart) {
  new Chart(chartCanvas, {
    type: 'line',
    data: {
      labels: ['Period 1', 'Period 2', 'Period 3', 'Period 4', 'Period 5', 'Period 6'],
      datasets: [{
        label: 'Illustrative index',
        data: [18, 24, 21, 32, 29, 41],
        borderColor: '#c7f36b',
        backgroundColor: 'rgba(199,243,107,.10)',
        fill: true,
        tension: .38,
        borderWidth: 2,
        pointRadius: 2,
        pointBackgroundColor: '#c7f36b'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false }, tooltip: { enabled: false } },
      scales: {
        x: { grid: { display: false }, ticks: { color: '#91a398', font: { size: 9 } }, border: { display: false } },
        y: { grid: { color: 'rgba(200,220,205,.10)' }, ticks: { color: '#91a398', font: { size: 9 } }, border: { display: false } }
      }
    }
  });
}