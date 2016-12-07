source('../../common/common.R')
loadPackages(c('rjson', 'RMySQL'))

config <- fromJSON(file = '../../config.json')
settings <- fromJSON(file = '../../settings.json')

loadData <- function() {
  conn <- dbConnect(
    RMySQL::MySQL(),
    host = config$mysql$host,
    dbname = config$mysql$database,
    user = config$mysql$user,
    password = config$mysql$password
  )
  
  
  data <-
    dbGetQuery(
      conn,
      'SELECT HOUR(`time`) AS `hour`, DAYOFWEEK(`time`) AS `day`, `keyword`, `percentage`, `location` FROM google_trends'
    )
  dbDisconnect(conn)
  data$weight <- 0
  for(country in settings$countries) {
    keywords <-
      c(country$gtrendsTerms,
        country$specialTerm)
    for(keyword in keywords) {
      data$weight <-
        data$weight + (data$keyword == keyword & data$location == country$geoCountryCode) * data$percentage * country$gtrendsWeights[[keyword]]
    }    
  }
  data
}

originalData <- loadData()
