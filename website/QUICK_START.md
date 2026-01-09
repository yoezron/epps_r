# 🚀 Quick Start Guide - EPPS Website

## ⚡ Cara Tercepat Membuka Website

### ✅ OPSI 1: Langsung Buka di Browser (RECOMMENDED untuk pemula)

1. **Double-click** file `index.html`
2. Website akan otomatis terbuka di browser
3. **Semua grafik dan data akan muncul** (menggunakan embedded data)

> 💡 **Catatan**: Versi terbaru website sudah memiliki embedded data, jadi tidak perlu web server!

---

### ✅ OPSI 2: Menggunakan Web Server (BEST EXPERIENCE)

Untuk pengalaman terbaik dengan akses ke semua fitur:

#### **Windows:**

```cmd
# Cara 1: Double-click launcher
start_server.bat

# Cara 2: Manual dengan Python
cd website
python -m http.server 8000
```

Lalu buka browser: `http://localhost:8000`

#### **Linux / Mac:**

```bash
# Cara 1: Launcher script
cd website
./start_server.sh

# Cara 2: Manual dengan Python
cd website
python3 -m http.server 8000
```

Lalu buka browser: `http://localhost:8000`

---

## 🎯 Verifikasi Website Berfungsi

Ketika website terbuka dengan benar, Anda akan melihat:

✅ **Profil Demografis**:
- Grafik Pie Jenis Kelamin (Laki-laki 60.19%, Perempuan 39.81%)
- Grafik Bar Pendidikan (SMA, D3, S1, S2, S3)

✅ **Analisis Reliabilitas**:
- Grafik Bar horizontal McDonald's Omega untuk 15 aspek
- Tabel dengan interpretasi (Excellent, Good, Acceptable, Questionable)

✅ **Statistik Deskriptif**:
- Grafik Bar horizontal Mean Scores untuk 15 aspek
- Tabel detail dengan N, Mean, SD, Min, Max, Median, Skewness

---

## 🔍 Debug Mode

Jika ada masalah, buka **Browser Console** (tekan F12) dan lihat:

```
🚀 Initializing EPPS Dashboard...
✅ AOS initialized
📊 Loading demographics data...
✅ Demographics data loaded from embedded source
📊 Loading reliability data...
✅ Reliability data loaded from embedded source
📊 Loading descriptive data...
✅ Descriptive data loaded from embedded source
✅ Dashboard initialized successfully
```

> **Catatan**: Jika Anda melihat "loaded from CSV" berarti web server berfungsi.
> Jika Anda melihat "loaded from embedded source" berarti menggunakan data backup (ini juga OK!).

---

## ❓ Troubleshooting Cepat

### 1. Grafik tidak muncul?

**Solusi:**
- ✅ Pastikan browser Anda modern (Chrome, Firefox, Edge, Safari terbaru)
- ✅ Refresh halaman (Ctrl+R atau Cmd+R)
- ✅ Hard refresh (Ctrl+Shift+R atau Cmd+Shift+R)
- ✅ Buka console (F12) untuk lihat error

### 2. Tabel kosong?

**Solusi:**
- ✅ Scroll ke bawah (tabel ada di bawah grafik)
- ✅ Refresh halaman
- ✅ Cek console untuk error

### 3. Website lambat loading?

**Solusi:**
- ✅ Tunggu beberapa detik (banyak visualisasi yang perlu di-load)
- ✅ Koneksi internet stabil (untuk load library dari CDN)
- ✅ Close tab browser lain yang tidak perlu

### 4. Animasi tidak smooth?

**Solusi:**
- ✅ Close aplikasi lain yang menggunakan banyak resource
- ✅ Update browser ke versi terbaru
- ✅ Gunakan browser modern (Chrome recommended)

### 5. Data berbeda dengan yang di CSV?

**Catatan:**
- Jika buka langsung file HTML: menggunakan **embedded data** (data sampel terbaru)
- Jika pakai web server: menggunakan **data dari CSV** (data lengkap)
- Keduanya valid dan menggunakan data yang sama!

---

## 💡 Tips Penggunaan

### Navigation
- **Klik menu** di navbar untuk jump ke section
- **Scroll smooth** otomatis aktif
- **Tombol ↑** muncul ketika scroll ke bawah (kembali ke atas)

### Visualisasi
- **Hover** pada grafik untuk detail
- **Klik legend** untuk hide/show data
- **Tabs** di galeri visualisasi untuk kategori berbeda

### Tabel
- **Klik header** untuk sorting
- **Search box** untuk cari data
- **Scroll horizontal** untuk kolom yang banyak

### Download
- **Klik tombol Download** di hero section untuk laporan lengkap

---

## 📱 Mobile View

Website fully responsive! Di mobile:
- Menu berubah jadi hamburger icon (☰)
- Grafik otomatis menyesuaikan ukuran
- Tabel bisa di-scroll horizontal
- Semua fitur tetap berfungsi

---

## 🎨 Screenshot Normal (Reference)

Website yang berfungsi dengan baik akan menampilkan:

1. **Hero Section**: Gradient purple-pink dengan judul dan tombol
2. **Stats Cards**: 4 kartu dengan angka besar (6,464, 420, 15, 0.67)
3. **15 Aspect Cards**: Grid kartu berwarna dengan icon
4. **Demographics**: 2 grafik side-by-side
5. **Reliability**: 1 grafik horizontal + 1 tabel
6. **Descriptive**: 1 grafik horizontal + 1 tabel
7. **IRT Analysis**: Gambar ICC curves
8. **Network**: Diagram network circular
9. **Gallery**: Tabs dengan banyak visualisasi

---

## 📞 Masih Bermasalah?

Jika masih ada masalah:

1. ✅ Coba browser lain (Chrome, Firefox, Edge)
2. ✅ Clear browser cache
3. ✅ Disable browser extensions
4. ✅ Cek koneksi internet
5. ✅ Pastikan file lengkap (tidak corrupt saat download)

---

## 🎯 System Requirements

### Minimum:
- Browser: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- RAM: 4GB
- Internet: Untuk load CDN libraries (Bootstrap, Chart.js, etc.)

### Recommended:
- Browser: Chrome latest version
- RAM: 8GB
- Screen: 1920x1080 atau lebih
- Internet: Broadband

---

**Happy Exploring! 📊**

*Jika semua berfungsi dengan baik, Anda akan melihat dashboard yang cantik dengan banyak grafik dan tabel interaktif!*
