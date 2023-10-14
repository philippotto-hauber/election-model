plot_prob_win_states <- function(
    df,
    filter_t, 
    plt_title_prefix){
  n_geographies <- length(load_states())
  stopifnot(n_geographies == length(unique(df$geography)))

  ggplot(filter(df, date == filter_t), 
         aes(x = party, 
             y = prob_win, 
             fill = party)
  )+
    geom_bar(stat = "identity", show.legend = FALSE)+
    geom_label(aes(label = paste0(format(round(prob_win * 100, digits = 1), nsmall = 1), " %")), color = "white", size = 2, show.legend = F)+
    ggsci::scale_fill_jco()+
    scale_y_continuous(breaks=seq(0, 1, 0.2), limits = c(0, 1))+
    facet_wrap(~geography, ceiling(sqrt(n_geographies)))+
    labs(title = paste0(plt_title_prefix, ": Probability of winning electoral votes on ", filter_t))+
    ylab("probability")+
    xlab("") -> plt
  plt
}