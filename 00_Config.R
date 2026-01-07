# ================================================================================
# EPPS Analysis Configuration File
# ================================================================================
# This file centralizes all configuration parameters used throughout the analysis
# pipeline. Modify these values to customize the analysis without editing
# individual scripts.
#
# Created: 2026-01-07
# ================================================================================

# ================================================================================
# GENERAL SETTINGS
# ================================================================================

# Random seed for reproducibility
CONFIG_RANDOM_SEED <- 2025

# Data file name (should be in working directory)
CONFIG_DATA_FILE <- "epps_raw.csv"

# Data import settings
CONFIG_DATA_DELIMITER <- ";"
CONFIG_DATA_ENCODING <- "UTF-8-BOM"

# Output directories
CONFIG_OUTPUT_DIR <- "output"
CONFIG_PLOTS_DIR <- "output/plots"
CONFIG_TABLES_DIR <- "output/tables"
CONFIG_MODELS_DIR <- "output/models"


# ================================================================================
# ASPECT DEFINITIONS (15 EPPS Personality Traits)
# ================================================================================

# Aspect codes and labels
CONFIG_ASPECTS <- c(
  "Ach" = "Achievement",
  "Def" = "Deference",
  "Ord" = "Order",
  "Exh" = "Exhibition",
  "Aut" = "Autonomy",
  "Aff" = "Affiliation",
  "Int" = "Intraception",
  "Suc" = "Succorance",
  "Dom" = "Dominance",
  "Aba" = "Abasement",
  "Nur" = "Nurturance",
  "Chg" = "Change",
  "End" = "Endurance",
  "Het" = "Heterosexuality",
  "Agg" = "Aggression"
)

# Get aspect codes only
CONFIG_ASPECT_CODES <- names(CONFIG_ASPECTS)


# ================================================================================
# DEMOGRAPHIC COLUMN DETECTION
# ================================================================================

# Patterns for identifying demographic columns
CONFIG_DEMO_PATTERNS <- list(
  gender = c("gender", "jk", "jenis_kelamin", "sex"),
  education = c("education", "pendidikan", "educ"),
  age = c("age", "usia", "umur"),
  name = c("nama", "name"),
  id = c("id", "responden", "respondent")
)


# ================================================================================
# IRT ANALYSIS SETTINGS
# ================================================================================

# Minimum number of items per aspect for IRT analysis
CONFIG_IRT_MIN_ITEMS <- 3

# 3PL Model: Maximum guessing parameter
CONFIG_3PL_MAX_GUESSING <- 0.25

# MIRT Settings
CONFIG_MIRT_MAX_SAMPLE <- 3000  # Maximum sample size for computational efficiency
CONFIG_MIRT_NCYCLES <- 2000     # Number of EM cycles
CONFIG_MIRT_METHOD <- "EAP"     # Factor score estimation method

# TIRT (Thurstonian IRT) Settings
CONFIG_TIRT_MAX_SAMPLE <- 500   # Maximum sample size due to memory constraints
CONFIG_TIRT_SKIP <- TRUE         # Set to FALSE to enable TIRT (may cause memory issues)

# GRM (Graded Response Model) Settings
CONFIG_GRM_MAX_SAMPLE <- 2000   # Maximum sample size
CONFIG_GRM_MIN_CATEGORIES <- 3  # Minimum response categories required


# ================================================================================
# NETWORK ANALYSIS SETTINGS
# ================================================================================

# Correlation thresholds
CONFIG_NETWORK_THRESHOLD_LOW <- 0.15   # For qgraph visualization
CONFIG_NETWORK_THRESHOLD_HIGH <- 0.30  # For fallback correlation networks

# Eigenvalue threshold for matrix regularization
CONFIG_NETWORK_EIGEN_THRESHOLD <- 0.01

# Bootstrap settings
CONFIG_NETWORK_RUN_BOOTSTRAP <- FALSE  # Set TRUE to enable (computationally intensive)
CONFIG_NETWORK_BOOTSTRAP_ITER <- 100   # Bootstrap iterations for stability
CONFIG_NETWORK_BOOTSTRAP_EDGE <- 500   # Edge stability bootstrap iterations

# Network Comparison Test (NCT) settings
CONFIG_NCT_MIN_GROUP_SIZE <- 100       # Minimum observations per group
CONFIG_NCT_IT <- 100                   # NCT iterations

# Temporal network settings
CONFIG_NETWORK_TIME_WINDOWS <- 5       # Number of time windows for temporal analysis


# ================================================================================
# NORMA AND SCORING SETTINGS
# ================================================================================

# T-score parameters (standardized scores)
CONFIG_TSCORE_MEAN <- 50
CONFIG_TSCORE_SD <- 10

# T-score category boundaries
CONFIG_TSCORE_VERY_HIGH <- 70
CONFIG_TSCORE_HIGH <- 60
CONFIG_TSCORE_LOW <- 40
CONFIG_TSCORE_VERY_LOW <- 30

# Category labels
CONFIG_SCORE_CATEGORIES <- c(
  "Sangat Rendah",  # Very Low
  "Rendah",         # Low
  "Sedang",         # Average
  "Tinggi",         # High
  "Sangat Tinggi"   # Very High
)

