set.seed(1234)
data(snp)  # load S&P 500 data
snp <- snp[1:200,1]
T    <- length(snp)  # Sample size
r0   <- round(T*(0.01 + 1.8/sqrt(T)))  # Minimal window size

test <- rtadf(snp, r0, test = "sadf")  # estimate test statistic and date-stamping sequence
cvs  <- rtadfSimPar(T, nrep = 100, r0, test = "sadf")  # simulate critical values and date-stamping threshold

testDf <- list("test statistic" = test$testStat, "critical values" = cvs$testCVs)  # test results

print(testDf)

dateStampDf <- ts(cbind(test$testSeq, cvs$datestampCVs[,2]),
                  start = c(1870,1), frequency = 12)  # data for datestamping procedure

ts.plot(dateStampDf, plot.type = "single", col = c("blue", "red"))
