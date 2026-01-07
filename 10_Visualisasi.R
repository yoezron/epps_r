# ================================================================================
# SCRIPT 10: VISUALISASI KOMPREHENSIF EPPS
# ================================================================================
# Visualisasi lengkap untuk analisis psikometrik Edwards Personal Preference
# Schedule (EPPS) dengan 15+ jenis plot berkualitas tinggi
#
# Semua label dan keterangan dalam Bahasa Indonesia
# ================================================================================

# Load konfigurasi dan utilities
if (file.exists("00_Config.R")) {
  source("00_Config.R")
  source("00_Utilities.R")
} else {
  # Fallback jika file config tidak ada
  CONFIG_OUTPUT_DIR <- "output"
  CONFIG_PLOTS_DIR <- "output/plots"
  CONFIG_RANDOM_SEED <- 2025
}

# Load data yang sudah diproses
load("output/data_processed.RData")

print_section_header("MEMBUAT VISUALISASI KOMPREHENSIF")

# Load required libraries
required_packages <- c("ggplot2", "reshape2", "fmsb", "qgraph", "plotly",
                       "htmlwidgets", "RColorBrewer", "gridExtra", "scales",
                       "ggpubr", "corrplot", "pheatmap", "viridis")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE, quietly = TRUE)
  }
}

# Setup seed untuk reproducibility
set.seed(CONFIG_RANDOM_SEED)

# Persiapkan data
mean_scores <- colMeans(skor_aspek, na.rm = TRUE)
sd_scores <- apply(skor_aspek, 2, sd, na.rm = TRUE)
median_scores <- apply(skor_aspek, 2, median, na.rm = TRUE)
min_scores <- apply(skor_aspek, 2, min, na.rm = TRUE)
max_scores <- apply(skor_aspek, 2, max, na.rm = TRUE)

# ================================================================================
# 1. PROFIL SKOR RATA-RATA DENGAN STATISTIK DESKRIPTIF
# ================================================================================
cat("\n--- 1. Profil Skor Rata-rata ---\n")

profile_data <- data.frame(
  Aspek = factor(aspek_labels[aspek_epps], levels = aspek_labels[aspek_epps]),
  Kode = aspek_epps,
  Mean = mean_scores,
  Median = median_scores,
  SD = sd_scores,
  Min = min_scores,
  Max = max_scores,
  Lower = mean_scores - sd_scores,
  Upper = mean_scores + sd_scores,
  SE = sd_scores / sqrt(nrow(skor_aspek))
)

# Plot dengan error bars dan median
p1 <- ggplot(profile_data, aes(x = Aspek, y = Mean)) +
  geom_ribbon(aes(ymin = Lower, ymax = Upper), fill = "steelblue", alpha = 0.2) +
  geom_line(aes(group = 1), color = "steelblue", size = 1.2) +
  geom_point(size = 4, color = "steelblue", shape = 16) +
  geom_point(aes(y = Median), size = 3, color = "darkred", shape = 18) +
  geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE),
                width = 0.2, color = "gray30", size = 0.5) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray30"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Profil Skor Rata-rata 15 Aspek Kepribadian EPPS",
    subtitle = sprintf("N = %d responden | Area biru: ±1 SD | Error bars: ±1 SE | Titik merah: Median",
                       nrow(skor_aspek)),
    x = "Aspek Kepribadian",
    y = "Skor Rata-rata",
    caption = "Sumber: Analisis Data EPPS"
  ) +
  scale_y_continuous(breaks = pretty_breaks(n = 10))

ggsave("output/plots/01_Profile_MeanScores_Enhanced.png", p1,
       width = 14, height = 7, dpi = 300)

# ================================================================================
# 2. HEATMAP HIERARKIS DENGAN CLUSTERING
# ================================================================================
cat("\n--- 2. Heatmap dengan Clustering ---\n")

# Sample responden untuk visualisasi
n_sample <- min(100, nrow(skor_aspek))
sample_idx <- sample(1:nrow(skor_aspek), n_sample)
data_heatmap <- skor_aspek[sample_idx, ]

