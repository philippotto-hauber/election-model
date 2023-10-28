# election-model

Code to generate forecasts for the 2024 election in Dataland.

## Model

The model is based  . See `model_description.html` for details. Th

## Repo

The folder structure of the repo is guided by the required steps of the analysis. With the exception of the computationally intensive model estimation, all of the analyses are in Quarto notebooks (`*.qmd`). The corresp which contain the code and also document or explain the underlying analysis as well as plot results Some of the notebooks are more polished than others! 

- `data/prepare_polls_scenarios_2024.html` prepares the poll data for the 2024 election campaign, mak

- `fundamental_forecast/`
- `priors`

- `model`

- `results/export_and_plot_results.qmd` processes the MCMC output and calculates the win probalities. It also exports the csv result files that are in the main directory of this repo (e.g. `national_forecast_A.csv`). The rendered notebook also includes plots of the main results. 

## Possible extensions/improvements

- over and beyond sampling uncertainty the model only includes house effects as devi

- the Stan code prioritizes transparency and ease of implementation over efficiency

- the prior

## Replication

To generate the forecasts for the 2024 election, execute `run_scripts.bat` or run the individual scripts/notebooks in the order listed therein. This ensures that all the steps are performed in the correct order, e.g. that the fundamental forecast is produced first which is then used to set the prior for the expected vote shares on election day! 

For backtests, there is a separate batch script in the corresponding directoy called `run_backtests.bat`.


