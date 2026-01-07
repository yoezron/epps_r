# ============================================================================
# SCRIPT 10: VISUALISASI KOMPREHENSIF
# ============================================================================

load("output/data_processed.RData")

cat("\n=== MEMBUAT VISUALISASI KOMPREHENSIF ===\n")

library(ggplot2)
library(reshape2)
library(fmsb)
library(qgraph)
library(plotly)
library(htmlwidgets)

# ===== PROFILE PLOT MEAN SCORES =====
cat("\n--- Profile Plot ---\n")

mean_scores <- colMeans(skor_aspek, na.rm = TRUE)
sd_scores <- apply(skor_aspek, 2, sd, na.rm = TRUE)

profile_data <- data.frame(
  Aspek = factor(aspek_labels[aspek_epps], levels = aspek_labels[aspek_epps]),
  Mean = mean_scores,
  SD = sd_scores,
  Lower = mean_scores - sd_scores,
  Upper = mean_scores + sd_scores
)

p1 <- ggplot(profile_data, aes(x = Aspek, y = Mean)) +
  geom_point(size = 4, color = "steelblue") +
  geom_line(group = 1, color = "steelblue", size = 1) +
  geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.2, color = "gray50") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Profil Skor Rata-rata 15 Aspek EPPS",
       subtitle = "Error bars menunjukkan ±1 SD",
       x = "Aspek Kepribadian",
       y = "Skor Rata-rata")

ggsave("output/plots/Profile_MeanScores.png", p1, width = 12, height = 6, dpi = 300)

# ===== HEATMAP SKOR PER RESPONDEN (SAMPLE) =====
cat("\n--- Heatmap Skor ---\n")

set.seed(2025)
sample_resp <- sample(1:nrow(skor_aspek), min(100, nrow(skor_aspek)))
data_heatmap <- skor_aspek[sample_resp, ]
data_heatmap_scaled <- scale(data_heatmap)
colnames(data_heatmap_scaled) <- aspek_labels[aspek_epps]

# Tambahkan ID agar melt aman
data_heatmap_df <- as.data.frame(data_heatmap_scaled)
data_heatmap_df$Responden <- rownames(data_heatmap_df)

data_long <- melt(data_heatmap_df, id.vars = "Responden")
names(data_long) <- c("Responden", "Aspek", "Zscore")

p2 <- ggplot(data_long, aes(x = Aspek, y = factor(Responden), fill = Zscore)) +
  geom_tile() +
  scale_fill_gradient2(low = "#D73027", mid = "white", high = "#1A9850",
                       midpoint = 0, name = "Z-score") +
  theme_minimal(base_size = 10) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  labs(title = "Heatmap Skor 100 Responden (Z-score)",
       x = "Aspek", y = "Responden")

ggsave("output/plots/Heatmap_Scores.png", p2, width = 12, height = 10, dpi = 300)

# ===== DISTRIBUSI SKOR DENGAN DENSITY =====
cat("\n--- Density Plots ---\n")

# PERBAIKAN: Tambahkan ID Responden Eksplisit sebelum melt
df_melt_prep <- as.data.frame(skor_aspek)
df_melt_prep$Responden <- 1:nrow(df_melt_prep)

data_long_all <- melt(df_melt_prep, id.vars = "Responden")
# Sekarang kita punya 3 kolom: Responden, variable, value
names(data_long_all) <- c("Responden", "Aspek", "Skor")

# Map kode aspek ke label panjang
# Gunakan as.character untuk memastikan matching string yang benar
data_long_all$Aspek <- aspek_labels[as.character(data_long_all$Aspek)]

p3 <- ggplot(data_long_all, aes(x = Skor, fill = Aspek)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ Aspek, scales = "free", ncol = 5) +
  theme_minimal(base_size = 10) +
  theme(legend.position = "none") +
  labs(title = "Distribusi Skor 15 Aspek EPPS",
       x = "Skor", y = "Density")

