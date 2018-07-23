# A unit test for rtadf function
if (require(testthat)) {
  context("Tests rtadfSimPar results")
  set.seed(1203)
  obs  <- 100
  r0 <- 90

  adf   <- rtadfSimPar(obs, 90, 1, test = "adf")[[1]]
  sadf  <- rtadfSimPar(obs, 90, 1, test = "sadf")[[1]]
  gsadf <- rtadfSimPar(obs, 90, 1, test = "gsadf")[[1]]

  expect_equal(adf, -7.02676, tolerance = 0.00001)
  expect_equal(sadf, -6.800959, tolerance = 0.00001)
  expect_equal(gsadf, -6.44748, tolerance = 0.00001)
}
