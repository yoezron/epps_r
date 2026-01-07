# ================================================================================
# EPPS Analysis Utility Functions
# ================================================================================
# This file contains shared utility functions used across multiple analysis
# scripts to reduce code duplication and improve maintainability.
#
# Created: 2026-01-07
# ================================================================================

# Load required configuration (if not already loaded)
if (!exists("CONFIG_RANDOM_SEED")) {
  source("00_Config.R")
}


# ================================================================================
# PACKAGE MANAGEMENT
# ================================================================================

#' Install and load required packages
#' @param packages Character vector of package names
#' @param quietly Suppress startup messages (default: TRUE)
#' @return None (side effect: packages loaded)
#' @export
ensure_packages <- function(packages, quietly = TRUE) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = quietly)) {
      cat("Installing package:", pkg, "\n")
      install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org/")
      library(pkg, character.only = TRUE, quietly = quietly)
    }
  }
}


# ================================================================================
# DIRECTORY MANAGEMENT
# ================================================================================

#' Create output directory structure
#' @param base_dir Base output directory (default from config)
#' @return None (side effect: directories created)
#' @export
setup_output_dirs <- function(base_dir = CONFIG_OUTPUT_DIR) {
  dirs <- c(
    base_dir,
    file.path(base_dir, "plots"),
    file.path(base_dir, "tables"),
    file.path(base_dir, "models"),
    file.path(base_dir, "reports")
  )

  for (dir in dirs) {
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE)
      cat("Created directory:", dir, "\n")
    }
  }
}


# ================================================================================
# DATA VALIDATION
# ================================================================================

#' Validate that required columns exist in data
#' @param data Data frame to validate
#' @param required_cols Character vector of required column names
#' @param script_name Name of calling script for error messages
#' @return Logical TRUE if valid, stops with error otherwise
#' @export
validate_columns <- function(data, required_cols, script_name = "Unknown") {
  missing_cols <- setdiff(required_cols, colnames(data))

  if (length(missing_cols) > 0) {
    stop(sprintf(
      "[%s] Missing required columns: %s",
      script_name,
      paste(missing_cols, collapse = ", ")
    ))
  }

  return(TRUE)
}

#' Check for NA values in data
#' @param data Data frame or matrix
#' @param warn_threshold Proportion of NAs to trigger warning (default: 0.05)
#' @return List with na_count, na_proportion, and affected columns
#' @export
check_missing_data <- function(data, warn_threshold = 0.05) {
  na_count <- sum(is.na(data))
  total_values <- prod(dim(data))
  na_proportion <- na_count / total_values

  # Identify columns with NAs
  cols_with_na <- colnames(data)[colSums(is.na(data)) > 0]

  if (na_proportion > warn_threshold) {
    warning(sprintf(
      "Data contains %.2f%% missing values (threshold: %.2f%%)\nAffected columns: %s",
      na_proportion * 100,
      warn_threshold * 100,
      paste(cols_with_na, collapse = ", ")
    ))
  }

  return(list(
    na_count = na_count,
    na_proportion = na_proportion,
    affected_columns = cols_with_na
  ))
}


# ================================================================================
# CORRELATION MATRIX UTILITIES
# ================================================================================

