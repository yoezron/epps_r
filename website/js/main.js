// ============================================================================
// EPPS Analysis Dashboard - Main JavaScript with Embedded Data
// ============================================================================

// ============================================================================
// EMBEDDED DATA (Fallback when CSV fetch fails)
// ============================================================================
const EMBEDDED_DATA = {
    gender: [
        { Kategori: "Laki-laki", Frekuensi: "3891", "Persentase.Freq": "60.19" },
        { Kategori: "Perempuan", Frekuensi: "2573", "Persentase.Freq": "39.81" }
    ],
    education: [
        { Kategori: "SMA", Frekuensi: "2156", "Persentase.Freq": "33.35" },
        { Kategori: "D3", Frekuensi: "1289", "Persentase.Freq": "19.94" },
        { Kategori: "S1", Frekuensi: "2431", "Persentase.Freq": "37.61" },
        { Kategori: "S2", Frekuensi: "512", "Persentase.Freq": "7.92" },
        { Kategori: "S3", Frekuensi: "76", "Persentase.Freq": "1.18" }
    ],
    reliability: [
        { Aspek: "Achievement", Jumlah_Item: "28", Omega: "0.598" },
        { Aspek: "Deference", Jumlah_Item: "28", Omega: "0.490" },
        { Aspek: "Order", Jumlah_Item: "28", Omega: "0.753" },
        { Aspek: "Exhibition", Jumlah_Item: "28", Omega: "0.511" },
        { Aspek: "Autonomy", Jumlah_Item: "28", Omega: "0.604" },
        { Aspek: "Affiliation", Jumlah_Item: "28", Omega: "0.571" },
        { Aspek: "Intraception", Jumlah_Item: "28", Omega: "0.590" },
        { Aspek: "Succorance", Jumlah_Item: "28", Omega: "0.739" },
        { Aspek: "Dominance", Jumlah_Item: "28", Omega: "0.700" },
        { Aspek: "Abasement", Jumlah_Item: "28", Omega: "0.644" },
        { Aspek: "Nurturance", Jumlah_Item: "28", Omega: "0.664" },
        { Aspek: "Change", Jumlah_Item: "28", Omega: "0.603" },
        { Aspek: "Endurance", Jumlah_Item: "28", Omega: "0.712" },
        { Aspek: "Heterosexuality", Jumlah_Item: "28", Omega: "0.848" },
        { Aspek: "Aggression", Jumlah_Item: "28", Omega: "0.748" }
    ],
    descriptive: [
        { Aspek: "Achievement", n: "6464", mean: "16.47", sd: "3.38", min: "4", max: "28", median: "16", skew: "-0.00" },
        { Aspek: "Deference", n: "6464", mean: "14.46", sd: "3.36", min: "2", max: "26", median: "14", skew: "-0.11" },
        { Aspek: "Order", n: "6464", mean: "17.39", sd: "4.57", min: "1", max: "28", median: "18", skew: "-0.31" },
        { Aspek: "Exhibition", n: "6464", mean: "13.12", sd: "3.28", min: "1", max: "26", median: "13", skew: "0.08" },
        { Aspek: "Autonomy", n: "6464", mean: "10.74", sd: "3.41", min: "0", max: "23", median: "11", skew: "0.20" },
        { Aspek: "Affiliation", n: "6464", mean: "13.14", sd: "3.65", min: "1", max: "26", median: "13", skew: "0.09" },
        { Aspek: "Intraception", n: "6464", mean: "17.07", sd: "3.68", min: "3", max: "27", median: "17", skew: "-0.02" },
        { Aspek: "Succorance", n: "6464", mean: "11.34", sd: "4.47", min: "0", max: "28", median: "11", skew: "0.18" },
        { Aspek: "Dominance", n: "6464", mean: "14.72", sd: "4.25", min: "2", max: "28", median: "14", skew: "0.28" },
        { Aspek: "Abasement", n: "6464", mean: "16.90", sd: "3.75", min: "1", max: "28", median: "17", skew: "-0.22" },
        { Aspek: "Nurturance", n: "6464", mean: "16.36", sd: "4.14", min: "3", max: "28", median: "16", skew: "-0.02" },
        { Aspek: "Change", n: "6464", mean: "14.95", sd: "3.95", min: "2", max: "28", median: "15", skew: "0.14" },
        { Aspek: "Endurance", n: "6464", mean: "18.35", sd: "4.25", min: "0", max: "28", median: "18", skew: "-0.24" },
        { Aspek: "Heterosexuality", n: "6464", mean: "5.20", sd: "4.53", min: "0", max: "26", median: "4", skew: "1.02" },
        { Aspek: "Aggression", n: "6464", mean: "9.78", sd: "4.33", min: "0", max: "26", median: "9", skew: "0.35" }
    ],
    percentile: [
        { Aspek: "Achievement", P10: "12", P25: "14", P50: "16", P75: "19", P90: "21" },
        { Aspek: "Deference", P10: "10", P25: "12", P50: "14", P75: "17", P90: "19" },
        { Aspek: "Order", P10: "11", P25: "14", P50: "18", P75: "21", P90: "23" },
        { Aspek: "Exhibition", P10: "9", P25: "11", P50: "13", P75: "15", P90: "17" },
        { Aspek: "Autonomy", P10: "6", P25: "8", P50: "11", P75: "13", P90: "15" },
        { Aspek: "Affiliation", P10: "8", P25: "11", P50: "13", P75: "16", P90: "18" },
        { Aspek: "Intraception", P10: "12", P25: "15", P50: "17", P75: "20", P90: "22" },
        { Aspek: "Succorance", P10: "6", P25: "8", P50: "11", P75: "15", P90: "17" },
        { Aspek: "Dominance", P10: "10", P25: "12", P50: "14", P75: "17", P90: "21" },
        { Aspek: "Abasement", P10: "12", P25: "14", P50: "17", P75: "20", P90: "22" },
        { Aspek: "Nurturance", P10: "11", P25: "14", P50: "16", P75: "19", P90: "22" },
        { Aspek: "Change", P10: "10", P25: "12", P50: "15", P75: "17", P90: "20" },
        { Aspek: "Endurance", P10: "13", P25: "15", P50: "18", P75: "21", P90: "24" },
        { Aspek: "Heterosexuality", P10: "0", P25: "2", P50: "4", P75: "8", P90: "12" },
        { Aspek: "Aggression", P10: "4", P25: "6", P50: "9", P75: "13", P90: "16" }
    ],
    tscore: [
        { Aspek: "Achievement", Mean: "16.47", SD: "3.38", Min: "4", Max: "28" },
        { Aspek: "Deference", Mean: "14.46", SD: "3.36", Min: "2", Max: "26" },
        { Aspek: "Order", Mean: "17.39", SD: "4.57", Min: "1", Max: "28" },
        { Aspek: "Exhibition", Mean: "13.12", SD: "3.28", Min: "1", Max: "26" },
        { Aspek: "Autonomy", Mean: "10.74", SD: "3.41", Min: "0", Max: "23" },
        { Aspek: "Affiliation", Mean: "13.14", SD: "3.65", Min: "1", Max: "26" },
        { Aspek: "Intraception", Mean: "17.07", SD: "3.68", Min: "3", Max: "27" },
        { Aspek: "Succorance", Mean: "11.34", SD: "4.47", Min: "0", Max: "28" },
        { Aspek: "Dominance", Mean: "14.72", SD: "4.25", Min: "2", Max: "28" },
        { Aspek: "Abasement", Mean: "16.90", SD: "3.75", Min: "1", Max: "28" },
        { Aspek: "Nurturance", Mean: "16.36", SD: "4.14", Min: "3", Max: "28" },
        { Aspek: "Change", Mean: "14.95", SD: "3.95", Min: "2", Max: "28" },
        { Aspek: "Endurance", Mean: "18.35", SD: "4.25", Min: "0", Max: "28" },
        { Aspek: "Heterosexuality", Mean: "5.20", SD: "4.53", Min: "0", Max: "26" },
        { Aspek: "Aggression", Mean: "9.78", SD: "4.33", Min: "0", Max: "26" }
    ],
    categoryDist: [
        { Aspek: "Achievement", SangatTinggi: "113", Tinggi: "1132", Ratarata: "3973", Rendah: "1137", SangatRendah: "109" },
        { Aspek: "Deference", SangatTinggi: "95", Tinggi: "1094", Ratarata: "4058", Rendah: "1073", SangatRendah: "144" },
        { Aspek: "Order", SangatTinggi: "59", Tinggi: "1183", Ratarata: "4293", Rendah: "711", SangatRendah: "218" },
        { Aspek: "Exhibition", SangatTinggi: "178", Tinggi: "756", Ratarata: "4662", Rendah: "758", SangatRendah: "110" },
        { Aspek: "Autonomy", SangatTinggi: "181", Tinggi: "709", Ratarata: "4450", Rendah: "1061", SangatRendah: "63" },
        { Aspek: "Affiliation", SangatTinggi: "153", Tinggi: "1000", Ratarata: "4305", Rendah: "892", SangatRendah: "114" },
        { Aspek: "Intraception", SangatTinggi: "138", Tinggi: "1020", Ratarata: "4225", Rendah: "963", SangatRendah: "118" },
        { Aspek: "Succorance", SangatTinggi: "145", Tinggi: "1046", Ratarata: "4273", Rendah: "939", SangatRendah: "61" },
        { Aspek: "Dominance", SangatTinggi: "182", Tinggi: "1010", Ratarata: "4274", Rendah: "891", SangatRendah: "107" },
        { Aspek: "Abasement", SangatTinggi: "90", Tinggi: "1020", Ratarata: "4229", Rendah: "925", SangatRendah: "200" },
        { Aspek: "Nurturance", SangatTinggi: "147", Tinggi: "906", Ratarata: "4254", Rendah: "979", SangatRendah: "178" },
        { Aspek: "Change", SangatTinggi: "219", Tinggi: "955", Ratarata: "4100", Rendah: "1020", SangatRendah: "170" },
        { Aspek: "Endurance", SangatTinggi: "83", Tinggi: "1106", Ratarata: "4030", Rendah: "1098", SangatRendah: "147" },
        { Aspek: "Heterosexuality", SangatTinggi: "271", Tinggi: "903", Ratarata: "4559", Rendah: "731", SangatRendah: "0" },
        { Aspek: "Aggression", SangatTinggi: "196", Tinggi: "793", Ratarata: "4344", Rendah: "1083", SangatRendah: "48" }
    ]
};

