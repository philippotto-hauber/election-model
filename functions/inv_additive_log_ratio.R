inv_additive_log_ratio <- function(y){
  len_y <- length(y)
  y_exp <- exp(y)
  x <- y_exp / sum(y_exp)
  x
}