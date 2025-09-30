#' nonParQuantileCausality: Nonparametric Causality in Quantiles
#'
#' Implements the nonparametric causality-in-quantiles test (in mean or variance),
#' returning a test object with an S3 plot() method.
#'
#' @section Lag order (important):
#'  The current implementation uses one lag of each series (first-order Granger 
#'  causality setup).
#'
#' @section References:
#' \itemize{
#'   \item Balcilar, M., Gupta, R., & Pierdzioch, C. (2016). 
#'         Does uncertainty move the gold price? New evidence from a nonparametric
#'         causality-in-quantiles test. \emph{Resources Policy}, 49, 74–80.
#'         \doi{10.1016/j.resourpol.2016.04.004}
#'   \item Balcilar, M., Gupta, R., Kyei, C., & Wohar, M. E. (2016).
#'         Does economic policy uncertainty predict exchange rate returns and 
#'         volatility? Evidence from a nonparametric causality-in-quantiles test.
#'         \emph{Open Economies Review}, 27(2), 229–250.
#'         \doi{10.1007/s11079-016-9388-x}
#' }
#'
#' @keywords internal
"_PACKAGE"
