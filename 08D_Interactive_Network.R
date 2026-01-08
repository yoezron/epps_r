# ============================================================================
# SCRIPT 08D: INTERACTIVE NETWORK VISUALIZATION & DYNAMIC ANALYSIS
# ============================================================================
# Visualisasi network interaktif dan analisis dinamis:
# - Interactive networks (visNetwork, networkD3)
# - Force-directed layouts and Sankey diagrams
# - Radial network visualization
# - Network growth animation data
# - Dynamic network by quartiles
# - 3D network visualization
#
# Dependencies: visNetwork, networkD3, htmlwidgets, igraph, plotly
# Input: output/data_processed.RData
# Output: Interactive HTML plots and tables (49-55)
# ============================================================================

# Load configuration and utilities
source("00_Config.R")
source("00_Utilities.R")

log_message("=== STARTING INTERACTIVE NETWORK & DYNAMIC ANALYSIS ===", level = "INFO")

# Load processed data
if (!file.exists("output/data_processed.RData")) {
  stop("Data file not found. Please run 01_Setup_Data.R first.")
}
load("output/data_processed.RData")

# Ensure required packages
ensure_packages(c("visNetwork", "networkD3", "htmlwidgets", "igraph", "plotly",
                  "ggplot2", "tidyr", "Matrix"))

log_message("Interactive Network: Data loaded successfully", level = "INFO")

# Rename untuk visualisasi
skor_aspek_label <- skor_aspek
names(skor_aspek_label) <- aspek_labels[aspek_epps]

# ===== 1. PREPARE NETWORK DATA =====
log_message("Preparing network data for interactive visualization", level = "INFO")

# Compute and regularize correlation matrix
cor_matrix <- cor(skor_aspek_label, use = "pairwise.complete.obs")
cor_matrix <- regularize_correlation_matrix(cor_matrix, method = "nearPD")

# Create edge list
edges_data <- data.frame(
  from = rep(1:ncol(cor_matrix), each = ncol(cor_matrix)),
  to = rep(1:ncol(cor_matrix), times = ncol(cor_matrix)),
  weight = as.vector(cor_matrix)
)

# Remove self-loops and weak edges (use config threshold)
edges_data <- edges_data[edges_data$from != edges_data$to, ]
edges_data <- edges_data[abs(edges_data$weight) > CONFIG_NETWORK_THRESHOLD_LOW, ]

# Add edge attributes
edges_data$color <- ifelse(edges_data$weight > 0,
                           "#1A9850",  # Positive = green
                           "#D73027")  # Negative = red
edges_data$width <- abs(edges_data$weight) * 5
edges_data$title <- paste0(names(skor_aspek_label)[edges_data$from],
                          " <-> ",
                          names(skor_aspek_label)[edges_data$to],
                          ": ",
                          round(edges_data$weight, 3))

log_message("Network data prepared for interactive visualization", level = "INFO")

# ===== 2. INTERACTIVE NETWORK - visNetwork =====
log_message("Creating interactive network (visNetwork)", level = "INFO")

# Node data
library(igraph)
g <- graph_from_adjacency_matrix(abs(cor_matrix),
                                 mode = "undirected",
                                 weighted = TRUE,
                                 diag = FALSE)

strength <- colSums(abs(cor_matrix)) - diag(abs(cor_matrix))
betweenness <- betweenness(g)

nodes_data <- data.frame(
  id = 1:ncol(cor_matrix),
  label = names(skor_aspek_label),
  title = paste0("<b>", names(skor_aspek_label), "</b><br>",
                "Strength: ", round(strength, 2), "<br>",
                "Betweenness: ", round(betweenness, 2)),
  value = strength * 2,  # Node size based on strength
  group = cluster_louvain(g)$membership,
  color = rainbow(max(cluster_louvain(g)$membership))[cluster_louvain(g)$membership]
)

# Create interactive network
vis_net <- visNetwork(nodes_data, edges_data,
                      main = "Interactive Network - Aspek EPPS") %>%
  visIgraphLayout(layout = "layout_with_fr") %>%
  visOptions(highlightNearest = list(enabled = TRUE, degree = 1, hover = TRUE),
             nodesIdSelection = TRUE) %>%
  visInteraction(navigationButtons = TRUE,
                hover = TRUE,
                zoomView = TRUE) %>%
  visPhysics(stabilization = TRUE,
             solver = "forceAtlas2Based",
             forceAtlas2Based = list(gravitationalConstant = -50)) %>%
  visLegend(position = "right", main = "Community")

