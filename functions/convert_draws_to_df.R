convert_draws_to_df <- function(draws, dims_draws, territories, parties){
  as.data.frame(draws) %>%
    tibble::rownames_to_column(var = "draw") %>%
    tidyr::pivot_longer(col = -draw, names_to = "tmp", values_to = "values") %>%
    tidyr::separate(tmp, into = dims_draws) %>% 
    mutate(values = ifelse(is.nan(values), NA, values),
           t = as.numeric(t),
           draw = as.numeric(draw),
           party = parties[as.numeric(party)],
           territory = territories[as.numeric(territory)]) -> df
  df
}

