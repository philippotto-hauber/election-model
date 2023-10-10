load_states <- function() {
    states_regions <- load_dataland_states_regions()
    return(states_regions$state)
}