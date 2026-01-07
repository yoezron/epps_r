// Data Loader for EPPS Interactive Report
// Loads CSV data and populates the interactive report

// Utility function to parse CSV
function parseCSV(text) {
    const lines = text.trim().split('\n');
    const headers = lines[0].split(',').map(h => h.trim().replace(/^"|"$/g, ''));
    const data = [];

    for (let i = 1; i < lines.length; i++) {
        const values = lines[i].split(',').map(v => v.trim().replace(/^"|"$/g, ''));
        const row = {};
        headers.forEach((header, index) => {
            row[header] = values[index];
        });
        data.push(row);
    }

    return { headers, data };
}

// Load CSV file
async function loadCSV(filepath) {
    try {
        const response = await fetch(filepath);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const text = await response.text();
        return parseCSV(text);
    } catch (error) {
        console.error(`Error loading ${filepath}:`, error);
        return null;
    }
}

// Load and display key statistics
async function loadKeyStats() {
    const statsContainer = document.getElementById('keyStats');

    try {
        // Load summary analysis
        const summary = await loadCSV('tables/00_Summary_Analisis.csv');

        // Load reliability data
        const reliability = await loadCSV('tables/03_Reliabilitas.csv');

        // Load descriptive data for sample size
        const descriptive = await loadCSV('tables/02_Deskriptif_Aspek.csv');

        let totalN = 'N/A';
        let avgOmega = 'N/A';
        let totalVisualizations = '20+';

        if (descriptive && descriptive.data.length > 0) {
            totalN = descriptive.data[0].N || 'N/A';
        }

        if (reliability && reliability.data.length > 0) {
            const omegas = reliability.data
                .map(row => parseFloat(row.Omega))
                .filter(val => !isNaN(val));
            if (omegas.length > 0) {
                const avg = omegas.reduce((a, b) => a + b, 0) / omegas.length;
                avgOmega = avg.toFixed(3);
            }
        }

        const stats = [
            {
                label: 'Total Responden',
                value: totalN,
                description: 'Partisipan dalam analisis'
            },
            {
                label: 'Total Aspek',
                value: '15',
                description: 'Aspek kepribadian EPPS'
            },
            {
                label: 'Reliabilitas Rata-rata',
                value: avgOmega,
                description: 'McDonald\'s Omega'
            },
            {
                label: 'Visualisasi',
                value: totalVisualizations,
                description: 'Plot berkualitas tinggi'
            }
        ];

        statsContainer.innerHTML = stats.map(stat => `
            <div class="stat-card">
                <div class="stat-label">${stat.label}</div>
                <div class="stat-value">${stat.value}</div>
                <div class="stat-description">${stat.description}</div>
            </div>
        `).join('');

    } catch (error) {
        console.error('Error loading key stats:', error);
        // Keep placeholder stats
        statsContainer.innerHTML = `
            <div class="stat-card">
                <div class="stat-label">Total Responden</div>
                <div class="stat-value">N/A</div>
                <div class="stat-description">Partisipan dalam analisis</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Aspek</div>
                <div class="stat-value">15</div>
                <div class="stat-description">Aspek kepribadian EPPS</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Reliabilitas Rata-rata</div>
                <div class="stat-value">N/A</div>
                <div class="stat-description">McDonald's Omega</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Visualisasi</div>
                <div class="stat-value">20+</div>
                <div class="stat-description">Plot berkualitas tinggi</div>
            </div>
        `;
    }
}

// Load and display reliability table
async function loadReliabilityData() {
    const tableBody = document.getElementById('reliabilitasTable').getElementsByTagName('tbody')[0];

    try {
        const result = await loadCSV('tables/03_Reliabilitas.csv');

        if (!result || result.data.length === 0) {
            throw new Error('No data');
        }

        // Clear existing rows
        tableBody.innerHTML = '';

        // Populate table
        result.data.forEach(row => {
            const tr = tableBody.insertRow();

            const alpha = parseFloat(row.Alpha);
            const omega = parseFloat(row.Omega);

            let interpretation = 'N/A';
            if (!isNaN(omega)) {
                if (omega >= 0.90) interpretation = 'Excellent';
                else if (omega >= 0.80) interpretation = 'Good';
                else if (omega >= 0.70) interpretation = 'Acceptable';
                else if (omega >= 0.60) interpretation = 'Questionable';
                else interpretation = 'Poor';
            }

            tr.innerHTML = `
                <td>${row.Aspek}</td>
                <td>${!isNaN(alpha) ? alpha.toFixed(3) : 'N/A'}</td>
                <td>${!isNaN(omega) ? omega.toFixed(3) : 'N/A'}</td>
                <td><span class="badge ${
                    interpretation === 'Excellent' ? 'badge-success' :
                    interpretation === 'Good' ? 'badge-info' :
                    interpretation === 'Acceptable' ? 'badge-warning' :
                    'badge-danger'
                }">${interpretation}</span></td>
            `;
        });

    } catch (error) {
        console.error('Error loading reliability data:', error);
        tableBody.innerHTML = `
            <tr>
                <td colspan="4" style="text-align: center; padding: 2rem;">
                    <em>Data tidak dapat dimuat. File mungkin tidak tersedia: tables/03_Reliabilitas.csv</em>
                </td>
            </tr>
        `;
    }
}

