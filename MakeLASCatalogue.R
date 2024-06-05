# LAS Catalogue Tool
# This script processes very large LAS files and creates a LAS catalogue, using the functions of the lidR package for working with cats.
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
las_path <- "path_to_las_files" # Update with your path
file <- "PointCloud.laz"

setwd(las_path)

# Read LAS -------------------------------------------------------------------
# Read and check the LAS file
las_raw <- readLAS(paste0(las_path, "/", file))
if (is.null(las_raw)) {
  stop("Error reading LAS file")
}
print(las_raw)

# Step 1: Read the large LAS file
large_las <- readLAS(paste0(las_path, "/", file))
if (is.null(large_las)) {
  stop("Error reading large LAS file")
}

# Step 2: Split the large LAS file into smaller tiles
# Define the size of the tiles (e.g., 1000x1000 meters)
tile_size <- 100

# Create a grid for tiling
extent_las <- st_bbox(large_las)
x_coords <- seq(extent_las["xmin"], extent_las["xmax"], by = tile_size)
y_coords <- seq(extent_las["ymin"], extent_las["ymax"], by = tile_size)

# Function to clip and save each tile
save_tile <- function(xmin, xmax, ymin, ymax) {
  # Clip the LAS file to the tile extent
  tile_las <- clip_rectangle(large_las, xmin, ymin, xmax, ymax)
  
  if (is.null(tile_las) || npoints(tile_las) == 0) {
    warning(paste("No data in tile:", xmin, xmax, ymin, ymax))
    return(NULL)
  }
  
  # Define the filename for the tile
  tile_filename <- paste0(las_path, "/Tiles/tile_", xmin, "_", ymin, ".las")
  
  # Write the tile to disk
  writeLAS(tile_las, tile_filename)
}

# Create the output directory if it doesn't exist
if (!dir.exists(paste0(las_path, "/Tiles"))) {
  dir.create(paste0(las_path, "/Tiles"))
}

# Step 3: Loop through each tile extent and save the tiles
for (x in x_coords[-length(x_coords)]) {
  for (y in y_coords[-length(y_coords)]) {
    save_tile(x, x + tile_size, y, y + tile_size)
  }
}

# Step 4: Create a LAS catalog from the smaller tiles
# Define the directory where the tiles are saved
tile_dest <- paste0(las_path, "/Tiles/")
tiles_directory <- tile_dest

# Create a LAS catalog
las_catalog <- readLAScatalog(tiles_directory)

# Optional: Print the summary of the LAS catalog
print(las_catalog)
plot(las_catalog)
