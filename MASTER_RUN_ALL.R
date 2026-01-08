# ============================================================================
# MASTER SCRIPT: ANALISIS PSIKOMETRIK KOMPREHENSIF EPPS
# PT. Data Riset Nusantara untuk PT. Nirmala Satya Development
# ============================================================================
#
# INSTRUKSI:
# 1. Set working directory ke folder EPPS-Analysis
# 2. Pastikan file epps_raw.csv ada di folder tersebut
# 3. Jalankan script ini: source("MASTER_RUN_ALL.R")
#
# OPSI KONFIGURASI:
# - SKIP_TIRT: Set TRUE untuk skip Thurstonian IRT (direkomendasikan)
# - SKIP_NETWORK_BOOTSTRAP: Set TRUE untuk skip bootstrap (lebih cepat)
# - INSTALL_MISSING: Set TRUE untuk auto-install missing packages
#
# ============================================================================

# ============================================================================
# KONFIGURASI EKSEKUSI
# ============================================================================

# Opsi untuk skip script yang computationally intensive
SKIP_TIRT <- TRUE  # Thurstonian IRT (sangat berat, sering gagal)
SKIP_NETWORK_BOOTSTRAP <- TRUE  # Bootstrap untuk network stability

# Auto-install missing packages
INSTALL_MISSING <- TRUE

# Logging
LOG_TO_FILE <- TRUE
LOG_FILE <- "MASTER_RUN_LOG.txt"

# ============================================================================
# SETUP AWAL
# ============================================================================

