library(shiny)


shinyUI(pageWithSidebar(
  headerPanel("Bank Failures & Assistance Transactions In the US From 1970 - 2014"),
  sidebarPanel(
    h4('Select your parameters to view the graph and the data table'), 
    h5('Selection: '),
    dateInput("fromdate", "From Date:", min = "1970-01-01", max = "2015-01-01", value = "1970-01-01", format = "mm/dd/yyyy"),
    dateInput("todate", "To Date:", min = "1970-01-01", max = "2015-01-01", value = "2014-08-01", format = "mm/dd/yyyy"),
    uiOutput("state"),
    radioButtons("trantype", "Transaction Type:", choices=c("Both","Assistance","Failure"), selected = "Both"),
    sliderInput("assetsize", "Total Asset Size (*1000):", min = 0, max = 2000000000, value = c(0, 2000000000)),
    submitButton('Submit')
  ),
  mainPanel(
    plotOutput("bankPlot"),
    h4('Bank Failures & Assistance Transactions (sorted by Asset Size)'),
    dataTableOutput("filetable")
  )
))