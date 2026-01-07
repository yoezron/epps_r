# Laporan Interaktif Analisis Psikometrik EPPS

## 📋 Tentang Laporan Ini

Laporan interaktif ini menyajikan hasil analisis psikometrik komprehensif terhadap instrumen Edwards Personal Preference Schedule (EPPS) untuk PT. Nirmala Satya Development (PT.NSD).

Laporan ini dibuat oleh PT. Data Riset Nusantara (PT.Darinusa) - Tim Konsultan Psikometri.

## 🎯 Fitur Utama

- **Navigasi Interaktif**: Menu navigasi untuk mengakses berbagai bagian laporan
- **Visualisasi Dinamis**: 20+ visualisasi berkualitas tinggi (300 DPI)
- **Galeri Gambar**: Klik gambar untuk melihat versi ukuran penuh
- **Tabel Data Interaktif**: Data dari analisis CSV dimuat secara dinamis
- **Visualisasi 3D & Network Interaktif**: Plot interaktif yang dapat dieksplorasi
- **Responsive Design**: Dapat diakses dari desktop, tablet, dan mobile
- **Professional Styling**: Desain profesional sesuai standar corporate

## 📁 Struktur File

```
output/
├── interactive_report.html          # File utama laporan interaktif
├── data_loader.js                   # Script untuk memuat data CSV
├── README_INTERACTIVE_REPORT.md     # Dokumentasi ini
├── plots/                           # Folder visualisasi
│   ├── *.png                        # Visualisasi statis
│   └── *.html                       # Visualisasi interaktif
└── tables/                          # Folder data CSV
    └── *.csv                        # Data hasil analisis
```

## 🚀 Cara Menggunakan

### Metode 1: Buka Langsung di Browser

1. Buka folder `output/`
2. Double-click file `interactive_report.html`
3. File akan terbuka di browser default Anda

### Metode 2: Menggunakan Local Server (Rekomendasi)

Untuk performa terbaik dan memastikan semua fitur berfungsi (terutama loading data CSV), gunakan local server:

**Menggunakan Python:**

```bash
# Python 3
cd output
python -m http.server 8000

# Python 2
cd output
python -m SimpleHTTPServer 8000
```

Kemudian buka browser dan akses: `http://localhost:8000/interactive_report.html`

**Menggunakan Node.js:**

```bash
npm install -g http-server
cd output
http-server
```

**Menggunakan PHP:**

```bash
cd output
php -S localhost:8000
```

### Metode 3: Upload ke Web Server

Upload seluruh folder `output/` ke web server Anda, kemudian akses via URL.

## 📊 Konten Laporan

### 1. Ringkasan Eksekutif
- Tujuan analisis
- Metodologi (CTT, IRT, Network Analysis)
- Statistik kunci
- Temuan utama

### 2. Karakteristik Sampel
- Profil demografis (gender, pendidikan, usia)
- Statistik deskriptif per aspek
- Visualisasi distribusi skor

### 3. Analisis Reliabilitas
- Cronbach's Alpha
- McDonald's Omega
- Interpretasi per aspek
- Visualisasi perbandingan

### 4. Analisis Item Response Theory (IRT)
- Model 2PL (Difficulty & Discrimination)
- Model 3PL (dengan Guessing parameter)
- Multidimensional IRT (MIRT)
- Thurstonian IRT (TIRT) untuk koreksi ipsativity
- Item Characteristic Curves (ICC)

### 5. Network Analysis
- Gaussian Graphical Models
- Centrality measures (Strength, Betweenness, Closeness)
- Community detection
- Visualisasi network interaktif
- Bridge connections

### 6. Norma dan Sistem Penyekoran
- Raw score norms
- T-Score conversion
- Percentile ranks
- Kategori normatif
- Norma demografis

### 7. Galeri Visualisasi Lengkap
- Semua visualisasi dalam satu tempat
- Kategorisasi berdasarkan jenis analisis
- Akses cepat ke visualisasi interaktif

