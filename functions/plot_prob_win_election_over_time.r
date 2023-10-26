plot_prob_win_election_over_time <- function(
  df,
  plt_title_prefix,
  plt_sbtitle = element_blank(),
  plt_caption = element_blank()
) {
    df %>%
    ggplot(aes(x = date, y = prob_win, fill = party, color = party)) +
    geom_bar(position = "stack", stat = "identity", width = 1) +
    ggsci::scale_fill_jco() + 
    ggsci::scale_color_jco() +
    labs(
      title = paste0(plt_title_prefix, ": Probability of winning the election"),
      caption = plt_caption
    )+
    ylab("probability")+
    xlab("") +
    theme(
        legend.position = "top", 
        legend.title = element_blank()) -> plt
  plt
}




