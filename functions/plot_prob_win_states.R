plot_prob_win_states <- function(df_prob_win_states, plt_title_prefix){
  ggplot(df_prob_win_states, 
         aes(x = party, 
             y = prob_win, 
             fill = party)
  )+
    geom_bar(stat = "identity", show.legend = FALSE)+
    geom_label(aes(label = paste0(format(round(prob_win * 100, digits = 1), nsmall = 1), " %")), color = "white", size = 2, show.legend = F)+
    ggsci::scale_fill_jco()+
    scale_y_continuous(breaks=seq(0, 1, 0.2), limits = c(0, 1))+
    facet_wrap(~geography)+
    labs(title = paste0(plt_title_prefix, ": Probability of winning electoral votes"))+
    ylab("probability")+
    xlab("") -> plt_probwin_states
  plt_probwin_states
}