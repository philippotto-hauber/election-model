load_electoral_votes <- function(path = here::here("data", "dataland_demographics.csv")) {
    dat <- read.csv(path)
    states_regions <- load_dataland_states_regions()
    # merge with dat to preserve order of states!
    states_regions <- dplyr::inner_join(states_regions, dat,
        by = dplyr::join_by(
            region == region,
            state == province
        )
    )
    electoral_votes <- states_regions$electoral_college_votes
    names(electoral_votes) <- states_regions$state
    electoral_votes
}
