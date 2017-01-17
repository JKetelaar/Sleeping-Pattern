source('../../common/common.R')
loadPackages(c('rjson', 'RMySQL', 'plotly'))

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
