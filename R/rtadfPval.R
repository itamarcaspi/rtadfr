#' Returns p-values based on a response surface function approximation
#'
#' \code{rtadfPval} approximate p-values for the SADF test (Phillips,Wu and Yu,
#' 2011) using the MacKinnon (1996) response surface function approach.
#'
#' @param t   Number of observations (i.e., length of the sample)
#' @param testStat  Test statistic
#' @param testType  Test type, either "adf", "sadf" of "gsadf".
#'
#' @return Numeric, p-value that corresponds to a user-specified test statistic.
#'
#' @references Phillips, P. C. B., Wu, Y., & Yu, J. (2011). Explosive Behavior
#'   in the 1990s Nasdaq: When Did Exuberance Escalate Asset Values?,
#'   \emph{International Economic Review}, 201(1), 201--226.
#'
#'   Phillips, P. C. B., Shi, S., & Yu, J. (2015). Testing for multiple bubbles:
#'   Historical episodes of exuberance and collapse in the S&P 500.
#'   \emph{International Economic Review}, 56(4), 1034--1078.
#'
#'   MacKinnon, J. G. (1996). Numerical distribution functions for unit root and cointegration
#'   tests. \emph{Journal of Applied Econometrics}, 11(6):601–618.
#'
#' @export
#'
#' @importFrom stats qnorm pnorm
#'
#' @examples
#' pval <- rtadfPval(t = 100,  testStat = 1.5, testType = "sadf")
rtadfPval <- function(t, testStat, testType){

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

  distance <- abs(Yhat - testStat)
  idx <- which.min(distance)  # find index of closest percentile
  if (idx + 4 >= length(Qs)) {
    pval <- 1
    warning("Test statistic out of bounds", call. = FALSE)
  } else if (idx - 4 <= 0) {
    pval <- 0
    warning("Test statistic out of bounds", call. = FALSE)
  } else {
    closest <- Yhat[seq(idx - 4,idx + 4,1),];  # closest value
    closestPval  <- Qs[seq(idx - 4,idx + 4,1)];  # closest value

    X <- cbind(rep(1,9), closest, closest^2)
    Y <- stats::qnorm(closestPval)
    delta <- solve(t(X) %*% X) %*% (t(X) %*% Y)
    dep <- matrix(c(1, (Yhat[idx]), (Yhat[idx])^2), 3, 1)
    pval <- stats::pnorm(crossprod(dep, delta))
  }

  return(pval)

}
