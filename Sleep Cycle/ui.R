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
    p(HTML(
      paste(
        "Here you can see a bunch of visualisations providing information about the data we've gathered during the project.",
        "This data is gathered from online sources and uploaded, anonymised data.",
        sep = "<br/>"
      )
    )),
    hr(),
    sidebarLayout(
      sidebarPanel(wellPanel(h5('Soon to come'))),
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