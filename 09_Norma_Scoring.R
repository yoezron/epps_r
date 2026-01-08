# ============================================================================
# SCRIPT 09: PEMBUATAN NORMA DAN SISTEM PENYEKORAN
# ============================================================================

load("output/data_processed.RData")

cat("\n=== PEMBUATAN NORMA PENYEKORAN EPPS ===\n")

# ===== NORMA BERDASARKAN RAW SCORE =====
cat("\n--- Norma Skor Mentah ---\n")

norma_raw <- data.frame(
  Aspek = aspek_labels[aspek_epps],
  Mean = numeric(15),
  SD = numeric(15),
  Min = numeric(15),
  Max = numeric(15),
  P10 = numeric(15),
  P25 = numeric(15),
  P50 = numeric(15),
  P75 = numeric(15),
  P90 = numeric(15)
)

for(i in 1:15) {
  aspek <- aspek_epps[i]
  scores <- skor_aspek[[aspek]]

  norma_raw[i, "Mean"] <- mean(scores, na.rm = TRUE)
  norma_raw[i, "SD"] <- sd(scores, na.rm = TRUE)
  norma_raw[i, "Min"] <- min(scores, na.rm = TRUE)
  norma_raw[i, "Max"] <- max(scores, na.rm = TRUE)
  norma_raw[i, "P10"] <- quantile(scores, 0.10, na.rm = TRUE)
  norma_raw[i, "P25"] <- quantile(scores, 0.25, na.rm = TRUE)
  norma_raw[i, "P50"] <- quantile(scores, 0.50, na.rm = TRUE)
  norma_raw[i, "P75"] <- quantile(scores, 0.75, na.rm = TRUE)
  norma_raw[i, "P90"] <- quantile(scores, 0.90, na.rm = TRUE)
}

norma_raw[, 2:10] <- round(norma_raw[, 2:10], 2)
write.csv(norma_raw, "output/tables/29_Norma_RawScore.csv", row.names = FALSE)

# ===== KONVERSI T-SCORE (Mean=50, SD=10) =====
cat("\n--- Konversi T-Score ---\n")

tscore_data <- skor_aspek
for(aspek in aspek_epps) {
  mean_val <- mean(skor_aspek[[aspek]], na.rm = TRUE)
  sd_val <- sd(skor_aspek[[aspek]], na.rm = TRUE)
  tscore_data[[paste0(aspek, "_T")]] <- 50 + 10 * (skor_aspek[[aspek]] - mean_val) / sd_val
}

# Tabel konversi T-score
tabel_konversi <- list()

for(aspek in aspek_epps) {
  raw_scores <- sort(unique(skor_aspek[[aspek]]))
  mean_val <- mean(skor_aspek[[aspek]], na.rm = TRUE)
  sd_val <- sd(skor_aspek[[aspek]], na.rm = TRUE)

  t_scores <- 50 + 10 * (raw_scores - mean_val) / sd_val

  tabel <- data.frame(
    Aspek = aspek_labels[aspek],
    RawScore = raw_scores,
    TScore = round(t_scores, 1)
  )

  tabel_konversi[[aspek]] <- tabel
}

all_konversi <- do.call(rbind, tabel_konversi)
write.csv(all_konversi, "output/tables/30_Tabel_Konversi_TScore.csv", row.names = FALSE)

# Simpan juga norma T-score untuk dashboard (dengan nama yang diharapkan)
write.csv(norma_raw, "output/tables/19_Norma_TScore.csv", row.names = FALSE)

# ===== PERCENTILE RANKS =====
cat("\n--- Percentile Ranks ---\n")

percentile_data <- skor_aspek
for(aspek in aspek_epps) {
  scores <- skor_aspek[[aspek]]
  percentile_data[[paste0(aspek, "_Percentile")]] <-
    ecdf(scores)(scores) * 100
}

# Simpan norma percentile untuk dashboard
norma_percentile <- data.frame(
  Aspek = aspek_labels[aspek_epps],
  P10 = norma_raw$P10,
  P25 = norma_raw$P25,
  P50 = norma_raw$P50,
  P75 = norma_raw$P75,
  P90 = norma_raw$P90
)
write.csv(norma_percentile, "output/tables/20_Norma_Percentile.csv", row.names = FALSE)

# ===== KATEGORI NORMATIF =====
cat("\n--- Kategori Normatif ---\n")

# Fungsi kategorisasi berdasarkan T-score
kategorisasi <- function(tscore) {
  ifelse(tscore >= 70, "Sangat Tinggi",
         ifelse(tscore >= 60, "Tinggi",
                ifelse(tscore >= 40, "Rata-rata",
                       ifelse(tscore >= 30, "Rendah", "Sangat Rendah"))))
}

kategori_data <- skor_aspek
for(aspek in aspek_epps) {
  t_col <- paste0(aspek, "_T")
  kategori_data[[paste0(aspek, "_Kategori")]] <-
    kategorisasi(tscore_data[[t_col]])
}

# Distribusi kategori per aspek
distribusi_kategori <- data.frame(
  Aspek = aspek_labels[aspek_epps],
  SangatTinggi = numeric(15),
  Tinggi = numeric(15),
  Ratarata = numeric(15),
  Rendah = numeric(15),
  SangatRendah = numeric(15)
)

