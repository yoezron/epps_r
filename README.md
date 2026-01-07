# ANALISIS PSIKOMETRIK KOMPREHENSIF EPPS
## Edwards Personal Preference Schedule

---

**Client:** PT. Nirmala Satya Development (NSD)  
**Konsultan:** PT. Data Riset Nusantara (Darinusa)  
**Instrumen:** Edwards Personal Preference Schedule (EPPS)

---

## STRUKTUR SCRIPT

Script ini terdiri dari 11 modul analisis + 1 master script:

```
MASTER_RUN_ALL.R          → Script master untuk menjalankan semua analisis
├── 01_Setup_Data.R       → Setup dan persiapan data
├── 02_Deskriptif_CTT.R   → Analisis deskriptif dan Classical Test Theory
├── 03_IRT_2PL.R          → IRT 2-Parameter Logistic Model
├── 04_IRT_3PL.R          → IRT 3-Parameter Logistic Model
├── 05_MIRT.R             → Multidimensional IRT
├── 06_TIRT.R             → Thurstonian IRT (koreksi forced-choice)
├── 07_GRM.R              → Graded Response Model
├── 08_Network_Analysis.R → Network Analysis antar aspek
├── 09_Norma_Scoring.R    → Pembuatan norma dan sistem penyekoran
├── 10_Visualisasi.R      → Visualisasi komprehensif
└── 11_Laporan.R          → Laporan psikometrik komprehensif
```

---

## PERSIAPAN

### 1. Struktur Folder
```
D:/1 NSD Project/EPPS/EPPS-Analysis/
├── epps_raw.csv              (FILE DATA WAJIB)
├── MASTER_RUN_ALL.R
├── 01_Setup_Data.R
├── 02_Deskriptif_CTT.R
├── ... (semua script lainnya)
└── output/                   (akan dibuat otomatis)
    ├── tables/
    ├── plots/
    ├── models/
    └── data_processed.RData
```

### 2. Instalasi Package
Script akan otomatis menginstal package yang diperlukan:
- ltm, mirt (IRT modeling)
- psych (reliability analysis)
- thurstonianIRT (forced-choice IRT)
- ggplot2, plotly, corrplot (visualisasi)
- qgraph, bootnet (network analysis)
- lavaan (SEM/CFA)
- dplyr, tidyr, reshape2 (data manipulation)

---

## CARA MENJALANKAN

### OPSI 1: Jalankan Semua Analisis Sekaligus (REKOMENDASI)

```r
# Set working directory
setwd("D:/1 NSD Project/EPPS/EPPS-Analysis")

# Jalankan master script
source("MASTER_RUN_ALL.R")
```

**Estimasi waktu:** 30-60 menit (tergantung spesifikasi komputer)

---

### OPSI 2: Jalankan Bertahap (Manual)

```r
# Set working directory
setwd("D:/1 NSD Project/EPPS/EPPS-Analysis")

# Jalankan satu per satu
source("01_Setup_Data.R")
source("02_Deskriptif_CTT.R")
source("03_IRT_2PL.R")
source("04_IRT_3PL.R")
source("05_MIRT.R")
source("06_TIRT.R")
source("07_GRM.R")
source("08_Network_Analysis.R")
source("09_Norma_Scoring.R")
source("10_Visualisasi.R")
source("11_Laporan.R")
```

---

### OPSI 3: Jalankan Analisis Tertentu Saja

```r
# Load data terlebih dahulu
load("output/data_processed.RData")

# Jalankan analisis yang diinginkan, misalnya:
source("08_Network_Analysis.R")  # Hanya network analysis
source("10_Visualisasi.R")        # Hanya visualisasi
```

---

## OUTPUT YANG DIHASILKAN

### 1. Tables (CSV) - ~35 file
- **Demografis:** Distribusi gender, pendidikan, usia
- **Deskriptif:** Statistik skor per aspek
- **Reliabilitas:** Alpha, Omega per aspek
- **IRT 2PL/3PL:** Parameter item (difficulty, discrimination, guessing)
- **MIRT:** Fit indices, parameter, factor scores, korelasi antar faktor
- **TIRT:** Fit indices, trait estimates, korelasi trait
- **GRM:** Parameter polytomous
- **Network:** Centrality measures, edge weights, communities
- **Norma:** Raw score, T-score, percentile, konversi, norma demografis