// ============================================================================
// INITIALIZATION
// ============================================================================
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Initializing EPPS Dashboard...');

    // Initialize AOS (Animate On Scroll)
    if (typeof AOS !== 'undefined') {
        AOS.init({
            duration: 800,
            easing: 'ease-in-out',
            once: true,
            offset: 100
        });
        console.log('✅ AOS initialized');
    } else {
        console.warn('⚠️ AOS library not loaded');
    }

    // Initialize all components
    initScrollButton();
    loadDemographicsData();
    loadReliabilityData();
    loadDescriptiveData();
    loadNormaData();
    initSmoothScroll();

    console.log('✅ Dashboard initialized successfully');
});

// ============================================================================
// SCROLL TO TOP BUTTON
// ============================================================================
function initScrollButton() {
    const scrollBtn = document.getElementById('scrollTopBtn');
    if (!scrollBtn) return;

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
    console.log('📊 Loading demographics data...');

    try {
        // Try to fetch from CSV files
        const genderResponse = await fetch('data/tables/01_Demografis_JenisKelamin.csv');
        const genderText = await genderResponse.text();
        const genderData = parseCSV(genderText);

        const eduResponse = await fetch('data/tables/01_Demografis_Pendidikan.csv');
        const eduText = await eduResponse.text();
        const eduData = parseCSV(eduText);

        createGenderChart(genderData);
        createEducationChart(eduData);
        console.log('✅ Demographics data loaded from CSV');
    } catch (error) {
        console.warn('⚠️ Could not fetch CSV, using embedded data:', error.message);
        // Use embedded data as fallback
        createGenderChart(EMBEDDED_DATA.gender);
        createEducationChart(EMBEDDED_DATA.education);
        console.log('✅ Demographics data loaded from embedded source');
    }
}

