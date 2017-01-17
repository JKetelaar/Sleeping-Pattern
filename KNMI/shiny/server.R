library(shiny)

tData <- TWITTER$analyzeData(KNMI$readTwitterData())
tData$day <- as.Date(tData$day, '%Y-%m-%d')
gData <- GTRENDS$applyWeights(KNMI$readGtrendsData())
gData$day <- as.Date(gData$day, '%Y-%m-%d')
tData$one <- 1
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
    twitterDataW <- tData[tData$country == country$name, ]
    gtrendsDataW <- gData[gData$location == country$geoCountryCode, ]
    if(!is.null(region)) {
      twitterDataW <- twitterDataW[twitterDataW$region == region$name, ]
    }
    twitterDataW <- aggregate(twitterDataW$weight, list(day = twitterDataW$day), mean)
    gtrendsDataW <- aggregate(gtrendsDataW$weight, list(day = gtrendsDataW$day), mean)
    gtrendsDataW$x <- norm(gtrendsDataW$x) * 2 - 1
    aggData <- merge(gtrendsDataW, twitterDataW, by = 'day', all = T)
    aggData[is.na(aggData)] <- 0
    aggData$a <- aggData$x.x * 0.5 + aggData$x.y * 0.5
    aggData$x.x <- NULL
    aggData$x.y <- NULL

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
        x = aggData$day,
        y = aggData$a,
        name = 'Aggregated',
        yaxis = "y2"
      ) %>%
      add_trace(
        x = twitterDataW$day,
        y = twitterDataW$x,
        name = 'Twitter',
        yaxis = "y2",
        visible = 'legendonly'
      ) %>%
      add_trace(
        x = gtrendsDataW$day,
        y = gtrendsDataW$x,
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
    gFreq <- gData[gData$location == country$geoCountryCode, ]
    tFreq <- tData[tData$country == country$name, ]
    if(!is.null(region)) {
      tFreq <- tFreq[tFreq$region == region$name, ]
    }
    gFreq <- aggregate(gFreq$percentage, list(day = gFreq$day), sum)
    tFreq <- aggregate(tFreq$one, list(day = tFreq$day), sum)
    gFreq$x <- norm(gFreq$x)
    tFreq$x <- norm(tFreq$x)
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
        x = tFreq$day,
        y = tFreq$x,
        name = 'Tweet Frequency',
        yaxis = "y2"
      ) %>%
      add_trace(
        x = gFreq$day,
        y = gFreq$x,
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
