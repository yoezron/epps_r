# ================================================================================
# SCRIPT 01: SETUP DAN PERSIAPAN DATA EPPS
# ================================================================================
# Edwards Personal Preference Schedule (EPPS) - Data Preparation
#
# This script:
# - Loads and validates raw data
# - Separates demographic and item columns
# - Aggregates item scores by aspect (15 personality traits)
# - Saves processed data for subsequent analysis
#
# PT. Data Riset Nusantara untuk PT. Nirmala Satya Development
# ================================================================================

# Load configuration and utilities
source("00_Config.R")
source("00_Utilities.R")

print_section_header("EPPS DATA SETUP AND PREPARATION")

# ================================================================================
# PACKAGE MANAGEMENT
# ================================================================================

print_progress("Loading required packages...")

required_packages <- c(
  "ltm", "mirt", "psych", "thurstonianIRT",
  "ggplot2", "plotly", "corrplot", "lavaan",
  "qgraph", "bootnet", "dplyr", "tidyr",
  "gridExtra", "RColorBrewer", "reshape2",
  "car", "GPArotation", "fmsb", "igraph",
  "networkD3", "visNetwork", "htmlwidgets", "Matrix"
)

ensure_packages(required_packages)

# ================================================================================
# DIRECTORY SETUP
# ================================================================================

print_progress("Creating output directories...")
setup_output_dirs()
init_log()

# ================================================================================
# DATA LOADING
# ================================================================================

print_progress("Loading raw data...")

if (!file.exists(CONFIG_DATA_FILE)) {
  stop(sprintf(
    "Data file not found: %s\nPlease ensure the file exists in the working directory: %s",
    CONFIG_DATA_FILE,
    getwd()
  ))
}

