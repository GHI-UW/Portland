# Portland Metropolitan Area
## ITHIM-R Implementation (January, 2018)

```{r, libs, echo = TRUE, warning = FALSE}
library("devtools")
install_github("ITHIM/ITHIM", ref="devel", force = TRUE)
library("ITHIM")
```

```{r, files}
activeTransportFile <- system.file("activeTravelOHAS.csv", package = "ITHIM")
GBDFile <- system.file("gdb_MetroMPA_Final_01262018.csv", package = "ITHIM")
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
                                             muwt = 4.525987*7,
                                             Rwt = Rwt,
                                             muct = 2.214794*7,
                                             Rct = Rct,
                                             cv = 1.648256,
                                             quantiles = c(0.1,0.3,0.5,0.7,0.9),
                                             EXCEL = TRUE
                                         ))


ITHIM.2027.constrained <- update(ITHIM.baseline, list(muwt = 5.064392*7, muct = 2.522432*7, cv = 1.639119))
ITHIM.2040.nobuild     <- update(ITHIM.baseline, list(muwt = 4.853009*7, muct = 2.657815*7, cv = 1.639940))
ITHIM.2040.constrained <- update(ITHIM.baseline, list(muwt = 5.415949*7, muct = 2.838158*7, cv = 1.631912))
ITHIM.2040.strategic   <- update(ITHIM.baseline, list(muwt = 5.603935*7, muct = 2.794518*7, cv = 1.630353))

ITHIM.scenario.list <- list(
    ITHIM.2027.constrained = ITHIM.2027.constrained,
    ITHIM.2040.nobuild = ITHIM.2040.nobuild,
    ITHIM.2040.constrained = ITHIM.2040.constrained,
    ITHIM.2040.strategic = ITHIM.2040.strategic
)

results.df <- superTabulate(ITHIM.baseline, ITHIM.scenario.list)
write.csv(results.df, file = "./results.csv", quote = FALSE, row.names = FALSE)
```

### Compare to Excel workbook

```{r results, echo = TRUE}
results.df %>% filter(vision == "ITHIM.2040.strategic" & disease == "Dementia" & burdenType == "daly" & sex == "F")
```

See _Health Summary_ worksheet cells _P33_-_P40_ for comparison.
Please be sure that the scenario _ITHIM.2040.strategic_ is selected on
the _user page_ worksheet.  The values returned by _superTabulate_ are
absoulte counts (not percentages).