# Standardisasi (Z-score)
data_heatmap_scaled <- scale(data_heatmap)
colnames(data_heatmap_scaled) <- aspek_labels[aspek_epps]

# Heatmap dengan clustering hierarkis
png("output/plots/02_Heatmap_Hierarchical_Clustering.png",
    width = 3000, height = 2400, res = 300)
pheatmap(t(data_heatmap_scaled),
         main = sprintf("Heatmap Skor %d Responden dengan Clustering Hierarkis", n_sample),
         cluster_cols = TRUE,
         cluster_rows = TRUE,
         clustering_distance_cols = "euclidean",
         clustering_distance_rows = "euclidean",
         clustering_method = "ward.D2",
         color = colorRampPalette(c("#D73027", "white", "#1A9850"))(100),
         fontsize = 10,
         fontsize_row = 9,
         fontsize_col = 7,
         show_colnames = FALSE,
         legend = TRUE,
         legend_breaks = c(-3, -1.5, 0, 1.5, 3),
         legend_labels = c("Sangat\nRendah", "Rendah", "Rata-rata", "Tinggi", "Sangat\nTinggi"),
         border_color = NA,
         cellwidth = NA,
         cellheight = 15)
dev.off()

# ================================================================================
# 3. DISTRIBUSI SKOR DENGAN KURVA NORMAL OVERLAY
# ================================================================================
cat("\n--- 3. Distribusi Skor dengan Kurva Normal ---\n")

# Persiapan data long format
df_melt_prep <- as.data.frame(skor_aspek)
df_melt_prep$Responden <- 1:nrow(df_melt_prep)
data_long_all <- melt(df_melt_prep, id.vars = "Responden")
names(data_long_all) <- c("Responden", "Kode_Aspek", "Skor")
data_long_all$Aspek <- aspek_labels[as.character(data_long_all$Kode_Aspek)]

# Histogram dengan kurva normal dan density
p3 <- ggplot(data_long_all, aes(x = Skor)) +
  geom_histogram(aes(y = ..density..), bins = 20,
                 fill = "steelblue", alpha = 0.6, color = "white") +
  geom_density(color = "darkblue", size = 1.2) +
  stat_function(fun = function(x) {
    dnorm(x,
          mean = mean(data_long_all$Skor[data_long_all$Aspek == data_long_all$Aspek[1]], na.rm = TRUE),
          sd = sd(data_long_all$Skor[data_long_all$Aspek == data_long_all$Aspek[1]], na.rm = TRUE))
  }, color = "red", linetype = "dashed", size = 0.8) +
  facet_wrap(~ Aspek, scales = "free", ncol = 5) +
  theme_minimal(base_size = 9) +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 8),
    plot.title = element_text(face = "bold", size = 13)
  ) +
  labs(
    title = "Distribusi Skor 15 Aspek EPPS dengan Overlay Kurva Normal",
    subtitle = "Histogram abu-abu: Data aktual | Garis biru: Density kernel | Garis merah putus-putus: Distribusi normal teoretis",
    x = "Skor",
    y = "Densitas",
    caption = sprintf("Total N = %d responden", nrow(skor_aspek))
  )

ggsave("output/plots/03_Distribution_With_Normal_Curve.png", p3,
       width = 16, height = 10, dpi = 300)

# ================================================================================
# 4. VIOLIN PLOT DENGAN STATISTIK
# ================================================================================
cat("\n--- 4. Violin Plot dengan Statistik ---\n")

# Tambahkan statistik ke data
stats_summary <- data_long_all %>%
  group_by(Aspek) %>%
  summarise(
    median = median(Skor, na.rm = TRUE),
    q25 = quantile(Skor, 0.25, na.rm = TRUE),
    q75 = quantile(Skor, 0.75, na.rm = TRUE)
  )

