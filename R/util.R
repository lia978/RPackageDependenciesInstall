#' Install R package dependencies from DESCRIPTION file
#' @param filename path to DESCRIPTION file.
#' @param url specified if filename is an url: must be raw content, if from github, must be specified as raw.githubusercontent.com/PATH
#' @param verbose optional text output of installation status.
#' @export
fast_install<-function(filename, 
	url = TRUE, 
	verbose=TRUE){
	packages<-get_deps(filename, url = url)
	packages.status<-lapply(packages,fast_install_single_package)
	names(packages.status)<-packages
	status<-table(unlist(packages.status))
	status.names<-names(status)
	status.values<-lapply(status.names, function(i){
		paste(packages[which(packages.status %in% i)], collapse = ", ")
		})
	msg<-paste(paste0(status, 
		" packages with status \'", 
		status.names, 
		"\': ", 
		status.values),
		collapse = "\n")
	VERBOSE(verbose, msg)
	VERBOSE(verbose, "\n")
}

#' Get list of package dependencies from DESCRIPTION file
#' @param filename path to DESCRIPTION file.
#' @param url specified if filename is an url.
#' @export
get_deps<-function(filename, #name of DESCRIPTION file
	url = TRUE
	){

	#read in DESCRIPTION file
	if(!url)
		str<-scan(filename, what="character", sep="\n", quiet = T)
	else 
		str<-suppressWarnings(scan(url(filename), what="character", sep="\n", quiet = T))
	
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
	
	if(is.null(packages)) stop("error reading DESCRIPTION filename, check that the file content is a valid DESCRIPTION file")
	else return(packages)

}

#' Install a single package
#' @param pkg package name to be installed.
#' @param verbose optional text input to display installation status.
#' @param ind index for CRAN mirror selection
#' @param ... optional parameters for install.packages()
#' @export
fast_install_single_package <- function(pkg, #package name
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
			return("successfully installed through bioconductor")
		} else {
			#attempt to install through CRAN
			VERBOSE(verbose, paste0("could not install ",pkg, " through bioconductor"))
			VERBOSE(verbose, paste0("attempting to install ",pkg, " through CRAN"))
			
			install.packages(pkg, graphics = FALSE, ...)

			if(require(pkg, character.only = TRUE)){
				VERBOSE(verbose, paste0("successfully installed ",pkg, " through CRAN"))
				return("installed through CRAN")
			} 
		}
	}
	return("installation failed")
} 


VERBOSE <- function( v, ... )
{
  if ( v ) cat( ... )
}


