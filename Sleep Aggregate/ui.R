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

uiAggregate <- function(){
  tabItem(
  tabName = "twitter",

  titlePanel('Data'),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        'country', choices = getCountries(), label = 'Country', selected = 1
      ),
      uiOutput('regionC'),
      selectInput(
        'days',
        choices = list(
          'All' = 0,
          'Sunday' = 1,
          'Monday' = 2,
          'Tuesday' = 3,
          'Wednesday' = 4,
          'Thursday' = 5,
          'Friday' = 6,
          'Saturday' = 7
        ),
        label = 'Day',
        selected = 0
      ),
      radioButtons(
        'method',
        'Display',
        c('Total' = 'sum',
          'Mean' = 'mean'),
        selected = 'sum'
      )
    ),
    
    mainPanel(
      plotOutput('sleep'),
      plotOutput('totals')
    )
  )
)
}