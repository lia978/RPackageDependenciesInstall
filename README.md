# fastRPackageInstall

Fast installation of R package dependencies (supports CRAN and Bioconductor packages)

## instructions for installation
```R
install.packages("devtools")
library(devtools)
install_github("lia978/fastRPackageInstall")
```

##example walkthrough

```R
library(fastRPackageInstall)
desc_file<-"https://raw.githubusercontent.com/montilab/CBMRtools/master/CBMRtools/DESCRIPTION"
fast_install(filename = desc_file, url = TRUE, verbose = TRUE) 
