


# Make sure your system has gdal installed
# note that 'terra' and 'sf' can be loaded with a manual command, see git pages for install information


install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Check and install dependencies
install_if_missing("sf")
install_if_missing("terra")
install_if_missing("lidR")
install_if_missing("future")


# Load libraries
library(sf)
library(terra)
library(lidR)
library(future)

# Dynamically set the number of cores (adjust if needed)
num_cores <- 4
options(future.globals.maxSize = 1e9) # Set max size of globals if needed

# Set file path for the LAS file
las_path <- "/Users/mickmorrison/Documents/Home and farm/DJI_202307091418_003_jugans/"
file <- "PointCloud.laz"

# Read LAS file
las <- readLAS(paste0(las_path, file))

# Optional: Check for issues in the LArandom_per_voxel()# Optional: Check for issues in the LAS file
issues <- las_check(las)
print(issues)

# Remove duplicate points
nodupes <- filter_duplicates(las)

# Classify ground points using the CSF algorithm with adjusted parameters
groundpts <- classify_ground(nodupes, algorithm = csf(sloop_smooth = TRUE, class_threshold = 0.02))

# Filter LAS for ground points only
ground_points <- filter_poi(nodupes, Classification == 2)

# Create a Digital Terrain Model (DTM) using KNN interpolation
dtm <- grid_terrain(ground_points, res = 0.1, algorithm = knnidw(k = 10, p = 2))

# Plot the DTM to visualize the terrain
plot(dtm, main = "Digital Terrain Model")

# Save the DTM as a GeoTIFF file
writeRaster(dtm, filename = paste0(las_path, "/dtm.tiff"), format = "GTiff", overwrite = TRUE)
