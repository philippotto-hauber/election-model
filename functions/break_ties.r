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
  break_ties <- function(tied_parties, df_state_winner, df_pop_vote){
    
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