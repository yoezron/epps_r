# ============================================================================
# SCRIPT 08B: ADVANCED NETWORK ANALYSIS ANTAR ASPEK
# ============================================================================
# Analisis network yang lebih komprehensif dengan multiple methods:
# - Multiple layouts (spring, circle, groups)
# - Extended centrality measures (Eigenvector, PageRank, Authority)
# - Bridge centrality analysis
# - Global network metrics and clique analysis
#
# Dependencies: qgraph, igraph, Matrix, ggplot2, tidyr
# Input: output/data_processed.RData
# Output: Extended network plots and tables (29-38)
# ============================================================================

# Load configuration and utilities
source("00_Config.R")
source("00_Utilities.R")

log_message("=== STARTING ADVANCED NETWORK ANALYSIS ===", level = "INFO")

# Load processed data
if (!file.exists("output/data_processed.RData")) {
  stop("Data file not found. Please run 01_Setup_Data.R first.")
}
load("output/data_processed.RData")

# Ensure required packages
ensure_packages(c("qgraph", "igraph", "Matrix", "ggplot2", "tidyr", "reshape2"))

log_message("Advanced Network: Data loaded successfully", level = "INFO")

# Rename untuk visualisasi
skor_aspek_label <- skor_aspek
names(skor_aspek_label) <- aspek_labels[aspek_epps]

# ===== 1. MULTIPLE NETWORK ESTIMATION METHODS =====
log_message("Estimating network with multiple methods", level = "INFO")

# Compute and regularize correlation matrix using utility function
raw_cor <- cor(skor_aspek_label, use = "pairwise.complete.obs")
cor_matrix <- regularize_correlation_matrix(raw_cor, method = "nearPD")

# 3. Method 1: Correlation Network
# Kita gunakan tryCatch agar jika masih error, skrip tidak berhenti total
network_cor <- tryCatch({
  estimateNetwork(cor_matrix,
                  sampleSize = nrow(skor_aspek_label),
                  default = "cor")
}, error = function(e) {
  cat("Warning: estimateNetwork 'cor' failed. Creating manual network object.\n")
  # Fallback: Buat objek manual agar skrip selanjutnya tetap jalan
  list(graph = cor_matrix,
       labels = colnames(cor_matrix),
       nNode = ncol(cor_matrix))
})

# 4. Method 2: Partial Correlation (GGM)
network_pcor <- tryCatch({
  estimateNetwork(cor_matrix,
                  sampleSize = nrow(skor_aspek_label),
                  default = "pcor")
}, error = function(e) {
  cat("Partial correlation failed. Using correlation network as fallback.\n")
  network_cor
})

log_message("Networks estimated successfully", level = "INFO")

# ===== 2. NETWORK VISUALIZATION - MULTIPLE LAYOUTS =====
log_message("Creating network visualizations with multiple layouts", level = "INFO")

# Layout 1: Spring layout
save_plot(
  filename = "Network_Spring_Layout.png",
  plot_function = function() {
    qgraph(cor_matrix,
           layout = "spring",
           graph = "cor",
           threshold = "sig",
           sampleSize = nrow(skor_aspek_label),
           alpha = 0.05,
           title = "Network Aspek EPPS - Spring Layout",
           labels = names(skor_aspek_label),
           label.cex = 1.0,
           vsize = 7,
           esize = 10,
           posCol = "#1A9850",
           negCol = "#D73027",
           theme = "colorblind")
  },
  width = CONFIG_PLOT_WIDTH_XLARGE,
  height = CONFIG_PLOT_HEIGHT_XLARGE,
  res = CONFIG_PLOT_RESOLUTION
)