cat("\n")
cat("==============================================================================\n")
cat("        ANALISIS PSIKOMETRIK KOMPREHENSIF EPPS - MASTER SCRIPT\n")
cat("        PT. Nirmala Satya Development\n")
cat("==============================================================================\n")
cat("\n")
cat("Waktu mulai:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# Inisialisasi log
if(LOG_TO_FILE) {
  sink(LOG_FILE, split = TRUE)
  on.exit(sink())
}

# Cek working directory
current_wd <- getwd()
cat("Working directory:", current_wd, "\n")

# ============================================================================
# VALIDASI PRE-REQUISITES
# ============================================================================

cat("\n")
cat("------------------------------------------------------------------------------\n")
cat("VALIDASI PRE-REQUISITES\n")
cat("------------------------------------------------------------------------------\n\n")

# 1. Cek file data
cat("[1/5] Checking data file...\n")
if(!file.exists("epps_raw.csv")) {
  stop("\nERROR: File 'epps_raw.csv' tidak ditemukan!\n",
       "Pastikan file ada di folder: ", current_wd, "\n")
}
cat("      ✓ File data ditemukan: epps_raw.csv\n")

# 2. Cek script files
cat("[2/5] Checking script files...\n")
required_scripts <- c(
  "00_Config.R", "00_Utilities.R", "01_Setup_Data.R",
  "02_Deskriptif_CTT.R", "03_IRT_2PL.R", "04_IRT_3PL.R",
  "05_MIRT.R", "06_TIRT.R", "07_GRM.R",
  "08_Network_Analysis.R", "08B_Advanced_Network.R",
  "08C_Comparative_Network.R", "08D_Interactive_Network.R",
  "09_Norma_Scoring.R", "10_Visualisasi.R", "11_Laporan.R"
)

missing_scripts <- required_scripts[!file.exists(required_scripts)]
if(length(missing_scripts) > 0) {
  stop("\nERROR: Script berikut tidak ditemukan:\n",
       paste("  -", missing_scripts, collapse = "\n"), "\n")
}
cat("      ✓ Semua", length(required_scripts), "script ditemukan\n")

# 3. Cek dan install packages
cat("[3/5] Checking required packages...\n")
required_packages <- c(
  "ltm", "mirt", "psych", "thurstonianIRT",
  "ggplot2", "plotly", "corrplot", "lavaan",
  "qgraph", "bootnet", "dplyr", "tidyr",
  "gridExtra", "RColorBrewer", "reshape2",
  "car", "GPArotation", "fmsb", "igraph",
  "networkD3", "visNetwork", "htmlwidgets", "Matrix"
)

missing_packages <- required_packages[!sapply(required_packages,
                                               requireNamespace,
                                               quietly = TRUE)]

if(length(missing_packages) > 0) {
  cat("      Missing packages:", length(missing_packages), "\n")
  cat("      Packages:", paste(missing_packages, collapse = ", "), "\n")

  if(INSTALL_MISSING) {
    cat("      Installing missing packages...\n")
    for(pkg in missing_packages) {
      cat("        Installing:", pkg, "...")
      tryCatch({
        install.packages(pkg, dependencies = TRUE,
                        repos = "https://cloud.r-project.org/",
                        quiet = TRUE)
        cat(" ✓\n")
      }, error = function(e) {
        cat(" ✗\n")
        cat("        Warning: Failed to install", pkg, "\n")
      })
    }
  } else {
    warning("Missing packages detected but auto-install disabled.\n",
            "Set INSTALL_MISSING <- TRUE to auto-install.\n")
  }
} else {
  cat("      ✓ All required packages available\n")
}

# 4. Load configuration
cat("[4/5] Loading configuration...\n")
tryCatch({
  source("00_Config.R", echo = FALSE)
  cat("      ✓ Configuration loaded\n")
}, error = function(e) {
  stop("\nERROR: Failed to load configuration\n", e$message, "\n")
})

# 5. Load utilities
cat("[5/5] Loading utility functions...\n")
tryCatch({
  source("00_Utilities.R", echo = FALSE)
  cat("      ✓ Utility functions loaded\n")
}, error = function(e) {
  stop("\nERROR: Failed to load utilities\n", e$message, "\n")
})

cat("\n✓ All pre-requisites validated\n")

# ============================================================================
# FUNGSI HELPER
# ============================================================================

# Fungsi untuk menjalankan script dengan enhanced error handling
run_script <- function(script_name, description, optional = FALSE, skip = FALSE) {
  cat("\n")
  cat("------------------------------------------------------------------------------\n")

  if(skip) {
    cat(">>> SKIPPED:", description, "\n")
    cat("    Script:", script_name, "(manually skipped)\n")
    cat("------------------------------------------------------------------------------\n")
    return(list(success = NA, duration = 0, skipped = TRUE))
  }

  cat(">>> RUNNING:", description, "\n")
  cat("    Script:", script_name, "\n")
  cat("    Time:", format(Sys.time(), "%H:%M:%S"), "\n")
  cat("------------------------------------------------------------------------------\n")

  start_time <- Sys.time()

  result <- tryCatch({
    # Suppress warnings selama source untuk output yang lebih bersih
    # tapi tangkap warning untuk logging
    warnings_list <- character()
    withCallingHandlers(
      source(script_name, echo = FALSE),
      warning = function(w) {
        warnings_list <<- c(warnings_list, w$message)
        invokeRestart("muffleWarning")
      }
    )

    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)

    cat("\n✓ SUCCESS:", description)
    cat(" (", duration, " sec)\n")

    if(length(warnings_list) > 0) {
      cat("  Note:", length(warnings_list), "warning(s) generated\n")
    }

    list(success = TRUE, duration = as.numeric(duration), skipped = FALSE,
         warnings = warnings_list)

  }, error = function(e) {
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)

    if(optional) {
      cat("\n⚠ WARNING:", description, "- FAILED (optional)\n")
      cat("  Error:", e$message, "\n")
      cat("  Duration:", duration, "sec\n")
      cat("  Note: This is an optional script, continuing...\n")

      list(success = FALSE, duration = as.numeric(duration), skipped = FALSE,
           optional = TRUE, error = e$message)
    } else {
      cat("\n✗ ERROR:", description, "- FAILED\n")
      cat("  Error:", e$message, "\n")
      cat("  Duration:", duration, "sec\n")

      list(success = FALSE, duration = as.numeric(duration), skipped = FALSE,
           error = e$message)
    }
  })

  return(result)
}

# ============================================================================
# JALANKAN ANALISIS SECARA BERTAHAP
# ============================================================================

