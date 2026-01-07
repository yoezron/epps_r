# ============================================================================
# SCRIPT 01: SETUP DAN PERSIAPAN DATA EPPS
# PT. Data Riset Nusantara untuk PT. Nirmala Satya Development
# ============================================================================

# Instalasi dan loading packages
packages <- c("ltm", "mirt", "psych", "thurstonianIRT", "ggplot2", "plotly",
              "corrplot", "lavaan", "qgraph", "bootnet", "dplyr", "tidyr",
              "gridExtra", "RColorBrewer", "reshape2", "car", "GPArotation")

for(pkg in packages) {
  if(!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# Set working directory
setwd("D:/1 NSD Project/EPPS/EPPS-Analysis")

# Buat folder output
dir.create("output", showWarnings = FALSE)
dir.create("output/plots", showWarnings = FALSE)
dir.create("output/tables", showWarnings = FALSE)
dir.create("output/models", showWarnings = FALSE)

# Load data dengan delimiter semicolon
data_raw <- read.csv("epps_raw.csv", fileEncoding = "UTF-8-BOM", sep = ";",
                     stringsAsFactors = FALSE, check.names = FALSE)

# Hapus kolom pertama jika kosong/hanya nomor
if(names(data_raw)[1] == "" || names(data_raw)[1] == "ï..#") {
  data_raw <- data_raw[, -1]
}

# Identifikasi kolom demografis dan item
# Cari kolom yang berisi demografis
demo_patterns <- c("#", "Responden", "Jenis Kelamin", "Tingkat Pendidikan",
                   "USIA", "Rentang Usia", "_angka")

demo_cols <- names(data_raw)[sapply(names(data_raw), function(x) {
  any(sapply(demo_patterns, function(p) grepl(p, x, fixed = TRUE)))
})]

# Ekstrak data item saja
data_items <- data_raw[, !names(data_raw) %in% demo_cols]

# Konversi semua kolom ke numeric
data_items[] <- lapply(data_items, function(x) as.numeric(as.character(x)))

# Ekstrak nama aspek dari nama kolom
get_trait_name <- function(col_name) {
  # Format: "2B - ACH" atau "2A - DEF"
  if(grepl(" - ", col_name)) {
    parts <- strsplit(col_name, " - ")[[1]]
    if(length(parts) >= 2) return(trimws(parts[2]))
  }
  return(NA)
}

trait_names <- sapply(names(data_items), get_trait_name)

# Definisi 15 aspek EPPS
aspek_epps <- c("ACH", "DEF", "ORD", "EXH", "AUT", "AFF", "INT", "SUC",
                "DOM", "ABA", "NUR", "CHG", "END", "HET", "AGG")

aspek_labels <- c(
  "ACH" = "Achievement",
  "DEF" = "Deference",
  "ORD" = "Order",
  "EXH" = "Exhibition",
  "AUT" = "Autonomy",
  "AFF" = "Affiliation",
  "INT" = "Intraception",
  "SUC" = "Succorance",
  "DOM" = "Dominance",
  "ABA" = "Abasement",
  "NUR" = "Nurturance",
  "CHG" = "Change",
  "END" = "Endurance",
  "HET" = "Heterosexuality",
  "AGG" = "Aggression"
)

# Agregasi skor per aspek (raw score)
skor_aspek <- as.data.frame(matrix(0, nrow = nrow(data_items), ncol = length(aspek_epps)))
names(skor_aspek) <- aspek_epps

for(aspek in aspek_epps) {
  item_cols <- which(trait_names == aspek)
  if(length(item_cols) > 0) {
    # Pastikan data numeric
    item_data <- data_items[, item_cols, drop = FALSE]
    item_data[] <- lapply(item_data, function(x) as.numeric(as.character(x)))
    skor_aspek[[aspek]] <- rowSums(item_data, na.rm = TRUE)
  }
}

# Gabungkan dengan data demografis
data_final <- tryCatch({
  cbind(data_raw[, demo_cols, drop = FALSE],
        skor_aspek,
        data_items)
}, error = function(e) {
  cat("Warning: Gagal menggabungkan data. Menggunakan alternatif.\n")
  data.frame(skor_aspek, data_items)
})

# Simpan data yang sudah diproses
save(data_raw, data_items, data_final, skor_aspek, trait_names,
     aspek_epps, aspek_labels, demo_cols,
     file = "output/data_processed.RData")

cat("\n=== DATA BERHASIL DIPROSES ===\n")
cat("Jumlah responden:", nrow(data_items), "\n")
cat("Jumlah item:", ncol(data_items), "\n")
cat("Aspek yang dianalisis:", length(aspek_epps), "\n")

# Tampilkan jumlah item per aspek
cat("\nJumlah item per aspek:\n")
for(aspek in aspek_epps) {
  n_items <- sum(trait_names == aspek, na.rm = TRUE)
  cat(sprintf("  %s (%s): %d item\n", aspek, aspek_labels[aspek], n_items))
}

cat("\nData tersimpan di: output/data_processed.RData\n")