# Save interactive network
saveWidget(vis_net,
          file.path(CONFIG_PLOTS_DIR, "Network_Interactive_visNetwork.html"),
          selfcontained = TRUE)

log_message("Interactive visNetwork saved: Network_Interactive_visNetwork.html", level = "INFO")

# ===== 3. FORCE-DIRECTED NETWORK - networkD3 =====
log_message("Creating force-directed network (D3)", level = "INFO")

# Prepare data for networkD3 (0-indexed)
edges_d3 <- data.frame(
  source = edges_data$from - 1,
  target = edges_data$to - 1,
  value = abs(edges_data$weight) * 10
)

nodes_d3 <- data.frame(
  name = names(skor_aspek_label),
  group = cluster_louvain(g)$membership,
  size = strength * 3
)

# Create force network
force_net <- forceNetwork(Links = edges_d3,
                         Nodes = nodes_d3,
                         Source = "source",
                         Target = "target",
                         Value = "value",
                         NodeID = "name",
                         Group = "group",
                         Nodesize = "size",
                         opacity = 0.9,
                         zoom = TRUE,
                         fontSize = 14,
                         linkDistance = 100,
                         charge = -50,
                         bounded = TRUE,
                         legend = TRUE,
                         opacityNoHover = 0.3)

saveWidget(force_net,
          file.path(CONFIG_PLOTS_DIR, "Network_Force_Directed_D3.html"),
          selfcontained = TRUE)

log_message("Force-directed network saved: Network_Force_Directed_D3.html", level = "INFO")

# ===== 4. SANKEY DIAGRAM - STRONGEST CONNECTIONS =====
log_message("Creating Sankey diagram for top connections", level = "INFO")

# Get top 30 strongest edges
top_edges <- edges_data[order(abs(edges_data$weight), decreasing = TRUE), ]
top_edges <- head(top_edges, 30)

sankey_links <- data.frame(
  source = top_edges$from - 1,
  target = top_edges$to - 1,
  value = abs(top_edges$weight) * 10
)

sankey_net <- sankeyNetwork(Links = sankey_links,
                           Nodes = nodes_d3,
                           Source = "source",
                           Target = "target",
                           Value = "value",
                           NodeID = "name",
                           fontSize = 12,
                           nodeWidth = 20,
                           height = 600,
                           width = 800)

saveWidget(sankey_net,
          file.path(CONFIG_PLOTS_DIR, "Network_Sankey_TopConnections.html"),
          selfcontained = TRUE)

log_message("Sankey diagram saved: Network_Sankey_TopConnections.html", level = "INFO")

# ===== 5. RADIAL NETWORK =====
log_message("Creating radial network visualization", level = "INFO")

# 1. Ambil data membership dari komunitas
# Kita perlu mengubah struktur flat (Node A ada di Grup 1) menjadi Hierarki (Grup 1 punya anak Node A)
comm_obj <- cluster_louvain(g)
membership_data <- data.frame(
  node = names(membership(comm_obj)),
  group = as.numeric(membership(comm_obj)),
  stringsAsFactors = FALSE
)

# 2. Konversi ke format Hierarchical List (Tree Structure) yang dibutuhkan networkD3
# Struktur: Root -> Group (Community) -> Node (Aspek)
hc_list <- list(
  name = "EPPS Network",
  children = list()
)

# Loop untuk setiap grup komunitas
unique_groups <- sort(unique(membership_data$group))

for(grp in unique_groups) {
  # Ambil semua node dalam grup ini
  nodes_in_group <- membership_data$node[membership_data$group == grp]

  # Buat list anak-anak (nodes)
  children_nodes <- lapply(nodes_in_group, function(n) list(name = n))

  # Masukkan ke dalam grup
  group_list <- list(
    name = paste("Community", grp), # Nama Cabang
    children = children_nodes       # Daun (Nodes)
  )

  # Masukkan grup ke root
  hc_list$children[[length(hc_list$children) + 1]] <- group_list
}

# 3. Buat Radial Network
radial_net <- radialNetwork(List = hc_list,
                            fontSize = 12,
                            opacity = 0.9,
                            nodeColour = "name", # Warna berdasarkan nama level
                            nodeStroke = "#fff",
                            textColour = "#000")

# 4. Simpan Widget
saveWidget(radial_net,
           file.path(CONFIG_PLOTS_DIR, "Network_Radial_Communities.html"),
           selfcontained = TRUE)

