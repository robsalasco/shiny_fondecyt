library(shiny)
library(shinydashboard)
library(leaflet)
library(tidyverse)
library(plotly)
library(RColorBrewer)

#library(rgdal)
#library(rmapshaper)
#chl <- readOGR(dsn="data/comunas.json",encoding = "UTF-8")
#chl <- ms_simplify(chl, keep = 0.1)
#chl <- write_rds(chl,"data/chl.rds")
#muni_data <- read_csv("data/piemunicipal.csv")
#social_data <- read_csv("data/sociales.csv")
#muni_data <- write_rds(muni_data,"data/piemunicipal.rds")
#social_data <- write_rds(social_data,"data/sociales.rds")

chl <- read_rds("data/chl.rds")
muni_data <- read_rds("data/piemunicipal.rds")
social_data <- read_rds("data/sociales.rds")

ui <- dashboardPage(skin = "purple",
  dashboardHeader(title = "FONDECYT 1161417"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Comunas", icon = icon("th"), tabName = "widgets"
               , badgeColor = "green")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                box(width = 12,
                    leafletOutput("map",width="100%")
                )
  
              ),
              fluidRow(
                box(title = "Municipal income", width = 6,height = 350, status = "primary",
                    plotlyOutput("plot1",height = 300)),
                column(width = 6,
                              valueBoxOutput("povertyBox", width = 12),
                              valueBoxOutput("fpsBox", width = 12),
                              valueBoxOutput("subsidyBox", width = 12)
                       )
              )
      ),
      
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      )
    )
  )
)

server = function(input, output, session){
  output$map <- renderLeaflet({
    geoID <- as.vector(chl$id)
    geoNAME <- as.vector(chl$name)
    
    leaflet(chl) %>%
      setView(-70.1404253,-38.1671819,zoom=5) %>% 
      addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      addPolygons(
        weight = 1,
        color = '#444444',
        fillOpacity = 0.2,
        fillColor = brewer.pal(9,"Paired"),
        layerId = geoID,
        label=~geoNAME,
        labelOptions= labelOptions(direction = 'auto'),
        highlightOptions = highlightOptions(
          color='#000000', opacity = 1, weight = 1.5, fillOpacity = 0.4,
          bringToFront = T, sendToBack = T))
  })
  
  observe({ 
    click <- input$map_shape_click
    if(is.null(click))
      click$id <- "13101"
    output$plot1 <- renderPlotly({
      code <- click$id
      data <- muni_data %>% 
        filter(CODIGO==code) %>% 
        gather(VARIABLE,TOTAL,CASINO:MINERAS)
      
      comuna <- unique(data$MUNICIPIO)
      
      plot_ly(data, x = ~VARIABLE,y = ~TOTAL,type = 'bar',marker = list(color = brewer.pal(9,"Paired"))) %>% 
        layout(title =comuna,xaxis = list(title = "", tickangle = -45),
               yaxis = list(title = ""),
               margin = list(b = 100))
    })
    output$povertyBox <- renderValueBox({
      code <- click$id
      data <- social_data %>% 
        filter(CODIGO==code) %>% 
        gather(VARIABLE,TOTAL,POVERTY:`SUBSIDY NUMBER`) %>% filter(VARIABLE=="POVERTY")
      valueBox(
        data$TOTAL, "CASEN Poverty index", icon = icon("flash", lib = "glyphicon"),
        color = "red",width=NULL
      )
    })
    output$fpsBox <- renderValueBox({
      code <- click$id
      data <- social_data %>% 
        filter(CODIGO==code) %>% 
        gather(VARIABLE,TOTAL,POVERTY:`SUBSIDY NUMBER`) %>% filter(VARIABLE=="FPS NUMBER")
      valueBox(
        data$TOTAL, "FPS", icon = icon("file", lib = "glyphicon"),
        color = "green",width=NULL
      )
    })
    output$subsidyBox <- renderValueBox({
      code <- click$id
      data <- social_data %>% 
        filter(CODIGO==code) %>% 
        gather(VARIABLE,TOTAL,POVERTY:`SUBSIDY NUMBER`) %>% filter(VARIABLE=="SUBSIDY NUMBER")
      valueBox(
        data$TOTAL, "Subsidies", icon = icon("home", lib = "glyphicon"),
        color = "yellow",width=NULL
      )
    })
    
    text2<-paste("You've selected point ", click$id)
    output$Click_text<-renderText({
      text2
    })
    
  })
}

shinyApp(ui, server)