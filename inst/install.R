## Sequence of commands to check and build the package 
## and generate html page documents

install.packages("devtools")
install.packages("pkgdown")

require(devtools)
require(pkgdown)

#set path to package home directory
package.dir <- normalizePath("../../fastRPackageInstall")

cat("Documenting...\n")
document(package.dir) # creates help pages

cat("Checking...\n")
check(package.dir) # checking

cat("Loading...\n")
load_all(package.dir) # loading

cat("Installing..\n")
install(package.dir, dependencies = TRUE) #installing
