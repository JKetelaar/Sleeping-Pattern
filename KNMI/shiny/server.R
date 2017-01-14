library(shiny)

weatherByDay <- KNMI$readData()

weatherByDay$day <- as.Date(weatherByDay$day, '%Y-%m-%d')

x <- list(title = 'Day')
y <- list(title = 'Temp(Celcius)')

modifyTemp <- function(region, data) {
  if(is.null(region)) {
    data <- aggregate(data$temperature, list(day = data$day), mean)
    data$temperature <- data$x
  } else {
    data <- data[data$source == region$station,]
  }
  data
}

weatherWithAnalyticsData <- function(input, output)  {
  output$weather <- renderPlotly({
    country <- settings$countries[[as.integer(input$country)]]
    index <- as.integer(input$region)
    if (is.null(input$region)) {
      index <- 0
    }
    region <- NULL
    if (index > 0 && index <= length(country$regions)) {
      region <- country$regions[[index]]
    }
    day <- modifyTemp(region, weatherByDay[weatherByDay$night == 0,])
    night <- modifyTemp(region, weatherByDay[weatherByDay$night == 1,])
    plot_ly(
      night,
      x = ~ day,
      y = ~ temperature,
      type = 'scatter',
      mode = 'lines',
      name = 'Night Temp'
    ) %>%
      add_trace(x = day$day,
                y = day$temperature,
                name = 'Day Temp') %>%
      add_trace(
        x = KNMI$aggData$day,
        y = KNMI$aggData$a,
        name = 'Aggregated',
        yaxis = "y2"
      ) %>%
      add_trace(
        x = twitterData$day,
        y = twitterData$x,
        name = 'Twitter',
        yaxis = "y2",
        visible = 'legendonly'
      ) %>%
      add_trace(
        x = gtrendsData$day,
        y = gtrendsData$x,
        name = 'Gtrends',
        yaxis = "y2",
        visible = 'legendonly'
      ) %>%
      layout(
        showlegend = TRUE,
        title = 'Weather and Analytics Data',
        xaxis = x,
        yaxis = y,
        yaxis2 = list(
          title = 'Asleep / Awake',
          side = 'right',
          overlaying = 'y'
        )
      )
    
  })
}

weatherWithFrequency <- function(input, output) {
  output$frequency <- renderPlotly({
    country <- settings$countries[[as.integer(input$country)]]
    index <- as.integer(input$region)
    if (is.null(input$region)) {
      index <- 0
    }
    region <- NULL
    if (index > 0 && index <= length(country$regions)) {
      region <- country$regions[[index]]
    }
    day <- modifyTemp(region, weatherByDay[weatherByDay$night == 0,])
    night <- modifyTemp(region, weatherByDay[weatherByDay$night == 1,])
    
    plot_ly(
      night,
      x = ~ day,
      y = ~ temperature,
      type = 'scatter',
      mode = 'lines',
      name = 'Night Temp'
    ) %>%
      add_trace(x = day$day,
                y = day$temperature,
                name = 'Day Temp') %>%
      add_trace(
        x = KNMI$tFreq$day,
        y = KNMI$tFreq$x,
        name = 'Tweet Frequency',
        yaxis = "y2"
      ) %>%
      add_trace(
        x = KNMI$gFreq$day,
        y = KNMI$gFreq$x,
        name = 'Search Frequency',
        yaxis = "y2"
      ) %>%
      layout(
        showlegend = TRUE,
        title = 'Weather, Tweet Frequency and Search Frequency',
        xaxis = x,
        yaxis = y,
        yaxis2 = list(
          title = 'Frequency',
          side = 'right',
          overlaying = 'y'
        )
      )
    
    
  })
}
