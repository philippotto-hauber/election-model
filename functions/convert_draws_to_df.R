convert_draws_to_df <- function(draws, geographies, parties, dates_campaign){
  as.data.frame(draws) %>%
    tibble::rownames_to_column(var = "draw") %>%
    tidyr::pivot_longer(col = -draw, names_to = "tmp", values_to = "values") %>%
    tidyr::separate(
      tmp, 
      into = c("t", "party", "geography")
    ) %>% 
    mutate(values = ifelse(is.nan(values), NA, values),
           t = dates_campaign[as.numeric(t)],
           draw = as.numeric(draw),
           party = parties[as.numeric(party)],
           geography = geographies[as.numeric(geography)]) -> df
  df
}

