## agents
library(tidyverse)

#setup WBA
WBA_agent <- function(w_direct, w_social, first_rating, group_rating){
  
  #get length for determining number of draws alter
  n <- length(first_rating)
  
  #calc alpha and beta values to feed to beta dist 
  alpha = 0.5 + w_direct * first_rating + w_social * group_rating
  
  beta  = 0.5 + w_direct * (7-first_rating) + w_social * (7-group_rating)
  
  #draw a rate
  rate <- rbeta(n, alpha, beta)
  
  #turn rate into a choice
  choice <- rbinom(n, size=7, rate)
  
  choice
}

#setup PBA agent
PBA_agent <- function(p, first_rating, group_rating){
  
  #get length for determining number of draws alter
  n <- length(first_rating)
  
  #calc alpha and beta values to feed to beta dist 
  alpha = 0.5 + p * first_rating + (1-p) * group_rating
  
  beta  = 0.5 + p * (7-first_rating) + (1-p) * (7-group_rating)
  
  #draw a rate
  rate <- rbeta(n, alpha, beta)
  
  #turn rate into a choice
  choice <- rbinom(n, size=7, rate)
  
  choice
}

## simulate scenarios
set.seed(1)

scenarios = list(
  list(name = "1", w1 = 1, w2 = 1), 
  list(name = "2", w1 = .8, w2 = 2), 
  list(name = "3", w1 = .6, w2 = .4), 
  list(name = "4", w1 = .5, w2 = .1))

#manual for scen 5
p = .7

#create evidence df
source("sim_1st_and_group_rating.R")

#make ouput folder if doesn't exist
out_dir <- "scenario_data"
if (!dir.exists(out_dir)) {
  dir.create(out_dir)
}

#loop over scenarios and make dfs
for (scenario in scenarios) {
  
  #get weights
  w_first = scenario$w1
  w_group = scenario$w2
  
  #get name
  scenario_name = scenario$name
  
  # update dataframe
  choice_df <- evidence_df %>% 
    mutate(second_rating = WBA_agent(w_first, w_group, first_ratings, group_ratings),
           w_first = w_first,
           w_group = w_group)
  
  #check if NAs were produced
  if (sum(is.na.data.frame(choice_df)) > 0) {
    cat("NAs in dataframe for sceneario", sceneario_name)}
  
  #construct file name
  csv_file_name <- paste0(
    out_dir, "/",
    "scenario_", scenario_name,
    ".csv")
  
  #save
  write_csv(choice_df, csv_file_name)
}

###### do manual PBA_agent df
#get name
scenario_name = "5"

# update dataframe
choice_df <- evidence_df %>% 
  mutate(second_rating = PBA_agent(p, first_ratings, group_ratings),
         p = p)

#check if NAs were produced
if (sum(is.na.data.frame(choice_df)) > 0) {
  cat("NAs in dataframe for sceneario", sceneario_name)}

#construct file name
csv_file_name <- paste0(
  out_dir, "/",
  "scenario_", scenario_name,
  ".csv")

#save
write_csv(choice_df, csv_file_name)