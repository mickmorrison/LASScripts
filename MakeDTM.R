# Simplified MakeDTM.R
# Script for processing point clouds from UAV-derived models to create a DTM
# Dependencies: Ensure GDAL is installed, and 'terra', 'sf', 'lidR' packages are installed.

# Setup -------------------------------------------------------------------
# Check and install dependencies
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

install_if_missing("sf")
install_if_missing("terra")
install_if_missing("lidR")

# Load libraries
library(sf)
library(terra)
library(lidR)

# Customize -------------------------------------------------------------------
# Set file path and working directory for las catalogue (here, 'tiles'). Adjust as needed.
las_path <- "set path"
tile_dest <- paste0(las_path, "/Tiles/")
output_dest <- paste0(las_path, "processed/")
warning_log <- paste0(las_path, "warning_log.txt")

setwd(las_path)

# Load LAS Catalog -------------------------------------------------------------------
las_catalog <- readLAScatalog(tile_dest)

# Set global catalog options
opt_chunk_buffer(las_catalog) <- 15
opt_independent_files(las_catalog) <- TRUE
opt_output_files(las_catalog) <- paste0(output_dest, "{XLEFT}_{YBOTTOM}_dtm")

# Process and create DTM -------------------------------------------------------------------
process_tile <- function(cluster) {
  las <- readLAS(cluster)
  las <- classify_noise(las, sor(k = 10, m = 3))
  las <- filter_duplicates(las)
  las <- classify_ground(las, algorithm = csf())
  las_filtered <- filter_poi(las, Classification == 2)
}

# Apply processing function
catalog_apply(las_catalog, process_tile)

# Verify the output
print("Processing completed.")