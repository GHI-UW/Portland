# Portland Metropolitan Area



```r
library("devtools")
#install_github("ITHIM/ITHIM", ref="devel", force = TRUE)
install("~/ITHIM/")
```

```
## Installing ITHIM
```

```
## '/Library/Frameworks/R.framework/Resources/bin/R' --no-site-file  \
##   --no-environ --no-save --no-restore --quiet CMD INSTALL  \
##   '/Users/syounkin/ITHIM'  \
##   --library='/Library/Frameworks/R.framework/Versions/3.3/Resources/library'  \
##   --install-tests
```

```
## 
```

```r
library("ITHIM")
```

```
## Loading required package: tidyverse
```

```
## ── Attaching packages ────────────────────────────────── tidyverse 1.2.1 ──
```

```
## ✔ ggplot2 2.2.1     ✔ purrr   0.2.4
## ✔ tibble  1.4.2     ✔ dplyr   0.7.4
## ✔ tidyr   0.8.0     ✔ stringr 1.3.0
## ✔ readr   1.1.1     ✔ forcats 0.3.0
```

```
## ── Conflicts ───────────────────────────────────── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

```
## Loading required package: reshape2
```

```
## 
## Attaching package: 'reshape2'
```

```
## The following object is masked from 'package:tidyr':
## 
##     smiths
```

```
## Welcome to ITHIM version 3.0.0.
## ~~~~~~~~~~~~~~~~~
## >()_  >()_  >()_ 
##  (__)  (__)  (__)
## ~~~~~~~~~~~~~~~~~
```

## May, 2018


```r
OHAS.df <- readRDS(file = "~/Bullitt/data/OHAS/OHAS.df.rds")
OHAS.list <- readRDS(file = "~/Bullitt/data/OHAS/OHAS.rds")
n.df <- inner_join(OHAS.list$PER,OHAS.list$HH,by = "SAMPN") %>% filter(!is.na(COUNTYNAME)) %>% select(SAMPN, COUNTYNAME) %>% group_by(COUNTYNAME) %>% summarise(n = n())

individual.df <- OHAS.df %>% group_by(COUNTYNAME, SAMPN, PERNO, MODE ) %>% select(COUNTYNAME, SAMPN, PERNO, PNAME, MODE, TRPDUR) %>% summarise(T = sum(TRPDUR)) %>% ungroup() %>% spread(MODE, T, fill = 0)%>% mutate(TA = 7*(3*walk/60 + 6*cycle/60))

activity.df <- individual.df %>% filter(TA != 0 & !is.na(COUNTYNAME)) %>% group_by(COUNTYNAME) %>% summarise(meanTA = mean(TA), sdTA = sd(TA), meanlogTA = mean(log(TA)), sdlogTA = sd(log(TA)))

fAT <- 1/4
p0.df <- individual.df %>% group_by(COUNTYNAME) %>% summarise( p0 = sum(TA == 0, na.rm = TRUE)/sum(!is.na(TA)) ) %>% mutate(p0.adj = p0*fAT)

parameters.df <- inner_join(activity.df, p0.df, by = "COUNTYNAME") %>% select(group = COUNTYNAME, p0 = p0.adj, meanlog = meanlogTA, sdlog = sdlogTA)

write.csv(parameters.df, file = "./data/activity.portland.baseline.csv", quote = FALSE, row.names = FALSE)

parameters.df.scenario <- within(parameters.df,{
    p0 <- p0 - 0.05
})

write.csv(parameters.df.scenario, file = "./data/activity.portland.scenario.csv", quote = FALSE, row.names = FALSE)

CRA.df <- CRA("./data/activity.portland.baseline.csv","./data/activity.portland.scenario.csv")
```


```r
full_join(
    p0.df,
    n.df ) %>%
    ggplot(aes(x = COUNTYNAME, y = p0, size = n)) +
    geom_point(aes(size = n)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
```

```
## Joining, by = "COUNTYNAME"
```

```
## Warning: Removed 1 rows containing missing values (geom_point).
```

![plot of chunk fig1](figure/fig1-1.png)


```r
full_join(activity.df, n.df, by = "COUNTYNAME") %>%
    ggplot(aes(x = COUNTYNAME, y = meanTA, fill = COUNTYNAME)) + geom_bar(stat = "identity") +
    geom_errorbar(aes(ymin = meanTA - 1.96*sdTA/sqrt(n), ymax = meanTA + 1.96*sdTA/sqrt(n))) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
```

```
## Warning: Removed 1 rows containing missing values (position_stack).
```

```
## Warning: Removed 4 rows containing missing values (geom_errorbar).
```

![plot of chunk fig2](figure/fig2-1.png)


```r
full_join(activity.df, n.df, by = "COUNTYNAME") %>%
    ggplot(aes(x = COUNTYNAME, y = meanlogTA, fill = COUNTYNAME)) + geom_bar(stat = "identity") +
    geom_errorbar(aes(ymin = meanlogTA - 1.96*sdlogTA/sqrt(n), ymax = meanlogTA + 1.96*sdlogTA/sqrt(n))) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
```

```
## Warning: Removed 1 rows containing missing values (position_stack).
```

```
## Warning: Removed 4 rows containing missing values (geom_errorbar).
```

![plot of chunk fig3](figure/fig3-1.png)

```r
parameters.df %>% ggplot(aes(x = sdlog, y = meanlog, size = 1-p0, label = group)) + geom_point()  + geom_text(aes(label = group), hjust=0, vjust=0)
```

```
## Warning: Removed 3 rows containing missing values (geom_point).
```

```
## Warning: Removed 3 rows containing missing values (geom_text).
```

![plot of chunk fig4](figure/fig4-1.png)

## Appendix
### ITHIM-R Implementation (January, 2018)
This is the code that mimics Excel.  The devel branch.

```r
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


```r
results.df %>% filter(vision == "ITHIM.2040.strategic" & disease == "Dementia" & burdenType == "daly" & sex == "F")
```

See _Health Summary_ worksheet cells _P33_-_P40_ for comparison.
Please be sure that the scenario _ITHIM.2040.strategic_ is selected on
the _user page_ worksheet.  The values returned by _superTabulate_ are
absoulte counts (not percentages).