// ============================================================================
// CREATE GENDER CHART
// ============================================================================
function createGenderChart(data) {
    const ctx = document.getElementById('genderChart');
    if (!ctx) {
        console.error('❌ Gender chart canvas not found');
        return;
    }

    console.log('📈 Creating gender chart with data:', data);

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

    console.log('✅ Gender chart created');
}

// ============================================================================
// CREATE EDUCATION CHART
// ============================================================================
function createEducationChart(data) {
    const ctx = document.getElementById('educationChart');
    if (!ctx) {
        console.error('❌ Education chart canvas not found');
        return;
    }

    console.log('📈 Creating education chart with data:', data);

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

    console.log('✅ Education chart created');
}

// ============================================================================
// LOAD RELIABILITY DATA
// ============================================================================
async function loadReliabilityData() {
    console.log('📊 Loading reliability data...');

    try {
        const response = await fetch('data/tables/02_Reliabilitas_Aspek.csv');
        const text = await response.text();
        const data = parseCSV(text);

        createReliabilityChart(data);
        populateReliabilityTable(data);
        console.log('✅ Reliability data loaded from CSV');
    } catch (error) {
        console.warn('⚠️ Could not fetch CSV, using embedded data:', error.message);
        createReliabilityChart(EMBEDDED_DATA.reliability);
        populateReliabilityTable(EMBEDDED_DATA.reliability);
        console.log('✅ Reliability data loaded from embedded source');
    }
}