#' Regularize correlation matrix to ensure positive definiteness
#' @param cor_matrix Correlation matrix to regularize
#' @param method Method for regularization ("nearPD", "eigen", or "ridge")
#' @param eigen_threshold Minimum eigenvalue (default from config)
#' @return Regularized correlation matrix
#' @export
regularize_correlation_matrix <- function(cor_matrix,
                                          method = "nearPD",
                                          eigen_threshold = CONFIG_NETWORK_EIGEN_THRESHOLD) {
  # Check if matrix is already positive definite
  eigenvalues <- eigen(cor_matrix, only.values = TRUE)$values

  if (all(eigenvalues > 0)) {
    return(cor_matrix)  # Already positive definite
  }

  cat("Regularizing correlation matrix (min eigenvalue:",
      round(min(eigenvalues), 4), ")\n")

  # Method 1: Use Matrix::nearPD
  if (method == "nearPD") {
    if (require("Matrix", quietly = TRUE)) {
      cor_matrix_pd <- as.matrix(Matrix::nearPD(cor_matrix, corr = TRUE)$mat)
      return(cor_matrix_pd)
    } else {
      warning("Matrix package not available, falling back to eigen method")
      method <- "eigen"
    }
  }

  # Method 2: Eigenvalue adjustment
  if (method == "eigen") {
    eigen_decomp <- eigen(cor_matrix)
    eigenvalues <- eigen_decomp$values
    eigenvectors <- eigen_decomp$vectors

    # Replace negative eigenvalues with threshold
    eigenvalues[eigenvalues < eigen_threshold] <- eigen_threshold

    # Reconstruct matrix
    cor_matrix_pd <- eigenvectors %*% diag(eigenvalues) %*% t(eigenvectors)

    # Ensure diagonal is 1
    diag(cor_matrix_pd) <- 1

    # Ensure symmetry
    cor_matrix_pd <- (cor_matrix_pd + t(cor_matrix_pd)) / 2

    return(cor_matrix_pd)
  }

  # Method 3: Ridge regularization
  if (method == "ridge") {
    diag_adjustment <- eigen_threshold * diag(nrow(cor_matrix))
    cor_matrix_pd <- cor_matrix + diag_adjustment
    diag(cor_matrix_pd) <- 1
    return(cor_matrix_pd)
  }

  stop("Unknown regularization method:", method)
}

#' Safe correlation matrix computation with error handling
#' @param data Numeric data frame or matrix
#' @param method Correlation method ("pearson", "spearman", "kendall")
#' @param use How to handle missing values (default: "pairwise.complete.obs")
#' @param regularize Whether to regularize the matrix (default: TRUE)
#' @return Correlation matrix
#' @export
safe_cor_matrix <- function(data,
                             method = "pearson",
                             use = "pairwise.complete.obs",
                             regularize = TRUE) {
  tryCatch({
    cor_matrix <- cor(data, method = method, use = use)

    # Check for NAs
    if (any(is.na(cor_matrix))) {
      warning("Correlation matrix contains NAs, attempting fallback")
      cor_matrix <- cor(data, method = method, use = "complete.obs")
    }

    # Regularize if requested
    if (regularize) {
      cor_matrix <- regularize_correlation_matrix(cor_matrix)
    }

    return(cor_matrix)

  }, error = function(e) {
    stop("Failed to compute correlation matrix: ", e$message)
  })
}


# ================================================================================
# IRT MODEL UTILITIES
# ================================================================================

