# EPPS Psychometric Analysis Dashboard

Dashboard interaktif untuk visualisasi hasil analisis psikometrik EPPS.

## Fitur Dashboard

### 1. Overview
- Total respondents, items, dan aspects
- Summary statistics
- Reliability by aspect

### 2. Deskriptif & Reliabilitas
- Descriptive statistics per aspek
- Item analysis lengkap
- Correlation matrix heatmap

### 3. IRT Analysis
- Parameter IRT 2PL dan 3PL
- Item Characteristic Curves
- Item information functions

### 4. Network Analysis
- Centrality measures (Strength, Betweenness, Closeness)
- Community detection
- Clustering coefficients
- Network visualizations (GGM, Communities)

### 5. Interactive Networks
- visNetwork interactive network
- 3D network visualization (Plotly)
- Radial network
- D3 force-directed network

### 6. Norma & Scoring
- T-Score norms per aspek
- Percentile ranks
- Scoring guidelines

### 7. Visualizations Gallery
- Browser untuk semua visualisasi yang tersedia
- 47 visualisasi (PNG dan HTML)

## Cara Menjalankan

### Opsi 1: Menggunakan script launcher
```r
source("RUN_DASHBOARD.R")
```

### Opsi 2: Langsung dari direktori dashboard
```r
shiny::runApp("dashboard", launch.browser = TRUE)
```

### Opsi 3: Dari RStudio
1. Buka file `dashboard/app.R` di RStudio
2. Klik tombol "Run App" di toolbar

## Persyaratan

Dashboard membutuhkan packages berikut:
- shiny
- shinydashboard
- DT
- ggplot2
- plotly
- htmltools

Packages akan diinstall otomatis saat menjalankan `RUN_DASHBOARD.R`.

## Catatan

- Dashboard membaca data dari folder `output/tables/` dan `output/plots/`
- Pastikan sudah menjalankan `MASTER_RUN_ALL.R` untuk generate semua output
- Dashboard akan terbuka di browser default pada port 3838 atau port tersedia lainnya
- Untuk stop dashboard, tekan Ctrl+C atau Esc di R console

## Troubleshooting

**Dashboard tidak menampilkan data:**
- Pastikan folder `output/` ada dan berisi file hasil analisis
- Jalankan `MASTER_RUN_ALL.R` terlebih dahulu

**Interactive HTML tidak muncul:**
- Pastikan file HTML ada di `output/plots/`
- Jalankan `08D_Interactive_Network.R` untuk generate interactive visualizations

**Error saat launch:**
- Check apakah semua required packages sudah terinstall
- Pastikan working directory benar (folder root project)
