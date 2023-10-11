plot_prob_win_electoral_college <- function(
  df_prob_win_electoral_college,
  plt_title_prefix){
  ggplot(df_prob_win_electoral_college, 
         aes(x = party, 
             y = prob_win, 
             fill = party)
        )+
    geom_bar(stat = "identity", show.legend = FALSE)+
    geom_label(aes(label = paste0(format(round(prob_win * 100, digits = 1), nsmall = 1), " %")), color = "white", show.legend = F)+
    ggsci::scale_fill_jco()+
    scale_y_continuous(breaks=seq(0, 1, 0.2), limits = c(0, 1))+
    labs(title = paste0(plt_title_prefix, ": Probability of winning the election"))+
    ylab("probability")+
    xlab("") -> plt_probwin_electoral_college
  plt_probwin_electoral_college
}