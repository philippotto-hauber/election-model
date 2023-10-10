load_election_day <- function(path = here::here("data", "dataland_electoral_calendar.csv"), 
                              year = 2024){
  dat <- read.csv(path)
  return(as.Date(dat[dat$election_cycle == year, "election_day"]))
}