cat("\n")
cat("==============================================================================\n")
cat("MEMULAI ANALISIS PSIKOMETRIK\n")
cat("==============================================================================\n")

start_total <- Sys.time()
results <- list()

# ===== PHASE 1: DATA SETUP (CRITICAL) =====
cat("\n")
cat("========== PHASE 1: DATA PREPARATION ==========\n")

results$setup <- run_script(
  "01_Setup_Data.R",
  "Setup dan Persiapan Data",
  optional = FALSE
)

if(!isTRUE(results$setup$success)) {
  stop("\n\nFATAL ERROR: Data setup gagal. Analisis tidak dapat dilanjutkan.\n",
       "Perbaiki error di atas sebelum mencoba lagi.\n")
}

# ===== PHASE 2: DESCRIPTIVE STATISTICS =====
cat("\n")
cat("========== PHASE 2: DESCRIPTIVE & CLASSICAL TEST THEORY ==========\n")

results$deskriptif <- run_script(
  "02_Deskriptif_CTT.R",
  "Analisis Deskriptif dan Reliabilitas",
  optional = FALSE
)

# ===== PHASE 3: IRT MODELS =====
cat("\n")
cat("========== PHASE 3: ITEM RESPONSE THEORY MODELS ==========\n")

results$irt_2pl <- run_script(
  "03_IRT_2PL.R",
  "IRT 2-Parameter Logistic Model",
  optional = FALSE
)

results$irt_3pl <- run_script(
  "04_IRT_3PL.R",
  "IRT 3-Parameter Logistic Model",
  optional = TRUE
)

results$mirt <- run_script(
  "05_MIRT.R",
  "Multidimensional IRT (MIRT)",
  optional = TRUE
)

# TIRT - computationally intensive, optional
if(SKIP_TIRT) {
  cat("\n")
  cat("------------------------------------------------------------------------------\n")
  cat(">>> SKIPPED: Thurstonian IRT\n")
  cat("    Reason: SKIP_TIRT = TRUE (computationally intensive)\n")
  cat("    Note: Set SKIP_TIRT <- FALSE to enable (not recommended)\n")
  cat("------------------------------------------------------------------------------\n")
  results$tirt <- list(success = NA, duration = 0, skipped = TRUE)
} else {
  results$tirt <- run_script(
    "06_TIRT.R",
    "Thurstonian IRT (Forced-Choice) - EXPERIMENTAL",
    optional = TRUE
  )
}

results$grm <- run_script(
  "07_GRM.R",
  "Graded Response Model",
  optional = TRUE
)

# ===== PHASE 4: NETWORK ANALYSIS =====
cat("\n")
cat("========== PHASE 4: NETWORK PSYCHOMETRICS ==========\n")

# Set bootstrap config jika user skip
if(SKIP_NETWORK_BOOTSTRAP) {
  assign("CONFIG_NETWORK_RUN_BOOTSTRAP", FALSE, envir = .GlobalEnv)
  cat("\nNote: Network bootstrap disabled (CONFIG_NETWORK_RUN_BOOTSTRAP = FALSE)\n")
  cat("      Set SKIP_NETWORK_BOOTSTRAP <- FALSE to enable\n")
}

results$network <- run_script(
  "08_Network_Analysis.R",
  "Network Analysis (Core)",
  optional = FALSE
)

results$network_advanced <- run_script(
  "08B_Advanced_Network.R",
  "Advanced Network Analysis",
  optional = TRUE
)

results$network_comparative <- run_script(
  "08C_Comparative_Network.R",
  "Comparative & Predictability Network",
  optional = TRUE
)

results$network_interactive <- run_script(
  "08D_Interactive_Network.R",
  "Interactive Network Visualizations",
  optional = TRUE
)

# ===== PHASE 5: NORMS AND SCORING =====
cat("\n")
cat("========== PHASE 5: NORMS & SCORING SYSTEM ==========\n")

results$norma <- run_script(
  "09_Norma_Scoring.R",
  "Pembuatan Norma dan Sistem Penyekoran",
  optional = FALSE
)