#' Fit IRT model with error handling and validation
#' @param data Item response data (numeric matrix or data frame)
#' @param model_type Type of model ("1PL", "2PL", "3PL", "GRM")
#' @param aspect_name Name of aspect being analyzed
#' @param ... Additional parameters passed to model fitting function
#' @return List containing model object and fit statistics, or NULL if failed
#' @export
fit_irt_model <- function(data, model_type = "2PL", aspect_name = "Unknown", ...) {
  # Validate input
  if (ncol(data) < CONFIG_IRT_MIN_ITEMS) {
    warning(sprintf(
      "[%s] Insufficient items (%d < %d), skipping",
      aspect_name, ncol(data), CONFIG_IRT_MIN_ITEMS
    ))
    return(NULL)
  }

  # Ensure numeric data
  data <- as.data.frame(lapply(data, as.numeric))

  # Remove rows with all NAs
  data <- data[rowSums(is.na(data)) < ncol(data), ]

  if (nrow(data) < 50) {
    warning(sprintf(
      "[%s] Insufficient valid responses (%d < 50), skipping",
      aspect_name, nrow(data)
    ))
    return(NULL)
  }

  # Fit model based on type
  model <- NULL
  fit_stats <- NULL

  tryCatch({
    if (model_type == "2PL") {
      require("ltm", quietly = TRUE)
      model <- ltm::ltm(data ~ z1, ...)
      fit_stats <- list(
        logLik = logLik(model),
        AIC = AIC(model),
        BIC = BIC(model)
      )

    } else if (model_type == "3PL") {
      require("ltm", quietly = TRUE)
      model <- ltm::tpm(data, max.guessing = CONFIG_3PL_MAX_GUESSING, ...)
      fit_stats <- list(
        logLik = logLik(model),
        AIC = AIC(model),
        BIC = BIC(model)
      )

    } else if (model_type == "GRM") {
      require("ltm", quietly = TRUE)
      model <- ltm::grm(data, ...)
      fit_stats <- list(
        logLik = logLik(model),
        AIC = AIC(model),
        BIC = BIC(model)
      )

    } else {
      stop("Unknown model type: ", model_type)
    }

    cat(sprintf("[%s] %s model fitted successfully\n", aspect_name, model_type))

    return(list(
      model = model,
      fit_stats = fit_stats,
      convergence = TRUE
    ))

  }, error = function(e) {
    warning(sprintf(
      "[%s] Error fitting %s model: %s",
      aspect_name, model_type, e$message
    ))
    return(NULL)
  })
}


# ================================================================================
# PLOT UTILITIES
# ================================================================================

#' Save plot with standardized dimensions and error handling
#' @param filename Output filename (path)
#' @param plot_function Function that creates the plot
#' @param width Plot width in pixels (default from config)
#' @param height Plot height in pixels (default from config)
#' @param res Resolution in DPI (default from config)
#' @return Logical indicating success
#' @export
save_plot <- function(filename,
                      plot_function,
                      width = CONFIG_PLOT_WIDTH_MEDIUM,
                      height = CONFIG_PLOT_HEIGHT_MEDIUM,
                      res = CONFIG_PLOT_RESOLUTION) {
  tryCatch({
    png(filename, width = width, height = height, res = res)
    plot_function()
    dev.off()
    cat("Plot saved:", filename, "\n")
    return(TRUE)

  }, error = function(e) {
    if (dev.cur() > 1) dev.off()  # Close device if open
    warning("Failed to save plot ", filename, ": ", e$message)
    return(FALSE)
  })
}

#' Create standard color palette for aspects
#' @param n Number of colors needed
#' @return Character vector of hex color codes
#' @export
get_aspect_colors <- function(n = 15) {
  if (n <= 12) {
    return(RColorBrewer::brewer.pal(max(3, n), "Set3")[1:n])
  } else {
    # For more than 12 colors, use rainbow
    return(rainbow(n, s = 0.6, v = 0.8))
  }
}


# ================================================================================
# DATA EXPORT UTILITIES
# ================================================================================

#' Save data frame to CSV with error handling
#' @param data Data frame to save
#' @param filename Output filename
#' @param row_names Include row names (default: FALSE)
#' @return Logical indicating success
#' @export
safe_write_csv <- function(data, filename, row_names = FALSE) {
  tryCatch({
    write.csv(data, filename, row.names = row_names, fileEncoding = "UTF-8")
    cat("Table saved:", filename, "\n")
    return(TRUE)

  }, error = function(e) {
    warning("Failed to save CSV ", filename, ": ", e$message)
    return(FALSE)
  })
}

#' Save R object to RDS with error handling
#' @param object R object to save
#' @param filename Output filename
#' @return Logical indicating success
#' @export
safe_save_rds <- function(object, filename) {
  tryCatch({
    saveRDS(object, filename)
    cat("Model saved:", filename, "\n")
    return(TRUE)

  }, error = function(e) {
    warning("Failed to save RDS ", filename, ": ", e$message)
    return(FALSE)
  })
}


