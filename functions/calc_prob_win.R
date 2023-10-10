calc_prob_win <- function(df_draws_ppi, df_draws_ppi_nat, election_day, states, parties, electoral_votes){
  # auxiliary function to break ties in the electoral college vote ----
  
  #' Break ties in the electoral college
  #' 
  #' Function to determine the winner of the electoral college in case of multiple parties having
  #' the same number of electoral votes
  #' - first tiebreaker: the party that won the most states
  #' - second tiebreaker (if needed): party that won the popular vote
  #' The function throws an error if these two tiebreakers do not produce a clear winner. 
  #'
  #' @param tied_parties character vector containing the parties that received the same number of electoral votes
  #' @param df_state_winner data.frame containing the winner of each state for a given draw
  #' @param df_pop_vote data.frame containng the share of the popular vote of each party for a given draw
  #'
  #' @return winning_party string containing the name of the winning party
  break_ties_in_electoral_college <- function(tied_parties, df_state_winner, df_pop_vote){
    
    states_won <- vector(mode = "numeric", length = length(tied_parties))
    names(states_won) <- tied_parties
    for (p in tied_parties)
      states_won[p] <- sum(df_state_winner$party == p)
    id_most_states_won <- which(states_won == max(states_won))
    parties_most_states_won <- tied_parties[id_most_states_won]
    
    if (length(parties_most_states_won) > 1){
      share_pop_vote <- vector(mode = "numeric", length = length(parties_most_states_won))
      names(share_pop_vote) <- parties_most_states_won
      for (p in parties_most_states_won){
        share_pop_vote[p] <- df_pop_vote$values[df_pop_vote$party == p]
      }
      id_winner_popular_vote <- which(share_pop_vote == max(share_pop_vote))
      parties_winner_pop_vote <- parties_most_states_won[id_winner_popular_vote]
      if (length(parties_winner_pop_vote) == 1)
        winning_party <- parties_most_states_won[id_winner_popular_vote]
      else 
        stop("Could not determine a unique winner of the electoral college. Abort!")
    } else {
      winning_party <- tied_parties[id_most_states_won]
    }
    winning_party
  }
  
  # for each draw determine the winner in each state ----
  
  # back out number of draws
  n_draws <- max(df_draws_ppi$draw)
  
  df_draws_ppi %>% 
    filter(t == election_day) %>% 
    mutate(values = ifelse(is.na(values), 0.0, values)) %>% # set missings to 0
    group_by(draw, territory) %>% 
    slice_max(values) -> df_state_winner 
  
  # probability of winning each state ----
  df_state_winner %>%
    ungroup() %>%
    group_by(territory) %>%
    count(party) %>%
    mutate(prob_win = round(n/n_draws, digits = 4)) %>% 
    select(-n) %>%
    # pivot_wider, then longer to fill in missing entries with NA, then replace with 0!
    tidyr::pivot_wider(names_from = "party", values_from = "prob_win") %>%
    tidyr::pivot_longer(cols = -territory, names_to = "party", values_to = "prob_win") %>%
    mutate(prob_win = ifelse(is.na(prob_win), 0.0, prob_win)) -> df_prob_win_states
  
  # check that all parties present in df, even if they do not win any of the draws!
  missing_parties <- setdiff(parties, df_prob_win_states$party)
  if (length(missing_parties) > 0){
    for (missing_party in missing_parties){
      df_prob_win_states <- rbind(df_prob_win_states,
                                  data.frame(party = missing_party,
                                             territory = states,
                                             prob_win = 0.0)
      )
    }
  }
  
  # calculate sum of electoral votes by party and draw ----
  df_state_winner %>%
    left_join(data.frame(territory = states, 
                         ev = electoral_votes),
              by = "territory") %>% 
    group_by(draw, party) %>% # overwrite grouping
    summarise(ev_tot = sum(ev)) %>%
    slice_max(ev_tot) %>%
    select(-ev_tot) -> df_ev
  
  # determine the probability of each party winning the election----
  
  # loop over rows of df and determine winning party in case of ties
  count_win <- vector(length = n_parties)
  names(count_win) <- parties
  for (m in seq(1, n_draws)){
    winning_parties <- df_ev$party[df_ev$draw == m]
    if (length(winning_parties) > 1){
      print("breaking ties")
      winning_party <- break_ties_in_electoral_college(winning_parties,
                                                       filter(df_state_winner, draw == m),
                                                       filter(df_draws_ppi_nat, draw == 5, t == election_day)) 
    } else {
      winning_party <- winning_parties
    }
    count_win[winning_party] <- count_win[winning_party] + 1
  }
  
  
  # calculate probability of winning the election
  df_prob_win_electoral_college <- data.frame(party = names(count_win),
                                              prob_win = count_win/n_draws)
  
  # check that all parties present in df, even if they do not win any of the draws!
  missing_parties <- setdiff(parties, df_prob_win_electoral_college$party)
  if (length(missing_parties) > 0){
    df_prob_win <- rbind(df_prob_win_electoral_college,
                         data.frame(party = missing_parties,
                                    prob_win = 0.0)
    )
  }
  
  # return output as list ----
  out <- list(df_prob_win_electoral_college = df_prob_win_electoral_college,
              df_prob_win_states = df_prob_win_states)
  out
}
