# ============================================================================
# SCRIPT 08: NETWORK ANALYSIS ASPEK EPPS
# ============================================================================

load("output/data_processed.RData")

cat("\n=== NETWORK ANALYSIS ANTAR ASPEK ===\n")

# Rename columns untuk visualisasi
skor_aspek_label <- skor_aspek
names(skor_aspek_label) <- aspek_labels[aspek_epps]

# ===== GAUSSIAN GRAPHICAL MODEL (GGM) =====
cat("\n--- Estimasi Network (EBICglasso) ---\n")

# Check correlation matrix
cor_matrix <- cor(skor_aspek_label, use = "pairwise.complete.obs")

# Check if positive definite
is_pd <- tryCatch({
  chol(cor_matrix)
  TRUE
}, error = function(e) FALSE)

if(!is_pd) {
  cat("Warning: Correlation matrix not positive definite (common in forced-choice data)\n")
  cat("Applying regularization...\n")

  # Apply regularization to make it positive definite
  eigenvalues <- eigen(cor_matrix)$values
  min_eigen <- min(eigenvalues)

  if(min_eigen < 0) {
    # Add small constant to diagonal
    regularization <- abs(min_eigen) + 0.01
    diag(cor_matrix) <- diag(cor_matrix) + regularization
    cat("Regularization applied: +", round(regularization, 4), "to diagonal\n")
  }
}

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
png("output/plots/Network_GGM.png", width = 2800, height = 2800, res = 300)
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
         minimum = 0.1,
         cut = 0.3)
})
dev.off()

# ===== CENTRALITY MEASURES =====
cat("\n--- Analisis Centrality ---\n")

centrality_measures <- tryCatch({
  centralityTable(network)
}, error = function(e) {
  cat("Standard centrality failed, computing from graph...\n")

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

write.csv(centrality_measures, "output/tables/25_Network_Centrality.csv", row.names = FALSE)

# Plot centrality
png("output/plots/Network_Centrality.png", width = 2400, height = 2000, res = 300)
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
dev.off()

# ===== CLUSTERING COEFFICIENT =====
cat("\n--- Clustering Coefficient ---\n")

clustering <- tryCatch({
  clustcoef_auto(network$graph)
}, error = function(e) {
  cat("Clustering from network failed, using correlation matrix...\n")
  # Simple clustering from correlation
  rep(NA, ncol(cor_matrix))
})

clustering_df <- data.frame(
  Aspek = names(skor_aspek_label),
  ClusteringCoefficient = round(clustering, 3)
)
write.csv(clustering_df, "output/tables/26_Network_Clustering.csv", row.names = FALSE)

# ===== NETWORK STABILITY (OPTIONAL) =====
cat("\n--- Stability Analysis (Bootstrap) ---\n")

# Note: Bootstrap can be very slow and may fail for forced-choice data
# Set run_bootstrap = FALSE to skip
run_bootstrap <- FALSE

if(run_bootstrap) {
  set.seed(2025)
  sample_idx <- sample(1:nrow(skor_aspek_label), min(1000, nrow(skor_aspek_label)))
  data_boot <- skor_aspek_label[sample_idx, ]

  boot_result <- tryCatch({
    bootnet(data_boot,
            nBoots = 500,  # Reduced from 1000
            default = "cor",  # Use simpler method
            type = "nonparametric",
            nCores = 1)
  }, error = function(e) {
    cat("Bootstrap failed:", e$message, "\n")
    cat("Skipping stability analysis (common for forced-choice data)\n")
    return(NULL)
  })

  if(!is.null(boot_result)) {
    # Plot stability
    png("output/plots/Network_Stability.png", width = 2400, height = 2000, res = 300)
    plot(boot_result, labels = FALSE, order = "sample") +
      ggtitle("Network Stability (Bootstrap)")
    dev.off()

    saveRDS(boot_result, "output/models/Network_Bootstrap.rds")
    cat("Bootstrap completed successfully\n")
  }
} else {
  cat("Bootstrap skipped (set run_bootstrap = TRUE to enable)\n")
  cat("Note: Bootstrap is optional and often fails for forced-choice data\n")
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

  write.csv(edge_df, "output/tables/27_Network_EdgeWeights.csv", row.names = FALSE)
}

# ===== COMMUNITY DETECTION =====
cat("\n--- Community Detection ---\n")

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
write.csv(community_df, "output/tables/28_Network_Communities.csv", row.names = FALSE)

# Plot dengan community colors
png("output/plots/Network_Communities.png", width = 2800, height = 2800, res = 300)
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
         minimum = 0.1)
})
dev.off()

cat("\n=== NETWORK ANALYSIS SELESAI ===\n")
cat("Network stability analysis:", ifelse(run_bootstrap, "completed", "skipped"), "\n")
cat("Centrality measures dan communities tersimpan\n")
