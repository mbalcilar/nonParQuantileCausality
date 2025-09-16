#' Plot method for np_quantile_causality objects
#'
#' @param x an object of class \code{np_quantile_causality}
#' @param cv numeric; a reference critical value line (default 1.96 for ~5%)
#' @param title optional plot title; default is constructed from \code{x$type}
#' @param ... unused (for S3 compatibility)
#'
#' @return A ggplot object (invisibly).
#' 
#' @section References:
#' \itemize{
#'   \item Balcilar, M., Gupta, R., & Pierdzioch, C. (2016).
#'         Does uncertainty move the gold price? New evidence from a nonparametric
#'         causality-in-quantiles test. \emph{Resources Policy}, 49, 74–80.
#'   \item Balcilar, M., Gupta, R., Kyei, C., & Wohar, M. E. (2016).
#'         Does economic policy uncertainty predict exchange rate returns and volatility?
#'         Evidence from a nonparametric causality-in-quantiles test.
#'         \emph{Open Economies Review}, 27(2), 229–250.
#' }
#'
#' @export
plot.np_quantile_causality <- function(x, cv = 1.96, title = NULL, ...) {
  stopifnot(inherits(x, "np_quantile_causality"))
  df <- data.frame(
    q = x$quantiles,
    stat = x$statistic,
    cv = rep(cv, length(x$quantiles))
  )
  if (is.null(title)) {
    title <- sprintf("Causality-in-%s: test statistic by quantile",
                     if (x$type == "variance") "variance" else "mean")
  }
  p <- ggplot2::ggplot(df, ggplot2::aes(x = q)) +
    ggplot2::geom_line(ggplot2::aes(y = stat, linetype = "Statistic"), linewidth = 1) +
    ggplot2::geom_line(ggplot2::aes(y = cv, linetype = sprintf("CV (%.0f%%)", 5)),
                       linewidth = 0.6) +
    ggplot2::scale_linetype_manual(values = c("Statistic" = "solid", "CV (5%)" = "dashed")) +
    ggplot2::labs(title = title, x = "Quantile", y = "Test statistic", linetype = NULL) +
    ggplot2::theme_bw(base_size = 12) +
    ggplot2::theme(legend.position = "top")
  print(p)
  invisible(p)
}
