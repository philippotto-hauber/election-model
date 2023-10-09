quarto render ./data/polls_scenarios_2024.qmd

quarto render ./priors/construct_priors.qmd

Rscript --vanilla ./model/estimate_models.r


