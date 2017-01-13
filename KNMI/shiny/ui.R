library(shiny)


uiKnmi <- function() {
  div(plotlyOutput("weather"),
  br(),
  plotlyOutput("frequency")
  )
}