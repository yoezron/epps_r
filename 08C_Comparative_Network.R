# ============================================================================
# SCRIPT 08C: COMPARATIVE NETWORK ANALYSIS & PREDICTABILITY
# Network analysis across groups dan predictability analysis
# ============================================================================

load("output/data_processed.RData")

cat("\n=== COMPARATIVE NETWORK ANALYSIS & PREDICTABILITY ===\n\n")

# Rename untuk visualisasi
skor_aspek_label <- skor_aspek
names(skor_aspek_label) <- aspek_labels[aspek_epps]

# ===== 1. NETWORK COMPARISON BY GENDER =====
cat("--- Network Comparison by Gender ---\n")

# Detect gender column
gender_col <- names(data_raw)[grepl("Jenis.*Kelamin|Gender|gender",
                                    names(data_raw), ignore.case = TRUE)]

if(length(gender_col) > 0 && !is.null(data_raw[[gender_col[1]]])) {
  gender_data <- data_raw[[gender_col[1]]]

  # Get unique groups (filter out NA and ensure minimum sample size)
  gender_groups <- table(gender_data)
  valid_groups <- names(gender_groups[gender_groups >= 100])

  if(length(valid_groups) >= 2) {
    cat("Comparing networks for groups:", paste(valid_groups, collapse = ", "), "\n")

    # Network per group
    network_by_gender <- list()

    for(group in valid_groups[1:min(2, length(valid_groups))]) {
      idx <- which(gender_data == group)
      data_group <- skor_aspek_label[idx, ]

      # Regularize if needed
      cor_group <- cor(data_group, use = "pairwise.complete.obs")
      eigenvalues <- eigen(cor_group)$values
      if(min(eigenvalues) < 0) {
        regularization <- abs(min(eigenvalues)) + 0.01
        diag(cor_group) <- diag(cor_group) + regularization
      }

      network_by_gender[[group]] <- tryCatch({
        estimateNetwork(data_group,
                       default = "cor",
                       corMethod = "cor")
      }, error = function(e) {
        list(graph = cor_group)
      })

      # Plot network per group
      png(paste0("output/plots/Network_", gsub(" ", "_", group), ".png"),
          width = 2800, height = 2800, res = 300)
      qgraph(cor_group,
             layout = "spring",
             graph = "cor",
             threshold = 0.15,
             title = paste("Network Aspek EPPS -", group),
             labels = names(skor_aspek_label),
             label.cex = 1.0,
             vsize = 7,
             posCol = "#1A9850",
             negCol = "#D73027",
             theme = "colorblind")
      dev.off()
    }

    # Network Comparison Test (NCT)
    if(length(network_by_gender) == 2) {
      cat("Running Network Comparison Test (NCT)...\n")
      cat("Note: This may take several minutes\n")

      group_names <- names(network_by_gender)
      data_g1 <- skor_aspek_label[gender_data == group_names[1], ]
      data_g2 <- skor_aspek_label[gender_data == group_names[2], ]

      nct_result <- tryCatch({
        NCT(data_g1, data_g2,
            it = 100,  # Reduced iterations for speed
            test.edges = TRUE,
            test.centrality = TRUE,
            progressbar = FALSE)
      }, error = function(e) {
        cat("NCT failed:", e$message, "\n")
        NULL
      })

      if(!is.null(nct_result)) {
        # Save NCT results
        nct_summary <- data.frame(
          Test = c("Global Strength", "Network Structure", "Edge Invariance"),
          p_value = c(nct_result$glstrinv.pval,
                     nct_result$nwinv.pval,
                     ifelse(is.null(nct_result$einv.pval), NA, nct_result$einv.pval))
        )

        write.csv(nct_summary, "output/tables/39_NCT_Gender_Comparison.csv",
                 row.names = FALSE)

        # Plot NCT results
        if(!is.null(nct_result$einv.pvals)) {
          png("output/plots/Network_Gender_Comparison.png",
              width = 3000, height = 2400, res = 300)
          plot(nct_result, what = "edge")
          dev.off()
        }

        cat("✓ NCT completed\n")
      }
    }
  }
} else {
  cat("Gender variable not found or insufficient data\n")
}

cat("\n")

# ===== 2. NETWORK COMPARISON BY EDUCATION =====
cat("--- Network Comparison by Education ---\n")

