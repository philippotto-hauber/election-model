
# extract params ----
args <- commandArgs(trailingOnly = TRUE)
params <- list()
params$year <- as.numeric(args[1])

# set up ----
library(dplyr)
library(data.table)

# source functions
names_functions = list.files(here::here("functions"))
for (f in names_functions)
    source(here::here("functions", f))
rm(f, names_functions)

# mcmc options
mcmc_options <- load_mcmc_options()

# load parties, states
parties <- load_parties()
states <- load_states()
regions <- load_regions()

# set up data list for stan
data_for_stan <- list()
data_for_stan[["n_parties"]] <- length(parties)
data_for_stan[["n_parties_by_state"]] <- load_n_parties_by_geography("state")
data_for_stan[["n_parties_by_region"]] <- load_n_parties_by_geography("region")
states_regions <- load_dataland_states_regions()
data_for_stan[["n_states"]] <- length(states)
data_for_stan[["n_regions"]] <- length(regions)
data_for_stan[["n_pollsters"]] <- length(load_pollsters())
data_for_stan[["dim_mmu_v"]] <- load_dim_mmu_v()
data_for_stan[["offset_mmu_v"]] <- load_offset_mmu_v()
data_for_stan[["state_weights_nat"]] <- load_pop_weights("national")
data_for_stan[["state_weights_reg"]] <- load_pop_weights("regional")
dates_campaign <- load_dates_election_campaign(year = params$year)
data_for_stan[["n_days"]] <- length(dates_campaign)

# compile/load compiled stan model
# model <- cmdstanr::cmdstan_model(
#     here::here("model", "election_model.stan"), 
#     compile=TRUE,
#     force=TRUE
# )

model <- cmdstanr::cmdstan_model(
    exe_file = here::here("model", "election_model.exe"),
    compile=FALSE
)

# load priors
priors <- prepare_priors_backtest()

# load polls
polls <- readRDS(here::here("backtest", paste0("polls_", params$year, ".Rds")))

# loop over scenarios
scenarios_backtest <- c("all", "short")

for (scen in scenarios_backtest) {
    # scenario-specific data
    data_for_stan[["n_polls_state"]] <- dim(polls[[scen]]$y)[2]
    data_for_stan[["n_polls_reg"]] <- dim(polls[[scen]]$y_reg)[2]
    data_for_stan[["n_polls_nat"]] <- dim(polls[[scen]]$y_nat)[2]

    data_for_stan_scenario <- list()
    data_for_stan_scenario  <- c(data_for_stan,
                                 polls[[scen]], 
                                 priors)
    # sample from model
    fit <- model$sample(
                    data = data_for_stan_scenario,
                    chains = mcmc_options[["n_chains"]],
                    parallel_chains = mcmc_options[["parallel_chains"]], 
                    iter_warmup = mcmc_options[["n_warmup"]],
                    iter_sampling = mcmc_options[["n_sampling"]],
                    refresh = mcmc_options[["n_refresh"]],
                    seed = mcmc_options[["seed"]]
                    )
    out <- rstan::read_stan_csv(fit$output_files())

    saveRDS(
        out,
        file = here::here(
            "backtest",
            paste0("mcmc_out_", params$year, "_", scen, ".Rds")
        )
    )
}