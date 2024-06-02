# MakeDTM.R
# Simple script for processing point clouds generated from UAV-derived models
# Mick Morrison, R packages lidR, terra, sf. Full credit to package authors
# DEPENDENCIES: Make sure your system has GDAL installed. 
# 'terra' and 'sf' packages load best from the respective git repos, see GitHub for install information.
# Plot functions do not always work for the LAS files; this developing package is useful: https://github.com/Jean-Romain/lidRviewer
# Manual installation of xquartz seems to help

# Setup -------------------------------------------------------------------
# Function to check if a package is installed, and install it if missing
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Check and install dependencies
install_if_missing("sf")
install_if_missing("terra")
install_if_missing("lidR")
install_if_missing("rgl")

# Load libraries
library(sf)
library(terra)
library(lidR)
library(rgl)

# Customise -------------------------------------------------------------------
# Set file path and working directory. Change to suit your project.
las_path <- "/Users/mickmorrison/Documents/Home and farm/DJI_202307091418_003_jugans/"
file <- "PointCloud.laz"

setwd(las_path)

# Read LAS -------------------------------------------------------------------
# Read and check the LAS file
las_raw <- readLAS(paste0(las_path, file))
las_raw

# Check for issues in the LAS file. Uncomment on first run
#issues <- las_check(las)
#print(issues)

# Decimate function for testing the script. Comment out to run script over the whole LAS.
# Uncomment and set to the percentage of points to retain (e.g., 0.1 for 10%)
las <- decimate_points(las_raw, random(0.25))
las

# Clean, Classify, and Normalize Points -------------------------------------------------------------------
# Classify noise using Statistical Outlier Removal (SOR)
las <- classify_noise(las, sor(k = 10, m = 3))
las

# rm duplicate points rm junk
las <- filter_duplicates(las)
las

# Open rgl device and plot denoised and deduped LAS file
rgl::close3d()
rgl::open3d()
plot(las, size = "2", bkg = "black", color = "RGB", backend = "rgl")
rglwidget()

# Classify ground using Cloth Simulation Function (CSF)
las <- classify_ground(las, algorithm = csf())

# Filter LAS for ground points only, excluding noise (classification 18)
las_filtered <- filter_poi(las, Classification == 2 & Classification != 18)

# View the results
plot(las_filtered, size = "3", bkg = "black", color = "RGB", backend = "rgl")
rglwidget()

# Set the viewing position
rgl::view3d(fov = 1, zoom = 0.6, userMatrix = rgl::rotationMatrix(pi/4, 1, 0, 0))
rglwidget()

# Create and Save DTM -------------------------------------------------------------------
# Create a Digital Terrain Model (DTM) using K nearest neighbor and inverse-distance weighting interpolation (default settings: k=10 NN, IDW power=2)
dtm <- grid_terrain(las_filtered, res = 0.1, algorithm = knnidw(k = 10, p = 2))

plot(dtm)
