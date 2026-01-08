# ============================================================================
# SCRIPT 08: NETWORK ANALYSIS ASPEK EPPS
# ============================================================================
# Analisis network psikometrik menggunakan Gaussian Graphical Models
# dan analisis centrality untuk memahami struktur hubungan antar aspek.
#
# Dependencies: bootnet, qgraph, igraph, Matrix
# Input: output/data_processed.RData
# Output: Network plots, centrality tables, community detection results
# ============================================================================

# Load configuration and utilities
source("00_Config.R")
source("00_Utilities.R")

log_message("=== STARTING NETWORK ANALYSIS ===", level = "INFO")

# Load processed data
if (!file.exists("output/data_processed.RData")) {
  stop("Data file not found. Please run 01_Setup_Data.R first.")
}
load("output/data_processed.RData")

# Ensure required packages
ensure_packages(c("bootnet", "qgraph", "igraph", "Matrix"))

log_message("Network Analysis: Data loaded successfully", level = "INFO")

# Rename columns untuk visualisasi
skor_aspek_label <- skor_aspek
names(skor_aspek_label) <- aspek_labels[aspek_epps]

# ===== GAUSSIAN GRAPHICAL MODEL (GGM) =====
log_message("Estimating Gaussian Graphical Model (GGM)", level = "INFO")

# Compute and regularize correlation matrix
cor_matrix <- cor(skor_aspek_label, use = "pairwise.complete.obs")
cor_matrix <- regularize_correlation_matrix(cor_matrix, method = "nearPD")

# Estimate network with error handling
network <- tryCatch({
  estimateNetwork(skor_aspek_label,
                  default = "EBICglasso",
                  corMethod = "cor",
                  missing = "pairwise",
                  threshold = TRUE)
}, error = function(e) {
  cat("EBICglasso failed:", e$message, "\n")
  cat("Trying alternative method (cor)...\n")

  tryCatch({
    estimateNetwork(skor_aspek_label,
                    default = "cor",
                    corMethod = "cor",
                    missing = "pairwise")
  }, error = function(e2) {
    cat("Alternative method also failed:", e2$message, "\n")
    cat("Using simple correlation network...\n")

    # Manual network creation
    list(graph = cor_matrix,
         results = list(optnet = cor_matrix))
  })
})

# Plot network
save_plot(
  filename = "Network_GGM.png",
  plot_function = function() {
    tryCatch({
      plot(network,
           layout = "spring",
           title = "Network Antar Aspek EPPS (Gaussian Graphical Model)",
           theme = "colorblind",
           labels = names(skor_aspek_label),
           label.cex = 1.2,
           vsize = 8,
           edge.labels = FALSE)
    }, error = function(e) {
      # Fallback: plot correlation matrix as network
      qgraph(cor_matrix,
             layout = "spring",
             title = "Network Antar Aspek EPPS (Correlation-based)",
             theme = "colorblind",
             labels = names(skor_aspek_label),
             label.cex = 1.2,
             vsize = 8,
             minimum = CONFIG_NETWORK_THRESHOLD_LOW,
             cut = CONFIG_NETWORK_THRESHOLD_HIGH)
    })
  },
  width = CONFIG_PLOT_WIDTH_XLARGE,
  height = CONFIG_PLOT_HEIGHT_XLARGE,
  res = CONFIG_PLOT_RESOLUTION
)

log_message("Network plot saved: Network_GGM.png", level = "INFO")

# ===== CENTRALITY MEASURES =====
log_message("Computing centrality measures", level = "INFO")

centrality_measures <- tryCatch({
  centralityTable(network)
}, error = function(e) {
  log_message("Standard centrality failed, computing from graph", level = "WARN")

  # Manual centrality from graph
  g <- network$graph
  if(is.null(g)) g <- cor_matrix

  # Compute basic centrality
  strength <- colSums(abs(g)) - diag(abs(g))

  data.frame(
    node = names(skor_aspek_label),
    measure = "Strength",
    value = strength
  )
})

write.csv(centrality_measures,
          file.path(CONFIG_TABLES_DIR, "25_Network_Centrality.csv"),
          row.names = FALSE)
log_message("Centrality table saved: 25_Network_Centrality.csv", level = "INFO")

# Plot centrality
save_plot(
  filename = "Network_Centrality.png",
  plot_function = function() {
    tryCatch({
      centralityPlot(network, include = c("Strength", "Betweenness", "Closeness"),
                     orderBy = "Strength",
                     scale = "z-scores") +
        ggtitle("Centrality Measures - Aspek EPPS") +
        theme_minimal(base_size = 12)
    }, error = function(e) {
      # Fallback: simple barplot
      if("value" %in% names(centrality_measures)) {
        strength_data <- centrality_measures[centrality_measures$measure == "Strength", ]
        par(mar = c(5, 10, 4, 2))
        barplot(strength_data$value,
                names.arg = strength_data$node,
                horiz = TRUE,
                las = 1,
                col = "steelblue",
                main = "Network Strength - Aspek EPPS",
                xlab = "Strength")
      }
    })
  },
  width = CONFIG_PLOT_WIDTH_MEDIUM,
  height = CONFIG_PLOT_HEIGHT_SMALL,
  res = CONFIG_PLOT_RESOLUTION
)

log_message("Centrality plot saved: Network_Centrality.png", level = "INFO")

# ===== CLUSTERING COEFFICIENT =====
log_message("Computing clustering coefficient", level = "INFO")

clustering <- tryCatch({
  clustcoef_auto(network$graph)
}, error = function(e) {
  log_message("Clustering from network failed, using fallback", level = "WARN")
  # Simple clustering from correlation
  rep(NA, ncol(cor_matrix))
})

