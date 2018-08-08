rtadfDstamp <- function(y, r0, sigLevel, test) {

  t <- length(y)
  DSthreshold <- c(rep(NA, r0), rep(0 ,t - r0))
  for (r in r0:t) {
    DSthreshold[r] <- rtadfCval(r, sigLevel, testType = test)
  }

  return(DSthreshold)
}
