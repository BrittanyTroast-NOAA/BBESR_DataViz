rm(list=ls())

library(shiny)
library(ggplot2)
library(plotly)

ui <- fluidPage(
  selectInput("data", label = h2("Choose Indicator:", style = "font-size:20px;"),
              choices = c("Oil Spills",
                          "Nuisance Aquatic Vegetation",
                          "Red Drum",
                          "Blue Crab Catch",
                          "Brown Pelican",
                          "Oyster Catch",
                          "Percent Small Business",
                          "Vessels Fishing & Seafood Dealers")),
  plotlyOutput("plot1")
)

server <- function(input, output, session) {
  
  #####Data Names#####
  dat_shrt_nms<-data.frame(c(
    oilsp="Oil Spills",
    nav="Nuisance Aquatic Vegetation",
    rdrum="Red Drum",
    blcrab="Blue Crab Catch",
    brpeli="Brown Pelican",
    oystercat="Oyster Catch",
    persmbusi="Percent Small Business",
    vesfish="Vessels Fishing & Seafood Dealers"
  ))
  dat_shrt_nms<-tibble::rownames_to_column(dat_shrt_nms)
  colnames(dat_shrt_nms)<-c("short", "long")
  
  # data_url <- "https://raw.githubusercontent.com/BrittanyTroast-NOAA/BBESR_DataViz/main/Data_Obj/Data_R/brpeli_li.r"
  
  ####Load Data Separately#####
  get_data <- reactive({
    shrt_nm<-dat_shrt_nms$short[dat_shrt_nms$long==input$data]
    filename <- paste0("https://raw.githubusercontent.com/BrittanyTroast-NOAA/BBESR_DataViz/main/Data_Obj/Data_R/",shrt_nm,"_li.r")
    dat_df<-source(url(filename))
    dat_df
  })
  
  
  output$plot1<- renderPlotly({
    
    dat_pick<-get_data()
    dat_df2<-dat_pick$value$data
    
    
    toplot<-ggplot(dat_df2, aes(x=year, y=value))+
      geom_point(color="darkturquoise")
    ly_plot<-ggplotly(toplot)
    ly_plot
  })
  
}

shinyApp(ui, server)
