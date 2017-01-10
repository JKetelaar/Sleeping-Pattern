library(shiny)

weatherByDay <- readData();
weatherByDay$day <- as.Date(weatherByDay$day, '%Y-%m-%d')

shinyServer(function(input, output) {
   
  output$weather <- renderPlot({
    day <- weatherByDay[weatherByDay$night == 0,]
    night <- weatherByDay[weatherByDay$night == 1,]
    out <- plot(day$day, day$temperature, type = 'l', col = 'red')
    points(night$day, night$temperature, type = 'l', col = 'blue')
    out
  })
  
})