# Layout 2: Circle layout
save_plot(
  filename = "Network_Circle_Layout.png",
  plot_function = function() {
    qgraph(cor_matrix,
           layout = "circle",
           graph = "cor",
           threshold = CONFIG_NETWORK_THRESHOLD_LOW,
           title = "Network Aspek EPPS - Circle Layout",
           labels = names(skor_aspek_label),
           label.cex = 1.0,
           vsize = 7,
           esize = 10,
           posCol = "#1A9850",
           negCol = "#D73027",
           theme = "colorblind")
  },
  width = CONFIG_PLOT_WIDTH_XLARGE,
  height = CONFIG_PLOT_HEIGHT_XLARGE,
  res = CONFIG_PLOT_RESOLUTION
)

# Layout 3: Groups layout (berdasarkan similarity)
save_plot(
  filename = "Network_Groups_Layout.png",
  plot_function = function() {
    qgraph(cor_matrix,
           layout = "groups",
           graph = "cor",
           threshold = CONFIG_NETWORK_THRESHOLD_LOW,
           title = "Network Aspek EPPS - Groups Layout",
           labels = names(skor_aspek_label),
           label.cex = 1.0,
           vsize = 7,
           esize = 10,
           posCol = "#1A9850",
           negCol = "#D73027")
  },
  width = CONFIG_PLOT_WIDTH_XLARGE,
  height = CONFIG_PLOT_HEIGHT_XLARGE,
  res = CONFIG_PLOT_RESOLUTION
)

log_message("Network plots created (Spring, Circle, Groups)", level = "INFO")

# ===== 3. CENTRALITY ANALYSIS - EXTENDED =====
log_message("Computing extended centrality measures", level = "INFO")

# Use manual calculation via igraph (more robust)
library(igraph)

# Pastikan kita menggunakan cor_matrix yang valid dari Section 1
# Jika cor_matrix tertimpa, kita ambil dari network_cor jika memungkinkan
if(!exists("cor_matrix")) {
  if(is.list(network_cor) && !is.null(network_cor$graph)) {
    cor_matrix <- network_cor$graph
  }
}

# Buat graph object dari matrix
# Kita gunakan nilai absolut (abs) untuk centrality strength
g <- graph_from_adjacency_matrix(abs(cor_matrix),
                                 mode = "undirected",
                                 weighted = TRUE,
                                 diag = FALSE)

# Additional centrality measures
cat("Calculating Eigenvector centrality...\n")
eigenvector_cent <- eigen_centrality(g)$vector

cat("Calculating PageRank...\n")
pagerank_cent <- page_rank(g)$vector

cat("Calculating Authority score...\n")
authority_cent <- authority_score(g)$vector

# Combine all centrality measures
centrality_all <- data.frame(
  Aspek = names(skor_aspek_label),
  Strength = colSums(abs(cor_matrix)) - diag(abs(cor_matrix)), # Hitung strength manual
  Betweenness = betweenness(g),
  Closeness = closeness(g),
  Eigenvector = eigenvector_cent,
  PageRank = pagerank_cent,
  Authority = authority_cent
)

# Standardize (z-scores) agar skala seragam
centrality_all[, -1] <- scale(centrality_all[, -1])

# Simpan tabel
write.csv(centrality_all,
          file.path(CONFIG_TABLES_DIR, "29_Network_Centrality_Extended.csv"),
          row.names = FALSE)
log_message("Extended centrality table saved: 29_Network_Centrality_Extended.csv", level = "INFO")

# Plot extended centrality
library(ggplot2)
library(tidyr)

centrality_long <- pivot_longer(centrality_all,
                                cols = -Aspek,
                                names_to = "Measure",
                                values_to = "Value")