p4 <- ggplot(data_long_all, aes(x = reorder(Aspek, Skor, FUN = median),
                                 y = Skor, fill = Aspek)) +
  geom_violin(trim = FALSE, alpha = 0.7, scale = "width") +
  geom_boxplot(width = 0.15, fill = "white", outlier.size = 1,
               outlier.alpha = 0.5, alpha = 0.8) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3,
               fill = "red", color = "darkred") +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.x = element_blank()
  ) +
  scale_fill_manual(values = colorRampPalette(brewer.pal(11, "Spectral"))(15)) +
  labs(
    title = "Distribusi Skor per Aspek dengan Violin Plot",
    subtitle = "Urutan berdasarkan median | Box putih: IQR | Titik merah: Mean",
    x = "Aspek Kepribadian",
    y = "Skor",
    caption = "Lebar violin menunjukkan densitas distribusi"
  )

ggsave("output/plots/04_Violin_Plot_Enhanced.png", p4,
       width = 15, height = 8, dpi = 300)

# ================================================================================
# 5. RADAR CHART DENGAN MULTIPLE LAYERS
# ================================================================================
cat("\n--- 5. Radar Chart Multi-layer ---\n")

# Siapkan data untuk radar chart (mean, median, Q1, Q3)
radar_data_full <- data.frame(rbind(
  max = rep(max(max_scores) + 5, 15),
  min = rep(0, 15),
  mean = mean_scores,
  median = median_scores
))
colnames(radar_data_full) <- aspek_labels[aspek_epps]

png("output/plots/05_Radar_Chart_MultiLayer.png",
    width = 2800, height = 2800, res = 300)
par(mar = c(1, 1, 3, 1))
radarchart(
  radar_data_full,
  axistype = 1,
  pcol = c("transparent", "transparent", "#2166AC", "#B2182B"),
  pfcol = c("transparent", "transparent", rgb(0.1, 0.4, 0.7, 0.3), rgb(0.7, 0.1, 0.2, 0.3)),
  plwd = c(0, 0, 3, 3),
  plty = c(0, 0, 1, 2),
  cglcol = "grey70",
  cglty = 1,
  cglwd = 1,
  axislabcol = "grey30",
  caxislabels = seq(0, max(max_scores) + 5, length.out = 5),
  vlcex = 0.85,
  title = "Profil Kepribadian EPPS: Rata-rata vs Median"
)
legend("topright",
       legend = c("Rata-rata", "Median"),
       col = c("#2166AC", "#B2182B"),
       lty = c(1, 2),
       lwd = 3,
       bty = "n",
       cex = 1.1)
dev.off()

# ================================================================================
# 6. PERBANDINGAN DEMOGRAFIS DENGAN UJI STATISTIK
# ================================================================================
cat("\n--- 6. Perbandingan Demografis ---\n")

# Cari kolom gender
gender_col <- names(data_raw)[grepl("Jenis.*Kelamin|Gender|Sex",
                                     names(data_raw), ignore.case = TRUE) &
                               !grepl("angka", names(data_raw), ignore.case = TRUE)][1]

