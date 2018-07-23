# A unit test for rtadf function
if (require(testthat)) {
  context("Tests rtadfSim results")
  set.seed(1203)
  obs  <- 100
  r0 <- 90

  adf   <- rtadfSim(obs, 90, 1, test = "adf")[[1]]
  sadf  <- rtadfSim(obs, 90, 1, test = "sadf")[[1]]
  gsadf <- rtadfSim(obs, 90, 1, test = "gsadf")[[1]]

  expect_equal(adf, -1.45073, tolerance = 0.00001)
  expect_equal(sadf[[1]], -0.8274213, tolerance = 0.00001)
  expect_equal(gsadf[[1]], -2.15203, tolerance = 0.00001)
}
