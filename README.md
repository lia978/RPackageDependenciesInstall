# RPackageDependenciesInstall

Fast installation of R package dependencies from specified DESCRIPTION file (supports CRAN and Bioconductor packages)

## Instructions for installation
```R
install.packages("devtools")
library(devtools)
install_github("lia978/RPackageDependenciesInstall")
```

## Example walkthrough

```R
#install R package dependencies
library(RPackageDependenciesInstall)
desc_file<-"https://raw.githubusercontent.com/montilab/CBMRtools/master/CBMRtools/DESCRIPTION"
fast_install(filename = desc_file, url = TRUE, verbose = TRUE)

## proceed to install R package as normal
library(devtools)
install_github("montilab/CBMRtools/CBMRtools")
