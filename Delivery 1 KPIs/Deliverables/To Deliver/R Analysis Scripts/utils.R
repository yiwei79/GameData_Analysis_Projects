# =====================================================
# Utility Functions for KPI Analysis
# =====================================================
# Helper functions for database connectivity, statistical
# analysis, visualization, and reporting
# =====================================================

# =====================================================
# DATABASE FUNCTIONS
# =====================================================

#' Safely connect to MySQL database
#' @return Database connection object or stops with error
safe_connect <- function() {
  if (!requireNamespace("RMySQL", quietly = TRUE)) {
    stop("Package 'RMySQL' is required. Install with: install.packages('RMySQL')")
  }
  
  library(RMySQL)
  
  tryCatch({
    con <- dbConnect(
      MySQL(),
      host = DB_CONFIG$host,
      dbname = DB_CONFIG$dbname,
      user = DB_CONFIG$user,
      password = DB_CONFIG$password
    )
    
    cat("✓ Successfully connected to database:", DB_CONFIG$dbname, "\n")
    return(con)
    
  }, error = function(e) {
    cat("✗ Database connection failed!\n")
    cat("Error:", conditionMessage(e), "\n")
    cat("\nTroubleshooting:\n")
    cat("1. Verify database name:", DB_CONFIG$dbname, "\n")
    cat("2. Check username:", DB_CONFIG$user, "\n")
    cat("3. Confirm password is correct\n")
    cat("4. Ensure host is correct:", DB_CONFIG$host, "\n")
    stop("Cannot proceed without database connection")
  })
}

#' Execute SQL query with error handling and logging
#' @param con Database connection object
#' @param query SQL query string
#' @param query_name Optional name for logging
#' @return Data frame with query results
execute_query <- function(con, query, query_name = NULL) {
  if (REPORT_CONFIG$verbose && !is.null(query_name)) {
    cat("  Executing:", query_name, "...")
  }
  
  tryCatch({
    result <- dbGetQuery(con, query)
    
    if (REPORT_CONFIG$verbose && !is.null(query_name)) {
      cat(" ✓ (", nrow(result), "rows)\n", sep = "")
    }
    
    return(result)
    
  }, error = function(e) {
    if (!is.null(query_name)) {
      cat("\n✗ Query failed:", query_name, "\n")
    }
    cat("Error:", conditionMessage(e), "\n")
    cat("Query:", substr(query, 1, 200), "...\n")
    return(NULL)
  })
}

#' Read SQL query from file
#' @param filepath Path to SQL file
#' @param query_number Number/identifier of query to extract
#' @return SQL query string
read_sql_query <- function(filepath, query_number = NULL) {
  if (!file.exists(filepath)) {
    stop("SQL file not found: ", filepath)
  }
  
  sql_content <- readLines(filepath, warn = FALSE)
  sql_text <- paste(sql_content, collapse = "\n")
  
  # If query_number specified, extract specific query
  # Otherwise return entire file
  return(sql_text)
}


# =====================================================
# STATISTICAL FUNCTIONS
# =====================================================

#' Calculate confidence interval for a numeric vector
#' @param x Numeric vector
#' @param conf_level Confidence level (default 0.95)
#' @return List with mean, lower, upper, and formatted string
calculate_ci <- function(x, conf_level = ANALYSIS_CONFIG$confidence_level) {
  # Remove NA values
  x <- x[!is.na(x)]
  
  if (length(x) < ANALYSIS_CONFIG$min_sample_size) {
    return(list(
      mean = NA,
      lower = NA,
      upper = NA,
      ci_string = "Insufficient data",
      n = length(x)
    ))
  }
  
  # Perform t-test to get confidence interval
  test_result <- t.test(x, conf.level = conf_level)
  
  mean_val <- mean(x)
  ci_lower <- test_result$conf.int[1]
  ci_upper <- test_result$conf.int[2]
  
  # Format as string
  ci_string <- sprintf("%.2f [%.2f, %.2f]", mean_val, ci_lower, ci_upper)
  
  return(list(
    mean = mean_val,
    lower = ci_lower,
    upper = ci_upper,
    ci_string = ci_string,
    n = length(x)
  ))
}

#' Perform appropriate statistical test based on sample size
#' @param x First group
#' @param y Second group
#' @return Test result object
smart_test <- function(x, y) {
  x <- x[!is.na(x)]
  y <- y[!is.na(y)]
  
  # If either group too small, return NULL
  if (length(x) < ANALYSIS_CONFIG$min_sample_size || 
      length(y) < ANALYSIS_CONFIG$min_sample_size) {
    return(NULL)
  }
  
  # Use t-test for continuous data
  tryCatch({
    test_result <- t.test(x, y)
    return(test_result)
  }, error = function(e) {
    return(NULL)
  })
}