# ================================================================================
# DEMOGRAPHIC UTILITIES
# ================================================================================

#' Detect demographic columns using pattern matching
#' @param data Data frame to search
#' @param patterns Named list of patterns (from config)
#' @return Named list of detected column names
#' @export
detect_demographic_cols <- function(data, patterns = CONFIG_DEMO_PATTERNS) {
  detected <- list()

  for (demo_type in names(patterns)) {
    pattern_regex <- paste(patterns[[demo_type]], collapse = "|")
    matches <- grep(pattern_regex, tolower(colnames(data)), value = TRUE)

    if (length(matches) > 0) {
      # Get original case column name
      original_name <- colnames(data)[tolower(colnames(data)) == matches[1]]
      detected[[demo_type]] <- original_name
    } else {
      detected[[demo_type]] <- NA
    }
  }

  return(detected)
}


# ================================================================================
# SAMPLING UTILITIES
# ================================================================================

#' Sample data with maximum size limit
#' @param data Data frame to sample
#' @param max_size Maximum sample size
#' @param seed Random seed (default from config)
#' @return Sampled data frame and sampling indices
#' @export
smart_sample <- function(data, max_size, seed = CONFIG_RANDOM_SEED) {
  n <- nrow(data)

  if (n <= max_size) {
    return(list(data = data, indices = 1:n, sampled = FALSE))
  }

  set.seed(seed)
  sample_idx <- sample(1:n, max_size)

  cat(sprintf("Sampling %d of %d observations (%.1f%%)\n",
              max_size, n, 100 * max_size / n))

  return(list(
    data = data[sample_idx, ],
    indices = sample_idx,
    sampled = TRUE
  ))
}


# ================================================================================
# PROGRESS REPORTING
# ================================================================================

#' Print section header
#' @param title Section title
#' @param width Total width (default: 80)
#' @export
print_section_header <- function(title, width = 80) {
  cat("\n")
  cat(strrep("=", width), "\n")
  cat(title, "\n")
  cat(strrep("=", width), "\n\n")
}

#' Print subsection header
#' @param title Subsection title
#' @param width Total width (default: 80)
#' @export
print_subsection_header <- function(title, width = 80) {
  cat("\n")
  cat(strrep("-", width), "\n")
  cat(title, "\n")
  cat(strrep("-", width), "\n\n")
}

#' Print progress message with timestamp
#' @param message Progress message
#' @export
print_progress <- function(message) {
  timestamp <- format(Sys.time(), "%H:%M:%S")
  cat(sprintf("[%s] %s\n", timestamp, message))
}


# ================================================================================
# LOGGING
# ================================================================================

# Global log file path
LOG_FILE <- file.path(CONFIG_OUTPUT_DIR, "analysis_log.txt")

#' Initialize log file
#' @export
init_log <- function() {
  if (dir.exists(CONFIG_OUTPUT_DIR)) {
    cat("", file = LOG_FILE)  # Create/clear log file
    log_message("Analysis log initialized")
  }
}

#' Write message to log file
#' @param message Message to log
#' @param level Log level ("INFO", "WARNING", "ERROR")
#' @export
log_message <- function(message, level = "INFO") {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_entry <- sprintf("[%s] %s: %s\n", timestamp, level, message)

  # Write to log file if it exists
  if (file.exists(dirname(LOG_FILE))) {
    cat(log_entry, file = LOG_FILE, append = TRUE)
  }

  # Also print to console for INFO and WARNING
  if (level %in% c("INFO", "WARNING")) {
    cat(log_entry)
  }
}


# ================================================================================
# INITIALIZATION MESSAGE
# ================================================================================

cat("\n✓ Utility functions loaded successfully\n")
cat("  Available functions:", length(ls(pattern = "^[a-z_]+$")), "\n")
cat("  Run ls() to see all available utilities\n\n")