data_raw <- tryCatch({
  read.csv(
    CONFIG_DATA_FILE,
    fileEncoding = CONFIG_DATA_ENCODING,
    sep = CONFIG_DATA_DELIMITER,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}, error = function(e) {
  stop(sprintf("Failed to load data file: %s\nError: %s", CONFIG_DATA_FILE, e$message))
})

log_message(sprintf("Raw data loaded: %d rows, %d columns", nrow(data_raw), ncol(data_raw)))

# ================================================================================
# DATA CLEANING
# ================================================================================

print_progress("Cleaning data...")

# Remove empty first column if present (common BOM issue)
if (names(data_raw)[1] == "" || grepl("^ï|^#$", names(data_raw)[1])) {
  data_raw <- data_raw[, -1]
  log_message("Removed empty/BOM column")
}

# ================================================================================
# COLUMN IDENTIFICATION
# ================================================================================

print_progress("Identifying demographic and item columns...")

# Detect demographic columns using pattern matching
demo_cols_detected <- detect_demographic_cols(data_raw)

# Additional demographic patterns
demo_patterns <- c("#", "Responden", "Jenis Kelamin", "Tingkat Pendidikan",
                   "USIA", "Rentang Usia", "_angka", "Nama")

demo_cols <- names(data_raw)[sapply(names(data_raw), function(x) {
  any(sapply(demo_patterns, function(p) grepl(p, x, fixed = TRUE)))
})]

log_message(sprintf("Detected %d demographic columns", length(demo_cols)))

# Extract item columns only
data_items <- data_raw[, !names(data_raw) %in% demo_cols, drop = FALSE]

if (ncol(data_items) == 0) {
  stop("No item columns found after removing demographics. Please check column patterns.")
}

# ================================================================================
# NUMERIC CONVERSION
# ================================================================================

print_progress("Converting items to numeric...")

# Convert all item columns to numeric
data_items[] <- lapply(data_items, function(x) {
  as.numeric(as.character(x))
})

# Check for missing data
missing_info <- check_missing_data(data_items, warn_threshold = 0.10)

if (missing_info$na_proportion > 0) {
  log_message(sprintf(
    "Missing data: %.2f%% of values",
    missing_info$na_proportion * 100
  ), level = "WARNING")
}

# ================================================================================
# ASPECT EXTRACTION
# ================================================================================

print_progress("Extracting aspect names from item columns...")

#' Extract trait/aspect name from column name
#' @param col_name Column name (format: "2B - ACH" or similar)
#' @return Aspect code (e.g., "ACH") or NA
get_trait_name <- function(col_name) {
  # Format: "2B - ACH" or "2A - DEF"
  if (grepl(" - ", col_name)) {
    parts <- strsplit(col_name, " - ")[[1]]
    if (length(parts) >= 2) {
      trait <- trimws(parts[2])
      # Standardize to uppercase
      return(toupper(trait))
    }
  }
  return(NA)
}

trait_names <- sapply(names(data_items), get_trait_name)

# Use aspect definitions from config
aspek_epps <- CONFIG_ASPECT_CODES
aspek_labels <- CONFIG_ASPECTS

# Validate that extracted traits match expected aspects
extracted_aspects <- unique(trait_names[!is.na(trait_names)])
unknown_aspects <- setdiff(extracted_aspects, aspek_epps)

if (length(unknown_aspects) > 0) {
  log_message(sprintf(
    "Unknown aspects found in data: %s",
    paste(unknown_aspects, collapse = ", ")
  ), level = "WARNING")
}

# ================================================================================
# SCORE AGGREGATION
# ================================================================================

print_progress("Aggregating scores by aspect...")

# Initialize score matrix
skor_aspek <- as.data.frame(
  matrix(0, nrow = nrow(data_items), ncol = length(aspek_epps))
)
names(skor_aspek) <- aspek_epps

# Aggregate items for each aspect
for (aspek in aspek_epps) {
  item_cols <- which(trait_names == aspek)

  if (length(item_cols) > 0) {
    item_data <- data_items[, item_cols, drop = FALSE]

    # Ensure numeric data
    item_data[] <- lapply(item_data, function(x) as.numeric(as.character(x)))

    # Sum across items (row-wise)
    skor_aspek[[aspek]] <- rowSums(item_data, na.rm = TRUE)

    log_message(sprintf(
      "Aspect %s (%s): %d items aggregated",
      aspek, aspek_labels[aspek], length(item_cols)
    ))
  } else {
    log_message(sprintf(
      "Aspect %s (%s): No items found",
      aspek, aspek_labels[aspek]
    ), level = "WARNING")
  }
}

# ================================================================================
# DATA COMBINATION
# ================================================================================

print_progress("Combining demographic and score data...")

# Combine demographics, aspect scores, and item-level data
data_final <- tryCatch({
  cbind(
    data_raw[, demo_cols, drop = FALSE],
    skor_aspek,
    data_items
  )
}, error = function(e) {
  log_message("Failed to combine demographic data, using scores only", level = "WARNING")
  data.frame(skor_aspek, data_items)
})

# ================================================================================
# DATA EXPORT
# ================================================================================

print_progress("Saving processed data...")

# Save all processed data objects
save(
  data_raw,
  data_items,
  data_final,
  skor_aspek,
  trait_names,
  aspek_epps,
  aspek_labels,
  demo_cols,
  file = file.path(CONFIG_OUTPUT_DIR, "data_processed.RData")
)

log_message("Processed data saved to output/data_processed.RData")

# ================================================================================
# SUMMARY REPORT
# ================================================================================

print_section_header("DATA PROCESSING SUMMARY")

cat("Data File          :", CONFIG_DATA_FILE, "\n")
cat("Total Respondents  :", nrow(data_items), "\n")
cat("Total Items        :", ncol(data_items), "\n")
cat("Aspects Analyzed   :", length(aspek_epps), "\n")
cat("Missing Data       :", sprintf("%.2f%%", missing_info$na_proportion * 100), "\n\n")

# Display item count per aspect
print_subsection_header("Items per Aspect")

aspect_summary <- data.frame(
  Code = aspek_epps,
  Aspect = sapply(aspek_epps, function(x) aspek_labels[x]),
  Items = sapply(aspek_epps, function(x) sum(trait_names == x, na.rm = TRUE)),
  Mean_Score = round(colMeans(skor_aspek, na.rm = TRUE), 2),
  SD_Score = round(apply(skor_aspek, 2, sd, na.rm = TRUE), 2),
  stringsAsFactors = FALSE
)

print(aspect_summary, row.names = FALSE)

# Save aspect summary
safe_write_csv(
  aspect_summary,
  file.path(CONFIG_TABLES_DIR, "01_Aspect_Summary.csv")
)

cat("\n")
print_section_header("DATA SETUP COMPLETE")
cat("✓ All data processed and saved successfully\n")
cat("✓ Ready for analysis\n")
cat("\nNext: Run 02_Deskriptif_CTT.R for descriptive statistics\n\n")
