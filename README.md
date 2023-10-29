# election-model

Code to generate forecasts for the 2024 election in Dataland.

## Model

The model is based  . See `model_description.html` for details. Th

## Repo

The folder structure of the repo is guided by the required steps of the analysis. With the exception of the computationally intensive model estimation, all of the analyses are in notebooks which bundle the underlying R code, narrative or documentation and (graphical) output. (Some of the notebooks are more polished than others!) 

- `data/prepare_polls_scenarios_2024.html` prepares the poll data for the 2024 election campaign, mak

- `fundamental_forecast/generate_fundamental_forecast.html` 

- `priors/construct_priors.html` 

- `model/estimate_models.r`

- `model/election_model.stan`

- `results/export_and_plot_results.qmd` processes the MCMC output and calculates the win probalities. It also exports the csv result files that are in the main directory of this repo (e.g. `national_forecast_A.csv`). The rendered notebook also includes plots of the main results. 

- `backtest/plot_results`

## Possible extensions/improvements

- Over and beyond sampling uncertainty the model only includes "house effects" as a wedge between observed polling results and underlying voting intentions. Other sources of noise in the polls such as who is being polled (registered voters, all adults?) or how they are polled (online?) and should be adressed in the model in a similar fashion. 

- The Stan code that estimates the model prioritizes transparency and ease of implementation over efficiency! 

- The prior

- The fundamental forecast 

## Replication

To generate the forecasts for the 2024 election, execute `run_scripts.bat` or run the individual scripts/notebooks in the order listed therein. This ensures that all the steps are performed in the correct order, e.g. that the fundamental forecast is produced first which is then used to set the prior for the expected vote shares on election day! 

For the backtests there is a separate batch script in the corresponding directoy called `run_backtests.bat`. Note that the years for which the model is backtested are hard-coded and need to be adjusted manually if desired. 


