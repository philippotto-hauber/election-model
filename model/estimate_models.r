
# set up ----

# source functions
names_functions = list.files(here::here("functions"))
for (f in names_functions)
    source(here::here("functions", f))
rm(f, names_functions)

# mcmc options
mcmc_options <- load_mcmc_options()

# set up data list for stan
data_for_stan <- list()
data_for_stan[["n_parties"]] <- length(load_parties())
data_for_stan[["n_parties_by_state"]] <- load_n_parties_by_geography("state")
data_for_stan[["n_parties_by_region"]] <- load_n_parties_by_geography("region")
states_regions <- load_dataland_states_regions()
data_for_stan[["n_states"]] <- nrow(states_regions)
data_for_stan[["n_regions"]] <- length(unique(states_regions$region))
data_for_stan[["n_pollsters"]] <- length(load_pollsters())
data_for_stan[["dim_mmu_v"]] <- load_dim_mmu_v()
data_for_stan[["offset_mmu_v"]] <- load_offset_mmu_v()
data_for_stan[["state_weights_nat"]] <- load_pop_weights("national")
data_for_stan[["state_weights_reg"]] <- load_pop_weights("regional")
dates_campaign <- load_dates_election_campaign()
data_for_stan[["n_days"]] <- length(dates_campaign)

# compile/load compiled stan model
# model <- cmdstanr::cmdstan_model(here::here("model", "election_model.stan"), 
#                                  compile=TRUE, force=TRUE)
model <- cmdstanr::cmdstan_model(exe_file = here::here("model", "election_model.exe"), 
                                 compile=FALSE)

# load priors
priors <- readRDS(here::here("priors", paste0("priors.Rds")))

# load polls
polls <- readRDS(here::here("data", paste0("polls.Rds")))

# loop over scenarios -----
scenarios <- load_scenarios() 
for (scenario in scenarios) {
    data_for_stan[["n_polls_state"]] <- dim(polls[[scenario]]$y)[2]
    data_for_stan[["n_polls_reg"]] <- dim(polls[[scenario]]$y_reg)[2]
    data_for_stan[["n_polls_nat"]] <- dim(polls[[scenario]]$y_nat)[2]

    # sample from model
    data_for_stan_scenario <- list()
    data_for_stan_scenario  <- c(data_for_stan,
                                 polls[[scenario]], 
                                 priors[[scenario]])

    if (scenario == "B"){
        # scenario B only has 1 regional polls. This causes problems in Stan 
        # where the variables refering to regional polls are declared as arrays (of size 1)
        # In this case, Stan requires the data to have a dim attribute!
        # The easiest way of doing this is by converting the variables to arrays
        # see here: https://stackoverflow.com/questions/53163214/how-to-have-a-variable-in-the-data-block-of-stan-be-an-array-of-length-j-1
        # It's a bit puzzling because an R vector does not have a dim attribute either so 
        # I don't see the difference to other scenarios. But I guess a vector of length 1 is treated differently!
        data_for_stan_scenario[["day_poll_reg"]] <- as.array(data_for_stan_scenario[["day_poll_reg"]])
        data_for_stan_scenario[["n_responses_reg"]] <- as.array(data_for_stan_scenario[["n_responses_reg"]])
        data_for_stan_scenario[["house_poll_reg"]] <- as.array(data_for_stan_scenario[["house_poll_reg"]])
        data_for_stan_scenario[["region_poll"]] <- as.array(data_for_stan_scenario[["region_poll"]])
    }

    fit <- model$sample(
                        data = data_for_stan_scenario,
                        chains = mcmc_options[["n_chains"]],
                        parallel_chains = mcmc_options[["parallel_chains"]], 
                        iter_warmup = mcmc_options[["n_warmup"]],
                        iter_sampling = mcmc_options[["n_sampling"]],
                        refresh = mcmc_options[["n_refresh"]],
                        seed = 1843
                        )
    out <- rstan::read_stan_csv(fit$output_files())

    saveRDS(out, file = here::here("model", paste0("mcmc_out_", scenario, ".Rds")))
    rm(out, data_for_stan_scenario, fit)
}
