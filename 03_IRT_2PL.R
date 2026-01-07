# ============================================================================
# SCRIPT 03: ANALISIS IRT 2-PARAMETER LOGISTIC MODEL (2PL)
# ============================================================================

load("output/data_processed.RData")

cat("\n=== ANALISIS IRT 2PL PER ASPEK ===\n")

# Data frame untuk menyimpan hasil
hasil_2pl <- data.frame(
  Aspek = character(),
  Jumlah_Item = integer(),
  LogLikelihood = numeric(),
  AIC = numeric(),
  BIC = numeric(),
  stringsAsFactors = FALSE
)

parameter_2pl <- list()

# Loop untuk setiap aspek
for(aspek in aspek_epps) {
  cat("\nMemproses aspek:", aspek_labels[aspek], "\n")
  
  item_cols <- which(trait_names == aspek)
  if(length(item_cols) < 3) {
    cat("  Item terlalu sedikit, dilewati.\n")
    next
  }
  
  data_aspek <- data_items[, item_cols]
  data_aspek <- data_aspek[complete.cases(data_aspek), ]
  
  # Fit model 2PL
  model_2pl <- tryCatch({
    ltm(data_aspek ~ z1)
  }, error = function(e) {
    cat("  Error fitting model:", e$message, "\n")
    return(NULL)
  })
  
  if(!is.null(model_2pl)) {
    # Ekstrak parameter
    params <- coef(model_2pl)
    
    # Simpan parameter
    param_df <- data.frame(
      Aspek = aspek_labels[aspek],
      Item = rownames(params),
      Difficulty = round(params[, "Dffclt"], 3),
      Discrimination = round(params[, "Dscrmn"], 3)
    )
    parameter_2pl[[aspek]] <- param_df
    
    # Fit statistics
    hasil_2pl <- rbind(hasil_2pl, data.frame(
      Aspek = aspek_labels[aspek],
      Jumlah_Item = length(item_cols),
      LogLikelihood = round(logLik(model_2pl), 2),
      AIC = round(AIC(model_2pl), 2),
      BIC = round(BIC(model_2pl), 2)
    ))
    
    # Plot ICC
    png(paste0("output/plots/2PL_ICC_", aspek, ".png"), 
        width = 2400, height = 1800, res = 300)
    plot(model_2pl, type = "ICC", 
         main = paste("Item Characteristic Curves -", aspek_labels[aspek]),
         xlab = "Tingkat Trait (Theta)",
         ylab = "Probabilitas Menjawab Benar")
    dev.off()
    
    # Plot IIC
    png(paste0("output/plots/2PL_IIC_", aspek, ".png"), 
        width = 2400, height = 1800, res = 300)
    plot(model_2pl, type = "IIC",
         main = paste("Item Information Curves -", aspek_labels[aspek]),
         xlab = "Tingkat Trait (Theta)",
         ylab = "Informasi Item")
    dev.off()
    
    # Simpan model
    saveRDS(model_2pl, paste0("output/models/2PL_", aspek, ".rds"))
  }
}

# Gabungkan semua parameter
all_params_2pl <- do.call(rbind, parameter_2pl)
write.csv(all_params_2pl, "output/tables/05_Parameter_2PL.csv", row.names = FALSE)

# Simpan fit statistics
write.csv(hasil_2pl, "output/tables/06_FitStatistics_2PL.csv", row.names = FALSE)

cat("\n=== ANALISIS 2PL SELESAI ===\n")
cat("Total aspek dianalisis:", nrow(hasil_2pl), "\n")
cat("Output tersimpan di output/tables/ dan output/plots/\n")