log_message("Radial network saved: Network_Radial_Communities.html", level = "INFO")

# ===== 6. ANIMATED NETWORK GROWTH =====
log_message("Creating network growth animation data", level = "INFO")

# Simulate network growth by edge weight threshold
thresholds <- seq(0.5, 0.1, by = -0.05)

growth_data <- list()
for(i in seq_along(thresholds)) {
  threshold <- thresholds[i]

  # Filter edges
  edges_thresh <- edges_data[abs(edges_data$weight) >= threshold, ]

  # Count nodes and edges
  nodes_in_net <- unique(c(edges_thresh$from, edges_thresh$to))

  growth_data[[i]] <- data.frame(
    Step = i,
    Threshold = threshold,
    N_Nodes = length(nodes_in_net),
    N_Edges = nrow(edges_thresh),
    Density = nrow(edges_thresh) / (length(nodes_in_net) * (length(nodes_in_net) - 1) / 2)
  )
}

growth_df <- do.call(rbind, growth_data)
write.csv(growth_df,
          file.path(CONFIG_TABLES_DIR, "49_Network_Growth_Sequence.csv"),
          row.names = FALSE)
log_message("Growth sequence table saved: 49_Network_Growth_Sequence.csv", level = "INFO")

# Plot growth curve
library(ggplot2)

p_growth <- ggplot(growth_df, aes(x = Threshold)) +
  geom_line(aes(y = N_Edges, color = "Edges"), size = 1.2) +
  geom_line(aes(y = N_Nodes * 10, color = "Nodes (×10)"), size = 1.2) +
  scale_y_continuous(
    name = "Number of Edges",
    sec.axis = sec_axis(~./10, name = "Number of Nodes")
  ) +
  scale_x_reverse() +
  scale_color_manual(values = c("Edges" = "blue", "Nodes (×10)" = "red")) +
  theme_minimal(base_size = 12) +
  labs(title = "Network Growth as Threshold Decreases",
       subtitle = "Lower threshold = more edges included",
       x = "Correlation Threshold",
       color = "") +
  theme(legend.position = "top")

ggsave(file.path(CONFIG_PLOTS_DIR, "Network_Growth_Curve.png"), p_growth,
       width = 10, height = 6, dpi = CONFIG_PLOT_RESOLUTION)

log_message("Growth curve plot saved: Network_Growth_Curve.png", level = "INFO")

# ===== 7. DYNAMIC NETWORK BY QUARTILES =====
log_message("Creating networks by score quartiles", level = "INFO")

# Hitung strength global dulu jika belum ada
if(!exists("strength")) {
  # Hitung ulang cepat jika variabel strength hilang dari memori
  temp_cor <- cor(skor_aspek_label, use = "pairwise.complete.obs")
  strength <- colSums(abs(temp_cor)) - diag(abs(temp_cor))
}

# Ambil 3 aspek dengan centrality tertinggi
top_nodes <- head(order(strength, decreasing = TRUE), 3)

for(node_idx in top_nodes) {
  node_name <- names(skor_aspek_label)[node_idx]
  node_scores <- skor_aspek_label[, node_idx]

  # Create quartile groups (Membagi data menjadi 4 kelompok skor: Rendah s/d Tinggi)
  quartiles <- quantile(node_scores, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)

  for(q in 1:4) {
    q_label <- paste0("Q", q)

    # Ambil sampel yang skornya masuk range quartile ini
    # Kita pakai >= di awal dan <= di akhir untuk handle nilai max
    if (q == 4) {
      idx_q <- which(node_scores >= quartiles[q] & node_scores <= quartiles[q+1])
    } else {
      idx_q <- which(node_scores >= quartiles[q] & node_scores < quartiles[q+1])
    }

    # Proses hanya jika sampel cukup (min 30 orang agar korelasi valid)
    if(length(idx_q) >= 30) {
      data_q <- skor_aspek_label[idx_q, ]

      # 1. Hitung Korelasi
      # Kita gunakan tryCatch untuk handle jika variansi data terlalu kecil (sangat seragam)
      cor_q <- tryCatch({
        cor(data_q, use = "pairwise.complete.obs")
      }, warning = function(w) {
        # Jika terjadi warning (misal SD=0), return matriks nol
        matrix(0, ncol(data_q), ncol(data_q))
      })

      # Cek apakah cor_q valid (bukan NA)
      if(any(is.na(cor_q))) {
        cor_q[is.na(cor_q)] <- 0
      }

      # 2. Regularisasi Robust (nearPD)
      # Ini solusi ampuh menghilangkan warning "positive definite"
      clean_fit <- nearPD(cor_q, corr = TRUE, do2eigen = TRUE)
      cor_q_clean <- as.matrix(clean_fit$mat)

      # 3. Plot
      png(paste0("output/plots/Network_", gsub(" ", "_", node_name),
                 "_", q_label, ".png"),
          width = 2400, height = 2400, res = 300)

      tryCatch({
        qgraph(cor_q_clean,
               layout = "spring",
               graph = "cor",
               threshold = CONFIG_NETWORK_THRESHOLD_LOW,
               title = paste("Network -", node_name, q_label,
                             "(n =", length(idx_q), ")"),
               labels = names(skor_aspek_label),
               label.cex = 0.9,
               vsize = 6,
               posCol = "#1A9850",
               negCol = "#D73027",
               color = "white",       # Warna node netral
               theme = "colorblind")
      }, error = function(e) {
        log_message(sprintf("Skip quartile plot due to error: %s", e$message), level = "WARN")
      })

      dev.off()
    }
  }

  log_message(sprintf("Quartile networks created for: %s", node_name), level = "INFO")
}

