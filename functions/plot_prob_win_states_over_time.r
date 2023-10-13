plot_prob_win_states_over_time <- function(
    df, 
    plt_title_prefix){
  n_geographies <- length(load_states())
  stopifnot(n_geographies == length(unique(df$geography)))

    ggplot(df, 
        aes(x = date, 
            y = prob_win, 
            fill = party, 
            color = party)
    ) +
    geom_bar(position = "stack", stat = "identity", width = 1) +
    ggsci::scale_fill_jco() + 
    ggsci::scale_color_jco() + 
    scale_y_continuous(breaks=seq(0, 1, 0.2), limits = c(0, 1))+
    facet_wrap(~geography, ceiling(sqrt(n_geographies)))+
    labs(title = paste0(plt_title_prefix, ": Probability of winning electoral votes"))+
    ylab("probability")+
    xlab("") -> plt
  plt
}