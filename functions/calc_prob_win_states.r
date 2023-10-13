calc_prob_win_states <- function(
  df_draws_ppi, 
  filter_t, 
  states, 
  parties){
  # for each draw determine the winner in each state ----
  
  # back out number of draws
  n_draws <- max(df_draws_ppi$draw)
  
  df_draws_ppi %>% 
    filter(t == filter_t) %>% 
    mutate(values = ifelse(is.na(values), 0.0, values)) %>% # set missings to 0
    group_by(draw, geography) %>% 
    slice_max(values) -> df_state_winner 
  
  # probability of winning each state ----
  df_state_winner %>%
    ungroup() %>%
    group_by(geography) %>%
    count(party) %>%
    mutate(prob_win = round(n/n_draws, digits = 4)) %>%
    select(-n) %>%
    # pivot_wider, then longer to fill in missing entries with NA, then replace with 0!
    tidyr::pivot_wider(
        names_from = "party", 
        values_from = "prob_win") %>%
    tidyr::pivot_longer(
        cols = -geography, 
        names_to = "party", 
        values_to = "prob_win") %>%
    mutate(prob_win = ifelse(is.na(prob_win), 0.0, prob_win)) -> df_prob_win_states
  
  # check that all parties present in df, 
  # even if they do not win any of the draws!
  missing_parties <- setdiff(parties, df_prob_win_states$party)
  if (length(missing_parties) > 0){
    for (missing_party in missing_parties){
      df_prob_win_states <- rbind(df_prob_win_states,
                                  data.frame(
                                    party = missing_party,
                                    geography = states,
                                    prob_win = 0.0)
      )
    }
  }
  df_prob_win_states$date <- filter_t
  df_prob_win_states
}