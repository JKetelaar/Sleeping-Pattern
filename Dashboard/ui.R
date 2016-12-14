source("../common/common.R")
loadPackages(c(
  "shiny",
  "ggplot2",
  "lubridate",
  "plyr",
  "shinythemes",
  "shinydashboard"
))

source("../Sleep Aggregate/ui.R")
source("../Sleep Cycle/ui.R")

shinyUI(dashboardPage(
  dashboardHeader(title = "Sleeping Pattern"),
  dashboardSidebar(sidebarMenu(
    menuItem(
      "Sleep Cycle",
      tabName = "sleepcycle",
      icon = icon("dashboard")
    ),
    menuItem("Twitter",
             tabName = "twitter",
             icon = icon("dashboard"))
  )),
  dashboardBody(tabItems(
    uiAggregate(),
    tabItem(
      tabName = "sleepcycle",
      titlePanel("Take a look at your own data!"),
      sidebarLayout(
        sidebarPanel(wellPanel(
          fileInput(
            'file1',
            'Choose CSV File',
            accept = c('text/csv',
                       'text/comma-separated-values,text/plain',
                       '.csv'),
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
  ))
))