edu_col <- names(data_raw)[grepl("Pendidikan|Education|education",
                                 names(data_raw), ignore.case = TRUE)]

if(length(edu_col) > 0 && !is.null(data_raw[[edu_col[1]]])) {
  edu_data <- data_raw[[edu_col[1]]]
  edu_groups <- table(edu_data)
  valid_edu <- names(edu_groups[edu_groups >= 100])

  if(length(valid_edu) >= 2) {
    cat("Comparing networks for education levels:",
        paste(head(valid_edu, 2), collapse = " vs "), "\n")

    # Compare top 2 education levels
    for(group in head(valid_edu, 2)) {
      idx <- which(edu_data == group)
      data_edu <- skor_aspek_label[idx, ]

      cor_edu <- cor(data_edu, use = "pairwise.complete.obs")
      eigenvalues <- eigen(cor_edu)$values
      if(min(eigenvalues) < 0) {
        regularization <- abs(min(eigenvalues)) + 0.01
        diag(cor_edu) <- diag(cor_edu) + regularization
      }

      png(paste0("output/plots/Network_Edu_", gsub(" ", "_", group), ".png"),
          width = 2800, height = 2800, res = 300)
      qgraph(cor_edu,
             layout = "spring",
             graph = "cor",
             threshold = 0.15,
             title = paste("Network -", group),
             labels = names(skor_aspek_label),
             label.cex = 1.0,
             vsize = 7,
             posCol = "#1A9850",
             negCol = "#D73027",
             theme = "colorblind")
      dev.off()
    }

    cat("✓ Education networks created\n")
  }
} else {
  cat("Education variable not found or insufficient data\n")
}

cat("\n")

# ===== 3. NODE PREDICTABILITY =====
cat("--- Node Predictability Analysis ---\n")

# Compute predictability (R-squared for each node)
predictability <- numeric(ncol(skor_aspek_label))
names(predictability) <- names(skor_aspek_label)

for(i in 1:ncol(skor_aspek_label)) {
  # Predict node i from all other nodes
  target <- skor_aspek_label[, i]
  predictors <- skor_aspek_label[, -i]

  # Remove rows with NA
  complete_idx <- complete.cases(cbind(target, predictors))
  target_clean <- target[complete_idx]
  predictors_clean <- predictors[complete_idx, ]

  if(sum(complete_idx) > 20) {
    # Fit linear model
    model <- tryCatch({
      lm(target_clean ~ ., data = as.data.frame(predictors_clean))
    }, error = function(e) NULL)

    if(!is.null(model)) {
      predictability[i] <- summary(model)$r.squared
    }
  }
}

predictability_df <- data.frame(
  Aspek = names(skor_aspek_label),
  Predictability = round(predictability, 3),
  Variance_Explained = paste0(round(predictability * 100, 1), "%")
)

predictability_df <- predictability_df[order(predictability_df$Predictability,
                                             decreasing = TRUE), ]

write.csv(predictability_df, "output/tables/40_Node_Predictability.csv",
         row.names = FALSE)

# Plot predictability
library(ggplot2)

p_pred <- ggplot(predictability_df,
                 aes(x = reorder(Aspek, Predictability), y = Predictability)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = Variance_Explained), hjust = -0.1, size = 3) +
  coord_flip() +
  ylim(0, 1) +
  theme_minimal(base_size = 11) +
  labs(title = "Node Predictability - Seberapa Predictable Tiap Aspek",
       subtitle = "R² dari regresi: prediksi aspek dari aspek lainnya",
       x = "Aspek", y = "Predictability (R²)")

ggsave("output/plots/Network_Predictability.png", p_pred,
       width = 10, height = 8, dpi = 300)

cat("✓ Predictability computed\n")
cat("Mean predictability:", round(mean(predictability, na.rm = TRUE), 3), "\n\n")

# ===== 4. NETWORK WITH PREDICTABILITY VISUALIZATION =====
cat("--- Network with Predictability Pie Charts ---\n")

# Gunakan library Matrix untuk regularisasi yang robust (sama seperti script 08B)
if(!require(Matrix)) install.packages("Matrix")
library(Matrix)

