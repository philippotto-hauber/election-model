# function that returns the number of parties running in each state/region
# output is a named vector with length equal to the number of states/regions
load_n_parties_by_geography <- function(geography){
    n_parties_by_region <- c(3, 3, 4)
    names(n_parties_by_region) <- c("Circuit Confederation", "Metaflux Realm", "Synapse Territories")
    
    if (geography == "region"){
        return(n_parties_by_region)
    } else if (geography == "state"){
        df_states <- load_dataland_states_regions()
        n_parties_by_state <- c()
        for (i in 1:nrow(df_states)){
            region <- df_states$region[i]
            n_parties_by_state <- c(n_parties_by_state, 
                                    n_parties_by_region[region])       
        }
        names(n_parties_by_state) <- df_states$state
        return(n_parties_by_state)
    } else {
        stop("geography must be either 'region' or 'state'")
    }
}