// ============================================================================
// CREATE RELIABILITY CHART
// ============================================================================
function createReliabilityChart(data) {
    const ctx = document.getElementById('reliabilityChart');
    if (!ctx) {
        console.error('❌ Reliability chart canvas not found');
        return;
    }

    console.log('📈 Creating reliability chart with data:', data);

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

    console.log('✅ Reliability chart created');
}

// ============================================================================
// POPULATE RELIABILITY TABLE
// ============================================================================
function populateReliabilityTable(data) {
    const tbody = document.getElementById('reliabilityTableBody');
    if (!tbody) {
        console.error('❌ Reliability table body not found');
        return;
    }

    console.log('📋 Populating reliability table');

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

    // Initialize DataTable if available
    if (typeof $.fn.DataTable !== 'undefined') {
        try {
            $('#reliabilityTable').DataTable({
                paging: false,
                searching: false,
                info: false,
                order: [[2, 'desc']]
            });
            console.log('✅ Reliability table DataTable initialized');
        } catch (e) {
            console.warn('⚠️ DataTable initialization failed:', e.message);
        }
    }

    console.log('✅ Reliability table populated');
}

// ============================================================================
// LOAD DESCRIPTIVE STATISTICS DATA
// ============================================================================
async function loadDescriptiveData() {
    console.log('📊 Loading descriptive data...');

    try {
        const response = await fetch('data/tables/01_Deskriptif_Aspek.csv');
        const text = await response.text();
        const data = parseCSV(text);

        createMeanScoresChart(data);
        populateDescriptiveTable(data);
        console.log('✅ Descriptive data loaded from CSV');
    } catch (error) {
        console.warn('⚠️ Could not fetch CSV, using embedded data:', error.message);
        createMeanScoresChart(EMBEDDED_DATA.descriptive);
        populateDescriptiveTable(EMBEDDED_DATA.descriptive);
        console.log('✅ Descriptive data loaded from embedded source');
    }
}

// ============================================================================
// CREATE MEAN SCORES CHART
// ============================================================================
function createMeanScoresChart(data) {
    const ctx = document.getElementById('meanScoresChart');
    if (!ctx) {
        console.error('❌ Mean scores chart canvas not found');
        return;
    }

    console.log('📈 Creating mean scores chart with data:', data);

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

    console.log('✅ Mean scores chart created');
}

