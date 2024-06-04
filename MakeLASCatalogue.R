# LAS Catalogue Tool
# This script processes very large LAS files and creates a LAS catalogue, using the functions of the LIDR package for working with cats.
# Mick Morrison and OpenAI 

# Setup -------------------------------------------------------------------
# Function to check if a package is installed, and install it if missing
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Check and install dependencies
install_if_missing("sf")
install_if_missing("lidR")

# Load libraries
library(sf)
library(lidR)

# Customise -------------------------------------------------------------------
# Set file path and working directory. Change to suit your project.
las_path <- ""
file <- "PointCloud.laz"

setwd(las_path)

# Read LAS -------------------------------------------------------------------
# Read and check the LAS file
las_raw <- readLAS(paste0(las_path, file))
las_raw

# Step 1: Read the large LAS file
large_las <- readLAS(las_path)

# Step 2: Split the large LAS file into smaller tiles
# Define the size of the tiles (e.g., 1000x1000 meters)
tile_size <- 1000

# Create a grid for tiling
extent_las <- st_bbox(large_las)
x_coords <- seq(extent_las[1], extent_las[3], by = tile_size)
y_coords <- seq(extent_las[2], extent_las[4], by = tile_size)

# Function to clip and save each tile
save_tile <- function(xmin, xmax, ymin, ymax) {
  # Define the extent of the tile
  tile_extent <- extent(xmin, xmax, ymin, ymax)
  
  # Clip the LAS file to the tile extent
  tile_las <- clip_rectangle(large_las, xmin, ymin, xmax, ymax)
  
  # Define the filename for the tile
  tile_filename <- paste0("tile_", xmin, "_", ymin, ".las")
  
  # Write the tile to disk
  writeLAS(tile_las, tile_filename)
}

# Step 3: Loop through each tile extent and save the tiles
for (x in x_coords[-length(x_coords)]) {
  for (y in y_coords[-length(y_coords)]) {
    save_tile(x, x + tile_size, y, y + tile_size)
  }
}

# Step 4: Create a LAS catalog from the smaller tiles
# Define the directory where the tiles are saved
tile_dest <- paste0(las_path, "Tiles/")
tiles_directory <- "path_to_tiles_directory"

# Create a LAS catalog
las_catalog <- readLAScatalog(tiles_directory)

# Optional: Print the summary of the LAS catalog
print(las_catalog)