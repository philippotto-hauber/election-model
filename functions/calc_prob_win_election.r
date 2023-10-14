calc_prob_win_election <- function(
  df_draws_ppi,
  df_draws_ppi_nat,
  filter_t,
  states,
  parties,
  electoral_votes){
  # for each draw determine the winner in each state ----
  
  # back out number of draws
  n_draws <- max(df_draws_ppi$draw)
  
  df_draws_ppi %>% 
    filter(t == filter_t) %>% 
    mutate(values = ifelse(is.na(values), 0.0, values)) %>% # set missings to 0
    group_by(draw, geography) %>% 
    slice_max(values) -> df_state_winner 
  
  # calculate sum of electoral votes by party and draw ----
  df_state_winner %>%
    left_join(data.frame(geography = states, 
                         ev = electoral_votes),
              by = "geography") %>% 
    group_by(draw, party) %>% # overwrite grouping
    summarise(ev_tot = sum(ev)) %>%
    slice_max(ev_tot) %>%
    select(-ev_tot) -> df_ev
  
  # determine the probability of each party winning the election----
  
  # loop over rows of df and determine winning party in case of ties
  count_win <- vector(length = length(parties))
  names(count_win) <- parties
  for (m in seq(1, n_draws)){
    winning_parties <- df_ev$party[df_ev$draw == m]
    if (length(winning_parties) > 1) {
      winning_party <- break_ties(
        winning_parties,
        filter(df_state_winner, draw == m),
        filter(df_draws_ppi_nat, draw == m, t == filter_t)) 
    } else {
      winning_party <- winning_parties
    }
    count_win[winning_party] <- count_win[winning_party] + 1
  }
  
  
 # calculate probability of winning the election
  df_prob_win_election <- data.frame(
    date = filter_t,
    party = names(count_win),
    prob_win = count_win/n_draws,
    row.names = NULL
)
  
  # check that all parties present in df, even if they do not win any of the draws!
  missing_parties <- setdiff(parties, df_prob_win_election$party)
  if (length(missing_parties) > 0){
    df_prob_win_election <- rbind(
        df_prob_win_election,
        data.frame(
            date = filter_t, 
            party = missing_parties,
            prob_win = 0.0
        )
    )
  }
  
  # return output as list ----
  df_prob_win_election
}
