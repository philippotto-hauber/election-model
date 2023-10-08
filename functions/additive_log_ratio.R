additive_log_ratio <- function(x, drop_last = FALSE) {
  len_x <- length(x)
  x_ratio <- x/x[len_x]
  x_logratio <- log(x_ratio)
  if (drop_last) {
    x_logratio <- x_logratio[-len_x]
  }
  x_logratio
}