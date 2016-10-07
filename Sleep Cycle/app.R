source("../common/common.R")
loadPackages(c("lubridate", "plyr", "ggplot2", "rjson"))

settings <- fromJSON(file = "../settings.json")

toDataFrame <- function(data, sep) {
  if (nrow(data) > 1) {
    names(data) <- tolower(names(data))
    
    for (tag in settings$sleepcycleTags) {
      if (is.null(data[[tag]])) {
        data[[tag]] <- NA
      }
    }
    return(data)
  } else{
    warning("Doesn't seem like a proper CSV, or does it?")
  }
}

#sleep <-
  #read.csv(file = "../data/sleep-cycle/sleepdata-thom.csv", header = TRUE, sep = ",")
#result <- toDataFrame(sleep)