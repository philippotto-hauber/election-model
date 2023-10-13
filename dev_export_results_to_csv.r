df_draws_ppi %>% 
    group_by(t, party, geography) %>% 
    summarise(mean_vote_share = mean(values)) %>%
    rename(date = t, province = geography) %>%
    mutate(party = tolower(party)) %>%
    tidyr::pivot_wider(
        names_from = "party", 
        values_from = "mean_vote_share",
        names_glue = "{party}_{.value}") -> tmp

sum(tmp[10, 3:6])


df_draws_ppi_nat %>% 
    select(-geography) %>%
    group_by(t, party) %>% 
    summarise(mean_vote_share = mean(values)) %>%
    rename(date = t) %>%
    mutate(party = tolower(party)) %>%
    tidyr::pivot_wider(
        names_from = "party", 
        values_from = "mean_vote_share",
        names_glue = "{party}_{.value}") -> tmp_nat


sum(tmp_nat[10, 2:5])