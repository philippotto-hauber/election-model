load_regions <- function() {
    states_regions <- load_dataland_states_regions()
    return(unique(states_regions$region))
}