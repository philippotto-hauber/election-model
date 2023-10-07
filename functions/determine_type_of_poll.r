determine_type_of_poll <- function(geography, states_regions){
    type_of_poll <- rep(NA, length = length(geography))

    id_nat <- geography == "National"
    type_of_poll[id_nat] <- "national"

    id_reg <- geography %in% unique(states_regions$region)
    type_of_poll[id_reg] <- "regional"

    id_state <- geography %in% states_regions$state
    type_of_poll[id_state] <- "state"

    if (any(is.na(type_of_poll)))
        stop("NA in type_of_poll. Abort!")
    type_of_poll
}