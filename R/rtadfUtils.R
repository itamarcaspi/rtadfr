ur.adfr1r2 <- function(y, r1, r2, type = c("none", "drift", "trend"),
                      lags = 1, selectlags = c("Fixed", "AIC", "BIC")) {

  ytrim  <- y[r1:r2]
  urca::ur.df(ytrim, type, lags, selectlags)@teststat
}


ur.sadf <- function(y, r0, type = c("none", "drift", "trend"),
                    lags = 1, selectlags = c("Fixed", "AIC", "BIC")) {

  adfs <- rep(NA, length(y) - r0)
  adfs[1] <- ur.adfr1r2(y,1,r0,type,lags,selectlags)
  j <- r0 + 1
  for (r2 in j:length(y)) {
    adfs[2 + r2 - j] <- ur.adfr1r2(y,1,r2,type,lags,selectlags)
  }
  maxstat <- max(adfs)
  list("stat" = maxstat, "sequence" = adfs)
}

ur.bsadf <- function(y, r0, r2, type = c("none", "drift", "trend"),
                     lags = 1, selectlags = c("Fixed", "AIC", "BIC")) {

  maxtstat <- ur.adfr1r2(y,1,r2,type,lags,selectlags)
  j <- r2 - r0
  for (r1 in 2:j) {
    temp <- ur.adfr1r2(y,r1,r2,type,lags,selectlags)
    if (temp > maxtstat) {
      maxtstat <- temp
    }
  }
  return(maxtstat)
}

ur.gsadf <- function(y, r0, type = c("none", "drift", "trend"),
                     lags = 1, selectlags = c("Fixed", "AIC", "BIC")) {

  bsadfs <- rep(NA, length(y) - r0)
  bsadfs[1] <- ur.bsadf(y,r0,r0,type,lags,selectlags)
  j <- r0 + 1
  for (r2 in j:length(y)) {
    bsadfs[2 + r2 - j] <- ur.bsadf(y,r0,r2,type,lags,selectlags)
  }
  maxstat <- max(bsadfs)
  list("stat" = maxstat, "sequence" = bsadfs)
}
