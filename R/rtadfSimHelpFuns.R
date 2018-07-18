### adf statistic ###
adf <- function(y) {

  lags <- 1
  z <- diff(y)
  n <- length(z)
  x <- embed(z, lags)
  z.diff <- x[, 1]
  z.lag.1 <- y[lags:n]
  X <- cbind(1, z.lag.1)
  result <- fastLmPure(X, z.diff)
  tau <- result$coefficients[[2]]/result$se[[2]]

}

### adf(r1,r2) statistic ###
adfr1r2 <- function(y,r1,r2) {

  ytrim  <- y[r1:r2]

  return(adf(ytrim))
}

### sadf statistic ###
sadf <- function(y, r0) {

  adfs <- rep(NA, length(y) - r0)
  adfs[1] <- adfr1r2(y,1,r0)
  j <- r0 + 1
  for (r2 in j:length(y)) {
    adfs[2 + r2 - j] <- adfr1r2(y,1,r2)
  }
  maxstat <- max(adfs)
  results <- list("stat" = maxstat, "sequence" = adfs)
  return(results)
}

### bsadf statistic ###
bsadf <- function(y, r0, r2) {

  maxtstat <- adfr1r2(y,1,r2)
  j <- r2 - r0
  for (r1 in 2:j) {
    temp <- adfr1r2(y,r1,r2)
    if (temp > maxtstat) {
      maxtstat <- temp
    }
  }
  return(maxtstat)
}

### gsadf statistic ###
gsadf <- function(y, r0) {

  bsadfs <- rep(NA, length(y) - r0)
  bsadfs[1] <- bsadf(y,r0,r0)
  j <- r0 + 1
  for (r2 in j:length(y)) {
    bsadfs[2 + r2 - j] <- bsadf(y,r0,r2)
  }
  maxstat <- max(bsadfs)
  results <- list("stat" = maxstat, "sequence" = bsadfs)
  return(results)
}

# a function that generates the results of a single "experiment"
teststat <- function(t, r0, testType){

  eta   <- 1
  d     <- 1
  drift <- d*t^(-eta)
  y     <- cumsum(rnorm(t) + drift)

  if (testType == "adf") {
    results <- adf(y)
  }
  if (testType == "sadf") {
    results <- sadf(y,r0)
  }
  if (testType == "gsadf") {
    results <- gsadf(y,r0)
  }

  return(results)

}


