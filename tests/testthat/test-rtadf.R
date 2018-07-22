# A unit test for rtadf function
if (require(testthat)) {
  context("Tests rtadf results")
  set.seed(1203)
  x <- rnorm(100)

  adf   <- rtadf(x, 90, test = "adf", lags = 1, selectlags = "Fixed")$testStat[1]
  sadf  <- rtadf(x, 90, test = "sadf", lags = 1, selectlags = "Fixed")$testStat[1]
  gsadf <- rtadf(x, 90, test = "gsadf", lags = 1, selectlags = "Fixed")$testStat[1]

  expect_equal(adf, -7.02676, tolerance = 0.00001)
  expect_equal(sadf, -6.800959, tolerance = 0.00001)
  expect_equal(gsadf, -6.44748, tolerance = 0.00001)
}
