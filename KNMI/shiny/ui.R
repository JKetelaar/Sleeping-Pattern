library(shiny)

shinyUI(fluidPage(
  titlePanel("KNMI Data"),
  
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
       plotlyOutput("weather"),
       br(),
       plotlyOutput("frequency")
    )
  )
))
