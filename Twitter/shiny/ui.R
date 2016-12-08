library(shiny)

getCountries <- function() {
  countries <- list()
  i <- 1
  for(country in settings$countries) {
    countries[[country$name]] <- i
    i <- i + 1
  }
  countries
}

shinyUI(fluidPage(
  titlePanel('Tweet analysis'),
  
  sidebarLayout(
    sidebarPanel(
       selectInput(
         'country', choices = getCountries(), label = 'Country', selected = 1
       ),
       uiOutput('regionC'),
       radioButtons(
         'method',
         'Display',
         c('Total' = 'sum',
           'Mean' = 'mean'),
         selected = 'sum'
       )
    ),
    
    mainPanel(
       plotOutput('sleep')
    )
  )
))