#' Format p-value for reporting
#' @param p_value P-value from statistical test
#' @return Formatted string
format_pvalue <- function(p_value) {
  if (is.na(p_value) || is.null(p_value)) {
    return("N/A")
  }
  
  if (p_value < 0.001) {
    return("p < 0.001 ***")
  } else if (p_value < 0.01) {
    return(sprintf("p = %.3f **", p_value))
  } else if (p_value < 0.05) {
    return(sprintf("p = %.3f *", p_value))
  } else {
    return(sprintf("p = %.3f", p_value))
  }
}


# =====================================================
# DATA TRANSFORMATION FUNCTIONS
# =====================================================

#' Create age buckets from continuous age variable
#' @param ages Vector of ages
#' @return Factor with age groups
create_age_buckets <- function(ages) {
  cut(ages, 
      breaks = c(-Inf, 18, 25, 35, 45, Inf),
      labels = c("<18", "18-25", "26-35", "36-45", "45+"),
      right = FALSE)
}

#' Categorize gender from continuous variable
#' @param gender Vector of gender values (0-1)
#' @return Factor with gender categories
categorize_gender <- function(gender) {
  cut(gender,
      breaks = c(-Inf, 0.33, 0.67, Inf),
      labels = c("Male", "Neutral", "Female"),
      right = FALSE)
}

#' Format large numbers with commas
#' @param x Numeric value
#' @return Formatted string
format_number <- function(x) {
  format(round(x, REPORT_CONFIG$decimal_places), 
         big.mark = ",", 
         scientific = FALSE)
}

#' Format currency values
#' @param x Numeric value
#' @return Formatted string with $ symbol
format_currency <- function(x) {
  paste0("$", format(round(x, 2), nsmall = 2, big.mark = ","))
}

#' Format percentage values
#' @param x Numeric value (as proportion or percentage)
#' @param is_proportion If TRUE, multiply by 100
#' @return Formatted string with % symbol
format_percentage <- function(x, is_proportion = FALSE) {
  if (is_proportion) {
    x <- x * 100
  }
  paste0(round(x, REPORT_CONFIG$decimal_places), "%")
}


# =====================================================
# VISUALIZATION FUNCTIONS
# =====================================================

#' Export plot to file with consistent settings
#' @param plot ggplot object
#' @param filename Filename (without extension)
#' @param width Width in inches
#' @param height Height in inches
export_plot <- function(plot, filename, 
                       width = ANALYSIS_CONFIG$plot_width,
                       height = ANALYSIS_CONFIG$plot_height) {
  
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required")
  }
  
  # Create output directory if it doesn't exist
  output_dir <- ANALYSIS_CONFIG$output_dir
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    cat("Created output directory:", output_dir, "\n")
  }
  
  # Determine DPI based on quality setting
  dpi <- ifelse(ANALYSIS_CONFIG$high_quality_plots, 300, 72)
  
  # Save in requested formats
  for (format in VIZ_CONFIG$save_formats) {
    filepath <- file.path(output_dir, paste0(filename, ".", format))
    
    if (format == "png") {
      ggsave(filepath, plot, width = width, height = height, dpi = dpi)
    } else if (format == "pdf") {
      ggsave(filepath, plot, width = width, height = height, device = "pdf")
    }
    
    if (REPORT_CONFIG$verbose) {
      cat("  Saved:", filepath, "\n")
    }
  }
}

#' Get color palette based on configuration
#' @param n Number of colors needed
#' @return Vector of color codes
get_color_palette <- function(n = 5) {
  palette_name <- VIZ_CONFIG$color_palette
  
  if (palette_name %in% c("viridis", "plasma", "cividis", "magma")) {
    if (!requireNamespace("viridis", quietly = TRUE)) {
      # Fallback to base colors
      return(rainbow(n))
    }
    return(viridis::viridis(n, option = palette_name))
  }
  
  # Use RColorBrewer for other palettes
  if (!requireNamespace("RColorBrewer", quietly = TRUE)) {
    return(rainbow(n))
  }
  
  return(RColorBrewer::brewer.pal(min(n, 8), palette_name))
}

#' Apply standard theme to ggplot
#' @param plot ggplot object
#' @return ggplot object with theme applied
apply_theme <- function(plot) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    return(plot)
  }
  
  theme_name <- VIZ_CONFIG$plot_theme
  base_size <- VIZ_CONFIG$base_font_size
  
  theme_func <- switch(theme_name,
    "minimal" = ggplot2::theme_minimal,
    "bw" = ggplot2::theme_bw,
    "classic" = ggplot2::theme_classic,
    "gray" = ggplot2::theme_gray,
    ggplot2::theme_minimal  # default
  )
  
  plot + theme_func(base_size = base_size)
}


