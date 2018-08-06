library(shiny)
library(shinyjs)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    library(openxlsx)
    
    useShinyjs()
    
    waterOrg <- read.xlsx("treatability_organic.xlsx", sheet = 2, rows = 11:320, cols = 1:10, 
                          na.strings = c("NA", "--", "---", ""))

    names(waterOrg) <- c("sample", "site", "surface_subsurface", "collection_method", "raw_treated", 
                         "alum_dose", "ph", "uv254", "color", "doc")
    
    library(dplyr)
    waterOrg <- waterOrg %>% 
        filter(!is.na(ph) & !is.na(uv254) & !is.na(color) & !is.na(doc) & (!is.na(alum_dose) | raw_treated == "Raw"))
    waterOrg[waterOrg$raw_treated == "Raw", "alum_dose"] = 0
    
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
    
    output$modelSummary <- renderPrint({
        summary(ourModel())
    })
    
    output$residualPlot <- renderPlot({
        par(mfrow = c(2,2))
        plot(ourModel())
    })
    
    
    # This way toggling seems to work on shinyapps.io
    shinyjs::html(id = "doc", includeHTML("gettingstarted.html"))
    shinyjs::onclick("toggleDocLink", shinyjs::toggle("doc"))
  
})