# ===== 8. CORRELATION NETWORK OVER TIME SIMULATION =====
log_message("Simulating temporal network changes", level = "INFO")

# Split data into time windows (simulate temporal data)
n_windows <- CONFIG_NETWORK_TIME_WINDOWS
window_size <- floor(nrow(skor_aspek_label) / n_windows)

temporal_metrics <- data.frame(
  Window = integer(),
  Density = numeric(),
  Transitivity = numeric(),
  Mean_Strength = numeric(),
  Max_Betweenness = numeric()
)

for(w in 1:n_windows) {
  start_idx <- (w - 1) * window_size + 1
  end_idx <- min(w * window_size, nrow(skor_aspek_label))

  data_window <- skor_aspek_label[start_idx:end_idx, ]
  cor_window <- cor(data_window, use = "pairwise.complete.obs")

  # Regularize
  eigenvalues_w <- eigen(cor_window)$values
  if(min(eigenvalues_w) < 0) {
    regularization_w <- abs(min(eigenvalues_w)) + 0.01
    diag(cor_window) <- diag(cor_window) + regularization_w
  }

  # Compute metrics
  g_window <- graph_from_adjacency_matrix(abs(cor_window),
                                         mode = "undirected",
                                         weighted = TRUE,
                                         diag = FALSE)

  temporal_metrics <- rbind(temporal_metrics, data.frame(
    Window = w,
    Density = edge_density(g_window),
    Transitivity = transitivity(g_window),
    Mean_Strength = mean(colSums(abs(cor_window)) - diag(abs(cor_window))),
    Max_Betweenness = max(betweenness(g_window))
  ))
}

write.csv(temporal_metrics,
          file.path(CONFIG_TABLES_DIR, "50_Temporal_Network_Metrics.csv"),
          row.names = FALSE)
log_message("Temporal metrics table saved: 50_Temporal_Network_Metrics.csv", level = "INFO")

# Plot temporal changes
library(tidyr)
temporal_long <- pivot_longer(temporal_metrics,
                              cols = -Window,
                              names_to = "Metric",
                              values_to = "Value")

# Normalize for plotting
temporal_long <- temporal_long %>%
  group_by(Metric) %>%
  mutate(Value_Scaled = scale(Value)[,1])

