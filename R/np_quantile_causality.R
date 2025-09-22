#' Nonparametric Causality-in-Quantiles Test
#'
#' @description
#' Computes the Balcilar-Jeong-Nishiyama style nonparametric quantile
#' Granger-causality test for first-order lags. Methodology is based on 
#' Balcilar, Gupta, and Pierdzioch (2016, \doi{10.1016/j.resourpol.2016.04.004})
#' and Balcilar et al. (2016, \doi{10.1007/s11079-016-9388-x}).
#'
#' @param x numeric vector; candidate cause (independent) variable. The test internally uses the
#'   **first lag** of x (one-lag Granger causality setup).
#' @param y numeric vector; effect (dependent) variable. The test internally uses the
#'   **first lag** of y (one-lag Granger causality setup).
#' @param type character; "mean" or "variance" (causality in mean or variance).
#' @param q numeric vector of quantiles in (0,1). Default is seq(0.01, 0.99, 0.01).
#' @param hm optional numeric bandwidth; if `NULL`, uses Yu & Jones (1998) style
#'   plug-in via \code{KernSmooth::dpill} on the mean-regression proxy.
#'
#' @return An object of class \code{np_quantile_causality} with elements:
#' \itemize{
#'   \item \code{statistic}: numeric vector of test statistics by quantile
#'   \item \code{quantiles}: numeric vector of quantiles tested
#'   \item \code{bandwidth}: scalar base bandwidth used before quantile adjustment
#'   \item \code{type}: "mean" or "variance"
#'   \item \code{n}: effective sample size
#'   \item \code{call}: the matched call
#' }
#'
#' @details
#' Uses local polynomial quantile regression at each quantile with kernel weights,
#' constructs the Song et al. (2012) style quadratic form, and rescales to the
#' asymptotic standard-normal statistic.
#'
#' @section Lag order (important):
#' The current implementation **uses one lag** of each series only:
#' \eqn{x_{t-1}} and \eqn{y_{t-1}} (first-order Granger setup).
#' Extending to higher lags requires changing the internal embedding
#' (currently `stats::embed(*, 2)`) and the kernel construction to handle
#' multivariate lag vectors (e.g., a product kernel over all lag coordinates
#' or a multivariate Gaussian kernel).
#'
#' @note This function tests whether \eqn{x_{t-1}} Granger-causes \eqn{y_t}
#' in quantile \eqn{\theta} (and, with `type = "variance"`, whether
#' \eqn{x_{t-1}^2} causes \eqn{y_t^2}). Higher-order lags are **not** supported
#' in this release.
#'
#' @examples
#' \donttest{
#' set.seed(1234)
#' x <- arima.sim(n = 600, list(ar = 0.4))
#' y <- 0.5*lag(x, -1) + rnorm(600)  # x Granger-causes y
#' y[is.na(y)] <- mean(y, na.rm = TRUE)
#' obj <- np_quantile_causality(x, y, type = "mean", q = seq(0.1, 0.9, 0.1))
#' plot(obj)  # test statistic vs quantiles with 5% CV line
#'
#' # Example with bundled dataset (Gold causes Gold or Oil depending on call)
#' data(gold_oil)
#' # use first 500 days
#' gold_oil <- gold_oil[1:501,]
#' q_grid <- seq(0.25, 0.75, by = 0.25)
#'
#' # Causality in conditional mean (does Oil_t-1 cause Gold_t?)
#' res_mean <- np_quantile_causality(
#'   x = gold_oil$Oil,
#'   y = gold_oil$Gold,
#'   type = "mean",
#'   q = q_grid
#' )
#' res_mean
#'
#' # Causality in conditional variance
#' res_var <- np_quantile_causality(
#'   x = gold_oil$Oil,
#'   y = gold_oil$Gold,
#'   type = "variance",
#'   q = q_grid
#' )
#' res_var
#'
#' # Plot (with 5% critical value line); returns a ggplot object invisibly
#' plot(res_mean)
#' plot(res_var)
#' }
#'
#' @section References:
#' \itemize{
#'   \item Balcilar, M., Gupta, R., & Pierdzioch, C. (2016).
#'         Does uncertainty move the gold price? New evidence from a nonparametric
#'         causality-in-quantiles test. \emph{Resources Policy}, 49, 74–80.
#'         \doi{10.1016/j.resourpol.2016.04.004}
#'   \item Balcilar, M., Gupta, R., Kyei, C., & Wohar, M. E. (2016).
#'         Does economic policy uncertainty predict exchange rate returns and volatility?
#'         Evidence from a nonparametric causality-in-quantiles test.
#'         \emph{Open Economies Review}, 27(2), 229–250.
#'         \doi{10.1007/s11079-016-9388-x}
#' }
#'
#' @export
np_quantile_causality <- function(x,
                                  y,
                                  type = c("mean", "variance"),
                                  q = NULL,
                                  hm = NULL) {
  cl <- match.call()
  type <- match.arg(type)
  
  if (!is.numeric(x) ||
      !is.numeric(y))
    stop("x and y must be numeric vectors.")
  if (length(x) != length(y))
    stop("x and y must have the same length.")
  if (is.null(q))
    qvec <- seq(0.01, 0.99, by = 0.01)
  else
    qvec <- q
  if (any(qvec <= 0 |
          qvec >= 1))
    stop("All quantiles must be in (0,1).")
  
  # First lag embedding
  if (length(y) < 3)
    stop("Need at least length >= 3.")
  y_all <- stats::embed(y, 2)
  y_lag1 <- y_all[, 2]  # y_{t-1}
  y_t    <- y_all[, 1]  # y_t
  
  x_all <- stats::embed(x, 2)
  x_lag1 <- x_all[, 2]  # x_{t-1}
  
  # Switch for mean/variance causality
  if (type == "variance") {
    y2 <- y^2
    x2 <- x^2
  } else {
    y2 <- y
    x2 <- x
  }
  
  y2_all <- stats::embed(y2, 2)
  y2_t   <- y2_all[, 1]   # y2_t
  y2_lag1 <- y2_all[, 2]  # y2_{t-1}
  
  # NOTE: the original code had x2_all built from y2; fix to use x2.
  x2_all <- stats::embed(x2, 2)
  x2_t    <- x2_all[, 1]   # x2_t (unused downstream but kept for symmetry)
  x2_lag1 <- x2_all[, 2]   # x2_{t-1}
  
  tn <- length(y_t)  # effective n
  
  # Base bandwidth from mean-regression proxy (Yu & Jones, 1998) via dpill
  if (is.null(hm)) {
    # Use y_{t-1} -> y_t mean-regression proxy for dpill inputs
    h_base <- KernSmooth::dpill(y_lag1, y_t, gridsize = tn)
  } else {
    h_base <- hm
  }
  
  tstat_vec <- numeric(length(qvec))
  
  # Loop over quantiles
  for (j in seq_along(qvec)) {
    qj <- qvec[j]
    # Quantile-specific bandwidth adjustment
    qrh <- h_base * ((qj * (1 - qj) / (stats::dnorm(
      stats::qnorm(qj)
    )^2))^(1 / 5))
    
    # Local linear quantile regression of y2_t on y2_{t-1}, evaluated at y_{t-1}
    fit <- lprq2_(
      x = y2_lag1,
      y = y2_t,
      h = qrh,
      tau = qj,
      x0 = y_lag1
    )
    
    # Indicator residuals I(y2_t <= \hat{Q}_tau) - tau
    if_temp <- as.numeric(y2_t <= fit$fv) - qj
    if_vec  <- matrix(if_temp, ncol = 1)
    
    # Kernel weight matrix K over (y_{t-1}, x_{t-1}) distances, scaled
    # Using Gaussian product kernel
    y_mat <- outer(y_lag1, y_lag1, "-")
    x_mat <- outer(x_lag1, x_lag1, "-")
    # Scale x kernel by relative sd to y (matches original code intent)
    scale_x <- (stats::sd(y_lag1) / stats::sd(x_lag1))
    K <- stats::dnorm(y_mat / qrh) * stats::dnorm((x_mat / qrh) * scale_x)
    
    num <- t(if_vec) %*% K %*% if_vec
    den <- sqrt(tn / (2 * qj * (1 - qj)) / (tn - 1) / sum(K^2))
    
    tstat_vec[j] <- as.numeric(num * den) # asymptotic N(0,1) under H0
  }
  
  out <- list(
    statistic = tstat_vec,
    quantiles = qvec,
    bandwidth = h_base,
    type = type,
    n = tn,
    call = cl
  )
  class(out) <- "np_quantile_causality"
  out
}

#' @export
#' @rdname np_quantile_causality
#' @usage NULL
lrq_causality_test <- function(...) {
  .Deprecated("np_quantile_causality",
              package = "nonParQuantileCausality",
              msg = "Use np_quantile_causality(); dots-in-names are deprecated.")
  np_quantile_causality(...)
}
