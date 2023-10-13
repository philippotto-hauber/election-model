load_mcmc_options <- function() {
    mcmc_options <- list()
    mcmc_options[["n_chains"]] <- 2    
    mcmc_options[["parallel_chains"]] <- 2
    mcmc_options[["n_warmup"]] <- 250
    mcmc_options[["n_sampling"]] <- 1000
    mcmc_options[["n_refresh"]] <- 100
    mcmc_options
}