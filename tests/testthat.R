Sys.setenv("R_TESTS" = "")
library(testthat)
library(rtadfr)

test_check("rtadfr")
