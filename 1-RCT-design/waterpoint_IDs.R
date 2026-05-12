# waterpoint ID edit
# Date: 05/11/2026
# Author: Kennedy Brown
# This script generates unique water point ID's based on the state, community
# waterpoint type, and number. This is output to the merged CLEAN dataset
#----------------

library(here)
library(magick)
library(DT)
source(paste0(here::here(),"/0-config.R"))

unencyrpt <- read_excel(scoping_nedta)
encrypt <- read_excel(scoping_edta)

dta <- read_dta(old_merged_dta)

dta<- dta %>% 
  mutate(wp_id_type = paste0(state,community, "-", water_pt_type,"-")) %>% 
  group_by(community) %>% 
  mutate(idx = row_number(),
         wp_id_new= paste0(wp_id_type, idx)) %>% 
  select(-idx) %>% 
  arrange(community) 

output<- file.path(clean)
file_name <- file.path(output, paste0("MergedData_CLEAN.xlsx"))
writexl::write_xlsx(dta, path = file_name)
