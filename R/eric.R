
library("devtools")

#install("~/ITHIM/")
install_github("ITHIM/ITHIM", ref="devel")
library("ITHIM")
activeTransportFile <- system.file("activeTravelOHAS.csv", package = "ITHIM")
GBDFile <- system.file("gdb_MetroMPA_Final_12222017.csv", package = "ITHIM")
FFile <- system.file("F.portland.11_21_2017.csv", package = "ITHIM")

ITHIM.baseline <- createITHIM( activeTransportFile = activeTransportFile, GBDFile = GBDFile, FFile = FFile)

Rwt <- ITHIM.baseline@parameters@Rwt
Rwt[1,] <- c(0.4305,0.3471)
Rwt[2,] <- c(0.4934,0.4814)

Rct <- ITHIM.baseline@parameters@Rct
Rct[1,] <- c(0.2935,0.1231)
Rct[2,] <- c(1.3194,0.8278)
Rct[8,] <- c(0.1,0.1)

ITHIM.baseline <- update(ITHIM.baseline, list(
  muwt = 21.37996926,
  Rwt = Rwt,
  muct = 15.50355926,
  Rct = Rct,
  cv = 1.6483,
  quantiles = c(0.1,0.3,0.5,0.7,0.9)
))

ITHIM.baseline <- update(ITHIM.baseline, list(muwt = 21.37996926, Rwt = Rwt, muct = 15.50355926, Rct = Rct,cv = 1.6483, quantiles = c(0.1,0.3,0.5,0.7,0.9)))

ITHIM.2040.nobuild <-     update(ITHIM.baseline, list(muwt = 21.8917543173484, muct = 17.6570265353853, cv = 1.64247437041186))
ITHIM.2027.constrained <- update(ITHIM.baseline, list(muwt = 22.0263570473938, muct = 18.6047053305233, cv = 1.64414417619357))
ITHIM.2040.constrained <- update(ITHIM.baseline, list(muwt = 22.828614937802, muct = 19.8671063791508, cv = 1.63928889662021))
ITHIM.2040.strategic <-   update(ITHIM.baseline, list(muwt = 22.6715071450601, muct = 19.5616261437237, cv = 1.64000260386367))

ITHIM.scenario.list <- list(
  ITHIM.2027.constrained = ITHIM.2027.constrained,
  ITHIM.2040.nobuild = ITHIM.2040.nobuild,
  ITHIM.2040.constrained = ITHIM.2040.constrained,
  ITHIM.2040.strategic = ITHIM.2040.strategic
)

results.df <- superTabulate(ITHIM.baseline, ITHIM.scenario.list)

results.df %>% tail




write.csv(results.df, file = "./results.csv", quote = FALSE, row.names = FALSE)
head(results.df)


write.csv(results.df, file=choose.files(caption="Save As...", filters = c("Comma Delimited Files (.csv)",".csv")),row.names = FALSE)


