loadPackages <- function(packages) {
	toInstall <- setdiff(packages, rownames(installed.packages()))
	if(length(toInstall) > 0) {
		install.packages(toInstall, repos = 'http://cran.r-project.org')
	}
	lapply(packages, function(x) {
		library(x, character.only = T)
	})
}

norm <- function(vals) {
  maxVal <- max(vals)
  minVal <- min(vals)
  (vals - minVal) / (maxVal - minVal)
}