# 1. Hitung ulang matriks korelasi dengan metode robust
raw_cor <- cor(skor_aspek_label, use = "pairwise.complete.obs")
clean_fit <- nearPD(raw_cor, corr = TRUE, do2eigen = TRUE)
cor_matrix <- as.matrix(clean_fit$mat)

png("output/plots/Network_With_Predictability.png",
    width = 3200, height = 3200, res = 300)

# PERBAIKAN UTAMA:
# 1. Menghapus 'theme = "colorblind"' untuk mencegah error 'invalid color name'
# 2. Menambahkan 'color = "white"' sebagai warna dasar node
qgraph(cor_matrix,
       layout = "spring",
       graph = "cor",
       threshold = 0.15,
       pie = predictability,       # Bagian terisi = seberapa predictable node tersebut
       pieBorder = 0.3,
       title = "Network dengan Predictability (Pie Charts)",
       labels = names(skor_aspek_label),
       label.cex = 0.9,
       vsize = 10,
       posCol = "#1A9850",         # Tetap gunakan warna ramah buta warna manual
       negCol = "#D73027",
       color = "white",            # Warna dasar node (di balik pie chart)
       legend = TRUE)
dev.off()

cat("✓ Network with predictability created successfully\n\n")

# ===== 5. STABILITY OF INDIVIDUAL EDGES =====
cat("--- Individual Edge Stability ---\n")

# Bootstrap edge weights
set.seed(2025)
n_boot <- 100
edge_boots <- array(NA, dim = c(ncol(skor_aspek_label),
                                ncol(skor_aspek_label),
                                n_boot))

sample_size <- min(1000, nrow(skor_aspek_label))

for(b in 1:n_boot) {
  boot_idx <- sample(1:nrow(skor_aspek_label), sample_size, replace = TRUE)
  boot_data <- skor_aspek_label[boot_idx, ]

  boot_cor <- cor(boot_data, use = "pairwise.complete.obs")
  edge_boots[, , b] <- boot_cor
}

# Compute edge stability (SD across bootstraps)
edge_stability <- apply(edge_boots, c(1, 2), sd, na.rm = TRUE)
rownames(edge_stability) <- colnames(edge_stability) <- names(skor_aspek_label)

# Get most stable edges
stable_edges <- data.frame(
  From = character(),
  To = character(),
  Mean_Weight = numeric(),
  SD = numeric(),
  CV = numeric()
)

for(i in 1:(ncol(cor_matrix)-1)) {
  for(j in (i+1):ncol(cor_matrix)) {
    mean_weight <- mean(edge_boots[i, j, ], na.rm = TRUE)
    sd_weight <- edge_stability[i, j]

    stable_edges <- rbind(stable_edges, data.frame(
      From = names(skor_aspek_label)[i],
      To = names(skor_aspek_label)[j],
      Mean_Weight = round(mean_weight, 3),
      SD = round(sd_weight, 3),
      CV = round(sd_weight / abs(mean_weight), 3)
    ))
  }
}

# Sort by stability (lowest SD or CV)
stable_edges <- stable_edges[order(stable_edges$SD), ]

# Top 20 most stable edges
write.csv(head(stable_edges, 20),
          "output/tables/41_Most_Stable_Edges.csv",
          row.names = FALSE)

# Top 20 least stable edges
write.csv(tail(stable_edges, 20),
          "output/tables/42_Least_Stable_Edges.csv",
          row.names = FALSE)

cat("✓ Edge stability computed (", n_boot, "bootstraps)\n\n")

# ===== 6. EXPECTED INFLUENCE =====
cat("--- Expected Influence Analysis ---\n")

# Kita tidak perlu loop manual yang error itu.
# Kita gunakan Matrix Algebra yang jauh lebih cepat & stabil.

# Pastikan cor_matrix tersedia
if(!exists("cor_matrix")) {
  if(!require(Matrix)) install.packages("Matrix")
  library(Matrix)
  raw_cor <- cor(skor_aspek_label, use = "pairwise.complete.obs")
  clean_fit <- nearPD(raw_cor, corr = TRUE, do2eigen = TRUE)
  cor_matrix <- as.matrix(clean_fit$mat)
}

# 1. One-step Expected Influence (EI)
# Definisi: Jumlah bobot edge (mempertahankan tanda positif/negatif).
# Ini penting untuk melihat apakah aspek ini cenderung 'mengaktifkan' atau 'menekan' sistem.
ei_1_step <- colSums(cor_matrix) - diag(cor_matrix)

