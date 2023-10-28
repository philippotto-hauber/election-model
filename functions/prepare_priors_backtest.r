prepare_priors_backtest <- function() {
    priors <- readRDS(here::here("priors", paste0("priors.Rds")))

    # rm scenarios    
    priors_bt <- priors[["A"]]

    # extract names
    names_mmu_T <- names(priors_bt$m_mmu_T)

    # load mean vote share in past elections
    df_fcast <- readRDS(here::here(
        "backtest",
        "mean_vote_shares.rds"
        )
    )
    # convert to log ratios
    df_fcast %>% 
        inner_join(
            load_dataland_states_regions(), 
            by = join_by(province == state)) %>%
        mutate(party = toupper(party)) %>%
        group_by(province) %>%
        mutate(vote_share_lr = additive_log_ratio(vote_share)) %>% 
        filter(vote_share_lr != 0) %>% 
        arrange(region, province) %>%
        tidyr::unite(
            name, 
            province, 
            party, 
            sep = "_") -> df_m_mmu_T
    
    # check calc
    stopifnot(all(df_m_mmu_T$name == names_mmu_T))

    # store in list
    priors_bt[["m_mmu_T"]] <- df_m_mmu_T$vote_share_lr
    names(priors_bt[["m_mmu_T"]]) <- names_mmu_T
    # export to rds for documentation
    saveRDS(
        priors_bt,
        here::here(
            "backtest",
            "priors_backtest.rds"
        )
    )
    
    return(priors_bt)
}