p_cent <- ggplot(centrality_long, aes(x = reorder(Aspek, Value), y = Value, fill = Measure)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  facet_wrap(~ Measure, scales = "free_x") +
  theme_minimal(base_size = 10) +
  labs(title = "Extended Centrality Measures - Aspek EPPS",
       x = "Aspek", y = "Z-score") +
  theme(legend.position = "none")

ggsave("output/plots/Network_Centrality_Extended.png", p_cent,
       width = 14, height = 10, dpi = 300)

cat("✓ Extended centrality computed successfully\n\n")

# ===== 4. BRIDGE CENTRALITY =====
cat("--- Bridge Centrality Analysis ---\n")

# Identify potential communities first
communities <- cluster_louvain(g)

# Bridge function
bridge_centrality <- function(graph, communities) {
  bridge_strength <- numeric(vcount(graph))

  for(i in 1:vcount(graph)) {
    # Get neighbors
    neighbors <- neighbors(graph, i)
    if(length(neighbors) == 0) next

    # Count neighbors from different communities
    node_comm <- communities$membership[i]
    different_comm <- sum(communities$membership[neighbors] != node_comm)

    bridge_strength[i] <- different_comm / length(neighbors)
  }

  return(bridge_strength)
}

bridge_scores <- bridge_centrality(g, communities)

bridge_df <- data.frame(
  Aspek = names(skor_aspek_label),
  Bridge_Strength = round(bridge_scores, 3),
  Community = communities$membership
)

write.csv(bridge_df, "output/tables/30_Network_Bridge_Centrality.csv",
          row.names = FALSE)

# Plot bridge centrality
png("output/plots/Network_Bridge_Centrality.png", width = 2400, height = 1800, res = 300)
par(mar = c(5, 10, 4, 2))
barplot(bridge_scores,
        names.arg = names(skor_aspek_label),
        horiz = TRUE,
        las = 1,
        col = "coral",
        main = "Bridge Centrality - Penghubung Antar Community",
        xlab = "Bridge Strength")
dev.off()

cat("✓ Bridge centrality computed\n\n")

# ===== 5. NETWORK DENSITY & GLOBAL METRICS =====
cat("--- Global Network Metrics ---\n")

global_metrics <- data.frame(
  Metric = c("Density", "Transitivity", "Average Path Length",
             "Diameter", "Modularity", "Number of Communities"),
  Value = c(
    round(edge_density(g), 3),
    round(transitivity(g), 3),
    round(mean_distance(g), 3),
    diameter(g),
    round(modularity(communities), 3),
    max(communities$membership)
  )
)

write.csv(global_metrics, "output/tables/31_Network_Global_Metrics.csv",
          row.names = FALSE)

cat("Global Metrics:\n")
print(global_metrics)
cat("\n")

# ===== 6. CLIQUE ANALYSIS =====
cat("--- Clique Analysis ---\n")

# Find maximal cliques
cliques <- max_cliques(g, min = 3)  # Minimal 3 nodes

# Get top 10 largest cliques
clique_sizes <- sapply(cliques, length)
top_cliques <- cliques[order(clique_sizes, decreasing = TRUE)][1:min(10, length(cliques))]

clique_list <- list()
for(i in seq_along(top_cliques)) {
  clique_nodes <- names(skor_aspek_label)[top_cliques[[i]]]
  clique_list[[i]] <- data.frame(
    Clique_ID = i,
    Size = length(clique_nodes),
    Members = paste(clique_nodes, collapse = ", ")
  )
}

if(length(clique_list) > 0) {
  cliques_df <- do.call(rbind, clique_list)
  write.csv(cliques_df, "output/tables/32_Network_Cliques.csv", row.names = FALSE)
  cat("✓ Top", nrow(cliques_df), "cliques identified\n\n")
}

# ===== 7. DYAD & TRIAD ANALYSIS =====
cat("--- Dyad & Triad Analysis ---\n")

# Dyad census
dyad_census_result <- dyad_census(g)
dyad_df <- data.frame(
  Type = c("Mutual", "Asymmetric", "Null"),
  Count = c(dyad_census_result$mut, dyad_census_result$asym, dyad_census_result$null)
)

# Triad census
triad_census_result <- triad_census(g)
triad_types <- c("003", "012", "102", "021D", "021U", "021C", "111D", "111U",
                 "030T", "030C", "201", "120D", "120U", "120C", "210", "300")
triad_df <- data.frame(
  Type = triad_types,
  Count = triad_census_result
)

write.csv(dyad_df, "output/tables/33_Network_Dyad_Census.csv", row.names = FALSE)
write.csv(triad_df, "output/tables/34_Network_Triad_Census.csv", row.names = FALSE)

cat("✓ Dyad & Triad census completed\n\n")

# ===== 8. CORRELATION BY COMMUNITY =====
cat("--- Within vs Between Community Correlations ---\n")

community_cors <- data.frame(
  Community = integer(),
  Within_Mean = numeric(),
  Within_SD = numeric(),
  Between_Mean = numeric(),
  Between_SD = numeric()
)

for(comm in 1:max(communities$membership)) {
  nodes_in_comm <- which(communities$membership == comm)

  # Within-community correlations
  if(length(nodes_in_comm) > 1) {
    within_cors <- cor_matrix[nodes_in_comm, nodes_in_comm]
    within_cors <- within_cors[lower.tri(within_cors)]

    # Between-community correlations
    nodes_out_comm <- which(communities$membership != comm)
    if(length(nodes_out_comm) > 0) {
      between_cors <- as.vector(cor_matrix[nodes_in_comm, nodes_out_comm])

      community_cors <- rbind(community_cors, data.frame(
        Community = comm,
        Within_Mean = round(mean(within_cors, na.rm = TRUE), 3),
        Within_SD = round(sd(within_cors, na.rm = TRUE), 3),
        Between_Mean = round(mean(between_cors, na.rm = TRUE), 3),
        Between_SD = round(sd(between_cors, na.rm = TRUE), 3)
      ))
    }
  }
}

write.csv(community_cors, "output/tables/35_Network_Community_Correlations.csv",
          row.names = FALSE)

cat("✓ Community correlation analysis completed\n\n")

# ===== 9. NETWORK HEATMAP =====
cat("--- Network Heatmap ---\n")

library(reshape2)
cor_melted <- melt(cor_matrix)
names(cor_melted) <- c("Aspek1", "Aspek2", "Correlation")

p_heatmap <- ggplot(cor_melted, aes(x = Aspek1, y = Aspek2, fill = Correlation)) +
  geom_tile() +
  scale_fill_gradient2(low = "#D73027", mid = "white", high = "#1A9850",
                       midpoint = 0, limits = c(-1, 1),
                       name = "Correlation") +
  theme_minimal(base_size = 10) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(angle = 0)) +
  labs(title = "Network Heatmap - Korelasi Antar Aspek EPPS",
       x = "", y = "") +
  coord_fixed()

