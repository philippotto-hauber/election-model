# function to the names of the pollsters
# output is sorted alphabetically
# # same pollsters in 2024 as in 1984-2023 -> load from 2024 csv as it's smaller!
load_pollsters <- function(path = here::here("data", "dataland_polls_2024_scenarios.csv")){
    dat <- read.csv(path)
    pollsters <- sort(unique(dat$pollster))
    pollsters
}