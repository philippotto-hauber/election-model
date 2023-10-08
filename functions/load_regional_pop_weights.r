# function to calculate the share of the regional population for each state
# output is a matrix with rows equal to the number of regions 
# and columns equal to the number of states. 
# States not in a given region/row receive a weight of 0.
load_regional_pop_weights <- function(path = "./dataland/dataland_demographics.csv"){
    # load national weights    
    pop_weights_nat <- load_national_pop_weights()    
    
    # load data
    dat <- read.csv(path, stringsAsFactors = FALSE)

    # back out states and regions
    states <- unique(dat$province)
    n_states <- length(states)
    regions <- unique(dat$region)
    n_regions <- length(regions)

    # calculate regional weights
    pop_weights_reg <- matrix(0, nrow = n_regions, ncol = n_states) 
    for (r in seq(1, n_regions)){
        id_region <- which(grepl(regions[r], dat$region))
        sum_region <- sum(pop_weights_nat[id_region])
        pop_weights_reg[r, id_region] <- pop_weights_nat[id_region] / sum_region
    }
    rownames(pop_weights_reg) <- regions
    colnames(pop_weights_reg) <- states

    # return matrix
    pop_weights_reg
}