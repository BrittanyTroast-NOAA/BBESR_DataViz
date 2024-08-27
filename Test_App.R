library(shiny)
library(ggplot2)
library(bslib)


mydat<-read.csv(url("https://github.com/BrittanyTroast-NOAA/BBESR_DataViz/blob/main/Data_Obj/Data_CSV/brown_peli.csv"))

ui <- fluidPage(
  tableOutput("view")
)

# dat<-dat$data

server <- function(input, output, session) {
  
  output$view <- renderTable({
    head(mydat)
  })  
  
}

shinyApp(ui = ui, server = server)
