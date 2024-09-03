library(shiny)
library(ggplot2)
library(plotly)

ui <- fluidPage(
  selectInput("data", label="Choose Data", choices=c("brpeli", "blcrab")),
  plotlyOutput("plot1"),
  textOutput("testing")
)

server <- function(input, output, session) {

  # test_input<- reactive({input$data})
  # data_url <- "https://raw.githubusercontent.com/BrittanyTroast-NOAA/BBESR_DataViz/main/Data_Obj/Data_R/blcrab_li.r"
  data_url <-reactive({paste0("https://raw.githubusercontent.com/BrittanyTroast-NOAA/BBESR_DataViz/main/Data_Obj/Data_R/",input$data,"_li.r")})
  dat<-reactive({source(url(data_url()))})

  # crab<-"https://raw.githubusercontent.com/BrittanyTroast-NOAA/BBESR_DataViz/main/Data_Obj/Data_R/blcrab_li.r"
  # peli<-"https://raw.githubusercontent.com/BrittanyTroast-NOAA/BBESR_DataViz/main/Data_Obj/Data_R/brpeli_li.r"

output$plot1<- renderPlotly({
  test_dat<-dat()$value$data

  toplot<-ggplot(test_dat, aes(x=year, y=value))+
    geom_point(color="darkturquoise")
    ly_plot<-ggplotly(toplot)
    ly_plot

    })
}

shinyApp(ui, server)
