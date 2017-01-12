library(shiny)

weatherByDay <- readData()

weatherByDay$day <- as.Date(weatherByDay$day, '%Y-%m-%d')

shinyServer(function(input, output) {
  x <- list(title = 'Day')
  y <- list(title = 'Temp(Celcius)')
  
  output$weather <- renderPlotly({
    day <- weatherByDay[weatherByDay$night == 0,]
    night <- weatherByDay[weatherByDay$night == 1,]
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
        xaxis = x,
        yaxis = y,
        yaxis2 = list(
          title = 'Asleep / Awake',
          side = 'right',
          overlaying = 'y'
        )
      )
    
  })
  
  output$frequency <- renderPlotly({
    day <- weatherByDay[weatherByDay$night == 0,]
    night <- weatherByDay[weatherByDay$night == 1,]
    
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
        xaxis = x,
        yaxis = y,
        yaxis2 = list(
          title = 'Frequency',
          side = 'right',
          overlaying = 'y'
        )
      )
    
    
  })
  
})
