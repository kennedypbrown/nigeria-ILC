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

dta <- read_dta(old_merged_dta) %>% 
  rename(encoded_picture = water_point_picture) %>% 
  left_join(dta_un %>% select(wp_id,water_point_picture), by=("wp_id")) %>% 
  left_join(dta_en %>% select(wp_id,water_point_picture), by=("wp_id")) %>% 
  mutate(
    water_point_picture = coalesce(water_point_picture.x, water_point_picture.y)
  ) %>% 
  select(-water_point_picture.x, -water_point_picture.y)

output<- file.path(clean, "Media")

#Create a media folder
if (!dir.exists(output)) {
  dir.create(output, recursive = TRUE)}

# Loop over each row and file into state/ward/community/type folders
walk(1:nrow(dta), function(i) {
  row <- dta[i, ]
  
  # Build nested folder path
  folder <- file.path(
    output,
    row$state,
    row$ward,
    row$community
  )
  
  # Create folder if it doesn't exist
  if (!dir.exists(folder)) dir.create(folder, recursive = TRUE)
  
  # Strip leading "media/" or "media\" at the start
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
    return(NULL)
  }
  dst <- file.path(folder, basename(row$water_point_picture))
  
  # Copy if source file exists
  dst <- file.path(folder, basename(row$water_point_picture))
  
  
  # Rename to wp_id_new, preserving original file extension
  ext <- tools::file_ext(photo_file)
  new_filename <- paste0(row$wp_id_new, ".", ext)
  dst <- file.path(folder, new_filename)
   
  file.copy(src, dst, overwrite = TRUE)
})






# #Name of image column
# photo_cols <- dta %>% select(water_point_picture)
# #Writing code to organize the images by the state, community, and WP type
# dta_state <- dta %>% 
#   group_by(state) 
# 
#  df_name <- deparse(substitute(df))
#   folder_path <- file.path(base_path, df_name)
#   dir_create(folder_path)
#   
#   
#   for (i in seq_len(nrow(df))) {
#     for (col in photo_cols) {
#       photo_file <- df[[col]][i]
#       if (!is.na(photo_file) && photo_file != "") {
#         local_photo <- file.path(media_folder, sub("^media[\\\\/]", "", photo_file))
#         
#         if (file_exists(local_photo)) {
#           safe_name <- str_replace_all(paste(
#             df$facility_name[i],
#             df$facility_id[i],
#             col, i,
#             basename(local_photo)), "[^A-Za-z0-9_\\.]", "_")
#           
#           file_copy(local_photo, file.path(folder_path, safe_name), overwrite = TRUE)
#         } else {
#           if (grepl("media", photo_file, ignore.case = TRUE)) {
#             # Add to the temporary list
#             current_missing_list[[length(current_missing_list) + 1]] <- data.frame(
#               log_type = df_name, # Added this so you know which log it came from!
#               row_index = i,
#               facility_id = df$facility_id[i],
#               facility_name = df$facility_name[i],
#               upload_date = df$upload_date[i],
#               column_name = col,
#               expected_path = local_photo,
#               stringsAsFactors = FALSE)}
#           warning("File does not exist: ", local_photo)
#         }}}}
#   
#   
#   # Report findings
#   message("Photos for ", df_name, " saved to: ", folder_path)
