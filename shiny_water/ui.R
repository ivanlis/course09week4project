library(shiny)
library(shinyjs)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  useShinyjs(),
    
  # Application title
  titlePanel("Models for Dissolved Organic Carbon in Water"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       radioButtons(inputId = "predictors", label = "Predictors to use",
                    choices = c("Color" = "color", 
                                "UV 254" = "uv",
                                "Color and UV 254" = "colorUv", 
                                "Color, UV 254 and interactions" = 
                                    "colorUvInteractions", 
                                "Color, UV 254 and PH" = 
                                    "colorUvPh"),
                    selected = c("colorUv")),
       selectInput(inputId = "origin", label = "Water origin",
                   choices = c("Runoff" = "Runoff", 
                               "Surface" = "Surface", 
                               "30 cm" = "~30 cm",
                               "60 cm" = "~60 cm"),
                   multiple = TRUE,
                   selected = c("Runoff", "Surface", "~30 cm", "~60 cm")),
       actionButton(inputId = "buildButton", label = "Build"),
       tags$br(), tags$br(),
       tags$p(
           tags$a(href = "#", "Toggle Documentation", id = "toggleDocLink")  
       ),
       tags$p(
           tags$a(href = "https://data.unisa.edu.au/Dataset.aspx?DatasetID=273951",
                  "Dataset web page")
       )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       #htmlOutput(outputId = "doc"),
       #shinyjs::hidden(uiOutput(outputId = "doc")),
       shinyjs::hidden(div(id = "doc")),
       plotOutput(outputId = "residualPlot"),
       verbatimTextOutput(outputId = "modelSummary")
    )
  )
))
