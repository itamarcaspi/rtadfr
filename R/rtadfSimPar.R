#' Simulate critical values and date-stamping threshold sequence in parallel
#'
#' Simulates in parallel critical values and date-stamping sequences for the
#' right-tailed ADF, SADF and GSADF tests.
#'
#' @param t   Number of observations (i.e., length of the sample)
#' @param r0  Minimal window size
#' @param nrep  Number of replications
#' @param test  Test type, either "adf", "sadf" of "gsadf".
#'
#' @return List with 90, 95, 99 precent critical values and a threshold series
#'   for the date-stamping procedure
#'
#' @references
#' Phillips, P. C. B., Wu, Y., & Yu, J. (2011). Explosive Behavior
#' in the 1990s Nasdaq: When Did Exuberance Escalate Asset Values?,
#' \emph{International Economic Review}, 201(1), 201--226.
#'
#' Phillips, P. C. B., Shi, S., & Yu, J. (2015). Testing for multiple bubbles:
#' Historical episodes of exuberance and collapse in the S&P 500.
#' \emph{International Economic Review}, 56(4), 1034--1078.
#'
#' @export
#'
#' @importFrom doParallel registerDoParallel
#' @importFrom doRNG %dorng%
#' @importFrom RcppEigen fastLmPure
#' @importFrom stats rnorm
#' @importFrom stats embed
#'
#' @examples
#' cv <- rtadfSimPar(t = 100, r0 = 10, nrep = 100, test = "sadf")
rtadfSimPar <- function(t, r0, nrep = 1000, test = c("adf", "sadf", "gsadf")) {

  # The parallel Monte Carlo simulation loop----------------------------------

  cl <- parallel::makeCluster(parallel::detectCores())
  registerDoParallel(cl)

  MCresults <- foreach::foreach(i = 1:nrep, .inorder = FALSE,
                       .packages = c("RcppEigen"),
                       .combine = cbind) %dorng% {
                         teststat(t, r0, test)
                       }

  parallel::stopCluster(cl)


  # Calculate critical values--------------------------------------------------

  if (test == "adf") {

    statistics   <- as.numeric(MCresults)

    testCVs      <- stats::quantile(statistics, probs = c(0.90, 0.95, 0.99))

    #generate a list with critical values (test and datestamp)
    simResults        <- list("testCVs" = testCVs)
    names(simResults) <- c("testCVs")

    print(simResults$testCVs)


  } else {

    statistics   <- as.numeric(MCresults[seq(1,length(MCresults) - 1,2)])
    datestampSeq <- do.call(rbind,as.matrix(MCresults[seq(2,length(MCresults),2)]))

    testCVs      <- stats::quantile(statistics, probs = c(0.90, 0.95, 0.99))
    datestampCVs <- apply(datestampSeq, 2, stats::quantile, probs = c(0.90, 0.95, 0.99), na.rm = TRUE)
    NAmat        <- matrix(NA, nrow = r0 - 1, ncol = 3)
    datestampCVs <- rbind(NAmat, datestampCVs)

    #generate a list with critical values (test and datestamp)
    simResults        <- list("testCVs" = testCVs, "datestampCVs" = datestampCVs)
    names(simResults) <- c("testCVs", "datestampCVs")

    simResults
  }

}

