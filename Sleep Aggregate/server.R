library(shiny)

shinyServer(function(input, output) {
  output$regionC <- renderUI({
    regions <- list('All' = 0)
    i <- 1
    for(region in settings$countries[[as.integer(input$country)]]$regions) {
      regions[[region$name]] <- i
      i <- i + 1
    }
    selectInput('region', label = 'Region', selected = 0, choices = regions)
  })
  output$sleep <- renderPlot({
    country <- settings$countries[[as.integer(input$country)]]
    index <- as.integer(input$region)
    if(is.null(input$region)) {
      index <- 0
    }
    region <- NULL
    if(index > 0 && index <= length(country$regions)) {
      region <- country$regions[[index]]
    }
    gData <- gtrendsData[gtrendsData$location == country$geoCountryCode,]
    tData <- twitterData[twitterData$country == country$name,]
    if(!is.null(region)) {
      tData <- tData[tData$region == region$name,]
    }
    if(input$days != 0) {
      gData <- gData[gData$day == input$days,]
      tData <- tData[tData$day == input$days,]
    }
    method <- sum
    if(input$method == 'mean') {
      method <- mean
    }
    gData <- aggregate(gData$weight, list(Hour = gData$hour), method)
    tData <- aggregate(tData$weight, list(Hour = tData$hour), method)
    gData$x <- norm(gData$x) * 2 - 1
    tData$x <- norm(tData$x) * 2 - 1
    out <- plot(gData$Hour, gData$x, type = 'h', ylab = 'Awake / Asleep', xlab = 'Hour')
    points(tData$Hour, tData$x, type = 'l', col = 'red')
    out
  })
})