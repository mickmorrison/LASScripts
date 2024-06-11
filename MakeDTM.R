# Experimental MakeDTM.R
# Script for processing point clouds from UAV-derived models to create a Digital Terrain Model (DTM)
# Dependencies: Ensure GDAL is installed, and 'terra', 'sf', 'lidR' packages are installed.

# Setup -------------------------------------------------------------------
# Function to check and install missing dependencies
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Check and install necessary packages
install_if_missing("sf")
install_if_missing("terra")
install_if_missing("lidR")

# Load required libraries
library(sf)
library(terra)
library(lidR)
library(future)

# Customize -------------------------------------------------------------------
# Set file paths and working directory. Adjust these paths as needed.
las_path <- ""
tile_dest <- paste0(las_path, "/Tiles/")
output_dest <- paste0(las_path, "/processed/")
warning_log <- paste0(las_path, "warning_log.txt")

# Ensure the output directory exists
if (!dir.exists(output_dest)) {
  dir.create(output_dest, recursive = TRUE)
}

# Set the working directory
setwd(las_path)

# Load LAS Catalog -------------------------------------------------------------------
# Load LAScatalog from the specified directory
las_catalog <- readLAScatalog(tile_dest)

# Perform a check on the LAS catalog for potential issues
issues <- las_check(las_catalog)
print(issues)

# Set global catalog options
plan(multisession)
opt_chunk_buffer(las_catalog) <- 15  # Set buffer size for processing chunks
opt_independent_files(las_catalog) <- TRUE  # Ensure each file is processed independently
opt_output_files(las_catalog) <- paste0(output_dest, "{XLEFT}_{YBOTTOM}_dtm.tif")  # Set output file naming template

# Process and create DTM -------------------------------------------------------------------
# Function to process each tile in the LAS catalog
process_tile <- function(cluster) {
  # Read LAS data from the cluster
  las <- readLAS(cluster)
  
  # Classify noise in the point cloud data
  las <- classify_noise(las, sor(k = 10, m = 3))
  
  # Filter out duplicate points
  las <- filter_duplicates(las)
  
  # Classify ground points using the CSF algorithm
  las <- classify_ground(las, algorithm = csf())
  
  # Filter to retain only ground points
  las_filtered <- filter_ground(las)
  
  # Remove degenerated ground points by keeping only unique (X, Y) coordinates
  las_filtered <- filter_poi(las_filtered, !duplicated(paste0(las_filtered@data$X, las_filtered@data$Y)))
  
  # Create a DTM using the ground points
  dtm <- grid_terrain(las_filtered, res = 1, algorithm = tin())
  
  # Get the filename for the current cluster's output
  output_filename <- paste0(output_dest, gsub(".las$", "", basename(cluster@files)), "_dtm.tif")
  
  # Check if the file already exists and delete it if it does
  if (file.exists(output_filename)) {
    file.remove(output_filename)
  }
  
  # Write the DTM to a file with overwrite enabled
  writeRaster(dtm, filename = output_filename, format = "GTiff", overwrite = TRUE)
}

# Apply the processing function to each tile in the LAS catalog
catalog_apply(las_catalog, process_tile)

# Merge individual DTMs into a single DTM for the entire area
dtm_files <- list.files(output_dest, pattern = "_dtm.tif$", full.names = TRUE)

# Load the raster files as SpatRasters and merge them
merged_dtm_list <- lapply(dtm_files, rast)
merged_dtm <- do.call(merge, merged_dtm_list)

# Write the merged DTM to a file
writeRaster(merged_dtm, filename = paste0(output_dest, "merged_dtm.tif"), overwrite = TRUE)
