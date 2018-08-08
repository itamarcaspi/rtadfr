x <- read.csv("data/gsadfSurfaceCoefs")
surfParams$gsadf <- x
devtools::use_data(surfParams, internal = TRUE, overwrite = TRUE)