# 2. Node Strength (Kekuatan)
# Definisi: Jumlah nilai mutlak (abs). Seberapa kuat koneksinya tanpa peduli arah.
node_strength <- colSums(abs(cor_matrix)) - diag(abs(cor_matrix))

# 3. Two-step Expected Influence
# Pengaruh ke tetangganya tetangga (indirect influence)
cor_matrix_squared <- cor_matrix %*% cor_matrix
ei_2_step <- colSums(cor_matrix_squared) - diag(cor_matrix_squared)

# Gabungkan data
influence_df <- data.frame(
  Aspek = names(skor_aspek_label),
  Expected_Influence = round(ei_1_step, 3), # EI Murni
  Strength = round(node_strength, 3),       # Total Konektivitas (Absolut)
  EI_2_Step = round(ei_2_step, 3)           # Pengaruh Sekunder
)

# Urutkan berdasarkan Expected Influence murni
influence_df <- influence_df[order(influence_df$Expected_Influence, decreasing = TRUE), ]

write.csv(influence_df, "output/tables/43_Expected_Influence.csv",
          row.names = FALSE)

# Plot Expected Influence
# Kita bedakan warna positif (hijau) dan negatif (merah)
library(ggplot2)

p_ei <- ggplot(influence_df,
               aes(x = reorder(Aspek, Expected_Influence), y = Expected_Influence,
                   fill = Expected_Influence > 0)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "#1A9850", "FALSE" = "#D73027"),
                    labels = c("TRUE" = "Positive Influence", "FALSE" = "Negative Influence"),
                    name = "Direction") +
  theme_minimal(base_size = 11) +
  labs(title = "Expected Influence (1-Step)",
       subtitle = "Positif = Memicu aspek lain; Negatif = Menghambat aspek lain",
       x = "Aspek", y = "Expected Influence Value") +
  theme(legend.position = "bottom")

ggsave("output/plots/Network_Expected_Influence.png", p_ei,
       width = 10, height = 8, dpi = 300)

cat("✓ Expected influence computed successfully (Matrix Method)\n\n")

# ===== 7. FLOW ANALYSIS =====
cat("--- Network Flow Analysis ---\n")

library(igraph)

# Pastikan cor_matrix tersedia
if(!exists("cor_matrix")) {
  # Fallback jika cor_matrix belum ada
  if(!require(Matrix)) install.packages("Matrix")
  library(Matrix)
  raw_cor <- cor(skor_aspek_label, use = "pairwise.complete.obs")
  clean_fit <- nearPD(raw_cor, corr = TRUE, do2eigen = TRUE)
  cor_matrix <- as.matrix(clean_fit$mat)
}

# 1. Buat Graph Khusus Flow (Menggunakan Nilai Mutlak)
# PENTING: Kita pakai abs() karena betweenness tidak bisa memproses jarak negatif.
# Dalam psikometrika, hubungan negatif kuat (-0.9) sama "pentingnya" dengan positif (0.9).
g_flow <- graph_from_adjacency_matrix(abs(cor_matrix),
                                      mode = "undirected",
                                      weighted = TRUE,
                                      diag = FALSE)

# 2. Hitung Metrics
# Sekarang aman dijalankan karena semua weight sudah positif
cat("Calculating betweenness and closeness...\n")
bet_scores <- betweenness(g_flow, normalized = TRUE)
close_scores <- closeness(g_flow, normalized = TRUE)

flow_metrics <- data.frame(
  Aspek = names(skor_aspek_label),
  Betweenness = bet_scores,
  Closeness = close_scores,
  # Flow potential: Interaksi antara seberapa sering dilewati (Betweenness)
  # dan seberapa cepat bisa mencapai node lain (Closeness)
  Flow_Potential = bet_scores * close_scores
)

# Urutkan berdasarkan Flow Potential
flow_metrics <- flow_metrics[order(flow_metrics$Flow_Potential,
                                   decreasing = TRUE), ]

write.csv(flow_metrics, "output/tables/44_Network_Flow_Metrics.csv",
          row.names = FALSE)

