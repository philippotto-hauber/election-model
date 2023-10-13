
library(ggplot2)
library(dplyr)
names_functions = list.files(here::here("functions"))
for (f in names_functions)
    source(here::here("functions", f))
rm(f, names_functions)

scen <- "A"

load(here::here("model", paste0("mcmc_out_", scen, ".RDA")))

draws_ppi_reg <-  rstan::extract(out, pars = "ppi_reg")[["ppi_reg"]]

draws_ppi_states <-  rstan::extract(out, pars = "ppi")[["ppi"]]

draw <- 1
t <- 10

draw_ppi_reg <- draws_ppi_reg[draw, t, , ]

draw_ppi <- draws_ppi_states[draw, t, , ]

weights_region <- load_pop_weights("regional")

draw_ppi_reg_calc <- as.matrix(draw_ppi) %*% t(as.matrix(weights_region))

electoral_votes <- load_electoral_votes()
