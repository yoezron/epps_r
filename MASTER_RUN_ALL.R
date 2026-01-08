# ============================================================================
# MASTER SCRIPT: ANALISIS PSIKOMETRIK KOMPREHENSIF EPPS
# PT. Data Riset Nusantara untuk PT. Nirmala Satya Development
# ============================================================================
#
# INSTRUKSI:
# 1. Set working directory ke folder EPPS-Analysis
# 2. Pastikan file epps_raw.csv ada di folder tersebut
# 3. Jalankan script ini atau jalankan script individual secara bertahap
# 
# ============================================================================

cat("\n")
cat("==============================================================================\n")
cat("        ANALISIS PSIKOMETRIK KOMPREHENSIF EPPS - MASTER SCRIPT\n")
cat("==============================================================================\n")
cat("\n")

# Cek working directory
current_wd <- getwd()
cat("Working directory saat ini:", current_wd, "\n")

# Cek file data
if(!file.exists("epps_raw.csv")) {
  stop("\nERROR: File 'epps_raw.csv' tidak ditemukan!\n",
       "Pastikan file ada di folder: ", current_wd, "\n")
}

cat("\n✓ File data ditemukan\n")

# Fungsi untuk menjalankan script dengan error handling
run_script <- function(script_name, description) {
  cat("\n")
  cat("------------------------------------------------------------------------------\n")
  cat(">>> MENJALANKAN:", description, "\n")
  cat("    Script:", script_name, "\n")
  cat("------------------------------------------------------------------------------\n")
  
  start_time <- Sys.time()
  
  tryCatch({
    source(script_name)
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)
    cat("\n✓ SELESAI -", description, "(", duration, "detik )\n")
    return(TRUE)
  }, error = function(e) {
    cat("\n✗ ERROR:", description, "\n")
    cat("  Pesan error:", e$message, "\n")
    return(FALSE)
  })
}

# ============================================================================
# JALANKAN ANALISIS BERTAHAP
# ============================================================================

cat("\nMulai analisis...\n")
start_total <- Sys.time()

results <- list()

# Script 01: Setup dan Persiapan Data
results$setup <- run_script("01_Setup_Data.R", 
                            "Setup dan Persiapan Data")

if(!results$setup) {
  stop("Setup data gagal. Analisis dihentikan.")
}

# Script 02: Deskriptif dan CTT
results$deskriptif <- run_script("02_Deskriptif_CTT.R",
                                 "Analisis Deskriptif dan Classical Test Theory")

# Script 03: IRT 2PL
results$irt_2pl <- run_script("03_IRT_2PL.R",
                              "IRT 2-Parameter Logistic Model")

# Script 04: IRT 3PL
results$irt_3pl <- run_script("04_IRT_3PL.R",
                              "IRT 3-Parameter Logistic Model")

# Script 05: MIRT
results$mirt <- run_script("05_MIRT.R",
                          "Multidimensional IRT")

# Script 06: Thurstonian IRT
results$tirt <- run_script("06_TIRT.R",
                          "Thurstonian IRT (Forced-Choice)")

# Script 07: Graded Response Model
results$grm <- run_script("07_GRM.R",
                         "Graded Response Model")

# Script 08: Network Analysis
results$network <- run_script("08_Network_Analysis.R",
                             "Network Analysis")

# Script 08B: Advanced Network Analysis
results$network_advanced <- run_script("08B_Advanced_Network.R",
                                      "Advanced Network Analysis (Extended Metrics)")

# Script 08C: Comparative Network Analysis
results$network_comparative <- run_script("08C_Comparative_Network.R",
                                         "Comparative Network & Predictability Analysis")

# Script 08D: Interactive Network Visualization
results$network_interactive <- run_script("08D_Interactive_Network.R",
                                         "Interactive Network & Dynamic Visualization")

# Script 09: Norma dan Scoring
results$norma <- run_script("09_Norma_Scoring.R",
                           "Pembuatan Norma dan Sistem Penyekoran")

# Script 10: Visualisasi
results$viz <- run_script("10_Visualisasi.R",
                         "Visualisasi Komprehensif")

# Script 11: Laporan
results$laporan <- run_script("11_Laporan.R",
                             "Pembuatan Laporan Psikometrik")

# ============================================================================
# SUMMARY
# ============================================================================

end_total <- Sys.time()
total_duration <- round(difftime(end_total, start_total, units = "mins"), 2)

cat("\n")
cat("==============================================================================\n")
cat("                          RINGKASAN EKSEKUSI\n")
cat("==============================================================================\n\n")

success_count <- sum(unlist(results))
total_count <- length(results)

cat("Total script dijalankan    :", total_count, "\n")
cat("Berhasil                   :", success_count, "\n")
cat("Gagal                      :", total_count - success_count, "\n")
cat("Total waktu eksekusi       :", total_duration, "menit\n\n")

cat("Status per script:\n")
for(i in 1:length(results)) {
  status <- ifelse(results[[i]], "✓ SUKSES", "✗ GAGAL")
  cat(sprintf("  %s: %s\n", names(results)[i], status))
}

cat("\n")
cat("==============================================================================\n")
cat("                          OUTPUT FILES\n")
cat("==============================================================================\n\n")

if(dir.exists("output")) {
  cat("Folder output/tables:\n")
  tables <- list.files("output/tables", pattern = "\\.csv$")
  cat("  Total tabel CSV:", length(tables), "file\n")
  
  cat("\nFolder output/plots:\n")
  plots <- list.files("output/plots", pattern = "\\.(png|html)$")
  cat("  Total visualisasi:", length(plots), "file\n")
  
  cat("\nFolder output/models:\n")
  models <- list.files("output/models", pattern = "\\.rds$")
  cat("  Total model tersimpan:", length(models), "file\n")
  
  cat("\nLaporan utama:\n")
  if(file.exists("output/LAPORAN_PSIKOMETRIK_EPPS.txt")) {
    cat("  ✓ LAPORAN_PSIKOMETRIK_EPPS.txt\n")
  }
}

cat("\n")
cat("==============================================================================\n")
cat("                          SELESAI\n")
cat("==============================================================================\n")
cat("\nSemua hasil analisis tersimpan di folder 'output/'\n")
cat("Silakan baca file LAPORAN_PSIKOMETRIK_EPPS.txt untuk ringkasan lengkap.\n\n")

# ============================================================================
# PANDUAN PENGGUNAAN
# ============================================================================

cat("==============================================================================\n")
cat("PANDUAN MENJALANKAN ANALISIS:\n")
cat("==============================================================================\n\n")

cat("OPSI 1 - Jalankan semua analisis sekaligus:\n")
cat('  source("MASTER_RUN_ALL.R")\n\n')

cat("OPSI 2 - Jalankan script individual bertahap:\n")
cat('  source("01_Setup_Data.R")\n')
cat('  source("02_Deskriptif_CTT.R")\n')
cat('  source("03_IRT_2PL.R")\n')
cat('  ... dan seterusnya\n\n')

cat("OPSI 3 - Jalankan analisis tertentu saja:\n")
cat("  Misalnya hanya Network Analysis (semua):\n")
cat('  load("output/data_processed.RData")\n')
cat('  source("08_Network_Analysis.R")\n')
cat('  source("08B_Advanced_Network.R")\n')
cat('  source("08C_Comparative_Network.R")\n')
cat('  source("08D_Interactive_Network.R")\n\n')

cat("==============================================================================\n\n")