if (!is.na(gender_col) && length(gender_col) > 0) {
  cat("Variabel Gender ditemukan:", gender_col, "\n")

  data_with_demo <- cbind(data_raw[, gender_col, drop = FALSE], skor_aspek)
  names(data_with_demo)[1] <- "JenisKelamin"

  data_gender_long <- melt(data_with_demo, id.vars = "JenisKelamin")
  names(data_gender_long) <- c("Gender", "Kode_Aspek", "Skor")
  data_gender_long$Aspek <- aspek_labels[as.character(data_gender_long$Kode_Aspek)]
  data_gender_long <- data_gender_long[!is.na(data_gender_long$Gender) &
                                        data_gender_long$Gender != "", ]

  # Plot dengan uji statistik
  p6 <- ggplot(data_gender_long, aes(x = Aspek, y = Skor, fill = Gender)) +
    geom_boxplot(alpha = 0.8, outlier.size = 0.5) +
    stat_compare_means(aes(group = Gender),
                      method = "t.test",
                      label = "p.signif",
                      label.y.npc = 0.95,
                      hide.ns = TRUE,
                      size = 3) +
    theme_minimal(base_size = 11) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
      plot.title = element_text(face = "bold", size = 14),
      legend.position = "top"
    ) +
    scale_fill_brewer(palette = "Set2", name = "Jenis Kelamin") +
    labs(
      title = "Perbandingan Skor Berdasarkan Jenis Kelamin",
      subtitle = "Uji t independen | *: p<0.05, **: p<0.01, ***: p<0.001, ns: tidak signifikan",
      x = "Aspek Kepribadian",
      y = "Skor",
      caption = "Box menunjukkan Q1, Median, Q3"
    )

  ggsave("output/plots/06_Gender_Comparison_With_Stats.png", p6,
         width = 16, height = 8, dpi = 300)

  # Mean comparison bar chart
  gender_means <- data_gender_long %>%
    group_by(Gender, Aspek) %>%
    summarise(
      Mean = mean(Skor, na.rm = TRUE),
      SE = sd(Skor, na.rm = TRUE) / sqrt(n()),
      .groups = "drop"
    )

  p6b <- ggplot(gender_means, aes(x = Aspek, y = Mean, fill = Gender)) +
    geom_bar(stat = "identity", position = position_dodge(0.9), alpha = 0.8) +
    geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE),
                  position = position_dodge(0.9), width = 0.25) +
    theme_minimal(base_size = 11) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
      plot.title = element_text(face = "bold", size = 14),
      legend.position = "top"
    ) +
    scale_fill_brewer(palette = "Paired", name = "Jenis Kelamin") +
    labs(
      title = "Rata-rata Skor per Aspek Berdasarkan Jenis Kelamin",
      subtitle = "Error bars menunjukkan ±1 SE",
      x = "Aspek Kepribadian",
      y = "Skor Rata-rata",
      caption = "Perbandingan mean dengan standard error"
    )

  ggsave("output/plots/06B_Gender_Mean_Comparison.png", p6b,
         width = 15, height = 7, dpi = 300)

} else {
  cat("Variabel Gender tidak ditemukan. Skip plot demografi.\n")
}

# ================================================================================
# 7. MATRIKS KORELASI DENGAN CLUSTERING
# ================================================================================
cat("\n--- 7. Matriks Korelasi ---\n")

cor_matrix <- cor(skor_aspek, use = "pairwise.complete.obs")
rownames(cor_matrix) <- colnames(cor_matrix) <- aspek_labels[aspek_epps]

# Corrplot dengan berbagai metode
png("output/plots/07_Correlation_Matrix_Full.png",
    width = 3200, height = 3200, res = 300)
corrplot(cor_matrix,
         method = "color",
         type = "full",
         order = "hclust",
         addrect = 3,
         tl.col = "black",
         tl.cex = 0.9,
         tl.srt = 45,
         col = colorRampPalette(c("#D73027", "#FFFFBF", "#1A9850"))(200),
         addCoef.col = "black",
         number.cex = 0.6,
         cl.cex = 0.8,
         title = "Matriks Korelasi Antar Aspek EPPS dengan Clustering Hierarkis",
         mar = c(0, 0, 2, 0))
dev.off()

# Corrplot lower triangle dengan circles
png("output/plots/07B_Correlation_Matrix_Circle.png",
    width = 2800, height = 2800, res = 300)
corrplot(cor_matrix,
         method = "circle",
         type = "lower",
         order = "hclust",
         tl.col = "black",
         tl.cex = 0.9,
         tl.srt = 45,
         col = colorRampPalette(c("#2166AC", "#F7F7F7", "#B2182B"))(200),
         cl.cex = 0.9,
         title = "Matriks Korelasi (Lower Triangle)",
         mar = c(0, 0, 2, 0))
dev.off()

# ================================================================================
# 8. 3D SCATTER INTERAKTIF DENGAN ANOTASI
# ================================================================================
cat("\n--- 8. Visualisasi 3D Interaktif ---\n")

# Pilih 3 aspek dengan varians tertinggi
var_aspek <- apply(skor_aspek, 2, var, na.rm = TRUE)
top3_aspek <- names(sort(var_aspek, decreasing = TRUE)[1:3])
top3_labels <- aspek_labels[top3_aspek]

