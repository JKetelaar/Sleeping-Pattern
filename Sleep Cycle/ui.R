source("../common/common.R")
loadPackages(c(
  "shiny",
  "ggplot2",
  "lubridate",
  "plyr",
  "shinythemes",
  "shinydashboard"
))

uiSleepCycle <- function() {
  tabItem(
    tabName = "sleepcycle",
    titlePanel("Take a look at the general data!"),
    sidebarLayout(
      sidebarPanel(wellPanel(h5('Soon to cum'))),
      mainPanel(
        h2('Sleep Quality per minute'),
        plotOutput('gTimeInBed'),
        
        h2('Sleep Quality by month'),
        plotOutput('gTimeInBedMonth'),
        
        h2('Sleep Duration'),
        plotOutput('gSleepDuration')
      )
    )
  )
}

uiMySleepCycle <- function() {
  tabItem(
    tabName = "mysleepcycle",
    titlePanel("Take a look at your own data!"),
    sidebarLayout(
      sidebarPanel(wellPanel(
        fileInput(
          'file1',
          'Choose CSV File',
          accept = c(
            'text/csv',
            'text/comma-separated-values,text/plain',
            '.csv'
          ),
          width = "800px"
        ),
        textInput('username', 'Your name'),
        actionButton("do", "Submit")
      )),
      mainPanel(
        h2('Out of bed frequency'),
        plotOutput('outbed'),
        h2('Contents of CSV'),
        tableOutput('contents')
      )
    )
  )
}