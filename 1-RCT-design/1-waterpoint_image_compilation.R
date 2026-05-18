# waterpoint image organization
# Date: 05/11/2026
# Author: Kennedy Brown
#----------------

library(here)
library(magick)
library(DT)
source(paste0(here::here(),"/0-config.R"))

#Reference media folders:
#scoping_emedia 
#scoping_nemedia  

dta_un <- read_excel(scoping_nedta)
dta_en<- read_excel(scoping_edta)

dta_all <- read_excel(clean_merged_dta) %>% 
  rename(encoded_picture = water_point_picture) %>% 
  left_join(dta_un %>% select(wp_id,water_point_picture), by=("wp_id")) %>% 
  left_join(dta_en %>% select(wp_id,water_point_picture), by=("wp_id")) %>% 
  mutate(
    water_point_picture = coalesce(water_point_picture.x, water_point_picture.y),
    new_photo_filename   = ifelse(!is.na(water_point_picture), paste0(wp_id_new, ".jpg"), NA)
  ) %>% select(wp_id_new, state, ward, community, enumerator, water_pt_type, water_point_picture, new_photo_filename, water_pt_name, water_pt_location, water_pt_identifiers, -water_point_picture.x, -water_point_picture.y)


dta <- dta_all %>% 
  mutate(
    state= as.character(state),
    ward = as.character(ward),
    community = as.character(community)) %>% 
  left_join (communities, by = c("state", "ward", "community")) %>% 
  filter(!is.na(sha_upgrade_status)) #use as proxy to select only selected baseline facilities by using variable present in selected community data
# ----------------------------------
# WATER POINT IMAGE SUMMARY
# ----------------------------------

wp_image_state <- dta %>% 
  group_by(state) %>% 
  summarise(
    missing_images = sum(is.na(water_point_picture)),
    image_present = sum(!is.na(water_point_picture)),
    total_waterpoints = n()
  )

wp_image_ward <- dta %>% 
  group_by(ward) %>% 
  summarise(
    missing_images = sum(is.na(water_point_picture)),
    image_present = sum(!is.na(water_point_picture)),
    total_waterpoints = n()
  )

wp_image_community <- dta %>% 
  group_by(community) %>% 
  summarise(
    missing_images = sum(is.na(water_point_picture)),
    image_present = sum(!is.na(water_point_picture)),
    total_waterpoints = n()
  )

wp_image_enumerator <- dta %>% 
  group_by(enumerator) %>% 
  summarise(
    missing_images = sum(is.na(water_point_picture)),
    image_present = sum(!is.na(water_point_picture)),
    total_waterpoints = n()
  )

# wp_type_ward <- dta %>% 
#   group_by(ward) %>% 
#   summarise( 
#     HP = sum(water_pt_type == "HP"),
#     MB = 
      
  wp_type_ward <- dta %>% 
  count(community, water_pt_type) %>% 
  pivot_wider(names_from = water_pt_type, values_from = n, values_fill = 0)

# I already ran this and just want to comment it out for now
# It takes about 30-45 minutes to run, if needed to recompile we can 
# un comment this

# # ----------------------------------
# # MEDIA FILE ORGANIZATION
# # ----------------------------------
#  output<- file.path(clean, "Media")
# 
#  #Create a media folder
#  if (!dir.exists(output)) {
#    dir.create(output, recursive = TRUE)}
# 
#  # Loop over each row and file into state/ward/community/type folders
#  walk(1:nrow(dta), function(i) {
#    row <- dta[i, ]
# 
#    # Build nested folder path
#    folder <- file.path(
#      output,
#      row$state,
#      row$community
#    )
# 
#    # Create folder if it doesn't exist
#    if (!dir.exists(folder)) dir.create(folder, recursive = TRUE)
# 
#    # Strip leading "media/" or "media\" at the start
#    photo_file <- sub("^media[\\\\/]", "", row$water_point_picture)
# 
#    # Skip if no image
#    if (is.na(photo_file) || photo_file == "") return(NULL)
# 
# 
# 
#   src_1 <- file.path(scoping_emedia, photo_file)
#   src_2 <- file.path(scoping_nemedia, photo_file)
# 
#   #Combine both file sources
#   src <- if (file.exists(src_1)) {
#     src_1
#   } else if (file.exists(src_2)) {
#     src_2
#   } else {
#     warning(paste("File not found in either source:", row$water_point_picture))
#     return(NULL)
#   }
# 
# 
#   # Rename to wp_id_new, preserving original file extension
#   ext <- tools::file_ext(photo_file)
#   new_filename <- paste0(row$wp_id_new, ".", ext)
#   dst <- file.path(folder, new_filename)
# 
#   # Copy if source file exists
#   file.copy(src, dst, overwrite = TRUE)
# })


  # ----------------------------------
  # SOURCE ID ORGANIZATION FOR SURVEY
  # ----------------------------------
 output<- file.path(baseline_survey, "SourceID_Media")

#Create a media folder
if (!dir.exists(output)) {
  dir.create(output, recursive = TRUE)}

# # Loop over each row and file into state/ward/community/type folders
walk(1:nrow(dta), function(i) {
  row <- dta[i, ]

#  # Strip leading "media/" or "media\" at the start
   photo_file <- sub("^media[\\\\/]", "", row$water_point_picture)

   # Skip if no image
   if (is.na(photo_file) || photo_file == "") return(NULL)

   src_1 <- file.path(scoping_emedia, photo_file)
   src_2 <- file.path(scoping_nemedia, photo_file)

   #Combine both file sources
 src <- if (file.exists(src_1)) {
   src_1
  } else if (file.exists(src_2)) {
    src_2
  } else {
   warning(paste("File not found in either source:", row$water_point_picture))
   return(NULL)   }

# Rename to wp_id_new, converting to jpg if needed
ext <- tools::file_ext(photo_file)
new_filename <- paste0(row$wp_id_new, ".jpg")
dst <- file.path(output, new_filename)

if (tolower(ext) == "jpg" || tolower(ext) == "jpeg") {
  # Already jpg, just copy
  file.copy(src, dst, overwrite = TRUE)
} else {
  # Convert to jpg using magick
  image_read(src) %>%
    image_write(dst, format = "jpg")
}})



source_id_summary <- dta %>% 
  mutate(
    list_name = "source_id",
    value = wp_id_new,
    label = paste0(
      if_else(!is.na(water_pt_name),        paste0("Name: ", water_pt_name, ", "), ""),
      if_else(!is.na(water_pt_location),    paste0("Location: ", water_pt_location, ", "), ""),
      if_else(!is.na(water_pt_identifiers), paste0("Identifier: ", water_pt_identifiers, ", "), ""),
      wp_id_new
    ),
    label_hausa = "",
    label_pidgin = "",
    filter = community,
    media_image = new_photo_filename
  ) %>% 
  select(list_name, value, label, label_hausa, label_pidgin, filter, media_image)

file_name <- file.path(baseline_survey, paste0("SourceID_Master.xlsx"))
writexl::write_xlsx(source_id_summary, path = file_name)
