# waterpoint ID edit
# Date: 05/11/2026
# Author: Kennedy Brown
#----------------

library(here)
library(magick)
library(DT)
source(paste0(here::here(),"/0-config.R"))

dta_en <- read_excel(scoping_edta)
dta_un <- read_excel(scoping_nedta)

id_en <- dta_en %>% 
  select(state, community, water_pt_type, wp_id) %>%
  mutate(wp_id_type = paste0(state,community, "-", water_pt_type,"-")) %>% 
  group_by(wp_id_type) %>% 
  mutate(idx = row_number(),
         wp_id_new= paste0(wp_id_type, idx)) %>% 
  select(-idx)

  
id_un <- dta_un %>% 
  select(state, community, water_pt_type, wp_id) %>%
  mutate(wp_id_type = paste0(state,community, "-", water_pt_type,"-")) %>% 
  group_by(wp_id_type) %>% 
  mutate(idx = row_number(),
         wp_id_new= paste0(wp_id_type, idx)) %>% 
  select(-idx)