### 2. Plots (PNG/HTML) - ~60 file
- Korelasi antar aspek
- Distribusi skor (histogram, density, violin)
- ICC dan IIC curves (per aspek, per model)
- Network diagram
- Radar chart profil
- Heatmap
- Perbandingan demografis
- 3D scatter plot
- Stability plots
- dan banyak lagi...

### 3. Models (RDS) - ~20 file
- Model IRT tersimpan untuk setiap aspek dan metode
- Dapat di-load kembali untuk analisis lanjutan

### 4. Laporan
- **LAPORAN_PSIKOMETRIK_EPPS.txt:** Laporan komprehensif dalam Bahasa Indonesia

---

## INTERPRETASI HASIL

### Reliabilitas
- **Omega > 0.90:** Excellent
- **0.80-0.89:** Good
- **0.70-0.79:** Acceptable
- **< 0.70:** Questionable (perlu revisi)

### Fit Indices (MIRT/TIRT)
- **CFI/TLI > 0.95:** Excellent fit
- **CFI/TLI > 0.90:** Acceptable fit
- **RMSEA < 0.06:** Good fit
- **RMSEA < 0.08:** Acceptable fit
- **SRMSR < 0.08:** Good fit

### IRT Parameter Interpretation
- **Difficulty (b):** Tingkat kesulitan item (semakin tinggi = lebih sulit)
- **Discrimination (a):** Daya beda item (semakin tinggi = lebih baik)
  - a > 1.5: Very high
  - a > 1.0: High
  - a > 0.5: Moderate
  - a < 0.5: Low (pertimbangkan revisi)

---

## 15 ASPEK EPPS

1. **Achievement (ACH)** - Dorongan untuk menyelesaikan tugas sulit
2. **Deference (DEF)** - Kecenderungan mengikuti instruksi
3. **Order (ORD)** - Kebutuhan akan keteraturan
4. **Exhibition (EXH)** - Keinginan menjadi pusat perhatian
5. **Autonomy (AUT)** - Hasrat kebebasan
6. **Affiliation (AFF)** - Kebutuhan mendekatkan diri
7. **Intraception (INT)** - Empati psikologis
8. **Succorance (SUC)** - Keinginan didukung
9. **Dominance (DOM)** - Kebutuhan mengontrol
10. **Abasement (ABA)** - Kecenderungan menyerah pasif
11. **Nurturance (NUR)** - Dorongan membantu
12. **Change (CHG)** - Kebutuhan variasi
13. **Endurance (END)** - Kegigihan
14. **Heterosexuality (HET)** - Ketertarikan sosial lawan jenis
15. **Aggression (AGG)** - Dorongan mengkritik

---

## CATATAN PENTING

### Tentang Forced-Choice Data
EPPS menggunakan format **forced-choice** yang menghasilkan **ipsative scores**. 
Ini berarti:
- Skor antar aspek saling bergantung (sum to constant)
- Korelasi negatif artifisial muncul
- **Solusi:** Gunakan **Thurstonian IRT (TIRT)** untuk koreksi

### Sampling untuk Efisiensi
Beberapa analisis menggunakan sampling (1000-3000 responden) untuk:
- Mengurangi waktu komputasi
- Mencegah memory overflow
- Tetap mempertahankan akurasi estimasi

Parameter dari sample kemudian dapat diterapkan ke full dataset.

---

## TROUBLESHOOTING

### Error: Package tidak ditemukan
```r
install.packages("nama_package", dependencies = TRUE)
```

### Error: Memory limit
- Tutup aplikasi lain
- Restart R session
- Gunakan sample size lebih kecil di script MIRT/TIRT

### Error: Model tidak konvergen
- Sudah ada fallback handling dalam script
- Model akan skip jika gagal, analisis lain tetap jalan

---

## KONTAK

**PT. Data Riset Nusantara (Darinusa)**  
Konsultan Psikometri

Untuk pertanyaan teknis, hubungi tim analisis.

---

## VERSI

**Versi 1.0** - Januari 2025  
Analisis komprehensif dengan semua model IRT modern

---

**© 2025 PT. Data Riset Nusantara**
