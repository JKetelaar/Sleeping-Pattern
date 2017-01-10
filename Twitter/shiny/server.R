library(shiny)

originalData <- analyzeData(readData())

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
    data <- originalData[originalData$country == country$name,]
    if(!is.null(region)) {
      data <- data[data$region == region$name,]
    }
    method <- sum
    if(input$method == 'mean') {
      method <- mean
    }
    plot(aggregate(data$weight, list(Hour = data$hour), method), type = 'h', ylab = 'Asleep / Awake')
  })
  
})
