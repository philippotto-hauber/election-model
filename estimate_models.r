
# to-dos ----

# function for dim_mmu_v
# function for offset_mmu_v
# function to load parties -> get n_parties that way!
# adjust data so that no regional polls like in scenario B can be handled
# poll data in one file with different lists for scenarios -> like for priors!

# set up ----

# source functions
names_functions = list.files(here::here("functions"))
for (f in names_functions)
    source(here::here("functions", f))
rm(f, names_functions)

# mcmc options
mcmc_options <- list()
mcmc_options[["n_chains"]] <- 1
mcmc_options[["n_warmup"]] <- 10
mcmc_options[["n_sampling"]] <- 10
mcmc_options[["n_refresh"]] <- 10

# set up data list for stan
data_for_stan <- list()
data_for_stan[["n_parties"]] <- 4
data_for_stan[["n_parties_by_state"]] <- load_n_parties_by_geography("state")
data_for_stan[["n_parties_by_region"]] <- load_n_parties_by_geography("region")
states_regions <- load_dataland_states_regions()
data_for_stan[["n_states"]] <- nrow(states_regions)
data_for_stan[["n_regions"]] <- length(unique(states_regions$region))
data_for_stan[["n_pollsters"]] <- length(load_pollsters())
data_for_stan[["dim_mmu_v"]] <- sum(data_for_stan[["n_parties_by_state"]] - 1)
data_for_stan[["offset_mmu_v"]] <- c(0, cumsum(data_for_stan[["n_parties_by_state"]] - 1)[1:(data_for_stan[["n_states"]] - 1)])
data_for_stan[["state_weights_nat"]] <- load_national_pop_weights()
data_for_stan[["state_weights_reg"]] <- load_regional_pop_weights()

# compile/load compiled stan model
# model <- cmdstanr::cmdstan_model(here::here("stan", "election_model.stan"), 
#                                  compile=TRUE, force=TRUE)
model <- cmdstanr::cmdstan_model(exe_file = here::here("stan", "election_model.exe"), 
                                 compile=FALSE)

# load priors
load(here::here("priors", paste0("priors.Rda")))

# loop over scenarios -----
#scenarios <- load_scenarios()
scenarios <- c("A", "C", "D", "E")

for (scenario in scenarios) {

    # load dates
    dates_campaign <- load_dates_election_campaign(scenario = scenario)
    data_for_stan[["n_days"]] <- length(dates_campaign)

    # load polls
    load(here::here("data", paste0("data_scenario", scenario, ".Rda")))
    data_for_stan[["n_polls_state"]] <- dim(lst_data$y)[2]
    data_for_stan[["n_polls_reg"]] <- dim(lst_data$y_reg)[2]
    data_for_stan[["n_polls_nat"]] <- dim(lst_data$y_nat)[2]

    # sample from model
    data_for_stan_scenario <- list()
    data_for_stan_scenario  <- c(data_for_stan,
                                 lst_data, 
                                 priors[[scenario]])

    fit <- model$sample(
                        data = data_for_stan_scenario,
                        chains = mcmc_options[["n_chains"]],
                        iter_warmup = mcmc_options[["n_warmup"]],
                        iter_sampling = mcmc_options[["n_sampling"]],
                        refresh = mcmc_options[["n_refresh"]]
                        )
    out <- rstan::read_stan_csv(fit$output_files())

    save(out, file = here::here("stan", paste0("mcmc_out_", scenario, ".Rda")))
    rm(out, lst_data, data_for_stan_scenario, fit)
}