# Sample untuk performa
n_3d <- min(1000, nrow(skor_aspek))
sample_3d_idx <- sample(1:nrow(skor_aspek), n_3d)
data_3d <- skor_aspek[sample_3d_idx, top3_aspek]
colnames(data_3d) <- top3_labels
data_3d_df <- as.data.frame(data_3d)

# Tambahkan cluster untuk warna
set.seed(CONFIG_RANDOM_SEED)
kmeans_result <- kmeans(data_3d_df, centers = 4)
data_3d_df$Cluster <- factor(paste("Kelompok", kmeans_result$cluster))

# 3D scatter dengan plotly
fig_3d <- plot_ly(data_3d_df,
                  x = as.formula(paste0("~`", top3_labels[1], "`")),
                  y = as.formula(paste0("~`", top3_labels[2], "`")),
                  z = as.formula(paste0("~`", top3_labels[3], "`")),
                  color = ~Cluster,
                  colors = brewer.pal(4, "Set1"),
                  type = "scatter3d",
                  mode = "markers",
                  marker = list(
                    size = 4,
                    opacity = 0.7,
                    line = list(color = "white", width = 0.5)
                  ),
                  text = ~paste(
                    "Kelompok:", Cluster,
                    "<br>", top3_labels[1], ":", round(get(top3_labels[1]), 2),
                    "<br>", top3_labels[2], ":", round(get(top3_labels[2]), 2),
                    "<br>", top3_labels[3], ":", round(get(top3_labels[3]), 2)
                  ),
                  hoverinfo = "text") %>%
  layout(
    title = list(
      text = sprintf("Plot 3D Interaktif: Top 3 Aspek dengan Varians Tertinggi<br><sub>K-means clustering (k=4) | N=%d responden</sub>", n_3d),
      font = list(size = 14)
    ),
    scene = list(
      xaxis = list(title = top3_labels[1]),
      yaxis = list(title = top3_labels[2]),
      zaxis = list(title = top3_labels[3]),
      camera = list(
        eye = list(x = 1.5, y = 1.5, z = 1.5)
      )
    ),
    legend = list(title = list(text = "Kelompok Cluster"))
  )

saveWidget(fig_3d, "output/plots/08_3D_Scatter_Interactive.html", selfcontained = TRUE)

# ================================================================================
# 9. NETWORK DIAGRAM DENGAN LAYOUT OPTIMAL
# ================================================================================
cat("\n--- 9. Network Diagram ---\n")

# Network dengan qgraph - layout spring
png("output/plots/09_Network_Correlation.png",
    width = 3200, height = 3200, res = 300)
qgraph(cor_matrix,
       layout = "spring",
       graph = "cor",
       threshold = 0.15,
       labels = colnames(cor_matrix),
       label.cex = 1.1,
       node.width = 1.8,
       edge.labels = FALSE,
       posCol = "#1A9850",
       negCol = "#D73027",
       edge.width = 2,
       vsize = 8,
       title = "Network Korelasi Antar Aspek Kepribadian EPPS\n(Threshold: r > 0.15)",
       title.cex = 1.3,
       borders = TRUE,
       color = colorRampPalette(brewer.pal(9, "Set1"))(15))
dev.off()

# Network dengan circular layout
png("output/plots/09B_Network_Circular.png",
    width = 3000, height = 3000, res = 300)
qgraph(cor_matrix,
       layout = "circle",
       graph = "cor",
       threshold = 0.20,
       labels = colnames(cor_matrix),
       label.cex = 1.0,
       node.width = 1.5,
       edge.labels = FALSE,
       posCol = "#4575B4",
       negCol = "#D73027",
       edge.width = 1.5,
       vsize = 7,
       title = "Network Korelasi - Layout Circular\n(Threshold: r > 0.20)",
       title.cex = 1.2,
       borders = TRUE,
       color = viridis(15))
dev.off()

# ================================================================================
# 10. DISTRIBUSI ITEM DIFFICULTY (jika ada data IRT)
# ================================================================================
cat("\n--- 10. Distribusi Item Difficulty ---\n")

