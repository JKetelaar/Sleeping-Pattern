library(shiny)

shinyUI(fluidPage(
  titlePanel("KNMI Data"),
  
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
       plotOutput("weather")
    )
  )
))