# ===== PHASE 6: COMPREHENSIVE VISUALIZATIONS =====
cat("\n")
cat("========== PHASE 6: COMPREHENSIVE VISUALIZATIONS ==========\n")

results$viz <- run_script(
  "10_Visualisasi.R",
  "Visualisasi Komprehensif",
  optional = TRUE
)

# ===== PHASE 7: FINAL REPORT =====
cat("\n")
cat("========== PHASE 7: REPORT GENERATION ==========\n")

results$laporan <- run_script(
  "11_Laporan.R",
  "Pembuatan Laporan Psikometrik Final",
  optional = FALSE
)

# ============================================================================
# SUMMARY & STATISTICS
# ============================================================================

end_total <- Sys.time()
total_duration <- round(difftime(end_total, start_total, units = "mins"), 2)

cat("\n")
cat("==============================================================================\n")
cat("                          EXECUTION SUMMARY\n")
cat("==============================================================================\n\n")

# Hitung statistik
success_results <- sapply(results, function(x) isTRUE(x$success))
failed_results <- sapply(results, function(x) isFALSE(x$success))
skipped_results <- sapply(results, function(x) isTRUE(x$skipped))

success_count <- sum(success_results, na.rm = TRUE)
failed_count <- sum(failed_results, na.rm = TRUE)
skipped_count <- sum(skipped_results, na.rm = TRUE)
total_count <- length(results)

cat("Total Scripts          :", total_count, "\n")
cat("  ✓ Success            :", success_count, "\n")
cat("  ✗ Failed             :", failed_count, "\n")
cat("  ⊘ Skipped            :", skipped_count, "\n")
cat("Total Execution Time   :", total_duration, "minutes\n\n")

# Detail per script
cat("Detailed Results:\n")
cat(strrep("-", 80), "\n")
cat(sprintf("%-40s %-15s %10s\n", "Script", "Status", "Duration"))
cat(strrep("-", 80), "\n")

for(i in 1:length(results)) {
  script_name <- names(results)[i]
  result <- results[[i]]

  if(isTRUE(result$skipped)) {
    status <- "⊘ SKIPPED"
    duration_str <- "-"
  } else if(isTRUE(result$success)) {
    status <- "✓ SUCCESS"
    duration_str <- sprintf("%.1f sec", result$duration)
  } else {
    if(isTRUE(result$optional)) {
      status <- "⚠ FAILED (opt)"
    } else {
      status <- "✗ FAILED"
    }
    duration_str <- sprintf("%.1f sec", result$duration)
  }

  cat(sprintf("%-40s %-15s %10s\n", script_name, status, duration_str))
}
cat(strrep("-", 80), "\n\n")

# Warnings summary
total_warnings <- sum(sapply(results, function(x) {
  if(!is.null(x$warnings)) length(x$warnings) else 0
}))

if(total_warnings > 0) {
  cat("⚠ Total Warnings Generated:", total_warnings, "\n")
  cat("  (Check individual script outputs for details)\n\n")
}

# ============================================================================
# OUTPUT FILES SUMMARY
# ============================================================================

cat("==============================================================================\n")
cat("                          OUTPUT FILES GENERATED\n")
cat("==============================================================================\n\n")

