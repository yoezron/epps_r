# ============================================================================
# SCRIPT 05: MULTIDIMENSIONAL IRT (MIRT)
# ============================================================================

load("output/data_processed.RData")

cat("\n=== ANALISIS MULTIDIMENSIONAL IRT ===\n")

# Sampling untuk efisiensi (gunakan 3000 responden)
set.seed(2025)
sample_idx <- sample(1:nrow(data_items), min(3000, nrow(data_items)))
data_sample <- data_items[sample_idx, ]

cat("Jumlah responden dalam sample:", nrow(data_sample), "\n")

# ===== MIRT MODEL: 15 DIMENSI (SESUAI 15 ASPEK) =====
cat("\n--- Fitting MIRT 15 Dimensi ---\n")

# Buat spesifikasi model
mirt_spec <- paste0("F", 1:15, " = ", 
                    sapply(aspek_epps, function(a) {
                      items <- which(trait_names == a)
                      paste(items, collapse = ",")
                    }))
mirt_spec <- paste(mirt_spec, collapse = "\n")

# Fit model
model_mirt <- tryCatch({
  mirt(data_sample, model = mirt_spec, itemtype = "2PL", 
       verbose = FALSE, technical = list(NCYCLES = 2000))
}, error = function(e) {
  cat("Error fitting MIRT:", e$message, "\n")
  return(NULL)
})

if(!is.null(model_mirt)) {
  # Extract fit indices dengan error handling
  fit_mirt <- tryCatch({
    M2(model_mirt, type = "C2")
  }, error = function(e) {
    cat("Warning: M2 calculation failed, using alternative fit indices\n")
    cat("Error:", e$message, "\n")
    # Return minimal structure jika M2 gagal
    list(
      M2 = NA,
      df = NA,
      p = NA,
      RMSEA = NA,
      RMSEA_5 = NA,
      RMSEA_95 = NA,
      SRMSR = NA,
      TLI = NA,
      CFI = NA
    )
  })

  fit_stats <- data.frame(
    Index = c("M2", "df", "p-value", "RMSEA", "RMSEA_5", "RMSEA_95",
              "SRMSR", "TLI", "CFI"),
    Value = c(
      round(fit_mirt$M2, 2),
      fit_mirt$df,
      round(fit_mirt$p, 4),
      round(fit_mirt$RMSEA, 4),
      round(fit_mirt$RMSEA_5, 4),
      round(fit_mirt$RMSEA_95, 4),
      round(fit_mirt$SRMSR, 4),
      round(fit_mirt$TLI, 4),
      round(fit_mirt$CFI, 4)
    )
  )
  
  write.csv(fit_stats, "output/tables/09_MIRT_FitIndices.csv", row.names = FALSE)
  
  # Extract parameter
  params_mirt <- coef(model_mirt, simplify = TRUE)
  items_params <- params_mirt$items
  
  write.csv(items_params, "output/tables/10_MIRT_ItemParameters.csv", row.names = TRUE)
  
  # Factor correlations
  cov_matrix <- params_mirt$cov
  cor_factors <- cov2cor(cov_matrix)
  
  colnames(cor_factors) <- rownames(cor_factors) <- aspek_labels[aspek_epps]
  write.csv(cor_factors, "output/tables/11_MIRT_FactorCorrelations.csv", row.names = TRUE)
  
  # Plot factor correlations
  png("output/plots/MIRT_FactorCorrelations.png", width = 2400, height = 2400, res = 300)
  corrplot(cor_factors, method = "color", type = "upper",
           tl.col = "black", tl.srt = 45, tl.cex = 0.8,
           addCoef.col = "black", number.cex = 0.6,
           col = colorRampPalette(c("#D73027", "white", "#1A9850"))(200),
           title = "Korelasi Antar Faktor (MIRT)",
           mar = c(0,0,2,0))
  dev.off()
  
  # Estimate factor scores
  fscores <- fscores(model_mirt, method = "EAP")
  colnames(fscores) <- aspek_labels[aspek_epps]
  
  write.csv(fscores, "output/tables/12_MIRT_FactorScores_Sample.csv", row.names = FALSE)
  
  # Simpan model
  saveRDS(model_mirt, "output/models/MIRT_15dim.rds")
  
  # Informasi model
  info_model <- data.frame(
    Metric = c("LogLikelihood", "AIC", "BIC", "Sample Size", "Number of Items"),
    Value = c(
      round(logLik(model_mirt), 2),
      round(AIC(model_mirt), 2),
      round(BIC(model_mirt), 2),
      nrow(data_sample),
      ncol(data_sample)
    )
  )
  
  write.csv(info_model, "output/tables/13_MIRT_ModelInfo.csv", row.names = FALSE)
  
  cat("\n=== MIRT ANALYSIS SELESAI ===\n")
  cat("Fit indices tersimpan\n")
  cat("Parameter tersimpan\n")
  cat("Factor scores tersimpan\n")
}
