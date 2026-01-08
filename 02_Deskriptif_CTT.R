# ============================================================================
# SCRIPT 02: ANALISIS DESKRIPTIF DAN CLASSICAL TEST THEORY
# ============================================================================

load("output/data_processed.RData")

# ===== STATISTIK DESKRIPTIF DEMOGRAFIS =====
cat("\n=== ANALISIS DESKRIPTIF DEMOGRAFIS ===\n")

# Cari kolom gender
gender_col <- names(data_raw)[grepl("Jenis Kelamin", names(data_raw)) &
                                !grepl("angka", names(data_raw), ignore.case = TRUE)][1]

# Cari kolom pendidikan
edu_col <- names(data_raw)[grepl("Tingkat Pendidikan", names(data_raw)) &
                             !grepl("angka", names(data_raw), ignore.case = TRUE)][1]

# Cari kolom usia
usia_col <- names(data_raw)[grepl("^USIA$", names(data_raw))][1]

# Distribusi jenis kelamin
if(!is.na(gender_col)) {
  tbl_gender <- table(data_raw[[gender_col]])
  prop_gender <- prop.table(tbl_gender) * 100

  write.csv(data.frame(
    Kategori = names(tbl_gender),
    Frekuensi = as.numeric(tbl_gender),
    Persentase = round(prop_gender, 2)
  ), "output/tables/01_Demografis_JenisKelamin.csv", row.names = FALSE)
}

# Distribusi pendidikan
if(!is.na(edu_col)) {
  tbl_edu <- table(data_raw[[edu_col]])
  prop_edu <- prop.table(tbl_edu) * 100

  write.csv(data.frame(
    Kategori = names(tbl_edu),
    Frekuensi = as.numeric(tbl_edu),
    Persentase = round(prop_edu, 2)
  ), "output/tables/01_Demografis_Pendidikan.csv", row.names = FALSE)
}

# Statistik usia
if(!is.na(usia_col)) {
  usia_data <- as.numeric(data_raw[[usia_col]])
  stat_usia <- data.frame(
    Mean = mean(usia_data, na.rm = TRUE),
    SD = sd(usia_data, na.rm = TRUE),
    Min = min(usia_data, na.rm = TRUE),
    Max = max(usia_data, na.rm = TRUE),
    Median = median(usia_data, na.rm = TRUE)
  )

  write.csv(stat_usia, "output/tables/01_Statistik_Usia.csv", row.names = FALSE)
}

# ===== STATISTIK DESKRIPTIF SKOR ASPEK =====
cat("\n=== STATISTIK DESKRIPTIF SKOR ASPEK ===\n")

desc_aspek <- describe(skor_aspek)
desc_aspek$Aspek <- aspek_labels[rownames(desc_aspek)]
desc_aspek <- desc_aspek[, c("Aspek", "n", "mean", "sd", "min", "max",
                             "median", "skew", "kurtosis")]

write.csv(desc_aspek, "output/tables/01_Deskriptif_Aspek.csv", row.names = TRUE)

# ===== RELIABILITAS (CRONBACH'S ALPHA & OMEGA) =====
cat("\n=== ANALISIS RELIABILITAS ===\n")

reliabilitas <- data.frame(
  Aspek = character(),
  Jumlah_Item = integer(),
  Alpha = numeric(),
  Omega = numeric(),
  stringsAsFactors = FALSE
)

for(aspek in aspek_epps) {
  item_cols <- which(trait_names == aspek)
  if(length(item_cols) > 2) {
    data_aspek <- data_items[, item_cols, drop = FALSE]
    data_aspek <- data_aspek[complete.cases(data_aspek), ]

    # Cronbach's Alpha
    alpha_result <- tryCatch({
      alpha(data_aspek)
    }, error = function(e) {
      list(total = list(raw_alpha = NA))
    })
    alpha_val <- alpha_result$total$raw_alpha

    # McDonald's Omega
    omega_result <- tryCatch({
      omega(data_aspek, nfactors = 1, plot = FALSE)$omega.tot
    }, error = function(e) NA)

    reliabilitas <- rbind(reliabilitas, data.frame(
      Aspek = aspek_labels[aspek],
      Jumlah_Item = length(item_cols),
      Alpha = round(alpha_val, 3),
      Omega = round(omega_result, 3)
    ))
  }
}

write.csv(reliabilitas, "output/tables/02_Reliabilitas_Aspek.csv", row.names = FALSE)

# ===== ITEM ANALYSIS (untuk dashboard) =====
cat("\n=== ITEM ANALYSIS ===\n")

item_analysis <- data.frame(
  Item = character(),
  Aspek = character(),
  Mean = numeric(),
  SD = numeric(),
  stringsAsFactors = FALSE
)

for(aspek in aspek_epps) {
  item_cols <- which(trait_names == aspek)
  if(length(item_cols) > 0) {
    data_aspek <- data_items[, item_cols, drop = FALSE]
    data_aspek <- data_aspek[complete.cases(data_aspek), ]

    for(i in 1:ncol(data_aspek)) {
      item_analysis <- rbind(item_analysis, data.frame(
        Item = names(data_aspek)[i],
        Aspek = aspek_labels[aspek],
        Mean = round(mean(data_aspek[, i], na.rm = TRUE), 3),
        SD = round(sd(data_aspek[, i], na.rm = TRUE), 3)
      ))
    }
  }
}

write.csv(item_analysis, "output/tables/03_Item_Analysis.csv", row.names = FALSE)

# ===== KORELASI ANTAR ASPEK =====
cat("\n=== KORELASI ANTAR ASPEK ===\n")

cor_matrix <- cor(skor_aspek, use = "pairwise.complete.obs")
colnames(cor_matrix) <- rownames(cor_matrix) <- aspek_labels[aspek_epps]

write.csv(cor_matrix, "output/tables/04_Korelasi_Aspek.csv", row.names = TRUE)

# Visualisasi korelasi
png("output/plots/01_Korelasi_Aspek.png", width = 2400, height = 2400, res = 300)
corrplot(cor_matrix, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45, tl.cex = 0.8,
         addCoef.col = "black", number.cex = 0.6,
         col = colorRampPalette(c("#D73027", "white", "#1A9850"))(200),
         title = "Matriks Korelasi Antar Aspek EPPS",
         mar = c(0,0,2,0))
dev.off()

# Simpan juga dengan nama untuk dashboard
png("output/plots/Correlation_Heatmap.png", width = 2400, height = 2400, res = 300)
corrplot(cor_matrix, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45, tl.cex = 0.8,
         addCoef.col = "black", number.cex = 0.6,
         col = colorRampPalette(c("#D73027", "white", "#1A9850"))(200),
         title = "Matriks Korelasi Antar Aspek EPPS",
         mar = c(0,0,2,0))
dev.off()

# ===== DISTRIBUSI SKOR =====
png("output/plots/02_Distribusi_Skor_Aspek.png", width = 4000, height = 3000, res = 300)
par(mfrow = c(3, 5), mar = c(4, 4, 2, 1))
for(i in 1:length(aspek_epps)) {
  hist(skor_aspek[, aspek_epps[i]],
       main = aspek_labels[aspek_epps[i]],
       xlab = "Skor", ylab = "Frekuensi",
       col = "steelblue", border = "white")
  abline(v = mean(skor_aspek[, aspek_epps[i]], na.rm = TRUE),
         col = "red", lwd = 2, lty = 2)
}
dev.off()

cat("\n=== ANALISIS DESKRIPTIF SELESAI ===\n")
cat("Output tersimpan di folder output/tables/ dan output/plots/\n")
