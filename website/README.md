# EPPS Analysis Report Website

> **Laporan Analisis Psikometrik Edwards Personal Preference Schedule (EPPS)**
> Website estetis dan interaktif untuk PT. Nirmala Satya Development

---

## 📋 Deskripsi

Website ini menampilkan hasil analisis psikometrik komprehensif dari instrumen Edwards Personal Preference Schedule (EPPS) yang dilakukan oleh PT. Data Riset Nusantara (Darinusa) untuk PT. Nirmala Satya Development.

### Fitur Utama

✅ **Desain Modern & Responsif**
- Tampilan estetis dengan gradient dan animasi halus
- Responsif untuk desktop, tablet, dan mobile
- Smooth scrolling dan transisi yang mulus

✅ **Visualisasi Interaktif**
- Grafik dinamis menggunakan Chart.js
- Tabel interaktif dengan DataTables
- Galeri gambar hasil analisis

✅ **Konten Komprehensif**
- 15 aspek kepribadian EPPS
- Profil demografis responden
- Analisis reliabilitas (McDonald's Omega)
- Statistik deskriptif
- Item Response Theory (IRT) Analysis
- Network Analysis
- Galeri visualisasi lengkap

---

## 📁 Struktur Folder

```
website/
├── index.html              # Halaman utama
├── css/
│   └── style.css          # Custom stylesheet
├── js/
│   └── main.js            # JavaScript untuk interaktivitas
├── assets/
│   └── plots/             # Semua visualisasi dari analisis
└── data/
    └── tables/            # Data CSV dari hasil analisis
```

---

## 🚀 Cara Menggunakan

### Metode 1: Buka Langsung di Browser

1. **Buka File Explorer** dan navigasi ke folder `website/`
2. **Double-click** pada file `index.html`
3. Website akan terbuka di browser default Anda

### Metode 2: Menggunakan Local Server (Recommended)

Untuk pengalaman terbaik, gunakan local web server:

#### Menggunakan Python:

```bash
# Python 3
cd website
python -m http.server 8000

# Python 2
cd website
python -m SimpleHTTPServer 8000
```

Kemudian buka browser dan akses: `http://localhost:8000`

#### Menggunakan Node.js (http-server):

```bash
# Install http-server (sekali saja)
npm install -g http-server

# Jalankan server
cd website
http-server -p 8000
```

Kemudian buka browser dan akses: `http://localhost:8000`

#### Menggunakan PHP:

```bash
cd website
php -S localhost:8000
```

Kemudian buka browser dan akses: `http://localhost:8000`

#### Menggunakan VS Code Live Server:

1. Install extension "Live Server" di VS Code
2. Buka folder `website/` di VS Code
3. Right-click pada `index.html`
4. Pilih "Open with Live Server"

---

## 📊 Konten Website

### 1. **Beranda (Hero Section)**
- Judul laporan
- Informasi klien dan konsultan
- Tombol navigasi cepat
- Opsi download laporan lengkap

### 2. **Overview**
- 4 statistik utama dalam kartu (Total Responden, Total Item, Aspek, Reliabilitas)
- Informasi ringkas tentang analisis

### 3. **15 Aspek Kepribadian EPPS**
Penjelasan singkat untuk setiap aspek:
- Achievement (ACH)
- Deference (DEF)
- Order (ORD)
- Exhibition (EXH)
- Autonomy (AUT)
- Affiliation (AFF)
- Intraception (INT)
- Succorance (SUC)
- Dominance (DOM)
- Abasement (ABA)
- Nurturance (NUR)
- Change (CHG)
- Endurance (END)
- Heterosexuality (HET)
- Aggression (AGG)

### 4. **Profil Demografis**
- Grafik distribusi jenis kelamin (Doughnut Chart)
- Grafik distribusi pendidikan (Bar Chart)
- Statistik detail dalam tabel

### 5. **Analisis Reliabilitas**
- Bar chart horizontal McDonald's Omega
- Tabel detail dengan interpretasi
- Color-coded berdasarkan tingkat reliabilitas

### 6. **Statistik Deskriptif**
- Grafik rata-rata skor per aspek
- Tabel lengkap dengan Mean, SD, Min, Max, Median, Skewness

### 7. **IRT Analysis**
- Penjelasan model 2PL dan 3PL
- Visualisasi Item Characteristic Curves (ICC)
- Penjelasan parameter IRT

### 8. **Network Analysis**
- Network visualization (Circle Layout)
- Centrality measures
- Bridge centrality
- Interpretasi hubungan antar aspek

### 9. **Galeri Visualisasi**
Tab-based gallery dengan kategori:
- **Korelasi**: Heatmap dan scatterplot
- **Distribusi**: Histogram dan density plot
- **Network**: Berbagai layout network
- **IRT**: ICC dan IIC curves

---

## 🎨 Teknologi yang Digunakan

### Frontend Framework & Libraries

- **HTML5**: Struktur markup semantic
- **CSS3**: Styling modern dengan custom properties
- **Bootstrap 5.3**: Responsive grid dan komponen
- **Chart.js 4.4**: Visualisasi data interaktif
- **DataTables**: Tabel interaktif dengan sorting dan search
- **AOS (Animate On Scroll)**: Animasi scroll yang smooth
- **Bootstrap Icons**: Icon set lengkap

### Fonts

- **Inter**: Font body yang clean dan modern
- **Poppins**: Font heading yang bold dan menarik

### Color Scheme

- **Primary**: #4f46e5 (Indigo)
- **Success**: #10b981 (Green)
- **Warning**: #f59e0b (Amber)
- **Danger**: #ef4444 (Red)
- **Info**: #3b82f6 (Blue)

---

## 🔧 Kustomisasi

### Mengubah Warna

Edit file `css/style.css` di bagian `:root`:

```css
:root {
    --primary-color: #4f46e5;    /* Ubah warna utama */
    --secondary-color: #10b981;  /* Ubah warna sekunder */
    /* ... */
}
```

### Menambah Data

1. **Tambah tabel CSV**: Letakkan di folder `data/tables/`
2. **Tambah visualisasi**: Letakkan di folder `assets/plots/`
3. **Update JavaScript**: Edit `js/main.js` untuk memuat data baru

### Mengubah Konten

Edit file `index.html` untuk mengubah:
- Teks dan deskripsi
- Struktur section
- Konten informasi

---

## 📱 Kompatibilitas Browser

Website ini kompatibel dengan:

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+
- ✅ Opera 76+

---

## 📄 Data Sources

Semua data berasal dari analisis psikometrik EPPS yang dilakukan menggunakan:

- **Classical Test Theory (CTT)**
- **Item Response Theory (IRT)**: 2PL, 3PL, MIRT
- **Network Analysis**: Gaussian Graphical Model
- **Reliability Analysis**: Cronbach's Alpha, McDonald's Omega

Pipeline analisis lengkap tersedia di repository utama (`MASTER_RUN_ALL.R`).

---

## 🔒 Keamanan & Privacy

- ⚠️ **CONFIDENTIAL**: Website ini berisi data rahasia PT. Nirmala Satya Development
- 🚫 Dilarang mempublikasikan atau membagikan tanpa izin tertulis
- 🔐 Hanya untuk penggunaan internal dan presentasi resmi

---

## 📞 Dukungan

Untuk pertanyaan atau dukungan teknis:

**PT. Data Riset Nusantara (Darinusa)**
Tim Konsultan Psikometri

**PT. Nirmala Satya Development**
Klien

---

## 🎯 Deployment Options

### Option 1: Static Hosting

Upload folder `website/` ke layanan hosting statis:

- **GitHub Pages**: Gratis untuk repository public
- **Netlify**: Gratis dengan custom domain
- **Vercel**: Gratis dengan auto-deployment
- **Firebase Hosting**: Gratis tier tersedia

### Option 2: Internal Server

Deploy ke server internal perusahaan:

1. Upload semua file ke web server
2. Pastikan web server (Apache/Nginx) sudah dikonfigurasi
3. Set permissions yang sesuai
4. Akses melalui domain internal

### Option 3: Docker Container

```dockerfile
FROM nginx:alpine
COPY website/ /usr/share/nginx/html/
EXPOSE 80
```

Build dan jalankan:

```bash
docker build -t epps-website .
docker run -p 8080:80 epps-website
```

---

## 📋 Checklist Deployment

Sebelum deploy, pastikan:

- [ ] Semua file ada (HTML, CSS, JS, images, data)
- [ ] Path relatif sudah benar (tidak ada absolute path)
- [ ] Browser compatibility sudah ditest
- [ ] Mobile responsive sudah diverifikasi
- [ ] Data CSV terbaru sudah diupdate
- [ ] Visualisasi terbaru sudah ada
- [ ] Footer information sudah benar
- [ ] Link download laporan berfungsi

---

## 🚀 Performance Tips

### Optimasi Loading

1. **Compress Images**: Gunakan tools seperti TinyPNG untuk compress PNG
2. **Minify CSS/JS**: Gunakan minifier untuk production
3. **Enable Caching**: Set cache headers di web server
4. **Use CDN**: Bootstrap dan libraries lain sudah dari CDN

### Best Practices

- Gunakan local server untuk development
- Test di berbagai browser
- Verify responsive design di mobile
- Check console untuk errors
- Validate HTML/CSS

---

## 📝 Version History

### Version 1.0 (Januari 2026)

- ✅ Initial release
- ✅ 15 aspek kepribadian
- ✅ Visualisasi demografis
- ✅ Analisis reliabilitas
- ✅ Statistik deskriptif
- ✅ IRT Analysis
- ✅ Network Analysis
- ✅ Galeri visualisasi
- ✅ Responsive design
- ✅ Interactive charts

---

## 📜 License

© 2026 PT. Data Riset Nusantara (Darinusa) & PT. Nirmala Satya Development

**CONFIDENTIAL - All Rights Reserved**

Unauthorized distribution, reproduction, or use is strictly prohibited.

---

## 🙏 Credits

**Developed by:**
PT. Data Riset Nusantara (Darinusa)
Tim Konsultan Psikometri

**For:**
PT. Nirmala Satya Development (PT.NSD)

**Technologies:**
- Bootstrap Team
- Chart.js Team
- DataTables
- AOS Library
- Google Fonts

---

**Happy Exploring! 📊 🎉**

*Website ini merepresentasikan best practices dalam visualisasi data psikometrik modern, menggabungkan analisis mendalam dengan presentasi yang menarik dan user-friendly.*
