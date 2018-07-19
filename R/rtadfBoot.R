#' Bootstrap critical values and date-stamping threshold sequence
#'
#' Bootstraps critical values and date-stamping sequences for the right-tailed
#' ADF, SADF and GSADF tests.
#'
#' @param y   Vector of observations
#' @param r0  Minimal window size
#' @param nrep  Number of replications
#' @param test  Test type, either "adf", "sadf" of "gsadf".
#'
#' @return List with 90, 95, 99 precent critical values and a threshold series
#'   for the date-stamping procedure
#' @export
#'
#' @examples
#' cv <- rtadfSim(t = 100, r0 = 10, nrep = 1000, test = "sadf")
rtadfBoot <- function(y, r0, nrep = 1000, test = c("adf", "sadf", "gsadf")) {

  statistics   <- rep(NA, nrep) #holds the simulated test statistics
  datestampSeq <- matrix(NA, nrow = t - r0 + 1,
                         ncol = nrep) #holds simulated datestamping sequences

  start.time <- Sys.time()

  eps <- c(0, diff)
  eps <- eps - mean(eps)


  for (i in 1:nrep) {

    runResults       <- teststatBoot(t, r0, test)
    if (test == "adf") {

      statistics[i]    <- runResults

    } else {

      statistics[i]    <- runResults$stat
      datestampSeq[,i] <- runResults$sequence

    }
  }

  end.time <- Sys.time()
  time.taken <- end.time - start.time

  # Calculate quantiles -----------------------------------------------------

  if (test == "adf") {

    testCVs <- quantile(statistics, probs = c(0.90, 0.95, 0.99))

    #generate a list with critical values
    simResults <- list("testCVs" = testCVs)
    names(simResults) <- c("testCVs")

    print(simResults$testCVs)

  } else {

    testCVs      <- quantile(statistics, probs = c(0.90, 0.95, 0.99))
    datestampCVs <- rowQuantiles(datestampSeq, probs = c(0.90, 0.95, 0.99))
    NAmat        <- matrix(NA, nrow = r0 - 1, ncol = 3)
    datestampCVs <- rbind(NAmat, datestampCVs)

    #generate a list with critical values
    simResults <- list("testCVs" = testCVs, "datestampCVs" = datestampCVs)
    names(simResults) <- c("testCVs", "datestampCVs")

    simResults


  }
}

