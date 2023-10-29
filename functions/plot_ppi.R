plot_ppi <- function(
    df_draws,
    df_polls,
    n_geographies,
    type_of_poll,
    plt_title_prefix,
    plt_caption = element_blank(),
    df_results = NULL
  ){
  df_draws %>%
    mutate(values = ifelse(values == 0.0, NA, values)) %>%
    group_by(t, geography, party) %>%
    summarise(mn = mean(values, na.rm = T),
              q_95_upp = quantile(values, prob = c(0.025), na.rm = T),
              q_95_low = quantile(values, prob = c(1-0.025), na.rm = T),
              q_83_upp = quantile(values, prob = c(0.0855), na.rm = T),
              q_83_low = quantile(values, prob = c(1-0.085), na.rm = T)) %>%
    ungroup() %>%
    ggplot(aes(x = t))+
    geom_line(aes(y = mn, color = party), linetype = "dashed", linewidth= 1.0)+
    geom_ribbon(aes(ymin = q_95_low, ymax = q_95_upp, fill = party), alpha = 0.2)+
    geom_ribbon(aes(ymin = q_83_low, ymax = q_83_upp, fill = party), alpha = 0.3)+
    # add share in polls as points in plot
    geom_point(data = filter(df_polls, type_of_poll == !!type_of_poll),
               mapping = aes(x = date, y = value / sample_size, color = party),
               shape = 1)+
    {if (!is.null(df_results)) {
      # add election resultd as a diamond
      geom_point(
          mapping = aes(x = t, y = vote_share, color = party),
          data = df_results,
          shape = 18,
          size = 2,
          show.legend = FALSE
      )
    }
    }+
    ggsci::scale_color_jco()+
    ggsci::scale_fill_jco()+
    facet_wrap(
      vars(geography),
      nrow = ceiling(sqrt(n_geographies)),
      scales = "free"
    )+    
    labs(
      title = paste0(
        plt_title_prefix,
        ": Expected vote share"
      ),
      caption = plt_caption
    )+
    ylab("share")+
    theme(legend.position="top",
          legend.title = element_blank(),
          plot.caption = ggtext::element_textbox_simple(size = 7, 
                                                        margin = margin(8, 0, 0, 0)
          ))-> plt_ppi
  plt_ppi
}