install.packages("devtools")

library("devtools")
install_github("Ram-N/weatherData")

x <-
  getWeatherForDate(
    "IZUIDHOL301",
    "2016-10-06",
    opt_detailed = TRUE,
    opt_all_columns = TRUE,
    station_type = "ID"
  )

date <- x$Time
source <- "IZUIDHOL301"
wind <- x$WindSpeedKMH
temp <- x$TemperatureC
min_temp <- min(x$TemperatureC)
max_temp <- max(x$TemperatureC)
air_pressure <- x$PressurehPa
rain <- x$dailyrainMM