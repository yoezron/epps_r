# ============================================================================
# SHINY DASHBOARD: EPPS PSYCHOMETRIC ANALYSIS VISUALIZATION
# ============================================================================
# Interactive dashboard untuk menampilkan hasil analisis psikometrik EPPS
# ============================================================================

library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(plotly)
library(htmltools)

# ===== UI =====
ui <- dashboardPage(
  skin = "blue",

  # Header
  dashboardHeader(title = "EPPS Psychometric Analysis"),

  # Sidebar
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Deskriptif & Reliabilitas", tabName = "descriptive", icon = icon("chart-bar")),
      menuItem("IRT Analysis", tabName = "irt", icon = icon("chart-line")),
      menuItem("Network Analysis", tabName = "network", icon = icon("project-diagram")),
      menuItem("Interactive Networks", tabName = "interactive", icon = icon("sitemap")),
      menuItem("Norma & Scoring", tabName = "norma", icon = icon("table")),
      menuItem("Visualizations", tabName = "viz", icon = icon("image"))
    )
  ),

  # Body
  dashboardBody(
    tabItems(
      # ===== TAB: OVERVIEW =====
      tabItem(
        tabName = "overview",
        fluidRow(
          valueBoxOutput("total_respondents"),
          valueBoxOutput("total_items"),
          valueBoxOutput("total_aspects")
        ),
        fluidRow(
          box(
            title = "Summary Statistics",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            DTOutput("summary_table")
          )
        ),
        fluidRow(
          box(
            title = "Reliability by Aspect",
            width = 12,
            solidHeader = TRUE,
            status = "info",
            DTOutput("reliability_table")
          )
        )
      ),

      # ===== TAB: DESCRIPTIVE & RELIABILITY =====
      tabItem(
        tabName = "descriptive",
        fluidRow(
          box(
            title = "Descriptive Statistics",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            DTOutput("descriptive_stats")
          )
        ),
        fluidRow(
          box(
            title = "Item Analysis",
            width = 12,
            solidHeader = TRUE,
            status = "info",
            DTOutput("item_analysis")
          )
        ),
        fluidRow(
          box(
            title = "Correlation Matrix Plot",
            width = 12,
            solidHeader = TRUE,
            status = "success",
            imageOutput("correlation_plot", height = "600px")
          )
        )
      ),

      # ===== TAB: IRT ANALYSIS =====
      tabItem(
        tabName = "irt",
        fluidRow(
          box(
            title = "IRT 2PL Parameters",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            DTOutput("irt_2pl_table")
          )
        ),
        fluidRow(
          box(
            title = "IRT 3PL Parameters",
            width = 12,
            solidHeader = TRUE,
            status = "info",
            DTOutput("irt_3pl_table")
          )
        ),
        fluidRow(
          box(
            title = "Item Characteristic Curves",
            width = 12,
            solidHeader = TRUE,
            status = "success",
            imageOutput("icc_plot", height = "600px")
          )
        )
      ),

      # ===== TAB: NETWORK ANALYSIS =====
      tabItem(
        tabName = "network",
        fluidRow(
          box(
            title = "Network Centrality Measures",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            DTOutput("centrality_table")
          )
        ),
        fluidRow(
          box(
            title = "Community Detection",
            width = 6,
            solidHeader = TRUE,
            status = "info",
            DTOutput("community_table")
          ),
          box(
            title = "Clustering Coefficient",
            width = 6,
            solidHeader = TRUE,
            status = "info",
            DTOutput("clustering_table")
          )
        ),
        fluidRow(
          box(
            title = "Network Visualization (GGM)",
            width = 12,
            solidHeader = TRUE,
            status = "success",
            imageOutput("network_ggm", height = "700px")
          )
        ),
        fluidRow(
          box(
            title = "Network with Communities",
            width = 12,
            solidHeader = TRUE,
            status = "warning",
            imageOutput("network_communities", height = "700px")
          )
        )
      ),

      # ===== TAB: INTERACTIVE NETWORKS =====
      tabItem(
        tabName = "interactive",
        fluidRow(
          box(
            title = "Interactive Network (visNetwork)",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            uiOutput("interactive_visnetwork")
          )
        ),
        fluidRow(
          box(
            title = "3D Network (Plotly)",
            width = 12,
            solidHeader = TRUE,
            status = "info",
            uiOutput("interactive_3d")
          )
        ),
        fluidRow(
          box(
            title = "Radial Network",
            width = 6,
            solidHeader = TRUE,
            status = "success",
            uiOutput("interactive_radial")
          ),
          box(
            title = "D3 Force Network",
            width = 6,
            solidHeader = TRUE,
            status = "success",
            uiOutput("interactive_d3")
          )
        )
      ),

      # ===== TAB: NORMA & SCORING =====
      tabItem(
        tabName = "norma",
        fluidRow(
          box(
            title = "T-Score Norms by Aspect",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            DTOutput("norma_table")
          )
        ),
        fluidRow(
          box(
            title = "Percentile Ranks",
            width = 12,
            solidHeader = TRUE,
            status = "info",
            DTOutput("percentile_table")
          )
        )
      ),

      # ===== TAB: VISUALIZATIONS =====
      tabItem(
        tabName = "viz",
        fluidRow(
          box(
            title = "Available Visualizations",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            selectInput("viz_select", "Select Visualization:", choices = NULL),
            imageOutput("selected_viz", height = "700px")
          )
        )
      )
    )
  )
)

