test_that("gold_oil example runs (mean/variance + plot)", {
  skip_on_cran()
  set.seed(123)
  
  data(gold_oil, package = "nonParQuantileCausality")
  # use first 500 days
  gold_oil <- gold_oil[1:501,]
  expect_true(is.data.frame(gold_oil))
  expect_true(all(c("Gold", "Oil") %in% names(gold_oil)))
  
  q_grid <- seq(0.25, 0.75, by = 0.25)
  
  # mean
  res_mean <- np_quantile_causality(
    x = gold_oil$Oil, y = gold_oil$Gold,
    type = "mean", q = q_grid
  )
  expect_s3_class(res_mean, "np_quantile_causality")
  expect_equal(length(res_mean$statistic), length(q_grid))
  expect_true(is.numeric(res_mean$statistic))
  
  # variance
  res_var <- np_quantile_causality(
    x = gold_oil$Oil, y = gold_oil$Gold,
    type = "variance", q = q_grid
  )
  expect_s3_class(res_var, "np_quantile_causality")
  expect_equal(length(res_var$statistic), length(q_grid))
  
  # plot should invisibly return a ggplot object; don't assert rendering
  p1 <- plot(res_mean)
  p2 <- plot(res_var)
  expect_true(inherits(p1, "ggplot"))
  expect_true(inherits(p2, "ggplot"))
})