clustering_df <- data.frame(
  Aspek = names(skor_aspek_label),
  ClusteringCoefficient = round(clustering, 3)
)
write.csv(clustering_df,
          file.path(CONFIG_TABLES_DIR, "26_Network_Clustering.csv"),
          row.names = FALSE)
log_message("Clustering table saved: 26_Network_Clustering.csv", level = "INFO")

# ===== NETWORK STABILITY (OPTIONAL) =====
log_message("Checking network stability configuration", level = "INFO")

# Use configuration parameter
run_bootstrap <- CONFIG_NETWORK_RUN_BOOTSTRAP

if(run_bootstrap) {
  set.seed(CONFIG_RANDOM_SEED)
  sample_idx <- sample(1:nrow(skor_aspek_label), min(1000, nrow(skor_aspek_label)))
  data_boot <- skor_aspek_label[sample_idx, ]

  log_message("Running bootstrap stability analysis", level = "INFO")

  boot_result <- tryCatch({
    bootnet(data_boot,
            nBoots = CONFIG_NETWORK_BOOTSTRAP_ITER,
            default = "cor",  # Use simpler method
            type = "nonparametric",
            nCores = 1)
  }, error = function(e) {
    log_message(sprintf("Bootstrap failed: %s", e$message), level = "ERROR")
    return(NULL)
  })

  if(!is.null(boot_result)) {
    # Plot stability
    save_plot(
      filename = "Network_Stability.png",
      plot_function = function() {
        plot(boot_result, labels = FALSE, order = "sample") +
          ggtitle("Network Stability (Bootstrap)")
      },
      width = CONFIG_PLOT_WIDTH_MEDIUM,
      height = CONFIG_PLOT_HEIGHT_SMALL,
      res = CONFIG_PLOT_RESOLUTION
    )

    saveRDS(boot_result, file.path(CONFIG_MODELS_DIR, "Network_Bootstrap.rds"))
    log_message("Bootstrap completed successfully", level = "INFO")
  }
} else {
  log_message("Bootstrap skipped (CONFIG_NETWORK_RUN_BOOTSTRAP = FALSE)", level = "INFO")
}

# ===== EDGE WEIGHTS =====
edge_weights <- tryCatch({
  network$graph
}, error = function(e) {
  cor_matrix
})

if(!is.null(edge_weights) && is.matrix(edge_weights)) {
  edge_df <- data.frame(
    From = rep(rownames(edge_weights), ncol(edge_weights)),
    To = rep(colnames(edge_weights), each = nrow(edge_weights)),
    Weight = as.vector(edge_weights)
  )
  edge_df <- edge_df[edge_df$Weight != 0 & edge_df$From != edge_df$To, ]
  edge_df <- edge_df[order(abs(edge_df$Weight), decreasing = TRUE), ]

  write.csv(edge_df,
            file.path(CONFIG_TABLES_DIR, "27_Network_EdgeWeights.csv"),
            row.names = FALSE)
  log_message("Edge weights table saved: 27_Network_EdgeWeights.csv", level = "INFO")
}

# ===== COMMUNITY DETECTION =====
log_message("Performing community detection", level = "INFO")

library(igraph)

# Get adjacency matrix
adj_matrix <- abs(edge_weights)

# Remove diagonal
diag(adj_matrix) <- 0

# Create igraph object
g <- graph_from_adjacency_matrix(adj_matrix,
                                 mode = "undirected",
                                 weighted = TRUE,
                                 diag = FALSE)

# Community detection
communities <- tryCatch({
  cluster_walktrap(g)
}, error = function(e) {
  cat("Walktrap failed, trying Louvain...\n")
  tryCatch({
    cluster_louvain(g)
  }, error = function(e2) {
    cat("Community detection failed, using simple grouping\n")
    # Fallback: assign all to one community
    list(membership = rep(1, ncol(adj_matrix)))
  })
})

community_df <- data.frame(
  Aspek = names(skor_aspek_label),
  Community = communities$membership
)
write.csv(community_df,
          file.path(CONFIG_TABLES_DIR, "28_Network_Communities.csv"),
          row.names = FALSE)
log_message("Communities table saved: 28_Network_Communities.csv", level = "INFO")

# Plot dengan community colors
save_plot(
  filename = "Network_Communities.png",
  plot_function = function() {
    tryCatch({
      plot(network,
           layout = "spring",
           groups = communities$membership,
           title = "Network dengan Community Detection",
           labels = names(skor_aspek_label),
           label.cex = 1.2,
           vsize = 8)
    }, error = function(e) {
      # Fallback: plot dengan qgraph
      qgraph(adj_matrix,
             layout = "spring",
             groups = communities$membership,
             title = "Network dengan Community Detection",
             labels = names(skor_aspek_label),
             label.cex = 1.2,
             vsize = 8,
             minimum = CONFIG_NETWORK_THRESHOLD_LOW)
    })
  },
  width = CONFIG_PLOT_WIDTH_XLARGE,
  height = CONFIG_PLOT_HEIGHT_XLARGE,
  res = CONFIG_PLOT_RESOLUTION
)

log_message("Community plot saved: Network_Communities.png", level = "INFO")

# ===== SUMMARY =====
log_message("=== NETWORK ANALYSIS COMPLETED ===", level = "INFO")
log_message(sprintf("Network stability analysis: %s",
                    ifelse(run_bootstrap, "completed", "skipped")),
            level = "INFO")
log_message("Tables saved: 25-28 (Centrality, Clustering, EdgeWeights, Communities)",
            level = "INFO")
log_message("Plots saved: Network_GGM, Network_Centrality, Network_Communities",
            level = "INFO")
