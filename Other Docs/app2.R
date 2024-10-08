######START APP######

library(shiny)
library(ggplot2)
library(plotly)
library(gt)
library(tidyr)
library(dplyr)
library(shinyjs)
library(bslib)

ui <- fluidPage(
  useShinyjs(),
  #Sidebar
  sidebarLayout(
    sidebarPanel(selectInput("data", label = h2(HTML("<b>Choose Indicator:</b>"), style = "font-size:22px;"),
                             choices = list(
                               'Drivers' = list("Precipitation","Air Temperature"),
                               'Pressures'=list("Oil Spills", "Nuisance Aquatic Vegetation"),
                               'States'=list("Red Drum","Brown Pelican"),
                               'Human Activities'=list("Blue Crab Catch","Oyster Catch", "Seafood Dealers & Vessels Fishing"),
                               'Human Dimensions'=list("Percent Small Business","Unemployment")
                             )),
                 selectInput("data2", label = h2(HTML("<b>Compare Indicator:</b>"), style = "font-size:22px;"),
                             choices = list("",
                                            'Drivers' = list("Precipitation","Air Temperature"),
                                            'Pressures'=list("Oil Spills", "Nuisance Aquatic Vegetation"),
                                            'States'=list("Red Drum","Brown Pelican"),
                                            'Human Activities'=list("Blue Crab Catch","Oyster Catch", "Seafood Dealers & Vessels Fishing"),
                                            'Human Dimensions'=list("Percent Small Business","Unemployment")
                             )),
                 sliderInput("yearSlider", "Year Range:", min = 1800, max = 2024, value= c(1800, 2024), sep=""),
                 tags$style("#yearSlider .irs-grid-text {font-size: 25px}"),
                 actionButton("goButton", HTML("<b>Go</b>"), style='font-size:150%'),
                 actionButton("reset", HTML("<b>Reset</b>"), style='font-size:150%'),
                 width = 2),
    #Main
    mainPanel(
                uiOutput("message_or_plot")
      
      
    ) #sidePan
    
  ) #sideLay
  
) #flpage

