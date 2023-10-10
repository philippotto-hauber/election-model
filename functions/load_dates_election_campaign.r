load_dates_election_campaign <- function(scenario, year = 2024) {

    if (year == 2024){
        rawdat <- read.csv(here::here("data", "dataland_polls_2024_scenarios.csv"), stringsAsFactors = FALSE)
        rawdata <- rawdat[rawdat$scenario == scenario, ]
    } else {
        rawdat <- read.csv(here::here("data", "dataland_polls_1984_2023.csv"), stringsAsFactors = FALSE)
    }
    start_campaign <- min(as.Date(rawdat$date_published))
    end_campaign <- load_election_day(year = year)
    dates_campaign <- seq(start_campaign, end_campaign, by = "1 day")
    dates_campaign
}