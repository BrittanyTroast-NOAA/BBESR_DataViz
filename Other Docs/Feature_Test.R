library(shiny)

ui <- fluidPage(
  selectInput(
    inputId = "indicator",
    label = "Choose an Indicator:",
    choices = list(
      "Zebra" = c("Indicator Z1", "Indicator Z2"),
      "Lion" = c("Indicator L1", "Indicator L2"),
      "Monkey" = c("Indicator M1", "Indicator M2")
    )
  ),
  textOutput("selected")
)

server <- function(input, output, session) {
  output$selected <- renderText({
    paste("You selected:", input$indicator)
  })
}

shinyApp(ui, server)
