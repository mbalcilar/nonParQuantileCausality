# nonParQuantileCausality 0.1.1 (2025-09-30)

- Fixed some documentation issues.

# nonParQuantileCausality 0.1.0 (2025-09-15)

First public release (prepared for CRAN).

## New features
- Introduces `np_quantile_causality()` — a nonparametric **causality-in-quantiles** test
  for first-order lags, supporting causality in **mean** and **variance**.
- Returns an S3 object of class `np_quantile_causality` with fields for statistics,
  quantiles, bandwidth, type, and sample size.
- Adds `plot()` method for `np_quantile_causality` objects to visualize test
  statistics across quantiles with a reference critical-value line.

## API changes
- Renames legacy `lrq.causality.test` → `np_quantile_causality`.
- Replaces dots with underscores in all function names.
- Deprecation shim: `lrq_causality_test()` calls `np_quantile_causality()` and warns.
- Replaces `do.causality.figure()` with the S3 plotting interface `plot.np_quantile_causality()`.

## Data
- Bundles example dataset `gold_oil` (Gold, Oil) for runnable examples and tests.

## Implementation details
- Bandwidth: uses `KernSmooth::dpill()` as a mean-regression proxy (Yu & Jones, 1998)
  with quantile-specific rescaling.
- Internal local-linear quantile regression helper: `lprq2_()` (quantreg-backed).
- Kernel matrix uses a product Gaussian kernel with relative scaling between lags.

## Bug fixes
- Corrects a historical bug where `x2` lags were mistakenly embedded from `y2`
  in the variance case. Now uses `embed(x2, 2)` as intended.

## Documentation
- Adds package-level documentation and function docs via roxygen2.
- Includes a “References” section citing:
  - Balcilar, M., Gupta, R., & Pierdzioch, C. (2016), *Resources Policy*, 49, 74–80.
  - Balcilar, M., Gupta, R., Kyei, C., & Wohar, M. E. (2016), *Open Economies Review*, 27(2), 229–250.
- Provides `inst/CITATION` entries for standard package citation.
- Examples demonstrate mean/variance tests and plotting using `gold_oil`.

## Testing
- `testthat` suite covers:
  - Object creation and basic structure for mean/variance runs.
  - Plot method returns a `ggplot` object (skipped on CRAN).
- Examples and tests are lightweight and CRAN-friendly (no network or disk writes).

## Licensing
- MIT license (`License: MIT + file LICENSE`).

## Known limitations
- Current implementation supports **first-order lags only**.
- No built-in bootstrap wrapper for small-sample critical values.
- O(n²) kernel matrix construction may be slow for very large n.