ggsave("output/plots/Density_AllAspects.png", p3, width = 15, height = 9, dpi = 300)

# ===== VIOLIN PLOT =====
cat("\n--- Violin Plot ---\n")

# Kita gunakan data_long_all yang sudah diperbaiki di atas
p4 <- ggplot(data_long_all, aes(x = Aspek, y = Skor, fill = Aspek)) +
  geom_violin(trim = FALSE, alpha = 0.7) +
  geom_boxplot(width = 0.1, fill = "white", outlier.shape = NA) +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none") +
  labs(title = "Distribusi Skor per Aspek (Violin Plot)",
       x = "Aspek", y = "Skor")

ggsave("output/plots/Violin_Scores.png", p4, width = 14, height = 7, dpi = 300)

# ===== RADAR CHART (Mean Profile) =====
cat("\n--- Radar Chart ---\n")

radar_data <- data.frame(rbind(
  max = rep(max(mean_scores) + 5, 15),
  min = rep(0, 15),
  mean = mean_scores
))
colnames(radar_data) <- aspek_labels[aspek_epps]

png("output/plots/Radar_MeanProfile.png", width = 2400, height = 2400, res = 300)
radarchart(radar_data,
           axistype = 1,
           pcol = rgb(0.2, 0.5, 0.8, 0.8),
           pfcol = rgb(0.2, 0.5, 0.8, 0.4),
           plwd = 3,
           cglcol = "grey",
           cglty = 1,
           axislabcol = "grey",
           caxislabels = seq(0, max(mean_scores) + 5, length.out = 5),
           cglwd = 0.8,
           vlcex = 0.8,
           title = "Profil Rata-rata 15 Aspek EPPS (Radar Chart)")
dev.off()

# ===== PERBANDINGAN DEMOGRAFI =====
cat("\n--- Perbandingan Demografi ---\n")

# Cari kolom gender
gender_col <- names(data_raw)[grepl("Jenis.*Kelamin|Gender|Sex", names(data_raw), ignore.case = TRUE) &
                                !grepl("angka", names(data_raw), ignore.case = TRUE)][1]

if(!is.na(gender_col) && length(gender_col) > 0) {
  cat("Variabel Gender ditemukan:", gender_col, "\n")

  data_with_demo <- cbind(data_raw[, gender_col, drop = FALSE], skor_aspek)
  # Rename kolom pertama jadi JenisKelamin untuk konsistensi
  names(data_with_demo)[1] <- "JenisKelamin"

  # Melt data gender
  data_gender_long <- melt(data_with_demo, id.vars = "JenisKelamin")
  names(data_gender_long) <- c("Gender", "Aspek", "Skor")

  # Fix Labels
  data_gender_long$Aspek <- aspek_labels[as.character(data_gender_long$Aspek)]

  # Filter missing gender if needed
  data_gender_long <- data_gender_long[!is.na(data_gender_long$Gender) & data_gender_long$Gender != "", ]

  p5 <- ggplot(data_gender_long, aes(x = Aspek, y = Skor, fill = Gender)) +
    geom_boxplot(alpha = 0.7) +
    theme_minimal(base_size = 11) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_brewer(palette = "Set2") +
    labs(title = "Perbandingan Skor Berdasarkan Jenis Kelamin",
         x = "Aspek", y = "Skor")

  ggsave("output/plots/Comparison_Gender.png", p5, width = 14, height = 7, dpi = 300)
} else {
  cat("Variabel Gender tidak ditemukan. Skip plot demografi.\n")
}

# ===== 3D SCATTER (Top 3 Aspek) =====
cat("\n--- 3D Visualization ---\n")

# Pilih 3 aspek dengan varians tertinggi
var_aspek <- apply(skor_aspek, 2, var, na.rm = TRUE)
top3_aspek <- names(sort(var_aspek, decreasing = TRUE)[1:3])