// ============================================================================
// POPULATE DESCRIPTIVE TABLE
// ============================================================================
function populateDescriptiveTable(data) {
    const tbody = document.getElementById('descriptiveTableBody');
    if (!tbody) {
        console.error('❌ Descriptive table body not found');
        return;
    }

    console.log('📋 Populating descriptive table');

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

    // Initialize DataTable if available
    if (typeof $.fn.DataTable !== 'undefined') {
        try {
            $('#descriptiveTable').DataTable({
                paging: false,
                searching: true,
                info: false,
                order: [[2, 'desc']]
            });
            console.log('✅ Descriptive table DataTable initialized');
        } catch (e) {
            console.warn('⚠️ DataTable initialization failed:', e.message);
        }
    }

    console.log('✅ Descriptive table populated');
}

// ============================================================================
// NAVBAR SCROLL EFFECT
// ============================================================================
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        if (window.scrollY > 50) {
            navbar.style.padding = '0.5rem 0';
            navbar.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1)';
        } else {
            navbar.style.padding = '1rem 0';
            navbar.style.boxShadow = 'none';
        }
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
// LOAD NORMA DATA
// ============================================================================
async function loadNormaData() {
    console.log('📊 Loading norma data...');

    try {
        const percentileResponse = await fetch('data/tables/20_Norma_Percentile.csv');
        const percentileText = await percentileResponse.text();
        const percentileData = parseCSV(percentileText);

        const tscoreResponse = await fetch('data/tables/19_Norma_TScore.csv');
        const tscoreText = await tscoreResponse.text();
        const tscoreData = parseCSV(tscoreText);

        const categoryResponse = await fetch('data/tables/31_Distribusi_Kategori.csv');
        const categoryText = await categoryResponse.text();
        const categoryData = parseCSV(categoryText);

        createNormaDistributionChart(categoryData);
        createPercentileBoxPlot(percentileData);
        populatePercentileTable(percentileData);
        populateTScoreStatsTable(tscoreData);
        populateCategoryDistTable(categoryData);
        createConversionSample();
        console.log('✅ Norma data loaded from CSV');
    } catch (error) {
        console.warn('⚠️ Could not fetch CSV, using embedded data:', error.message);
        createNormaDistributionChart(EMBEDDED_DATA.categoryDist);
        createPercentileBoxPlot(EMBEDDED_DATA.percentile);
        populatePercentileTable(EMBEDDED_DATA.percentile);
        populateTScoreStatsTable(EMBEDDED_DATA.tscore);
        populateCategoryDistTable(EMBEDDED_DATA.categoryDist);
        createConversionSample();
        console.log('✅ Norma data loaded from embedded source');
    }
}

// ============================================================================
// CREATE NORMA DISTRIBUTION CHART (Stacked Bar)
// ============================================================================
function createNormaDistributionChart(data) {
    const ctx = document.getElementById('normaDistributionChart');
    if (!ctx) {
        console.error('❌ Norma distribution chart canvas not found');
        return;
    }

    console.log('📈 Creating norma distribution chart');

    const labels = data.map(row => row.Aspek);
    const sangatTinggi = data.map(row => parseInt(row.SangatTinggi));
    const tinggi = data.map(row => parseInt(row.Tinggi));
    const ratarata = data.map(row => parseInt(row.Ratarata));
    const rendah = data.map(row => parseInt(row.Rendah));
    const sangatRendah = data.map(row => parseInt(row.SangatRendah));

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Sangat Rendah',
                    data: sangatRendah,
                    backgroundColor: 'rgba(239, 68, 68, 0.8)',
                    borderColor: 'rgba(239, 68, 68, 1)',
                    borderWidth: 1
                },
                {
                    label: 'Rendah',
                    data: rendah,
                    backgroundColor: 'rgba(245, 158, 11, 0.8)',
                    borderColor: 'rgba(245, 158, 11, 1)',
                    borderWidth: 1
                },
                {
                    label: 'Rata-rata',
                    data: ratarata,
                    backgroundColor: 'rgba(107, 114, 128, 0.8)',
                    borderColor: 'rgba(107, 114, 128, 1)',
                    borderWidth: 1
                },
                {
                    label: 'Tinggi',
                    data: tinggi,
                    backgroundColor: 'rgba(59, 130, 246, 0.8)',
                    borderColor: 'rgba(59, 130, 246, 1)',
                    borderWidth: 1
                },
                {
                    label: 'Sangat Tinggi',
                    data: sangatTinggi,
                    backgroundColor: 'rgba(16, 185, 129, 0.8)',
                    borderColor: 'rgba(16, 185, 129, 1)',
                    borderWidth: 1
                }
            ]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                x: {
                    stacked: true,
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
                    stacked: true,
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
                    position: 'bottom',
                    labels: {
                        font: {
                            family: 'Inter'
                        },
                        padding: 15
                    }
                }
            }
        }
    });

    console.log('✅ Norma distribution chart created');
}

