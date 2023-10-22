load_mcmc_options <- function() {
    mcmc_options <- list()
    mcmc_options[["n_chains"]] <- 2
    mcmc_options[["parallel_chains"]] <- 2
    # minimum number of required warmup iterations is
    # 150 see https://mc-stan.org/docs/2_18/reference-manual/hmc-algorithm-parameters.html#adaptation.figure
    mcmc_options[["n_warmup"]] <- 250
    mcmc_options[["n_sampling"]] <- 500
    mcmc_options[["n_refresh"]] <- 100
    mcmc_options[["seed"]] <- 501
    mcmc_options
}