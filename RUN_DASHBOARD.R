# ============================================================================
# SCRIPT: LAUNCH EPPS PSYCHOMETRIC DASHBOARD
# ============================================================================
# Script untuk menjalankan Shiny dashboard
# ============================================================================

cat("\n")
cat("==============================================================================\n")
cat("        LAUNCHING EPPS PSYCHOMETRIC ANALYSIS DASHBOARD\n")
cat("==============================================================================\n")
cat("\n")

# Check if output directory exists
if(!dir.exists("output")) {
  stop("ERROR: Output directory not found!\n",
       "Please run MASTER_RUN_ALL.R first to generate analysis results.\n")
}

# Check if dashboard exists
if(!file.exists("dashboard/app.R")) {
  stop("ERROR: Dashboard application not found at dashboard/app.R\n")
}

# Check for required packages
required_packages <- c("shiny", "shinydashboard", "DT", "ggplot2", "plotly", "htmltools")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if(length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages)
}

cat("\nStarting dashboard...\n")
cat("Dashboard will open in your default web browser.\n")
cat("To stop the dashboard, press Ctrl+C or Esc in the R console.\n\n")

# Launch dashboard
shiny::runApp("dashboard", launch.browser = TRUE)
