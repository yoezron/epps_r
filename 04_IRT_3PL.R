# ============================================================================
# SCRIPT 04: ANALISIS IRT 3-PARAMETER LOGISTIC MODEL (3PL)
# ============================================================================

load("output/data_processed.RData")

cat("\n=== ANALISIS IRT 3PL PER ASPEK ===\n")

hasil_3pl <- data.frame(
  Aspek = character(),
  Jumlah_Item = integer(),
  LogLikelihood = numeric(),
  AIC = numeric(),
  BIC = numeric(),
  stringsAsFactors = FALSE
)

parameter_3pl <- list()

for(aspek in aspek_epps) {
  cat("\nMemproses aspek:", aspek_labels[aspek], "\n")
  
  item_cols <- which(trait_names == aspek)
  if(length(item_cols) < 3) {
    cat("  Item terlalu sedikit, dilewati.\n")
    next
  }
  
  data_aspek <- data_items[, item_cols]
  data_aspek <- data_aspek[complete.cases(data_aspek), ]
  
  # Fit model 3PL
  model_3pl <- tryCatch({
    tpm(data_aspek, type = "latent.trait", max.guessing = 0.25)
  }, error = function(e) {
    cat("  Error fitting model:", e$message, "\n")
    return(NULL)
  })
  
  if(!is.null(model_3pl)) {
    params <- coef(model_3pl)
    
    param_df <- data.frame(
      Aspek = aspek_labels[aspek],
      Item = rownames(params),
      Difficulty = round(params[, "Dffclt"], 3),
      Discrimination = round(params[, "Dscrmn"], 3),
      Guessing = round(params[, "Gussng"], 3)
    )
    parameter_3pl[[aspek]] <- param_df
    
    hasil_3pl <- rbind(hasil_3pl, data.frame(
      Aspek = aspek_labels[aspek],
      Jumlah_Item = length(item_cols),
      LogLikelihood = round(logLik(model_3pl), 2),
      AIC = round(AIC(model_3pl), 2),
      BIC = round(BIC(model_3pl), 2)
    ))
    
    # Plot ICC
    png(paste0("output/plots/3PL_ICC_", aspek, ".png"), 
        width = 2400, height = 1800, res = 300)
    plot(model_3pl, type = "ICC",
         main = paste("3PL Item Characteristic Curves -", aspek_labels[aspek]),
         xlab = "Tingkat Trait (Theta)",
         ylab = "Probabilitas Menjawab Benar")
    dev.off()
    
    # Plot IIC
    png(paste0("output/plots/3PL_IIC_", aspek, ".png"), 
        width = 2400, height = 1800, res = 300)
    plot(model_3pl, type = "IIC",
         main = paste("3PL Item Information Curves -", aspek_labels[aspek]),
         xlab = "Tingkat Trait (Theta)",
         ylab = "Informasi Item")
    dev.off()
    
    saveRDS(model_3pl, paste0("output/models/3PL_", aspek, ".rds"))
  }
}

all_params_3pl <- do.call(rbind, parameter_3pl)
write.csv(all_params_3pl, "output/tables/07_Parameter_3PL.csv", row.names = FALSE)
write.csv(hasil_3pl, "output/tables/08_FitStatistics_3PL.csv", row.names = FALSE)

cat("\n=== ANALISIS 3PL SELESAI ===\n")
cat("Total aspek dianalisis:", nrow(hasil_3pl), "\n")
