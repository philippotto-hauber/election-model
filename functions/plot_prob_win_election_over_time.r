plot_prob_win_election_over_time(df, plt_title_prefix) {
    df %>%
    ggplot(aes(x = date, y = prob_win, fill = party, color = party)) +
    geom_bar(position = "stack", stat = "identity", width = 1) +
    ggsci::scale_fill_jco() + 
    ggsci::scale_color_jco() +
    labs(title = paste0(plt_title_prefix, ": Probability of winning the election over time"))+
    ylab("probability")+
    xlab("") +
    theme(
        legend.position = "bottom", 
        legend.title = element_blank()) -> plt
  plt
}




