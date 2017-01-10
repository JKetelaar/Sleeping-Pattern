source('../../common/common.R')
loadPackages(c('rjson', 'RMySQL'))

config <- fromJSON(file = '../../config.json')
settings <- fromJSON(file = '../../settings.json')

readData <- function() {
  conn <- dbConnect(RMySQL::MySQL(),
                    host = config$mysql$host,
                    dbname = config$mysql$database,
                    user = config$mysql$user,
                    password = config$mysql$password)
  data <- dbGetQuery(conn, 'SELECT AVG(`temperature`) AS `temperature`, AVG(`rain`) AS `rain`, DATE(`date`) AS `day`, (HOUR(`date`) > 17 OR HOUR(`date`) < 5) AS `night` FROM (SELECT * FROM `knmi` WHERE `temperature` > -573.3) AS `fixd` GROUP BY `night`, `day`')
  dbDisconnect(conn)
  data
}