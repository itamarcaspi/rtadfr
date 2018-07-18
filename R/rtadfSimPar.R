#' Simulate critical values and date-stamping threshold sequence in parallel
#'
#' Simulates in parallel critical values and date-stamping sequences for the
#' right-tailed ADF, SADF and GSADF tests.
#'
#' @param t   Number of observations (i.e., length of the sample)
#' @param r0  Minimal window size
#' @param nrep  Number of replications
#' @param testType  Test type, either "adf", "sadf" of "gsadf".
#'
#' @return List with 90, 95, 99 precent critical values and a threshold series
#'   for the date-stamping procedure
#' @export
#'
#' @examples
#' cv <- cvSimPar(100, 10, 1000, testType = "sadf")
rtadfSimPar <- function(t, nrep, testType) {

  # Setup -------------------------------------------------------------------

  r0 <- round(t*(0.01 + 1.8/sqrt(t))) #minimal window size

  # The parallel Monte Carlo simulation loop----------------------------------

  cl <- makeCluster(detectCores())
  registerDoParallel(cl)

  start.time <- Sys.time()

  MCresults <- foreach(i = 1:nrep, .inorder = FALSE,
                       .packages = c("urca", "RcppEigen"),
                       .combine = cbind) %dorng% {
                         teststat(t, r0, testType)
                       }

  end.time <- Sys.time()
  time.taken <- end.time - start.time

  stopCluster(cl)


  # Calculate critical values--------------------------------------------------

  if (testType == "adf") {

    statistics   <- as.numeric(MCresults)

    testCVs      <- quantile(statistics, probs = c(0.90, 0.95, 0.99))

    #generate a list with critical values (test and datestamp)
    simResults        <- list("testCVs" = testCVs)
    names(simResults) <- c("testCVs")

    print(simResults$testCVs)


  } else {

    statistics   <- as.numeric(MCresults[seq(1,length(MCresults) - 1,2)])
    datestampSeq <- do.call(rbind,as.matrix(MCresults[seq(2,length(MCresults),2)]))

    testCVs      <- quantile(statistics, probs = c(0.90, 0.95, 0.99))
    datestampCVs <- colQuantiles(datestampSeq, probs = c(0.90, 0.95, 0.99))

    #generate a list with critical values (test and datestamp)
    simResults        <- list("testCVs" = testCVs, "datestampCVs" = datestampCVs)
    names(simResults) <- c("testCVs", "datestampCVs")

    simResults$testCVs
  }

}

