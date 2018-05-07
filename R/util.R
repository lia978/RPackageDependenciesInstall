#' Install R package dependencies from DESCRIPTION file
#' @param filename path to DESCRIPTION file.
#' @param verbose optional text output of installation status.
#' @export
fast_install<-function(filename, verbose=TRUE){
	packages<-get_deps(filename)
	packages.status<-lapply(packages,fast_install_package)
	names(packages.status)<-packages
	status<-table(unlist(packages.status))
	status.names<-names(status)
	status.values<-lapply(status.names, function(i){
		paste(packages[which(packages.status %in% i)], collapse = ", ")
		})
	msg<-paste0(status, " packages with status \'", status.names, "\': ", status.values)
	VERBOSE(verbose, msg)
	return(packages.status)
}

#' Get list of package dependencies from DESCRIPTION file
#' @param filename path to DESCRIPTION file.
#' @export
get_deps<-function(filename #name of DESCRIPTION file
	){

	#read in DESCRIPTION file
	str<-scan(filename, what="character", sep="\n", quiet = T)

	##combine lines if is continuation of previous file (indicated by lack of seperator)
	str2<-c()
	for(i in 1:length(str)){
		str.curr<-str[i]
		#if new item
		if(grepl(":", str.curr)){
			str2<-c(str2, str.curr)
		}
		#if appending item
		else {
			str2[length(str2)]<-paste0(str2[length(str2)], str.curr)
		}
	}

	#turn lists into key, value, and value list format triples
	str3<-lapply(str2, function(i){
		j<-strsplit(i, split = ":")[[1]]
		j.name<-j[1]
		j.value<-j[2]
		j.value.list<-strsplit(gsub(" ", "", j.value), split = ",")[[1]]
		return(list(name = j.name, value = j.value, value.list = j.value.list))
		})
	names(str3)<-lapply(str3, function(i) i$name)

	#list elements whose value lists are package dependencies
	fields<-c("Depends", "Imports", "Suggests")
	packages<-lapply(fields, function(i){
		str3[[i]]$value.list
		})

	packages<-unique(unlist(packages))
	packages<-packages[!grepl("R\\(.*\\)", packages)]
	return(packages)

}

#' Install a single package
#' @param pkg package name to be installed.
#' @param verbose optional text input to display installation status.
#' @param ind index for CRAN mirror selection
#' @param ... optional parameters for install.packages()
#' @export
fast_install_package <- function(pkg, #package name
	verbose = FALSE,
	ind = 57, #index for mirror selection
	... ){
	if(require(pkg, character.only = TRUE)){
		VERBOSE(verbose, paste0(pkg," is already installed and loaded"))
		return("preinstalled")
	} else {
		chooseCRANmirror(ind = ind, graphics = FALSE)

		#attempt to install through bioconductor first
		VERBOSE(verbose, paste0("attempting to install ", pkg, " through bioconductor"))
		
		source("http://bioconductor.org/biocLite.R")
		biocLite(pkg)

		if(require(pkg, character.only = TRUE)){
			VERBOSE(verbose, paste0("installing ",pkg, " through bioconductor"))
			return("successfully installed through bioconductor")
		} else {
			#attempt to install through CRAN
			VERBOSE(verbose, paste0("could not install ",pkg, " through bioconductor"))
			VERBOSE(verbose, paste0("attempting to install ",pkg, " through CRAN"))
			
			install.packages(pkg, graphics = FALSE, ...)
			if(require(pkg, character.only = TRUE)){
				VERBOSE(verbose, paste0("successfull installed ",pkg, " through CRAN"))
				return("installed through CRAN")
			} 
		}
	}
	return("installation failed")
} 