// ============================================================================
// CREATE PERCENTILE BOX PLOT
// ============================================================================
function createPercentileBoxPlot(data) {
    const ctx = document.getElementById('percentileBoxPlot');
    if (!ctx) {
        console.error('❌ Percentile box plot canvas not found');
        return;
    }

    console.log('📈 Creating percentile box plot');

    const labels = data.map(row => row.Aspek);
    const p10 = data.map(row => parseFloat(row.P10));
    const p25 = data.map(row => parseFloat(row.P25));
    const p50 = data.map(row => parseFloat(row.P50));
    const p75 = data.map(row => parseFloat(row.P75));
    const p90 = data.map(row => parseFloat(row.P90));

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'P10 (Base)',
                    data: p10,
                    backgroundColor: 'rgba(0, 0, 0, 0)',
                    borderWidth: 0,
                    stack: 'percentile'
                },
                {
                    label: 'P10-P25',
                    data: p25.map((val, i) => val - p10[i]),
                    backgroundColor: 'rgba(239, 68, 68, 0.3)',
                    borderWidth: 0,
                    stack: 'percentile'
                },
                {
                    label: 'P25-P50',
                    data: p50.map((val, i) => val - p25[i]),
                    backgroundColor: 'rgba(245, 158, 11, 0.5)',
                    borderWidth: 0,
                    stack: 'percentile'
                },
                {
                    label: 'P50-P75',
                    data: p75.map((val, i) => val - p50[i]),
                    backgroundColor: 'rgba(59, 130, 246, 0.5)',
                    borderWidth: 0,
                    stack: 'percentile'
                },
                {
                    label: 'P75-P90',
                    data: p90.map((val, i) => val - p75[i]),
                    backgroundColor: 'rgba(16, 185, 129, 0.3)',
                    borderWidth: 0,
                    stack: 'percentile'
                }
            ]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                x: {
                    stacked: true,
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
                    stacked: true,
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
                    position: 'bottom',
                    labels: {
                        font: {
                            family: 'Inter'
                        },
                        padding: 10,
                        filter: function(legendItem) {
                            return legendItem.text !== 'P10 (Base)';
                        }
                    }
                }
            }
        }
    });

    console.log('✅ Percentile box plot created');
}

// ============================================================================
// POPULATE PERCENTILE TABLE
// ============================================================================
function populatePercentileTable(data) {
    const tbody = document.getElementById('percentileTableBody');
    if (!tbody) return;

    let html = '';
    data.forEach(row => {
        html += '<tr><td><strong>' + row.Aspek + '</strong></td><td>' + row.P10 + '</td><td>' + row.P25 + '</td><td class="table-info"><strong>' + row.P50 + '</strong></td><td>' + row.P75 + '</td><td>' + row.P90 + '</td></tr>';
    });
    tbody.innerHTML = html;
    console.log('✅ Percentile table populated');
}

// ============================================================================
// POPULATE T-SCORE STATISTICS TABLE
// ============================================================================
function populateTScoreStatsTable(data) {
    const tbody = document.getElementById('tscoreStatsTableBody');
    if (!tbody) return;

    let html = '';
    data.forEach(row => {
        const range = row.Min + ' - ' + row.Max;
        html += '<tr><td><strong>' + row.Aspek + '</strong></td><td>' + parseFloat(row.Mean).toFixed(2) + '</td><td>' + parseFloat(row.SD).toFixed(2) + '</td><td>' + range + '</td></tr>';
    });
    tbody.innerHTML = html;
    console.log('✅ T-Score stats table populated');
}

