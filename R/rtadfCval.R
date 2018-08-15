#' Returns critical values based on a response surface function approximation
#'
#' Returns critical values the right-tailed ADF, SADF and GSADF tests, based on
#' a surface function approximation
#'
#' @param t   Number of observations (i.e., length of the sample)
#' @param pval  Significance level (in percent)
#' @param testType  Test type, either "adf", "sadf" of "gsadf".
#'
#' @return Numeric, critical value at the user-specified significance level.
#'
#' @references Phillips, P. C. B., Wu, Y., & Yu, J. (2011). Explosive Behavior
#' in the 1990s Nasdaq: When Did Exuberance Escalate Asset Values?,
#' \emph{International Economic Review}, 201(1), 201--226.
#'
#' Phillips, P. C. B., Shi, S., & Yu, J. (2015). Testing for multiple bubbles:
#' Historical episodes of exuberance and collapse in the S&P 500.
#' \emph{International Economic Review}, 56(4), 1034--1078.
#'
#' MacKinnon, J. G. (1996). Numerical distribution functions for unit root and cointegration
#' tests. \emph{Journal of Applied Econometrics}, 11(6):601–618.
#'
#' @export
#'
#' @importFrom stats qnorm
#'
#' @examples
#' cv <- rtadfCval(t = 100,  pval = 0.95, testType = "sadf")
rtadfCval <- function(t, pval, testType){

  if (testType == "adf") {
    theta <- surfParams$adf
  }
  if (testType == "sadf") {
    theta <- surfParams$sadf
  }
  if (testType == "gsadf") {
    theta <- surfParams$gsadf
  }

  theta <- as.matrix(theta)[,-1]
  Qs <- seq(0.005,0.995,0.005)

  if (testType == "adf") {
    X <- matrix(c(1, 1/t, 1/t^2, 1/t^3), 4, 1)
  } else {
    X <- matrix(c(1, 1/t, 1/t^2), 3, 1)
  }

  Yhat <- theta %*% X
  distance <- abs(Qs - pval)
  idx <- which.min(distance)  # find index of closest percentile
  if (pval < 0.005 || pval > 0.995) {
    stop("P-value supplied by user out of bounds (try pval between 0.005 and 0.995)", call. = FALSE)
  } else  if (Qs[idx] <= 0.975 && Qs[idx] >= 0.025) {
    closest <- Yhat[seq(idx - 4,idx + 4,1),];  # closest value
    closestPval  <- Qs[seq(idx - 4,idx + 4,1)];  # closest value

    X <- cbind(rep(1,9), stats::qnorm(closestPval), stats::qnorm(closestPval)^2)
    Y <- closest
    delta <- solve(t(X) %*% X) %*% (t(X) %*% Y)
  } else if (Qs[idx] > 0.975 && Qs[idx] <= 0.995) {
    closest <- Yhat[seq(length(Yhat) - 4,length(Yhat),1),];  # closest value
    closestPval  <- Qs[seq(length(Qs) - 4,length(Qs),1)];  # closest value

    X <- cbind(rep(1,5), stats::qnorm(closestPval), stats::qnorm(closestPval)^2)
    Y <- closest
    delta <- solve(t(X) %*% X) %*% (t(X) %*% Y)
  } else if (Qs[idx] >= 0.005 && Qs[idx] < 0.025) {
    closest <- Yhat[1:5,];  # closest value
    closestPval  <- Qs[1:5];  # closest value

    X <- cbind(rep(1,5), stats::qnorm(closestPval), stats::qnorm(closestPval)^2)
    Y <- closest
    delta <- solve(t(X) %*% X) %*% (t(X) %*% Y)
  }

  dep <- matrix(c(1, stats::qnorm(Qs[idx]), stats::qnorm(Qs[idx])^2), 3, 1)
  cval <- crossprod(dep, delta)
  return(cval)

}