server <- function(input, output, session) {
  
  ####FUNCTIONS####
  # Plot from RDS object
  plot_fn_obj<-function(df_obj) {
    df_obj$data <- subset(df_obj$data, df_obj$data$year>= isolate(input$yearSlider[1]) & df_obj$data$year<= isolate(input$yearSlider[2]))
    df_obj$pos <- subset(df_obj$pos, df_obj$pos$year>= isolate(input$yearSlider[1]) & df_obj$pos$year<= isolate(input$yearSlider[2]))
    df_obj$neg <- subset(df_obj$neg, df_obj$neg$year>= isolate(input$yearSlider[1]) & df_obj$neg$year<= isolate(input$yearSlider[2]))
    
    
    if (ncol(df_obj$data)<5.5){
      #single plot
      plot_main<-ggplot(data=df_obj$data, aes(x=year, y=value))+
        geom_ribbon(data=df_obj$pos, aes(group=1,ymax=max, ymin=df_obj$vals$mean),fill="#7FFF7F")+
        geom_ribbon(data=df_obj$neg, aes(group=1,ymax=df_obj$vals$mean, ymin=min), fill="#FF7F7F")+
        geom_rect(aes(xmin=min(df_obj$data$year),xmax=max(df_obj$data$year),ymin=df_obj$vals$mean-df_obj$vals$sd, ymax=df_obj$vals$mean+df_obj$vals$sd), fill="white")+
        geom_hline(yintercept=df_obj$vals$mean, lty="dashed")+
        geom_hline(yintercept=df_obj$vals$mean+df_obj$vals$sd)+
        geom_hline(yintercept=df_obj$vals$mean-df_obj$vals$sd)+
        geom_line(aes(group=1), lwd=1)+
        labs(x="Year", y=df_obj$labs[2,2], title = df_obj$labs[1,2])+
        theme_bw() + theme(title = element_text(size=14, face = "bold"))
      
      if (max(df_obj$data$year)-min(df_obj$data$year)>20) {
        plot_main<-plot_main+scale_x_continuous(breaks = seq(min(df_obj$data$year),max(df_obj$data$year),5))
      } else {
        plot_main<-plot_main+scale_x_continuous(breaks = seq(min(df_obj$data$year),max(df_obj$data$year),2))
      }
      plot_main
      
    } else {
      #facet plot
      
      plot_sec<-ggplot(data=df_obj$data, aes(x=year, y=value))+
        facet_wrap(~subnm, ncol=ifelse(length(unique(df_obj$data$subnm))<4,1,2), scales = "free_y")+
        geom_ribbon(data=df_obj$pos, aes(group=subnm,ymax=max, ymin=mean),fill="#7FFF7F")+
        geom_ribbon(data=df_obj$neg, aes(group=subnm,ymax=mean, ymin=min), fill="#FF7F7F")+
        geom_rect(data=merge(df_obj$data,df_obj$vals), aes(xmin=min(df_obj$data$year),xmax=max(df_obj$data$year),ymin=mean-sd, ymax=mean+sd), fill="white")+
        geom_hline(aes(yintercept=mean), lty="dashed",data=df_obj$vals)+
        geom_hline(aes(yintercept=mean+sd),data=df_obj$vals)+
        geom_hline(aes(yintercept=mean-sd),data=df_obj$vals)+
        geom_line(aes(group=1), lwd=0.75)+
        labs(x="Year", y=df_obj$labs[2,2], title = df_obj$labs[1,2])+
        theme_bw()+theme(strip.background = element_blank(),
                         strip.text = element_text(face="bold"),
                         title = element_text(size=14, face = "bold"))
      
      if (max(df_obj$data$year)-min(df_obj$data$year)>20) {
        plot_sec<-plot_sec+scale_x_continuous(breaks = seq(min(df_obj$data$year),max(df_obj$data$year),5))
      } else {
        # plot_sec<-plot_sec+scale_x_continuous(breaks = seq(min(df_obj$data$year),max(df_obj$data$year),2))
      }
      plot_sec
      
    }
  }
  
  ####GET DATA####
  dat_shrt_nms<-data.frame(c(
    oilsp="Oil Spills",
    nav="Nuisance Aquatic Vegetation",
    rdrum="Red Drum",
    blcrab="Blue Crab Catch",
    brpeli="Brown Pelican",
    oystercat="Oyster Catch",
    persmbusi="Percent Small Business",
    vesfish="Seafood Dealers & Vessels Fishing",
    unemploy="Unemployment",
    precip="Precipitation",
    airtemps="Air Temperature"
  ))
  dat_shrt_nms<-tibble::rownames_to_column(dat_shrt_nms)
  colnames(dat_shrt_nms)<-c("short", "long")
  
  #Data 1
  shrt_nm<-reactive({dat_shrt_nms$short[dat_shrt_nms$long==input$data]})
  data_url <-reactive({paste0("https://raw.githubusercontent.com/BrittanyTroast-NOAA/BBESR_DataViz/main/Data_Obj/Data_R/",shrt_nm(),"_li.r")})
  dat_vl<-reactive({source(url(data_url()))})
  dat<-reactive({dat_vl()$value})
  
  #Data 2
  shrt_nm2<-reactive({dat_shrt_nms$short[dat_shrt_nms$long==input$data2]})
  data_url2 <-reactive({paste0("https://raw.githubusercontent.com/BrittanyTroast-NOAA/BBESR_DataViz/main/Data_Obj/Data_R/",shrt_nm2(),"_li.r")})
  dat_vl2<-reactive({source(url(data_url2()))})
  dat2<-reactive({dat_vl2()$value})
  
  ####CUSTOM SLIDER####
  observe({
    shinyjs::click("goButton")
  })
  
  observeEvent(input$data, {
    selected_data<- dat()$data
    updateSliderInput(session, "yearSlider",
                      min = min(selected_data$year),
                      max= max(selected_data$year),
                      value=c(min(selected_data$year), max(selected_data$year)), step=1)
  })
  
  observeEvent(input$reset,{
    selected_data<- dat()$data
    updateSliderInput(session,'yearSlider',value = c(min(selected_data$year), max(selected_data$year)))
    
  })
  
  
  
  observeEvent(input$goButton, {
    
    ####MAIN PLOT####
    output$plot<-renderPlotly({
      df_pick <- dat()
      plot_gg<-plot_fn_obj(df_pick)
      plotly_gg<-ggplotly(plot_gg)
      plotly_gg
      
    })
    
    ####OutputSwtich####
    output$message_or_plot<- renderUI({
      
      if(input$data2 == ""){
        return(h2("Please choose a second indicator from the 'Compare Indicator' dropdown"))
      } else {
        plotlyOutput("compare", height = '120%')
      }
      
    })
    
    ####Compare Plot####
    output$compare<-renderPlotly({
      
      dat1_df<-dat()
      dat2_df<-dat2()
      
      df_pick1<-dat1_df$data
      df_pick2<-dat2_df$data
      
      a_dat <- subset(df_pick1, df_pick1$year>= isolate(input$yearSlider[1]) & df_pick1$year<= isolate(input$yearSlider[2]))
      b_dat <- subset(df_pick2, df_pick2$year>= isolate(input$yearSlider[1]) & df_pick2$year<= isolate(input$yearSlider[2]))
      
      a_dat$scaled<-scale(a_dat$value)
      b_dat$scaled<-scale(b_dat$value)
      
      a_dat$indicator<-input$data
      b_dat$indicator<-input$data2
      
      ab_dat<-as.data.frame(rbind(cbind(a_dat$year, a_dat$scaled, a_dat$indicator), cbind(b_dat$year, b_dat$scaled, b_dat$indicator)))
      colnames(ab_dat)<-c("year", "scaled", "indicator")
      ab_dat[,1:2]<-lapply(ab_dat[,1:2], as.numeric)
      
      p<-ggplot(ab_dat, aes(x=year, y=scaled))+
        geom_hline(yintercept = 0, color="gray50", lwd=0.5, lty="dashed")+
        geom_line(aes(color=indicator), lwd=1)+
        scale_color_manual(values = c("blue", "red"))+
        labs(x="Year", y="Scaled Value", color="Selected Indicators")+
        theme_bw() + theme(legend.position = "bottom")
      
      ggplotly(p) %>%
        layout(legend=list(y=1.1,x=0.5, xanchor="center", yanchor="center", orientation="h"))
    })
    
    output$nocompare<-renderText({
      "Please select and indicator to compare from the 'Compare Indicator' dropdown."
    })
    

    
  })
  
}

shinyApp(ui, server)