// Load and display descriptive statistics table
async function loadDescriptiveData() {
    const tableBody = document.getElementById('deskriptifTable').getElementsByTagName('tbody')[0];

    try {
        const result = await loadCSV('tables/02_Deskriptif_Aspek.csv');

        if (!result || result.data.length === 0) {
            // Try alternative file
            const altResult = await loadCSV('tables/35_Statistik_Deskriptif_Lengkap.csv');
            if (altResult && altResult.data.length > 0) {
                populateDescriptiveTable(tableBody, altResult.data);
                return;
            }
            throw new Error('No data');
        }

        populateDescriptiveTable(tableBody, result.data);

    } catch (error) {
        console.error('Error loading descriptive data:', error);
        tableBody.innerHTML = `
            <tr>
                <td colspan="7" style="text-align: center; padding: 2rem;">
                    <em>Data tidak dapat dimuat. File mungkin tidak tersedia.</em>
                </td>
            </tr>
        `;
    }
}

function populateDescriptiveTable(tableBody, data) {
    // Clear existing rows
    tableBody.innerHTML = '';

    // Populate table
    data.forEach(row => {
        const tr = tableBody.insertRow();

        const mean = parseFloat(row.Mean);
        const median = parseFloat(row.Median);
        const sd = parseFloat(row.SD);
        const min = parseFloat(row.Min);
        const max = parseFloat(row.Max);
        const range = parseFloat(row.Range);

        tr.innerHTML = `
            <td>${row.Aspek}</td>
            <td>${!isNaN(mean) ? mean.toFixed(2) : 'N/A'}</td>
            <td>${!isNaN(median) ? median.toFixed(2) : 'N/A'}</td>
            <td>${!isNaN(sd) ? sd.toFixed(2) : 'N/A'}</td>
            <td>${!isNaN(min) ? min.toFixed(0) : 'N/A'}</td>
            <td>${!isNaN(max) ? max.toFixed(0) : 'N/A'}</td>
            <td>${!isNaN(range) ? range.toFixed(0) : 'N/A'}</td>
        `;
    });
}

// Load and display centrality data
async function loadCentralityData() {
    const tableBody = document.getElementById('centralityTable').getElementsByTagName('tbody')[0];

    try {
        const result = await loadCSV('tables/25_Network_Centrality.csv');

        if (!result || result.data.length === 0) {
            throw new Error('No data');
        }

        // Clear existing rows
        tableBody.innerHTML = '';

        // Populate table
        result.data.forEach(row => {
            const tr = tableBody.insertRow();

            const value = parseFloat(row.value);

            tr.innerHTML = `
                <td>${row.node}</td>
                <td>${row.measure}</td>
                <td>${!isNaN(value) ? value.toFixed(3) : 'N/A'}</td>
            `;
        });

    } catch (error) {
        console.error('Error loading centrality data:', error);
        tableBody.innerHTML = `
            <tr>
                <td colspan="3" style="text-align: center; padding: 2rem;">
                    <em>Data tidak dapat dimuat. File mungkin tidak tersedia: tables/25_Network_Centrality.csv</em>
                </td>
            </tr>
        `;
    }
}

// Load demographic information
async function loadDemografisData() {
    const container = document.getElementById('demografisContent');

    try {
        // Try to load gender demographics
        const gender = await loadCSV('tables/01_Demografis_JenisKelamin.csv');
        const education = await loadCSV('tables/01_Demografis_Pendidikan.csv');
        const age = await loadCSV('tables/01_Statistik_Usia.csv');

        let html = '<p>Total responden yang berpartisipasi dalam analisis ini mencerminkan keberagaman demografis yang representatif.</p>';

        if (gender && gender.data.length > 0) {
            html += '<h4 style="color: var(--secondary-color); margin-top: 1.5rem;">Jenis Kelamin:</h4><ul>';
            gender.data.forEach(row => {
                const n = parseInt(row.N || row.Frequency || 0);
                const pct = parseFloat(row.Percentage || row.Percent || 0);
                html += `<li>${row.JenisKelamin || row.Gender}: ${n} orang (${pct.toFixed(1)}%)</li>`;
            });
            html += '</ul>';
        }

        if (education && education.data.length > 0) {
            html += '<h4 style="color: var(--secondary-color); margin-top: 1.5rem;">Tingkat Pendidikan:</h4><ul>';
            education.data.forEach(row => {
                const n = parseInt(row.N || row.Frequency || 0);
                const pct = parseFloat(row.Percentage || row.Percent || 0);
                html += `<li>${row.Pendidikan || row.Education}: ${n} orang (${pct.toFixed(1)}%)</li>`;
            });
            html += '</ul>';
        }

        if (age && age.data.length > 0) {
            html += '<h4 style="color: var(--secondary-color); margin-top: 1.5rem;">Statistik Usia:</h4><ul>';
            const ageRow = age.data[0];
            for (const key in ageRow) {
                const value = parseFloat(ageRow[key]);
                if (!isNaN(value)) {
                    html += `<li>${key}: ${value.toFixed(2)} tahun</li>`;
                }
            }
            html += '</ul>';
        }

        container.innerHTML = html;

    } catch (error) {
        console.error('Error loading demographic data:', error);
        // Keep default content
    }
}

// Initialize all data loading
async function initializeData() {
    console.log('Loading data...');

    await Promise.all([
        loadKeyStats(),
        loadReliabilityData(),
        loadDescriptiveData(),
        loadCentralityData(),
        loadDemografisData()
    ]);

    console.log('Data loading complete');
}

// Export for use in main HTML
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initializeData,
        loadCSV,
        parseCSV
    };
}
