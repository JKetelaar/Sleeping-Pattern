source('../common/common.R')
loadPackages(c('weatherData', 'rjson'))

settings <- fromJSON(file = '../settings.json')

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

data <- NULL

for (country in settings$countries) {
  for (region in country$regions) {
    data <- rbind(data, getData(region$station))
  }
}

data <- data[data$date != '<br>',]