# ===== SERVER =====
server <- function(input, output, session) {

  # Helper function to read CSV safely
  read_csv_safe <- function(filename) {
    filepath <- file.path("output/tables", filename)
    if(file.exists(filepath)) {
      return(read.csv(filepath, stringsAsFactors = FALSE))
    } else {
      return(data.frame(Message = paste("File not found:", filename)))
    }
  }

  # Helper function to render image safely
  render_image_safe <- function(filename) {
    filepath <- file.path("output/plots", filename)
    if(file.exists(filepath)) {
      return(filepath)
    } else {
      return(NULL)
    }
  }

  # ===== VALUE BOXES =====
  output$total_respondents <- renderValueBox({
    # Try to get from descriptive stats
    desc <- read_csv_safe("01_Deskriptif_Aspek.csv")
    n <- ifelse("N" %in% names(desc), max(desc$N, na.rm = TRUE), 6464)

    valueBox(
      value = format(n, big.mark = ","),
      subtitle = "Total Respondents",
      icon = icon("users"),
      color = "blue"
    )
  })

  output$total_items <- renderValueBox({
    valueBox(
      value = "420",
      subtitle = "Total Items",
      icon = icon("list"),
      color = "green"
    )
  })

  output$total_aspects <- renderValueBox({
    valueBox(
      value = "15",
      subtitle = "Personality Aspects",
      icon = icon("brain"),
      color = "purple"
    )
  })

  # ===== SUMMARY TABLE =====
  output$summary_table <- renderDT({
    df <- read_csv_safe("01_Deskriptif_Aspek.csv")
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })

  # ===== RELIABILITY TABLE =====
  output$reliability_table <- renderDT({
    df <- read_csv_safe("02_Reliabilitas_Aspek.csv")
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })

  # ===== DESCRIPTIVE STATS =====
  output$descriptive_stats <- renderDT({
    df <- read_csv_safe("01_Deskriptif_Aspek.csv")
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })

  # ===== ITEM ANALYSIS =====
  output$item_analysis <- renderDT({
    df <- read_csv_safe("03_Item_Analysis.csv")
    datatable(df, options = list(pageLength = 20, scrollX = TRUE))
  })

  # ===== CORRELATION PLOT =====
  output$correlation_plot <- renderImage({
    filepath <- render_image_safe("Correlation_Heatmap.png")
    if(!is.null(filepath)) {
      list(src = filepath, contentType = "image/png", width = "100%")
    } else {
      list(src = "", alt = "Image not found")
    }
  }, deleteFile = FALSE)

  # ===== IRT TABLES =====
  output$irt_2pl_table <- renderDT({
    df <- read_csv_safe("05_IRT_2PL_Parameters.csv")
    datatable(df, options = list(pageLength = 20, scrollX = TRUE))
  })

  output$irt_3pl_table <- renderDT({
    df <- read_csv_safe("07_IRT_3PL_Parameters.csv")
    datatable(df, options = list(pageLength = 20, scrollX = TRUE))
  })

  # ===== ICC PLOT =====
  output$icc_plot <- renderImage({
    filepath <- render_image_safe("IRT_2PL_ICC.png")
    if(!is.null(filepath)) {
      list(src = filepath, contentType = "image/png", width = "100%")
    } else {
      list(src = "", alt = "Image not found")
    }
  }, deleteFile = FALSE)

  # ===== NETWORK TABLES =====
  output$centrality_table <- renderDT({
    df <- read_csv_safe("25_Network_Centrality.csv")
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })

  output$community_table <- renderDT({
    df <- read_csv_safe("28_Network_Communities.csv")
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })

  output$clustering_table <- renderDT({
    df <- read_csv_safe("26_Network_Clustering.csv")
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })

  # ===== NETWORK PLOTS =====
  output$network_ggm <- renderImage({
    filepath <- render_image_safe("Network_GGM.png")
    if(!is.null(filepath)) {
      list(src = filepath, contentType = "image/png", width = "100%")
    } else {
      list(src = "", alt = "Image not found")
    }
  }, deleteFile = FALSE)

  output$network_communities <- renderImage({
    filepath <- render_image_safe("Network_Communities.png")
    if(!is.null(filepath)) {
      list(src = filepath, contentType = "image/png", width = "100%")
    } else {
      list(src = "", alt = "Image not found")
    }
  }, deleteFile = FALSE)

  # ===== INTERACTIVE NETWORKS =====
  output$interactive_visnetwork <- renderUI({
    filepath <- file.path("output/plots", "Network_Interactive_visNetwork.html")
    if(file.exists(filepath)) {
      tags$iframe(src = "plots/Network_Interactive_visNetwork.html",
                  width = "100%", height = "700px", frameborder = 0)
    } else {
      tags$p("Interactive network not found. Please run 08D_Interactive_Network.R")
    }
  })

  output$interactive_3d <- renderUI({
    filepath <- file.path("output/plots", "Network_3D_Plotly.html")
    if(file.exists(filepath)) {
      tags$iframe(src = "plots/Network_3D_Plotly.html",
                  width = "100%", height = "700px", frameborder = 0)
    } else {
      tags$p("3D network not found. Please run 08D_Interactive_Network.R")
    }
  })

  output$interactive_radial <- renderUI({
    filepath <- file.path("output/plots", "Network_Radial.html")
    if(file.exists(filepath)) {
      tags$iframe(src = "plots/Network_Radial.html",
                  width = "100%", height = "600px", frameborder = 0)
    } else {
      tags$p("Radial network not found. Please run 08D_Interactive_Network.R")
    }
  })

  output$interactive_d3 <- renderUI({
    filepath <- file.path("output/plots", "Network_D3_Force.html")
    if(file.exists(filepath)) {
      tags$iframe(src = "plots/Network_D3_Force.html",
                  width = "100%", height = "600px", frameborder = 0)
    } else {
      tags$p("D3 network not found. Please run 08D_Interactive_Network.R")
    }
  })

  # ===== NORMA TABLES =====
  output$norma_table <- renderDT({
    df <- read_csv_safe("19_Norma_TScore.csv")
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })

  output$percentile_table <- renderDT({
    df <- read_csv_safe("20_Norma_Percentile.csv")
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })

  # ===== VISUALIZATION SELECTOR =====
  observe({
    # Get all PNG files from plots directory
    plots_dir <- "output/plots"
    if(dir.exists(plots_dir)) {
      png_files <- list.files(plots_dir, pattern = "\\.png$", full.names = FALSE)
      updateSelectInput(session, "viz_select", choices = png_files)
    }
  })

  output$selected_viz <- renderImage({
    req(input$viz_select)
    filepath <- file.path("output/plots", input$viz_select)
    if(file.exists(filepath)) {
      list(src = filepath, contentType = "image/png", width = "100%")
    } else {
      list(src = "", alt = "Image not found")
    }
  }, deleteFile = FALSE)
}

# ===== RUN APP =====
shinyApp(ui = ui, server = server)
