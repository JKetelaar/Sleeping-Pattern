source('../common/common.R')
loadPackages(c('rjson', 'twitteR', 'RMySQL'))

config <- fromJSON(file = '../config.json')
settings <- fromJSON(file = '../settings.json')

conn <- dbConnect(RMySQL::MySQL(),
                  host = config$mysql$host,
                  dbname = config$mysql$database,
                  user = config$mysql$user,
                  password = config$mysql$password)
data <- dbReadTable(conn, 'tweets')
dbDisconnect(conn)

data$date <- as.POSIXct(data$date, origin = '1970-01-01')

times = as.POSIXct(format(data$date, format = "%H:%M"), format = "%H:%M")
hist(times, 'hours', format = '%H:%M')
