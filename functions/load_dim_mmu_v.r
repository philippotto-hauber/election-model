# function to calculate the dimension of the vectorised transformed latent voting intentions -> \mu_t
# this is simply the number of parties in each state  minus one (because of the log ratio transformation)
load_dim_mmu_v <- function() {
    n_parties_by_state <- load_n_parties_by_geography("state")
    return(sum(n_parties_by_state - 1))
}