### 8. Kesimpulan dan Rekomendasi
- Kesimpulan utama dari analisis
- Rekomendasi implementasi (Prioritas Tinggi, Menengah, Jangka Panjang)
- Limitasi analisis
- Langkah selanjutnya

## 🎨 Visualisasi yang Tersedia

### Visualisasi Statis (PNG):
1. Profil skor rata-rata dengan statistik
2. Heatmap dengan clustering hierarkis
3. Distribusi skor dengan kurva normal
4. Violin plot distribusi per aspek
5. Radar chart multi-layer
6. Perbandingan gender dengan uji statistik
7. Matriks korelasi (2 variasi)
8. Network diagram (2 variasi)
9. Distribusi item difficulty
10. Perbandingan reliabilitas
11. Box plot semua aspek
12. Grafik persentil
13. Dashboard ringkasan
14. Dan banyak lagi...

### Visualisasi Interaktif (HTML):
1. Network 3D interaktif
2. Network force-directed D3
3. Network visNetwork
4. 3D Scatter plot dengan clustering
5. Dan lainnya...

## 🔧 Troubleshooting

### Masalah: Data tidak muncul di tabel

**Solusi:**
- Pastikan folder `tables/` berisi file CSV yang diperlukan
- Gunakan local server (bukan double-click) untuk membuka file
- Cek console browser (F12) untuk error messages

### Masalah: Gambar tidak muncul

**Solusi:**
- Pastikan folder `plots/` berisi file visualisasi
- Periksa path relatif file
- Refresh browser (Ctrl+F5 atau Cmd+Shift+R)

### Masalah: Visualisasi interaktif tidak dapat dibuka

**Solusi:**
- Pastikan file HTML interaktif ada di folder `plots/`
- Cek pop-up blocker browser Anda
- Coba buka file interaktif secara langsung dari folder `plots/`

## 📱 Kompatibilitas Browser

Laporan ini kompatibel dengan:
- ✅ Google Chrome (Recommended)
- ✅ Mozilla Firefox
- ✅ Microsoft Edge
- ✅ Safari
- ⚠️ Internet Explorer (Limited support)

## 🖨️ Mencetak Laporan

Untuk mencetak laporan:
1. Buka laporan di browser
2. Tekan Ctrl+P (Windows) atau Cmd+P (Mac)
3. Atur pengaturan cetak:
   - Layout: Portrait atau Landscape
   - Paper size: A4
   - Margins: Default
   - Background graphics: On (untuk mempertahankan warna)
4. Save as PDF atau Print

## 💾 Export Data

Semua data mentah tersedia dalam format CSV di folder `tables/`. Anda dapat:
- Import ke Excel/Google Sheets
- Analisis lebih lanjut dengan R/Python
- Integrasi dengan sistem lain

## 🔒 Keamanan dan Kerahasiaan

**PENTING:**
- Laporan ini bersifat RAHASIA
- Hanya untuk internal PT. Nirmala Satya Development
- Jangan share tanpa izin tertulis
- Hapus setelah selesai digunakan jika diperlukan

## 📞 Kontak dan Dukungan

Untuk pertanyaan atau dukungan teknis:

**PT. Data Riset Nusantara (PT.Darinusa)**
- Email: support@darinusa.co.id (contoh)
- Website: www.darinusa.co.id (contoh)
- Tim Konsultan Psikometri

## 📝 Changelog

### Version 2.0 (2026-01-07)
- ✨ Initial release dengan laporan interaktif lengkap
- 📊 20+ visualisasi berkualitas tinggi
- 🔄 Dynamic data loading dari CSV
- 📱 Responsive design
- 🎨 Professional styling

## 📜 Lisensi

© 2026 PT. Data Riset Nusantara (PT.Darinusa). All Rights Reserved.

Laporan ini adalah milik PT. Nirmala Satya Development dan dilindungi hak cipta.

---

**Terima kasih telah menggunakan Laporan Interaktif Analisis Psikometrik EPPS!**

Untuk feedback atau pertanyaan, silakan hubungi tim konsultan kami.