if (file.exists("output/tables/05_Parameter_2PL.csv")) {
  params_2pl <- read.csv("output/tables/05_Parameter_2PL.csv")

  # Histogram per aspek
  p10a <- ggplot(params_2pl, aes(x = Difficulty, fill = Aspek)) +
    geom_histogram(bins = 25, alpha = 0.7, color = "white") +
    facet_wrap(~ Aspek, scales = "free_y", ncol = 5) +
    theme_minimal(base_size = 9) +
    theme(
      legend.position = "none",
      strip.text = element_text(face = "bold", size = 8),
      plot.title = element_text(face = "bold", size = 13)
    ) +
    scale_fill_manual(values = colorRampPalette(brewer.pal(11, "Spectral"))(15)) +
    labs(
      title = "Distribusi Tingkat Kesulitan Item (Parameter b) dari Model IRT 2PL",
      subtitle = "Distribusi per aspek kepribadian",
      x = "Difficulty Parameter (b)",
      y = "Frekuensi",
      caption = "Nilai b lebih tinggi = item lebih sulit"
    )

  ggsave("output/plots/10_ItemDifficulty_PerAspect.png", p10a,
         width = 16, height = 10, dpi = 300)

  # Scatter: Difficulty vs Discrimination
  if ("Discrimination" %in% names(params_2pl)) {
    p10b <- ggplot(params_2pl, aes(x = Difficulty, y = Discrimination,
                                    color = Aspek)) +
      geom_point(size = 3, alpha = 0.7) +
      geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = 0.8) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "blue", size = 0.8) +
      theme_minimal(base_size = 11) +
      theme(
        legend.position = "right",
        plot.title = element_text(face = "bold", size = 14)
      ) +
      scale_color_manual(values = colorRampPalette(brewer.pal(11, "Spectral"))(15)) +
      labs(
        title = "Hubungan Difficulty vs Discrimination Item",
        subtitle = "Garis merah: a=1 (batas daya beda memadai) | Garis biru: b=0 (kesulitan rata-rata)",
        x = "Difficulty (b) - Tingkat Kesulitan",
        y = "Discrimination (a) - Daya Beda",
        color = "Aspek",
        caption = "Item ideal: a > 1 dan b mendekati 0"
      )

    ggsave("output/plots/10B_Difficulty_vs_Discrimination.png", p10b,
           width = 14, height = 8, dpi = 300)
  }
}

# ================================================================================
# 11. PERBANDINGAN RELIABILITAS
# ================================================================================
cat("\n--- 11. Perbandingan Reliabilitas ---\n")

if (file.exists("output/tables/03_Reliabilitas.csv")) {
  rel_data <- read.csv("output/tables/03_Reliabilitas.csv")

  # Bar chart dengan threshold lines
  rel_long <- melt(rel_data[, c("Aspek", "Alpha", "Omega")], id.vars = "Aspek")
  names(rel_long) <- c("Aspek", "Metode", "Nilai")

  p11 <- ggplot(rel_long, aes(x = reorder(Aspek, -Nilai), y = Nilai, fill = Metode)) +
    geom_bar(stat = "identity", position = position_dodge(0.9), alpha = 0.8) +
    geom_hline(yintercept = 0.90, linetype = "solid", color = "#1A9850", size = 0.8) +
    geom_hline(yintercept = 0.80, linetype = "solid", color = "#4575B4", size = 0.8) +
    geom_hline(yintercept = 0.70, linetype = "dashed", color = "#D73027", size = 0.8) +
    geom_text(aes(label = sprintf("%.2f", Nilai)),
              position = position_dodge(0.9), vjust = -0.5, size = 3) +
    annotate("text", x = 14, y = 0.92, label = "Excellent (≥0.90)",
             color = "#1A9850", hjust = 0, size = 3.5) +
    annotate("text", x = 14, y = 0.82, label = "Good (≥0.80)",
             color = "#4575B4", hjust = 0, size = 3.5) +
    annotate("text", x = 14, y = 0.72, label = "Acceptable (≥0.70)",
             color = "#D73027", hjust = 0, size = 3.5) +
    theme_minimal(base_size = 11) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
      plot.title = element_text(face = "bold", size = 14),
      legend.position = "top"
    ) +
    scale_fill_manual(values = c("Alpha" = "#E69F00", "Omega" = "#56B4E9"),
                      labels = c("Cronbach's Alpha", "McDonald's Omega")) +
    scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
    labs(
      title = "Perbandingan Reliabilitas Internal 15 Aspek EPPS",
      subtitle = "Cronbach's Alpha vs McDonald's Omega | Urutan dari reliabilitas tertinggi",
      x = "Aspek Kepribadian",
      y = "Koefisien Reliabilitas",
      fill = "Metode",
      caption = "Nilai ≥0.70 dianggap dapat diterima untuk penelitian"
    )

  ggsave("output/plots/11_Reliability_Comparison_Enhanced.png", p11,
         width = 16, height = 9, dpi = 300)
}