# Minimum sample size for demographic subgroup norms
CONFIG_NORM_MIN_SUBGROUP <- 30


# ================================================================================
# VISUALIZATION SETTINGS
# ================================================================================

# Default plot dimensions
CONFIG_PLOT_WIDTH_SMALL <- 1800
CONFIG_PLOT_HEIGHT_SMALL <- 1500
CONFIG_PLOT_WIDTH_MEDIUM <- 2400
CONFIG_PLOT_HEIGHT_MEDIUM <- 1800
CONFIG_PLOT_WIDTH_LARGE <- 2400
CONFIG_PLOT_HEIGHT_LARGE <- 2400
CONFIG_PLOT_WIDTH_XLARGE <- 3000
CONFIG_PLOT_HEIGHT_XLARGE <- 3000
CONFIG_PLOT_RESOLUTION <- 300  # DPI

# Sample sizes for specific visualizations
CONFIG_VIZ_HEATMAP_SAMPLE <- 100   # Respondents shown in heatmap

# Color schemes
CONFIG_COLOR_PRIMARY <- rgb(0.2, 0.5, 0.8, 0.8)
CONFIG_COLOR_SECONDARY <- rgb(0.8, 0.3, 0.3, 0.8)


# ================================================================================
# RELIABILITY SETTINGS
# ================================================================================

# Reliability interpretation thresholds (Cronbach's Alpha / Omega)
CONFIG_RELIABILITY_EXCELLENT <- 0.90
CONFIG_RELIABILITY_GOOD <- 0.80
CONFIG_RELIABILITY_ACCEPTABLE <- 0.70
CONFIG_RELIABILITY_QUESTIONABLE <- 0.60
# Below 0.60 is considered "Poor"


# ================================================================================
# REPORT SETTINGS
# ================================================================================

# Organization name for report header
CONFIG_ORGANIZATION <- "PT. Nirmala Satya Development"

# Report date format
CONFIG_REPORT_DATE_FORMAT <- "%Y-%m-%d"


# ================================================================================
# HELPER FUNCTIONS
# ================================================================================

#' Print configuration summary
#' @export
print_config <- function() {
  cat("\n")
  cat("=" %R% 80, "\n")
  cat("EPPS ANALYSIS CONFIGURATION SUMMARY\n")
  cat("=" %R% 80, "\n\n")

  cat("General Settings:\n")
  cat("  Random Seed:", CONFIG_RANDOM_SEED, "\n")
  cat("  Data File:", CONFIG_DATA_FILE, "\n")
  cat("  Output Directory:", CONFIG_OUTPUT_DIR, "\n\n")

  cat("IRT Settings:\n")
  cat("  Min Items per Aspect:", CONFIG_IRT_MIN_ITEMS, "\n")
  cat("  MIRT Max Sample:", CONFIG_MIRT_MAX_SAMPLE, "\n")
  cat("  TIRT Max Sample:", CONFIG_TIRT_MAX_SAMPLE, "\n")
  cat("  TIRT Skip:", CONFIG_TIRT_SKIP, "\n\n")

  cat("Network Settings:\n")
  cat("  Correlation Threshold:", CONFIG_NETWORK_THRESHOLD_LOW, "\n")
  cat("  Run Bootstrap:", CONFIG_NETWORK_RUN_BOOTSTRAP, "\n\n")

  cat("Scoring Settings:\n")
  cat("  T-Score Mean:", CONFIG_TSCORE_MEAN, "\n")
  cat("  T-Score SD:", CONFIG_TSCORE_SD, "\n\n")

  cat("=" %R% 80, "\n\n")
}

#' Get configuration value with default fallback
#' @param name Configuration parameter name
#' @param default Default value if not found
#' @return Configuration value
#' @export
get_config <- function(name, default = NULL) {
  value <- get0(name, envir = .GlobalEnv, inherits = FALSE)
  if (is.null(value)) {
    return(default)
  }
  return(value)
}


# ================================================================================
# VALIDATION
# ================================================================================

# Validate configuration on load
validate_config <- function() {
  errors <- c()

  # Check numeric ranges
  if (CONFIG_IRT_MIN_ITEMS < 1) {
    errors <- c(errors, "CONFIG_IRT_MIN_ITEMS must be >= 1")
  }

  if (CONFIG_3PL_MAX_GUESSING < 0 || CONFIG_3PL_MAX_GUESSING > 1) {
    errors <- c(errors, "CONFIG_3PL_MAX_GUESSING must be between 0 and 1")
  }

  if (CONFIG_TSCORE_SD <= 0) {
    errors <- c(errors, "CONFIG_TSCORE_SD must be positive")
  }

  if (length(CONFIG_ASPECT_CODES) != 15) {
    errors <- c(errors, "CONFIG_ASPECTS must contain exactly 15 aspects")
  }

  # Report validation results
  if (length(errors) > 0) {
    cat("\n*** CONFIGURATION VALIDATION ERRORS ***\n")
    for (err in errors) {
      cat("  -", err, "\n")
    }
    cat("\nPlease fix these errors in 00_Config.R\n\n")
    stop("Configuration validation failed")
  }
}

# Auto-validate when sourced
validate_config()

cat("\n✓ Configuration file loaded successfully\n")
cat("  Run print_config() to see all settings\n\n")
