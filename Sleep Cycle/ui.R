source("../common/common.R")
loadPackages(
  c(
    "shiny",
    "ggplot2",
    "lubridate",
    "plyr",
    "shinythemes",
    "shinydashboard",
    "plotly",
    "dplyr",
    "lubridate",
    "e1071"
  )
)

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
      mainPanel(
        pdf(NULL),
        h2('Sleep Quality per minute'),
        plotlyOutput('gTimeInBed'),
        
        h2('Sleep Quality by month'),
        plotlyOutput('gTimeInBedMonth'),
        
        h2('Sleep Duration'),
        plotlyOutput('gSleepDuration'),
        
        h2('Average temperature per week'),
        plotlyOutput('gAvgTempPerWeek'),
        
        h2('Effects of temperature and wind on sleep quality'),
        plotlyOutput('gTempWindSleepQuality')
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
        actionButton("do", "Submit"),
        div(id = 'loader', class = 'spinner')
      )),
      mainPanel(
        uiOutput(outputId = "progressIndicator"),
        
        textOutput('analytics'),
        
        h2('Out of bed frequency'),
        plotlyOutput('outbed'),
        
        h2('Average temperature per week'),
        plotlyOutput('avgTempPerWeek'),
        
        h2('Effects of temperature and wind on sleep quality'),
        plotlyOutput('tempWindSleepQuality'),
        
        h2('Sleep quality per date, combined with the temperature'),
        plotlyOutput('sleepQualityTempPerDate'),
        
        h2('Contents of CSV'),
        tableOutput('contents')
      )
    )
  )
}
