
# set up ----
params <- list()
params$year <- 2023

library(dplyr)
library(data.table)

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
priors <- readRDS(here::here("priors", paste0("priors.Rds")))

# load polls
polls <- readRDS(here::here("backtest", paste0("polls_", params$year, ".Rds")))


data_for_stan[["n_polls_state"]] <- dim(polls$y)[2]
data_for_stan[["n_polls_reg"]] <- dim(polls$y_reg)[2]
data_for_stan[["n_polls_nat"]] <- dim(polls$y_nat)[2]

# sample from model
data_for_stan  <- c(
    data_for_stan,
    polls, 
    priors[["A"]]
)


fit <- model$sample(
                    data = data_for_stan,
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
        paste0("mcmc_out_", params$year, ".Rds")
    )
)
parties <- load_parties()
states <- load_states()
    df_draws_ppi <- convert_draws_to_dt(
        rstan::extract(out, pars = "ppi")[["ppi"]],                        
        geographies = states,
        parties = parties,
        dates_campaign = dates_campaign)