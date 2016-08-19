require(mxnet)
require(imager)
require(shiny)
require(jpeg)
require(png)

shinyUI(pageWithSidebar(
  headerPanel(title = 'Image Classification using MXNetR',
              windowTitle = 'Image Classification using MXNetR'),
  
  sidebarPanel(
    includeCSS('boot.css'),
    tabsetPanel(
      id = "tabs",
      tabPanel("Upload Image",
               fileInput('file1', 'Upload a PNG / JPEG File:')),
      tabPanel(
        "Use the URL",
        textInput("url", "Image URL:", "http://"),
        actionButton("goButton", "Go!")
      )
    )
  ),
  
  mainPanel(
    h3("Image"),
    tags$hr(),
    imageOutput("originImage", height = "auto"),
    tags$hr(),
    h3("Classification Labels"),
    tags$hr(),
    verbatimTextOutput("res")
  )
))
