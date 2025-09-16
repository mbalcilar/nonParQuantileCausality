#' @importFrom stats coef
lprq2_ <- function(x, y, h, tau, x0) {
  n <- length(x0)
  xx0 <- x0
  xx <- x
  fv <- numeric(n)
  dv <- numeric(n)  # slope, kept for parity with original
  
  for (i in seq_len(n)) {
    z <- x - xx[i]
    z0 <- xx0-x0[i] 
    w  <- stats::dnorm(z0 / h)
    # local linear quantile regression via quantreg::rq with weights
    fit <- quantreg::rq(y ~ z, weights = w, tau = tau, ci = FALSE)
    fv[i] <- stats::coef(fit)[1]
    dv[i] <- stats::coef(fit)[2]
  }
  list(xx = x0, fv = fv, dv = dv)
}
