# ============================================================================
# SCRIPT 07: GRADED RESPONSE MODEL (GRM)
# Untuk analisis polytomous pada skor agregat per aspek
# ============================================================================

load("output/data_processed.RData")

cat("\n=== ANALISIS GRADED RESPONSE MODEL ===\n")

# CATATAN: GRM unidimensional tidak cocok untuk 15 traits yang independen
# Alternative: GRM per trait untuk melihat fungsi kategori response

# Sampling
set.seed(2025)
sample_idx <- sample(1:nrow(skor_aspek), min(2000, nrow(skor_aspek)))
data_grm <- skor_aspek[sample_idx, ]

cat("Sample size:", nrow(data_grm), "\n")
cat("Approach: GRM per trait (bukan unidimensional)\n\n")

# ===== FIT GRM PER TRAIT =====
cat("--- Fitting GRM per Trait ---\n")

grm_results <- list()
grm_params <- list()

for(trait in aspek_epps) {
  cat("\nProcessing:", aspek_labels[trait], "...")

  trait_data <- data.frame(score = data_grm[[trait]])

  # Check variability
  if(length(unique(trait_data$score)) < 3) {
    cat(" Skipped (insufficient categories)\n")
    next
  }

  # Fit GRM
  model_grm <- tryCatch({
    mirt(trait_data, model = 1, itemtype = "graded",
         verbose = FALSE, technical = list(NCYCLES = 500))
  }, error = function(e) {
    cat(" Error:", e$message, "\n")
    return(NULL)
  })

  if(!is.null(model_grm)) {
    # Extract parameters
    params <- coef(model_grm, simplify = TRUE)$items

    grm_params[[trait]] <- data.frame(
      Trait = aspek_labels[trait],
      Discrimination = round(params[1, 1], 3),
      Difficulty_Mean = round(mean(params[1, -1]), 3),
      Difficulty_Range = paste0("[",
                                round(min(params[1, -1]), 2),
                                ", ",
                                round(max(params[1, -1]), 2),
                                "]")
    )

    # Model fit info
    grm_results[[trait]] <- data.frame(
      Trait = aspek_labels[trait],
      LogLikelihood = round(logLik(model_grm), 2),
      AIC = round(AIC(model_grm), 2),
      BIC = round(BIC(model_grm), 2),
      N_Categories = length(unique(trait_data$score))
    )

    # Save model
    saveRDS(model_grm, paste0("output/models/GRM_", trait, ".rds"))

    # Plot Item Response Category Characteristic Curves
    png(paste0("output/plots/GRM_CategoryCurves_", trait, ".png"),
        width = 2000, height = 1500, res = 300)
    tryCatch({
      plot(model_grm, type = "trace", which.items = 1,
           main = paste("Category Response Curves -", aspek_labels[trait]),
           theta_lim = c(-4, 4))
    }, error = function(e) {
      plot.new()
      text(0.5, 0.5, "Plot unavailable", cex = 1.5)
    })
    dev.off()

    cat(" Done\n")
  }
}

# Combine results
if(length(grm_results) > 0) {
  grm_fit_df <- do.call(rbind, grm_results)
  write.csv(grm_fit_df, "output/tables/20_GRM_FitStatistics.csv", row.names = FALSE)
}

if(length(grm_params) > 0) {
  grm_params_df <- do.call(rbind, grm_params)
  write.csv(grm_params_df, "output/tables/21_GRM_Parameters.csv", row.names = FALSE)
}

# ===== SUMMARY PLOT: DISCRIMINATION COMPARISON =====
if(length(grm_params) > 0) {
  cat("\n--- Creating Summary Plots ---\n")

  # Plot discrimination comparison
  grm_params_df$Trait <- factor(grm_params_df$Trait,
                                levels = grm_params_df$Trait[order(grm_params_df$Discrimination)])

  png("output/plots/GRM_Discrimination_Comparison.png",
      width = 2400, height = 2000, res = 300)
  par(mar = c(5, 10, 4, 2))
  barplot(grm_params_df$Discrimination,
          names.arg = grm_params_df$Trait,
          horiz = TRUE,
          las = 1,
          col = "steelblue",
          xlab = "Discrimination Parameter",
          main = "GRM Discrimination by Trait")
  abline(v = 1, col = "red", lty = 2, lwd = 2)
  text(1.5, par("usr")[4] * 0.9, "Reference: a=1", col = "red")
  dev.off()
}

cat("\n=== GRADED RESPONSE MODEL SELESAI ===\n")
cat("GRM fit untuk", length(grm_results), "traits\n")
if(length(grm_results) > 0) {
  cat("Rata-rata discrimination:",
      round(mean(grm_params_df$Discrimination, na.rm = TRUE), 3), "\n")
}
