source('../common/common.R')
loadPackages(c('weatherData', 'rjson'))

settings <- fromJSON(file = './settings.json')

toDataFrame <- function(result, station) {
  do.call(rbind,
          lapply(result,
                 function(x) {
                   c(
                     date = x$Time,
                     source = station,
                     wind = x$WindSpeedKMH,
                     temp = x$TemperatureC,
                     min_temp = min(x$TemperatureC),
                     max_temp = max(x$TemperatureC),
                     air_pressure = x$PressurehPa,
                     rain = x$dailyrainMM
                   )
                 }))
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

data <- NULL

for (country in settings$countries) {
  for (region in country$regions) {
    data <- rbind(data, getData(region$station))
  }
}