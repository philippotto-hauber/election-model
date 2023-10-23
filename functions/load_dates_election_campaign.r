load_dates_election_campaign <- function(year = 2024) {
    if (year == 2024){
        rawdat <- read.csv(here::here("data", "dataland_polls_2024_scenarios.csv"), stringsAsFactors = FALSE)
    } else {
        rawdat <- read.csv(
            here::here(
                "data", 
                "dataland_polls_1984_2023.csv"),
            stringsAsFactors = FALSE)
        rawdat <- filter(rawdat, year == !!year)
    }
    # start of campaign = earliest poll -> assume same start in all scenarios
    start_campaign <- min(as.Date(rawdat$date_conducted))
    end_campaign <- load_election_day(year = year)
    dates_campaign <- seq(start_campaign, end_campaign, by = "1 day")
    dates_campaign
}