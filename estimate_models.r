
# to-dos ----

# function for dim_mmu_v -> DONE!!!!
# function for offset_mmu_v -> DONE!!!!
# function to load parties -> get n_parties that way!-> DONE!!!!
# function to load mcmc options  -> DONE!!!!
# adjust data so that no regional polls like in scenario B can be handled -> DONE!!!!
# poll data in one file with different lists for scenarios -> like for priors! -> DONE!!!!

# set up ----

# source functions
names_functions = list.files(here::here("functions"))
for (f in names_functions)
    source(here::here("functions", f))
rm(f, names_functions)

# mcmc options
mcmc_options <- load_mcmc_options()
# mcmc_options <- list()
# mcmc_options[["n_chains"]] <- 1
# mcmc_options[["n_warmup"]] <- 10
# mcmc_options[["n_sampling"]] <- 10
# mcmc_options[["n_refresh"]] <- 10

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
data_for_stan[["state_weights_nat"]] <- load_national_pop_weights()
data_for_stan[["state_weights_reg"]] <- load_regional_pop_weights()

# compile/load compiled stan model
model <- cmdstanr::cmdstan_model(here::here("stan", "election_model.stan"), 
                                 compile=TRUE, force=TRUE)
# model <- cmdstanr::cmdstan_model(exe_file = here::here("stan", "election_model.exe"), 
#                                  compile=FALSE)

# load priors
load(here::here("priors", paste0("priors.Rda")))

# load polls
load(here::here("data", paste0("polls.Rda")))

# loop over scenarios -----
scenarios <- load_scenarios() 

for (scenario in scenarios) {

    # load dates
    dates_campaign <- load_dates_election_campaign(scenario = scenario)
    data_for_stan[["n_days"]] <- length(dates_campaign)


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
                        iter_warmup = mcmc_options[["n_warmup"]],
                        iter_sampling = mcmc_options[["n_sampling"]],
                        refresh = mcmc_options[["n_refresh"]],
                        seed = 1843
                        )
    out <- rstan::read_stan_csv(fit$output_files())

    save(out, file = here::here("stan", paste0("mcmc_out_", scenario, ".Rda")))
    rm(out, data_for_stan_scenario, fit)
}

