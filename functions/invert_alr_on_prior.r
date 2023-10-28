invert_alr_on_prior <- function(prior_mmuT) {
    prior_mmuT <- as.data.frame(prior_mmuT)    
    names(prior_mmuT) <- "mmu"   
    prior_mmuT %>% 
        as.data.frame() %>%
        tibble::rownames_to_column(var = "tmp") %>%
        tidyr::separate(
            tmp, 
            into = c("state", "party"), 
            sep = "_") %>% 
        tidyr::pivot_wider(
            names_from = "party", 
            values_from = "mmu") %>% 
        mutate(SSP = NA) -> df_prior_mmuT

    df_prior_mmuT[is.na(df_prior_mmuT)] <- 0.0

    prior_ppi <- matrix(NA, 
                        nrow = length(states), 
                        ncol = length(parties),
                        dimnames = list(states, parties))

    for (s in seq(1, length(states))) {
        parties_s <- parties[1:(n_parties_by_state[s])]
        ppi_s <- inv_additive_log_ratio(unlist(df_prior_mmuT[s, parties_s]))
        prior_ppi[s, 1:n_parties_by_state[s]] <- ppi_s 
    }

    prior_ppi %>% 
        as.data.frame() %>% 
        tibble::rownames_to_column(var = "geography") %>% 
        tidyr::pivot_longer(
            cols = -geography, 
            names_to = "party", 
            values_to = "value"
            ) -> df_prior_ppi
    df_prior_ppi
}