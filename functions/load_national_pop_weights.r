# function to calculate the share of the total population of each state
# output is a named vector of length equal to the number of states
load_national_pop_weights <- function(path = "./dataland/dataland_demographics.csv"){
    dat <- read.csv(path, stringsAsFactors = FALSE)        
    pop_weights_nat <- dat$population/sum(dat$population)
    names(pop_weights_nat) <- dat$province
    pop_weights_nat
}