# =====================================================
# REPORTING FUNCTIONS
# =====================================================

#' Generate markdown table from data frame
#' @param df Data frame
#' @param caption Optional caption
#' @return Character vector with markdown table
summary_table <- function(df, caption = NULL) {
  if (!is.null(caption)) {
    cat("\n**", caption, "**\n\n", sep = "")
  }
  
  # Header
  cat("|", paste(names(df), collapse = " | "), "|\n", sep = "")
  cat("|", paste(rep("---", ncol(df)), collapse = "|"), "|\n", sep = "")
  
  # Rows
  for (i in 1:nrow(df)) {
    row_values <- sapply(df[i,], function(x) {
      if (is.numeric(x)) {
        format(round(x, REPORT_CONFIG$decimal_places), nsmall = REPORT_CONFIG$decimal_places)
      } else {
        as.character(x)
      }
    })
    cat("|", paste(row_values, collapse = " | "), "|\n", sep = "")
  }
  cat("\n")
}

#' Export data frame to CSV
#' @param df Data frame
#' @param filename Filename
export_csv <- function(df, filename) {
  if (!REPORT_CONFIG$export_csv) {
    return(invisible(NULL))
  }
  
  output_dir <- ANALYSIS_CONFIG$output_dir
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  filepath <- file.path(output_dir, paste0(filename, ".csv"))
  write.csv(df, filepath, row.names = FALSE)
  
  if (REPORT_CONFIG$verbose) {
    cat("  Exported CSV:", filepath, "\n")
  }
}

#' Print section header
#' @param title Section title
#' @param level Header level (1-3)
print_section <- function(title, level = 2) {
  prefix <- paste(rep("#", level), collapse = "")
  cat("\n", prefix, " ", title, "\n", sep = "")
  cat(paste(rep("=", nchar(title) + 2), collapse = ""), "\n\n", sep = "")
}

#' Print diagnostic message with checkmark
#' @param message Message to print
#' @param value Optional value to display
print_diagnostic <- function(message, value = NULL) {
  if (REPORT_CONFIG$verbose) {
    if (is.null(value)) {
      cat("✓", message, "\n")
    } else {
      cat("✓", message, ":", value, "\n")
    }
  }
}


# =====================================================
# VALIDATION FUNCTIONS
# =====================================================

#' Check if required packages are installed
#' @param packages Vector of package names
#' @return TRUE if all installed, FALSE otherwise
check_packages <- function(packages) {
  missing <- c()
  
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing <- c(missing, pkg)
    }
  }
  
  if (length(missing) > 0) {
    cat("✗ Missing required packages:", paste(missing, collapse = ", "), "\n")
    cat("\nInstall with:\n")
    cat("install.packages(c(", paste0("'", missing, "'", collapse = ", "), "))\n\n")
    return(FALSE)
  }
  
  cat("✓ All required packages are installed\n")
  return(TRUE)
}

#' Validate database connection and table structure
#' @param con Database connection
#' @return TRUE if valid, FALSE otherwise
validate_database <- function(con) {
  required_tables <- c("users", "sessions", "purchases", "items")
  
  tryCatch({
    existing_tables <- dbListTables(con)
    missing_tables <- setdiff(required_tables, existing_tables)
    
    if (length(missing_tables) > 0) {
      cat("✗ Missing required tables:", paste(missing_tables, collapse = ", "), "\n")
      return(FALSE)
    }
    
    cat("✓ All required tables exist\n")
    return(TRUE)
    
  }, error = function(e) {
    cat("✗ Cannot validate database:", conditionMessage(e), "\n")
    return(FALSE)
  })
}


# =====================================================
# INITIALIZATION
# =====================================================

#' Initialize analysis environment
#' @return TRUE if successful
initialize_analysis <- function() {
  cat("\n")
  cat("========================================\n")
  cat("  KPI Analysis - Initialization\n")
  cat("========================================\n\n")
  
  # Check packages
  required_pkgs <- c("RMySQL", "ggplot2", "dplyr", "tidyr")
  if (!check_packages(required_pkgs)) {
    stop("Please install missing packages before proceeding")
  }
  
  # Verify config
  tryCatch({
    verify_config()
  }, error = function(e) {
    cat("✗ Configuration error:", conditionMessage(e), "\n")
    stop("Please fix configuration issues")
  })
  
  cat("\n✓ Initialization complete\n\n")
  return(TRUE)
}


# =====================================================
# END OF UTILITIES
# =====================================================
cat("Utility functions loaded successfully\n")

