library(shiny)
library(ggplot2)

shinyServer(
  function(input, output) {   
    filedata <- reactive({
        read.csv("./data/hsobReport.csv")
    })
    
    output$state <- renderUI({
      df <-filedata()
      State <- levels(factor(df$State))
      State <- c("", State)
      selectInput("state", "Choose State: ", State)
    })
    
    output$bankPlot <- renderPlot({
      df <- filedata()
      df$TotalDeposits <- as.numeric(gsub(",","", df$TotalDeposits))
      df$TotalAssets <- as.numeric(gsub(",","",df$TotalAssets))
      df <- subset(df, TotalAssets >= as.numeric(input$assetsize[1]) & TotalAssets <= as.numeric(input$assetsize[2]))
      df$EffectiveDate <- as.Date(as.character(df$EffectiveDate), "%m/%d/%Y")
      df$year <- format(df$EffectiveDate, "%Y")
      if(is.null(input$state)) return (NULL)
      if(input$state != "")
        df <- df[df$State==input$state,]
      if(input$trantype == "Assistance"){
        df <- df[df$FailureAssistance=="ASSISTANCE",]
      }
      if(input$trantype == "Failure"){
        df <- df[df$FailureAssistance=="FAILURE",]
      }
      df <- subset(df, EffectiveDate >= as.Date(input$fromdate) & EffectiveDate <= as.Date(input$todate))
      plotdata <- aggregate(InstitutionName~year+CharterClass, data=df, FUN=length)
      ggplot(plotdata, aes(year, weight = InstitutionName)) + geom_bar(aes(fill=CharterClass)) + ggtitle("Bank Failure/Assistance Transactions In the US per Year") + ylab("Number of Failures/Assistance Transactions") + xlab("Year")
    })
    
    output$filetable <- renderDataTable({
      df <- filedata()
      df$TotalDeposits <- as.numeric(gsub(",","", df$TotalDeposits))
      df$TotalAssets <- as.numeric(gsub(",","",df$TotalAssets))
      df <- subset(df, TotalAssets >= as.numeric(input$assetsize[1]) & TotalAssets <= as.numeric(input$assetsize[2]))
      df$EffectiveDate <- as.Date(as.character(df$EffectiveDate), "%m/%d/%Y")
      df$year <- format(df$EffectiveDate, "%Y")
      if(is.null(input$state)) return (NULL)
      if(input$state != "")
        df <- df[df$State==input$state,]
      if(input$trantype == "Assistance"){
        df <- df[df$FailureAssistance=="ASSISTANCE",]
      }
      if(input$trantype == "Failure"){
        df <- df[df$FailureAssistance=="FAILURE",]
      }
      df <- subset(df, EffectiveDate >= as.Date(input$fromdate) & EffectiveDate <= as.Date(input$todate))
      df <- df[with(df, order(-TotalAssets)), ] 
      df <- df[, -9]
      colnames(df) <- c("Institution Name","City", "State", "Effective Date", "Charter Class", "Failure/Assistance", "Total Deposits (* $1000)", "Total Assets (* $1000)")
      df
    }, options = list(bFilter = FALSE))
  }
)