plot_prob_win_election <- function(
  df,
  filter_t,
  plt_title_prefix){
  ggplot(filter(df, date == filter_t), 
         aes(x = party, 
             y = prob_win, 
             fill = party)
        )+
    geom_bar(stat = "identity", show.legend = FALSE)+
    geom_label(aes(label = paste0(format(round(prob_win * 100, digits = 1), nsmall = 1), " %")), color = "white", show.legend = F)+
    ggsci::scale_fill_jco()+
    scale_y_continuous(breaks=seq(0, 1, 0.2), limits = c(0, 1))+
    labs(title = paste0(plt_title_prefix, ": Probability of winning the election on ", filter_t))+
    ylab("probability")+
    xlab("") +
    theme(
      legend.position = "top",
      legend.title = element_blank()
    ) -> plt
  plt
}