if(dir.exists("output")) {

  # Tables
  if(dir.exists("output/tables")) {
    tables <- list.files("output/tables", pattern = "\\.csv$")
    cat("📊 CSV Tables (output/tables/):\n")
    cat("   Total:", length(tables), "files\n")
    if(length(tables) > 0) {
      # Group by prefix
      cat("   Sample files:\n")
      for(t in head(tables, 5)) {
        cat("     -", t, "\n")
      }
      if(length(tables) > 5) {
        cat("     ... and", length(tables) - 5, "more\n")
      }
    }
    cat("\n")
  }

  # Plots
  if(dir.exists("output/plots")) {
    plots_png <- list.files("output/plots", pattern = "\\.png$")
    plots_html <- list.files("output/plots", pattern = "\\.html$")
    cat("📈 Visualizations (output/plots/):\n")
    cat("   PNG plots:", length(plots_png), "files\n")
    cat("   HTML interactive:", length(plots_html), "files\n")
    cat("   Total:", length(plots_png) + length(plots_html), "files\n\n")
  }

  # Models
  if(dir.exists("output/models")) {
    models <- list.files("output/models", pattern = "\\.rds$")
    cat("🔧 Saved Models (output/models/):\n")
    cat("   Total:", length(models), "files\n")
    if(length(models) > 0) {
      cat("   Sample files:\n")
      for(m in head(models, 5)) {
        cat("     -", m, "\n")
      }
      if(length(models) > 5) {
        cat("     ... and", length(models) - 5, "more\n")
      }
    }
    cat("\n")
  }

  # Reports
  if(dir.exists("output/reports")) {
    reports <- list.files("output/reports", pattern = "\\.(txt|html|pdf)$")
    cat("📄 Reports (output/reports/):\n")
    if(length(reports) > 0) {
      for(r in reports) {
        cat("   -", r, "\n")
      }
    } else {
      cat("   (None generated)\n")
    }
    cat("\n")
  }

  # Main report
  if(file.exists("output/LAPORAN_PSIKOMETRIK_EPPS.txt")) {
    cat("📋 Main Report:\n")
    cat("   ✓ output/LAPORAN_PSIKOMETRIK_EPPS.txt\n\n")
  }

} else {
  cat("⚠ Warning: output/ directory not found\n\n")
}

# ============================================================================
# NEXT STEPS
# ============================================================================

cat("==============================================================================\n")
cat("                          NEXT STEPS\n")
cat("==============================================================================\n\n")

if(failed_count > 0) {
  cat("⚠ ATTENTION: Some scripts failed\n\n")
  cat("Failed scripts:\n")
  for(i in 1:length(results)) {
    if(isFALSE(results[[i]]$success) && !isTRUE(results[[i]]$optional)) {
      cat("  ✗", names(results)[i], "\n")
      if(!is.null(results[[i]]$error)) {
        cat("    Error:", results[[i]]$error, "\n")
      }
    }
  }
  cat("\nRecommendation:\n")
  cat("1. Check the error messages above\n")
  cat("2. Fix any data or configuration issues\n")
  cat("3. Re-run specific scripts or MASTER_RUN_ALL.R\n\n")
} else {
  cat("✓ All critical scripts completed successfully!\n\n")

  cat("What you can do now:\n")
  cat("1. Review main report: output/LAPORAN_PSIKOMETRIK_EPPS.txt\n")
  cat("2. Explore visualizations in: output/plots/\n")
  cat("3. Check detailed tables in: output/tables/\n")
  cat("4. Launch interactive dashboard:\n")
  cat('   source("RUN_DASHBOARD.R")\n\n')
}

# ============================================================================
# USAGE GUIDE
# ============================================================================

cat("==============================================================================\n")
cat("                          USAGE GUIDE\n")
cat("==============================================================================\n\n")

cat("To run this master script again:\n")
cat('  source("MASTER_RUN_ALL.R")\n\n')

cat("To run individual scripts:\n")
cat('  load("output/data_processed.RData")\n')
cat('  source("03_IRT_2PL.R")  # Example\n\n')

cat("To launch dashboard:\n")
cat('  source("RUN_DASHBOARD.R")\n\n')

cat("Configuration options (edit at top of MASTER_RUN_ALL.R):\n")
cat("  SKIP_TIRT <- TRUE/FALSE          # Skip Thurstonian IRT\n")
cat("  SKIP_NETWORK_BOOTSTRAP <- TRUE/FALSE  # Skip bootstrap analysis\n")
cat("  INSTALL_MISSING <- TRUE/FALSE    # Auto-install packages\n\n")

# ============================================================================
# CLEANUP & EXIT
# ============================================================================

cat("==============================================================================\n")
cat("Waktu selesai:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")

if(LOG_TO_FILE) {
  cat("\nLog file saved:", LOG_FILE, "\n")
}

cat("==============================================================================\n\n")

# Return invisible summary untuk programmatic access
invisible(list(
  results = results,
  total_duration = total_duration,
  success_count = success_count,
  failed_count = failed_count,
  skipped_count = skipped_count
))
