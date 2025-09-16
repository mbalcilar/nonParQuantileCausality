## -----------------------------------------------------------------------------
library(nonParQuantileCausality)
data(gold_oil)
# use first 500 rows
gold_oil <- gold_oil[1:501,]
q_grid <- seq(0.05, 0.95, by = 0.05)

# Causality in conditional mean (does Oil_t-1 cause Gold_t?)
res_mean <- np_quantile_causality(
  x = gold_oil$Oil,
  y = gold_oil$Gold,
  type = "mean",
  q = q_grid
)
res_mean

# Causality in conditional variance
res_var <- np_quantile_causality(
  x = gold_oil$Oil,
  y = gold_oil$Gold,
  type = "variance",
  q = q_grid
)
res_var

# Plot (with 5% critical value line); returns a ggplot object invisibly
plot(res_mean)
plot(res_var)

