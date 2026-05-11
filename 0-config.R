#-----------------
# 0-config
#
# Objective: set up file paths and load libraries for Nigeria ILC
#-----------------

rm(list=ls())

#------------------------
# load required libraries
#
#------------------------
#install.packages('rsurveycto')

packages <- c(#"rsurveycto",
  "haven",
  "data.table", 
  "stringdist",
  "here", 
  "plyr", 
  "lubridate", 
  "dplyr",
  "knitr", 
  "kableExtra", 
  "tidyr",
  "readr",
  #"flextable",
  "googlesheets4", 
  "officer",
  "openxlsx",
  "tidyverse", 
  "fs",
  "readxl",
  "tibble",
  "foreign",
  "tibble",
  "foreign",
  "scales",
  "grid",
  "RColorBrewer",
  "FactoMineR",
  "stringr",
  "magick",
  "tesseract",
  "qrcode",
  "grid",
  "gridExtra",
  "png",
  "ggplot2",
  "dplyr",
  "gridtext",
  "geosphere",
  "glue"
)

#Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

#Packages loading
invisible(lapply(packages, library, character.only = TRUE))


# load base functions
# source(paste0(here::here(),"/0-base-functions.R"))

#------------------------
# define user paths
#------------------------
# Instructions: always open this project from the .Rproj file in your local repo. 
#   This sets up your working directory to be the local repo. If you don't, you 
#   can run the github path script below.

# Box path
boxpath <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  user <- Sys.info()["user"]
  if (user == "jerem"){
    path = "C:/Users/jerem/Box/Nigeria ILC (GiveWell 2025-2028)" #windows file path example
  } 
  else if (user == "kennedybrown"){
    path = "~/Library/CloudStorage/Box-Box/Nigeria ILC (GiveWell 2025-2028)" #Mac file path example
  }
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  stopifnot(file.exists(path))
  return(path)
}

#------------------------
# define main study data paths
#------------------------
# current data download
datadir = paste0(boxpath(), "/data/1-raw data/current")
media_folder <- paste0(datadir, "/media")
deidentified <- paste0(boxpath(), "/data/2-deidentified")



# define output folder paths
#------------------------
casepath = paste0(boxpath(), "/data/6-case management")


#------------------------
# old paths
# #------------------------



