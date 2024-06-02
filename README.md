# LAS Scripts

This repository contains scripts for processing lidar and lidar-like files, particularly point clouds (PtC) used in the UNE Archaeology Lab at the University of New England.

Their purpose is to speed up the processing workflows, and to largely automate these using reproducible methods.

The scripts will run in R, are mostly experimental at this stage and I will list those that are functional here.

Happy for suggestions, improvements, corrections, complaints !

## MakeDEM.R

> [MakeDEM.R](https://github.com/mickmorrison/LASScripts/blob/main/MakeDEM.R)

This script will create a DTM from UAV photogrammetry workflows.

It first cleans the point

To use this script, first create and export a PtC with Agisoft metashape, shape, outputting a las file to your intended working directory.

There is no need to do any processing in Agisoft other than ensuring the PtC has been correctly created.
