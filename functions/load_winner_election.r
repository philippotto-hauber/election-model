load_winner_election <- function(year) {
    dat <- read.csv(
        here::here(
            "data",
            "dataland_election_results_1984_2023.csv"        
        )
    )
    winner_election <- dat[dat$year == year, "national_winner"]
    return(toupper(winner_election))
}