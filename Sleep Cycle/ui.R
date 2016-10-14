source("../common/common.R")
loadPackages(c(
  "shiny",
  "ggplot2",
  "lubridate",
  "plyr",
  "shinythemes",
  "shinydashboard"
))

ui <- dashboardPage(
  dashboardHeader(title = "Sleeping Pattern"),
  dashboardSidebar(sidebarMenu(
    menuItem(
      "Sleep Cycle",
      tabName = "sleepcycle",
      icon = icon("dashboard")
    )
  )),
  dashboardBody(tabItems(
    # First tab content
    tabItem(
      tabName = "sleepcycle",
      titlePanel("Take a look at your own data!"),
      sidebarLayout(sidebarPanel(
        wellPanel(
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
        )
      ),
      mainPanel(tableOutput('contents')))
    )
  ))
)

server <- function(input, output) {
  observeEvent(input$do, {
    output$contents <- renderTable({
      inFile <- input$file1
      
      if (is.null(inFile)) {
        return(NULL)
      }
      
      sleepy <-
        read.csv(inFile$datapath,
                 header = TRUE)
      
      source("./app.R")
      frame <- toDataFrame(sleepy, input$username)
      
      insertIntoDatabase(frame)
      return(frame)
    })
  })
}

shinyApp(ui, server)