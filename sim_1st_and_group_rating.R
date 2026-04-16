pacman::p_load(tidyverse)

set.seed(1)

## make dataframe for 1st and second group
n_trials = 153

#gen first ratings from 1-8
first_ratings <- sample(c(0, 1,2,3,4,5,6,7), size = n_trials, replace = T)

#sample -3 : +3 adjustments
group_adjustments <- sample(c(-3,-2,-1,0,1,2,3), size = n_trials, replace = T)

#use adjustments to generate group ratings
group_ratings <- first_ratings + group_adjustments

#cut group ratings below 1
group_ratings <- pmax(group_ratings, 0)

#cut group ratings above 8
group_ratings <- pmin(group_ratings, 7)

evidence_df <- tibble(trial_id = c(1:n_trials), first_ratings, group_ratings)