ggsave("output/plots/Network_Heatmap.png", p_heatmap,
       width = 12, height = 11, dpi = 300)

cat("✓ Heatmap created\n\n")

# ===== 10. EDGE BETWEENNESS PLOT =====
cat("--- Edge Betweenness Analysis ---\n")

edge_betweenness_scores <- edge_betweenness(g)

# Get top edges by betweenness
edges <- as_edgelist(g)
edge_df <- data.frame(
  From = names(skor_aspek_label)[edges[, 1]],
  To = names(skor_aspek_label)[edges[, 2]],
  Betweenness = edge_betweenness_scores,
  Weight = E(g)$weight
)

edge_df <- edge_df[order(edge_df$Betweenness, decreasing = TRUE), ]
write.csv(edge_df, "output/tables/36_Network_Edge_Betweenness.csv", row.names = FALSE)

# Plot top 20 edges
if(nrow(edge_df) >= 20) {
  top_edges <- head(edge_df, 20)
  top_edges$Edge <- paste(top_edges$From, "-", top_edges$To)

  p_edges <- ggplot(top_edges, aes(x = reorder(Edge, Betweenness), y = Betweenness)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    coord_flip() +
    theme_minimal(base_size = 10) +
    labs(title = "Top 20 Edges by Betweenness",
         x = "Edge", y = "Betweenness")

  ggsave("output/plots/Network_Edge_Betweenness.png", p_edges,
         width = 10, height = 8, dpi = 300)
}

cat("✓ Edge betweenness computed\n\n")

# ===== 11. SHORTEST PATHS ANALYSIS =====
cat("--- Shortest Paths Between Key Traits ---\n")

# Analyze paths between high centrality nodes
top_nodes <- head(order(centrality_all$Strength, decreasing = TRUE), 5)

paths_list <- list()
for(i in 1:(length(top_nodes)-1)) {
  for(j in (i+1):length(top_nodes)) {
    path <- shortest_paths(g, from = top_nodes[i], to = top_nodes[j])$vpath[[1]]
    if(length(path) > 0) {
      path_names <- names(skor_aspek_label)[path]
      paths_list[[length(paths_list) + 1]] <- data.frame(
        From = names(skor_aspek_label)[top_nodes[i]],
        To = names(skor_aspek_label)[top_nodes[j]],
        Path_Length = length(path) - 1,
        Path = paste(path_names, collapse = " -> ")
      )
    }
  }
}

if(length(paths_list) > 0) {
  paths_df <- do.call(rbind, paths_list)
  write.csv(paths_df, "output/tables/37_Network_Shortest_Paths.csv", row.names = FALSE)
  cat("✓ Shortest paths computed\n\n")
}

# ===== 12. NETWORK COMPARISON: Positive vs Negative Edges =====
cat("--- Positive vs Negative Edge Analysis ---\n")

cor_pos <- cor_matrix
cor_pos[cor_pos < 0] <- 0

cor_neg <- cor_matrix
cor_neg[cor_neg > 0] <- 0
cor_neg <- abs(cor_neg)

# Positive network
png("output/plots/Network_Positive_Only.png", width = 2800, height = 2800, res = 300)
qgraph(cor_pos,
       layout = "spring",
       threshold = 0.15,
       title = "Network - Positive Correlations Only",
       labels = names(skor_aspek_label),
       label.cex = 1.0,
       vsize = 7,
       color = "#1A9850",
       theme = "colorblind")
dev.off()

# Negative network
png("output/plots/Network_Negative_Only.png", width = 2800, height = 2800, res = 300)
qgraph(cor_neg,
       layout = "spring",
       threshold = 0.15,
       title = "Network - Negative Correlations Only (Ipsativity Effect)",
       labels = names(skor_aspek_label),
       label.cex = 1.0,
       vsize = 7,
       color = "#D73027",
       theme = "colorblind")
dev.off()

# Summary stats
edge_stats <- data.frame(
  Type = c("Positive Edges", "Negative Edges", "Total Edges"),
  Count = c(
    sum(cor_matrix[lower.tri(cor_matrix)] > 0),
    sum(cor_matrix[lower.tri(cor_matrix)] < 0),
    sum(cor_matrix[lower.tri(cor_matrix)] != 0)
  ),
  Mean_Weight = c(
    mean(cor_matrix[cor_matrix > 0], na.rm = TRUE),
    mean(abs(cor_matrix[cor_matrix < 0]), na.rm = TRUE),
    mean(abs(cor_matrix[lower.tri(cor_matrix)]), na.rm = TRUE)
  )
)

write.csv(edge_stats, "output/tables/38_Network_Edge_Statistics.csv", row.names = FALSE)

cat("✓ Positive/Negative network analysis completed\n\n")

# ===== SUMMARY =====
log_message("=== ADVANCED NETWORK ANALYSIS COMPLETED ===", level = "INFO")
log_message("Tables saved: 29-38 (Extended centrality, Bridge, Global metrics, etc.)", level = "INFO")
log_message("Plots saved: Multiple layouts, Heatmap, Edge betweenness, Positive/Negative networks", level = "INFO")

log_message(sprintf("Network density: %.3f", global_metrics$Value[1]), level = "INFO")
log_message(sprintf("Transitivity: %.3f", global_metrics$Value[2]), level = "INFO")
log_message(sprintf("Number of communities: %d", global_metrics$Value[6]), level = "INFO")
log_message(sprintf("Positive edges: %d, Negative edges: %d",
                    edge_stats$Count[1], edge_stats$Count[2]), level = "INFO")