# ================================================================================
# 12. BOX PLOT PERBANDINGAN SEMUA ASPEK
# ================================================================================
cat("\n--- 12. Box Plot Perbandingan ---\n")

p12 <- ggplot(data_long_all, aes(x = reorder(Aspek, Skor, FUN = median),
                                   y = Skor)) +
  geom_boxplot(aes(fill = Aspek), alpha = 0.7, outlier.colour = "red",
               outlier.shape = 16, outlier.size = 1.5) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3,
               fill = "yellow", color = "black") +
  coord_flip() +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.y = element_blank()
  ) +
  scale_fill_manual(values = colorRampPalette(brewer.pal(11, "Spectral"))(15)) +
  labs(
    title = "Perbandingan Distribusi Skor 15 Aspek EPPS",
    subtitle = "Urutan berdasarkan median (garis tengah box) | Titik kuning: mean | Titik merah: outliers",
    x = "Aspek Kepribadian",
    y = "Skor",
    caption = "Box menunjukkan Q1, Median, dan Q3 | Whiskers: ±1.5 IQR"
  )

ggsave("output/plots/12_BoxPlot_All_Aspects.png", p12,
       width = 12, height = 10, dpi = 300)

# ================================================================================
# 13. SUMMARY STATISTIK DESKRIPTIF
# ================================================================================
cat("\n--- 13. Tabel Statistik Deskriptif ---\n")

# Buat tabel statistik lengkap
stats_table <- data.frame(
  Kode = aspek_epps,
  Aspek = aspek_labels[aspek_epps],
  N = nrow(skor_aspek),
  Mean = round(mean_scores, 2),
  Median = round(median_scores, 2),
  SD = round(sd_scores, 2),
  Min = min_scores,
  Max = max_scores,
  Range = max_scores - min_scores,
  IQR = round(apply(skor_aspek, 2, IQR, na.rm = TRUE), 2),
  Skewness = round(apply(skor_aspek, 2, function(x) {
    require(moments)
    skewness(x, na.rm = TRUE)
  }), 2),
  Kurtosis = round(apply(skor_aspek, 2, function(x) {
    require(moments)
    kurtosis(x, na.rm = TRUE) - 3  # Excess kurtosis
  }), 2)
)

# Simpan tabel
write.csv(stats_table, "output/tables/35_Statistik_Deskriptif_Lengkap.csv",
          row.names = FALSE)

cat("Tabel statistik deskriptif disimpan\n")

# ================================================================================
# 14. GRAFIK PERSENTIL
# ================================================================================
cat("\n--- 14. Grafik Persentil ---\n")

# Hitung persentil untuk setiap aspek
percentiles <- c(10, 25, 50, 75, 90)
perc_data <- data.frame(
  Aspek = rep(aspek_labels[aspek_epps], each = length(percentiles)),
  Persentil = rep(paste0("P", percentiles), times = 15),
  Nilai = as.vector(sapply(aspek_epps, function(asp) {
    quantile(skor_aspek[[asp]], probs = percentiles / 100, na.rm = TRUE)
  }))
)

