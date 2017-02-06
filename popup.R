library(shiny)
library(leaflet)

df <- data.frame("id" = c("1", "2"),
                 "lng" = c(-93.65, -93.655),
                 "lat" = c(42.0285, 42.03),
                 "Text" = c("Department of Statistics", "something else"))


ui <- fluidPage(
  leafletOutput("map"),
  textOutput("locationid")
)

server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
    df %>% leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(-93.65, 42.0285, zoom = 15) %>%
      addMarkers(layerId = ~id, popup = ~paste("<b>", Text, "</b>"))
  })
  
  
  id <- reactive({
    validate(
      need(!is.null(input$map_popup_click), "Please select a location from the map above")
    )
    input$map_popup_click$id
  })
  
  output$locationid <- renderText({paste("Location Selected:", id())})
  
}

shinyApp(ui, server)