# nonParQuantileCausality

Implements the nonparametric causality-in-quantiles test.

**Lag order:** first-order only (uses $x_{t-1}$ and $y_{t-1}$).

## Install (dev)

```r
# install.packages("devtools")
devtools::install_local("nonParQuantileCausality")
```

## Example

```r
library(nonParQuantileCausality)
set.seed(1)
x <- arima.sim(n = 600, list(ar = 0.4))
y <- 0.5*dplyr::lag(x, 1) + rnorm(600)  # if dplyr present; otherwise build your own lag
y[is.na(y)] <- mean(y, na.rm = TRUE)

obj <- np_quantile_causality(x, y, type = "mean", q = seq(0.1, 0.9, 0.1))
plot(obj)
```

```r
library(nonParQuantileCausality)
data(gold_oil)

obj <- np_quantile_causality(
  x = gold_oil$Oil, y = gold_oil$Gold,
  type = "mean", q = seq(0.05, 0.95, 0.05)
)
plot(obj)
```

## References

- Balcilar, M., Gupta, R., & Pierdzioch, C. (2016).
  *Does uncertainty move the gold price?* New evidence from a nonparametric causality-in-quantiles test.
  _Resources Policy_, 49, 74–80.

- Balcilar, M., Gupta, R., Kyei, C., & Wohar, M. E. (2016).
  *Does economic policy uncertainty predict exchange rate returns and volatility?*
  Evidence from a nonparametric causality-in-quantiles test.
  _Open Economies Review_, 27(2), 229–250.
  

