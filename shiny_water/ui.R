library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Dissolved Organic Carbon vs Color and UV in Water"),
  
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
       selectInput(inputId = "origin", label = "Water Origin",
                   choices = c("Runoff" = "Runoff", 
                               "Surface" = "Surface", 
                               "30 cm" = "~30 cm",
                               "60 cm" = "~60 cm"),
                   multiple = TRUE,
                   selected = c("Runoff", "Surface", "~30 cm", "~60 cm")),
       actionButton(inputId = "buildButton", label = "Build"),
       tags$br(),
       actionButton(inputId = "toggleDocButton", label = "Toggle Documentation"),
       tags$p(
           tags$a(href = "https://data.unisa.edu.au/Dataset.aspx?DatasetID=273951",
                  "Dataset web page")
       )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       htmlOutput(outputId = "doc"),
       plotOutput(outputId = "residualPlot"),
       verbatimTextOutput(outputId = "modelSummary")
    )
  )
))
