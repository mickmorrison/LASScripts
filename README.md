# LAS Scripts

This repository contains scripts for processing point clouds created by the [Archaeology Department at the University of New England, Australia](https://www.une.edu.au/about-une/faculty-of-humanities-arts-social-sciences-and-education/hass/our-departments/department-of-archaeology-classics-and-history)

The scripts aim to speed up, semi-automate and standardise a range of processing workflows, using reproducible methods.

The scripts will run in R, are definitely experimental but the most reliable listed below.

Happy for suggestions, improvements, corrections, and complaints !

## MakeDTM.R

> [MakeDTM.R](https://github.com/mickmorrison/LASScripts/blob/main/MakeDTM.R)

This script will create a DTM from UAV photogrammetry workflows.

It first cleans the point cloud, 

There is an option to decimate the dtm, which is helpful for testing the script on a large las. 

To use this script, first create and export a *.las from Agisoft metashape to your intended working directory.

There is no need to do any processing in Agisoft, though you should optimise the dtm's resolution by processing the and generating the point cloud using 

## MakeLASCatalogue.R
> [MakeLASCatalogue.R](https://github.com/mickmorrison/LASScripts/blob/main/MakeLASCatalogue.R)
This script is designed to be used to prepare a large las file as a las catalogue, and to save to file for next processing steps.

## To do
* Canopy height function and tree analysis script -- can this be tweaked for archaeology?
* A python script for automating the batch processing file for metashape
