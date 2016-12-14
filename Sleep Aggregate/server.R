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

regionCAggregate <- function(input, output){
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

sleepAggregate <- function(input, output){
  renderPlot({
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
    if(nrow(tData) == 0 || nrow(gData) == 0) {
      msg <- plot(NULL, NULL, xlim = c(0, 100), ylim = c(0, 20), xaxt='n', ann=FALSE, yaxt='n', frame.plot=FALSE)
      text(8, 20, "No data")
      return(msg)
    }
    gData <- aggregate(gData$weight, list(Hour = gData$hour), method)
    tData <- aggregate(tData$weight, list(Hour = tData$hour), method)
    gData$x <- norm(gData$x) * 2 - 1
    tData$x <- norm(tData$x) * 2 - 1
    combinedData <- fixIfNoData(gData)$x * 0.5 + fixIfNoData(tData)$x * 0.5
   
    out <-
      plot(
        gData$Hour,
        gData$x,
        type = 'h',
        ylab = 'Awake / Asleep',
        xlab = 'Hour'
      )
    points(tData$Hour, tData$x, type = 'l', col = 'red')
    points(gData$Hour, combinedData, type = 'l', col = 'blue')
    out
    
  });
}

totalsAggregate <- function(input, output){
 renderPlot({
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

    if(nrow(tData) == 0 || nrow(gData) == 0) {
      msg <- plot(NULL, NULL, xlim = c(0, 100), ylim = c(0, 20), xaxt='n', ann=FALSE, yaxt='n', frame.plot=FALSE)
      text(8, 20, "No data")
      return(msg)
    }
    tData$one <- 1
    gData <- aggregate(gData$percentage, list(Hour = gData$hour), sum)
    tData <- aggregate(tData$one, list(Hour = tData$hour), sum)
    gData$x <- norm(gData$x)
    tData$x <- norm(tData$x)

    out <-
      plot(
        gData$Hour,
        gData$x,
        type = 'h',
        ylab = 'Frequency',
        xlab = 'Hour'
      )
    points(tData$Hour, tData$x, type = 'l', col = 'red')
    out
  });
}