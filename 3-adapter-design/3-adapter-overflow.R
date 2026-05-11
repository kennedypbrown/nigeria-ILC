#----------------
# TuriPump Adapter Data
# Date: 4/23/2026
# Author: Kennedy Brown
#----------------

library(here)
library(magick)
library(DT)


#install.packages("writexl")
library(writexl)  
source(paste0(here::here(),"/0-config.R"))

handpump = "/Users/kennedybrown/Library/CloudStorage/Box-Box/Venturi_Design/TuriTap_Handpump_Adaptation"
testing <- paste0(handpump, "/Design and Testing/Testing Results")
test1 <-paste0(testing, "/TuriPump_03192026.xlsx")
test1= read_xlsx(test1, sheet = 2)

test2 <-paste0(testing, "/TuriPump_04162026.xlsx")
test2= read_xlsx(test2, sheet = 2)


data1<-test1 %>% 
  rename( date = `Test Date`, 
          overflow = `Overflow? (Y/N)`,
          adapter = `Adapter ID`,
          bpm = `Metronome (BPM)`,
          pump_time = `Total Time Pumped (s)`,
          flow_rate_Ls = `Flow Rate (L/S)`) %>% 
  mutate(
    overflow = case_when(overflow == "Y"~TRUE, .default= FALSE),
    adapter = as.factor(adapter),
    flow_rate_Ls = as.numeric(flow_rate_Ls),
    adapter = case_when(
      adapter == "C3" ~ "Concentric 3",
      adapter == "C5" ~ "Concentric 5",
      adapter == "C7" ~ "Concentric 7",
      adapter == "E3" ~ "Eccentric 3",
      adapter == "E5" ~ "Eccentric 5",
      adapter == "E7" ~ "Eccentric 7",
      .default = adapter
    )
  ) %>% 
  filter(adapter != "Old")


paired_colors <- c(
  "Concentric 3"     = "skyblue", 
  "Concentric 5"     = "steelblue",  
  "Concentric 7"    = "navy",  
  "Eccentric 3"    = "pink",  
  "Eccentric 5"    = "hotpink",  
  "Eccentric 7"    = "hotpink4",
  "Eccentric - Sig" = "red"
)


ggplot(data1, aes(x = bpm, y = flow_rate_Ls, color = adapter)) +
  geom_point(
    size = 3,
    shape = 21,
    stroke = 1,
    aes(fill = ifelse(overflow, as.character(adapter), NA))
  ) +
  geom_hline(yintercept = 0.27, linetype = "dashed", color = "gray40")+
  scale_color_manual(values = paired_colors, name = "Adapter ID")+
  scale_fill_manual(values = paired_colors, name = "Adapter ID", na.value = NA, guide="none")+
  scale_y_continuous(
    breaks = seq(0.15, 0.35, by = 0.05),   
    limits = c(0.15, 0.35),
    expand=c(0,0))+
  scale_x_continuous(
    breaks = seq(90, 180, by = 20), 
    limits = c(85, 180),                      
    expand = c(0, 0)  
  ) +
  labs(
    x = "Metronome (BPM)",
    y = "Flow Rate (L/s)",
    title = "03/19/2026- Performance of Eccentric and Concentric Adapters",
    caption = "Filled in points mean the system experienced overflow during a 20s pumping cycle"
  ) +
  theme_minimal()



data2<-test2 %>% 
  rename( date = `Test Date`, 
          overflow = `Overflow? (Y/N)`,
          adapter = `Adapter ID`,
          bpm = `Metronome (BPM)`,
          pump_time = `Total Time Pumped (s)`,
          flow_rate_Ls = `Flow Rate (L/S)`) %>% 
  mutate(
    overflow = case_when(overflow == "Yes"~TRUE, .default= FALSE),
    adapter = as.factor(adapter),
    flow_rate_Ls = as.numeric(flow_rate_Ls),
    adapter = case_when(
      adapter == "Concentric" ~ "Concentric 5",
      .default = adapter
    )
  ) %>% 
  filter(adapter != "Eccentric No Extension" & adapter != "REGULAR PUMP")



ggplot(data2, aes(x = bpm, y = flow_rate_Ls, color = adapter, shape = Pumper)) +
  geom_point(
    size = 3,
    stroke = 1,
    aes(fill = ifelse(overflow, as.character(adapter), NA))
  ) +
  geom_hline(yintercept = 0.27, linetype = "dashed", color = "gray40")+
  scale_color_manual(values = paired_colors, name = "Adapter ID")+
  scale_fill_manual(values = paired_colors, name = "Adapter ID", na.value = NA, guide="none")+
  scale_shape_manual(values = c(21, 22, 23, 24, 25), name = "Pumper") +
  scale_y_continuous(
    breaks = seq(0.22, 0.34, by = 0.02),   
    limits = c(0.22, 0.33),
    expand=c(0,0))+
  scale_x_continuous(
    breaks = seq(120, 180, by = 20), 
    limits = c(115, 185),                      
    expand = c(0, 0)  
  ) +
  labs(
    x = "Metronome (BPM)",
    y = "Flow Rate (L/s)",
    title = "04/16/2026- Performance of Eccentric and Concentric Adapters",
    caption = "Filled in points mean the system experienced overflow during a 30s pumping cycle"
  ) +
  theme_minimal()


data_all <- data1 %>% 
  select(-`Wastage time (s)`) %>% 
  rbind(data2 %>% select(-`Time to Overflow (s)`,-Pumper))



ggplot(data_all, aes(x = bpm, y = flow_rate_Ls, color = adapter)) +
  geom_point(
    size = 3,
    shape = 21,
    stroke = 1,
    aes(fill = ifelse(overflow, as.character(adapter), NA))
  ) +
  geom_hline(yintercept = 0.27, linetype = "dashed", color = "gray40")+
  scale_color_manual(values = paired_colors, name = "Adapter ID")+
  scale_fill_manual(values = paired_colors, name = "Adapter ID", na.value = NA, guide="none")+
  scale_y_continuous(
    breaks = seq(0.20, 0.35, by = 0.05),   
    limits = c(0.20, 0.35),
    expand=c(0,0))+
  scale_x_continuous(
    breaks = seq(120, 180, by = 20), 
    limits = c(115, 185),                      
    expand = c(0, 0)  
  ) +
  labs(
    x = "Metronome (BPM)",
    y = "Flow Rate (L/s)",
    title = "ALL- Performance of Eccentric and Concentric Adapters",
    caption = "Filled in points mean the system experienced overflow during the 20 or 30s pumping cycle"
  ) +
  theme_minimal()

overflow<- data_all %>% 
  group_by(overflow, adapter) %>% 
  summarise(max_flow = round(max(flow_rate_Ls, na.rm = TRUE), 3)) %>% 
  pivot_wider(
    names_from = overflow,
    values_from = max_flow,
    values_fill = 0
  ) %>% 
  rename("No Overflow"= "FALSE",
         "Overflow" = "TRUE") %>% 
  mutate(Overflow = case_when(Overflow == 0 ~ NA_integer_, .default = Overflow ))

view(overflow)
