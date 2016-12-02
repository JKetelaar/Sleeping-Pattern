source('../../common/common.R')
loadPackages(c('rjson', 'twitteR', 'RMySQL', 'geosphere'))

config <- fromJSON(file = '../../config.json')
settings <- fromJSON(file = '../../settings.json')

readData <- function() {
  conn <- dbConnect(RMySQL::MySQL(),
                    host = config$mysql$host,
                    dbname = config$mysql$database,
                    user = config$mysql$user,
                    password = config$mysql$password)
  data <- dbReadTable(conn, 'tweets')
  dbDisconnect(conn)
  data
}

inRange <- function(tweet, region) {
  llT <- c(tweet$latitude, tweet$longitude)
  llR <- c(region$latitude, region$longitude)
  distm(llT, llR) <= (region$radius * 1000)
}

locationCache = new.env(hash = T)

getCountry <- function(tweet) {
  if(!is.na(tweet$latitude) && !is.na(tweet$longitude)) {
    key <- paste(tweet$latitude, ' ', tweet$longitude)
    if(!is.null(locationCache[[key]])) {
      return(locationCache[[key]])
    }
    c <- 1
    for(country in settings$countries) {
      r <- 1
      for(region in country$regions) {
        if(inRange(tweet, region)) {
          out <- c(c, r)
          locationCache[[key]] <- out
          return(out)
        }
        r <- r + 1
      }
      c <- c + 1
    }
  }
  NA
}

getWeight <- function(tweet, country) {
  if(!is.na(country)) {
    weight <- 0
    for(term in country$twitterTerms) {
      if(grepl(term, tweet$tweet, ignore.case = T)) {
        weight <- weight + country$twitterWeights[[term]]
      }
    }
    return(weight)
  }
  NA
}

analyzeData <- function(data) {
  countries <- c()
  weights <- c()
  regions <- c()
  i <- 1
  rows <- nrow(data)
  while (i <= rows) {
    tweet <- data[i,]
    loc <- getCountry(tweet)
    country <- settings$countries[[loc[1]]]
    countries <- c(countries, country$name)
    regions <- c(regions, country$regions[[loc[2]]]$name)
    weights <- c(weights, getWeight(tweet, country))
    i <- i + 1
  }
  data$weight <- weights
  data$country <- countries
  data$region <- regions
  data$hour <- as.integer((data$date %% 86400) / 3600)
  data
}

# data <- readData()
# data <- analyzeData(data)
# plot(aggregate(data$weight, list(Hour = data$hour), sum), type = 'h')