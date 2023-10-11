load_pop_weights <- function(geography, path = here::here("data", "dataland_demographics.csv")) {
    dat <- read.csv(path, stringsAsFactors = FALSE)
    states_regions <- load_dataland_states_regions()
    # merge with dat to preserve order of states!
    states_regions <- dplyr::inner_join(states_regions, dat,
        by = dplyr::join_by(
            region == region,
            state == province
        )
    )
    if (geography == "national") {
        pop_weights_nat <- states_regions$population / sum(states_regions$population)
        names(pop_weights_nat) <- states_regions$state
        return(pop_weights_nat)
    } else if (geography == "regional") {
        states <- states_regions$state
        n_states <- length(states)
        regions <- unique(states_regions$region)
        n_regions <- length(regions)
        # calculate regional weights
        pop_weights_reg <- matrix(0, nrow = n_regions, ncol = n_states)
        for (r in seq(1, n_regions)) {
            id_region <- which(grepl(regions[r], states_regions$region))
            pop_region <- sum(states_regions$population[id_region])
            pop_weights_reg[r, id_region] <- states_regions$population[id_region] / pop_region
        }
        rownames(pop_weights_reg) <- regions
        colnames(pop_weights_reg) <- states
        return(pop_weights_reg)
    } else {
        stop("input arg geography must be either 'national' or 'regional'. Abort!")
    }
}
