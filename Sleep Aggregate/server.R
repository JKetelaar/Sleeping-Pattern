library(shiny)

fixIfNoData <- function(df) {
  if (nrow(df) < 24) {
    i <- 0
    while (i < 24) {
      if (nrow(df[df$Hour == i, ]) == 0) {
        df <- rbind(df, data.frame(Hour = i, x = 0))
      }
      i <- i + 1
    }
    df <- df[order(df$Hour), ]
  }
  df
}

regionCAggregate <- function(input, output) {
  renderUI({
    regions <- list('All' = 0)
    i <- 1
    for (region in settings$countries[[as.integer(input$country)]]$regions) {
      regions[[region$name]] <- i
      i <- i + 1
    }
    selectInput('region',
                label = 'Region',
                selected = 0,
                choices = regions)
  })
}

sleepAggregate <- function(input, output) {
  renderPlotly({
    country <- settings$countries[[as.integer(input$country)]]
    index <- as.integer(input$region)
    if (is.null(input$region)) {
      index <- 0
    }
    region <- NULL
    if (index > 0 && index <= length(country$regions)) {
      region <- country$regions[[index]]
    }
    gData <-
      gtrendsData[gtrendsData$location == country$geoCountryCode, ]
    tData <- twitterData[twitterData$country == country$name, ]
    if (!is.null(region)) {
      tData <- tData[tData$region == region$name, ]
    }
    if (input$days != 0) {
      gData <- gData[gData$day == input$days, ]
      tData <- tData[tData$day == input$days, ]
    }
    method <- sum
    if (input$method == 'mean') {
      method <- mean
    }
    if (nrow(tData) == 0 || nrow(gData) == 0) {
      msg <-
        plot(
          NULL,
          NULL,
          xlim = c(0, 100),
          ylim = c(0, 20),
          xaxt = 'n',
          ann = FALSE,
          yaxt = 'n',
          frame.plot = FALSE
        )
      text(8, 20, "No data")
      return(msg)
    }
    gData <-
      aggregate(gData$weight, list(Hour = gData$hour), method)
    tData <-
      aggregate(tData$weight, list(Hour = tData$hour), method)
    gData$x <- norm(gData$x) * 2 - 1
    tData$x <- norm(tData$x) * 2 - 1
    combinedData <-
      fixIfNoData(gData)$x * 0.5 + fixIfNoData(tData)$x * 0.5
    
    x <- list(
      title = 'Hour'
    )
    y <- list(
      title = 'Asleep / Awake'
    )
    
    out <- plot_ly(gData, x = ~Hour, y = ~x, type = 'scatter', mode = 'lines', name = 'Gtrends') %>%
    add_trace(x = tData$Hour, y = tData$x, name = 'Twitter') %>%
    add_trace(x = gData$Hour, y = combinedData, name = 'Aggregated') %>%
    layout(showlegend = TRUE, xaxis = x, yaxis = y)
    out
    
  })
  
}

totalsAggregate <- function(input, output) {
  renderPlotly({
    country <- settings$countries[[as.integer(input$country)]]
    index <- as.integer(input$region)
    if (is.null(input$region)) {
      index <- 0
    }
    region <- NULL
    if (index > 0 && index <= length(country$regions)) {
      region <- country$regions[[index]]
    }
    gData <-
      gtrendsData[gtrendsData$location == country$geoCountryCode, ]
    tData <- twitterData[twitterData$country == country$name, ]
    if (!is.null(region)) {
      tData <- tData[tData$region == region$name, ]
    }
    if (input$days != 0) {
      gData <- gData[gData$day == input$days, ]
      tData <- tData[tData$day == input$days, ]
    }
    
    if (nrow(tData) == 0 || nrow(gData) == 0) {
      msg <-
        plot(
          NULL,
          NULL,
          xlim = c(0, 100),
          ylim = c(0, 20),
          xaxt = 'n',
          ann = FALSE,
          yaxt = 'n',
          frame.plot = FALSE
        )
      text(8, 20, "No data")
      return(msg)
    }
    tData$one <- 1
    gData <-
      aggregate(gData$percentage, list(Hour = gData$hour), sum)
    tData <- aggregate(tData$one, list(Hour = tData$hour), sum)
    gData$x <- norm(gData$x)
    tData$x <- norm(tData$x)
    
    
    x <- list(
      title = 'Hour'
    )
    y <- list(
      title = 'Frequency'
    )
    
    out <- plot_ly(gData, x = ~Hour, y = ~x,  type = 'scatter', mode = 'lines', name = 'Gtrends') %>%
    add_trace(x = tData$Hour, y = tData$x, name = 'Twitter') %>%
    layout(showlegend = TRUE, xaxis = x, yaxis = y)
    out
  })
  
}