p_temporal <- ggplot(temporal_long,
                     aes(x = Window, y = Value_Scaled, color = Metric, group = Metric)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  theme_minimal(base_size = 12) +
  labs(title = "Temporal Changes in Network Metrics",
       subtitle = "Simulated time windows across dataset",
       x = "Time Window", y = "Standardized Value") +
  theme(legend.position = "top")

ggsave(file.path(CONFIG_PLOTS_DIR, "Network_Temporal_Changes.png"), p_temporal,
       width = 10, height = 6, dpi = CONFIG_PLOT_RESOLUTION)

log_message("Temporal plot saved: Network_Temporal_Changes.png", level = "INFO")

# ===== 9. 3D NETWORK VISUALIZATION DATA =====
log_message("Preparing 3D network visualization data", level = "INFO")

# Create 3D coordinates using MDS
dist_matrix <- as.dist(1 - abs(cor_matrix))
mds_3d <- cmdscale(dist_matrix, k = 3)

nodes_3d <- data.frame(
  Aspek = names(skor_aspek_label),
  X = mds_3d[, 1],
  Y = mds_3d[, 2],
  Z = mds_3d[, 3],
  Strength = strength,
  Community = cluster_louvain(g)$membership
)

write.csv(nodes_3d,
          file.path(CONFIG_TABLES_DIR, "51_Network_3D_Coordinates.csv"),
          row.names = FALSE)
log_message("3D coordinates table saved: 51_Network_3D_Coordinates.csv", level = "INFO")

# Create plotly 3D scatter
library(plotly)

plot_3d <- plot_ly(nodes_3d,
                  x = ~X, y = ~Y, z = ~Z,
                  text = ~Aspek,
                  color = ~as.factor(Community),
                  size = ~Strength,
                  marker = list(sizemode = 'diameter',
                               sizeref = 0.5),
                  hoverinfo = 'text') %>%
  add_markers() %>%
  layout(title = "3D Network Visualization - Aspek EPPS",
         scene = list(
           xaxis = list(title = "Dimension 1"),
           yaxis = list(title = "Dimension 2"),
           zaxis = list(title = "Dimension 3")
         ))

saveWidget(plot_3d,
          file.path(CONFIG_PLOTS_DIR, "Network_3D_Interactive.html"),
          selfcontained = TRUE)

log_message("3D network visualization saved: Network_3D_Interactive.html", level = "INFO")

# ===== 10. NETWORK SUMMARY DASHBOARD DATA =====
log_message("Creating dashboard summary data", level = "INFO")

dashboard_data <- list(
  NetworkStats = data.frame(
    Metric = c("Total Nodes", "Total Edges", "Density", "Transitivity",
               "Average Path Length", "Diameter", "Communities"),
    Value = c(
      ncol(cor_matrix),
      nrow(edges_data),
      round(edge_density(g), 3),
      round(transitivity(g), 3),
      round(mean_distance(g), 3),
      diameter(g),
      max(cluster_louvain(g)$membership)
    )
  ),

  TopNodes = data.frame(
    Aspek = names(skor_aspek_label),
    Strength = strength,
    Betweenness = betweenness
  ) %>% arrange(desc(Strength)) %>% head(10),

  StrongestEdges = edges_data %>%
    arrange(desc(abs(weight))) %>%
    head(10) %>%
    mutate(
      From_Node = names(skor_aspek_label)[from],
      To_Node = names(skor_aspek_label)[to]
    ) %>%
    select(From_Node, To_Node, weight),

  Communities = data.frame(
    Community = 1:max(cluster_louvain(g)$membership),
    Size = as.numeric(table(cluster_louvain(g)$membership)),
    Members = sapply(1:max(cluster_louvain(g)$membership), function(c) {
      paste(names(skor_aspek_label)[cluster_louvain(g)$membership == c],
            collapse = ", ")
    })
  )
)

# Save dashboard data
write.csv(dashboard_data$NetworkStats,
         file.path(CONFIG_TABLES_DIR, "52_Dashboard_NetworkStats.csv"),
         row.names = FALSE)
write.csv(dashboard_data$TopNodes,
         file.path(CONFIG_TABLES_DIR, "53_Dashboard_TopNodes.csv"),
         row.names = FALSE)
write.csv(dashboard_data$StrongestEdges,
         file.path(CONFIG_TABLES_DIR, "54_Dashboard_StrongestEdges.csv"),
         row.names = FALSE)
write.csv(dashboard_data$Communities,
         file.path(CONFIG_TABLES_DIR, "55_Dashboard_Communities.csv"),
         row.names = FALSE)

log_message("Dashboard data tables saved: 52-55", level = "INFO")

# ===== SUMMARY =====
log_message("=== INTERACTIVE & DYNAMIC NETWORK ANALYSIS COMPLETED ===", level = "INFO")
log_message("Interactive visualizations: visNetwork, Force-Directed D3, Sankey, Radial, 3D Plotly", level = "INFO")
log_message("Static visualizations: Growth curve, Temporal changes, Quartile networks", level = "INFO")
log_message("Tables saved: 49-55 (Growth, Temporal, 3D, Dashboard summaries)", level = "INFO")
log_message("Interactive HTML files ready for web browser exploration", level = "INFO")
