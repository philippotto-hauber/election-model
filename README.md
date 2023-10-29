# election-model

This repo contains scripts to generate forecasts for the 2024 election in Dataland.

## Model 

The model I estimate is very similar to the one I originally described in the model outline. The description in  `model_description.html` contains a bit more details and hopefully less hand-waving.

## Repo structure

The folder structure of the repo is guided by the required steps of the analysis. These are: 

- generate a **fundamental forecast** based on a model of the relationship between past election results and historic macroeconomic data. For details on the model and how the fundamental forecasts differ across scenarios, see `fundamental_forecast/generate_fundamental_forecast.html`

- transform the **polls** of the 2024 campaign to a Stan-friendly format. See `data/polls_scenarios_2024.html` for the R code to do so along with plots describing the poll data

- construct the prior for the model estimation. This includes the fundamental forecast (as a prior on the expected vote share on election day)! For the underlying R code, a discussion of the priors and a visualization of the prior predictive distribution (in particular the prior probability of each party winning the election) see `priors/construct_priors.html`

- given the prior and data, **estimate** the model. See the R script `model/estimate_models.r` which compiles and samples from the Stan script `model/election_model.stan`

- process the MCMC output from the model estimation and calculate the mean vote shares and win probalities. See `results/export_and_plot_results.html` for the underlying R code that generates the csv-files and plots the results

- **backtest** the model's performance in three previous elections (each with a different winner). Plots of the results are in `backtest/plot_backtest_results_XXXX.html` where XXXX is the year of the election. A short summary: 
    - XXXX
    - YYYY
    - ZZZZ

## Notes

- throughout the code and documentation, I use the terms province and state interchangeably!

- some of the notebooks are more polished than others!

- because of their size, the MCMC output files are not stored in the repo but in this [Dropbox folder](https://www.dropbox.com/scl/fo/pu03a41st6of51rk1ezix/h?rlkey=4tg43mptcbgaie0y6mc22gejw&dl=0)

## Possible extensions/improvements

- over and beyond sampling uncertainty the model only includes "house effects" as a wedge between observed polling results and underlying voting intentions. Other sources of noise in the polls such as who is being polled (registered voters, all adults?) or how they are polled (online?) and should be adressed in the model in a similar fashion. The fact that is not the case is not a deliberate modelling decision but down to resource constraints!

- the Stan code so far prioritizes transparency and ease of implementation over efficiency

- improve the prior on the innovation covariance matrix that governs the comovement of the underlying vote intentions ($W$ in the model description's notation). I see two main points: 
    - use additional data in determining the correlation matrix of vote shares across parties and states, not just historic election results (see the discussion in `priors/construct_priors.html`) 
    - rather than fixing $\hat{W}$ and $\kappa$, place a prior on either or both values and update these in a fully Bayesian manner like the other parameters in the model. By treating $W$ as known, a major source of uncertainty in the model is disregarded! Prior information about likely correlations between parties and states can still be incorporated by choosing a suitable prior like an inverse Wishart

- the fundamental forecast XXXXX

## Replication

To generate the forecasts for the 2024 election, execute `run_scripts.bat` or run the individual scripts/notebooks in the order listed therein.

For the backtests there is a separate batch script in the corresponding directory called `run_backtests.bat`. Note that the years for which the model is backtested are hard-coded and need to be adjusted manually if desired. 