# 3. Identify Bottleneck Nodes
# Bottleneck = High Betweenness (Jembatan penting) tapi Low Closeness (Jauh dari pusat)
# Kita standarisasi dulu (z-score) agar skalanya seimbang
flow_metrics$Bottleneck_Score <- scale(flow_metrics$Betweenness) -
  scale(flow_metrics$Closeness)

bottlenecks <- flow_metrics[order(flow_metrics$Bottleneck_Score,
                                  decreasing = TRUE), ]

write.csv(head(bottlenecks, 10),
          "output/tables/45_Network_Bottlenecks.csv",
          row.names = FALSE)

cat("✓ Flow analysis completed successfully (using absolute weights)\n\n")

# ===== 8. NETWORK RESILIENCE =====
cat("--- Network Resilience Analysis ---\n")

# Simulate node removal and measure network fragmentation
resilience_results <- data.frame(
  Node_Removed = character(),
  Components_After = integer(),
  Largest_Component_Size = integer(),
  Avg_Path_Length = numeric(),
  Fragmentation = numeric()
)

for(i in 1:ncol(cor_matrix)) {
  # Remove node i
  g_reduced <- delete_vertices(g, i)

  # Measure network properties
  components <- components(g_reduced)
  avg_path <- tryCatch({
    mean_distance(g_reduced, directed = FALSE)
  }, error = function(e) NA)

  fragmentation <- 1 - (max(components$csize) / vcount(g_reduced))

  resilience_results <- rbind(resilience_results, data.frame(
    Node_Removed = names(skor_aspek_label)[i],
    Components_After = components$no,
    Largest_Component_Size = max(components$csize),
    Avg_Path_Length = round(avg_path, 3),
    Fragmentation = round(fragmentation, 3)
  ))
}

# Sort by fragmentation (highest = most critical node)
resilience_results <- resilience_results[order(resilience_results$Fragmentation,
                                               decreasing = TRUE), ]

write.csv(resilience_results, "output/tables/46_Network_Resilience.csv",
         row.names = FALSE)

# Plot resilience
p_resilience <- ggplot(resilience_results,
                       aes(x = reorder(Node_Removed, Fragmentation),
                           y = Fragmentation)) +
  geom_bar(stat = "identity", fill = "firebrick") +
  coord_flip() +
  theme_minimal(base_size = 11) +
  labs(title = "Network Resilience - Dampak Menghapus Tiap Node",
       subtitle = "Fragmentation score (higher = more critical node)",
       x = "Node Removed", y = "Network Fragmentation")

ggsave("output/plots/Network_Resilience.png", p_resilience,
       width = 10, height = 8, dpi = 300)

cat("✓ Resilience analysis completed\n\n")

# ===== 9. SMALL-WORLD PROPERTIES =====
cat("--- Small-World Analysis ---\n")

library(igraph)

# Pastikan cor_matrix tersedia dan valid
if(!exists("cor_matrix")) {
  if(!require(Matrix)) install.packages("Matrix")
  library(Matrix)
  raw_cor <- cor(skor_aspek_label, use = "pairwise.complete.obs")
  clean_fit <- nearPD(raw_cor, corr = TRUE, do2eigen = TRUE)
  cor_matrix <- as.matrix(clean_fit$mat)
}

# 1. Buat Graph Khusus Small-World (Wajib Nilai Mutlak)
# Kita pakai abs() agar tidak ada error "negative weight" pada perhitungan jarak
g_sw <- graph_from_adjacency_matrix(abs(cor_matrix),
                                    mode = "undirected",
                                    weighted = TRUE,
                                    diag = FALSE)

# 2. Compare to random graph
# PERBAIKAN: Ganti 'erdos.renyi.game' (jadul) dengan 'sample_gnp' (baru)
# Kita buat random graph dengan jumlah node dan density yang sama
g_random <- sample_gnp(n = vcount(g_sw),
                       p = edge_density(g_sw))

# 3. Compute metrics
cat("Calculating clustering coefficient...\n")
real_clustering <- transitivity(g_sw, type = "average")

cat("Calculating average path length...\n")
# Sekarang aman karena semua weight positif (hasil abs)
real_path_length <- mean_distance(g_sw, directed = FALSE)

# Metrics for random graph
random_clustering <- transitivity(g_random, type = "average")
random_path_length <- mean_distance(g_random, directed = FALSE)

