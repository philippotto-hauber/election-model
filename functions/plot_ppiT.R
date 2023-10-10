plot_ppiT <- function(df_draws, df_priors, id_election_day, n_states, plt_title_prefix) {
  df_draws %>%
    filter(t == id_election_day) %>%
    mutate(values = ifelse(values == 0.0, NA, values)) %>%
    ggplot(aes(x = values, color = party, fill = party)) +
    geom_density(alpha = 0.2)+
    # geom_vline(mapping = aes(xintercept = vals, color = party),
    #            data = filter(df_ppi, t == election_day, type == !!type),
    #            linewidth = 1, alpha = 0.4)+
    ggsci::scale_color_jco() +
    ggsci::scale_fill_jco() +
    facet_wrap(~territory, nrow = ceiling(sqrt(n_states)), scales = "free")+
    xlab("")+
    labs(title = paste0(plt_title_prefix, ": Posterior densities of the expected vote share on election day"),
         caption = "Vertical lines indicate the 'true', i.e. simulated values used to generate the polls with which the model is estimated. ")+
    theme(legend.position="top",
          plot.caption = ggtext::element_textbox_simple(size = 7, 
                                                        margin = margin(8, 0, 0, 0)
          ),
          axis.text.x = element_text(angle = 0)
    ) -> plt_ppiT
  plt_ppiT
}