// ============================================================================
// EPPS Analysis Dashboard - Main JavaScript
// ============================================================================

// ============================================================================
// INITIALIZATION
// ============================================================================
document.addEventListener('DOMContentLoaded', function() {
    // Initialize AOS (Animate On Scroll)
    AOS.init({
        duration: 800,
        easing: 'ease-in-out',
        once: true,
        offset: 100
    });

    // Initialize all components
    initScrollButton();
    loadDemographicsData();
    loadReliabilityData();
    loadDescriptiveData();
    initSmoothScroll();
});

// ============================================================================
// SCROLL TO TOP BUTTON
// ============================================================================
function initScrollButton() {
    const scrollBtn = document.getElementById('scrollTopBtn');

    window.addEventListener('scroll', function() {
        if (window.pageYOffset > 300) {
            scrollBtn.style.display = 'block';
        } else {
            scrollBtn.style.display = 'none';
        }
    });
}

function scrollToTop() {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
}

// ============================================================================
// SMOOTH SCROLL FOR NAVIGATION LINKS
// ============================================================================
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// ============================================================================
// CSV PARSER UTILITY
// ============================================================================
function parseCSV(text) {
    const lines = text.trim().split('\n');
    const headers = lines[0].split(',').map(h => h.replace(/"/g, '').trim());
    const data = [];

    for (let i = 1; i < lines.length; i++) {
        if (lines[i].trim() === '') continue;

        const values = lines[i].split(',').map(v => v.replace(/"/g, '').trim());
        const row = {};

        headers.forEach((header, index) => {
            row[header] = values[index];
        });

        data.push(row);
    }

    return data;
}

// ============================================================================
// LOAD DEMOGRAPHICS DATA
// ============================================================================
async function loadDemographicsData() {
    try {
        // Gender Distribution
        const genderResponse = await fetch('data/tables/01_Demografis_JenisKelamin.csv');
        const genderText = await genderResponse.text();
        const genderData = parseCSV(genderText);

        createGenderChart(genderData);

        // Education Distribution
        const eduResponse = await fetch('data/tables/01_Demografis_Pendidikan.csv');
        const eduText = await eduResponse.text();
        const eduData = parseCSV(eduText);

        createEducationChart(eduData);
    } catch (error) {
        console.error('Error loading demographics data:', error);
    }
}

// ============================================================================
// CREATE GENDER CHART
// ============================================================================
function createGenderChart(data) {
    const ctx = document.getElementById('genderChart');
    if (!ctx) return;

    const labels = data.map(row => row.Kategori);
    const values = data.map(row => parseFloat(row.Frekuensi));
    const percentages = data.map(row => parseFloat(row['Persentase.Freq']));

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: labels,
            datasets: [{
                data: values,
                backgroundColor: [
                    'rgba(79, 70, 229, 0.8)',
                    'rgba(239, 68, 68, 0.8)'
                ],
                borderColor: [
                    'rgba(79, 70, 229, 1)',
                    'rgba(239, 68, 68, 1)'
                ],
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        font: {
                            family: 'Inter',
                            size: 14
                        },
                        padding: 15
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const label = context.label || '';
                            const value = context.parsed || 0;
                            const percentage = percentages[context.dataIndex];
                            return `${label}: ${value.toLocaleString()} (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });
}

// ============================================================================
// CREATE EDUCATION CHART
// ============================================================================
function createEducationChart(data) {
    const ctx = document.getElementById('educationChart');
    if (!ctx) return;

    const labels = data.map(row => row.Kategori || row.Pendidikan);
    const values = data.map(row => parseFloat(row.Frekuensi));

    // Color palette
    const colors = [
        'rgba(79, 70, 229, 0.8)',   // Primary
        'rgba(16, 185, 129, 0.8)',  // Success
        'rgba(245, 158, 11, 0.8)',  // Warning
        'rgba(59, 130, 246, 0.8)',  // Info
        'rgba(139, 92, 246, 0.8)',  // Purple
        'rgba(236, 72, 153, 0.8)'   // Pink
    ];

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Jumlah Responden',
                data: values,
                backgroundColor: colors.slice(0, labels.length),
                borderColor: colors.slice(0, labels.length).map(c => c.replace('0.8', '1')),
                borderWidth: 2,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        font: {
                            family: 'Inter'
                        }
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    ticks: {
                        font: {
                            family: 'Inter'
                        }
                    },
                    grid: {
                        display: false
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return `Jumlah: ${context.parsed.y.toLocaleString()} orang`;
                        }
                    }
                }
            }
        }
    });

    // Create legend manually
    const legendDiv = document.getElementById('educationLegend');
    if (legendDiv) {
        let legendHTML = '';
        labels.forEach((label, index) => {
            legendHTML += `
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span><i class="bi bi-circle-fill me-2" style="color: ${colors[index]}"></i>${label}</span>
                    <strong>${values[index].toLocaleString()}</strong>
                </div>
            `;
        });
        legendDiv.innerHTML = legendHTML;
    }
}

// ============================================================================
// LOAD RELIABILITY DATA
// ============================================================================
async function loadReliabilityData() {
    try {
        const response = await fetch('data/tables/02_Reliabilitas_Aspek.csv');
        const text = await response.text();
        const data = parseCSV(text);

        createReliabilityChart(data);
        populateReliabilityTable(data);
    } catch (error) {
        console.error('Error loading reliability data:', error);
    }
}

// ============================================================================
// CREATE RELIABILITY CHART
// ============================================================================
function createReliabilityChart(data) {
    const ctx = document.getElementById('reliabilityChart');
    if (!ctx) return;

    const labels = data.map(row => row.Aspek);
    const omega = data.map(row => parseFloat(row.Omega));

    // Color based on reliability level
    const colors = omega.map(value => {
        if (value >= 0.90) return 'rgba(16, 185, 129, 0.8)';      // Excellent - Green
        if (value >= 0.80) return 'rgba(59, 130, 246, 0.8)';      // Good - Blue
        if (value >= 0.70) return 'rgba(245, 158, 11, 0.8)';      // Acceptable - Orange
        return 'rgba(239, 68, 68, 0.8)';                          // Questionable - Red
    });

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: "McDonald's Omega",
                data: omega,
                backgroundColor: colors,
                borderColor: colors.map(c => c.replace('0.8', '1')),
                borderWidth: 2,
                borderRadius: 8
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                x: {
                    beginAtZero: true,
                    max: 1.0,
                    ticks: {
                        callback: function(value) {
                            return value.toFixed(2);
                        },
                        font: {
                            family: 'Inter'
                        }
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                y: {
                    ticks: {
                        font: {
                            family: 'Inter',
                            size: 11
                        }
                    },
                    grid: {
                        display: false
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const value = context.parsed.x;
                            let interpretation = '';
                            if (value >= 0.90) interpretation = 'Excellent';
                            else if (value >= 0.80) interpretation = 'Good';
                            else if (value >= 0.70) interpretation = 'Acceptable';
                            else interpretation = 'Questionable';
                            return `Omega: ${value.toFixed(3)} (${interpretation})`;
                        }
                    }
                }
            }
        }
    });
}

// ============================================================================
// POPULATE RELIABILITY TABLE
// ============================================================================
function populateReliabilityTable(data) {
    const tbody = document.getElementById('reliabilityTableBody');
    if (!tbody) return;

    let html = '';
    data.forEach(row => {
        const omega = parseFloat(row.Omega);
        let interpretation = '';
        let badgeClass = '';

        if (omega >= 0.90) {
            interpretation = 'Excellent';
            badgeClass = 'bg-success';
        } else if (omega >= 0.80) {
            interpretation = 'Good';
            badgeClass = 'bg-primary';
        } else if (omega >= 0.70) {
            interpretation = 'Acceptable';
            badgeClass = 'bg-warning';
        } else {
            interpretation = 'Questionable';
            badgeClass = 'bg-danger';
        }

        html += `
            <tr>
                <td><strong>${row.Aspek}</strong></td>
                <td>${row.Jumlah_Item}</td>
                <td>${omega.toFixed(3)}</td>
                <td><span class="badge ${badgeClass}">${interpretation}</span></td>
            </tr>
        `;
    });

    tbody.innerHTML = html;

    // Initialize DataTable
    if ($.fn.DataTable) {
        $('#reliabilityTable').DataTable({
            paging: false,
            searching: false,
            info: false,
            order: [[2, 'desc']]
        });
    }
}

// ============================================================================
// LOAD DESCRIPTIVE STATISTICS DATA
// ============================================================================
async function loadDescriptiveData() {
    try {
        const response = await fetch('data/tables/01_Deskriptif_Aspek.csv');
        const text = await response.text();
        const data = parseCSV(text);

        createMeanScoresChart(data);
        populateDescriptiveTable(data);
    } catch (error) {
        console.error('Error loading descriptive data:', error);
    }
}

// ============================================================================
// CREATE MEAN SCORES CHART
// ============================================================================
function createMeanScoresChart(data) {
    const ctx = document.getElementById('meanScoresChart');
    if (!ctx) return;

    const labels = data.map(row => row.Aspek);
    const means = data.map(row => parseFloat(row.mean));
    const sds = data.map(row => parseFloat(row.sd));

    // Color palette
    const colors = [
        'rgba(79, 70, 229, 0.7)',   // Primary
        'rgba(16, 185, 129, 0.7)',  // Success
        'rgba(245, 158, 11, 0.7)',  // Warning
        'rgba(59, 130, 246, 0.7)',  // Info
        'rgba(139, 92, 246, 0.7)',  // Purple
        'rgba(236, 72, 153, 0.7)',  // Pink
        'rgba(20, 184, 166, 0.7)',  // Teal
        'rgba(251, 146, 60, 0.7)',  // Orange
        'rgba(99, 102, 241, 0.7)',  // Indigo
        'rgba(6, 182, 212, 0.7)',   // Cyan
        'rgba(132, 204, 22, 0.7)',  // Lime
        'rgba(244, 63, 94, 0.7)',   // Rose
        'rgba(168, 85, 247, 0.7)',  // Violet
        'rgba(234, 179, 8, 0.7)',   // Yellow
        'rgba(71, 85, 105, 0.7)'    // Slate
    ];

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Mean Score',
                data: means,
                backgroundColor: colors,
                borderColor: colors.map(c => c.replace('0.7', '1')),
                borderWidth: 2,
                borderRadius: 8
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                x: {
                    beginAtZero: true,
                    max: 28,
                    ticks: {
                        font: {
                            family: 'Inter'
                        }
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                y: {
                    ticks: {
                        font: {
                            family: 'Inter',
                            size: 11
                        }
                    },
                    grid: {
                        display: false
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const mean = context.parsed.x;
                            const sd = sds[context.dataIndex];
                            return `Mean: ${mean.toFixed(2)} (SD: ${sd.toFixed(2)})`;
                        }
                    }
                }
            }
        }
    });
}

// ============================================================================
// POPULATE DESCRIPTIVE TABLE
// ============================================================================
function populateDescriptiveTable(data) {
    const tbody = document.getElementById('descriptiveTableBody');
    if (!tbody) return;

    let html = '';
    data.forEach(row => {
        html += `
            <tr>
                <td><strong>${row.Aspek}</strong></td>
                <td>${parseInt(row.n).toLocaleString()}</td>
                <td>${parseFloat(row.mean).toFixed(2)}</td>
                <td>${parseFloat(row.sd).toFixed(2)}</td>
                <td>${row.min}</td>
                <td>${row.max}</td>
                <td>${parseFloat(row.median).toFixed(2)}</td>
                <td>${parseFloat(row.skew).toFixed(3)}</td>
            </tr>
        `;
    });

    tbody.innerHTML = html;

    // Initialize DataTable
    if ($.fn.DataTable) {
        $('#descriptiveTable').DataTable({
            paging: false,
            searching: true,
            info: false,
            order: [[2, 'desc']]
        });
    }
}

// ============================================================================
// NAVBAR SCROLL EFFECT
// ============================================================================
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.style.padding = '0.5rem 0';
        navbar.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1)';
    } else {
        navbar.style.padding = '1rem 0';
        navbar.style.boxShadow = 'none';
    }
});

// ============================================================================
// ACTIVE NAVIGATION HIGHLIGHTING
// ============================================================================
const sections = document.querySelectorAll('section[id]');
const navLinks = document.querySelectorAll('.nav-link');

window.addEventListener('scroll', () => {
    let current = '';

    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (pageYOffset >= sectionTop - 100) {
            current = section.getAttribute('id');
        }
    });

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${current}`) {
            link.classList.add('active');
        }
    });
});

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

// Format number with thousand separators
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// Calculate average
function calculateAverage(arr) {
    return arr.reduce((a, b) => a + b, 0) / arr.length;
}

// Parse value to float safely
function safeParseFloat(value, defaultValue = 0) {
    const parsed = parseFloat(value);
    return isNaN(parsed) ? defaultValue : parsed;
}

// ============================================================================
// ERROR HANDLING
// ============================================================================
window.addEventListener('error', function(e) {
    console.error('Global error:', e.error);
});

// ============================================================================
// CONSOLE WELCOME MESSAGE
// ============================================================================
console.log('%c EPPS Analysis Dashboard ', 'background: #4f46e5; color: white; font-size: 16px; padding: 10px;');
console.log('%c Version 2.0 | PT. Nirmala Satya Development ', 'color: #4f46e5; font-size: 12px;');
console.log('%c Developed by PT. Data Riset Nusantara (Darinusa) ', 'color: #666; font-size: 10px;');
