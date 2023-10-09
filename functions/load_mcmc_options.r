load_mcmc_options <- function() {
    mcmc_options <- list()
    mcmc_options[["n_chains"]] <- 1
    mcmc_options[["n_warmup"]] <- 200
    mcmc_options[["n_sampling"]] <- 500
    mcmc_options[["n_refresh"]] <- 10
    mcmc_options
}