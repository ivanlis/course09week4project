library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
#  output$distPlot <- renderPlot({
    
#    # generate bins based on input$bins from ui.R
#    x    <- faithful[, 2] 
#    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
#    # draw the histogram with the specified number of bins
#    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
#  })

    library(openxlsx)
    
    waterOrg <- read.xlsx("treatability_organic.xlsx", sheet = 2, rows = 11:320, cols = 1:10, na.strings = c("NA", "--", "---", ""))
    
    #TODO: factors, grouping
    
    names(waterOrg) <- c("sample", "site", "surface_subsurface", "collection_method", "raw_treated", "alum_dose", "ph", "uv254", "color", "doc")
    
    library(dplyr)
    
    waterOrg <- waterOrg %>% filter(!is.na(ph) & !is.na(uv254) & !is.na(color) & !is.na(doc) & (!is.na(alum_dose) | raw_treated == "Raw"))
    
    waterOrg[waterOrg$raw_treated == "Raw", "alum_dose"] = 0
    
    sampleSplit <- strsplit(sprintf("%0.1f" ,waterOrg$sample), ".", fixed = TRUE)
    
    waterOrg$sampleA <- 0
    waterOrg$sampleB <- 0
    
    for (i in 1:length(sampleSplit))
    {
        waterOrg$sampleA[i] <- as.integer(sampleSplit[[i]][1])
        waterOrg$sampleB[i] <- as.integer(sampleSplit[[i]][2])
    }
    
    waterOrg$sampleA <- as.factor(waterOrg$sampleA)
    
    dataToUse <- eventReactive(input$buildButton, {
        if (length(input$origin) == 0)
            waterOrg
        else
            waterOrg[waterOrg$surface_subsurface %in% input$origin, ]
        })
    
    ourModel <- eventReactive(input$buildButton, {
        
        if (input$predictors == "color")
            lm(data = dataToUse(), formula = doc ~ color)
        else if (input$predictors == "uv")
            lm(data = dataToUse(), formula = doc ~ uv254)        
        else if (input$predictors == "colorUv")
            lm(data = dataToUse(), formula = doc ~ color + uv254)
        else if (input$predictors == "colorUvInteractions")
            lm(data = dataToUse(), formula = doc ~ color * uv254)
        else if (input$predictors == "colorUvPh")
            lm(data = dataToUse(), formula = doc ~ color + uv254 + ph)
        else
            lm(data = dataToUse(), formula = doc ~ color)
    })
    
#    prediction <- reactive({
#        predict(ourModel(), dataToUse())
#    })
    
    output$modelSummary <- renderPrint({
        summary(ourModel())
    })
    
    output$residualPlot <- renderPlot({
        
    #    library(ggplot2)
        
    #    pg <- ggplot(data = data.frame(prediction = prediction(), 
    #                                   realDoc = dataToUse()$doc),
    #                 mapping = aes(x = prediction(), y = realDoc - prediction())) + 
    #        geom_point()
    #    pg
        
        par(mfrow = c(2,2))
        plot(ourModel())
    })
    
#    output$doc <- renderUI({
#        includeHTML("gettingstarted.html")
#    })
    
    observeEvent(input$toggleDocButton, {
        if (input$toggleDocButton %% 2 == 0)
            output$doc <- renderUI({""})
        else
            output$doc <- renderUI({
                includeHTML("gettingstarted.html")
                })
    })
  
})