for(i in 1:15) {
  aspek <- aspek_epps[i]
  kat_col <- paste0(aspek, "_Kategori")
  tbl <- table(kategori_data[[kat_col]])

  distribusi_kategori[i, "SangatTinggi"] <-
    ifelse("Sangat Tinggi" %in% names(tbl), tbl["Sangat Tinggi"], 0)
  distribusi_kategori[i, "Tinggi"] <-
    ifelse("Tinggi" %in% names(tbl), tbl["Tinggi"], 0)
  distribusi_kategori[i, "Ratarata"] <-
    ifelse("Rata-rata" %in% names(tbl), tbl["Rata-rata"], 0)
  distribusi_kategori[i, "Rendah"] <-
    ifelse("Rendah" %in% names(tbl), tbl["Rendah"], 0)
  distribusi_kategori[i, "SangatRendah"] <-
    ifelse("Sangat Rendah" %in% names(tbl), tbl["Sangat Rendah"], 0)
}

write.csv(distribusi_kategori, "output/tables/31_Distribusi_Kategori.csv", row.names = FALSE)

# ===== SKOR IRT-BASED (dari MIRT/TIRT jika ada) =====
cat("\n--- IRT-Based Scores ---\n")

# Load MIRT model jika ada
if(file.exists("output/models/MIRT_15dim.rds")) {
  model_mirt <- readRDS("output/models/MIRT_15dim.rds")

  # Estimate scores untuk semua responden (bisa memakan waktu)
  cat("Estimating IRT scores untuk semua responden...\n")

  # Gunakan sampling atau batch processing untuk efisiensi
  batch_size <- 1000
  n_batches <- ceiling(nrow(data_items) / batch_size)

  all_irt_scores <- list()

  for(b in 1:min(n_batches, 10)) {  # Maksimal 10 batch pertama
    start_idx <- (b-1) * batch_size + 1
    end_idx <- min(b * batch_size, nrow(data_items))

    batch_data <- data_items[start_idx:end_idx, ]
    batch_scores <- fscores(model_mirt, response.pattern = batch_data, method = "EAP")

    all_irt_scores[[b]] <- batch_scores

    cat("  Batch", b, "dari", n_batches, "selesai\n")
  }

  irt_scores <- do.call(rbind, all_irt_scores)
  colnames(irt_scores) <- aspek_labels[aspek_epps]

  # Convert ke T-score
  irt_tscores <- irt_scores
  for(i in 1:ncol(irt_scores)) {
    mean_val <- mean(irt_scores[, i], na.rm = TRUE)
    sd_val <- sd(irt_scores[, i], na.rm = TRUE)
    irt_tscores[, i] <- 50 + 10 * (irt_scores[, i] - mean_val) / sd_val
  }

  write.csv(irt_tscores, "output/tables/32_IRT_TScores_Sample.csv", row.names = FALSE)
}

# ===== NORMA BERDASARKAN DEMOGRAFI =====
cat("\n--- Norma Berdasarkan Demografi ---\n")

# Cari kolom gender dan pendidikan
gender_col <- names(data_raw)[grepl("Jenis Kelamin", names(data_raw)) &
                                !grepl("angka", names(data_raw), ignore.case = TRUE)][1]
edu_col <- names(data_raw)[grepl("Tingkat Pendidikan", names(data_raw)) &
                             !grepl("angka", names(data_raw), ignore.case = TRUE)][1]

# Norma berdasarkan Jenis Kelamin
if(!is.na(gender_col)) {
  norma_gender <- list()
  for(gender in unique(data_raw[[gender_col]])) {
    idx <- which(data_raw[[gender_col]] == gender)
    skor_gender <- skor_aspek[idx, ]

    norma_temp <- data.frame(
      JenisKelamin = gender,
      Aspek = aspek_labels[aspek_epps],
      Mean = colMeans(skor_gender, na.rm = TRUE),
      SD = apply(skor_gender, 2, sd, na.rm = TRUE)
    )

    norma_gender[[gender]] <- norma_temp
  }

  norma_gender_df <- do.call(rbind, norma_gender)
  write.csv(norma_gender_df, "output/tables/33_Norma_JenisKelamin.csv", row.names = FALSE)
}

# Norma berdasarkan Pendidikan
if(!is.na(edu_col)) {
  norma_edu <- list()
  for(edu in unique(data_raw[[edu_col]])) {
    idx <- which(data_raw[[edu_col]] == edu)
    if(length(idx) > 30) {  # Minimal 30 responden
      skor_edu <- skor_aspek[idx, ]

      norma_temp <- data.frame(
        Pendidikan = edu,
        Aspek = aspek_labels[aspek_epps],
        Mean = colMeans(skor_edu, na.rm = TRUE),
        SD = apply(skor_edu, 2, sd, na.rm = TRUE),
        N = length(idx)
      )

      norma_edu[[edu]] <- norma_temp
    }
  }

  if(length(norma_edu) > 0) {
    norma_edu_df <- do.call(rbind, norma_edu)
    write.csv(norma_edu_df, "output/tables/34_Norma_Pendidikan.csv", row.names = FALSE)
  }
}

cat("\n=== PEMBUATAN NORMA SELESAI ===\n")
cat("Norma raw score, T-score, percentile, dan kategori tersimpan\n")
cat("Norma demografis tersimpan\n")
