calc_cor_election_results <- function(election_results) {
    df_res <- data.frame()
    for (y in seq(min(election_results$year), max(election_results$year))){
        election_results %>% 
            filter(year == y) %>%
            select(
                year,
                state,
                region,
                CC,
                DGM,
                PDAL,
                SSP
            ) %>% 
            arrange(region, state) %>% 
            tidyr::pivot_longer(
                cols = -c("state", "region", "year"),
                names_to = "party",
                values_to = "vote_share"
            ) %>%
            mutate(party = toupper(party)) %>%
            group_by(state) %>% 
            # rm ssp from states in which it is not running
            filter(vote_share != 0) %>% 
            mutate(vote_share_lr = additive_log_ratio(vote_share)) %>%
            # rm "last" party in each state that is 0 due to alr
            filter(vote_share_lr != 0) %>% 
            arrange(region, state) %>%
            select(-c("region", "vote_share")) %>% 
            tidyr::unite(
                col = "state_party", 
                state, 
                party) %>%
            tidyr::pivot_wider(
                names_from = state_party, 
                values_from = vote_share_lr
            ) %>% 
            rbind(df_res) -> df_res
    }

    df_res %>% 
        select(-year) %>% 
        as.matrix -> mat_res

    dimnames(mat_res) <- list(df_res$year, names(df_res)[2:ncol(df_res)])

    # check dims
    if (!(nrow(mat_res) == n_elections & 
            ncol(mat_res) == sum(n_parties_by_state-1)))
        stop("Dimensions of matrix containing log ratio election results not correct. Abort!")

    # check names
    stopifnot(all(colnames(mat_res) == names_mmu_T))

    # return mat
    mat_res
}