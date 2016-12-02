library(shiny)

shinyServer(function(input, output) {
  output$regionC <- renderUI({
    regions <- c()
    for(region in settings$countries[[as.integer(input$country)]]$regions) {
      regions <- c(regions, region$name)
    }
    selectInput('region', label = 'Region', selected = 1, choices = regions)
  })
  output$sleep <- renderPlot({
    plot(0, 0)
  })
  
})
