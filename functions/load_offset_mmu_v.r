# function to calculate the row offset for the
# vectorised transformed voting intentions back into a matrix.
# To do this, Stan needs to know which entries in the vector
# correspond to each row of the matrix. For example,
# the latent support for the parties in the first state
# start at the first elementin 1 and go to $P_1-1$.
# The required offset is thus 0! For the second state,
# the values start with the $(P_1-1)+1$-th element and
# end with the $(P_1-1)+(P_2-1)$- th element and
# the required offset is P_1-1 and so on..
load_offset_mmu_v <- function() {
  n_parties_by_state <- load_n_parties_by_geography("state")
  n_states <- length(n_parties_by_state)
  return(c(0, cumsum(n_parties_by_state - 1)[1:(n_states - 1)]))
}
