source("../common/common.R")
loadPackages(c("lubridate", "plyr", "ggplot2", "rjson", "RMySQL"))

settings <- fromJSON(file = "../settings.json")
config <- fromJSON(file = "../config.json")

conn <- dbConnect(RMySQL::MySQL(),
                  host = config$mysql$host,
                  dbname = config$mysql$database,
                  user = config$mysql$user,
                  password = config$mysql$password)

stringToMinutes <- function(x) {
  x <- as.numeric(x)
  x[1]*60 + x[2]
}

toDataFrame <- function(data, sep) {
  if (nrow(data) > 1) {
    names(data) <- tolower(names(data))
    
    for (tag in settings$sleepcycleTags) {
      if (is.null(data[[tag]])) {
        data[[tag]] <- NA
      }
      
      if (tag == "time.in.bed"){
        data[[tag]] <- sapply(strsplit(as.character(data[[tag]]), ":"), stringToMinutes)
      }
      
      if (tag == "sleep.quality"){
        data[[tag]] <- as.integer(gsub("%", "", as.character(data[[tag]])))
      }
    }
    return(data)
  } else{
    warning("Doesn't seem like a proper CSV, or does it?")
  }
}

removeDatabaseDuplicates <- function(data, username){
  rs <- dbSendQuery(conn, sprintf("SELECT * FROM `sleep_cycle` WHERE `username` LIKE '%s'", dbEscapeStrings(conn, username)))
  data <- fetch(rs, n=-1)
  return(data)
}

# Examples
# sleep <-read.csv(file = "../data/sleep-cycle/sleepdata-kwdoyle.csv", header = TRUE, sep = ",")
# result <- toDataFrame(sleep)

# Read folder
# filenames <- list.files(path = "/Users/thomsuykerbuyk/github/sleepdata_test")
# sleep <- do.call("rbind", lapply(filenames, read.csv, header = TRUE))