source('../common/common.R')
loadPackages(c('rjson', 'RMySQL', 'reshape', 'ggplot2', 'plyr'))
library("devtools")
install_github("ozagordi/weatherData")
library("weatherData")
require(data.table)

settings <- fromJSON(file = '../settings.json')
config <- fromJSON(file = '../config.json')

conn <- dbConnect(
  RMySQL::MySQL(),
  host = config$mysql$host,
  dbname = config$mysql$database,
  user = config$mysql$user,
  password = config$mysql$password
)

toDataFrame <- function(result, station) {
  out <- data.frame(
    date = result$Time.1,
    wind = result$WindSpeedKMH,
    temp = result$TemperatureC,
    air_pressure = result$PressurehPa,
    rain = result$dailyrainMM
  )
  out$source = station
  return(out)
}

getData <- function(station) {
  result <-
    getWeatherForDate(
      station,
      Sys.Date() - 1,
      opt_detailed = TRUE,
      opt_all_columns = TRUE,
      station_type = "ID"
    )
  toDataFrame(result, station)
}

insertIntoDatabase <- function(data) {
  dbWriteTable(conn,
               'knmi',
               data,
               append = T,
               row.names = F)
}

data <- NULL

for (country in settings$countries) {
  for (region in country$regions) {
    data <- rbind(data, getData(region$station))
  }
}

data <- data[data$date != '<br>', ]

colnames(data) <-
  c('date',
    'wind',
    'temperature',
    'air_pressure',
    'rain',
    'source')
insertIntoDatabase(data)

#source <- data$source
#temp <- data$temp
#date <- data$date

apply.hourly <- function(x, FUN,...) {
  ep <- endpoints(x, 'hours')
  period.apply(x, ep, FUN, ...)
}

dat.xts <- xts(data$temp,
               as.POSIXct(data$date))
apply.hourly(dat.xts,sum)

head(data$date)

substr("2016-10-26 00:00:00", 0, 13)

x <- ddply(
  data, 
  .(when=substr(date, 0, 13)), 
  summarize, 
  temp=mean(temperature)
)

data$hour <- as.POSIXlt(data$date)$hour
ggplot(data, aes(hour, temperature, colour=source)) + 
  geom_line() + 
  geom_point() +
  theme_bw()

ggplot(df, aes(x=date, y=temp, colour=factor(source))) + 
  geom_point(size=2, shape=19)