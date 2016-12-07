library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$sleep <- renderPlot({
    country <- settings$countries[[as.integer(input$country)]]
    
    data <- originalData[originalData$location == country$geoCountryCode, ]
    method <- sum
    if (input$method == 'mean') {
      method <- mean
    }
    
    if (input$days != 0) {
      data <- data[data$day == input$days,]
    }
    data <- aggregate(data$weight, list(Hour = data$hour), method)

    data$x <- norm(data$x) * 2 - 1;
    plot(data$Hour, data$x, type = 'h', ylab = 'Awake / Asleep', xlab = 'Hour')
 
  })
  
})
