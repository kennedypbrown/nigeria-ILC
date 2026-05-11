#----------------
# Review of handpump collection data from field work

# Date: 3/4/2026
# Author: Kennedy Brown
#----------------

library(here)
library(magick)
library(DT)


#install.packages("writexl")
library(writexl)  
source(paste0(here::here(),"/0-config.R"))

#Accessing the most recent hp data
dta <- "~/Library/CloudStorage/Box-Box/Nigeria ILC (GiveWell 2025-2028)/Scoping/Data:analysis/Raw_data"
files1 <- list.files(path = dta, 
                     pattern = "ILC Scoping Waterpoint Survey_WIDE", 
                     full.names = TRUE)

files <- files1[!grepl("~\\$", files1)]
dt_path <- files[which.max(file.info(files)$mtime)]
survey = read.csv(dt_path)

hp1 <- survey %>% 
  select(date, state, functional, water_pt_type, wp_id, water_source_users, breakdowns, 271:292) %>% 
  filter(water_pt_type == "HP") %>% 
  rename_with(~ gsub("_afidev$", "_afridev", .x)) 

hp_all <- hp1 %>% 
  summarise(
    total_surveys = n(),
    india_mark    = sum(handpump_type == 2, na.rm = TRUE),
    afridev       = sum(handpump_type == 1, na.rm = TRUE),
    other         = sum(handpump_type == -96, na.rm = TRUE),
    unknown       = sum(handpump_type == -99, na.rm = TRUE) 
  )

hp<-hp1 %>% 
  filter(can_measure == 1) 

indiamark <- hp %>% 
  filter(handpump_type == 2) %>%
  filter(stack_height_im != 0) %>%    #manually removing this one
  mutate(
    circumference_3_im = case_when(
      wp_id == "K48-HP-111234" ~ NA_real_,
      TRUE ~ circumference_3_im
    )
  )

im_specs <-indiamark %>% 
  select(contains("im")) %>% 
  rename_with(~ gsub("_im$", "", .x)) %>% 
  mutate(
    diameter1 = circumference_1 / pi,
    diameter2 = circumference_2 / pi,
    diameter3 = circumference_3 / pi) #%>%
# pivot_longer(cols=everything(),
#              names_to="parameters_cm",
#              values_to="value") %>% 
# group_by(parameters_cm) %>% 
# summarise(
#   avg = mean(value, na.rm = TRUE),
#   min = min(value, na.rm = TRUE),
#   max = max(value, na.rm = TRUE),
#   std = sd(value, na.rm = TRUE)) %>% 
# mutate(across(where(is.numeric), ~ round(.x, 2)))

afridev <- hp %>% 
  filter(handpump_type == 1)

afd_specs <-afridev %>% 
  select(contains("dev")) %>% 
  rename_with(~ gsub("_afridev$", "", .x)) %>% 
  mutate(
    diameter1 = circumference_1 / pi,
    diameter2 = circumference_2 / pi,
    diameter3 = circumference_3 / pi) #%>% 

specs <- im_specs %>%
  select(-contains("body")) %>% 
  rbind(afd_specs %>%  select(-contains("body"))) %>% 
  pivot_longer(cols=everything(),
               names_to="parameters_cm",
               values_to="value") %>%
  group_by(parameters_cm) %>%
  summarise(
    avg = mean(value, na.rm = TRUE),
    min = min(value, na.rm = TRUE),
    max = max(value, na.rm = TRUE),
    median = median(value, na.rm = TRUE),
    std = sd(value, na.rm = TRUE)) %>%
  mutate(across(where(is.numeric), ~ round(.x, 2)))