sample_3d <- sample(1:nrow(skor_aspek), min(1000, nrow(skor_aspek)))
data_3d <- skor_aspek[sample_3d, top3_aspek]
colnames(data_3d) <- aspek_labels[top3_aspek]
data_3d_df <- as.data.frame(data_3d) # Pastikan jadi data frame

fig <- plot_ly(data = data_3d_df,
               x = as.formula(paste0("~`", colnames(data_3d)[1], "`")),
               y = as.formula(paste0("~`", colnames(data_3d)[2], "`")),
               z = as.formula(paste0("~`", colnames(data_3d)[3], "`")),
               type = "scatter3d",
               mode = "markers",
               marker = list(size = 3,
                             color = as.formula(paste0("~`", colnames(data_3d)[1], "`")),
                             colorscale = "Viridis",
                             showscale = TRUE)) %>%
  layout(title = paste("3D Scatter Plot (Top 3 Varians)"),
         scene = list(xaxis = list(title = colnames(data_3d)[1]),
                      yaxis = list(title = colnames(data_3d)[2]),
                      zaxis = list(title = colnames(data_3d)[3])))

saveWidget(fig, "output/plots/3D_Scatter.html", selfcontained = TRUE)

# ===== CORRELATION NETWORK DIAGRAM =====
cat("\n--- Correlation Network ---\n")

cor_matrix <- cor(skor_aspek, use = "pairwise.complete.obs")
colnames(cor_matrix) <- rownames(cor_matrix) <- aspek_labels[aspek_epps]

# Gunakan png() device agar lebih stabil saat save
png("output/plots/Correlation_Network.png", width = 3000, height = 3000, res = 300)
qgraph(cor_matrix,
       layout = "spring",
       graph = "cor",
       threshold = 0.1,
       labels = colnames(cor_matrix),
       label.cex = 1,
       node.width = 1.5,
       edge.labels = FALSE,
       title = "Network Korelasi Antar Aspek")
dev.off()

# ===== ITEM DIFFICULTY DISTRIBUTION =====
cat("\n--- Item Difficulty Distribution ---\n")

if(file.exists("output/tables/05_Parameter_2PL.csv")) {
  params_2pl <- read.csv("output/tables/05_Parameter_2PL.csv")

  p6 <- ggplot(params_2pl, aes(x = Difficulty, fill = Aspek)) +
    geom_histogram(bins = 30, alpha = 0.7, color = "black") +
    facet_wrap(~ Aspek, scales = "free_y", ncol = 5) +
    theme_minimal(base_size = 10) +
    theme(legend.position = "none") +
    labs(title = "Distribusi Item Difficulty (2PL) per Aspek",
         x = "Difficulty Parameter", y = "Frekuensi")

  ggsave("output/plots/ItemDifficulty_Distribution.png", p6, width = 15, height = 9, dpi = 300)
}

# ===== RELIABILITY COMPARISON =====
cat("\n--- Reliability Comparison ---\n")

if(file.exists("output/tables/03_Reliabilitas.csv")) {
  rel_data <- read.csv("output/tables/03_Reliabilitas.csv")

  rel_long <- melt(rel_data[, c("Aspek", "Alpha", "Omega")], id.vars = "Aspek")
  names(rel_long) <- c("Aspek", "Metric", "Value")

  p7 <- ggplot(rel_long, aes(x = Aspek, y = Value, fill = Metric)) +
    geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
    geom_hline(yintercept = 0.7, linetype = "dashed", color = "red") +
    theme_minimal(base_size = 11) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_brewer(palette = "Set1") +
    labs(title = "Perbandingan Reliabilitas (Alpha vs Omega)",
         subtitle = "Garis merah menunjukkan batas minimal 0.70",
         x = "Aspek", y = "Koefisien Reliabilitas")

  ggsave("output/plots/Reliability_Comparison.png", p7, width = 14, height = 7, dpi = 300)
}

cat("\n=== VISUALISASI SELESAI ===\n")
cat("Semua plot tersimpan di output/plots/\n")