# 4. Small-world coefficients
# Sigma > 1 biasanya mengindikasikan Small-World Network
sigma <- (real_clustering / random_clustering) /
  (real_path_length / random_path_length)

omega <- (real_path_length / random_path_length) -
  (real_clustering / random_clustering)

small_world_df <- data.frame(
  Metric = c("Clustering Coefficient (Real)",
             "Clustering Coefficient (Random)",
             "Average Path Length (Real)",
             "Average Path Length (Random)",
             "Small-Worldness (Sigma)",
             "Small-Worldness (Omega)"),
  Value = c(round(real_clustering, 3),
            round(random_clustering, 3),
            round(real_path_length, 3),
            round(random_path_length, 3),
            round(sigma, 3),
            round(omega, 3))
)

write.csv(small_world_df, "output/tables/47_Small_World_Properties.csv",
          row.names = FALSE)

cat("✓ Small-world analysis completed\n")
cat("Small-worldness (Sigma):", round(sigma, 3),
    ifelse(sigma > 1, "(Small-world)", "(Not small-world)"), "\n\n")

# ===== 10. CENTRALITY CORRELATION MATRIX =====
cat("--- Centrality Correlation Analysis ---\n")

library(igraph)

# 1. Persiapkan Data
# Pastikan cor_matrix tersedia
if(!exists("cor_matrix")) {
  if(!require(Matrix)) install.packages("Matrix")
  library(Matrix)
  raw_cor <- cor(skor_aspek_label, use = "pairwise.complete.obs")
  clean_fit <- nearPD(raw_cor, corr = TRUE, do2eigen = TRUE)
  cor_matrix <- as.matrix(clean_fit$mat)
}

# 2. Buat Graph dengan Nilai Mutlak (Wajib untuk Betweenness/Closeness)
g_abs <- graph_from_adjacency_matrix(abs(cor_matrix),
                                     mode = "undirected",
                                     weighted = TRUE,
                                     diag = FALSE)

# 3. Hitung Ulang Metric (agar aman dan konsisten)
# Strength (Total koneksi absolut)
strength_val <- colSums(abs(cor_matrix)) - diag(abs(cor_matrix))

# Expected Influence (Total koneksi mempertahankan tanda +/-)
ei_val <- colSums(cor_matrix) - diag(cor_matrix)

# Gabungkan semua metric
# Kita gunakan g_abs untuk metric yang tidak support nilai negatif
all_centrality <- data.frame(
  Strength = strength_val,
  Betweenness = betweenness(g_abs, normalized = TRUE),
  Closeness = closeness(g_abs, normalized = TRUE),
  Eigenvector = eigen_centrality(g_abs)$vector,
  PageRank = page_rank(g_abs)$vector,
  Expected_Influence = ei_val
)

# 4. Hitung Korelasi Antar Metric
centrality_cor <- cor(all_centrality)

# 5. Plot Correlation Heatmap
library(ggplot2)
library(reshape2)
centrality_cor_melt <- melt(centrality_cor)

p_cent_cor <- ggplot(centrality_cor_melt,
                     aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 2)), size = 3) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red",
                       midpoint = 0, limits = c(-1, 1),
                       name = "Correlation") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Correlation Between Centrality Measures",
       subtitle = "Apakah metric yang berbeda mengukur hal yang sama?",
       x = "", y = "") +
  coord_fixed()

ggsave("output/plots/Network_Centrality_Correlations.png", p_cent_cor,
       width = 10, height = 9, dpi = 300)

write.csv(centrality_cor, "output/tables/48_Centrality_Correlations.csv")

cat("✓ Centrality correlation analysis completed\n\n")

# ===== SUMMARY REPORT =====
cat("\n=== COMPARATIVE NETWORK ANALYSIS SELESAI ===\n\n")

cat("OUTPUT SUMMARY:\n")
cat("Tables created: 10 files (39-48)\n")
cat("Plots created: Multiple visualizations in output/plots/\n")
cat("Key Analysis Performed:\n")
cat("  - Network Comparison (Gender/Edu)\n")
cat("  - Node Predictability (R-squared)\n")
cat("  - Edge Stability & Expected Influence\n")
cat("  - Network Resilience & Small-worldness\n\n")

cat("All results saved in output/tables/ and output/plots/\n")
