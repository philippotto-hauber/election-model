quarto render ./data/polls_scenarios_2024.qmd

quarto render ./fundamental_forecast/generate_fundamental_forecast.qmd

quarto render ./priors/construct_priors.qmd

Rscript --vanilla ./model/estimate_models.r

quarto render ./results/export_and_plot_results.qmd
