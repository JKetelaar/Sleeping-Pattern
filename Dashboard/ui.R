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
      "Your Sleep Cycle",
      tabName = "mysleepcycle",
      icon = icon("user-md")
    ),
    menuItem(
      "General Sleep Cycle",
      tabName = "sleepcycle",
      icon = icon("bed")
    ),
    menuItem("Twitter",
             tabName = "twitter",
             icon = icon("twitter"))
  )),
  dashboardBody(tabItems(
    uiAggregate(),
    uiMySleepCycle(),
    uiSleepCycle()
  ))
))