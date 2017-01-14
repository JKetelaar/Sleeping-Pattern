source('../../common/common.R')
loadPackages(c('rjson', 'RMySQL', 'plotly'))


#config <- fromJSON(file = '../../config.json')
#settings <- fromJSON(file = '../../settings.json')

readData <- function() {
  conn <- dbConnect(RMySQL::MySQL(),
                    host = config$mysql$host,
                    dbname = config$mysql$database,
                    user = config$mysql$user,
                    password = config$mysql$password)
  data <- dbGetQuery(conn, 'SELECT `source`, AVG(`temperature`) AS `temperature`, AVG(`rain`) AS `rain`, DATE(`date`) AS `day`, (HOUR(`date`) > 17 OR HOUR(`date`) < 5) AS `night` FROM (SELECT * FROM `knmi` WHERE `temperature` > -573.3) AS `fixd` GROUP BY `source`, `night`, `day`')
  dbDisconnect(conn)
  data
}

readTwitterData <- function() {
  conn <- dbConnect(RMySQL::MySQL(),
                    host = config$mysql$host,
                    dbname = config$mysql$database,
                    user = config$mysql$user,
                    password = config$mysql$password)
  data <- dbGetQuery(conn, 'SELECT `date`, `latitude`, `longitude`, `tweet`, DATE(FROM_UNIXTIME(`date`)) AS `day` FROM `tweets`')
  dbDisconnect(conn)
  data
}

readGtrendsData <- function() {
  conn <- dbConnect(RMySQL::MySQL(),
                    host = config$mysql$host,
                    dbname = config$mysql$database,
                    user = config$mysql$user,
                    password = config$mysql$password)
  data <- dbGetQuery(conn, 'SELECT DATE(`time`) AS `day`, `keyword`, `percentage`, `location` FROM google_trends')
  dbDisconnect(conn)
  data
}

tData <- TWITTER$analyzeData(readTwitterData())
tData$day <- as.Date(tData$day, '%Y-%m-%d')
twitterData <- aggregate(tData$weight, list(day = tData$day), mean)

gData <- GTRENDS$applyWeights(readGtrendsData())
gData$day <- as.Date(gData$day, '%Y-%m-%d')
gtrendsData <- aggregate(gData$weight, list(day = gData$day), mean)
gtrendsData$x <- norm(gtrendsData$x) * 2 - 1

aggData <- merge(gtrendsData, twitterData, by = 'day', all = T)
aggData[is.na(aggData)] <- 0
aggData$a <- aggData$x.x * 0.5 + aggData$x.y * 0.5
aggData$x.x <- NULL
aggData$x.y <- NULL

tData$one <- 1
gFreq <- aggregate(gData$percentage, list(day = gData$day), sum)
tFreq <- aggregate(tData$one, list(day = tData$day), sum)
gFreq$x <- norm(gFreq$x)
tFreq$x <- norm(tFreq$x)