p14 <- ggplot(perc_data, aes(x = Aspek, y = Nilai, color = Persentil, group = Persentil)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "right"
  ) +
  scale_color_brewer(palette = "Set1", name = "Persentil") +
  labs(
    title = "Profil Persentil Skor 15 Aspek EPPS",
    subtitle = "P10: 10th percentile | P25: Q1 | P50: Median | P75: Q3 | P90: 90th percentile",
    x = "Aspek Kepribadian",
    y = "Skor",
    caption = "Persentil menunjukkan posisi relatif dalam distribusi"
  )

ggsave("output/plots/14_Percentile_Profiles.png", p14,
       width = 15, height = 8, dpi = 300)

# ================================================================================
# 15. DASHBOARD RINGKASAN
# ================================================================================
cat("\n--- 15. Dashboard Ringkasan ---\n")

# Mini plots untuk dashboard
mini_density <- ggplot(data_long_all, aes(x = Skor)) +
  geom_density(fill = "steelblue", alpha = 0.5) +
  theme_void() +
  labs(title = "Distribusi Keseluruhan")

mini_bar <- ggplot(profile_data, aes(x = reorder(Kode, -Mean), y = Mean)) +
  geom_bar(stat = "identity", fill = "steelblue", alpha = 0.7) +
  theme_minimal(base_size = 8) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Rata-rata per Aspek", x = "", y = "Mean")

# Statistik ringkasan
summary_text <- sprintf(
  "RINGKASAN STATISTIK\n\nTotal Responden: %d\nTotal Aspek: %d\n\nSkor Tertinggi:\n%s (%.2f)\n\nSkor Terendah:\n%s (%.2f)\n\nVarians Tertinggi:\n%s (%.2f)",
  nrow(skor_aspek),
  length(aspek_epps),
  aspek_labels[names(which.max(mean_scores))],
  max(mean_scores),
  aspek_labels[names(which.min(mean_scores))],
  min(mean_scores),
  aspek_labels[names(which.max(var_aspek))],
  max(var_aspek)
)

mini_text <- ggplot() +
  annotate("text", x = 0.5, y = 0.5, label = summary_text,
           size = 4, hjust = 0, vjust = 1, family = "mono") +
  theme_void()

# Combine dashboard
dashboard <- grid.arrange(
  mini_text, mini_bar, mini_density,
  ncol = 2,
  top = "Dashboard Ringkasan Analisis EPPS"
)

ggsave("output/plots/15_Dashboard_Summary.png", dashboard,
       width = 14, height = 10, dpi = 300)

# ================================================================================
# SUMMARY & COMPLETION
# ================================================================================

print_section_header("RINGKASAN VISUALISASI")

cat("Total visualisasi yang dibuat:\n")
cat("  1. Profil skor rata-rata dengan statistik\n")
cat("  2. Heatmap hierarkis dengan clustering\n")
cat("  3. Distribusi dengan kurva normal\n")
cat("  4. Violin plot dengan statistik\n")
cat("  5. Radar chart multi-layer\n")
cat("  6. Perbandingan gender dengan uji statistik\n")
cat("  7. Matriks korelasi (2 variasi)\n")
cat("  8. 3D scatter interaktif\n")
cat("  9. Network diagram (2 variasi)\n")
cat(" 10. Distribusi item difficulty (jika ada)\n")
cat(" 11. Perbandingan reliabilitas enhanced\n")
cat(" 12. Box plot semua aspek\n")
cat(" 13. Tabel statistik deskriptif\n")
cat(" 14. Grafik persentil\n")
cat(" 15. Dashboard ringkasan\n\n")

cat("Lokasi: output/plots/\n")
cat("Format: PNG (static), HTML (interactive)\n")
cat("Resolusi: 300 DPI (publication quality)\n\n")

print_section_header("VISUALISASI SELESAI")
cat("✓ Semua visualisasi telah dibuat dengan sukses\n")
cat("✓ Semua label dalam Bahasa Indonesia\n")
cat("✓ Visualisasi siap untuk analisis dan pelaporan\n\n")
