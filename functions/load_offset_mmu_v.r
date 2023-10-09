# function to calculate the row offset for the vectorised transformed voting intentions
load_offset_mmu_v <- function() {
    n_parties_by_state <- load_n_parties_by_geography("state")
    n_states <- length(n_parties_by_state)
    return(c(0, cumsum(n_parties_by_state - 1)[1:(n_states - 1)]))
}