// ============================================================================
// POPULATE CATEGORY DISTRIBUTION TABLE
// ============================================================================
function populateCategoryDistTable(data) {
    const tbody = document.getElementById('categoryDistTableBody');
    if (!tbody) return;

    let html = '';
    data.forEach(row => {
        const total = parseInt(row.SangatTinggi) + parseInt(row.Tinggi) + parseInt(row.Ratarata) + parseInt(row.Rendah) + parseInt(row.SangatRendah);
        const pctST = ((parseInt(row.SangatTinggi) / total) * 100).toFixed(1);
        const pctT = ((parseInt(row.Tinggi) / total) * 100).toFixed(1);
        const pctR = ((parseInt(row.Ratarata) / total) * 100).toFixed(1);
        const pctRd = ((parseInt(row.Rendah) / total) * 100).toFixed(1);
        const pctSR = ((parseInt(row.SangatRendah) / total) * 100).toFixed(1);

        html += '<tr><td><strong>' + row.Aspek + '</strong></td>';
        html += '<td>' + parseInt(row.SangatTinggi).toLocaleString() + ' <small class="text-muted">(' + pctST + '%)</small></td>';
        html += '<td>' + parseInt(row.Tinggi).toLocaleString() + ' <small class="text-muted">(' + pctT + '%)</small></td>';
        html += '<td>' + parseInt(row.Ratarata).toLocaleString() + ' <small class="text-muted">(' + pctR + '%)</small></td>';
        html += '<td>' + parseInt(row.Rendah).toLocaleString() + ' <small class="text-muted">(' + pctRd + '%)</small></td>';
        html += '<td>' + parseInt(row.SangatRendah).toLocaleString() + ' <small class="text-muted">(' + pctSR + '%)</small></td></tr>';
    });
    tbody.innerHTML = html;
    console.log('✅ Category distribution table populated');
}

// ============================================================================
// CREATE CONVERSION SAMPLE (Achievement as example)
// ============================================================================
function createConversionSample() {
    const tbody = document.getElementById('conversionSampleBody');
    if (!tbody) return;

    const mean = 16.47;
    const sd = 3.38;
    const samples = [8, 10, 12, 14, 16, 18, 20, 22, 24, 26];

    let html = '';
    samples.forEach(rawScore => {
        const tscore = 50 + 10 * ((rawScore - mean) / sd);
        let interpretation = '';
        let badgeClass = '';

        if (tscore >= 70) {
            interpretation = 'Sangat Tinggi';
            badgeClass = 'bg-success';
        } else if (tscore >= 60) {
            interpretation = 'Tinggi';
            badgeClass = 'bg-primary';
        } else if (tscore >= 40) {
            interpretation = 'Rata-rata';
            badgeClass = 'bg-secondary';
        } else if (tscore >= 30) {
            interpretation = 'Rendah';
            badgeClass = 'bg-warning';
        } else {
            interpretation = 'Sangat Rendah';
            badgeClass = 'bg-danger';
        }

        html += '<tr><td><strong>' + rawScore + '</strong></td><td><strong>' + tscore.toFixed(1) + '</strong></td><td><span class="badge ' + badgeClass + '">' + interpretation + '</span></td></tr>';
    });
    tbody.innerHTML = html;
    console.log('✅ Conversion sample table created');
}

// ============================================================================
// CONSOLE WELCOME MESSAGE
// ============================================================================
console.log('%c EPPS Analysis Dashboard ', 'background: #4f46e5; color: white; font-size: 16px; padding: 10px;');
console.log('%c Version 2.0 | PT. Nirmala Satya Development ', 'color: #4f46e5; font-size: 12px;');
console.log('%c Developed by PT. Data Riset Nusantara (Darinusa) ', 'color: #666; font-size: 10px;');
console.log('%c\n💡 Tip: Open this website using a local web server for best experience', 'color: #f59e0b; font-size: 11px;');
console.log('%c   Example: python3 -m http.server 8000\n', 'color: #10b981; font-size: 10px;');
